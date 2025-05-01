-- Function 04E8: Smithy's game manager dialogue and rule explanations
function func_04E8(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid == 0 then
        local1 = callis_003B()
        local2 = callis_001C(callis_001B(-232))
        local4 = callis_Random2(4, 1)
        if local2 == 10 then
            if local4 == 1 then
                local5 = "@Place thy bets.@"
            elseif local4 == 2 then
                local5 = "@No more bets.@"
            elseif local4 == 3 then
                local5 = "@Winner takes all.@"
            elseif local4 == 4 then
                local5 = "@The House wins.@"
            end
            bark(232, local5)
        else
            call_092EH(-232)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(232, 0)
    local0 = call_0909H()
    local1 = callis_003B()
    local2 = callis_001C(callis_001B(-232))
    add_answer({"bye", "job", "name"})

    if not get_flag(0x02B5) then
        add_dialogue("You see a well-dressed pirate with oil in his hair.")
        set_flag(0x02B5, true)
    else
        add_dialogue("\"May I help thee?\" Smithy asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am Smithy.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I run the games at the House of Games.")
            if local2 == 10 then
                add_dialogue("\"I can explain the rules and how to play for thee. I also make sure that one does not cheat.\"")
                add_answer({"cheat", "games"})
            else
                add_dialogue("\"Please do come and try thy skill when the facility is open for business.\"")
            end
        elseif answer == "cheat" then
            add_dialogue("\"If thou art caught cheating, thou wilt be arrested. And we do prosecute!\"")
            remove_answer("cheat")
        elseif answer == "games" then
            add_dialogue("\"There are three games that thou canst play. The first is Virtue Roulette. The second is The Rat Race. The third is Triples. Wouldst thou like to hear any rules?\"")
            if call_090AH() then
                add_dialogue("\"For which game dost thou want to hear the rules?\"")
                local3 = call_090BH({"Triples", "The Rat Race", "Virtue Roulette", "None"})
                if local3 == "None" then
                    add_dialogue("\"That is all right.\"")
                elseif local3 == "Virtue Roulette" then
                    add_dialogue("\"Simply place the amount of gold coins thou dost wish to bet on one or more colors. Use the wheel and thy money will be increased if thou hast bet correctly.\"")
                elseif local3 == "The Rat Race" then
                    add_dialogue("\"Place thy bet on the green spot at the end of the lane which corresponds to the trough in which thy rat is running.\"")
                elseif local3 == "Triples" then
                    add_dialogue("\"Thou canst bet on a triple, that is, three ones, three twos, or three threes. This has the highest payback. A '1, 2, 3' pays slightly less. A sum total of '4', '5', '7', or '8' pays the least. Do not place thy money in between numbers, especially the '4' and '5'. A '6' made up of anything other than three twos loses. After placing thy bet, spin the wheel.\"")
                end
            else
                add_dialogue("\"Fine then. Thou art on thine own.\"")
            end
        elseif answer == "bye" then
            add_dialogue("\"See thee again, ", local0, ".\"*")
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