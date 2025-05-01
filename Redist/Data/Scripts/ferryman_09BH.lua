-- Start ferryman_09BH.lua
local strings = {
    [0x0000] = "The hooded figure in the boat ignores you completely.*",
    [0x0037] = "sacrifice",
    [0x0041] = "Before you stands a tall, skeletal figure in a ghostly boat. He holds out his hand to you, and says in a sepulchral voice, \"I am the Ferryman of Skara Brae... Thou must pay two coins... to cross the Misty Channel.\"",
    [0x0118] = "The Ferryman of Skara Brae stands in his spectral boat, holding out his hand for any who would pay his price.",
    [0x0186] = "The Ferryman of Skara Brae stands in his spectral boat, holding his pole across his chest. He notices your approach. \"You need not pay... to return to the mainland.\"",
    [0x022C] = "return",
    [0x0233] = "He seems a bit disgruntled. \"I told you I would be here... until the end of eternity.\"",
    [0x028A] = "bye",
    [0x028E] = "Skara Brae",
    [0x0299] = "Misty Channel",
    [0x02A7] = "Ferryman",
    [0x02B0] = "job",
    [0x02B4] = "name",
    [0x02B9] = "pay",
    [0x02C2] = "\"I am... the Ferryman.\" His voice creaks like the rocking of the boat.",
    [0x0312] = "The Ferryman doesn't respond at first, shaking his head from side to side in puzzlement. \"I am... the Ferryman.\"",
    [0x038C] = "\"Yes, if you pay me... I can take you across the Misty Channel.\"",
    [0x03E4] = "He turns to the side and waves his skeletal hand in a sweeping gesture over the water upon which his boat rests. \"This... is the Misty Channel.\"",
    [0x048E] = "He turns all the way around and points across the water to the west. \"There... \"",
    [0x04DF] = "\"Er... ",
    [0x04E7] = ", art thou sure we need to go over there?\"*",
    [0x0513] = "\"What's the matter, Shamino? Art thou -afraid-?\"*",
    [0x0545] = "\"Of course not! I just... well, I... oh, never mind! Let's go!\"*",
    [0x0586] = "Iolo's eyes narrow as he adopts a patronizing look on his face.~~\"And I suppose thou art without fear?\" he says to Spark.*",
    [0x0601] = "\"No, sir. I am not afraid of a skeleton,\" he says. As he looks at the ferryman, however, he gulps.*",
    [0x0665] = "The gaunt figure looks around as if perplexed. \"This... is Skara Brae.\"",
    [0x06C3] = "\"Wilt thou pay my price... for passage to Skara Brae?\"",
    [0x06FA] = "You place the coins in the shade's palm and his bony fingers close over them. \"Step aboard... if thou wouldst go... to the Isle of the Dead.\"",
    [0x0788] = "\"I'll not cross... without proper payment.\"",
    [0x07B4] = "\"Very well.\" He seems a little disappointed.",
    [0x07E1] = "\"Dost thou wish... to return to the mainland?\"",
    [0x0810] = "\"I may not carry spirits to the mainland.\" He holds his pole in front of himself, blocking your way onto the boat.",
    [0x0883] = "The Ferryman seems to smile beneath his hood as he motions for you to once more board his spectral boat.",
    [0x08EC] = "You think you see pale flames flicker in the depths of his cowl where his eyes should be. They fade as he sighs, \"No matter...\"",
    [0x0981] = "Just for a moment you think you see a fleeting expression of hope cross the Ferryman's skeletal features, then it's gone. \"I must perform my duty... until the end of eternity.\"",
    [0x0A3C] = "\"Do not taunt me... with hopes of release. I must perform my duty... until the end of eternity.\"",
    [0x0AAB] = "Without acknowledging your goodbye, the Ferryman lowers his head and holds his pole across his chest.*"
}
answers = {}
answer = nil
local debug = true
function log(...) if debug then print(...) end end

function ferryman_09BH(object_id, event)
    log("ferryman_09BH called with object_id:", object_id, "event:", event)
    if event == 1 then
        if get_flag(0x01B3) then
            add_dialogue(object_id, strings[0x0000])
            return
        end

        switch_talk_to(285, 0) -- Avatar
        local shamino_id = get_party_member(-2) -- Shamino
        local iolo_id = get_party_member(-3) -- Iolo
        local player_name = get_player_name() or "Avatar"
        local spark_id = get_party_member(-1) -- Spark

        if not get_flag(0x0198) then
            add_answer( strings[0x0037]) -- sacrifice
        end

        if not get_flag(0x01C3) then
            add_dialogue(object_id, strings[0x0041])
            set_flag(0x01C3, true)
        elseif not get_flag(0x0197) then
            add_dialogue(object_id, strings[0x0118])
        else
            add_dialogue(object_id, strings[0x0186])
            add_answer( strings[0x022C]) -- return
        end

        if get_flag(0x01A3) then
            add_dialogue(object_id, strings[0x0233])
        end

        -- Default answers
        answers = {strings[0x028A], strings[0x028E], strings[0x0299], strings[0x02A7], strings[0x02B0], strings[0x02B4]} -- bye, Skara Brae, Misty Channel, Ferryman, job, name
        if not get_flag(0x0197) then
            add_answer( strings[0x02B9]) -- pay
        end
        log("Initial answers: ", table.concat(answers, ", "))

        while true do
            if answer == strings[0x02BD] or answer == strings[0x0309] then -- name
                add_dialogue(object_id, strings[0x02C2])
                remove_answer(strings[0x0309])
            elseif answer == strings[0x030E] then -- job
                add_dialogue(object_id, strings[0x0312])
            elseif answer == strings[0x0383] or answer == strings[0x03CD] then -- Ferryman
                add_dialogue(object_id, strings[0x038C])
                remove_answer(strings[0x03CD])
            elseif answer == strings[0x03D6] or answer == strings[0x0475] then -- Misty Channel
                add_dialogue(object_id, strings[0x03E4])
                remove_answer(strings[0x0475])
            elseif answer == strings[0x0483] or answer == strings[0x06AD] then -- Skara Brae
                if not get_flag(0x0197) then
                    add_dialogue(object_id, strings[0x048E])
                    if iolo_id and shamino_id then
                        switch_talk_to(3, 0) -- Iolo
                        add_dialogue(object_id, strings[0x04DF] .. player_name .. strings[0x04E7])
                        hide_npc(3)
                        switch_talk_to(2, 0) -- Shamino
                        add_dialogue(object_id, strings[0x0513])
                        hide_npc(2)
                        switch_talk_to(3, 0) -- Iolo
                        add_dialogue(object_id, strings[0x0545])
                        hide_npc(3)
                        if spark_id then
                            switch_talk_to(1, 0) -- Spark
                            add_dialogue(object_id, strings[0x0586])
                            hide_npc(1)
                            switch_talk_to(2, 0) -- Shamino
                            add_dialogue(object_id, strings[0x0601])
                            hide_npc(2)
                        end
                        switch_talk_to(285, 0) -- Avatar
                    end
                else
                    add_dialogue(object_id, strings[0x0665])
                end
                remove_answer(strings[0x06AD])
            elseif answer == strings[0x06BF] or answer == strings[0x0973] then -- pay
                if not get_flag(0x0197) then
                    add_dialogue(object_id, strings[0x06C3])
                    local choice = get_answer()
                    if choice == 1 then
                        local paid = spend_gold(2) -- Two coins
                        if paid then
                            add_dialogue(object_id, strings[0x06FA])
                            trigger_ferry(object_id) -- Start boat travel
                        else
                            add_dialogue(object_id, strings[0x0788])
                        end
                    else
                        add_dialogue(object_id, strings[0x07B4])
                    end
                end
                remove_answer(strings[0x0973])
            elseif answer == strings[0x06B8] or answer == strings[0x096C] then -- return
                add_dialogue(object_id, strings[0x07E1])
                local choice = get_answer()
                if choice == 1 then
                    local party_members = get_party_members()
                    local is_spirit = is_party_member(-144, party_members) or is_party_member(-147, party_members)
                    if not is_spirit then
                        add_dialogue(object_id, strings[0x0810])
                    else
                        add_dialogue(object_id, strings[0x0883])
                        trigger_ferry(object_id) -- Return to mainland
                    end
                else
                    add_dialogue(object_id, strings[0x08EC])
                end
                remove_answer(strings[0x096C])
            elseif answer == strings[0x0977] or answer == strings[0x0A32] or answer == strings[0x0A9D] then -- sacrifice
                if not get_flag(0x0199) then
                    add_dialogue(object_id, strings[0x0981])
                    remove_answer(strings[0x0A32])
                    set_flag(0x0199, true)
                else
                    add_dialogue(object_id, strings[0x0A3C])
                    remove_answer(strings[0x0A9D])
                end
            elseif answer == strings[0x0AA7] then -- bye
                add_dialogue(object_id, strings[0x0AAB])
                answers = {}
                answer = nil
                return
            end
            answers = {strings[0x028A], strings[0x028E], strings[0x0299], strings[0x02A7], strings[0x02B0], strings[0x02B4]} -- Reset answers
            if not get_flag(0x0197) then
                add_answer( strings[0x02B9]) -- pay
            else
                add_answer( strings[0x022C]) -- return
            end
            if not get_flag(0x0198) then
                add_answer( strings[0x0037]) -- sacrifice
            end
            log("Updated answers: ", table.concat(answers, ", "))
        end
    elseif event == 0 then
        return
    end
    log("ferryman_09BH completed")
end
-- End ferryman_09BH.lua

