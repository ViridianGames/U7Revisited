--- Best guess: Manages Tseramed’s dialogue, handling introductions, Fellowship opinions, and forest-related topics, with flag-based progression.
function func_040A(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_001A, var_001B, var_001C, var_001D, var_001E, var_001F, var_0020, var_0021, var_0022, var_0023, var_0024, var_0025, var_0026, var_0027, var_0028, var_0029, var_002A

    if eventid ~= 1 then
        if eventid == 0 then
            return
        end
        return
    end

    start_conversation()
    unknown_0003H(0, -10)
    var_0000 = unknown_0908H()
    var_0001 = get_lord_or_lady()
    var_0002 = get_party_members()
    var_0003 = unknown_093CH(unknown_001BH(-356))
    var_0004 = unknown_001BH(-10)
    var_0005 = unknown_001BH(-6)
    var_0006 = is_player_female() == 0 and "Abraham" or "Elizabeth"
    var_0007 = #var_0002
    var_0008 = var_0007 > 1 and "s" or ""
    var_0009 = 0
    var_000A = false
    var_000B = false
    var_000C = false
    var_000D = false
    var_000E = false
    var_000F = false
    var_0010 = false
    var_0011 = false
    var_0012 = false
    var_0013 = false
    var_0014 = false
    var_0015 = false
    var_0016 = false
    var_0017 = unknown_0035H(0, 13, 529, var_0004)
    var_0018 = unknown_0035H(0, 13, 510, var_0004)
    var_0019 = unknown_0035H(0, 13, 532, var_0004)
    var_001A = unknown_0035H(0, 20, 494, var_0004)
    var_001B = get_flag(228) or get_flag(229)
    var_001C = get_flag(350) and "noble enchanter" or "valiant warrior"
    if not get_flag(29) and get_flag(349) then
        unknown_08F2H(var_0000, var_0006)
        return
    end
    if var_0004 == var_0002 then
        unknown_08F4H(var_0000, var_0007)
        if not var_001B then
            add_answer("hermits")
        end
        if not var_0017 then
            add_answer("slime")
        end
        if not var_0018 then
            add_answer("foxes")
        end
        if not var_0019 then
            add_answer("harpies")
        end
        if not var_001A then
            add_dialogue("\"We need not be concerned about these bees, so long as we have a number of my trusty arrows.\"")
            add_answer("bees")
        end
        add_answer("Fellowship")
        var_0013 = true
    else
        add_dialogue("\"Greetings, traveller" .. var_0008 .. ".\"")
    end
    if get_flag(349) then
        var_001C = "lowly deceiver"
    end
    add_answer({"bye", "job", "name"})
    if get_flag(29) and var_0007 == 1 then
        set_flag(351, true)
    end
    if not get_flag(354) and var_0004 == var_0002 then
        add_answer(var_0006)
    end
    if not get_flag(351) and var_0007 > 1 and get_flag(29) then
        add_answer("introduce")
    end
    while true do
        var_001D = ""
        if cmps("name", var_0000) then
            cmps("name", var_0001)
            if get_flag(29) then
                add_dialogue("\"I am Tseramed the woodsman. Thou art a " .. var_001C .. ".\"")
            else
                add_dialogue("\"I am called Tseramed. Art thou Fellowship members? How art thou called?\"")
                save_answers()
                var_0009 = var_0009 + 1
                add_answer({"Fellowship", var_0000})
                if not get_flag(353) then
                    add_answer("Avatar")
                end
            end
        elseif cmps("Avatar") then
            cmps("Avatar")
            set_flag(353, true)
            add_dialogue("\"The Avatar! This is a strange chance. Tell me Avatar, by what name art thou called?\"")
            cmps(var_0000)
            remove_answer(var_0000)
            set_flag(29, true)
            add_dialogue("\"Well met, " .. var_0000 .. "\"")
            if not get_flag(353) then
                add_dialogue("Thy demeanor is noble.")
            end
            if var_0007 == 1 then
                set_flag(351, true)
            end
            restore_answers()
            if not get_flag(351) then
                add_dialogue("Perhaps thou couldst introduce me to thy companions?\"")
                add_answer("introduce")
            end
        elseif cmps("Fellowship") then
            cmps("Fellowship")
            if not get_flag(29) then
                if var_0004 == var_0002 or get_flag(354) then
                    add_dialogue("\"I do not trust The Fellowship, and most especially " .. var_0006 .. ".\"")
                    add_answer(var_0006)
                else
                    add_dialogue("\"I have no love for The Fellowship. We shall speak of it when I know thee better.\"")
                end
            else
                add_dialogue("\"Yes. Perhaps I am addressing the illustrious " .. var_0006 .. "?\"")
                add_answer(var_0006)
            end
            cmps(var_0006)
            remove_answer(var_0006)
            if not get_flag(29) then
                add_dialogue("\"Not long ago The Fellowship began to spread its influence throughout Britannia.")
                add_dialogue("\"In their early days they attracted many bright and enthusiastic young people, among them my love, Lady M.")
                add_dialogue("A woman so intelligent could not help but rise in their ranks. Her direct superior was " .. var_0006 .. ".")
                add_dialogue("One black evening she fell gravely ill. According to friends of mine, " .. var_0006 .. " forbade her to visit the local healer. By the time I learned of this, she had already passed away.")
                add_dialogue("She rests now forever in the Yew graveyard, may her sleep be peaceful. I searched the land for " .. var_0006 .. ", but never found my quarry. In fact, it seems that every time I near my prey, they have already vanished! My search shall never be truly over.\"")
                remove_answer(var_0006)
                add_answer({"Lady M.", "Yew"})
            else
                restore_answers()
                set_flag(349, true)
                var_001E = get_flag(353) and "thou dost tarnish the title of Avatar!" or ""
                add_dialogue("\"Knave, " .. var_001E .. " I have not forgotten thy wrong doing, nor the evil crime that followed it.")
                add_dialogue("Oh soul as black as pitch!\"")
                unknown_08F2H(var_0000, var_0006)
                return
            end
        elseif cmps("Lady M.") then
            cmps("Lady M.")
            add_dialogue("\"Youth is hers forever.\"")
        elseif cmps("job") then
            if not var_000A then
                var_000A = true
                if var_0004 == var_0002 then
                    add_dialogue("\"I travel with thee, " .. var_001C .. ", to aid thee with my wood craft.\"")
                    add_answer("forest")
                else
                    add_dialogue("\"I am but a humble woodsman. I garner my living from the forest and find knowledge in its depths.")
                    add_dialogue("I have explored all this region.\"")
                    add_answer({"knowledge", "forest"})
                end
            else
                add_dialogue("\"As I said, my woodcraft encompasses all this forest, even the caves in the mountain.\"")
                add_answer({"forest", "caves"})
            end
        elseif cmps("introduce") then
            var_0003 = unknown_08F5H(var_0002, var_0003)
            cmps("introduce")
            if not get_flag(29) and not var_0013 then
                if var_0004 == var_0002 or #var_0003 == 0 then
                    add_answer("Fellowship")
                    var_0013 = true
                end
            end
        elseif cmps("forest", "secret places", "caves", "knowledge") then
            var_001F = cmps("forest") and 1 or cmps("secret places", "caves") and 2 or cmps("knowledge") and 3 or 0
            if var_001F > 0 then
                if not get_flag(351) and not get_flag(29) then
                    var_0020 = {"Perhaps introductions are in order first.", "We may speak more after introductions..."}
                    var_0021 = var_0020[random2(#var_0020, 1)]
                    add_dialogue("\"" .. var_0021 .. "\"")
                    var_001F = 0
                    add_answer("introduce")
                end
                if var_001F == 1 then
                    var_000D = true
                    add_dialogue("\"The forest is a wild place, but tamed somewhat in recent years. Within, " .. var_001C .. ", thou mayest still find creatures spoken of only in legend.\"")
                    add_answer("creatures")
                elseif var_001F == 2 then
                    var_000C = true
                    add_dialogue("\"North of my hut is a deep bore-hole into the mountains. Within live bees of a size to rival sheep, or hounds. Their wings stir up leaves as they fly, and they humm with a noise to make men flee in fear.\"")
                    add_dialogue("\"Some have entered, never to return. Perhaps they are there still... Death is greedy, and holds a fate for those of like intent.\"")
                    add_answer({"death", "bees", "mountains"})
                elseif var_001F == 3 then
                    remove_answer("knowledge")
                    add_dialogue("\"Many years have I dwelt by the mountains. Many spans have vanished under my roaming feet. Into the depths of the dark swamp I have gone, and to the heights of the mountains. I know the trees of the forest, and the secret places in the earth.\"")
                    add_answer({"secret places", "swamp", "mountains"})
                end
            end
        elseif cmps("swamp") then
            cmps("swamp")
            add_dialogue("\"North of the mountain spur is a dense swamp. Killing slime lurk within, guarding a clear spring. All about the water is foul and noisome.")
            add_dialogue("Into thy boots the foul concoction will seep, bringing on nausea and dizziness. The wise traveller wears swamp boots in such places.")
            add_dialogue("East, North, and West that mire is drained. Through Yew and past the Abbey the westward river flows. The others both bend north into the sea.\"")
            add_answer({"sea", "Abbey", "Yew", "slime"})
        elseif cmps("Abbey") then
            cmps("Abbey")
            add_dialogue("\"Empath Abbey is its proper name " .. var_0001 .. ". They practice ancient arts there, the eldest being the fermentation and distillation of spirits. Demand for their products is high in Yew.\"")
            add_answer("Yew")
        elseif cmps("Yew") then
            cmps("Yew")
            add_dialogue("\"Citizens of a reclusive nature feel at peace there. Within the forest lie its buildings, many so grown-over as to seem a part of the wood.\"")
            add_dialogue("\"East of my dwelling the wood is thick, but a woodcrafty traveller may find the houses there.\"")
        elseif cmps("sea") then
            cmps("sea")
            add_dialogue("\"The sea! Its waves sooth a rough mood, but its fury is unrivaled. Ask those who live upon it! A gift it is, to live by it and reap its natural harvest. I cast in a line when I may.")
            add_dialogue("Dost thou wonder what mysteries the sea must hold?\"")
            if unknown_090AH() then
                add_dialogue("\"I also wonder. But the doings of those who travel upon it are more familiar to me. I have seen pirates land upon the northern coast.\"")
                add_answer("pirates")
            else
                add_dialogue("\"Perhaps thou art not as fond of the sea as I...\"")
            end
        elseif cmps("pirates") then
            cmps("pirates")
            add_dialogue("\"Perhaps they land to cache their booty in the forest. I have never followed them.\"")
        elseif cmps("mountains") then
            var_000B = true
            add_dialogue("\"Vaulting in from the coast looms a narrow spine. Dangerous and sharp rear the crags of those mountains. Caves there hold danger, and death for the unwary.\"")
            add_answer({"death", "caves"})
        elseif cmps("death") then
            cmps("death")
            add_dialogue("\"Death for the greedy. Death for any who steal from the dwellers in the caves.\"")
            add_answer("caves")
        elseif cmps("creatures") then
            cmps("creatures")
            add_dialogue("\"Aye. Such as would devour the unwary and pick bones dry. In the forest are harpies, and slime on the margins of the swamp, and bees in the caves.")
            add_dialogue("\"Good game live also in the forest: Foxes and the like.\"")
            add_answer({"bees", "harpies", "foxes", "slime"})
        elseif cmps("harpies") then
            cmps("harpies")
            if var_0019 then
                add_dialogue("\"Harpies! To battle! Let us slay them at once!\"")
            else
                add_dialogue("\"A malformed flying horror. Thou wouldst not want to meet one.\"")
            end
        elseif cmps("slime") then
            var_000E = true
            add_dialogue("\"A dangerous organism is the greenish slime. Acidic to touch, it will hurl pseudopods at its prey from three paces.")
            add_dialogue("\"Never sleeping, it has no mind and is composed in the main of poisonous substances. It engulfs and devours hapless animals voraciously.\"")
            if not var_0017 then
                add_dialogue("\"Attack it with flame! Slime has no defense against it.\"")
            end
        elseif cmps("foxes") then
            var_000F = true
            if not unknown_0035H(0, 10, 510, var_0004) then
                var_001D = "  See how lustrous is the coat of that fox."
            end
            add_dialogue("\"Cunning is the fox, and shy of humans. We shall never belong to the forest as they do." .. var_001D .. "\"")
        elseif cmps("bees") then
            var_0011 = true
            if var_001A then
                add_dialogue("\"Bees such as these may be tamed with my special arrows!\"")
                add_answer("arrows")
            else
                add_dialogue("\"Such bees as thou hast never seen! Large as a wolf they are, with wings stretching over a span in length.")
                add_dialogue("A creature stung by them will pass into a deep, death-like sleep.\"")
                if not (var_0004 == var_0002) then
                    add_dialogue("\"I have hunted them on many occasions, for I use their poison on my arrows. And I like their honey. Perhaps together we might journey into the cave for some?\"")
                    add_answer({"arrows", "join"})
                end
            end
        elseif cmps("arrows") then
            cmps("arrows")
            add_dialogue("\"I fashion my arrows from the stingers of giant bees. With them one may put a foe to sleep.\"")
            var_0022 = get_flag(339) and "If thou wouldst like, I would be happy to give thee a dozen of my special arrows. Art thou interested?" or "Shall I fashion these stingers into arrows?"
            var_0023 = 0
            if not get_flag(339) then
                var_0023 = unknown_0028H(359, 359, 947, 357)
                if var_0023 > 6 then
                    var_0023 = 6
                end
                var_0024 = unknown_0028H(359, 359, 568, 357)
                if var_0004 == var_0002 and var_0024 <= 6 and var_0023 > 0 then
                    var_0022 = "Shall I fashion these stingers into arrows?"
                end
            else
                var_0023 = 12
            end
            if var_0022 ~= "" then
                add_dialogue(var_0022)
                if unknown_090AH() then
                    var_0025 = unknown_002CH(false, 359, 359, 568, var_0023)
                    if var_0025 then
                        var_0026 = var_0023 > 1 and "s" or ""
                        add_dialogue("\"Use them with care, for even a scratch may put one to sleep!\" he says, handing you " .. var_0023 .. " arrow" .. var_0026 .. ".")
                        if not get_flag(339) then
                            var_001F = unknown_002BH(359, 359, 947, var_0023)
                        end
                        set_flag(339, true)
                    else
                        add_dialogue("\"Perhaps when thou art carrying less I can give them to thee.\"")
                    end
                else
                    add_dialogue("\"Very well, " .. var_0001 .. ".\"")
                end
            end
        elseif cmps("join") then
            cmps("join")
            if var_0007 < 8 then
                unknown_001EH(-10)
                add_dialogue("\"I would be honored, " .. var_0001 .. ".\"")
                add_answer("Fellowship")
            else
                add_dialogue("\"'Twould appear, " .. var_0001 .. ", that thou already hast more than enough travelling companions.\"")
            end
        elseif cmps("leave") then
            var_0027 = true
            add_dialogue("\"Dost thou want me to wait here or should I go home?\"")
            unknown_0009H()
            var_0028 = unknown_090BH({"go home", "wait here"})
            if var_0028 == "wait here" then
                add_dialogue("\"Very well! I shall wait for thee!\"")
                unknown_001FH(-10)
                unknown_001DH(15, unknown_001BH(-10))
                return
            else
                add_dialogue("\"Very well, " .. var_0001 .. ". Fare thee well.\"")
                unknown_001FH(-10)
                unknown_001DH(11, unknown_001BH(-10))
                return
            end
        elseif cmps("hermits") then
            var_0029 = true
            if var_000C and var_000B and not var_0012 then
                add_dialogue("\"Speaking of caves and mountains, there are some who dwell near, or perhaps in, the cave of bees. They are hermits.\"")
                var_0029 = true
                var_0012 = true
                add_answer("bees")
            end
            if var_0029 then
                cmps("hermits")
                if not get_flag(338) then
                    add_dialogue("\"One day I glimpsed a man and a woman deep within the cave as I was hunting. Since then I have seen them twice. I believe they are former citizens of Yew, though I do not know how they live in harmony with the bees.\"")
                    if var_001B then
                        add_dialogue("\"These are the people I saw!\"")
                    end
                    set_flag(338, true)
                    add_answer("bees")
                else
                    if var_001B then
                        add_dialogue("\"These people are the hermits I spoke of before.\"")
                    else
                        add_dialogue("\"Perhaps those hermits are still living in the cave.\"")
                    end
                end
                var_0012 = true
            end
        elseif var_000E and var_000F and not var_0010 then
            add_dialogue("\"This puts me in mind of a story. Wouldst thou like to hear it?\"")
            if unknown_090AH() then
                add_dialogue("\"One day while walking along the edge of the swamp I happened upon a strange sight. A fox was held at bay on a small hillock in the midst of the swamp, and all about the hillock writhed green slime.")
                add_dialogue("Slowly the slime crept up toward the fox, when suddenly the fox trotted directly across the surface of the ooze!")
                add_dialogue("Unharmed, the fox dashed off into the wood, leaving the slime writhing behind. By this I guess that the victims of slime are those caught sleeping, or unaware.\"")
            else
                add_dialogue("\"Perhaps another time.\"")
            end
            var_0010 = true
        end
        if var_000E then
            remove_answer("slime")
        end
        if var_000F then
            remove_answer("foxes")
        end
        if var_0011 then
            remove_answer("bees")
        end
        if var_000C then
            remove_answer({"caves", "secret places", "death"})
        end
        if var_000B then
            remove_answer("mountains")
        end
        if var_000D then
            remove_answer("forest")
        end
        if get_flag(353) and not (var_0004 == var_0002) and not get_flag(354) then
            unknown_08F3H(var_0002)
            set_flag(354, true)
        end
        if var_0004 == var_0002 then
            remove_answer("join")
        end
        if cmps("bye") then
            if var_0004 == var_0002 or var_0027 then
                var_0016 = true
            end
            if not get_flag(29) and not var_0016 then
                if not get_flag(353) then
                    add_dialogue("\"Thy pardon, " .. var_0001 .. ", but thy visage brings to my mind a statue that I once saw.  'Twas a likeness of the ancient hero known as the Avatar.")
                    add_dialogue("Art thou not that same honorable soul?\"")
                    if unknown_090AH() then
                        var_002A = is_player_female() == 1 and "Thou art more fair by far than any likeness in stone could portray." or "That sculptor did thee justice."
                        add_dialogue("\"Noble hero, it is an honor to make thine aquaintance. " .. var_002A .. "\"")
                        set_flag(353, true)
                    else
                        add_dialogue("\"I must be mistaken. Farewell.\"")
                    end
                else
                    add_dialogue("\"^" .. var_0001 .. ", if it pleases thee, I would be honored to travel with thee. I have skill in arms, and I can offer my knowledge and wood craft to thee...\"")
                    add_answer("join")
                    var_0016 = true
                end
            else
                add_dialogue("\"'Til next time, " .. var_0001 .. ".\"")
            end
        end
    end
    return
end