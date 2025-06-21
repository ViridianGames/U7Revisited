--- Best guess: Manages Sullivan’s dialogue in Buccaneer’s Den, a jailed Fellowship member who impersonated the Avatar, revealing insights about the organization.
function func_04DC(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid == 1 then
        switch_talk_to(0, 220)
        var_0000 = get_lord_or_lady()
        var_0001 = get_player_name()
        var_0002 = npc_id_in_party(240)
        var_0003 = npc_id_in_party(154)
        var_0004 = false
        start_conversation()
        add_answer({"bye", "Fellowship", "job", "name"})
        if get_flag(738) then
            add_dialogue("\"'Twas very kind of thee to release me from my cell. I shall now return to my former life. Good day!\"")
            return
        end
        var_0005 = get_npc_name(220)
        unknown_001DH(15, var_0005)
        if not get_flag(706) then
            add_dialogue("The man in the prison greets you with a rather large smile.")
        else
            add_dialogue("\"Why, hello, \" .. var_0000 .. \". In what way could I help thee this fine day?\"")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Sullivan, \" .. var_0000 .. \",\" he says pleasantly. \"Who wouldst thou be?\"")
                var_0006 = "the Avatar"
                var_0007 = unknown_090BH({var_0000, var_0006, var_0001})
                if var_0007 == var_0001 then
                    add_dialogue("\"Pleased to meet thee, \" .. var_0001 .. \".\" He moves his hand to shake yours but is prevented by the bars.")
                    add_dialogue("\"Ah, well, sorry, \" .. var_0000 .. \". Consider thyself well shaken.\"")
                elseif var_0007 == var_0000 then
                    add_dialogue("\"Of course, \" .. var_0000 .. \". I understand.\" He smiles.")
                elseif var_0007 == var_0006 then
                    add_dialogue("\"Oh, I see. Oops...\" He shrugs.")
                    add_answer("Oops")
                end
            elseif answer == "job" then
                add_dialogue("\"Well, in all honesty, \" .. var_0000 .. \", I have no job. Although, for a time, I was a thieving scoundrel.\"")
                add_answer("scoundrel")
            elseif answer == "Fellowship" then
                add_dialogue("\"'Tis truly a fantastic group of people, \" .. var_0000 .. \". We spread guidance and prosperity to the people who reside in our fair land. Of course, at the moment, my fellow members are a bit... displeased with me.\"")
                if var_0002 then
                    add_dialogue("*")
                    switch_talk_to(0, 240)
                    add_dialogue("\"That's a bit of an understatement!\"")
                    hide_npc(240)
                    switch_talk_to(0, 220)
                end
                remove_answer("Fellowship")
                add_answer({"displeased", "prosperity", "guidance"})
            elseif answer == "guidance" then
                add_dialogue("\"The Fellowship teaches people to follow their leaders like sheep. Canst thou think of better guidance?\"")
                remove_answer("guidance")
            elseif answer == "prosperity" then
                add_dialogue("\"When a member behaves properly and follows directions and so forth, he -- or she -- can hear the `inner voice' that teaches one how to win at the games. 'Tis the very reason I joined!\" he grins broadly.")
                add_dialogue("\"However, I have yet to hear the voice.\"")
                remove_answer("prosperity")
            elseif answer == "displeased" then
                add_dialogue("\"Well, apparently I hadn't striven hard enough to be deserving of the loan I... acquired from the money box upstairs.\"")
                remove_answer("displeased")
                add_answer({"loan", "deserving"})
            elseif answer == "deserving" then
                add_dialogue("As best he can, he leans toward you. For perhaps the first time in his entire life, he turns somber. \"Actually, deserve is a relative term. I have finally realized -- being on the racks for many hours during the day leaves time for quite a number of realizations -- the true nature of The Fellowship. Batlin and Abraham and Danag, they all are in error.\"")
                add_dialogue("When the Guardian makes his appearance here in Britannia, I have no doubt he will simply eliminate everyone, including The Fellowship leaders.\" His smile returns.")
                add_dialogue("\"That is why I decided to get everything out of The Fellowship and Britannia now, before we are all killed.\"")
                remove_answer("deserving")
                if not var_0004 then
                    add_answer("racks")
                end
            elseif answer == "loan" then
                add_dialogue("\"Well... I was going to return the money eventually. I just needed it to win more in the games.\"")
                remove_answer("loan")
            elseif answer == "Oops" then
                if var_0002 then
                    switch_talk_to(0, 240)
                    add_dialogue("\"What the fool means is that he used to don a costume and pretend to be thee in an attempt to woo goods from the proprietors.\"")
                    hide_npc(240)
                    switch_talk_to(0, 220)
                    add_dialogue("\"Quite true, Avatar. The ruse worked far too well. 'Twas a true shame, to be honest. I should not have gotten away with it, and, indeed, am being properly castigated for it now.\"")
                else
                    add_dialogue("\"Oh, just that I have been impersonating thee for some time now to take items from shopkeepers without paying for them. Well, -had- been actually. Now I am being properly castigated for it.\"")
                end
                if var_0003 then
                    add_dialogue("*")
                    switch_talk_to(0, 154)
                    add_dialogue("\"I thank thee.\"")
                    hide_npc(154)
                    switch_talk_to(0, 220)
                    add_dialogue("\"Thou art welcome.\" He nods.")
                end
                remove_answer("Oops")
            elseif answer == "scoundrel" then
                add_dialogue("\"Well, until I was caught, I would go from shop to shop all across Britannia, posing as `the Avatar.' The owners were all too happy to supply me with numerous gifts. Thou truly hast a good life, \" .. var_0000 .. \".\"")
                if var_0002 then
                    add_dialogue("*")
                    switch_talk_to(0, 240)
                    add_dialogue("\"Ask him about his taxes, \" .. var_0000 .. \".\"")
                    hide_npc(240)
                    switch_talk_to(0, 220)
                    add_answer("taxes")
                end
                add_answer("gifts")
                remove_answer("scoundrel")
            elseif answer == "gifts" then
                add_dialogue("\"Oh, just anything I asked for -- weapons, armour, provisions, spells. Of course, I had no real use for the spells, but it was nice to acquire them for free, regardless.\"")
                remove_answer("gifts")
            elseif answer == "taxes" then
                add_dialogue("He smiles.")
                add_dialogue("\"The Britannian Tax Council created a tax to raise money for the government. I did not feel like paying them,\" he shrugs, \"so I didn't. And, of course,\" he says, grinning, \"now they often put me on that fine rack.\"")
                add_dialogue("He stretches his neck and peers at the wooden slab.")
                add_dialogue("\"Very fine workmanship.\" He nods. \"Indeed, that is by far the best rack I have ever seen!\"")
                remove_answer("taxes")
                if not var_0004 then
                    add_answer("racks")
                end
            elseif answer == "racks" then
                add_dialogue("\"Is not that the finest rack thou hast ever seen? Exquisite workmanship, beautiful detail.\"")
                var_0004 = true
                remove_answer("racks")
            elseif answer == "bye" then
                add_dialogue("\"Pleasant days, \" .. var_0000 .. \". See thee soon on the surface world!\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(220)
    end
    return
end