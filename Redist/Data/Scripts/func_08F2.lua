--- Best guess: Manages a confrontational dialogue accusing the player of deception, demanding an apology or confession, with escalating consequences based on responses.
function func_08F2(var_0000, var_0001)
    start_conversation()
    local var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    save_answers()
    var_0002 = false
    var_0003 = true
    var_0004 = unknown_08F1H("")
    add_dialogue("\"" .. var_0000 .. "! Thou " .. var_0004 .. "!\"")
    var_0005 = {"life", "head", "blood"}
    var_0006 = var_0005[math.random(1, #var_0005)]
    add_dialogue("\"Shall I have my apology, or thy " .. var_0006 .. "?\"")
    var_0007 = "Forgive me"
    var_0008 = "Suffer my wrath"
    add_answer({var_0008, var_0007})
    while true do
        if string.lower(unknown_XXXXH()) == string.lower(var_0007) then
            var_0004 = unknown_08F1H("")
            add_dialogue("\"Forgive thee! What might I forgive in one such as thee, " .. var_0004 .. "?\"")
            remove_answer(var_0008)
            remove_answer(var_0007)
            add_answer({"My crime", "My deed", "My lie"})
        elseif string.lower(unknown_XXXXH()) == string.lower(var_0008) then
            break
        elseif string.lower(unknown_XXXXH()) == "my lie" then
            remove_answer({"My crime", "My deed", "My lie"})
            add_dialogue("\"Of what lie speakest thou? Art thou not " .. var_0000 .. "?\"")
            if unknown_090AH() then
                var_0004 = unknown_08F1H("")
                add_dialogue("\"Perhaps thou art not " .. var_0000 .. ", for I have never seen the " .. var_0004 .. ". Confess now thy true identity!\"")
                add_answer(var_0001)
                if not get_flag(353) then
                    add_answer("Avatar")
                end
            else
                break
            end
        elseif string.lower(unknown_XXXXH()) == "my deed" then
            add_dialogue("\"Speak not of thy deed! Such deeds must deeds receive to equal their merit.\"")
            break
        elseif string.lower(unknown_XXXXH()) == "my crime" then
            add_dialogue("\"Crime most foul, most horrible!\"")
            var_0003 = false
            break
        elseif string.lower(unknown_XXXXH()) == "avatar" then
            remove_answer("Avatar")
            add_dialogue("\"I doubt but thou deceivest me further. If true, thou dost shame the title. Admit now thy true name!\"")
            var_0002 = true
            set_flag(353, true)
        elseif string.lower(unknown_XXXXH()) == string.lower(var_0001) then
            var_0004 = unknown_08F1H("")
            var_0009 = unknown_08F1H(var_0004)
            add_dialogue("\"" .. var_0001 .. "! Perhaps honesty shall lift thee above the " .. var_0004 .. " " .. var_0000 .. "...\"")
            var_0002 = true
            break
        end
    end
    if not var_0002 then
        var_0004 = unknown_08F1H("")
        var_0009 = unknown_08F1H(var_0004)
        if var_0003 then
            add_dialogue("^" .. var_0004 .. "! ^" .. var_0009 .. "! Thy soul shall wail in the catacombs of the netherworld!")
            unknown_001DH(0, -10)
            unknown_003DH(2, -10)
        else
            add_dialogue("^" .. var_0004 .. "! Fly from this place at once! I shall provide escort for thee with my bow. Return at thy peril, " .. var_0009 .. ".")
            unknown_001DH(9, -10)
            unknown_003DH(0, -10)
        end
    else
        add_dialogue("\"I shall not take this deception lightly.\"")
        set_flag(29, true)
        unknown_003DH(0, -10)
    end
    return
end