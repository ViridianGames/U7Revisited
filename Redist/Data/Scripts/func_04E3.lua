-- Function 04E3: Mole's dialogue and Blacktooth reconciliation
function func_04E3(eventid, itemref)
    -- Local variables (7 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 0 then
        local4 = callis_001C(callis_001B(-227))
        if local4 == 11 then
            local5 = callis_Random2(4, 1)
            if local5 == 1 then
                local6 = "@Har!@"
            elseif local5 == 2 then
                local6 = "@Avast!@"
            elseif local5 == 3 then
                local6 = "@Blast!@"
            elseif local5 == 4 then
                local6 = "@Damn parrot droppings...@"
            end
            _ItemSay(local6, -227)
        else
            call_092EH(-227)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(227, 0)
    local0 = call_0909H()
    local1 = callis_0067()
    local2 = callis_001B(-227)
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x02A7) and not get_flag(0x02A5) then
        _AddAnswer("He misses thee")
    end

    if not get_flag(0x02B0) then
        say("You see an aging pirate who might have looked extremely dangerous at one time.")
        set_flag(0x02B0, true)
    else
        say("\"What is it?\" Mole asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"My name be Mole, it be! Do not ask me how I came by it. 'Tis a long story.\"")
            _RemoveAnswer("name")
            _AddAnswer("story")
        elseif answer == "job" then
            say("\"For years and years I roamed the seas, pillaging and raping and terrorizing. Now that I am past the age of fifty, I want to live the rest of my life in relative peace and quiet here on Buccaneer's Den.\"")
            _AddAnswer({"Buccaneer's Den", "peace and quiet"})
        elseif answer == "story" then
            say("\"Thou dost really want to hear it? 'Tis very long.\"")
            if call_090AH() then
                say("\"All right. I was born in a cave. So my mother named me Mole.\"*")
                local3 = call_08F7H(-1)
                if not local3 then
                    switch_talk_to(1, 0)
                    say("\"I thought thou said it was a long story.\"*")
                    _HideNPC(-1)
                    switch_talk_to(227, 0)
                end
            else
                say("\"Very well. How 'bout if I just say that I was born in a cave, so my mother named me Mole.\"")
            end
            say("Mole shrugs. \"I thought I would make a long story short.\"")
            _RemoveAnswer("story")
        elseif answer == "peace and quiet" then
            say("\"It is a good life. I grew weary of pirating. I grew weary of the salt water and the raw meat and the sewage on deck and the parrot droppings and the fact that every other word one heard was 'Har!'\"")
            _RemoveAnswer("peace and quiet")
        elseif answer == "Buccaneer's Den" then
            say("\"I spend my time at the House of Games or the Fallen Virgin. I love the sound of the die as it bounces against the felt. I love the taste of warm ale as it splashes down my throat! And... I have The Fellowship.\"")
            _RemoveAnswer("Buccaneer's Den")
            _AddAnswer("Fellowship")
        elseif answer == "Fellowship" then
            say("\"The group has given me a new lease on life. I thought I had mates when I was an active pirate, but they were nothing compared to my brothers in The Fellowship.")
            if local1 then
                say("\"Say, I see that thou art a member! Thou must be of sound character!")
            end
            say("\"Mine old mates, like my friend Blacktooth, have fallen by the wayside.\"")
            _RemoveAnswer("Fellowship")
            _AddAnswer({"mates", "Blacktooth"})
        elseif answer == "Blacktooth" then
            say("\"Blacktooth lives here on the island. We used to be the same link on a chain, knowest what I mean? But since I joined The Fellowship, he does not give me the shadow of a sundial! He acts as though I had the plague or something. I do not understand it. Makes me want to cut something up into mincemeat!\"")
            _RemoveAnswer("Blacktooth")
        elseif answer == "mates" then
            say("\"Blacktooth was like my brother. Not like my brothers in The Fellowship, but a 'real' brother, knowest what I mean? We did 'everything' together. We would share booty! We would share wenches! We did it all!\"")
            _RemoveAnswer("mates")
            _AddAnswer("brother")
        elseif answer == "brother" then
            say("\"Well, he is not a brother now! He hates me! If he wants nothing to do with me, so be it!\" But Mole quickly adds, \"He does not realize what I did for him. I made his life livable! Who was it that nursed him when he had scurvy? Me! Who was it that patched him up when he was sliced to bits by that butcher Silverbeard? Me!\"")
            _RemoveAnswer("brother")
            _AddAnswer({"Silverbeard", "life"})
        elseif answer == "Silverbeard" then
            say("\"Oh, he was some old pirate with a temper. He's probably dead now, if he knows what's good for him!\"")
            _RemoveAnswer("Silverbeard")
        elseif answer == "life" then
            say("\"Yes, it was a different life in those days...\" Mole reflects on some past memory as his eyes glaze over temporarily. Finally he says, \"I may have dwelt too strongly on my Fellowship business. Perhaps I pushed him too hard. I am sorry. If he would give me another chance I would probably leave The Fellowship. They are not as wonderful as I made them sound. They are more crooked than the pirates I used to sail with!\" Mole frowns. \"Thou hast put me in a foul mood.\"")
            _RemoveAnswer("life")
            set_flag(0x02A7, true)
            if not get_flag(0x02A5) then
                _AddAnswer("He misses thee")
                _RemoveAnswer("life")
            else
                say("*")
                return
            end
        elseif answer == "He misses thee" then
            say("You tell Mole what Blacktooth said. A change comes over the salty pirate, as if you had just given him a bouquet of flowers.~~\"Thou must be kidding me! Blackie misses me? I thought he hated mine innards! I shall have to go for a little walk and maybe I will run across that old dog! I thank thee, stranger, for imparting this information to me.\"~~With that, Mole turns away from you, doing a little jaunt.*")
            _RemoveAnswer("He misses thee")
            calli_001D(12, local2)
            return
        elseif answer == "bye" then
            say("\"Goodbye, stranger.\"*")
            return
        end
    end

    return
end

-- Helper functions
function say(...)
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