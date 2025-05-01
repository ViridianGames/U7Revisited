-- Function 04A4: Addom's dialogue and crystal purchase
function func_04A4(eventid, itemref)
    -- Local variables (7 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid ~= 1 then
        return
    end

    switch_talk_to(164, 0)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = false
    add_answer({"bye", "job", "name"})

    if not get_flag(0x0206) then
        add_dialogue("You see a handsome, hardened, muscular man who, surprisingly, bears a friendly smile on his face.")
        set_flag(0x0206, true)
    else
        add_dialogue("\"Please, ", local1, ". Join me for some company.\"")
        if not (get_flag(0x01DD) and get_flag(0x01ED)) then
            add_answer("crystal")
        end
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am called Addom, ", local1, ".\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I travel the world in search of rare and unique items to sell to museums. I am not a resident of Moonglow.\"")
            add_answer({"items", "travel", "Moonglow"})
            if not (get_flag(0x01DD) and get_flag(0x01ED)) then
                add_answer("crystal")
            end
        elseif answer == "travel" then
            add_dialogue("\"I have been all over Britannia, ", local1, ". Nothing about the land frightens me any longer.\" He grins. \"The same is not true of some of the residents.\"")
            add_answer("residents")
            remove_answer("travel")
        elseif answer == "residents" then
            add_dialogue("\"'Twas a joke, " .. local1 .. ".\"")
            remove_answer("residents")
        elseif answer == "items" then
            add_dialogue("\"I have found many odd artifacts. Many of the things thou hast seen in The Music Hall and the Lycaeum have been brought to them by me.\"")
            if not get_flag(0x01DD) then
                add_dialogue("\"In fact, ", local1, ", I have this unique crystal I found on the mainland near Jhelom that I am hoping will fetch a fair price from Nelson.\"He pulls out a small clear crystal and shows it to you.The facets gleam in the light.")
                if not local2 then
                    add_answer("Nelson")
                end
            end
            remove_answer("items")
        elseif answer == "Nelson" then
            add_dialogue("\"He is in charge of the Lycaeum. He loves trinkets and rarities.\"")
            local2 = true
            remove_answer("Nelson")
        elseif answer == "Moonglow" then
            add_dialogue("\"I am afraid, ", local1, ", that I know nothing about this fair city. I reside in Yew with my wife, Penni, who is the trainer there.\"Actually, ", local1, ", I have met two people here, other than Nelson.\"")
            remove_answer("Moonglow")
            add_answer({"Penni", "people"})
            set_flag(0x01DE, true)
        elseif answer == "people" then
            add_dialogue("I have come to know the bartender and the healer.")
            remove_answer("people")
            add_answer({"healer", "bartender"})
        elseif answer == "bartender" then
            add_dialogue("\"Phearcy is quite friendly. But he does love to gossip. He has offered me a deal whereby I might earn free meals if I can discover why Nelson's assistant reacts differently to some man, or something like that. I am not going to bother, but pray, do not tell Phearcy that!\"")
            if not local2 then
                add_answer("Nelson")
            end
            remove_answer("bartender")
        elseif answer == "healer" then
            add_dialogue("\"Elad is very generous. In fact, he is letting me sleep in one of his spare beds while I am in town. His only charge,\" he laughs, \"is the stories I tell him about mine adventures.Not a bad trade if I say so myself,\" he shrugs.")
            remove_answer("healer")
        elseif answer == "Penni" then
            add_dialogue("\"She teaches close-quarter combat. Everything I needed to know to survive on my journeys I learned from her.\"")
            remove_answer("Penni")
        elseif answer == "crystal" then
            add_dialogue("\"Dost thou mean this?\" He pulls a small, clear, multi-faceted gem from a pouch beneath his cloak. \"I just found this recently. I was hoping to sell it to the Lycaeum, but, alas, they have no use for it. Dost thou want it, perhaps?\" he asks, hopefully. \"I will sell it to thee for 20 gold.\"")
            local3 = call_090AH()
            if local3 then
                local4 = callis_002C(false, -359, -359, 746, 1)
                local5 = callis_002B(true, -359, -359, 644, 20)
                if local5 then
                    if local4 then
                        add_dialogue("\"I thank thee.\"")
                        set_flag(0x01ED, true)
                    else
                        add_dialogue("\"I am truly sorry, ", local1, ", but thou dost not have enough room.\"")
                    end
                    local6 = callis_002B(false, -359, -359, 746, 1)
                else
                    add_dialogue("\"I am truly sorry, ", local1, ", but thou dost not have enough gold.\"")
                end
            else
                add_dialogue("\"Very well,\" he sighs, disappointed.")
            end
            remove_answer("crystal")
        elseif answer == "bye" then
            add_dialogue("\"May thy days be always pleasant, ", local1, ".\"")
            break
        end

        -- Note: Original has 'db 40' here, ignored
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