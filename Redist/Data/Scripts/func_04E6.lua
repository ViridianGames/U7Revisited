-- Function 04E6: Gordy's overseer dialogue and Fellowship funding
function func_04E6(eventid, itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 0 then
        call_092EH(-230)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(230, 0)
    local0 = callis_003B()
    local1 = callis_0067()
    local2 = call_0909H()
    local3 = call_0908H()
    local4 = "Avatar"
    local5 = "a pseudonym"
    add_answer({"bye", "job", "name"})

    if get_flag(0x0104) or get_flag(0x0135) then
        add_answer("Hook")
    end

    if not get_flag(0x02B3) then
        add_dialogue("You see a pirate who is elegantly dressed and obviously rich. He reeks of pomade.")
        set_flag(0x02B3, true)
    else
        add_dialogue("\"Yes?\" Gordy asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am Gordy.\" He grins widely offering you his hand. You notice that it is none too clean.")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am 'The Mister' of the House of Games. Inside mine House thou mayest challenge thy skill at games of chance.\" He eyes you carefully, measuring your worth and gullibility.")
            if local0 == 5 or local0 == 6 or local0 == 7 or local0 == 0 then
                add_dialogue("\"Enter and enjoy! But first thou must register. Please sign the book so that we may verify thy proclaimed worth.\" Which name do you sign?")
                local6 = {local5, local4, local3}
                local7 = call_090BH(local6)
                if local7 == local3 then
                    add_dialogue("You sign your name. \"Very good, ", local3, ". Welcome to the House of Games!\" Gordy spreads his arms in an expansive gesture, obviously pleased to welcome your money to his gambling parlour.")
                elseif local7 == local4 then
                    add_dialogue("Gordy frowns when he sees what you wrote. \"Avatar, eh? We just had one of them a week ago. He was caught cheating at the tables!\" He takes a step back and glowers. \"Art thou going to give us trouble?\"")
                    if call_090AH() then
                        add_dialogue("\"We shall see about that!\"")
                    else
                        add_dialogue("\"Then thou canst not enter!\"*")
                        return
                    end
                elseif local7 == local5 then
                    add_dialogue("You sign in a false name. \"Fine, ", local2, ". I be glad to welcome thee!\" Gordy spreads his arms in an expansive gesture, obviously pleased to welcome your money to his gambling parlour.")
                end
            else
                add_dialogue("\"I hope to see thee there during business hours.\"")
            end
            if not get_flag(0x0006) then
                add_dialogue("\"Ah, thou art a Fellowship member. Thou wilt surely find thy reward at these tables!\" Gordy winks and nudges you, then guffaws loudly.")
            end
            add_answer({"skill", "House of Games", "The Mister"})
        elseif answer == "House of Games" then
            add_dialogue("\"The House of Games was established six years ago with the funds of... an interested party. It attracts people from all over Britannia who wish to live dangerously with their money. The business is very profitable.\" He pats his pouch, and coins clink. \"Very profitable.\" He grins.")
            remove_answer("House of Games")
            add_answer({"profitable", "party"})
        elseif answer == "The Mister" then
            add_dialogue("\"It refers to my being the overseer, but everyone here has always called me 'The Mister'. I am not sure why. But it appeals to me.\" He puffs up like a bantam rooster, trying to look important. He almost succeeds.")
            add_dialogue("\"And that is 'Mister' Gordy, to thee!\"")
            remove_answer("The Mister")
            add_answer("Mister Gordy")
        elseif answer == "Mister Gordy" then
            add_dialogue("\"Yes, what can I do for thee?\"")
            add_dialogue("He grins, very pleased with himself.")
            remove_answer("Mister Gordy")
        elseif answer == "skill" then
            add_dialogue("\"Each game requires a definite skill in determining the most profitable way to place a bet. Many visitors to the House of Games find that they have a skill. Others, sadly, do not.\"")
            if not get_flag(0x0006) and local1 then
                add_dialogue("He gestures toward your Fellowship medallion. \"Thou shouldst not have any problem.\" He winks and wiggles his eyebrows.")
            end
            remove_answer("skill")
        elseif answer == "profitable" then
            add_dialogue("\"Well, Buccaneer's Den is not in the jurisdiction of the Britannian Tax Council. We are not subject to Britannia's taxes.\" Gordy smiles wickedly. \"And that... is very profitable!\"")
            remove_answer("profitable")
        elseif answer == "Hook" then
            local8 = call_0931H(1, -359, 981, 1, -357)
            if local8 then
                add_dialogue("The Cube vibrates a moment. \"Yes, I know Hook very well. He lives beneath the House of Games. Talk to Sintag. He can direct thee.\"")
            else
                add_dialogue("\"I do not know anyone of that description.\" Gordy looks around nervously and loosens his collar as though it has suddenly gotten too tight.")
            end
            remove_answer("Hook")
        elseif answer == "party" then
            local8 = call_0931H(1, -359, 981, 1, -357)
            if local8 then
                add_dialogue("The Cube vibrates a moment. \"That would be The Fellowship, of course.\"")
            else
                add_dialogue("\"Well, now,... that would be revealin' the secret of my business and profit, now wouldn't it?\" His demeanor becomes threatening as he leans closer to you and snarls, \"Find thine own backers, whelp!\"*")
                return
            end
            remove_answer("party")
        elseif answer == "bye" then
            add_dialogue("\"Farewell, friend. I look forward to thy return.\"*")
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