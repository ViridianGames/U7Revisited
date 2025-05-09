--- Best guess: Progresses a murder investigation with a multi-step dialogue (occupation, evidence, suspect).
function func_0884(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    start_conversation()
    var_0000 = get_player_name() --- Guess: Gets player name
    clear_answers() --- Guess: Clears conversation answers
    if not get_flag(94) then
        add_dialogue("@Very well. What was Christopher's occupation?@")
        var_0001 = show_dialogue_options({"barkeep", "provisioner", "blacksmith", "tailor"}) --- Guess: Shows dialogue options
        if var_0001 == "blacksmith" then
            set_flag(94, true)
        else
            add_dialogue("@That is not right. Thou shouldst do some more work.@")
            return
        end
    end
    if not get_flag(95) then
        clear_answers() --- Guess: Clears conversation answers
        add_dialogue("@What didst thou find at the murder site?@")
        var_0001 = show_dialogue_options({"a bucket", "a key", "a body", "nothing"}) --- Guess: Shows dialogue options
        if var_0001 == "a key" then
            set_flag(95, true)
        elseif var_0001 == "a body" then
            add_dialogue("@I know that! What ELSE didst thou find?...@")
            return
        elseif var_0001 == "a bucket" then
            add_dialogue("@Yes, obviously it is filled with poor Christopher's own blood...@")
            return
        elseif var_0001 == "nothing" then
            add_dialogue("@Thou shouldst look again, 'Avatar'!@")
            return
        end
    end
    if not get_flag(96) then
        clear_answers() --- Guess: Clears conversation answers
        add_dialogue("@What did the key open?@")
        var_0001 = show_dialogue_options({"a chest", "a trap door", "a door", "a book"}) --- Guess: Shows dialogue options
        if var_0001 == "a chest" then
            set_flag(96, true)
        else
            add_dialogue("@I do not think that is correct.@")
            return
        end
    end
    if not get_flag(97) then
        clear_answers() --- Guess: Clears conversation answers
        add_dialogue("@What didst thou find in the chest?@")
        var_0001 = show_dialogue_options({"all of these", "none of these", "a scroll", "a medallion", "gold"}) --- Guess: Shows dialogue options
        if var_0001 == "all of these" then
            clear_answers() --- Guess: Clears conversation answers
            add_dialogue("@Dost thou have a suspect?@")
            if get_dialogue_choice() then --- Guess: Gets dialogue choice
                set_flag(97, true)
            else
                add_dialogue("@Well, continue to gather information until thou dost have one.@")
                return
            end
        elseif var_0001 == "gold" or var_0001 == "a medallion" or var_0001 == "a scroll" then
            add_dialogue("@Hmmm. I cannot believe that was all...@")
            return
        elseif var_0001 == "none of these" then
            add_dialogue("@I do not believe thou hast searched properly.@")
            return
        end
    end
    if not get_flag(98) then
        clear_answers() --- Guess: Clears conversation answers
        add_dialogue("@What dost this villain look like?@")
        var_0002 = {"eyepatch", "pegleg", "scar", "I don't know"}
        if get_flag(67) then
            table.insert(var_0002, "hook")
        end
        var_0003 = show_dialogue_options(var_0002) --- Guess: Shows dialogue options
        if var_0003 == "hook" then
            set_flag(98, true)
        else
            add_dialogue("@That is not satisfactory...@")
            return
        end
    end
    if not get_flag(99) then
        clear_answers() --- Guess: Clears conversation answers
        add_dialogue("@Hmmm. Any leads on finding this villain?@")
        var_0002 = {"No one saw him", "Could be anywhere", "I don't know"}
        if get_flag(64) then
            table.insert(var_0002, "Crown Jewel")
        end
        var_0004 = show_dialogue_options(var_0002) --- Guess: Shows dialogue options
        if var_0004 == "Crown Jewel" then
            set_flag(99, true)
            add_dialogue("@The Mayor is pleased...@")
            if not get_flag(68) then
                add_dialogue("@Here is half of thy reward money...@")
                var_0005 = add_item_to_inventory(359, 644, 100, 1) --- Guess: Adds item to inventory
                if not var_0005 then
                    add_dialogue("@Thou dost not have enough companions to carry thy reward!...@")
                    set_flag(69, true)
                else
                    add_dialogue("@The Mayor hands you 100 gold coins.@")
                    set_flag(68, true)
                    set_flag(69, false)
                end
            end
            add_dialogue("@Dost thou need the password?@")
            set_flag(66, true)
            if get_dialogue_choice() then --- Guess: Gets dialogue choice
                if calle_0886H() then --- External call to geography quiz
                    add_dialogue("@Excellent! I have no doubt now that thou art the one true Avatar!@")
                    add_dialogue("@Oh-- I almost forgot! The password to leave or enter the town is 'Blackbird'!@")
                    set_flag(61, true)
                    start_quest(100) --- Guess: Starts quest
                else
                    add_dialogue("@Hmmm. I am afraid that I still have my doubts about thou being the Avatar...@")
                end
            else
                add_dialogue("@All right then. Thou dost know that thou must have the password to leave or enter our town?...@")
                if get_dialogue_choice() then --- Guess: Gets dialogue choice
                    if calle_0886H() then --- External call to geography quiz
                        add_dialogue("@Excellent! I have no doubt now that thou art the one true Avatar!@")
                        add_dialogue("@Oh-- I almost forgot! The password to leave or enter the town is 'Blackbird'!@")
                        set_flag(61, true)
                        start_quest(100) --- Guess: Starts quest
                    else
                        add_dialogue("@Hmmm. I am afraid that I still have my doubts about thou being the Avatar...@")
                    end
                else
                    add_dialogue("@All right, " .. var_0000 .. ". I thank thee for all thine help.@")
                end
            end
        else
            add_dialogue("@Hmmm. Methinks thou shouldst continue the investigation...@")
        end
    end
end