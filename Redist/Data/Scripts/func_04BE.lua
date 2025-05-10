--- Best guess: Manages Betra’s dialogue in Terfin, a provisioner skeptical of The Fellowship and concerned about racial tensions.
function func_04BE(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        switch_talk_to(0, 190)
        var_0000 = false
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(591) then
            add_dialogue("The gargoyle welcomes you by making a sweeping motion with his open hand.")
            set_flag(591, true)
        else
            add_dialogue("\"To welcome you again, human,\" says Betra.")
        end
        if get_flag(574) and not get_flag(591) then
            add_answer("Quaeven")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To be named Betra. To be new to Terfin?\"")
                var_0001 = unknown_090AH()
                if var_0001 then
                    add_dialogue("\"To tell you to talk to Teregus, the sage or Forbrak, the tavernkeeper, for information about town. To help with building locations and residents.\"")
                else
                    add_dialogue("\"To welcome you back to Terfin.\"")
                end
                remove_answer("name")
                add_answer({"Betra", "Terfin"})
                set_flag(593, true)
                if get_flag(574) and var_0000 then
                    add_answer("Quaeven")
                end
            elseif answer == "Betra" then
                add_dialogue("\"To be the word for `small valor.'\"")
                remove_answer("Betra")
            elseif answer == "job" then
                add_dialogue("\"To be the seller of provisions.\"")
                add_answer("buy")
            elseif answer == "Terfin" then
                add_dialogue("\"To be the town set aside for us gargoyles who wish to reside in our own culture.\"")
                remove_answer("Terfin")
                add_answer({"culture", "set aside"})
            elseif answer == "culture" then
                add_dialogue("\"To have many things unique to our race -- other than our appearance -- that distinguish us from humans. To be different, but also equal.\"")
                remove_answer("culture")
            elseif answer == "set aside" then
                add_dialogue("\"To have been put here by the humans. To be permitted to leave, and also to reside elsewhere, but to know that many humans do not like us.\"")
                remove_answer("set aside")
                add_answer("dislike")
            elseif answer == "dislike" then
                add_dialogue("\"To be very ironic. To say that the only town with an equal number of humans and gargoyles is the one where most racial conflicts occur.\"")
                add_dialogue("He shrugs. \"To have been unwise, perhaps, to put so many differences together. To be sad times.\"")
                remove_answer("dislike")
            elseif answer == "buy" then
                var_0002 = unknown_001CH(unknown_001BH(190))
                if var_0002 == 7 then
                    unknown_0853H()
                else
                    add_dialogue("\"To sell to you during the hours of 9 in the morning and 6 in the evening. To be sorry, but to sell nothing before or after those hours.\"")
                end
            elseif answer == "Quaeven" then
                add_dialogue("He smiles at the mention of the name.")
                add_dialogue("\"To be a likable young gargoyle.\"")
                var_0000 = true
                add_answer("join Fellowship?")
                remove_answer("Quaeven")
            elseif answer == "join Fellowship?" then
                add_dialogue("\"To join The Fellowship?\" He shakes his head. \"To be an organization not for me. To be quite happy as I am, devoted to the altars. To believe Quaeven to have been misled by the others in The Fellowship. To not trust them, especially Sarpling.\"")
                add_answer({"altars", "Sarpling", "misled"})
                remove_answer("join Fellowship?")
            elseif answer == "misled" then
                add_dialogue("\"To believe that there is deceit from The Fellowship, and to expect that is not what it appears. To believe promises of happiness made when Quaeven first joined came true from Quaeven, himself, not The Fellowship.\"")
                remove_answer("misled")
            elseif answer == "Sarpling" then
                add_dialogue("\"To trust him as far as I could throw him, and to certainly throw him as far as I could.\"")
                remove_answer("Sarpling")
            elseif answer == "altars" then
                add_dialogue("\"To have heard the rumors about destroying the altars. To be upset, but to have no evidence.\"")
                add_dialogue("\"To know that only two gargoyles have easy access to such weapons. To be one of those gargoyles, and to know Sarpling is the other.\"")
                remove_answer("altars")
            elseif answer == "bye" then
                add_dialogue("\"To wish you safe travels, human.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092FH(190)
    end
    return
end