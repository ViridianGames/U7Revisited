--- Best guess: Manages Addom’s dialogue in Moonglow, discussing his travels, artifacts, and a crystal for sale.
function func_04A4(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 1 then
        switch_talk_to(0, 164)
        var_0000 = unknown_0908H()
        var_0001 = get_lord_or_lady()
        var_0002 = false
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(518) then
            add_dialogue("You see a handsome, hardened, muscular man who, surprisingly, bears a friendly smile on his face.")
            set_flag(518, true)
        else
            add_dialogue("\"Please, " .. var_0001 .. ". Join me for some company.\"")
            if get_flag(477) and not get_flag(493) then
                add_answer("crystal")
            end
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am called Addom, " .. var_0001 .. ".\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I travel the world in search of rare and unique items to sell to museums. I am not a resident of Moonglow.\"")
                add_answer({"items", "travel", "Moonglow"})
                if get_flag(477) and not get_flag(493) then
                    add_answer("crystal")
                end
            elseif answer == "travel" then
                add_dialogue("\"I have been all over Britannia, " .. var_0001 .. ". Nothing about the land frightens me any longer.\" He grins. \"The same is not true of some of the residents.\"")
                add_answer("residents")
                remove_answer("travel")
            elseif answer == "residents" then
                add_dialogue("\"'Twas a joke, " .. var_0001 .. ".\"")
                remove_answer("residents")
            elseif answer == "items" then
                add_dialogue("\"I have found many odd artifacts. Many of the things thou hast seen in The Music Hall and the Lycaeum have been brought to them by me.\"")
                if not get_flag(477) then
                    add_dialogue("\"In fact, " .. var_0001 .. ", I have this unique crystal I found on the mainland near Jhelom that I am hoping will fetch a fair price from Nelson.\" He pulls out a small clear crystal and shows it to you. The facets gleam in the light.")
                    if not var_0002 then
                        add_answer("Nelson")
                    end
                end
                remove_answer("items")
            elseif answer == "Nelson" then
                add_dialogue("\"He is in charge of the Lycaeum. He loves trinkets and rarities.\"")
                var_0002 = true
                remove_answer("Nelson")
            elseif answer == "Moonglow" then
                add_dialogue("\"I am afraid, " .. var_0001 .. ", that I know nothing about this fair city. I reside in Yew with my wife, Penni, who is the trainer there.\" \"Actually, " .. var_0001 .. ", I have met two people here, other than Nelson.\"")
                remove_answer("Moonglow")
                add_answer({"Penni", "people"})
                set_flag(478, true)
            elseif answer == "people" then
                add_dialogue("I have come to know the bartender and the healer.")
                remove_answer("people")
                add_answer({"healer", "bartender"})
            elseif answer == "bartender" then
                add_dialogue("\"Phearcy is quite friendly. But he does love to gossip. He has offered me a deal whereby I might earn free meals if I can discover why Nelson's assistant reacts differently to some man, or something like that. I am not going to bother, but pray, do not tell Phearcy that!\"")
                if not var_0002 then
                    add_answer("Nelson")
                end
                remove_answer("bartender")
            elseif answer == "healer" then
                add_dialogue("\"Elad is very generous. In fact, he is letting me sleep in one of his spare beds while I am in town. His only charge,\" he laughs, \"is the stories I tell him about mine adventures.\" \"Not a bad trade if I say so myself,\" he shrugs.")
                remove_answer("healer")
            elseif answer == "Penni" then
                add_dialogue("\"She teaches close-quarter combat. Everything I needed to know to survive on my journeys I learned from her.\"")
                remove_answer("Penni")
            elseif answer == "crystal" then
                add_dialogue("\"Dost thou mean this?\" He pulls a small, clear, multi-faceted gem from a pouch beneath his cloak. \"I just found this recently. I was hoping to sell it to the Lycaeum, but, alas, they have no use for it. Dost thou want it, perhaps?\" he asks, hopefully. \"I will sell it to thee for 20 gold.\"")
                var_0003 = unknown_090AH()
                if var_0003 then
                    var_0004 = unknown_002CH(false, 359, 746, 359, 1)
                    var_0005 = unknown_002BH(true, 359, 644, 359, 20)
                    if var_0005 then
                        if var_0004 then
                            add_dialogue("\"I thank thee.\"")
                            set_flag(493, true)
                        else
                            add_dialogue("\"I am truly sorry, " .. var_0001 .. ", but thou dost not have enough room.\"")
                        end
                    else
                        add_dialogue("\"I am truly sorry, " .. var_0001 .. ", but thou dost not have enough gold.\"")
                        var_0006 = unknown_002BH(false, 359, 746, 359, 1)
                    end
                else
                    add_dialogue("\"Very well,\" he sighs, disappointed.")
                end
                remove_answer("crystal")
            elseif answer == "bye" then
                add_dialogue("\"May thy days be always pleasant, " .. var_0001 .. ".\"")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end