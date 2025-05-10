--- Best guess: Manages Smithy’s dialogue in Buccaneer’s Den, explaining the rules of games at the House of Games and warning against cheating.
function func_04E8(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        switch_talk_to(0, 232)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_003BH()
        var_0002 = unknown_001CH(unknown_001BH(232))
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(693) then
            add_dialogue("You see a well-dressed pirate with oil in his hair.")
            set_flag(693, true)
        else
            add_dialogue("\"May I help thee?\" Smithy asks.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Smithy.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I run the games at the House of Games.\"")
                if var_0002 == 10 then
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
                if unknown_090AH() then
                    add_dialogue("\"For which game dost thou want to hear the rules?\"")
                    var_0003 = unknown_090BH({"Triples", "The Rat Race", "Virtue Roulette", "None"})
                    if var_0003 == "None" then
                        add_dialogue("\"That is all right.\"")
                        break
                    elseif var_0003 == "Virtue Roulette" then
                        add_dialogue("\"Simply place the amount of gold coins thou dost wish to bet on one or more colors. Use the wheel and thy money will be increased if thou hast bet correctly.\"")
                    elseif var_0003 == "The Rat Race" then
                        add_dialogue("\"Place thy bet on the green spot at the end of the lane which corresponds to the trough in which thy rat is running.\"")
                    elseif var_0003 == "Triples" then
                        add_dialogue("\"Thou canst bet on a triple, that is, three ones, three twos, or three threes. This has the highest payback. A '1, 2, 3' pays slightly less. A sum total of '4', '5', '7', or '8' pays the least. Do not place thy money in between numbers, especially the '4' and '5'. A '6' made up of anything other than three twos loses. After placing thy bet, spin the wheel.\"")
                    end
                else
                    add_dialogue("\"Fine then. Thou art on thine own.\"")
                end
            elseif answer == "bye" then
                add_dialogue("\"See thee again, \" .. var_0000 .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        var_0001 = unknown_003BH()
        var_0002 = unknown_001CH(unknown_001BH(232))
        var_0004 = random2(4, 1)
        if var_0002 == 10 then
            if var_0004 == 1 then
                var_0005 = "@Place thy bets.@"
            elseif var_0004 == 2 then
                var_0005 = "@No more bets.@"
            elseif var_0004 == 3 then
                var_0005 = "@Winner takes all.@"
            elseif var_0004 == 4 then
                var_0005 = "@The House wins.@"
            end
            bark(var_0005, 232)
        else
            unknown_092EH(232)
        end
    end
    return
end