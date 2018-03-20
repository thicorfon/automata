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
    transitions = Map.get(automata, :transitions) # Get the automata transitions
    current_state_transitions = Map.get(transitions, current_state) # Get all transitions from the current state
    Map.get(current_state_transitions, tape_head) # Gets the next state based on tape_head
  end

#----------------------------------------------------------------------------------------------------

  def run_dfa(automata, [], current_state) do
  # If the tape is empty, checks if last state is an acceptance_state. Returns true or false
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
  # Receives an automata, a tape and the current_state and re_runs the dfa with the next element in the tape and with its new state
    [tape_head | tape_tail] = tape
    new_state = apply_dfa(automata, tape_head, current_state)
    run_dfa(automata, tape_tail, new_state)
  end

#----------------------------------------------------------------------------------------------------

  def run_dfa_main(automata, tape) do
  # Receives a dfa and a tape and returns true if tape is accepted by automata.
    run_dfa(automata,tape,Map.get(automata, :start_state))
  end


#----------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------


  def filter_states([],_) do
    []
  end

  def filter_states(prospect_list, seen_list) do
  # Receives a prospect_list of states and drops all elements that appear in seen_list. used for avoiding loops.
    [prospect_head|prospect_tail] = prospect_list
    if inList(prospect_head, seen_list) do 
      filter_states(prospect_tail,seen_list)
    else
      [prospect_head|filter_states(prospect_tail,seen_list)]
    end
  end

#----------------------------------------------------------------------------------------------------

  def get_all_empty_transition_states(automata, list_of_states, seen \\[])
  # Receives an automata, a list_of_states and already seen states (default = []) and returns all states than can be reached via empty transitions.

  def get_all_empty_transition_states(_,[],_) do
  # If there are no more states to check, returns []
    []
  end

  def get_all_empty_transition_states(automata, list_of_states, seen) do
    [states_head|states_tail] = list_of_states
    transitions =  Map.get(automata, :transitions) # Get the automata transitions
    current_state_transitions = Map.get(transitions, states_head) # Get all transitions from the current_state
    input_transitions = Map.get(current_state_transitions, :epsilon) # Get all states that can be reached from the current_state with empty transitions
    if input_transitions != nil do # If there isn't an empty transition, Map.get returns :nil. If it doesn't find anything, returns nil
      possible_transitions = getDistincts(input_transitions)
      filtered_transitions = getDistincts(filter_states(possible_transitions,seen)) # Drops every element that was already seen
      appendList(filtered_transitions,get_all_empty_transition_states(automata, appendList(filtered_transitions,states_tail), appendList(filtered_transitions,seen))) # Calls get_all_empty_transition_states recursively, appending the new-found states to states_tail and seen.
    else
      get_all_empty_transition_states(automata, states_tail, seen)
    end

  end

#----------------------------------------------------------------------------------------------------

  def get_all_non_empty_transition_states(automata, input, current_state) do
  # Receives an automata, a input, and the current_state and returns a list of all states that can be reached.
    transitions =  Map.get(automata, :transitions) # Get the automata transitions
    current_state_transitions = Map.get(transitions, current_state) # Get all transitions from the current_state
    input_transitions = Map.get(current_state_transitions, input) # Get all states that can be reached from the current_state with given input
    if input_transitions != nil do # If there isn't a transition for given input, Map.get returns :nil. If it doesn't return :nil, returns input_transitions
      getDistincts(input_transitions)
    else
      []
    end 
  end

#----------------------------------------------------------------------------------------------------

  def run_nfa(automata, [], current_state) do
    if Enum.member?(Map.get(automata,:acceptance_states), current_state) do # If tape is empty and current_state is an acceptance_state, returns true 
      true
    else
      false
    end
  end

  def run_nfa(automata, tape, current_state) do
  # Receives an automata, a tape and the automata current_state, 
  # discovers all the states that can be reach from the given input and reruns the NFA for each one of them
    [tape_head | tape_tail] = tape
    possible_input_states = get_all_non_empty_transition_states(automata, tape_head, current_state) # From the current_state, evaluates input and get all other states 
                                                                                                    # that can be reached from said input
    all_possible_states = getDistincts(appendList(possible_input_states,get_all_empty_transition_states(automata,possible_input_states))) # For each of these states, get other states 
                                                                                                                                          # that can be reached doing empty transitions
                                                                                                                                          # and append to states already found
    if all_possible_states == [] do # If no states can be reached, returns false
      false
    else
      apply_run_nfa(automata, tape_tail, all_possible_states) # Creates new NFA's with starting states as each member on the list
    end
  end

#----------------------------------------------------------------------------------------------------

  def apply_run_nfa(_, _, []) do
    false # If there is no more states, return false (OR neutral)
  end

  def apply_run_nfa(automata, tape, list_of_states) do
    [states_head|states_tail] = list_of_states
    (run_nfa(automata, tape, states_head) or apply_run_nfa(automata,tape,states_tail)) # Calls run_nfa recursively
  end

#----------------------------------------------------------------------------------------------------

  def run_nfa_main(automata, tape) do
  # automata = %{:transitions => %{ :q1   => %{:epsilon => [:q2], 'b' => [:q3]}, 
  #                                 :q2   => %{:epsilon => [:q3], 'a' => [:q2,:q4,]}} ,
  #             :acceptance_states  => [:q1,:q2],
  #             :start_state        => :q1 }
  # tape = ['a','b','a']
  #
  # Returns if given tape is accepted by the NFA
    start_state = Map.get(automata,:start_state) # Get automata start_state
    possible_starts = getDistincts([start_state|get_all_empty_transition_states(automata, [start_state])]) # Get all other states that can be reached by
                                                                                                           # empty transitions from start_state
    apply_run_nfa(automata, tape, possible_starts) # Runs the NFA
  end
end