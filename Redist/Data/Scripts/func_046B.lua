-- Manages Iskander's dialogue, a cyclops hero, covering his heroic past, tribal homeland search, and the tetrahedron riddle.
function func_046B(eventid, itemref)
    local local0, local1, local2, local3, local4

    if eventid == 0 then
        return
    end

    switch_talk_to(-107, 0)
    local0 = get_answer({"Avatar"})
    local1 = local0
    local2 = get_player_name()

    add_answer({"bye", "job", "name"})

    if not get_flag(719) then
        add_answer("Eiko and Amanda")
    end

    if not get_flag(719) then
        say("You see a large cyclops. It looks at you and blinks its eye in irritation.")
        set_flag(719, true)
    else
        say("\"What dost thou want?\" says Iskander.")
    end

    while true do
        local answer = get_answer()
        if answer == "name" then
            say("\"I am of the clan Ironheart, the eleventh son of Valador. They call me Iskander.\"")
            remove_answer("name")
        elseif answer == "job" then
            say("\"My cyclopean people say I am a hero. Many of you humans say I am a monster. No doubt, the truth is somewhere in between.\"")
            add_answer({"monster", "hero"})
        elseif answer == "hero" then
            say("\"One hundred and eighty-nine years ago I slew the seven Gazer Princes when they used their magic to steal the eye from the leader of our tribe, but such things are now ancient history and are no longer of any consequence.\"")
            remove_answer("hero")
            add_answer({"ancient history", "eye", "tribe"})
        elseif answer == "monster" then
            say("\"On numerous occasions I have caused the unpleasant end of human interlopers who mistakenly believed our race was fit for nothing save to be plundered. But I have no quarrel with thee.\" He pauses to scrutinize you. \"For the moment.\"")
            remove_answer("monster")
            add_answer("thee")
        elseif answer == "thee" then
            say("\"Thou dost know my name, but I still do not know the name of thee. I like to know to whom I am speaking. What is thy name?\"")
            local3 = compare_strings(local2, local0)
            if local3 == local0 then
                say("\"I have heard of thee, Avatar. Thou hast come into conflict against our kind before, I know. But I have also heard the tales of thine heroic and spiritual quests and I believe thee to be a just and noble man. Thou mayest call me friend.\"")
                set_flag(726, true)
            elseif local3 == local2 then
                say("\"A pleasure to meet thee, " .. local2 .. ".\"")
                set_flag(725, true)
            end
            remove_answer("thee")
        elseif answer == "tribe" then
            say("\"Those of my tribe are a quiet people. They farm the rocky soil, but are also very good tool makers. I was sent to find them a new homeland.\"")
            remove_answer("tribe")
            add_answer("homeland")
        elseif answer == "eye" then
            say("\"The eye of a cyclops is considered quite a delicacy to some of the less genteel races of Britannia. Twice have foul creatures tried to take mine, and twice have I dined on their hearts.\"")
            remove_answer("eye")
        elseif answer == "ancient history" then
            say("\"Then they called me 'Wonder Boy'. For nearly a hundred years that was the nickname by which I was known. I was most grateful when they stopped doing that!\"")
            remove_answer("ancient history")
            add_answer("Wonder Boy")
        elseif answer == "Wonder Boy" then
            say("Iskander squints his eye at you. \"Do not start that again!\"")
            remove_answer("Wonder Boy")
        elseif answer == "homeland" then
            say("\"My village lies a great many days' journey away. The people there desire a place where they can live in peace with their surroundings. I have not found such a place yet, but I will search everywhere until I do.\"")
            remove_answer("homeland")
            add_answer({"everywhere", "peace"})
        elseif answer == "peace" then
            say("\"While I am two hundred and six, not long in years for one of my race, I already have the heart of an old man. A hero's adventures have no more attraction for me. I long to settle down with my people and spend my days tending the fields or in my workshop building things.\"")
            remove_answer("peace")
        elseif answer == "everywhere" then
            say("\"My searches have brought me to this dreadful place. I incorrectly surmised that since magic does not work it would be relatively safe. It is here that I have been perplexed by a terrible riddle.\"")
            remove_answer("everywhere")
            add_answer({"riddle", "magic"})
        elseif answer == "riddle" then
            say("\"Standing at the doorway of one room in this place, I saw an enormous image of a tetrahedron. As I tried to near it a wave of amnesia passed over me. Once more I was standing in the doorway. I could remember nothing more.\"")
            remove_answer("riddle")
            add_answer({"amnesia", "tetrahedron"})
        elseif answer == "tetrahedron" then
            say("\"I believe that is word you humans use to describe a polyhedron with four faces.\"")
            remove_answer("tetrahedron")
        elseif answer == "amnesia" then
            say("\"This same wave of amnesia struck me every time I tried to approach the tetrahedron. I do not know what sort of foul magic this is.\"")
            remove_answer("amnesia")
            add_answer("foul magic")
        elseif answer == "foul magic" then
            if get_flag(3) then
                say("\"Now that thou hast destroyed the mysterious tetrahedron I will complete mine exploration of this place. I have a feeling that the homeland I seek is very far away but one never knows where the next clue will be that shall lead me to it.\"")
            elseif get_flag(726) then
                say("\"Perhaps thou shalt be able to solve this mystery. I have been unable to as of yet. But I shall remain here until its secret is revealed.\"")
            elseif get_flag(725) then
                say("\"I warn thee that this place is not safe. It holds unknown perils. Perhaps thou wouldst do better to leave this place.\"")
            end
            remove_answer("foul magic")
        elseif answer == "magic" then
            if not get_flag(3) then
                say("\"Surely, thou dost know that magic no longer functions as it once did. There are those who say that the age of magic is over. If that is so, then I fear that there may be no place left in this world for my people.\"")
            else
                say("\"Of course, now that thou hast destroyed the tetrahedron all magic has been restored. I congratulate thee for thine heroic deed!\"")
            end
            remove_answer("magic")
        elseif answer == "Eiko and Amanda" then
            say("\"Yes, I have heard those names before. Those are the names of two warriors who have been after me for revenge. They say I killed their father and I must admit to thee that it is true. I did kill their father.\"")
            remove_answer("Eiko and Amanda")
            add_answer({"killed their father", "revenge"})
        elseif answer == "revenge" then
            say("\"I know that Eiko and Amanda have been after me for some time looking for vengeance. I say let them come. I will not stand still for them nor shall I run from them. When they find me they are welcome to try and take their justice from me. If they win then it was meant to be. If they do not I will have no regrets.\"")
            remove_answer("revenge")
        elseif answer == "killed their father" then
            say("\"Their father's name was Kalideth. He suffered from the mage madness. His attack on me was unprovoked. For some reason he blamed the failure of magic upon my people. His own magics were still quite potent and I barely survived the encounter. I killed Kalideth in self-defense, but I did not want to kill him. I wish there to still be some magic left in this world and I mourned his passing as much as anyone.\"")
            set_flag(724, true)
            remove_answer("killed their father")
        elseif answer == "bye" then
            if get_flag(726) then
                say("\"Farewell, Avatar.\"*")
            elseif get_flag(725) then
                say("\"Farewell, " .. local2 .. ".\"*")
            else
                say("\"Farewell.\"*")
            end
            break
        end
    end
    return
end