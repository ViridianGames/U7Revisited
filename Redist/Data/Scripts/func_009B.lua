--- Best guess: Manages the Ferryman of Skara Brae's dialogue, handling payment for passage, return trips, and refusal of sacrifice, with party member interactions (Shamino, Spark, Iolo).
function func_009B(eventid, itemref)
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        switch_talk_to(285, 0)
        var_0000 = unknown_08F7H(-2)
        var_0001 = unknown_08F7H(-3)
        var_0002 = unknown_0908H()
        if not get_flag(435) then
            add_dialogue("The hooded figure in the boat ignores you completely.")
            return
        end
        if not get_flag(408) then
            add_answer("sacrifice")
        end
        if not get_flag(451) then
            add_dialogue("Before you stands a tall, skeletal figure in a ghostly boat. He holds out his hand to you, and says in a sepulchral voice, \"I am the Ferryman of Skara Brae... Thou must pay two coins... to cross the Misty Channel.\"")
            set_flag(451, true)
        elseif not get_flag(407) then
            add_dialogue("The Ferryman of Skara Brae stands in his spectral boat, holding out his hand for any who would pay his price.")
        else
            add_dialogue("The Ferryman of Skara Brae stands in his spectral boat, holding his pole across his chest. He notices your approach. \"You need not pay... to return to the mainland.\"")
            add_answer("return")
        end
        if get_flag(419) then
            add_dialogue("He seems a bit disgruntled. \"I told you I would be here... until the end of eternity.\"")
        end
        add_answer({"bye", "Skara Brae", "Misty Channel", "Ferryman", "job", "name"})
        if not get_flag(407) then
            add_answer("pay")
        end
        while true do
            local response = string.lower(unknown_XXXXH())
            if response == "name" then
                add_dialogue("\"I am... the Ferryman.\" His voice creaks like the rocking of the boat.")
                remove_answer("name")
            elseif response == "job" then
                add_dialogue("The Ferryman doesn't respond at first, shaking his head from side to side in puzzlement. \"I am... the Ferryman.\"")
            elseif response == "ferryman" then
                add_dialogue("\"Yes, if you pay me... I can take you across the Misty Channel.\"")
                remove_answer("Ferryman")
            elseif response == "misty channel" then
                add_dialogue("He turns to the side and waves his skeletal hand in a sweeping gesture over the water upon which his boat rests. \"This... is the Misty Channel.\"")
                remove_answer("Misty Channel")
            elseif response == "skara brae" then
                if not get_flag(407) then
                    add_dialogue("He turns all the way around and points across the water to the west. \"There... \"")
                    if not (var_0001 and var_0000) then
                        switch_talk_to(3, 0)
                        add_dialogue("\"Er... " .. var_0002 .. ", art thou sure we need to go over there?\"")
                        unknown_0004H(-3)
                        switch_talk_to(2, 0)
                        add_dialogue("\"What's the matter, Shamino? Art thou -afraid-?\"")
                        unknown_0004H(-2)
                        switch_talk_to(3, 0)
                        add_dialogue("\"Of course not! I just... well, I... oh, never mind! Let's go!\"")
                        unknown_0004H(-3)
                        var_0003 = unknown_08F7H(-1)
                        if var_0003 then
                            switch_talk_to(1, 0)
                            add_dialogue("Iolo's eyes narrow as he adopts a patronizing look on his face.~~\"And I suppose thou art without fear?\" he says to Spark.")
                            unknown_0004H(-1)
                            switch_talk_to(2, 0)
                            add_dialogue("\"No, sir. I am not afraid of a skeleton,\" he says. As he looks at the ferryman, however, he gulps.")
                            unknown_0004H(-2)
                        end
                        switch_talk_to(285, 0)
                    end
                else
                    add_dialogue("The gaunt figure looks around as if perplexed. \"This... is Skara Brae.\"")
                end
                remove_answer("Skara Brae")
            elseif response == "pay" or response == "return" then
                remove_answer({"return", "pay"})
                if not get_flag(407) then
                    add_dialogue("\"Wilt thou pay my price... for passage to Skara Brae?\"")
                    var_0004 = unknown_090AH()
                    if var_0004 then
                        var_0005 = unknown_002BH(true, 359, 359, 644, 2)
                        if var_0005 then
                            add_dialogue("You place the coins in the shade's palm and his bony fingers close over them. \"Step aboard... if thou wouldst go... to the Isle of the Dead.\"")
                            unknown_0882H(itemref)
                        else
                            add_dialogue("\"I'll not cross... without proper payment.\"")
                        end
                    else
                        add_dialogue("\"Very well.\" He seems a little disappointed.")
                    end
                else
                    add_dialogue("\"Dost thou wish... to return to the mainland?\"")
                    var_0004 = unknown_090AH()
                    if var_0004 then
                        var_0006 = unknown_001BH(-144)
                        var_0007 = unknown_0023H()
                        var_0008 = unknown_001BH(-147)
                        if table.contains(var_0007, var_0006) or table.contains(var_0007, var_0008) then
                            add_dialogue("The Ferryman seems to smile beneath his hood as he motions for you to once more board his spectral boat.")
                            unknown_0882H(itemref)
                        else
                            add_dialogue("\"I may not carry spirits to the mainland.\" He holds his pole in front of himself, blocking your way onto the boat.")
                        end
                    else
                        add_dialogue("You think you see pale flames flicker in the depths of his cowl where his eyes should be. They fade as he sighs, \"No matter...\"")
                    end
                end
            elseif response == "sacrifice" then
                if not get_flag(409) then
                    add_dialogue("Just for a moment you think you see a fleeting expression of hope cross the Ferryman's skeletal features, then it's gone. \"I must perform my duty... until the end of eternity.\"")
                    remove_answer("sacrifice")
                    set_flag(409, true)
                else
                    add_dialogue("\"Do not taunt me... with hopes of release. I must perform my duty... until the end of eternity.\"")
                    remove_answer("sacrifice")
                end
            elseif response == "bye" then
                add_dialogue("Without acknowledging your goodbye, the Ferryman lowers his head and holds his pole across his chest.")
                return
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end