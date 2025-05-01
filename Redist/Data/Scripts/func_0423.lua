-- Manages Csil's dialogue in Britain, covering healing services, antibiotic theories, Lord British's malady, and Fellowship distrust.
function func_0423(eventid, itemref)
    local local0, local1, local2, local3, local4

    if eventid == 1 then
        switch_talk_to(35, 0)
        local0 = switch_talk_to(35)
        local1 = false

        add_answer({"bye", "services", "job", "name"})

        if not get_flag(164) then
            add_dialogue("You see a healer who looks wise and honest.")
            add_dialogue("\"I have been looking forward to thine arrival, Avatar. Word spreads quickly. I am pleased to meet thee!\"")
            set_flag(164, true)
        else
            add_dialogue("\"Hello again, Avatar!\" Csil says with a smile.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Csil the Healer, although in a past life I was known as Abrams. I became Csil when I was advanced.\"")
                remove_answer("name")
                add_answer("advanced")
            elseif answer == "job" then
                add_dialogue("\"I am Britain's healer, and have been for many years. If thou wishest to employ my services, please say so. I shall be only too happy to help.\"")
            elseif answer == "advanced" then
                add_dialogue("\"When my name was Abrams, I lived on the island of New Magincia and did mine apprentice work there. My practice grew, and soon I was travelling by ship to Moonglow to see patients there.\"")
                remove_answer("advanced")
                add_answer({"practice", "patients"})
            elseif answer == "patients" then
                add_dialogue("\"Soon I had patients on three islands. It was then that Lord British received word of my practice.\"")
                remove_answer("patients")
                add_answer("Lord British")
            elseif answer == "practice" then
                add_dialogue("\"My practice grew swiftly. I am a modest man, but I do not mind saying that I was a popular healer.\"")
                remove_answer("practice")
                local2 = get_item_type(-3)
                if local2 then
                    switch_talk_to(3, 0)
                    add_dialogue("\"He is probably the best healer in all Britannia. Why, he cured a, er, particular problem I had in no time at all.\"*")
                    local3 = get_item_type(-1)
                    if local3 then
                        switch_talk_to(1, 0)
                        add_dialogue("\"Oh? What problem was that?\"*")
                        switch_talk_to(3, 0)
                        add_dialogue("\"Never mind. The whole world does not need to know about it.\"*")
                        hide_npc(1)
                    end
                    hide_npc(3)
                    switch_talk_to(35, 0)
                end
            elseif answer == "Lord British" then
                add_dialogue("\"Well, Lord British himself was struck down with some sort of malady. He sent for me. I arrived at the castle as soon as I could leave my patients, and I examined the king. It appeared to me that something had infested his blood. I have a theory about it, which I am convinced is correct. Others, however, do not share my view.\"")
                remove_answer("Lord British")
                add_answer({"others", "theory"})
            elseif answer == "theory" then
                add_dialogue("\"I believe that most sicknesses are caused by tiny living things. We cannot see these things with the naked eye. However, I am working on developing an instrument which -can- see these creatures. I believe that someday, healing will not depend on magic at all, but on some form of treatment which makes one less vulnerable to these living creatures. Since these animals are biological, I call this theorized treatment 'antibiotics'. What dost thou think, Avatar? Am I on the right track?\"")
                remove_answer("theory")
                local4 = get_answer()
                if local4 then
                    add_dialogue("\"Good. I thought so.\"")
                else
                    add_dialogue("\"No? Hmmm.\" Csil looks concerned. \"Well, I cannot believe in the archaic tradition of bleeding a person until the sickness has left his body. There must be another way...\"~~Csil looks at his notes, worried that his theory is invalid.")
                end
            elseif answer == "others" then
                add_dialogue("\"There is a group of people who do not encourage my studies. We do not get along at all. I think they have something against healers which goes beyond simple distrust. Dost thou know whom I mean?\"")
                local4 = get_answer()
                if local4 then
                    add_dialogue("Csil nods. \"I thought so. The Fellowship is not... quite what they seem.\"")
                else
                    add_dialogue("\"No?\" Csil lowers his voice. \"The Fellowship.\"")
                end
                remove_answer("others")
                add_answer("Fellowship")
            elseif answer == "Fellowship" then
                add_dialogue("\"They have a doctrine which outlines their beliefs. They believe if one is faced with pain, then he has no choice but to go through it in order to be a 'better person'. I do not agree with this. No one should ever go through needless pain. But... they are entitled to their own opinions.\"")
                remove_answer("Fellowship")
            elseif answer == "services" then
                apply_effect(450, 30, 40) -- Unmapped intrinsic 0870
            elseif answer == "bye" then
                add_dialogue("\"Goodbye, Avatar.\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(35)
    end
    return
end