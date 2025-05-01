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

    switch_talk_to(220, 0)
    local0 = call_0909H()
    local1 = call_0908H()
    local2 = call_08F7H(-240)
    local3 = call_08F7H(-154)
    local4 = false
    add_answer({"bye", "Fellowship", "job", "name"})

    if get_flag(0x02E2) then
        add_dialogue("\"'Twas very kind of thee to release me from my cell. I shall now return to my former life. Good day!\"*")
        return
    end

    local5 = callis_001B(-220)
    calli_001D(15, local5)

    if not get_flag(0x02C2) then
        add_dialogue("The man in the prison greets you with a rather large smile.")
    else
        add_dialogue("\"Why, hello, ", local0, ". In what way could I help thee this fine day?\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am Sullivan, ", local0, ",\" he says pleasantly. \"Who wouldst thou be?\"*")
            local6 = "the Avatar"
            local7 = call_090BH({local0, local6, local1})
            if local7 == local1 then
                add_dialogue("\"Pleased to meet thee, ", local1, ".\" He moves his hand to shake yours but is prevented by the bars.~~\"Ah, well, sorry, ", local0, ". Consider thyself well shaken.\"")
            elseif local7 == local0 then
                add_dialogue("\"Of course, ", local0, ". I understand.\" He smiles.")
            elseif local7 == local6 then
                add_dialogue("\"Oh, I see. Oops...\" He shrugs.")
                add_answer("Oops")
            end
        elseif answer == "job" then
            add_dialogue("\"Well, in all honesty, ", local0, ", I have no job. Although, for a time, I was a thieving scoundrel.\"")
            add_answer("scoundrel")
        elseif answer == "Fellowship" then
            add_dialogue("\"'Tis truly a fantastic group of people, ", local0, ". We spread guidance and prosperity to the people who reside in our fair land. Of course, at the moment, my fellow members are a bit... displeased with me.\"")
            if not local2 then
                add_dialogue("*")
                switch_talk_to(240, 0)
                add_dialogue("\"That's a bit of an understatement!\"*")
                _HideNPC(-240)
                switch_talk_to(220, 0)
            end
            add_answer({"displeased", "prosperity", "guidance"})
            remove_answer("Fellowship")
        elseif answer == "guidance" then
            add_dialogue("\"The Fellowship teaches people to follow their leaders like sheep. Canst thou think of better guidance?\"")
            remove_answer("guidance")
        elseif answer == "prosperity" then
            add_dialogue("\"When a member behaves properly and follows directions and so forth, he -- or she -- can hear the `inner voice' that teaches one how to win at the games. 'Tis the very reason I joined!\" he grins broadly.~~\"However, I have yet to hear the voice.\"")
            remove_answer("prosperity")
        elseif answer == "displeased" then
            add_dialogue("\"Well, apparently I hadn't striven hard enough to be deserving of the loan I... acquired from the money box upstairs.\"")
            add_answer({"loan", "deserving"})
            remove_answer("displeased")
        elseif answer == "deserving" then
            add_dialogue("As best he can, he leans toward you. For perhaps the first time in his entire life, he turns somber. \"Actually, deserve is a relative term. I have finally realized -- being on the racks for many hours during the day leaves time for quite a number of realizations -- the true nature of The Fellowship. Batlin and Abraham and Danag, they all are in error.~~When the Guardian makes his appearance here in Britannia, I have no doubt he will simply eliminate everyone, including The Fellowship leaders.\" His smile returns.~~\"That is why I decided to get everything out of The Fellowship and Britannia now, before we are all killed.\"")
            if not local4 then
                add_answer("racks")
            end
            remove_answer("deserving")
        elseif answer == "loan" then
            add_dialogue("\"Well... I was going to return the money eventually. I just needed it to win more in the games.\"")
            remove_answer("loan")
        elseif answer == "Oops" then
            if not local2 then
                switch_talk_to(240, 0)
                add_dialogue("\"What the fool means is that he used to don a costume and pretend to be thee in an attempt to woo goods from the proprietors.\"*")
                _HideNPC(-240)
                switch_talk_to(220, 0)
                add_dialogue("\"Quite true, Avatar. The ruse worked far too well. 'Twas a true shame, to be honest. I should not have gotten away with it, and, indeed, am being properly castigated for it now.\"")
            else
                add_dialogue("\"Oh, just that I have been impersonating thee for some time now to take items from shopkeepers without paying for them. Well, -had- been actually. Now I am being properly castigated for it.\"")
                if not local3 then
                    add_dialogue("*")
                    switch_talk_to(154, 0)
                    add_dialogue("\"I thank thee.\"*")
                    _HideNPC(-154)
                    switch_talk_to(220, 0)
                    add_dialogue("\"Thou art welcome.\" He nods.*")
                end
            end
            remove_answer("Oops")
        elseif answer == "scoundrel" then
            add_dialogue("\"Well, until I was caught, I would go from shop to shop all across Britannia, posing as `the Avatar.' The owners were all too happy to supply me with numerous gifts. Thou truly hast a good life, ", local0, ".\"")
            if not local2 then
                add_dialogue("*")
                switch_talk_to(240, 0)
                add_dialogue("\"Ask him about his taxes, ", local0, ".\"*")
                _HideNPC(-240)
                switch_talk_to(220, 0)
                add_answer("taxes")
            end
            add_answer("gifts")
            remove_answer("scoundrel")
        elseif answer == "gifts" then
            add_dialogue("\"Oh, just anything I asked for -- weapons, armour, provisions, spells. Of course, I had no real use for the spells, but it was nice to acquire them for free, regardless.\"")
            remove_answer("gifts")
        elseif answer == "taxes" then
            add_dialogue("He smiles.~~\"The Britannian Tax Council created a tax to raise money for the government. I did not feel like paying them,\" he shrugs, \"so I didn't. And, of course,\" he says, grinning, \"now they often put me on that fine rack.\"~~He stretches his neck and peers at the wooden slab.~~\"Very fine workmanship.\" He nods. \"Indeed, that is by far the best rack I have ever seen!\"")
            if not local4 then
                add_answer("racks")
            end
            remove_answer("taxes")
        elseif answer == "racks" then
            add_dialogue("\"Is not that the finest rack thou hast ever seen? Exquisite workmanship, beautiful detail.\"")
            local4 = true
            remove_answer("racks")
        elseif answer == "bye" then
            add_dialogue("\"Pleasant days, ", local0, ". See thee soon on the surface world!\"*")
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