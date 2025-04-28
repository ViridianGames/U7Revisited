require "U7LuaFuncs"
-- Manages Zelda's dialogue in Moonglow, as the Lycaeum advisor, discussing her duties, townspeople, and romantic interest in Brion.
function func_0498(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid ~= 1 then
        return
    end

    switch_talk_to(-152, 0)
    local0 = get_player_name()
    local1 = get_party_size()
    local2 = false
    add_answer({"bye", "job", "name"})
    local3 = is_player_female()

    if not get_flag(506) then
        say("You see a woman who meets your gaze with an icy stare.")
        set_flag(506, true)
    else
        say("\"What dost thou need now?\"")
        if get_flag(475) then
            add_answer("Brion's feelings")
        end
        if get_flag(476) then
            add_answer("Nelson's feelings")
        end
    end

    while true do
        local answer = get_answer()
        if answer == "name" then
            say("\"I am Zelda.\"")
            remove_answer("name")
            if get_flag(475) then
                add_answer("Brion's feelings")
            end
            if get_flag(476) then
                add_answer("Nelson's feelings")
            end
        elseif answer == "job" then
            say("\"I am the advisor at the Lycaeum.\"")
            add_answer({"advisor", "Lycaeum"})
            if not get_flag(502) then
                add_answer("North East sea")
            end
        elseif answer == "Lycaeum" then
            say("She rolls her eyes. \"The Lycaeum is the building in which thou dost stand. It is a great library designed to house a wealth of knowledge. Though the structure has changed a bit over the past two hundred years, the essence of learning has not.\"")
            remove_answer("Lycaeum")
        elseif answer == "advisor" then
            say("\"Yes,\" she says. \"My job is to manage and regulate the events in the Lycaeum. And,\" she adds, \"provide assistance to the people here in Moonglow -- when they need it!\"")
            remove_answer("advisor")
            add_answer({"townspeople", "events"})
        elseif answer == "events" then
            say("\"I am in charge of maintaining the reading areas and bringing in new books. In addition, I help organize special group sessions for Jillian's tutorials and set up educational entertainment programs.\"")
            remove_answer("events")
            if not local2 then
                add_answer("Jillian")
            end
        elseif answer == "North East sea" then
            say("\"I have not the time for these petty geography questions. Check an atlas!\"")
            remove_answer("North East sea")
        elseif answer == "townspeople" then
            say("\"I have little time for this,\" she sighs. \"I know only the Lycaeum head and his twin, Brion, at all well. The trainer also studies here in the Lycaeum.\" She looks up at the ceiling, as if reading from an invisible, overhead list.~~\"Thou dost already know about Penumbra. Mariah is here. If thou wishest to know about a member of The Fellowship, ask the clerk there. Otherwise,\" she eyes you coldly, \"let me return to my duties.\" As an afterthought, she adds, \"And keep thy voice down. People are trying to read.\"")
            add_answer({"Penumbra", "Brion", "Lycaeum head", "Mariah"})
            if not local2 then
                add_answer("trainer")
            end
            remove_answer("townspeople")
        elseif answer == "Mariah" then
            say("\"Well, they say she used to be an adept mage, but all I see is a woman who wanders around complimenting the furniture. Thou mayest speak to her if thou wishest, but I doubt she will make sense to thee. And do not disorganize the shelves while looking for her!\"")
            remove_answer("Mariah")
        elseif answer == "trainer" or answer == "Jillian" then
            say("\"Jillian? She is very well-behaved. Also quiet and tidy. I believe she is an excellent scholar. If thou art going to seek her out, try not to overturn any shelves. Some new books have just arrived and I have not finished placing all of them.\"")
            remove_answer({"trainer", "Jillian"})
            local2 = true
            add_answer("new books")
        elseif answer == "new books" then
            say("\"Yes, they arrived not long ago, including the recently rediscovered copy of DeMaria and Spector's work,`The Avatar Adventures.' If thou canst avoid creating too much of a disturbance, I recommend it to thee.\"")
            remove_answer("new books")
            add_answer("Avatar Adventures")
        elseif answer == "Avatar Adventures" then
            say("\"If I tell thee this last thing, wilt thou depart so I may return to my job?\"")
            if local3 then
                local4 = "her"
            else
                local4 = "his"
            end
            local5 = get_answer()
            if not local5 then
                say("\"We discovered the tome in the lower depths of the basement. We have no way to account for the accuracy of the contents, but have noticed many parallels between the events in the work and the events in Britannia's recent history.~~ \"The book is a copy of the Avatar's diary, written about two hundred years ago during " .. local4 .. " most recent visit to Britannia. Of course,\" she smiles sardonically, \"it has been annotated by others.~~\"It was recently published to give the general public more courage and confidence.~~\"And now, goodbye.\"")
                return
            else
                say("\"Fine.\"")
                return
            end
        elseif answer == "Penumbra" then
            if local3 then
                local6 = "she"
            else
                local6 = "he"
            end
            say("She shakes her head, muttering, \"Why doth " .. local6 .. " waste my time in this manner?\" Looking back up at you, she says, \"Penumbra is the sage who put herself to sleep two centuries ago. Rumor has it that only the Avatar can awaken her.\"")
            remove_answer("Penumbra")
        elseif answer == "Lycaeum head" then
            say("\"Nelson is very competent, although a little eccentric. I do wish he would refrain from showing off his collection of trinkets to everyone who enters the building. It always makes such a commotion.\"")
            remove_answer("Lycaeum head")
        elseif answer == "Brion" then
            say("Her chilly expression melts away. \"Brion,\" she says, smiling, \"is very open-minded and idealistic. He knows the heavens quite well.\" She looks up to emphasize `heavens.' \"I find him very attractive. But, I do not know how to convey mine intentions.\" She turns away, shyly.~~\"Unless, perchance, " .. local1 .. " wilt aid me?\" she asks, hopefully. \"Wilt thou agree to tell him for me, " .. local1 .. "?\"")
            local7 = get_answer()
            if local7 then
                say("\"Thank thee, " .. local1 .. ". Thank thee.\" She blushes.")
                local8 = add_item(0, 6, -359, 340, 1)
                if local8 then
                    say("\"For thy kindness, I will give thee this white potion I found once while straightening the basement.\"")
                end
            else
                say("Her cold glare returns. \"Very well.\"*")
                return
            end
            set_flag(474, true)
            remove_answer("Brion")
        elseif answer == "Brion's feelings" then
            say("She looks down for a moment. \"I thought as much.\" As she raises her head, tears are visible in her eyes. \"I thank thee for trying.\"*")
            return
        elseif answer == "Nelson's feelings" then
            say("\"Nelson? I never really thought about him.\" She shrugs. \"Hmm, I suppose he is not a bad second best. I will try,\" she says, smiling.")
            set_flag(483, true)
            apply_effect(20) -- Unmapped intrinsic
            remove_answer("Nelson's feelings")
            if not get_flag(474) then
                add_answer("second best?")
            end
        elseif answer == "second best?" then
            say("\"Well, his brother, Brion, is quite attractive, I think.\"")
            remove_answer("second best?")
        elseif answer == "bye" then
            say("\"Good day.\"*")
            break
        end
    end
    return
end