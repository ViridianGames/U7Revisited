--- Best guess: Prompts for a party member selection for training, returning the selected NPC ID.
function func_0920(eventid, itemref)
    local var_0000

    start_conversation()
    add_dialogue("@Which of you wishes to train?@")
    var_0000 = select_party_member() --- Guess: Selects party member
    return var_0000
end