--- Best guess: Handles dialogue with Greg, the Provisioner's Shop owner, discussing his shop's history, lucky provisions, and a story about Gorn, with suspicions about a fake Avatar.
function npc_greg_0038(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    start_conversation()
    if eventid == 1 then
        switch_talk_to(38)
        var_0000 = get_lord_or_lady()
        var_0001 = get_schedule(38) --- Guess: Checks game state or timer
        var_0002 = get_schedule_type(38) --- Guess: Gets object state
        var_0003 = is_player_wearing_fellowship_medallion() --- Guess: Checks Fellowship membership
        add_answer({"bye", "job", "name"})
        if not get_flag(167) then
            add_dialogue("You see a gleeful-looking merchant with an enthusiastic voice and manner.")
            set_flag(167, true)
        else
            add_dialogue("\"Why, what can I do for thee, " .. var_0000 .. "?\" asks Greg.")
        end
        while true do
            var_0004 = get_answer()
            if var_0004 == "name" then
                add_dialogue("\"Why, my name is Greg. It is good to see thee.\"")
                remove_answer("name")
            elseif var_0004 == "job" then
                add_dialogue("\"Why, I run the Provisioner's Shop here in Britain. A second home to the intrepid, it is.\"")
                add_answer({"buy", "Britain", "Provisioner's Shop"})
            elseif var_0004 == "Provisioner's Shop" then
                add_dialogue("\"Why, thou dost look to be a person to whom adventure is no stranger. Whether thou art climbing a mountain, sailing the ocean, crossing a desert, exploring a dungeon or sleeping under the stars I have just what thou mayest need.\"")
                remove_answer("Provisioner's Shop")
                add_answer("need")
            elseif var_0004 == "Britain" then
                add_dialogue("\"I have moved my store here as a service to Lord British, who uses me exclusively to outfit all of his various expeditions. It is true!\"")
                remove_answer("Britain")
                add_answer({"Lord British", "moved"})
            elseif var_0004 == "moved" then
                add_dialogue("\"I used to have my shop in Paws. But no one in Paws has the money to buy much of anything.\"")
                remove_answer("moved")
            elseif var_0004 == "need" then
                add_dialogue("\"What every adventurer needs is good luck! There is just something about this shop, about the items bought here, something about me and my shop that is simply very lucky. I can give thee an example of what I mean.\"")
                remove_answer("need")
                add_answer({"example", "lucky"})
            elseif var_0004 == "example" then
                add_dialogue("\"A fighting man named Gorn once bought a shovel from me and he told me that it saved his life.\"")
                add_answer({"saved his life", "Gorn"})
                remove_answer("example")
            elseif var_0004 == "Gorn" then
                add_dialogue("\"Perhaps thou knowest of Gorn. He speaks with a most peculiar accent!\"")
                remove_answer("Gorn")
            elseif var_0004 == "saved his life" then
                add_dialogue("\"Gorn wanted to dig for some buried treasure somewhere, when he heard some noises behind him. Upon turning, he was horrified to see a swarm of undead skeletons rushing toward him! In his haste to dig up the treasure, he had unbuckled his belt and laid down his sword. The only thing in his hands was the shovel. He immediately began swinging it and ended up knocking all the skeletons to bits! He now considers it his 'lucky shovel'!\"")
                remove_answer("saved his life")
            elseif var_0004 == "Lord British" then
                add_dialogue("\"This is Lord British's favorite provisionary shop. He told me so himself. All sorts of famous adventurers pass through these doors. Why, just last week, we had the Avatar himself in this, my very own store!\"")
                var_0004 = utility_unknown_1073(359, 359, 838, 1, 356) --- Guess: Verifies Avatar identity
                if var_0004 then
                    add_dialogue("\"Why, now that I mention it, he was dressed a lot like thou art. Yes, he was.\"")
                    add_answer("dressed like Avatar")
                end
                if var_0003 then
                    add_dialogue("\"Why, I seem to remember that Avatar was also wearing a Fellowship medallion like the one thou dost possess. Hmmmm. And he nearly robbed me blind. I shall have to keep a careful eye on thee, I will.\"")
                    add_answer("robbed you blind?")
                end
                add_answer("another Avatar?")
                remove_answer("Lord British")
            elseif var_0004 == "another Avatar?" then
                add_dialogue("\"Well, he said he was the Avatar. But then it is not all that unusual encountering some loon or fool who claims to be the Avatar!\" He looks at you and for a moment appears a little embarrassed.")
                remove_answer("another Avatar?")
            elseif var_0004 == "dressed like Avatar" then
                add_dialogue("\"He was dressed like the Avatar, similarly to how thou art presently attired. At first I thought it was Jesse, the actor who is playing the Avatar in the play by that director... What is his name again?\"")
                add_dialogue("\"Oh, well. It was not him.\"")
                remove_answer("dressed like Avatar")
            elseif var_0004 == "robbed you blind?" then
                add_dialogue("\"Thou wouldst think that one who appears to be like the Avatar would be worthy of trust. But, no. In this day and age there is no telling what to expect!\"")
                remove_answer("robbed you blind?")
            elseif var_0004 == "lucky" then
                add_dialogue("\"My customers are all people who go out and perform dangerous feats of bravery and derring-do. But most keep returning to buy more provisions time and again. With all the dangerous things my customers do, it is a wonder I have not lost them all and gone out of business!\"")
                remove_answer("lucky")
            elseif var_0004 == "buy" then
                if var_0002 ~= 7 then
                    add_dialogue("\"I am dreadfully sorry but the Provisioner's Shop is currently closed. Do return at noon when it shall be open once again.\"")
                else
                    add_dialogue("\"As I say, we have everything thou dost need to have a jolly splendid adventure!\"")
                    utility_unknown_0921() --- Guess: Processes provision purchase
                end
                remove_answer("buy")
            elseif var_0004 == "bye" then
                break
            end
        end
        add_dialogue("\"Good day to thee, " .. var_0000 .. ".\"")
    elseif eventid == 0 then
        var_0001 = get_schedule(38) --- Guess: Checks game state or timer
        var_0002 = get_schedule_type(38) --- Guess: Gets object state
        if var_0002 == 7 then
            var_0005 = random(1, 4)
            if var_0005 == 1 then
                var_0006 = "@Provisions here!@"
            elseif var_0005 == 2 then
                var_0006 = "@Step right in!@"
            elseif var_0005 == 3 then
                var_0006 = "@Thou art welcome!@"
            elseif var_0005 == 4 then
                var_0006 = "@Fine goods here!@"
            end
            bark(38, var_0006)
        else
            utility_unknown_1070(38) --- Guess: Triggers a game event
        end
    end
end