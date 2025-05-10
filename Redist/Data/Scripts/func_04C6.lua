--- Best guess: Manages Sir Jordan’s dialogue in Serpent’s Hold, a blind knight running Iolo’s South and providing clues about the statue defacement.
function func_04C6(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid == 1 then
        switch_talk_to(0, 198)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_0908H()
        var_0002 = "Avatar"
        var_0003 = unknown_08F7H(-1)
        var_0004 = unknown_08F7H(-3)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if get_flag(606) and not get_flag(609) then
            add_answer("statue")
        end
        if not get_flag(623) then
            add_dialogue("You see a man who, despite being blind, quickly acknowledges you.")
            add_dialogue("\"I am Jordan. Sir Jordan. And thou art?\"")
            var_0006 = unknown_090BH({var_0002, var_0001})
            if var_0006 == var_0001 then
                add_dialogue("\"My pleasure, \" .. var_0001 .. \".\" He shakes your hand.")
                var_0005 = var_0001
                set_flag(602, true)
            else
                add_dialogue("He laughs. \"Yes, but of course thou art.\"")
                var_0005 = var_0002
                set_flag(603, true)
                if not var_0003 then
                    switch_talk_to(0, -1)
                    add_dialogue("\"'Tis true, Sir Jordan. He is the Avatar.\"")
                    hide_npc(1)
                    switch_talk_to(0, -198)
                    add_dialogue("Jordan smiles. \"I see. And who wouldst thou be? Shamino?\"")
                    if var_0004 then
                        switch_talk_to(0, -1)
                        add_dialogue("\"No.\" He points to Shamino. \"He is. I am Iolo!\"")
                        hide_npc(1)
                        switch_talk_to(0, -198)
                    else
                        switch_talk_to(0, -1)
                        add_dialogue("\"No. I am Iolo, not Shamino!\"")
                        hide_npc(1)
                        switch_talk_to(0, -198)
                    end
                    add_dialogue("\"Of course!\" He says, patronizingly. \"How could I not recognize the great Iolo.\"")
                end
            end
            set_flag(623, true)
        else
            add_dialogue("\"Greetings, \" .. var_0005 .. \".\"")
        end
        add_answer({"bye", "job", "name"})
        if get_flag(602) then
            var_0005 = var_0001
        elseif get_flag(603) then
            var_0005 = var_0002
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"As I told thee, my name is Sir Jordan.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I sell bows and crossbows here at Iolo's South.\"")
                add_answer({"sell", "Iolo's South"})
            elseif answer == "Iolo's South" then
                add_dialogue("\"The original branch is in Britain. But I do fine business here in the Hold.\"")
                remove_answer("Iolo's South")
                add_answer({"Hold", "original branch"})
            elseif answer == "Hold" then
                add_dialogue("\"Serpent's Hold, \" .. var_0000 .. \". I have sold many quality bows to the knights here.\"")
                remove_answer("Hold")
                add_answer("knights")
            elseif answer == "original branch" then
                add_dialogue("\"The great archer himself, Iolo, started that branch more than two hundred years ago.\"")
                if var_0003 then
                    add_dialogue("*")
                    switch_talk_to(0, -1)
                    add_dialogue("\"I, er, thank thee for thy compliment.\"")
                    switch_talk_to(0, -198)
                    add_dialogue("\"'Twould mean more wert thou Iolo!\"")
                    switch_talk_to(0, -1)
                    add_dialogue("\"Listen, here, rogue, I truly -am-...\"")
                    switch_talk_to(0, -198)
                    add_dialogue("\"Yes, yes, I know. Thou really -art- Iolo... And I am Lord British!\"")
                    hide_npc(1)
                end
                remove_answer("original branch")
            elseif answer == "knights" then
                add_dialogue("\"There are many who live within the walls of the Hold. Sir Denton, the bartender at the Hallowed Dock, knows them all.\"")
                remove_answer("knights")
            elseif answer == "sell" then
                var_0007 = unknown_001CH(unknown_001BH(198))
                if var_0007 == 7 then
                    add_dialogue("\"Weapons or missiles?\"")
                    save_answers()
                    add_answer({"missiles", "weapons"})
                else
                    add_dialogue("\"I am sorry, \" .. var_0000 .. \", but I can only sell things during my shop hours -- from 6 in the morning 'til 6 at night.\"")
                end
                remove_answer("sell")
            elseif answer == "weapons" then
                unknown_08A4H()
            elseif answer == "missiles" then
                unknown_08A3H()
            elseif answer == "statue" then
                add_dialogue("He looks defensive. \"I had nothing to do with that.\"")
                add_dialogue("\"But, I will tell thee that, on the night of the incident, I heard the sounds of scuffling in the commons. And, later on in the evening, I heard a woman cry out, as if in surprise!\"")
                add_answer("woman")
                remove_answer("statue")
                set_flag(604, true)
            elseif answer == "woman" then
                add_dialogue("\"I am not positive, \" .. var_0005 .. \", but I believe the voice was that of Lady Jehanne.\" He nods his head knowingly. \"Someone has lost their sense of unity.\"")
                remove_answer("woman")
            elseif answer == "bye" then
                add_dialogue("\"I hope to see thee again, \" .. var_0005 .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(198)
    end
    return
end