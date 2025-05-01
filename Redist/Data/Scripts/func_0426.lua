-- Manages Greg's dialogue in Britain, covering provisioner shop, lucky items, Gorn's story, and a fake Avatar encounter.
function func_0426(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 1 then
        switch_talk_to(38, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = switch_talk_to(38)
        local3 = get_item_type()

        add_answer({"bye", "job", "name"})

        if not get_flag(167) then
            say("You see a gleeful-looking merchant with an enthusiastic voice and manner.")
            set_flag(167, true)
        end
        say("\"Why, what can I do for thee, " .. local0 .. "?\" asks Greg.")

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"Why, my name is Greg. It is good to see thee.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"Why, I run the Provisioner's Shop here in Britain. A second home to the intrepid, it is.\"")
                add_answer({"buy", "Britain", "Provisioner's Shop"})
            elseif answer == "Provisioner's Shop" then
                say("\"Why, thou dost look to be a person to whom adventure is no stranger. Whether thou art climbing a mountain, sailing the ocean, crossing a desert, exploring a dungeon or sleeping under the stars I have just what thou mayest need.\"")
                remove_answer("Provisioner's Shop")
                add_answer("need")
            elseif answer == "Britain" then
                say("\"I have moved my store here as a service to Lord British, who uses me exclusively to outfit all of his various expeditions. It is true!\"")
                remove_answer("Britain")
                add_answer({"Lord British", "moved"})
            elseif answer == "moved" then
                say("\"I used to have my shop in Paws. But no one in Paws has the money to buy much of anything.\"")
                remove_answer("moved")
            elseif answer == "need" then
                say("\"What every adventurer needs is good luck! There is just something about this shop, about the items bought here, something about me and my shop that is simply very lucky. I can give thee an example of what I mean.\"")
                remove_answer("need")
                add_answer({"example", "lucky"})
            elseif answer == "example" then
                say("\"A fighting man named Gorn once bought a shovel from me and he told me that it saved his life.\"")
                add_answer({"saved his life", "Gorn"})
                remove_answer("example")
            elseif answer == "Gorn" then
                say("\"Perhaps thou knowest of Gorn. He speaks with a most peculiar accent!\"")
                remove_answer("Gorn")
            elseif answer == "saved his life" then
                say("\"Gorn wanted to dig for some buried treasure somewhere, when he heard some noises behind him. Upon turning, he was horrified to see a swarm of undead skeletons rushing toward him! In his haste to dig up the treasure, he had unbuckled his belt and laid down his sword. The only thing in his hands was the shovel. He immediately began swinging it and ended up knocking all the skeletons to bits! He now considers it his 'lucky shovel'!\"")
                remove_answer("saved his life")
            elseif answer == "Lord British" then
                say("\"This is Lord British's favorite provisionary shop. He told me so himself. All sorts of famous adventurers pass through these doors. Why, just last week, we had the Avatar himself in this, my very own store!\"")
                local4 = add_item(-359, -359, 838, 1, -356) -- Unmapped intrinsic 0931
                if not local4 then
                    say("\"Why, now that I mention it, he was dressed a lot like thou art. Yes, he was.\"")
                    add_answer("dressed like Avatar")
                end
                if local3 then
                    say("\"Why, I seem to remember that Avatar was also wearing a Fellowship medallion like the one thou dost possess. Hmmmm. And he nearly robbed me blind. I shall have to keep a careful eye on thee, I will.\"")
                    add_answer("robbed you blind?")
                end
                add_answer("another Avatar?")
                remove_answer("Lord British")
            elseif answer == "another Avatar?" then
                say("\"Well, he said he was the Avatar. But then it is not all that unusual encountering some loon or fool who claims to be the Avatar!\" He looks at you and for a moment appears a little embarrassed.")
                remove_answer("another Avatar?")
            elseif answer == "dressed like Avatar" then
                say("\"He was dressed like the Avatar, similarly to how thou art presently attired. At first I thought it was Jesse, the actor who is playing the Avatar in the play by that director... What is his name again?~~\"Oh, well. It was not him.\"")
                remove_answer("dressed like Avatar")
            elseif answer == "robbed you blind?" then
                say("\"Thou wouldst think that one who appears to be like the Avatar would be worthy of trust. But, no. In this day and age there is no telling what to expect!\"")
                remove_answer("robbed you blind?")
            elseif answer == "lucky" then
                say("\"My customers are all people who go out and perform dangerous feats of bravery and derring-do. But most keep returning to buy more provisions time and again. With all the dangerous things my customers do, it is a wonder I have not lost them all and gone out of business!\"")
                remove_answer("lucky")
            elseif answer == "buy" then
                if local2 ~= 7 then
                    say("\"I am dreadfully sorry but the Provisioner's Shop is currently closed. Do return at noon when it shall be open once again.\"")
                else
                    say("\"As I say, we have everything thou dost need to have a jolly splendid adventure!\"")
                    buy_provisions() -- Unmapped intrinsic 0899
                end
                remove_answer("buy")
            elseif answer == "bye" then
                say("\"Good day to thee, " .. local0 .. ".\"*")
                break
            end
        end
    elseif eventid == 0 then
        local1 = get_party_size()
        local2 = switch_talk_to(38)
        local4 = random(1, 4)
        local5 = ""

        if local2 == 7 then
            if local4 == 1 then
                local5 = "@Provisions here!@"
            elseif local4 == 2 then
                local5 = "@Step right in!@"
            elseif local4 == 3 then
                local5 = "@Thou art welcome!@"
            elseif local4 == 4 then
                local5 = "@Fine goods here!@"
            end
            item_say(local5, -38)
        else
            switch_talk_to(38)
        end
    end
    return
end