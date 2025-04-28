require "U7LuaFuncs"
-- Function 04F2: Taylor's monk dialogue and smoke bomb offer
function func_04F2(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -242)
    local0 = call_0909H()
    local2 = false
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0147) then
        say("You see an attractive, studious-looking man.")
        set_flag(0x0147, true)
    else
        say("\"Yes, ", local0, ",\" Taylor asks. \"May I assist thee?\"")
    end

    if not get_flag(0x0138) then
        local2 = true
        _AddAnswer({"Emps", "wisps"})
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"My name is Taylor, ", local0, ".\"")
            _RemoveAnswer("name")
            if not get_flag(0x00E2) then
                _AddAnswer("Julius")
            end
        elseif answer == "job" then
            say("\"I study the local flora, fauna, and geography here at the monastery.\"")
            _AddAnswer({"monastery", "geography", "fauna", "flora"})
        elseif answer == "flora" then
            say("\"There are many beautiful plants in this area. I am working on learning about all of them.\"")
            _RemoveAnswer("flora")
        elseif answer == "fauna" then
            say("\"Many different species of animals reside in the forest. I have encountered some fascinating ones in my studies.\"")
            if not get_flag(0x0100) and not local2 then
                _AddAnswer("wisps")
            end
            _RemoveAnswer("fauna")
        elseif answer == "monastery" then
            say("\"Our order is called the Brotherhood of the Rose.\"")
            _AddAnswer("order")
            _RemoveAnswer("monastery")
        elseif answer == "order" then
            say("\"Yes, ", local0, ". One other monk, Aimi, lives here in the Abbey. She is a painter and a gardener.\"")
            _AddAnswer({"gardener", "painter"})
            if not get_flag(0x0148) then
                _AddAnswer("Kreg")
            end
            _RemoveAnswer("order")
        elseif answer == "painter" then
            say("He smiles. \"Between us, she is a far better gardener.\"")
            _RemoveAnswer("painter")
        elseif answer == "gardener" then
            say("\"She raises the most lovely flowers that I have ever seen! Thou must see them to believe of their existence.\"")
            _RemoveAnswer("gardener")
        elseif answer == "geography" then
            say("\"I use my knowledge of the local landscape to aid in my studies. The better I know the locale, the farther away I can travel from the Brotherhood Abbey and still be sure I will be able to return -- unlike a fellow monk of mine.\"")
            _RemoveAnswer("geography")
            _AddAnswer("fellow")
        elseif answer == "fellow" then
            say("\"He became lost some time ago while surveying the area for birds -- the Golden-Cheeked Warbler, I believe it was. Sadly, he travelled too far, and we have not heard from him since.~~\"I do not wish to suffer the same fate.\"")
            _RemoveAnswer("fellow")
        elseif answer == "Kreg" then
            say("\"That name does not sound familiar, ", local0, ". Perhaps he is not from this area.\"")
            _RemoveAnswer("Kreg")
        elseif answer == "Julius" then
            say("\"Julius? I cannot be certain, but 'tis possible he may be someone who now resides in the... cemetery. I have heard that name mentioned as someone who was brought to the Abbey to be buried, though I know not who brought him and I do not remember from whom I heard it. I do hope he was not a friend of thine,\" he says, apologetically.")
            _RemoveAnswer("Julius")
        elseif answer == "wisps" then
            say("\"The wisps?\" he laughs. \"I doubt they exist. I realize many people seem to believe in them, but I have never seen any.~~\"If thou must know, popular legend maintains that they inhabit the forest area, near the Emps. Supposedly, the Emps are able to speak with them.\" He shrugs. \"Thou mayest look for them if that is thy wish, but I would not waste precious time, myself.\"")
            _AddAnswer({"Emps", "precious time"})
            set_flag(0x0138, true)
            _RemoveAnswer("wisps")
        elseif answer == "precious time" then
            say("\"There are so many exciting things to investigate... tree flowers, for example, ", local0, ".\"")
            _RemoveAnswer("precious time")
        elseif answer == "Emps" then
            say("\"Ah, the Emps. I have not been able to glean much information about them.~~\"They live on the eastern edge of the deep forest, not too terribly far from here.~~\"They resemble apes, but only slightly. They are exceedingly shy, and will rarely feel comfortable enough to approach a human.~~\"The only way I was able to view an Emp closely occurred when I happened to have honey in my pack which I had just picked up from Bee Cave. The creature appeared, stared at me for a few minutes, and then asked -- asked, I say -- for mine honey. I believe they are empathic, hence their name.~~\"Quite an interesting species, dost thou not agree?\"")
            _AddAnswer({"Bee Cave", "honey"})
            local2 = true
            _RemoveAnswer("Emps")
        elseif answer == "honey" then
            say("\"The honey from the caves is quite tasty, but rarely can one get it without a fight. The Bee Caves can be a rather dangerous place.\"")
            _RemoveAnswer("honey")
        elseif answer == "Bee Cave" then
            say("\"Bee Cave is located to the southwest of the Abbey. But if thou art planning a trip there, beware the giant bees that live in the caves. Their venom is very poisonous.~~")
            local3 = call_0931H(1, -359, 769, 1, -357)
            if not local3 then
                say("\"If thou wishest, I can give thee a smoke bomb that will repel the bees for a short time. Dost thou want it?\"")
                local4 = call_090AH()
                if local4 then
                    local5 = callis_002C(true, -359, -359, 769, 1)
                    if local5 then
                        say("\"Here it is.\"")
                    else
                        say("\"Perhaps thou shouldst lighten thy load before taking the bomb.\"")
                    end
                else
                    say("\"Very well. But be careful if thou dost happen by the caves!\"")
                end
            end
            _RemoveAnswer("Bee Cave")
        elseif answer == "bye" then
            say("\"May thy knowledge increase with thine encounters with nature, ", local0, ".\"*")
            return
        end
    end

    return
end

-- Helper functions
function say(...)
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