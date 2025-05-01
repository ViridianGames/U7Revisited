-- Function 04F2: Taylor's monk dialogue and smoke bomb offer
function func_04F2(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(242, 0)
    local0 = call_0909H()
    local2 = false
    add_answer({"bye", "job", "name"})

    if not get_flag(0x0147) then
        add_dialogue("You see an attractive, studious-looking man.")
        set_flag(0x0147, true)
    else
        add_dialogue("\"Yes, ", local0, ",\" Taylor asks. \"May I assist thee?\"")
    end

    if not get_flag(0x0138) then
        local2 = true
        add_answer({"Emps", "wisps"})
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"My name is Taylor, ", local0, ".\"")
            remove_answer("name")
            if not get_flag(0x00E2) then
                add_answer("Julius")
            end
        elseif answer == "job" then
            add_dialogue("\"I study the local flora, fauna, and geography here at the monastery.\"")
            add_answer({"monastery", "geography", "fauna", "flora"})
        elseif answer == "flora" then
            add_dialogue("\"There are many beautiful plants in this area. I am working on learning about all of them.\"")
            remove_answer("flora")
        elseif answer == "fauna" then
            add_dialogue("\"Many different species of animals reside in the forest. I have encountered some fascinating ones in my studies.\"")
            if not get_flag(0x0100) and not local2 then
                add_answer("wisps")
            end
            remove_answer("fauna")
        elseif answer == "monastery" then
            add_dialogue("\"Our order is called the Brotherhood of the Rose.\"")
            add_answer("order")
            remove_answer("monastery")
        elseif answer == "order" then
            add_dialogue("\"Yes, ", local0, ". One other monk, Aimi, lives here in the Abbey. She is a painter and a gardener.\"")
            add_answer({"gardener", "painter"})
            if not get_flag(0x0148) then
                add_answer("Kreg")
            end
            remove_answer("order")
        elseif answer == "painter" then
            add_dialogue("He smiles. \"Between us, she is a far better gardener.\"")
            remove_answer("painter")
        elseif answer == "gardener" then
            add_dialogue("\"She raises the most lovely flowers that I have ever seen! Thou must see them to believe of their existence.\"")
            remove_answer("gardener")
        elseif answer == "geography" then
            add_dialogue("\"I use my knowledge of the local landscape to aid in my studies. The better I know the locale, the farther away I can travel from the Brotherhood Abbey and still be sure I will be able to return -- unlike a fellow monk of mine.\"")
            remove_answer("geography")
            add_answer("fellow")
        elseif answer == "fellow" then
            add_dialogue("\"He became lost some time ago while surveying the area for birds -- the Golden-Cheeked Warbler, I believe it was. Sadly, he travelled too far, and we have not heard from him since.~~\"I do not wish to suffer the same fate.\"")
            remove_answer("fellow")
        elseif answer == "Kreg" then
            add_dialogue("\"That name does not sound familiar, ", local0, ". Perhaps he is not from this area.\"")
            remove_answer("Kreg")
        elseif answer == "Julius" then
            add_dialogue("\"Julius? I cannot be certain, but 'tis possible he may be someone who now resides in the... cemetery. I have heard that name mentioned as someone who was brought to the Abbey to be buried, though I know not who brought him and I do not remember from whom I heard it. I do hope he was not a friend of thine,\" he says, apologetically.")
            remove_answer("Julius")
        elseif answer == "wisps" then
            add_dialogue("\"The wisps?\" he laughs. \"I doubt they exist. I realize many people seem to believe in them, but I have never seen any.~~\"If thou must know, popular legend maintains that they inhabit the forest area, near the Emps. Supposedly, the Emps are able to speak with them.\" He shrugs. \"Thou mayest look for them if that is thy wish, but I would not waste precious time, myself.\"")
            add_answer({"Emps", "precious time"})
            set_flag(0x0138, true)
            remove_answer("wisps")
        elseif answer == "precious time" then
            add_dialogue("\"There are so many exciting things to investigate... tree flowers, for example, ", local0, ".\"")
            remove_answer("precious time")
        elseif answer == "Emps" then
            add_dialogue("\"Ah, the Emps. I have not been able to glean much information about them.~~\"They live on the eastern edge of the deep forest, not too terribly far from here.~~\"They resemble apes, but only slightly. They are exceedingly shy, and will rarely feel comfortable enough to approach a human.~~\"The only way I was able to view an Emp closely occurred when I happened to have honey in my pack which I had just picked up from Bee Cave. The creature appeared, stared at me for a few minutes, and then asked -- asked, I say -- for mine honey. I believe they are empathic, hence their name.~~\"Quite an interesting species, dost thou not agree?\"")
            add_answer({"Bee Cave", "honey"})
            local2 = true
            remove_answer("Emps")
        elseif answer == "honey" then
            add_dialogue("\"The honey from the caves is quite tasty, but rarely can one get it without a fight. The Bee Caves can be a rather dangerous place.\"")
            remove_answer("honey")
        elseif answer == "Bee Cave" then
            add_dialogue("\"Bee Cave is located to the southwest of the Abbey. But if thou art planning a trip there, beware the giant bees that live in the caves. Their venom is very poisonous.~~")
            local3 = call_0931H(1, -359, 769, 1, -357)
            if not local3 then
                add_dialogue("\"If thou wishest, I can give thee a smoke bomb that will repel the bees for a short time. Dost thou want it?\"")
                local4 = call_090AH()
                if local4 then
                    local5 = callis_002C(true, -359, -359, 769, 1)
                    if local5 then
                        add_dialogue("\"Here it is.\"")
                    else
                        add_dialogue("\"Perhaps thou shouldst lighten thy load before taking the bomb.\"")
                    end
                else
                    add_dialogue("\"Very well. But be careful if thou dost happen by the caves!\"")
                end
            end
            remove_answer("Bee Cave")
        elseif answer == "bye" then
            add_dialogue("\"May thy knowledge increase with thine encounters with nature, ", local0, ".\"*")
            return
        end
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end