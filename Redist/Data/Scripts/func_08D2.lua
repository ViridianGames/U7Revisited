--- Best guess: Manages a dialogue with a healer offering resurrection, curing, or healing services, with gold checks and party member selection.
function func_08D2(var_0000, var_0001, var_0002)
    start_conversation()
    local var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013

    var_0003 = get_lord_or_lady()
    add_dialogue("\"Dost thou want mine aid?\"")
    save_answers()
    var_0004 = ask_yes_no()
    if not var_0004 then
        add_dialogue("\"I am glad of that, " .. var_0003 .. ". I am happy to help those in need, but I would be far happier if there were never a need!\"")
        restore_answers()
        return
    end
    add_dialogue("\"What is thy need?\"")
    var_0005 = {"resurrection", "curing", "healing"}
    var_0006 = unknown_090BH(var_0005)
    if var_0006 == "healing" or var_0006 == "curing" then
        if var_0006 == "healing" then
            var_0007 = "healed"
            var_0008 = var_0002
        elseif var_0006 == "curing" then
            var_0007 = "cured"
            var_0008 = var_0001
        end
        add_dialogue("\"Who needs to be " .. var_0007 .. "?\"")
        var_0009 = unknown_090EH()
        if var_0009 == 0 then
            add_dialogue("\"None of you seem to require mine aid.\"~~She appears pleased.")
            restore_answers()
            return
        end
    elseif var_0006 == "resurrection" then
        var_0010 = unknown_0022H()
        var_0011 = unknown_000EH(25, 400, var_0010)
        var_0008 = var_0000
        if var_0011 == 0 then
            var_0011 = unknown_000EH(25, 414, var_0010)
            if var_0011 == 0 then
                add_dialogue("\"I am sorry, but thou hast not presented anyone to me who requires mine assistance. If there is someone who truly needs my skills, I must have a closer look.\"")
                restore_answers()
                return
            end
        end
    end
    add_dialogue("\"I must charge thee " .. var_0008 .. " gold. Is this price agreeable?\"")
    var_0012 = ask_yes_no()
    if var_0012 then
        var_0013 = unknown_0028H(359, 359, 644, 357)
        if var_0013 >= var_0008 then
            if var_0006 == "healing" then
                unknown_091DH(var_0008, var_0009)
            elseif var_0006 == "curing" then
                unknown_091EH(var_0008, var_0009)
            elseif var_0006 == "resurrection" then
                unknown_091FH(var_0008, var_0011)
            end
        else
            add_dialogue("\"I am sorry, " .. var_0003 .. ", but thou dost not have enough gold. Perhaps, I will be able to aid thee next time.\"")
        end
    else
        add_dialogue("\"Then I cannot help thee, " .. var_0003 .. ". I am truly sorry, but my fees are set.\"")
    end
    restore_answers()
    return
end