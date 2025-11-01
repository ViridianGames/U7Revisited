--- Best guess: Manages Beverlea's dialogue in Paws, an elderly shopkeeper selling antiques at the House of Items, with items like a cradle, lute, and sextant.
function npc_beverlea_0173(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013

    if eventid == 1 then
        switch_talk_to(0, 173)
        var_0000 = get_lord_or_lady()
        var_0001 = get_schedule()
        var_0002 = get_schedule_type(get_npc_name(173))
        var_0003 = find_nearest(-1, 839, 356)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(550) then
            add_dialogue("You see an old woman who gives you a smile of grandmotherly sweetness. You can see immediately that her vision is poor.")
            set_flag(550, true)
        else
            add_dialogue("\"Why, hello again, " .. var_0000 .. ". It is so good to see thee!\" says Beverlea.")
        end
        while true do
            local answer = get_answer()
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
                if var_0002 == 7 then
                    add_dialogue("\"There are many rare and fine things to be bought here in my shop. Bargains to be had nowhere else in all of Britannia.\"")
                    add_answer("many fine things")
                else
                    add_dialogue("\"My store is now closed. I am usually open in the afternoons.\"")
                end
                remove_answer("buy")
            elseif answer == "many fine things" then
                add_dialogue("\"Let me see... There is a cradle for sale. A rocking horse. A bell. An hourglass. A spittoon. A lute. A sextant... Since I am moving a bit more slowly these days, I let my customers help themselves and take what they have bought. Providing they pay me first, of course. I do trust folks to pay me the correct amount. I am nearly blind, I am afraid.\"")
                remove_answer("many fine things")
                add_answer({"sextant", "lute", "spittoon", "hourglass", "bell", "rocking horse", "cradle"})
            elseif answer == "cradle" then
                add_dialogue("\"That old cradle was the cradle used to rock Gorn the Barbarian to sleep at night when he was just a baby. Thou canst see that there is a crack in its side proving that even as a child Gorn was a strong little tyke. I can let thee take it for ten gold coins. Dost thou wish to buy the cradle?\"")
                var_0004 = ask_yes_no()
                if var_0004 then
                    var_0005 = remove_party_items(true, 359, 644, 359, 10)
                    if var_0005 then
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
                var_0006 = ask_yes_no()
                if var_0006 then
                    var_0007 = remove_party_items(true, 359, 644, 359, 12)
                    if var_0007 then
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
                var_0008 = ask_yes_no()
                if var_0008 then
                    var_0009 = remove_party_items(true, 359, 644, 359, 6)
                    if var_0009 then
                        add_dialogue("\"Thou mayest take thy bell. Use it in good health!\"")
                    else
                        add_dialogue("\"Thou dost not have enough money to buy it!\"")
                    end
                else
                    add_dialogue("\"Not in the mood for a bell today?\" She wrinkles her lips in the best attempt at a smile. \"Perhaps something else will strike thy fancy.\"")
                end
                remove_answer("bell")
            elseif answer == "hourglass" then
                if var_0003 then
                    add_dialogue("\"I also have an antique hourglass. It was sold to me by this old man who was so daft that he could not recall how to use it! I will sell it to thee for five gold pieces. Dost thou wish to buy it?\"")
                    var_000A = ask_yes_no()
                    if var_000A then
                        var_000B = remove_party_items(true, 359, 644, 359, 5)
                        if var_000B then
                            add_dialogue("\"I thank thee. Thou mayest take thy glass.\"")
                            set_flag(529, true)
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
                var_000C = ask_yes_no()
                if var_000C then
                    var_000D = remove_party_items(true, 359, 644, 359, 1)
                    if var_000D then
                        add_dialogue("\"I thank thee! Now thou canst go and please do not forget to take it with thee when thou dost leave!\"")
                    else
                        add_dialogue("\"Thou dost not even have a single gold piece! Nor the decency to inform me that I was wasting my time in talking with thee.\"")
                        return
                    end
                else
                    add_dialogue("\"I have many more things in my shop. Many things of high quality and great value as well. Please keep looking.\"")
                end
                remove_answer("spittoon")
            elseif answer == "lute" then
                add_dialogue("\"I have a lute for sale that once belonged to a travelling bard who lost it in a game of dice. I am asking twenty gold coins for it. A song! Wouldst thou like to buy it?\"")
                var_000E = ask_yes_no()
                if var_000E then
                    var_000F = remove_party_items(true, 359, 644, 359, 20)
                    if var_000F then
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
                var_0010 = ask_yes_no()
                if var_0010 then
                    var_0011 = remove_party_items(true, 359, 644, 359, 20)
                    if var_0011 then
                        add_dialogue("\"Thou mayest take thy sextant! And may thou always have smooth sailing!\"")
                    else
                        add_dialogue("\"Thou dost not have enough money!\"")
                    end
                else
                    add_dialogue("\"I am certain I have something that will interest thee. Browse to thine heart's content.\"")
                end
                remove_answer("sextant")
            elseif answer == "bye" then
                add_dialogue("\"A good day to thee, " .. var_0000 .. ".\"")
                break
            end
        end
    elseif eventid == 0 then
        var_0002 = get_schedule_type(get_npc_name(173))
        var_0012 = random2(4, 1)
        if var_0002 == 7 then
            if var_0012 == 1 then
                var_0013 = "@Antiques?@"
            elseif var_0012 == 2 then
                var_0013 = "@Curios? Knick knacks?@"
            elseif var_0012 == 3 then
                var_0013 = "@Trinkets? Antiques?@"
            elseif var_0012 == 4 then
                var_0013 = "@Collectibles? Antiques?@"
            end
            bark(173, var_0013)
        else
            utility_unknown_1070(173)
        end
    end
    return
end