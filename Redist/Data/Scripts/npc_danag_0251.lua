--- Best guess: Manages Danag's dialogue in Buccaneer's Den, the interim Fellowship leader, revealing sinister Fellowship plans and executioner details when the Cube vibrates.
function npc_danag_0251(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        switch_talk_to(251)
        var_0000 = get_schedule(251)
        var_0001 = is_player_wearing_fellowship_medallion()
        var_0002 = utility_unknown_1073(1, 359, 981, 1, 357)
        if var_0000 == 7 then
            add_dialogue("Danag nods his head at you. \"I do not mean to be impolite, but I am concentrating on the games. I wish to win a bundle tonight!\"")
            add_dialogue("He rubs his hand with glee.")
            return
        end
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(260) and not get_flag(309) then
            add_answer("Hook")
        end
        if not get_flag(612) then
            add_answer("Elizabeth and Abraham")
        end
        if not get_flag(681) then
            add_dialogue("You see a jovial man with a wide smile. It is obvious he is enjoying his life.")
            if var_0001 then
                add_dialogue("He notices your medallion.")
                add_dialogue("\"Fellow member! How art thee! I hope thy journey to Buccaneer's Den was not too troublesome! Welcome to our island!\"")
            end
            if var_0002 then
                add_dialogue("The Cube vibrates.")
                add_dialogue("\"And I recognize thee as the Avatar! I know that thou art condemned to die!\"")
                add_dialogue("Danag smiles as if he had just said that you had been invited to dine with the king.")
            end
            set_flag(681, true)
        else
            add_dialogue("\"Hello, there!\" Danag says.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Danag, my friend.\" The man overdoes a majestic bow.")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am interim Fellowship Branch leader here on Buccaneer's Den. Our regular leader, Abraham, is away on Fellowship business at the moment.\"")
                add_answer({"Abraham", "Fellowship"})
            elseif answer == "Fellowship" then
                add_dialogue("\"The Fellowship has been present on Buccaneer's Den for a long time. This is one of the oldest branches in Britannia, second only to the headquarters in Britain. Thou mayest wonder why an island of such ill-repute would attract The Fellowship.\"")
                remove_answer("Fellowship")
                add_answer("wonder")
            elseif answer == "wonder" then
                add_dialogue("\"The founders of The Fellowship felt that the people who inhabit this island would benefit the most from our organization.\"")
                if var_0002 then
                    add_dialogue("\"Especially since we would help them build an empire of sin and gluttony out of Buccaneer's Den.\"")
                    add_dialogue("You notice the Cube has been vibrating while Danag was speaking.")
                else
                    add_dialogue("\"Amidst all of the sin, the debauchery, the piracy, the gambling, the drunkenness -- The Fellowship has made its stand and recruited members to follow our principles. Buccaneer's Den has changed as a result.\"")
                end
                remove_answer("wonder")
                add_answer("Buccaneer's Den")
            elseif answer == "Buccaneer's Den" then
                add_dialogue("\"Long ago it was merely a hideout for pirates, scavengers, and rogues. Look around.\"")
                if var_0002 then
                    add_dialogue("\"Now it is the center of corruption in all of Britannia. The pirates are all controlled by The Fellowship.\"")
                    add_dialogue("The Cube continues to vibrate.")
                else
                    add_dialogue("\"Now Buccaneer's Den is an island paradise. It has its own commerce. It pays taxes to Lord British. The pirates here are now businessmen. They have made something of their lives.\"")
                end
                add_dialogue("\"As a result, The Baths and The House of Games are two of the most profitable establishments in the country.\"")
                remove_answer("Buccaneer's Den")
                add_answer({"House of Games", "The Baths"})
            elseif answer == "The Baths" then
                if var_0002 then
                    add_dialogue("\"It is, of course, a place where one may experience the pleasures of the flesh. All of the profits go to The Fellowship.\"")
                else
                    add_dialogue("\"It is a purely innocent business which caters to the weary who are in need of relaxation. One may receive physical and mental cleansing there.\"")
                end
                add_dialogue("\"It is truly a jewel in the crown that is Britannia.\"")
                remove_answer("The Baths")
            elseif answer == "House of Games" then
                if var_0002 then
                    add_dialogue("\"Why, it is a gambling parlor! The Fellowship certainly takes in a bundle from that place!\"")
                else
                    add_dialogue("\"It is an outfit which challenges the mind and its ability for assessing strategy in life. Exercising this aspect of one's brain is important for one's self-esteem and well-being.\"")
                end
                remove_answer("House of Games")
            elseif answer == "Abraham" then
                add_dialogue("\"Abraham is one of the members of the inner circle of The Fellowship. He and his colleague Elizabeth travel the country periodically, usually distributing or collecting the organization's funds and doing business at the other branches.\"")
                if var_0002 then
                    add_dialogue("The Cube vibrates.")
                    add_dialogue("\"Uhm... er... he is also a coordinator for executions and he cheats at cards.\"")
                end
                remove_answer("Abraham")
                add_answer("Elizabeth")
            elseif answer == "Elizabeth" then
                add_dialogue("\"Elizabeth is an extremely intelligent woman who acts as Director of Special Projects. She usually works with Batlin in Britain, but she spends most of her time travelling from branch to branch.\"")
                if var_0002 then
                    add_dialogue("As the Cube vibrates, Danag adds, \"She is, uhm... also a royal she-bitch and will murder thee at a moment's notice.\"")
                end
                remove_answer("Elizabeth")
                add_answer("Special Projects")
            elseif answer == "Special Projects" then
                add_dialogue("\"They might be anything from building a shelter for poor peasants to creating a new branch in a town without the benefit of a Fellowship Hall.\"")
                if var_0002 then
                    add_dialogue("As the Cube vibrates, Danag proudly adds, \"Our current Special Project is building the Black Gate for The Guardian. It is located at the Isle of the Avatar in our secret underground complex!\"")
                    add_answer({"complex", "Black Gate"})
                end
                remove_answer("Special Projects")
            elseif answer == "Black Gate" then
                add_dialogue("Danag's eyes widen with excitement. \"It is the gateway for our coming Lord and Master! He will be coming through in virtually a few hours!\"")
                remove_answer("Black Gate")
            elseif answer == "complex" then
                add_dialogue("\"It is inside a dungeon within the Shrine of the Codex. A barrier keeps out unwanted visitors. A special key opens the barrier, and only a few select people have one.\"")
                remove_answer("complex")
                add_answer("key")
            elseif answer == "key" then
                add_dialogue("\"I do not own one. The only people that do are Elizabeth and Abraham, Batlin, and Hook himself. Hook probably keeps his key in his abode.\"")
                remove_answer("key")
            elseif answer == "Hook" then
                if var_0002 then
                    add_dialogue("The Cube vibrates.")
                    add_dialogue("\"Man with a Hook? That's his name! 'Hook'! He lives here on the island! In fact, his quarters are in the secret catacombs behind the House of Games! Thou canst reach it by asking Sintag the guard about Hook. Of course, thou dost know that Hook is The Fellowship's chief executioner... along with his assistant, the gargoyle Forskis.\"")
                    add_answer({"Forskis", "executioner"})
                    utility_unknown_1041(100)
                else
                    add_dialogue("\"A pirate with a hook for a hand? No... I do not believe I know him. There are many pirates on this island. Many of them are missing appendages, too!\"")
                end
                remove_answer("Hook")
            elseif answer == "Elizabeth and Abraham" then
                add_dialogue("\"They usually travel together. They just arrived from our Meditation Retreat near Serpent's Hold and I believe they are somewhere on the island. Abraham told me I must keep working as interim branch leader until his return.\"")
                set_flag(680, true)
                if var_0002 then
                    add_dialogue("The Cube vibrates.")
                end
                add_dialogue("\"Actually, I believe they are on their way to the Isle of the Avatar to take care of our new Special Project.\"")
                remove_answer("Elizabeth and Abraham")
            elseif answer == "executioner" then
                add_dialogue("\"That's right. Hook does all the dirty work for The Fellowship. He was trained by Master De Snel in Jhelom. De Snel trained all the previous executioners as well. In fact, De Snel himself was The Fellowship's first executioner!\"")
                remove_answer("executioner")
            elseif answer == "Forskis" then
                add_dialogue("\"I understand the gargoyle's name means 'henchman' in Gargish. He's a tough wingless gargoyle who helps Hook out. I believe he resides in the catacombs with Hook.\"")
                remove_answer("Forskis")
            elseif answer == "bye" then
                add_dialogue("\"Farewell!\"")
                break
            end
        end
    elseif eventid == 0 then
        utility_unknown_1070(251)
    end
    return
end