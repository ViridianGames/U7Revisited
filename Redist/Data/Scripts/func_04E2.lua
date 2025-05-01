-- Function 04E2: Blacktooth's dialogue and Mole reconciliation
function func_04E2(eventid, itemref)
    -- Local variables (12 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    if eventid == 0 then
        local9 = callis_001C(callis_001B(-226))
        if local9 == 11 then
            local10 = callis_Random2(4, 1)
            if local10 == 1 then
                local11 = "@Har!@"
            elseif local10 == 2 then
                local11 = "@Avast!@"
            elseif local10 == 3 then
                local11 = "@Blast!@"
            elseif local10 == 4 then
                local11 = "@Damn parrot droppings...@"
            end
            _ItemSay(local11, -226)
        else
            call_092EH(-226)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(226, 0)
    local0 = call_0908H()
    local1 = callis_0067()
    local2 = "Avatar"
    local3 = callis_001B(-226)
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x02A3) then
        local4 = local0
    elseif not get_flag(0x02A4) then
        local4 = local2
    end

    if not get_flag(0x02A5) and not get_flag(0x02A7) then
        _AddAnswer("Mole says...")
    end

    if not get_flag(0x02AF) then
        say("This tall, middle-aged pirate looks at you with suspicion.~~\"Before I will look twice at thee, I must know who thou art.\" His voice is menacing.")
        local5 = call_090BH({local2, local0})
        if local5 == local0 then
            say("The pirate chews on something in his mouth before replying. \"Hi,\" he finally says.")
            set_flag(0x02A3, true)
            local4 = local0
        elseif local5 == local2 then
            say("The pirate looks as if you have just insulted his mother.~~\"I... do... not... like... Avatars!!\"~~The pirate spits on the ground. \"But thou dost not look as much like fishbait as the last Avatar I spoke with. All right. I will speak with thee.\"")
            set_flag(0x02A4, true)
            local4 = local2
        end
        set_flag(0x02AF, true)
    elseif get_flag(0x02A6) or not get_flag(0x02A5) then
        say("\"What dost thou want?\" Blacktooth asks in a threatening voice. \"Oh, 'tis thee, ", local4, ".\"")
    else
        say("\"I thought thou didst not want to be my friend!\" Blacktooth grumbles.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Blacktooth. See?\" The pirate smiles, revealing his teeth.")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"Making fishbait out of Avatars!\" He laughs aloud. \"I have had all I can stand of puny weaklings running around claiming they are an Avatar! I am seeking a particular Avatar that was here last week. A particular Avatar that is a Fellowship member!\"")
            _AddAnswer({"Fellowship", "Avatar"})
        elseif answer == "Avatar" then
            say("\"He was through here a week ago. Tried to filch some gold off of me! Imagine! The nerve of that bastard! He was gone before I had realized what he had done.\"")
            _RemoveAnswer("Avatar")
            _AddAnswer("filch")
        elseif answer == "filch" then
            say("\"We were playing cards in the pub. Damn me if he did not deal from the bottom. I can usually spot tricks like that, but he was good!\"")
            if local1 then
                say("The pirate notices your Fellowship medallion. \"I see that thou art one of them, too!\"")
            end
            _RemoveAnswer("filch")
        elseif answer == "Fellowship" then
            if local1 then
                local6 = "@No offense to thee, but "
            else
                local6 = "@Between thou and me, "
            end
            say(local6, "I do not trust 'em. I think they are all hiding something. I think they are all tricksters. Take mine old friend Mole, for example. Well, mine old ex-friend Mole. He has changed a great deal since joining them.\"")
            _RemoveAnswer("Fellowship")
            _AddAnswer({"changed", "Mole"})
        elseif answer == "Mole" then
            say("\"He is another aging pirate that has retired and lives on the island. We were mates for years, but then he joined that damned Fellowship. Now he thinks his droppings do not smell foul, if thou knowest what I mean.\"")
            _RemoveAnswer("Mole")
        elseif answer == "changed" then
            say("\"He has abandoned all of his pirate ways! He is a bloody saint now, and whenever he sees me he tries to convince me to join The Fellowship. I avoid him at all costs now. I cannot stand to see him this way. It burns my blood!\"~~Then, in a moment of weakness, the tough pirate says in a small voice, \"I miss him, too. We were best mates.\" You could swear there are tears in his eyes.*")
            local7 = call_08F7H(-2)
            if not local7 then
                switch_talk_to(2, 0)
                say("Spark whispers, \"Oh, come on, be a man!\"*")
                _HideNPC(-2)
                local8 = call_08F7H(-4)
                if not local8 then
                    switch_talk_to(4, 0)
                    say("Dupre turns away to suppress a smirk.*")
                    _HideNPC(-4)
                end
                switch_talk_to(226, 0)
            end
            say("You can see that the pirate is upset, so you decide to leave him alone.~~\"Yeah, go away. That's right! I never can keep any friends!")
            if not get_flag(0x02A4) then
                say("\"That would be just like an Avatar to leave me like this!")
            end
            if local1 then
                say("\"Typical Fellowship member! That's right! Leave me alone! Go away!")
            end
            say("\"I shall just remain here alone and destitute! Where is my dagger? I shall slit my throat!!\"")
            _RemoveAnswer("changed")
            set_flag(0x02A5, true)
            if not get_flag(0x02A7) then
                _AddAnswer("Mole says...")
            end
        elseif answer == "Mole says..." then
            say("\"He said that? Really?\" Blacktooth looks as if he may cry again.~~\"I must go take a look for him. I thank thee, ", local4, ", for considering my feelings in this matter.\" Blacktooth gives you a big hug, then turns away to look for Mole.*")
            _RemoveAnswer("Mole says...")
            set_flag(0x02A6, true)
            call_0911H(20)
            calli_001D(12, local3)
            return
        elseif answer == "bye" then
            if get_flag(0x02A6) or not get_flag(0x02A5) then
                say("\"Another time, then.\"*")
            else
                say("\"Yeah, goodbye! Leave! They all leave me alone eventually!\"*")
            end
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