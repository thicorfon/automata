defmodule AutomataTest do
    use ExUnit.Case

    test "dfa_test1" do
        dfa1 = %{:transitions       =>  %{:q1   => %{'a' => :q1, 'b' => :q2}, 
                                          :q2   => %{'a' => :q2, 'b' => :q1}},
                 :acceptance_states =>   [:q2],
                 :start_state       =>   :q1 }
        tape1 = ['a','b','b','a','b']
        tape2 = ['a','a','a','a']
        assert ((Automata.run_dfa_main(dfa1, tape1) == true) and
                (Automata.run_dfa_main(dfa1, tape2) == false))
    end

    test "nfa_test1" do
        nfa1 = %{:transitions       =>  %{:q0   => %{'a'        => [:q1]}, 
                                          :q1   => %{:epsilon   => [:q2]},
                                          :q2   => %{'a'        => [:q3]},
                                          :q3   => %{}},
                 :acceptance_states =>   [:q3],
                 :start_state       =>   :q0 }
        tape0 = ['a','a']
        tape1 = []
        tape2 = ['a']
        tape3 = ['a','a','a']
        assert ((Automata.run_nfa_main(nfa1, tape0) == true) and
                (Automata.run_nfa_main(nfa1, tape1) == false) and
                (Automata.run_nfa_main(nfa1, tape2) == false) and
                (Automata.run_nfa_main(nfa1, tape3) == false))
    end

    test "nfa_test2" do
        nfa2 = %{:transitions       =>  %{:q0   => %{'a' => [:q1,:q3]}, 
                                          :q1   => %{'a' => [:q2]},
                                          :q2   => %{},
                                          :q3   => %{}},
                 :acceptance_states =>   [:q2],
                 :start_state       =>   :q0 }
        tape0 = ['a','a']
        tape1 = []
        tape2 = ['a']
        tape3 = ['a','a','a']
        assert ((Automata.run_nfa_main(nfa2, tape0) == true) and
                (Automata.run_nfa_main(nfa2, tape1) == false) and
                (Automata.run_nfa_main(nfa2, tape2) == false) and
                (Automata.run_nfa_main(nfa2, tape3) == false))
    end


    test "nfa_test3" do
        nfa3 = %{:transitions       =>  %{:q0   => %{'a' => [:q1]}, 
                                          :q1   => %{'b' => [:q2]},
                                          :q2   => %{:epsilon => [:q3]},
                                          :q3   => %{:epsilon => [:q0]}},
                 :acceptance_states =>   [:q2],
                 :start_state       =>   :q0 }
        tape0 = ['a','b']
        tape1 = ['a','b','a','b','a','b']
        tape2 = ['a','b','b','b','a','b']
        tape3 = ['a','b','a','b','a']
        tape4 = []
        assert ((Automata.run_nfa_main(nfa3, tape0) == true) and
                (Automata.run_nfa_main(nfa3, tape1) == true) and
                (Automata.run_nfa_main(nfa3, tape2) == false) and
                (Automata.run_nfa_main(nfa3, tape3) == false) and
                (Automata.run_nfa_main(nfa3, tape4) == false))
    end

    test "nfa_test4" do
        nfa4 = %{:transitions       =>  %{:q0   => %{'1' => [:q1], :epsilon => [:q2]}, 
                                          :q1   => %{'0' => [:q0]},
                                          :q2   => %{}},
                 :acceptance_states =>   [:q0],
                 :start_state       =>   :q0 }
        tape0 = ['1','0']
        tape1 = []
        tape2 = ['1','1']
        tape3 = ['1','0','1','0','1','0','1','0','1','0','1','0']
        tape4 = ['1','0','1','0','1','0','1','0','1','0','1','0','1']
        assert ((Automata.run_nfa_main(nfa4,tape0) == true) and
                (Automata.run_nfa_main(nfa4,tape1) == true) and
                (Automata.run_nfa_main(nfa4,tape2) == false) and
                (Automata.run_nfa_main(nfa4,tape3) == true) and
                (Automata.run_nfa_main(nfa4,tape4) == false))
    end
end


    # test "nfa_test1" do
    #     dfa1 = %{:transitions       =>  %{:q1   => %{'b' => :q2}, 
    #                                       :q2   => %{'b' => :q1}},
    #              :acceptance_states =>   [:q2],
    #              :start_state       =>   :q1 }
    # end

    # text "nfa_teste2" do
    #     dfa1 = %{:transitions       =>  %{:q1   => %{:epsilon => :q2}, 
    #                                       :q2   => %{'b' => :q1}},
    #              :acceptance_states =>   [:q2],
    #              :start_state       =>   :q1 }
    # end







    # test "lambda_dfa_test1" do
    #     q1 = fn([tape_head|tape_tail]) ->
    #         case tape_head do
    #             'a' -> q1.(tape_tail)
    #             'b' -> q2.(tape_tail)
    #             '$' -> false    
    #         end
            
    #     end 

    #     q2 = fn([tape_head|tape_tail]) ->
    #         case tape_head do
    #             'a' -> q2.(tape_tail)
    #             'b' -> q1.(tape_tail)
    #             '$' -> true
    #         end
    #     end

    #     tape2 = ['a','b','b','a','b','$']

    #     assert Automata.run_lambda_dfa(q1,tape2) == true
    # end

