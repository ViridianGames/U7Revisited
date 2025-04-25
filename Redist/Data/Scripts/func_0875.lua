-- Function 0875: Denby training dialogue
function func_0875(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    local2 = select_training_target(eventid, itemref)
    local3 = _GetNPCName(local2)
    local4 = _GetPlayerName(local2)
    if local3 == local4 then
        local3 = "you"
    end
    if local2 == 0 then
        return
    end
    local5 = 3
    local6 = check_training_eligibility(local5, local2, eventid, itemref)
    if local6 == 0 then
        say(itemref, "\"I am sorry, but thou dost not have enough practical experience to train at this time. If thou couldst return at a later date, I would be most happy to train thee.\"")
        return
    elseif local6 == 1 then
        local7 = check_gold(-359, -359, 644, -357)
        say(itemref, "\"You gather your gold and count it, finding that you have " .. local7 .. " gold altogether.\"")
        if local7 < eventid then
            say(itemref, "\"I regret that thou dost not seem to have enough gold to train here. Mayhaps at another time, when thy fortunes are more prosperous...\"")
            return
        end
    elseif local6 == 2 then
        say(itemref, "\"Thou art already as proficient as I! I am afraid that thou cannot be trained further in this.\"")
        return
    end
    local8 = remove_gold(true, -359, -359, 644, eventid)
    say(itemref, "\"You pay " .. eventid .. " gold, and the training session begins.\"")
    if local3 == "you" then
        local9 = "complete"
        local10 = "feel"
        local11 = "your"
        local12 = "spend"
        local13 = "you"
    else
        local9 = "completes"
        local10 = "feels"
        local11 = "their"
        local12 = "spends"
        local13 = "them"
    end
    say(itemref, "\"Denby hands " .. local3 .. " a chart with runes printed on it. \\\"Study these runes and memorize them,\\\" he says. After " .. local3 .. " " .. local9 .. " this task, " .. local3 .. " " .. local10 .. " that there is a bit of knowledge in " .. local11 .. " mind that was not there earlier.~~\\\"Now we shall exercise. Practice what I teach thee at least twice a day. Then thou shalt become more agile and limber.\\\" ^" .. local3 .. " " .. local12 .. " a while mimicking the movements which Denby shows " .. local13 .. ". Finally, Denby teaches " .. local13 .. " a few magic words to intone for meditational purposes. When the training session is complete, " .. local3 .. " " .. local10 .. " much more energized and ready for anything that might come " .. local11 .. " way...*\"")
    local14 = get_stat(1, local2)
    local15 = get_stat(2, local2)
    local16 = get_stat(6, local2)
    if local14 < 30 then
        train_strength(1, local2)
    end
    if local15 < 30 then
        train_dexterity(1, local2)
    end
    if local16 < 30 then
        train_intelligence(1, local2)
    end
    return
end