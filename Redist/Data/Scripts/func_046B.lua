--- Best guess: Manages Iskander’s dialogue, a cyclops hero in a dungeon, discussing his tribe, heroic past, and a tetrahedron riddle, with flag-based interactions and name-based responses.
function func_046B(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 0 then
        return
    end

    start_conversation()
    switch_talk_to(0, 107)
    var_0000 = unknown_0908H()
    var_0001 = "Avatar"
    var_0002 = get_lord_or_lady()
    if not get_flag(719) then
        add_dialogue("You see a large cyclops. It looks at you and blinks its eye in irritation.")
        set_flag(719, true)
    else
        add_dialogue("\"What dost thou want?\" says Iskander.")
    end
    add_answer({"bye", "job", "name"})
    if not get_flag(731) then
        add_answer("Eiko and Amanda")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am of the clan Ironheart, the eleventh son of Valador. They call me Iskander.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"My cyclopean people say I am a hero. Many of you humans say I am a monster. No doubt, the truth is somewhere in between.\"")
            add_answer({"monster", "hero"})
        elseif cmps("hero") then
            add_dialogue("\"One hundred and eighty-nine years ago I slew the seven Gazer Princes when they used their magic to steal the eye from the leader of our tribe, but such things are now ancient history and are no longer of any consequence.\"")
            remove_answer("hero")
            add_answer({"ancient history", "eye", "tribe"})
        elseif cmps("monster") then
            add_dialogue("\"On numerous occasions I have caused the unpleasant end of human interlopers who mistakenly believed our race was fit for nothing save to be plundered. But I have no quarrel with thee.\" He pauses to scrutinize you. \"For the moment.\"")
            remove_answer("monster")
            add_answer("thee")
        elseif cmps("thee") then
            add_dialogue("\"Thou dost know my name, but I still do not know the name of thee. I like to know to whom I am speaking. What is thy name?\"")
            var_0003 = unknown_090BH({var_0000, var_0001})
            if var_0003 == var_0001 then
                add_dialogue("\"I have heard of thee, Avatar. Thou hast come into conflict against our kind before, I know. But I have also heard the tales of thine heroic and spiritual quests and I believe thee to be a just and noble man. Thou mayest call me friend.\"")
                set_flag(726, true)
            elseif var_0003 == var_0000 then
                add_dialogue("\"A pleasure to meet thee, " .. var_0000 .. ".\"")
                set_flag(725, true)
            end
            remove_answer("thee")
        elseif cmps("tribe") then
            add_dialogue("\"Those of my tribe are a quiet people. They farm the rocky soil, but are also very good tool makers. I was sent to find them a new homeland.\"")
            remove_answer("tribe")
            add_answer("homeland")
        elseif cmps("eye") then
            add_dialogue("\"The eye of a cyclops is considered quite a delicacy to some of the less genteel races of Britannia. Twice have foul creatures tried to take mine, and twice have I dined on their hearts.\"")
            remove_answer("eye")
        elseif cmps("ancient history") then
            add_dialogue("\"Then they called me 'Wonder Boy'. For nearly a hundred years that was the nickname by which I was known. I was most grateful when they stopped doing that!\"")
            remove_answer("ancient history")
            add_answer("Wonder Boy")
        elseif cmps("Wonder Boy") then
            add_dialogue("Iskander squints his eye at you. \"Do not start that again!\"")
            remove_answer("Wonder Boy")
        elseif cmps("homeland") then
            add_dialogue("\"My village lies a great many days' journey away. The people there desire a place where they can live in peace with their surroundings. I have not found such a place yet, but I will search everywhere until I do.\"")
            remove_answer("homeland")
            add_answer({"everywhere", "peace"})
        elseif cmps("peace") then
            add_dialogue("\"While I am two hundred and six, not long in years for one of my race, I already have the heart of an old man. A hero's adventures have no more attraction for me. I long to settle down with my people and spend my days tending the fields or in my workshop building things.\"")
            remove_answer("peace")
        elseif cmps("everywhere") then
            add_dialogue("\"My searches have brought me to this dreadful place. I incorrectly surmised that since magic does not work it would be relatively safe. It is here that I have been perplexed by a terrible riddle.\"")
            remove_answer("everywhere")
            add_answer({"riddle", "magic"})
        elseif cmps("riddle") then
            add_dialogue("\"Standing at the doorway of one room in this place, I saw an enormous image of a tetrahedron. As I tried to near it a wave of amnesia passed over me. Once more I was standing in the doorway. I could remember nothing more.\"")
            remove_answer("riddle")
            add_answer({"amnesia", "tetrahedron"})
        elseif cmps("tetrahedron") then
            add_dialogue("\"I believe that is word you humans use to describe a polyhedron with four faces.\"")
            remove_answer("tetrahedron")
        elseif cmps("amnesia") then
            add_dialogue("\"This same wave of amnesia struck me every time I tried to approach the tetrahedron. I do not know what sort of foul magic this is.\"")
            remove_answer("amnesia")
            add_answer("foul magic")
        elseif cmps("foul magic") then
            if get_flag(3) then
                add_dialogue("\"Now that thou hast destroyed the mysterious tetrahedron I will complete mine exploration of this place. I have a feeling that the homeland I seek is very far away but one never knows where the next clue will be that shall lead me to it.\"")
            elseif get_flag(726) then
                add_dialogue("\"Perhaps thou shalt be able to solve this mystery. I have been unable to as of yet. But I shall remain here until its secret is revealed.\"")
            elseif get_flag(725) then
                add_dialogue("\"I warn thee that this place is not safe. It holds unknown perils. Perhaps thou wouldst do better to leave this place.\"")
            end
            remove_answer("foul magic")
        elseif cmps("magic") then
            if not get_flag(3) then
                add_dialogue("\"Surely, thou dost know that magic no longer functions as it once did. There are those who say that the age of magic is over. If that is so, then I fear that there may be no place left in this world for my people.\"")
            else
                add_dialogue("\"Of course, now that thou hast destroyed the tetrahedron all magic has been restored. I congratulate thee for thine heroic deed!\"")
            end
            remove_answer("magic")
        elseif cmps("Eiko and Amanda") then
            add_dialogue("\"Yes, I have heard those names before. Those are the names of two warriors who have been after me for revenge. They say I killed their father and I must admit to thee that it is true. I did kill their father.\"")
            remove_answer("Eiko and Amanda")
            add_answer({"killed their father", "revenge"})
        elseif cmps("revenge") then
            add_dialogue("\"I know that Eiko and Amanda have been after me for some time looking for vengeance. I say let them come. I will not stand still for them nor shall I run from them. When they find me they are welcome to try and take their justice from me. If they win then it was meant to be. If they do not I will have no regrets.\"")
            remove_answer("revenge")
        elseif cmps("killed their father") then
            add_dialogue("\"Their father's name was Kalideth. He suffered from the mage madness. His attack on me was unprovoked. For some reason he blamed the failure of magic upon my people. His own magics were still quite potent and I barely survived the encounter. I killed Kalideth in self-defense, but I did not want to kill him. I wish there to still be some magic left in this world and I mourned his passing as much as anyone.\"")
            set_flag(4, true)
            remove_answer("killed their father")
        elseif cmps("bye") then
            break
        end
    end
    if get_flag(726) then
        add_dialogue("\"Farewell, Avatar.\"")
        return
    elseif get_flag(725) then
        add_dialogue("\"Farewell, " .. var_0000 .. ".\"")
    else
        add_dialogue("\"Farewell.\"")
    end
    return
end