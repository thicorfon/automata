defmodule Automata do

  def getDistincts([]) do
    []
  end

  def getDistincts([head|tail])do
    if inList(head,tail) == true do
      getDistincts(tail)
    else
      [head|getDistincts(tail)]
    end
  end

#----------------------------------------------------------------------------------------------------

  def inList(_, []) do
    false
  end

  def inList(member, [head|tail]) do
    if member == head do
      true
    else
      inList(member, tail)
    end
  end

#----------------------------------------------------------------------------------------------------

  def appendList([],list) do
    list
  end

  def appendList([head|tail], list) do
    [head|appendList(tail,list)]
  end

#----------------------------------------------------------------------------------------------------

  def apply_dfa(automata, tape_head, current_state) do
    transitions = Map.get(automata, :transitions)
    current_state_transitions = Map.get(transitions, current_state)
    Map.get(current_state_transitions, tape_head)
  end

#----------------------------------------------------------------------------------------------------

  def run_dfa(automata, [], current_state) do
    if Enum.member?(Map.get(automata,:acceptance_states), current_state) do
      true
    else
      false
    end
  end

  def run_dfa(automata, tape, current_state) do
  # automata = %{:transitions => %{  :q1   => %{'a' => :q1, 'b' => :q2}, 
  #                                 :q2   => %{'a' => :q2, 'b' => :q1}} ,
  #             :acceptance_states  => [:q1,:q2],
  #             :start_state        => :q1 }
  # tape = ['a','b','a']
    [tape_head | tape_tail] = tape
    new_state = apply_dfa(automata, tape_head, current_state)
    # IO.puts(Enum.join(["Tape:"|tape]))
    # IO.puts(([Atom.to_string(current_state)|[" --"|[tape_head|["--> "|Atom.to_string(new_state)]]]]))
    # IO.puts("\n")
    run_dfa(automata, tape_tail, new_state)
  end

#----------------------------------------------------------------------------------------------------

  def run_dfa_main(automata, tape) do
    run_dfa(automata,tape,Map.get(automata, :start_state))
  end


#----------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------


  def filter_states([],_) do
    []
  end

  def filter_states(prospect_list, seen_list) do
    [prospect_head|prospect_tail] = prospect_list
    if inList(prospect_head, seen_list) do 
      filter_states(prospect_tail,seen_list)
    else
      [prospect_head|filter_states(prospect_tail,seen_list)]
    end
  end

#----------------------------------------------------------------------------------------------------

  def get_all_empty_transition_states(automata, list_of_states, seen \\[])

  def get_all_empty_transition_states(_,[],_) do
    []
  end

  def get_all_empty_transition_states(automata, list_of_states, seen) do
    [states_head|states_tail] = list_of_states
    transitions =  Map.get(automata, :transitions)
    current_state_transitions = Map.get(transitions, states_head)
    input_transitions = Map.get(current_state_transitions, :epsilon)
    if input_transitions != nil do
      possible_transitions = getDistincts(input_transitions)
      filtered_transitions = getDistincts(filter_states(possible_transitions,seen))
      appendList(filtered_transitions,get_all_empty_transition_states(automata, appendList(filtered_transitions,states_tail), appendList(filtered_transitions,seen)))
    else
      get_all_empty_transition_states(automata, states_tail, seen)
    end

  end

#----------------------------------------------------------------------------------------------------

  def get_all_non_empty_transition_states(automata, input, current_state) do
    transitions =  Map.get(automata, :transitions)
    current_state_transitions = Map.get(transitions, current_state)
    input_transitions = Map.get(current_state_transitions, input)
    if input_transitions != nil do
      getDistincts(input_transitions)
    else
      []
    end 
  end

#----------------------------------------------------------------------------------------------------

  def run_nfa(automata, [], current_state) do
    if Enum.member?(Map.get(automata,:acceptance_states), current_state) do
      true
    else
      false
    end
  end

  def run_nfa(automata, tape, current_state) do
    [tape_head | tape_tail] = tape
    possible_input_states = get_all_non_empty_transition_states(automata, tape_head, current_state)
    all_possible_states = getDistincts(appendList(possible_input_states,get_all_empty_transition_states(automata,possible_input_states)))
    # IO.puts(Enum.join(["Tape:"|tape]))
    # IO.puts([Atom.to_string(current_state)|[" --"|[tape_head|["--> "|List.to_string(Enum.drop(Enum.map(all_possible_states,fn(s) -> Atom.to_string(s) end), -1))]]]])
    # IO.puts("\n")
    if all_possible_states == [] do
      false
    else
      apply_run_nfa(automata, tape_tail, all_possible_states)
    end
  end

#----------------------------------------------------------------------------------------------------

  def apply_run_nfa(_, _, []) do
    false
  end

  def apply_run_nfa(automata, tape, list_of_states) do
    [states_head|states_tail] = list_of_states
    (run_nfa(automata, tape, states_head) or apply_run_nfa(automata,tape,states_tail))
  end

#----------------------------------------------------------------------------------------------------

  def run_nfa_main(automata, tape) do
  # automata = %{:transitions => %{ :q1   => %{:epsilon => [:q2], 'b' => [:q3]}, 
  #                                 :q2   => %{:epsilon => [:q3], 'a' => [:q2,:q4,]}} ,
  #             :acceptance_states  => [:q1,:q2],
  #             :start_state        => :q1 }
  # tape = ['a','b','a']
    start_state = Map.get(automata,:start_state)
    possible_starts = getDistincts([start_state|get_all_empty_transition_states(automata, [start_state])])
    apply_run_nfa(automata, tape, possible_starts)
  end
end