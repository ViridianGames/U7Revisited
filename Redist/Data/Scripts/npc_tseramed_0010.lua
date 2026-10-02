--- Tseramed (NPC 10) — woodsman of Yew. Introductions, Fellowship, forest lore, join/leave.
function npc_tseramed_0010(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    start_conversation()
    switch_talk_to(10)

    local player_name = get_player_name()
    local lord_or_lady = get_lord_or_lady()
    local party_names = get_party_members()
    local party_size = 0
    if type(party_names) == "table" then
        party_size = #party_names
    end
    local in_party = npc_id_in_party(10)
    local fellowship_leader = is_player_female() and "Elizabeth" or "Abraham"
    local traveller_s = party_size > 1 and "s" or ""
    local epithet = get_flag(350) and "noble enchanter" or "valiant warrior"
    if get_flag(349) then
        epithet = "lowly deceiver"
    end

    local tseramed_ref = get_npc_name(10)
    local slime_near = find_nearby(0, 13, 529, tseramed_ref)
    local foxes_near = find_nearby(0, 13, 510, tseramed_ref)
    local harpies_near = find_nearby(0, 13, 532, tseramed_ref)
    local bees_near = find_nearby(0, 20, 494, tseramed_ref)
    local hermits_present = get_flag(228) or get_flag(229)

    local function nearby_any(results)
        return type(results) == "table" and #results > 0
    end

    -- Still angry from a prior deception and identity never cleared.
    if not get_flag(29) and get_flag(349) then
        utility_unknown_1010(player_name, fellowship_leader)
        abort()
    end

    local offered_join = false
    local talked_job = false
    local talked_mountains = false
    local talked_caves = false
    local talked_forest = false
    local talked_slime = false
    local talked_foxes = false
    local told_fox_story = false
    local talked_bees = false
    local talked_hermits = false
    local unlocked_fellowship = false
    local leaving = false

    if in_party then
        utility_unknown_1012(party_size, player_name)
        if not hermits_present then
            add_answer("hermits")
        end
        if not nearby_any(slime_near) then
            add_answer("slime")
        end
        if not nearby_any(foxes_near) then
            add_answer("foxes")
        end
        if not nearby_any(harpies_near) then
            add_answer("harpies")
        end
        if nearby_any(bees_near) then
            add_dialogue("\"We need not be concerned about these bees, so long as we have a number of my trusty arrows.\"")
            add_answer("bees")
        end
        add_answer("Fellowship")
        unlocked_fellowship = true
    else
        add_dialogue("\"Greetings, traveller" .. traveller_s .. ".\"")
    end

    add_answer({"bye", "job", "name"})
    if get_flag(29) and party_size == 1 then
        set_flag(351, true)
    end
    if not get_flag(354) and in_party then
        add_answer(fellowship_leader)
    end
    if not get_flag(351) and party_size > 1 and get_flag(29) then
        add_answer("introduce")
    end
    if in_party then
        add_answer("leave")
        remove_answer("join")
    end

    while true do
        local answer = get_answer()
        if type(answer) ~= "string" then
            -- First resume after yield can return a non-string; re-read the global.
            answer = get_answer()
        end
        if type(answer) ~= "string" then
            break
        end

        if answer == "name" then
            remove_answer("name")
            if get_flag(29) then
                add_dialogue("\"I am Tseramed the woodsman. Thou art a " .. epithet .. ".\"")
            else
                add_dialogue("\"I am called Tseramed. Art thou Fellowship members? How art thou called?\"")
                save_answers()
                add_answer({"Fellowship", player_name})
                if not get_flag(353) then
                    add_answer("Avatar")
                end
            end
        elseif answer == "Avatar" then
            remove_answer("Avatar")
            set_flag(353, true)
            add_dialogue("\"The Avatar! This is a strange chance. Tell me Avatar, by what name art thou called?\"")
            add_answer(player_name)
        elseif answer == player_name then
            remove_answer(player_name)
            set_flag(29, true)
            add_dialogue("\"Well met, " .. player_name .. "\"")
            if get_flag(353) then
                add_dialogue("Thy demeanor is noble.")
            end
            if party_size == 1 then
                set_flag(351, true)
            end
            restore_answers()
            if not get_flag(351) then
                add_dialogue("Perhaps thou couldst introduce me to thy companions?\"")
                add_answer("introduce")
            end
        elseif answer == "Fellowship" then
            remove_answer("Fellowship")
            if not get_flag(29) then
                if in_party or get_flag(354) then
                    add_dialogue("\"I do not trust The Fellowship, and most especially " .. fellowship_leader .. ".\"")
                    add_answer(fellowship_leader)
                else
                    add_dialogue("\"I have no love for The Fellowship. We shall speak of it when I know thee better.\"")
                end
            else
                add_dialogue("\"Yes. Perhaps I am addressing the illustrious " .. fellowship_leader .. "?\"")
                add_answer(fellowship_leader)
            end
        elseif answer == fellowship_leader then
            remove_answer(fellowship_leader)
            if not get_flag(29) then
                add_dialogue("\"Not long ago The Fellowship began to spread its influence throughout Britannia.")
                add_dialogue("\"In their early days they attracted many bright and enthusiastic young people, among them my love, Lady M.")
                add_dialogue("A woman so intelligent could not help but rise in their ranks. Her direct superior was " .. fellowship_leader .. ".")
                add_dialogue("One black evening she fell gravely ill. According to friends of mine, " .. fellowship_leader .. " forbade her to visit the local healer. By the time I learned of this, she had already passed away.")
                add_dialogue("She rests now forever in the Yew graveyard, may her sleep be peaceful. I searched the land for " .. fellowship_leader .. ", but never found my quarry. In fact, it seems that every time I near my prey, they have already vanished! My search shall never be truly over.\"")
                add_answer({"Lady M.", "Yew"})
            else
                restore_answers()
                set_flag(349, true)
                local tarnish = get_flag(353) and "thou dost tarnish the title of Avatar!" or ""
                add_dialogue("\"Knave, " .. tarnish .. " I have not forgotten thy wrong doing, nor the evil crime that followed it.")
                add_dialogue("Oh soul as black as pitch!\"")
                utility_unknown_1010(player_name, fellowship_leader)
                abort()
            end
        elseif answer == "Lady M." then
            remove_answer("Lady M.")
            add_dialogue("\"Youth is hers forever.\"")
        elseif answer == "job" then
            if not talked_job then
                talked_job = true
                if in_party then
                    add_dialogue("\"I travel with thee, " .. epithet .. ", to aid thee with my wood craft.\"")
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
        elseif answer == "introduce" then
            remove_answer("introduce")
            party_names = utility_unknown_1013(party_names, nil)
            in_party = npc_id_in_party(10)
            if type(party_names) == "table" then
                party_size = #party_names
            end
            if not get_flag(29) and not unlocked_fellowship then
                if in_party or get_flag(351) then
                    add_answer("Fellowship")
                    unlocked_fellowship = true
                end
            end
        elseif answer == "forest" then
            if not get_flag(351) and not get_flag(29) then
                local prompts = {
                    "Perhaps introductions are in order first.",
                    "We may speak more after introductions...",
                }
                add_dialogue("\"" .. prompts[random2(#prompts, 1)] .. "\"")
                add_answer("introduce")
            else
                talked_forest = true
                add_dialogue("\"The forest is a wild place, but tamed somewhat in recent years. Within, " .. epithet .. ", thou mayest still find creatures spoken of only in legend.\"")
                add_answer("creatures")
                remove_answer("forest")
            end
        elseif answer == "secret places" or answer == "caves" then
            if not get_flag(351) and not get_flag(29) then
                local prompts = {
                    "Perhaps introductions are in order first.",
                    "We may speak more after introductions...",
                }
                add_dialogue("\"" .. prompts[random2(#prompts, 1)] .. "\"")
                add_answer("introduce")
            else
                talked_caves = true
                add_dialogue("\"North of my hut is a deep bore-hole into the mountains. Within live bees of a size to rival sheep, or hounds. Their wings stir up leaves as they fly, and they humm with a noise to make men flee in fear.\"")
                add_dialogue("\"Some have entered, never to return. Perhaps they are there still... Death is greedy, and holds a fate for those of like intent.\"")
                add_answer({"death", "bees", "mountains"})
                remove_answer({"caves", "secret places"})
            end
        elseif answer == "knowledge" then
            if not get_flag(351) and not get_flag(29) then
                local prompts = {
                    "Perhaps introductions are in order first.",
                    "We may speak more after introductions...",
                }
                add_dialogue("\"" .. prompts[random2(#prompts, 1)] .. "\"")
                add_answer("introduce")
            else
                remove_answer("knowledge")
                add_dialogue("\"Many years have I dwelt by the mountains. Many spans have vanished under my roaming feet. Into the depths of the dark swamp I have gone, and to the heights of the mountains. I know the trees of the forest, and the secret places in the earth.\"")
                add_answer({"secret places", "swamp", "mountains"})
            end
        elseif answer == "swamp" then
            remove_answer("swamp")
            add_dialogue("\"North of the mountain spur is a dense swamp. Killing slime lurk within, guarding a clear spring. All about the water is foul and noisome.")
            add_dialogue("Into thy boots the foul concoction will seep, bringing on nausea and dizziness. The wise traveller wears swamp boots in such places.")
            add_dialogue("East, North, and West that mire is drained. Through Yew and past the Abbey the westward river flows. The others both bend north into the sea.\"")
            add_answer({"sea", "Abbey", "Yew", "slime"})
        elseif answer == "Abbey" then
            remove_answer("Abbey")
            add_dialogue("\"Empath Abbey is its proper name " .. lord_or_lady .. ". They practice ancient arts there, the eldest being the fermentation and distillation of spirits. Demand for their products is high in Yew.\"")
            add_answer("Yew")
        elseif answer == "Yew" then
            remove_answer("Yew")
            add_dialogue("\"Citizens of a reclusive nature feel at peace there. Within the forest lie its buildings, many so grown-over as to seem a part of the wood.\"")
            add_dialogue("\"East of my dwelling the wood is thick, but a woodcrafty traveller may find the houses there.\"")
        elseif answer == "sea" then
            remove_answer("sea")
            add_dialogue("\"The sea! Its waves sooth a rough mood, but its fury is unrivaled. Ask those who live upon it! A gift it is, to live by it and reap its natural harvest. I cast in a line when I may.")
            add_dialogue("Dost thou wonder what mysteries the sea must hold?\"")
            if ask_yes_no() then
                add_dialogue("\"I also wonder. But the doings of those who travel upon it are more familiar to me. I have seen pirates land upon the northern coast.\"")
                add_answer("pirates")
            else
                add_dialogue("\"Perhaps thou art not as fond of the sea as I...\"")
            end
        elseif answer == "pirates" then
            remove_answer("pirates")
            add_dialogue("\"Perhaps they land to cache their booty in the forest. I have never followed them.\"")
        elseif answer == "mountains" then
            talked_mountains = true
            remove_answer("mountains")
            add_dialogue("\"Vaulting in from the coast looms a narrow spine. Dangerous and sharp rear the crags of those mountains. Caves there hold danger, and death for the unwary.\"")
            add_answer({"death", "caves"})
        elseif answer == "death" then
            remove_answer("death")
            add_dialogue("\"Death for the greedy. Death for any who steal from the dwellers in the caves.\"")
            add_answer("caves")
        elseif answer == "creatures" then
            remove_answer("creatures")
            add_dialogue("\"Aye. Such as would devour the unwary and pick bones dry. In the forest are harpies, and slime on the margins of the swamp, and bees in the caves.")
            add_dialogue("\"Good game live also in the forest: Foxes and the like.\"")
            add_answer({"bees", "harpies", "foxes", "slime"})
        elseif answer == "harpies" then
            remove_answer("harpies")
            if nearby_any(harpies_near) then
                add_dialogue("\"Harpies! To battle! Let us slay them at once!\"")
            else
                add_dialogue("\"A malformed flying horror. Thou wouldst not want to meet one.\"")
            end
        elseif answer == "slime" then
            talked_slime = true
            remove_answer("slime")
            add_dialogue("\"A dangerous organism is the greenish slime. Acidic to touch, it will hurl pseudopods at its prey from three paces.")
            add_dialogue("\"Never sleeping, it has no mind and is composed in the main of poisonous substances. It engulfs and devours hapless animals voraciously.\"")
            if not nearby_any(slime_near) then
                add_dialogue("\"Attack it with flame! Slime has no defense against it.\"")
            end
        elseif answer == "foxes" then
            talked_foxes = true
            remove_answer("foxes")
            local fox_note = ""
            if nearby_any(find_nearby(0, 10, 510, tseramed_ref)) then
                fox_note = "  See how lustrous is the coat of that fox."
            end
            add_dialogue("\"Cunning is the fox, and shy of humans. We shall never belong to the forest as they do." .. fox_note .. "\"")
        elseif answer == "bees" then
            talked_bees = true
            remove_answer("bees")
            if nearby_any(bees_near) then
                add_dialogue("\"Bees such as these may be tamed with my special arrows!\"")
                add_answer("arrows")
            else
                add_dialogue("\"Such bees as thou hast never seen! Large as a wolf they are, with wings stretching over a span in length.")
                add_dialogue("A creature stung by them will pass into a deep, death-like sleep.\"")
                if not in_party then
                    add_dialogue("\"I have hunted them on many occasions, for I use their poison on my arrows. And I like their honey. Perhaps together we might journey into the cave for some?\"")
                    add_answer({"arrows", "join"})
                end
            end
        elseif answer == "arrows" then
            remove_answer("arrows")
            add_dialogue("\"I fashion my arrows from the stingers of giant bees. With them one may put a foe to sleep.\"")
            local prompt = ""
            local arrow_count = 0
            if get_flag(339) then
                prompt = "If thou wouldst like, I would be happy to give thee a dozen of my special arrows. Art thou interested?"
                arrow_count = 12
            else
                arrow_count = count_objects(59, 359, 947, 357)
                if arrow_count > 6 then
                    arrow_count = 6
                end
                local existing_arrows = count_objects(59, 359, 568, 357)
                if in_party and existing_arrows <= 6 and arrow_count > 0 then
                    prompt = "Shall I fashion these stingers into arrows?"
                elseif arrow_count > 0 then
                    prompt = "Shall I fashion these stingers into arrows?"
                end
            end
            if prompt ~= "" and arrow_count > 0 then
                add_dialogue(prompt)
                if ask_yes_no() then
                    local given = add_party_items(false, 359, 359, 568, arrow_count)
                    if given then
                        local plural = arrow_count > 1 and "s" or ""
                        add_dialogue("\"Use them with care, for even a scratch may put one to sleep!\" he says, handing you " .. arrow_count .. " arrow" .. plural .. ".")
                        if not get_flag(339) then
                            remove_party_items(359, 359, 947, arrow_count)
                        end
                        set_flag(339, true)
                    else
                        add_dialogue("\"Perhaps when thou art carrying less I can give them to thee.\"")
                    end
                else
                    add_dialogue("\"Very well, " .. lord_or_lady .. ".\"")
                end
            end
        elseif answer == "join" then
            remove_answer("join")
            party_names = get_party_members()
            party_size = 0
            if type(party_names) == "table" then
                party_size = #party_names
            end
            if party_size < 8 then
                add_to_party(10)
                in_party = true
                add_dialogue("\"I would be honored, " .. lord_or_lady .. ".\"")
                add_answer({"Fellowship", "leave"})
                remove_answer("join")
            else
                add_dialogue("\"'Twould appear, " .. lord_or_lady .. ", that thou already hast more than enough travelling companions.\"")
            end
        elseif answer == "leave" then
            leaving = true
            add_dialogue("\"Dost thou want me to wait here or should I go home?\"")
            local choice = ask_answer({"go home", "wait here"})
            if choice == "wait here" then
                add_dialogue("\"Very well! I shall wait for thee!\"")
                remove_from_party(10)
                set_schedule_type(10, 15)
                abort()
            else
                add_dialogue("\"Very well, " .. lord_or_lady .. ". Fare thee well.\"")
                remove_from_party(10)
                set_schedule_type(10, 11)
                abort()
            end
        elseif answer == "hermits" then
            remove_answer("hermits")
            if talked_caves and talked_mountains and not talked_hermits then
                add_dialogue("\"Speaking of caves and mountains, there are some who dwell near, or perhaps in, the cave of bees. They are hermits.\"")
                add_answer("bees")
            end
            if not get_flag(338) then
                add_dialogue("\"One day I glimpsed a man and a woman deep within the cave as I was hunting. Since then I have seen them twice. I believe they are former citizens of Yew, though I do not know how they live in harmony with the bees.\"")
                if hermits_present then
                    add_dialogue("\"These are the people I saw!\"")
                end
                set_flag(338, true)
                add_answer("bees")
            elseif hermits_present then
                add_dialogue("\"These people are the hermits I spoke of before.\"")
            else
                add_dialogue("\"Perhaps those hermits are still living in the cave.\"")
            end
            talked_hermits = true
        elseif answer == "bye" then
            if in_party or leaving then
                offered_join = true
            end
            if not get_flag(29) and not offered_join then
                if not get_flag(353) then
                    add_dialogue("\"Thy pardon, " .. lord_or_lady .. ", but thy visage brings to my mind a statue that I once saw.  'Twas a likeness of the ancient hero known as the Avatar.")
                    add_dialogue("Art thou not that same honorable soul?\"")
                    if ask_yes_no() then
                        local compliment = is_player_female()
                            and "Thou art more fair by far than any likeness in stone could portray."
                            or "That sculptor did thee justice."
                        add_dialogue("\"Noble hero, it is an honor to make thine aquaintance. " .. compliment .. "\"")
                        set_flag(353, true)
                    else
                        add_dialogue("\"I must be mistaken. Farewell.\"")
                        break
                    end
                else
                    add_dialogue("\"^" .. lord_or_lady .. ", if it pleases thee, I would be honored to travel with thee. I have skill in arms, and I can offer my knowledge and wood craft to thee...\"")
                    add_answer("join")
                    offered_join = true
                end
            else
                add_dialogue("\"'Til next time, " .. lord_or_lady .. ".\"")
                break
            end
        end

        -- Fox/slime anecdote once both topics have been discussed.
        if talked_slime and talked_foxes and not told_fox_story then
            add_dialogue("\"This puts me in mind of a story. Wouldst thou like to hear it?\"")
            if ask_yes_no() then
                add_dialogue("\"One day while walking along the edge of the swamp I happened upon a strange sight. A fox was held at bay on a small hillock in the midst of the swamp, and all about the hillock writhed green slime.")
                add_dialogue("Slowly the slime crept up toward the fox, when suddenly the fox trotted directly across the surface of the ooze!")
                add_dialogue("Unharmed, the fox dashed off into the wood, leaving the slime writhing behind. By this I guess that the victims of slime are those caught sleeping, or unaware.\"")
            else
                add_dialogue("\"Perhaps another time.\"")
            end
            told_fox_story = true
        end

        -- After Avatar title is known and he is not yet in the party, ask combat preference once.
        if get_flag(353) and not in_party and not get_flag(354) then
            utility_unknown_1011(party_names)
            set_flag(354, true)
        end

        if in_party then
            remove_answer("join")
        end
    end
end
