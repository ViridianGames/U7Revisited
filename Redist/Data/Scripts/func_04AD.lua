-- Function 04AD: Beverlea's antique shop dialogue and sales
function func_04AD(eventid, itemref)
    -- Local variables (20 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14, local15, local16, local17, local18, local19

    if eventid == 0 then
        local2 = callis_001B(-173)
        local3 = callis_001C(local2)
        if local3 == 7 then
            local13 = callis_Random2(4, 1)
            if local13 == 1 then
                bark(173, "@Antiques?@")
            elseif local13 == 2 then
                bark(173, "@Curios? Knick knacks?@")
            elseif local13 == 3 then
                bark(173, "@Trinkets? Antiques?@")
            elseif local13 == 4 then
                bark(173, "@Collectibles? Antiques?@")
            end
        else
            call_extern(0x092E, -173)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(173, 0)
    local0 = call_extern(0x0909, 0) -- Likely get_player_name
    local1 = callis_003B(0) -- Unknown, possibly check time or shop status
    local2 = callis_001B(-173) -- Possibly get NPC status
    local3 = callis_000E(-1, 839, -356) -- Possibly check item or world state
    add_answer({"bye", "job", "name"})

    if not get_flag(0x0226) then
        add_dialogue("You see an old woman who gives you a smile of grandmotherly sweetness. You can see immediately that her vision is poor.")
        set_flag(0x0226, true)
    else
        add_dialogue("\"Why, hello again, " .. local0 .. ". It is so good to see thee!\" says Beverlea.")
    end

    while true do
        local answers = {"bye", "job", "name"}
        if get_flag(0x0226) then
            table.insert(answers, "Paws")
            table.insert(answers, "House of Items")
            table.insert(answers, "buy")
        end
        local answer = get_answer(answers)

        if answer == "name" then
            add_dialogue("\"My name is Beverlea.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"Why, I run the House of Items here in Paws.\"")
            add_answer({"Paws", "House of Items"})
        elseif answer == "House of Items" then
            add_dialogue("\"It is a shop that sells antiques and previously used items. Running this shop allows me to remain youthful and active. It is heartening to sell things to the poor people of this town that they might not otherwise be able to afford.\"")
            remove_answer("House of Items")
            add_answer("buy")
        elseif answer == "Paws" then
            add_dialogue("\"Here in Paws the people have very little money, but it matters not, because they care for each other.\"")
            remove_answer("Paws")
        elseif answer == "buy" then
            if local2 == 7 then
                add_dialogue("\"There are many rare and fine things to be bought here in my shop. Bargains to be had nowhere else in all of Britannia.\"")
                add_answer("many fine things")
            else
                add_dialogue("\"My store is now closed. I am usually open in the afternoons.\"")
                remove_answer("buy")
            end
        elseif answer == "many fine things" then
            add_dialogue("\"Let me see... There is a cradle for sale. A rocking horse. A bell. An hourglass. A spittoon. A lute. A sextant... Since I am moving a bit more slowly these days, I let my customers help themselves and take what they have bought. Providing they pay me first, of course. I do trust folks to pay me the correct amount. I am nearly blind, I am afraid.\"")
            remove_answer("many fine things")
            add_answer({"cradle", "rocking horse", "bell", "hourglass", "spittoon", "lute", "sextant"})
        elseif answer == "cradle" then
            add_dialogue("\"That old cradle was the cradle used to rock Gorn the Barbarian to sleep at night when he was just a baby. Thou canst see that there is a crack in its side proving that even as a child Gorn was a strong little tyke. I can let thee take it for ten gold coins. Dost thou wish to buy the cradle?\"")
            local4 = call_extern(0x090A, 0) -- Yes/no prompt
            if local4 == 0 then
                local5 = buy_item("", -359, 1, 10, "cradle")
                if local5 == 1 then
                    add_dialogue("\"Thou mayest take it then. I hope that thou dost enjoy it.\"")
                else
                    add_dialogue("\"Thou dost not have enough gold!\"")
                end
            else
                add_dialogue("A sour look flashes across Beverlea's face. \"Very well. Perhaps I may interest thee in something else.\"")
            end
            remove_answer("cradle")
        elseif answer == "rocking horse" then
            add_dialogue("\"This is the rocking horse that once belonged to a little girl from Britain named Diane. She grew to be one of the finest equestriennes to ever sit upon a horse. I could let thee have this rare and unusual piece for twelve gold. Dost thou wish to buy it?\"")
            local6 = call_extern(0x090A, 0)
            if local6 == 0 then
                local7 = buy_item("", -359, 1, 12, "rocking horse")
                if local7 == 1 then
                    add_dialogue("\"Then thou art free to take the rocking horse. It is thine!\"")
                else
                    add_dialogue("\"Thou dost not have enough money to pay for it!\"")
                end
            else
                add_dialogue("Beverlea rolls her eyes. \"In a browsing mood, are we? Take thy time.\"")
            end
            remove_answer("rocking horse")
        elseif answer == "bell" then
            add_dialogue("\"That bell came from the High Court of Justice in Yew. It was rung to announce that court was in session. I can sell thee that interesting conversation piece for six gold coins. Dost thou wish to buy it?\"")
            local8 = call_extern(0x090A, 0)
            if local8 == 0 then
                local9 = buy_item("", -359, 1, 6, "bell")
                if local9 == 1 then
                    add_dialogue("\"Thou mayest take thy bell. Use it in good health!\"")
                else
                    add_dialogue("\"Thou dost not have enough money to buy it!\"")
                end
            else
                add_dialogue("\"Not in the mood for a bell today?\" She wrinkles her lips in the best attempt at a smile. \"Perhaps something else will strike thy fancy.\"")
            end
            remove_answer("bell")
        elseif answer == "hourglass" then
            if local3 == 0 then
                add_dialogue("\"I also have an antique hourglass. It was sold to me by this old man who was so daft that he could not recall how to use it! I will sell it to thee for five gold pieces. Dost thou wish to buy it?\"")
                local10 = call_extern(0x090A, 0)
                if local10 == 0 then
                    local11 = buy_item("", -359, 1, 5, "hourglass")
                    if local11 == 1 then
                        add_dialogue("\"I thank thee. Thou mayest take thy glass.\"")
                        set_flag(0x0211, true)
                    else
                        add_dialogue("\"Thou dost not have enough money.\"")
                    end
                else
                    add_dialogue("\"Thou art not interested in the hourglass?\" She sighs, \"Very well. Look around. I have all the time in the world.\" You catch just a hint of sarcasm in her voice.")
                end
            else
                add_dialogue("\"Curse mine old head and failing memory! Has the hourglass already been sold?! No! It must have been stolen! One of the few dishonest people in this town must have taken it!\"")
            end
            remove_answer("hourglass")
        elseif answer == "spittoon" then
            add_dialogue("\"I also have an old spittoon. It was once used by... a great many people. Thou mayest have it for a gold piece. Take it! Please!\"")
            local12 = call_extern(0x090A, 0)
            if local12 == 0 then
                local13 = buy_item("", -359, 1, 1, "spittoon")
                if local13 == 1 then
                    add_dialogue("\"I thank thee! Now thou canst go and please do not forget to take it with thee when thou dost leave!\"")
                else
                    add_dialogue("\"Thou dost not even have a single gold piece! Nor the decency to inform me that I was wasting my time in talking with thee.\"")
                    return -- Abrt in .dis
                end
            else
                add_dialogue("\"I have many more things in my shop. Many things of high quality and great value as well. Please keep looking.\"")
            end
            remove_answer("spittoon")
        elseif answer == "lute" then
            add_dialogue("\"I have a lute for sale that once belonged to a travelling bard who lost it in a game of dice. I am asking twenty gold coins for it. A song! Wouldst thou like to buy it?\"")
            local14 = call_extern(0x090A, 0)
            if local14 == 0 then
                local15 = buy_item("", -359, 1, 20, "lute")
                if local15 == 1 then
                    add_dialogue("\"I thank thee, kind customer. Thou mayest take thy lute. I can see that thou art a true artisan with an appreciation for quality.\"")
                else
                    add_dialogue("\"Thou canst not afford the lute!\"")
                end
            else
                add_dialogue("\"Very well, then. Do keep looking. After all, that is why my shop is here.\" You thought you could also hear Beverlea mutter to herself for a few moments after saying this, but you are not entirely certain.")
            end
            remove_answer("lute")
        elseif answer == "sextant" then
            add_dialogue("\"I have a sextant that was sold by the world-famous shipwright Owen of Minoc. They are going to be building a monument to him, I understand. Anyway, the sailor who sold it to me had just suffered some harrowing experience out on the waters. He said when he sold it to me that he was going to retire. He obviously did not realize the value of this item. But I can let thee have it for twenty gold pieces. Dost thou wish to buy it?\"")
            local16 = call_extern(0x090A, 0)
            if local16 == 0 then
                local17 = buy_item("", -359, 1, 20, "sextant")
                if local17 == 1 then
                    add_dialogue("\"Thou mayest take thy sextant! And may thou always have smooth sailing!\"")
                else
                    add_dialogue("\"Thou dost not have enough money!\"")
                end
            else
                add_dialogue("\"I am certain I have something that will interest thee. Browse to thine heart's content.\"")
            end
            remove_answer("sextant")
        elseif answer == "bye" then
            add_dialogue("\"A good day to thee, " .. local0 .. ".\"")
            break
        end
    end
end