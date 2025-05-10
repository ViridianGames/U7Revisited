--- Best guess: Handles dialogue with Csil, Britain’s healer, discussing his healing services, past as Abrams, and a theory on antibiotics, with tensions regarding the Fellowship.
function func_0423(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    start_conversation()
    if eventid == 1 then
        switch_talk_to(35, 0)
        var_0000 = unknown_001CH(35) --- Guess: Gets object state
        add_answer({"bye", "services", "job", "name"})
        if not get_flag(164) then
            add_dialogue("You see a healer who looks wise and honest.")
            add_dialogue("\"I have been looking forward to thine arrival, Avatar. Word spreads quickly. I am pleased to meet thee!\"")
            set_flag(164, true)
        else
            add_dialogue("\"Hello again, Avatar!\" Csil says with a smile.")
        end
        while true do
            var_0001 = get_answer()
            if var_0001 == "name" then
                add_dialogue("\"I am Csil the Healer, although in a past life I was known as Abrams. I became Csil when I was advanced.\"")
                remove_answer("name")
                add_answer("advanced")
            elseif var_0001 == "job" then
                add_dialogue("\"I am Britain's healer, and have been for many years. If thou wishest to employ my services, please say so. I shall be only too happy to help.\"")
            elseif var_0001 == "advanced" then
                add_dialogue("\"When my name was Abrams, I lived on the island of New Magincia and did mine apprentice work there. My practice grew, and soon I was travelling by ship to Moonglow to see patients there.\"")
                remove_answer("advanced")
                add_answer({"practice", "patients"})
            elseif var_0001 == "patients" then
                add_dialogue("\"Soon I had patients on three islands. It was then that Lord British received word of my practice.\"")
                remove_answer("patients")
                add_answer("Lord British")
            elseif var_0001 == "practice" then
                add_dialogue("\"My practice grew swiftly. I am a modest man, but I do not mind saying that I was a popular healer.\"")
                remove_answer("practice")
                var_0001 = unknown_08F7H(3) --- Guess: Checks player status
                if var_0001 then
                    switch_talk_to(3, 0)
                    add_dialogue("\"He is probably the best healer in all Britannia. Why, he cured a, er, particular problem I had in no time at all.\"")
                    var_0002 = unknown_08F7H(1) --- Guess: Checks player status
                    if var_0002 then
                        hide_npc(3)
                        switch_talk_to(1, 0)
                        add_dialogue("\"Oh? What problem was that?\"")
                        hide_npc(1)
                        switch_talk_to(3, 0)
                        add_dialogue("\"Never mind. The whole world does not need to know about it.\"")
                    end
                    hide_npc(3)
                    switch_talk_to(35, 0)
                end
            elseif var_0001 == "Lord British" then
                add_dialogue("\"Well, Lord British himself was struck down with some sort of malady. He sent for me. I arrived at the castle as soon as I could leave my patients, and I examined the king. It appeared to me that something had infested his blood. I have a theory about it, which I am convinced is correct. Others, however, do not share my view.\"")
                remove_answer("Lord British")
                add_answer({"others", "theory"})
            elseif var_0001 == "theory" then
                add_dialogue("\"I believe that most sicknesses are caused by tiny living things. We cannot see these things with the naked eye. However, I am working on developing an instrument which -can- see these creatures. I believe that someday, healing will not depend on magic at all, but on some form of treatment which makes one less vulnerable to these living creatures. Since these animals are biological, I call this theorized treatment 'antibiotics'. What dost thou think, Avatar? Am I on the right track?\"")
                remove_answer("theory")
                var_0003 = select_option()
                if var_0003 then
                    add_dialogue("\"Good. I thought so.\"")
                else
                    add_dialogue("\"No? Hmmm.\" Csil looks concerned. \"Well, I cannot believe in the archaic tradition of bleeding a person until the sickness has left his body. There must be another way...\"")
                    add_dialogue("Csil looks at his notes, worried that his theory is invalid.")
                end
            elseif var_0001 == "others" then
                add_dialogue("\"There is a group of people who do not encourage my studies. We do not get along at all. I think they have something against healers which goes beyond simple distrust. Dost thou know whom I mean?\"")
                var_0004 = select_option()
                if var_0004 then
                    add_dialogue("Csil nods. \"I thought so. The Fellowship is not... quite what they seem.\"")
                else
                    add_dialogue("\"No?\" Csil lowers his voice. \"The Fellowship.\"")
                end
                remove_answer("others")
                add_answer("Fellowship")
            elseif var_0001 == "Fellowship" then
                add_dialogue("\"They have a doctrine which outlines their beliefs. They believe if one is faced with pain, then he has no choice but to go through it in order to be a 'better person'. I do not agree with this. No one should ever go through needless pain. But... they are entitled to their own opinions.\"")
                remove_answer("Fellowship")
            elseif var_0001 == "services" then
                unknown_0870H(450, 30, 40) --- Guess: Performs healing, curing, or resurrection
            elseif var_0001 == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye, Avatar.\"")
    elseif eventid == 0 then
        unknown_092EH(35) --- Guess: Triggers a game event
    end
end