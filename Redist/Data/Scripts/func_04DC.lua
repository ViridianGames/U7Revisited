-- Function 04DC: Sullivan's dialogue and Guardian revelation
function func_04DC(eventid, itemref)
    -- Local variables (8 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid == 0 then
        call_092EH(-220)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -220)
    local0 = call_0909H()
    local1 = call_0908H()
    local2 = call_08F7H(-240)
    local3 = call_08F7H(-154)
    local4 = false
    _AddAnswer({"bye", "Fellowship", "job", "name"})

    if get_flag(0x02E2) then
        say("\"'Twas very kind of thee to release me from my cell. I shall now return to my former life. Good day!\"*")
        return
    end

    local5 = callis_001B(-220)
    calli_001D(15, local5)

    if not get_flag(0x02C2) then
        say("The man in the prison greets you with a rather large smile.")
    else
        say("\"Why, hello, ", local0, ". In what way could I help thee this fine day?\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Sullivan, ", local0, ",\" he says pleasantly. \"Who wouldst thou be?\"*")
            local6 = "the Avatar"
            local7 = call_090BH({local0, local6, local1})
            if local7 == local1 then
                say("\"Pleased to meet thee, ", local1, ".\" He moves his hand to shake yours but is prevented by the bars.~~\"Ah, well, sorry, ", local0, ". Consider thyself well shaken.\"")
            elseif local7 == local0 then
                say("\"Of course, ", local0, ". I understand.\" He smiles.")
            elseif local7 == local6 then
                say("\"Oh, I see. Oops...\" He shrugs.")
                _AddAnswer("Oops")
            end
        elseif answer == "job" then
            say("\"Well, in all honesty, ", local0, ", I have no job. Although, for a time, I was a thieving scoundrel.\"")
            _AddAnswer("scoundrel")
        elseif answer == "Fellowship" then
            say("\"'Tis truly a fantastic group of people, ", local0, ". We spread guidance and prosperity to the people who reside in our fair land. Of course, at the moment, my fellow members are a bit... displeased with me.\"")
            if not local2 then
                say("*")
                _SwitchTalkTo(0, -240)
                say("\"That's a bit of an understatement!\"*")
                _HideNPC(-240)
                _SwitchTalkTo(0, -220)
            end
            _AddAnswer({"displeased", "prosperity", "guidance"})
            _RemoveAnswer("Fellowship")
        elseif answer == "guidance" then
            say("\"The Fellowship teaches people to follow their leaders like sheep. Canst thou think of better guidance?\"")
            _RemoveAnswer("guidance")
        elseif answer == "prosperity" then
            say("\"When a member behaves properly and follows directions and so forth, he -- or she -- can hear the `inner voice' that teaches one how to win at the games. 'Tis the very reason I joined!\" he grins broadly.~~\"However, I have yet to hear the voice.\"")
            _RemoveAnswer("prosperity")
        elseif answer == "displeased" then
            say("\"Well, apparently I hadn't striven hard enough to be deserving of the loan I... acquired from the money box upstairs.\"")
            _AddAnswer({"loan", "deserving"})
            _RemoveAnswer("displeased")
        elseif answer == "deserving" then
            say("As best he can, he leans toward you. For perhaps the first time in his entire life, he turns somber. \"Actually, deserve is a relative term. I have finally realized -- being on the racks for many hours during the day leaves time for quite a number of realizations -- the true nature of The Fellowship. Batlin and Abraham and Danag, they all are in error.~~When the Guardian makes his appearance here in Britannia, I have no doubt he will simply eliminate everyone, including The Fellowship leaders.\" His smile returns.~~\"That is why I decided to get everything out of The Fellowship and Britannia now, before we are all killed.\"")
            if not local4 then
                _AddAnswer("racks")
            end
            _RemoveAnswer("deserving")
        elseif answer == "loan" then
            say("\"Well... I was going to return the money eventually. I just needed it to win more in the games.\"")
            _RemoveAnswer("loan")
        elseif answer == "Oops" then
            if not local2 then
                _SwitchTalkTo(0, -240)
                say("\"What the fool means is that he used to don a costume and pretend to be thee in an attempt to woo goods from the proprietors.\"*")
                _HideNPC(-240)
                _SwitchTalkTo(0, -220)
                say("\"Quite true, Avatar. The ruse worked far too well. 'Twas a true shame, to be honest. I should not have gotten away with it, and, indeed, am being properly castigated for it now.\"")
            else
                say("\"Oh, just that I have been impersonating thee for some time now to take items from shopkeepers without paying for them. Well, -had- been actually. Now I am being properly castigated for it.\"")
                if not local3 then
                    say("*")
                    _SwitchTalkTo(0, -154)
                    say("\"I thank thee.\"*")
                    _HideNPC(-154)
                    _SwitchTalkTo(0, -220)
                    say("\"Thou art welcome.\" He nods.*")
                end
            end
            _RemoveAnswer("Oops")
        elseif answer == "scoundrel" then
            say("\"Well, until I was caught, I would go from shop to shop all across Britannia, posing as `the Avatar.' The owners were all too happy to supply me with numerous gifts. Thou truly hast a good life, ", local0, ".\"")
            if not local2 then
                say("*")
                _SwitchTalkTo(0, -240)
                say("\"Ask him about his taxes, ", local0, ".\"*")
                _HideNPC(-240)
                _SwitchTalkTo(0, -220)
                _AddAnswer("taxes")
            end
            _AddAnswer("gifts")
            _RemoveAnswer("scoundrel")
        elseif answer == "gifts" then
            say("\"Oh, just anything I asked for -- weapons, armour, provisions, spells. Of course, I had no real use for the spells, but it was nice to acquire them for free, regardless.\"")
            _RemoveAnswer("gifts")
        elseif answer == "taxes" then
            say("He smiles.~~\"The Britannian Tax Council created a tax to raise money for the government. I did not feel like paying them,\" he shrugs, \"so I didn't. And, of course,\" he says, grinning, \"now they often put me on that fine rack.\"~~He stretches his neck and peers at the wooden slab.~~\"Very fine workmanship.\" He nods. \"Indeed, that is by far the best rack I have ever seen!\"")
            if not local4 then
                _AddAnswer("racks")
            end
            _RemoveAnswer("taxes")
        elseif answer == "racks" then
            say("\"Is not that the finest rack thou hast ever seen? Exquisite workmanship, beautiful detail.\"")
            local4 = true
            _RemoveAnswer("racks")
        elseif answer == "bye" then
            say("\"Pleasant days, ", local0, ". See thee soon on the surface world!\"*")
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