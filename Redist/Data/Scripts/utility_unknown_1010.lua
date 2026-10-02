--- Confrontational dialogue when Tseramed believes the Avatar lied about identity.
function utility_unknown_1010(player_name, fellowship_leader)
    save_answers()
    local confessed = false
    local demand_blood = true
    local insult = utility_unknown_1009("")
    add_dialogue("\"" .. player_name .. "! Thou " .. insult .. "!\"")
    local stakes = {"life", "head", "blood"}
    local stake = stakes[math.random(1, #stakes)]
    add_dialogue("\"Shall I have my apology, or thy " .. stake .. "?\"")
    local forgive = "Forgive me"
    local wrath = "Suffer my wrath"
    clear_answers()
    add_answer({wrath, forgive})

    while true do
        local answer = get_answer()
        if type(answer) ~= "string" then
            -- Resume after yield can hand back a non-string once; re-read global.
            answer = get_answer()
        end
        if type(answer) ~= "string" then
            break
        end
        local lower = string.lower(answer)

        if lower == string.lower(forgive) then
            insult = utility_unknown_1009("")
            add_dialogue("\"Forgive thee! What might I forgive in one such as thee, " .. insult .. "?\"")
            remove_answer(wrath)
            remove_answer(forgive)
            add_answer({"My crime", "My deed", "My lie"})
        elseif lower == string.lower(wrath) then
            break
        elseif lower == "my lie" then
            remove_answer({"My crime", "My deed", "My lie"})
            add_dialogue("\"Of what lie speakest thou? Art thou not " .. player_name .. "?\"")
            if ask_yes_no() then
                insult = utility_unknown_1009("")
                add_dialogue("\"Perhaps thou art not " .. player_name .. ", for I have never seen the " .. insult .. ". Confess now thy true identity!\"")
                add_answer(fellowship_leader)
                if not get_flag(353) then
                    add_answer("Avatar")
                end
            else
                break
            end
        elseif lower == "my deed" then
            add_dialogue("\"Speak not of thy deed! Such deeds must deeds receive to equal their merit.\"")
            break
        elseif lower == "my crime" then
            add_dialogue("\"Crime most foul, most horrible!\"")
            demand_blood = false
            break
        elseif lower == "avatar" then
            remove_answer("Avatar")
            add_dialogue("\"I doubt but thou deceivest me further. If true, thou dost shame the title. Admit now thy true name!\"")
            confessed = true
            set_flag(353, true)
        elseif lower == string.lower(fellowship_leader) then
            insult = utility_unknown_1009("")
            local insult2 = utility_unknown_1009(insult)
            add_dialogue("\"" .. fellowship_leader .. "! Perhaps honesty shall lift thee above the " .. insult .. " " .. player_name .. "...\"")
            confessed = true
            break
        end
    end

    if not confessed then
        insult = utility_unknown_1009("")
        local insult2 = utility_unknown_1009(insult)
        if demand_blood then
            add_dialogue("^" .. insult .. "! ^" .. insult2 .. "! Thy soul shall wail in the catacombs of the netherworld!")
            set_schedule_type(10, 0)
            set_alignment(10, 2)
        else
            add_dialogue("^" .. insult .. "! Fly from this place at once! I shall provide escort for thee with my bow. Return at thy peril, " .. insult2 .. ".")
            set_schedule_type(10, 9)
            set_alignment(10, 0)
        end
    else
        add_dialogue("\"I shall not take this deception lightly.\"")
        set_flag(29, true)
        set_alignment(10, 0)
    end
    restore_answers()
end
