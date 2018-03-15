defmodule Automata do

  def apply_dfa(automata, tape_head, current_state) do
    transitions = Map.get(automata, :transitions)
    current_state_transitions = Map.get(transitions, current_state)
    Map.get(current_state_transitions, tape_head)
  end

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
    run_dfa(automata, tape_tail, new_state)
  end

  def run_dfa_main(automata,tape) do
    run_dfa(automata,tape,Map.get(automata, :start_state))
  end

end

