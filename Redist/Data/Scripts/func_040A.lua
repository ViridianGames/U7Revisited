require "U7LuaFuncs"
-- Manages Tseramed's dialogue and interactions

-- Global variables for answer handling
answers = answers or {}
answer = answer or nil

function func_040A(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14, local15, local16, local17, local18, local19
    local local20, local21, local22, local23, local24, local25, local26, local27, local28, local29
    local local30, local31, local32, local33, local34, local35, local36, local37, local38, local39
    local local40, local41, local42

    if eventid == 1 then
        _SwitchTalkTo(0, -10)
        local0 = call_0908H()
        local1 = call_0909H()
        local2 = callis_0023()
        local3 = callis_001B(-356, local2)
        local3 = call_093CH(local3)
        local4 = callis_001B(-10)
        local5 = callis_001B(-6)
        local6 = callis_005A() and "Elizabeth" or "Abraham"
        local7 = callis_005E(local2)
        local8 = local7 > 1 and "s" or ""
        local9 = 0
        local10, local11, local12, local13, local14, local15, local16 = false, false, false, false, false, false, false
        local17 = callis_0035(0, 13, 529, local4)
        local18 = callis_0035(0, 13, 510, local4)
        local19 = callis_0035(0, 13, 532, local4)
        local20 = callis_0035(0, 20, 494, local4)
        local21 = call_08F7H(229) or call_08F7H(228)
        local22 = get_flag(350) and "noble enchanter" or "valiant warrior"
        if not get_flag(29) and get_flag(349) then
            call_08F2H(local6, local0)
            answers = {}
            answer = nil
            abort()
        end
        if local4 in local2 then
            call_08F4H(local7, local0)
            if not local21 then
                _AddAnswer("hermits")
            end
            if not local17 then
                _AddAnswer("slime")
            end
            if not local18 then
                _AddAnswer("foxes")
            end
            if not local19 then
                _AddAnswer("harpies")
            end
            if local20 then
                say("We need not be concerned about these bees, so long as we have a number of my trusty arrows.")
                _AddAnswer("bees")
            end
            _AddAnswer("Fellowship")
            local13 = true
        else
            if not answer then
                say("Greetings, traveller" .. local8 .. ".")
                answers = {}
                _AddAnswer({"bye", "job", "name"})
                if get_flag(349) then
                    local22 = "lowly deceiver"
                end
                if get_flag(29) and local7 == 1 then
                    set_flag(351, true)
                end
                if not get_flag(351) and local7 > 1 and get_flag(29) then
                    _AddAnswer("introduce")
                end
                answer = call_090BH(answers)
                return
            end
        end

        -- Process answer
        if cmp_strings("name", 1) then
            _RemoveAnswer("name")
            if get_flag(29) then
                say("I am Tseramed the woodsman. Thou art a " .. local22 .. ".")
            else
                say("I am called Tseramed. Art thou Fellowship members? How art thou called?")
                callis_0007()
                local9 = local9 + 1
                _AddAnswer({"Fellowship", local0})
                if not get_flag(353) then
                    _AddAnswer("Avatar")
                end
            end
        elseif cmp_strings("Avatar", 1) then
            _RemoveAnswer("Avatar")
            set_flag(353, true)
            say("The Avatar! This is a strange chance. Tell me Avatar, by what name art thou called?")
            _RemoveAnswer(local0)
            set_flag(29, true)
            say("Well met, " .. local0 .. "\"")
            if get_flag(353) then
                say("Thy demeanor is noble.")
            end
            if local7 == 1 then
                set_flag(351, true)
            end
            callis_0008()
            if not get_flag(351) then
                say("Perhaps thou couldst introduce me to thy companions?")
                _AddAnswer("introduce")
            end
        elseif cmp_strings("Fellowship", 1) then
            _RemoveAnswer("Fellowship")
            if get_flag(29) then
                if local4 in local2 or get_flag(354) then
                    say("I have no love for The Fellowship. We shall speak of it when I know thee better.")
                else
                    say("I do not trust The Fellowship, and most especially " .. local6 .. ".")
                    _AddAnswer(local6)
                end
            else
                say("Yes. Perhaps I am addressing the illustrious " .. local6 .. "?")
                _AddAnswer(local6)
            end
        elseif cmp_strings(local6, 1) then
            _RemoveAnswer(local6)
            if not get_flag(29) then
                say("Not long ago The Fellowship began to spread its influence throughout Britannia.")
                say("In their early days they attracted many bright and enthusiastic young people, among them my love, Lady M.")
                say("A woman so intelligent could not help but rise in their ranks. Her direct superior was " .. local6 .. ".")
                say("One black evening she fell gravely ill. According to friends of mine, " .. local6 .. " forbade her to visit the local healer. By the time I learned of this, she had already passed away.")
                say("She rests now forever in the Yew graveyard, may her sleep be peaceful. I searched the land for " .. local6 .. ", but never found my quarry. In fact, it seems that every time I near my prey, they have already vanished! My search shall never be truly over.")
                _RemoveAnswer(local6)
                _AddAnswer({"Lady M.", "Yew"})
            else
                callis_0008()
                set_flag(349, true)
                local24 = get_flag(353) and "thou dost tarnish the title of Avatar!" or local24
                say("Knave, " .. local24 .. " I have not forgotten thy wrong doing, nor the evil crime that followed it.")
                say("Oh soul as black as pitch!")
                call_08F2H(local6, local0)
                answers = {}
                answer = nil
                abort()
            end
        elseif cmp_strings("Lady M.", 1) then
            _RemoveAnswer("Lady M.")
            say("Youth is hers forever.")
        elseif cmp_strings("job", 1) then
            if not local10 then
                local10 = true
                if local4 in local2 then
                    say("I travel with thee, " .. local22 .. ", to aid thee with my wood craft.")
                    _AddAnswer("forest")
                else
                    say("I am but a humble woodsman. I garner my living from the forest and find knowledge in its depths.")
                    say("I have explored all this region.")
                    _AddAnswer({"knowledge", "forest"})
                end
            else
                say("As I said, my woodcraft encompasses all this forest, even the caves in the mountain.")
                _AddAnswer({"forest", "caves"})
            end
        elseif cmp_strings("introduce", 1) then
            local3 = call_08F5H(local3, local2)
            _RemoveAnswer("introduce")
            if not get_flag(29) or local13 then
                if local4 in local2 or callis_005E(local3) == 0 then
                    _AddAnswer("Fellowship")
                    local13 = true
                end
            end
        elseif cmp_strings("forest", 1) or cmp_strings("secret places", 2) or cmp_strings("caves", 2) or cmp_strings("knowledge", 1) then
            local25 = cmp_strings("forest", 1) and 1 or (cmp_strings("secret places", 2) or cmp_strings("caves", 2)) and 2 or cmp_strings("knowledge", 1) and 3 or 0
            if local25 > 0 then
                if not get_flag(351) or not get_flag(29) then
                    local26 = {"Perhaps introductions are in order first.", "We may speak more after introductions..."}
                    local27 = callis_0010(callis_005E(local26), 1)
                    say("\"" .. local26[local27] .. "\"")
                    local25 = 0
                    _AddAnswer("introduce")
                end
            end
            if local25 == 1 then
                local11 = true
                say("The forest is a wild place, but tamed somewhat in recent years. Within, " .. local22 .. ", thou mayest still find creatures spoken of only in legend.")
                _AddAnswer("creatures")
            elseif local25 == 2 then
                local12 = true
                say("North of my hut is a deep bore-hole into the mountains. Within live bees of a size to rival sheep, or hounds. Their wings stir up leaves as they fly, and they humm with a noise to make men flee in fear.")
                say("Some have entered, never to return. Perhaps they are there still... Death is greedy, and holds a fate for those of like intent.")
                _AddAnswer({"death", "bees", "mountains"})
            elseif local25 == 3 then
                _RemoveAnswer("knowledge")
                say("Many years have I dwelt by the mountains. Many spans have vanished under my roaming feet. Into the depths of the dark swamp I have gone, and to the heights of the mountains. I know the trees of the forest, and the secret places in the earth.")
                _AddAnswer({"secret places", "swamp", "mountains"})
            end
        elseif cmp_strings("swamp", 1) then
            _RemoveAnswer("swamp")
            say("North of the mountain spur is a dense swamp. Killing slime lurk within, guarding a clear spring. All about the water is foul and noisome.")
            say("Into thy boots the foul concoction will seep, bringing on nausea and dizziness. The wise traveller wears swamp boots in such places.")
            say("East, North, and West that mire is drained. Through Yew and past the Abbey the westward river flows. The others both bend north into the sea.")
            _AddAnswer({"sea", "Abbey", "Yew", "slime"})
        elseif cmp_strings("Abbey", 1) then
            _RemoveAnswer("Abbey")
            say("Empath Abbey is its proper name " .. local1 .. ". They practice ancient arts there, the eldest being the fermentation and distillation of spirits. Demand for their products is high in Yew.")
            _AddAnswer("Yew")
        elseif cmp_strings("Yew", 1) then
            _RemoveAnswer("Yew")
            say("Citizens of a reclusive nature feel at peace there. Within the forest lie its buildings, many so grown-over as to seem a part of the wood.")
            say("East of my dwelling the wood is thick, but a woodcrafty traveller may find the houses there.")
        elseif cmp_strings("sea", 1) then
            _RemoveAnswer("sea")
            say("The sea! Its waves sooth a rough mood, but its fury is unrivaled. Ask those who live upon it! A gift it is, to live by it and reap its natural harvest. I cast in a line when I may.")
            say("Dost thou wonder what mysteries the sea must hold?")
            if call_090AH() then
                say("I also wonder. But the doings of those who travel upon it are more familiar to me. I have seen pirates land upon the northern coast.")
                _AddAnswer("pirates")
            else
                say("Perhaps thou art not as fond of the sea as I...")
            end
        elseif cmp_strings("pirates", 1) then
            _RemoveAnswer("pirates")
            say("Perhaps they land to cache their booty in the forest. I have never followed them.")
        elseif cmp_strings("mountains", 1) then
            local15 = true
            say("Vaulting in from the coast looms a narrow spine. Dangerous and sharp rear the crags of those mountains. Caves there hold danger, and death for the unwary.")
            _AddAnswer({"death", "caves"})
        elseif cmp_strings("death", 1) then
            _RemoveAnswer("death")
            say("Death for the greedy. Death for any who steal from the dwellers in the caves.")
            _AddAnswer("caves")
        elseif cmp_strings("creatures", 1) then
            _RemoveAnswer("creatures")
            say("Aye. Such as would devour the unwary and pick bones dry. In the forest are harpies, and slime on the margins of the swamp, and bees in the caves.")
            say("Good game live also in the forest: Foxes and the like.")
            _AddAnswer({"bees", "harpies", "foxes", "slime"})
        elseif cmp_strings("harpies", 1) then
            _RemoveAnswer("harpies")
            if local19 then
                say("Harpies! To battle! Let us slay them at once!")
            else
                say("A malformed flying horror. Thou wouldst not want to meet one.")
            end
        elseif cmp_strings("slime", 1) then
            local14 = true
            say("A dangerous organism is the greenish slime. Acidic to touch, it will hurl pseudopods at its prey from three paces.")
            say("Never sleeping, it has no mind and is composed in the main of poisonous substances. It engulfs and devours hapless animals voraciously.")
            if not local17 then
                say("Attack it with flame! Slime has no defense against it.")
            end
        elseif cmp_strings("foxes", 1) then
            local15 = true
            if not callis_0035(0, 10, 510, local4) then
                local23 = "  See how lustrous is the coat of that fox."
            end
            say("Cunning is the fox, and shy of humans. We shall never belong to the forest as they do." .. local23 .. "\"")
        elseif cmp_strings("bees", 1) then
            local17 = true
            if local20 then
                say("Bees such as these may be tamed with my special arrows!")
                _AddAnswer("arrows")
            else
                say("Such bees as thou hast never seen! Large as a wolf they are, with wings stretching over a span in length.")
                say("A creature stung by them will pass into a deep, death-like sleep.")
                if not (local4 in local2) then
                    say("I have hunted them on many occasions, for I use their poison on my arrows. And I like their honey. Perhaps together we might journey into the cave for some?")
                    _AddAnswer({"arrows", "join"})
                end
            end
        elseif cmp_strings("arrows", 1) then
            _RemoveAnswer("arrows")
            say("I fashion my arrows from the stingers of giant bees. With them one may put a foe to sleep.")
            local28 = ""
            local29 = 0
            if not get_flag(339) then
                local30 = callis_0028(-359, -359, 947, -357)
                if local30 > 6 then
                    local30 = 6
                end
                local31 = callis_0028(-359, -359, 568, -357)
                if (local4 in local2) and local31 <= 6 and local30 > 0 then
                    local28 = "Shall I fashion these stingers into arrows?"
                end
            else
                local28 = "If thou wouldst like, I would be happy to give thee a dozen of my special arrows. Art thou interested?"
                local29 = 12
            end
            if local28 ~= "" then
                say(local28)
                answers = {true, false}
                answer = nil
                return
            end
        elseif cmp_strings(true, 1) then
            local32 = local29 > 1 and "s" or ""
            if not callis_002C(false, -359, -359, 568, local29) then
                say("Use them with care, for even a scratch may put one to sleep! he says, handing you " .. local29 .. " arrow" .. local32 .. ".")
                if not get_flag(339) then
                    callis_002B(true, -359, -359, 947, local29)
                end
                set_flag(339, true)
            else
                say("Perhaps when thou art carrying less I can give them to thee.")
            end
        elseif cmp_strings(false, 1) then
            say("Very well, " .. local1 .. ".")
        elseif cmp_strings("join", 1) then
            _RemoveAnswer("join")
            if local7 <= 8 then
                callis_001E(-10)
                say("I would be honored, " .. local1 .. ".")
                _AddAnswer("Fellowship")
            else
                say("'Twould appear, " .. local1 .. ", that thou already hast more than enough travelling companions.")
            end
        elseif cmp_strings("leave", 1) then
            local33 = true
            say("Dost thou want me to wait here or should I go home?")
            answers = {"go home", "wait here"}
            answer = nil
            return
        elseif cmp_strings("go home", 1) then
            say("Very well, " .. local1 .. ". Fare thee well.")
            callis_001F(-10)
            callis_001D(11, callis_001B(-10, -10))
            answers = {}
            answer = nil
            abort()
        elseif cmp_strings("wait here", 1) then
            say("Very well! I shall wait for thee!")
            callis_001F(-10)
            callis_001D(15, callis_001B(-10, -10))
            answers = {}
            answer = nil
            abort()
        elseif cmp_strings("hermits", 1) then
            local35 = true
            _RemoveAnswer("hermits")
            if not get_flag(338) then
                say("One day I glimpsed a man and a woman deep within the cave as I was hunting. Since then I have seen them twice. I believe they are former citizens of Yew, though I do not know how they live in harmony with the bees.")
                if not local21 then
                    say("These are the people I saw!")
                end
                set_flag(338, true)
                _AddAnswer("bees")
            else
                if not local21 then
                    say("These people are the hermits I spoke of before.")
                else
                    say("Perhaps those hermits are still living in the cave.")
                end
            end
            local12 = true
        elseif cmp_strings("slime", 1) or cmp_strings("foxes", 1) or cmp_strings("bees", 1) then
            if local14 and local15 and not local16 then
                say("This puts me in mind of a story. Wouldst thou like to hear it?")
                answers = {true, false}
                answer = nil
                return
            end
            if local14 then
                _RemoveAnswer("slime")
            end
            if local15 then
                _RemoveAnswer("foxes")
            end
            if local17 then
                _RemoveAnswer("bees")
            end
            if local12 then
                _RemoveAnswer({"caves", "secret places", "death"})
            end
            if local15 then
                _RemoveAnswer("mountains")
            end
            if local11 then
                _RemoveAnswer("forest")
            end
        elseif cmp_strings(true, 1) then
            say("One day while walking along the edge of the swamp I happened upon a strange sight. A fox was held at bay on a small hillock in the midst of the swamp, and all about the hillock writhed green slime.")
            say("Slowly the slime crept up toward the fox, when suddenly the fox trotted directly across the surface of the ooze!")
            say("Unharmed, the fox dashed off into the wood, leaving the slime writhing behind. By this I guess that the victims of slime are those caught sleeping, or unaware.")
            local16 = true
        elseif cmp_strings(false, 1) then
            say("Perhaps another time.")
            local16 = true
        elseif cmp_strings("bye", 1) then
            if not get_flag(29) and not local16 then
                if not get_flag(353) then
                    say("Thy pardon, " .. local1 .. ", but thy visage brings to mind a statue that I once saw. 'Twas a likeness of the ancient hero known as the Avatar.")
                    say("Art thou not that same honorable soul?")
                    answers = {true, false}
                    answer = nil
                    return
                else
                    say("^" .. local1 .. ", if it pleases thee, I would be honored to travel with thee. I have skill in arms, and I can offer my knowledge and wood craft to thee...")
                    _AddAnswer("join")
                    local16 = true
                end
            else
                say("'Til next time, " .. local1 .. ".")
                answers = {}
                answer = nil
                return
            end
        elseif cmp_strings(true, 1) then
            local36 = callis_005A() and "Thou art more fair by far than any likeness in stone could portray." or "That sculptor did thee justice."
            say("Noble hero, it is an honor to make thine aquaintance. " .. local36 .. "\"")
            set_flag(353, true)
        elseif cmp_strings(false, 1) then
            say("I must be mistaken. Farewell.")
        end

        -- Clear answer if not handled
        answer = nil
        return
    elseif eventid == 0 then
        answers = {}
        answer = nil
        abort()
    end
end

-- Helper functions
function eventid
    return 0 -- Placeholder
end

function say(...)
    print(table.concat({...}))
end

function get_flag(id)
    return false -- Placeholder
end

function set_flag(id, value)
    -- Placeholder
end

function cmp_strings(str, count)
    return false -- Placeholder
end