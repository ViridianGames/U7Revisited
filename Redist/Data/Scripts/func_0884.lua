--- Best guess: Progresses a murder investigation with a multi-step dialogue (occupation, evidence, suspect).
function func_0884(eventid, objectref)
    debug_print("Starting func_0884(), reporting to Finnigan")
    local var_884_0000, var_884_0001, var_884_0002, var_884_0003, var_884_0004, var_884_0005, var_884_0006
    debug_print("Declared local variables")
    -- --start_conversation()
    var_884_0000 = get_player_name() --- Guess: Gets player name
    if not get_flag(94) then

        var_884_0001 = ask_multiple_choice({"\"Very well. What was Christopher's occupation?\"", "barkeep", "provisioner", "blacksmith", "tailor"})
        if var_884_0001 == "blacksmith" then
            set_flag(94, true)
        else
            add_dialogue("\"That is not right. Thou shouldst do some more work.\"")
            return
        end
    end
    if not get_flag(95) then
        var_884_0001 = ask_multiple_choice({"\"What didst thou find at the murder site?\"", "a bucket", "a key", "a body", "nothing"})
        if var_884_0001 == "a key" then
            set_flag(95, true)
        elseif var_884_0001 == "a body" then
            add_dialogue("\"I know that! What ELSE didst thou find? Thou shouldst look again, Avatar!\"")
            return
        elseif var_884_0001 == "a bucket" then
            add_dialogue("\"Yes, obviously it is filled with poor Christopher's own blood. But surely there was something else that might point us in the direction of the killer or killers - thou shouldst look again, Avatar.\"")
            return
        elseif var_884_0001 == "nothing" then
            add_dialogue("\"Thou shouldst look again, 'Avatar'!\"")
            return
        end
    end
    if not get_flag(96) then
        var_884_0001 = ask_multiple_choice({"\"What did the key open?\"", "a chest", "a trap door", "a door", "a book"})
        if var_884_0001 == "a chest" then
            set_flag(96, true)
        else
            add_dialogue("\"I do not think that is correct.\"")
            return
        end
    end
    if not get_flag(97) then
        var_884_0001 = ask_multiple_choice({"\"What didst thou find in the chest?\"", "all of these", "none of these", "a scroll", "a medallion", "gold"})
        if var_884_0001 == "all of these" then
            var_884_0002 = ask_yes_no("\"Dost thou have a suspect?\"")
            if var_884_0002 then
                set_flag(97, true)
            else
                add_dialogue("\"Well, continue to gather information until thou dost have one.\"")
                return
            end
        elseif var_884_0001 == "gold" or var_884_0001 == "a medallion" or var_884_0001 == "a scroll" then
            add_dialogue("\"Hmmm. I cannot believe that was all...\"")
            return
        elseif var_884_0001 == "none of these" then
            add_dialogue("\"I do not believe thou hast searched properly.\"")
            return
        end
    end
    if not get_flag(98) then
        var_884_0002 = {"\"What dost this villain look like?\"", "eyepatch", "pegleg", "scar", "I don't know"}
        if get_flag(67) then
            table.insert(var_884_0002, "hook")
        end
        var_884_0003 = ask_multiple_choice(var_884_0002)
        if var_884_0003 == "hook" then
            set_flag(98, true)
        else
            add_dialogue("\"That is not satisfactory...\"")
            return
        end
    end
    if not get_flag(99) then
        var_884_0002 = {"\"Hmmm. Any leads on finding this villain?\"", "No one saw him", "Could be anywhere", "I don't know"}
        if get_flag(64) then
            table.insert(var_884_0002, "Crown Jewel")
        end
        var_884_0004 = ask_multiple_choice(var_884_0002)
        if var_884_0004 == "Crown Jewel" then
            set_flag(99, true)
            add_dialogue("The Mayor is pleased...")
            if not get_flag(68) then
                add_dialogue("\"Here is half of thy reward money...\"")
                var_884_0005 = add_object_to_npc_inventory(0, 644, 1, 100)
                if not var_884_0005 then
                    add_dialogue("\"Thou dost not have enough companions to carry thy reward!...\"")
                    set_flag(69, true)
                else
                    add_dialogue("\"The Mayor hands you 100 gold coins.\"")
                    set_flag(68, true)
                    set_flag(69, false)
                end
            end
            set_flag(66, true)
            var_884_0001 = ask_yes_no("\"Dost thou need the password?\"")
            if var_884_0001 then
               add_dialogue("\"Excellent! I have no doubt now that thou art the one true Avatar!\"")
               add_dialogue("\"Oh-- I almost forgot! The password to leave or enter the town is 'Blackbird'!\"")
               set_flag(61, true)
                 --start_quest(100) --- Guess: Starts quest
            else
               add_dialogue("\"All right then. Thou dost know that thou must have the password to leave or enter our town?...\"")
               add_dialogue("\"All right, " .. var_884_0000 .. ". I thank thee for all thine help.\"")
            end
        end
    end
end
