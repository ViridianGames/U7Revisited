--- Best guess: Manages Pamela’s dialogue, the innkeeper at the Out’n’Inn in Cove, discussing her business, her affection for Rayburt and his dog Regal, and room rentals, with flag-based transactions and a loop for party member pricing.
function func_044E(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid ~= 1 then
        if eventid == 0 then
            unknown_092EH(78)
        end
        add_dialogue("\"See thee soon!\"")
        return
    end

    start_conversation()
    switch_talk_to(0, 78)
    var_0000 = unknown_001CH(get_npc_name(78))
    add_answer({"bye", "job", "name"})
    if not get_flag(228) then
        add_answer("Rayburt")
    end
    if not get_flag(235) then
        add_dialogue("You see a friendly woman in her thirties.")
        set_flag(235, true)
    else
        add_dialogue("\"Greetings, again!\" Pamela says.")
    end
    add_answer("Out'n Inn")
    while true do
        if cmps("name") then
            add_dialogue("\"I am Pamela!\"")
            remove_answer("name")
            if not get_flag(228) then
                add_answer("Rayburt")
            end
            set_flag(240, true)
        elseif cmps("job") then
            add_dialogue("\"I am the Innkeeper at the Out'n'Inn.\"")
            if var_0000 == 16 or var_0000 == 11 then
                add_dialogue("\"If thou wouldst like a room, just say so!\"")
                add_answer("room")
            elseif var_0000 == 26 then
                add_dialogue("\"Please come by if thou wouldst like to rest thy weary feet for the night!\"")
            end
        elseif cmps("room") then
            add_dialogue("\"The room is quite inexpensive. Only 8 gold per person. Want one?\"")
            if ask_yes_no() then
                var_0001 = get_party_members()
                var_0002 = 0
                for i = 1, var_0001 do
                    var_0002 = var_0002 + 1
                end
                var_0006 = var_0002 * 8
                var_0007 = unknown_0028H(359, 359, 644, 357)
                if var_0007 >= var_0006 then
                    var_0008 = unknown_002CH(true, 359, 255, 641, 1)
                    if not var_0008 then
                        add_dialogue("\"Thou art carrying too much to take the room key!\"")
                    else
                        add_dialogue("\"Here is thy room key. It is good only until thou leavest.\"")
                        var_0009 = unknown_002BH(359, 359, 644, var_0006)
                    end
                else
                    add_dialogue("\"Thou dost not have enough gold, eh? Too bad.\"")
                end
            else
                add_dialogue("\"Another night, then.\"")
            end
            remove_answer("room")
        elseif cmps("Out'n Inn") then
            add_dialogue("\"Well... Cove is the city of Love and Passion, didst thou not know? Thou must be careful. If thou dost stay too long in Cove, thou wilt fall in love with someone! Mark my words!\"")
            remove_answer("Out'n Inn")
        elseif cmps("Rayburt") then
            add_dialogue("\"Oooh, he is such a wonderful man, dost thou not think? He is so intense and serious. Handsome, too! Oh, and I like Regal as well.\"")
            remove_answer("Rayburt")
            add_answer("Regal")
        elseif cmps("Regal") then
            add_dialogue("\"As far as dogs go, he is handsome, too!\"")
            remove_answer("Regal")
        elseif cmps("bye") then
            break
        end
    end
    return
end