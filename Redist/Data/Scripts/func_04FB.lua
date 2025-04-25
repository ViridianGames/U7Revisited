-- Function 04FB: Danag's dialogue and Black Gate revelations
function func_04FB(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid == 0 then
        call_092EH(-251)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -251)
    local0 = callis_003B()
    local1 = callis_0067()
    local2 = call_0931H(-359, -359, 981, 1, -357)

    if local0 == 7 then
        say("Danag nods his head at you. \"I do not mean to be impolite, but I am concentrating on the games. I wish to win a bundle tonight!\"")
        say("He rubs his hand with glee.*")
        return
    end

    _AddAnswer({"bye", "job", "name"})
    if get_flag(0x0104) or get_flag(0x0135) then
        _AddAnswer("Hook")
    end
    if not get_flag(0x0264) then
        _AddAnswer("Elizabeth and Abraham")
    end
    if not get_flag(0x02A9) then
        say("You see a jovial man with a wide smile. It is obvious he is enjoying his life.")
        if local1 then
            say("He notices your medallion.")
            say("\"Fellow member! How art thee! I hope thy journey to Buccaneer's Den was not too troublesome! Welcome to our island!\"")
        end
        if local2 then
            say("The Cube vibrates.")
            say("\"And I recognize thee as the Avatar! I know that thou art condemned to die!\"")
            say("Danag smiles as if he had just said that you had been invited to dine with the king.")
        end
        set_flag(0x02A9, true)
    else
        say("\"Hello, there!\" Danag says.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Danag, my friend.\" The man overdoes a majestic bow.")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am interim Fellowship Branch leader here on Buccaneer's Den. Our regular leader, Abraham, is away on Fellowship business at the moment.\"")
            _AddAnswer({"Abraham", "Fellowship"})
        elseif answer == "Fellowship" then
            say("\"The Fellowship has been present on Buccaneer's Den for a long time. This is one of the oldest branches in Britannia, second only to the headquarters in Britain. Thou mayest wonder why an island of such ill-repute would attract The Fellowship.\"")
            _RemoveAnswer("Fellowship")
            _AddAnswer("wonder")
        elseif answer == "wonder" then
            say("\"The founders of The Fellowship felt that the people who inhabit this island would benefit the most from our organization.\"")
            if local2 then
                say("\"Especially since we would help them build an empire of sin and gluttony out of Buccaneer's Den.\"")
                say("You notice the Cube has been vibrating while Danag was speaking.")
            else
                say("\"Amidst all of the sin, the debauchery, the piracy, the gambling, the drunkenness -- The Fellowship has made its stand and recruited members to follow our principles. Buccaneer's Den has changed as a result.\"")
            end
            _RemoveAnswer("wonder")
            _AddAnswer("Buccaneer's Den")
        elseif answer == "Buccaneer's Den" then
            say("\"Long ago it was merely a hideout for pirates, scavengers, and rogues. Look around.\"")
            if local2 then
                say("\"Now it is the center of corruption in all of Britannia. The pirates are all controlled by The Fellowship.\"")
                say("The Cube continues to vibrate.")
            else
                say("\"Now Buccaneer's Den is an island paradise. It has its own commerce. It pays taxes to Lord British. The pirates here are now businessmen. They have made something of their lives.\"")
            end
            say("\"As a result, The Baths and The House of Games are two of the most profitable establishments in the country.\"")
            _RemoveAnswer("Buccaneer's Den")
            _AddAnswer({"House of Games", "The Baths"})
        elseif answer == "The Baths" then
            if local2 then
                say("\"It is, of course, a place where one may experience the pleasures of the flesh. All of the profits go to The Fellowship.\"")
            else
                say("\"It is a purely innocent business which caters to the weary who are in need of relaxation. One may receive physical and mental cleansing there.\"")
            end
            say("\"It is truly a jewel in the crown that is Britannia.\"")
            _RemoveAnswer("The Baths")
        elseif answer == "House of Games" then
            if local2 then
                say("\"Why, it is a gambling parlor! The Fellowship certainly takes in a bundle from that place!\"")
            else
                say("\"It is an outfit which challenges the mind and its ability for assessing strategy in life. Exercising this aspect of one's brain is important for one's self-esteem and well-being.\"")
            end
            _RemoveAnswer("House of Games")
        elseif answer == "Abraham" then
            say("\"Abraham is one of the members of the inner circle of The Fellowship. He and his colleague Elizabeth travel the country periodically, usually distributing or collecting the organization's funds and doing business at the other branches.\"")
            if local2 then
                say("The Cube vibrates.")
                say("\"Uhm... er... he is also a coordinator for executions and he cheats at cards.\"")
            end
            _RemoveAnswer("Abraham")
            _AddAnswer("Elizabeth")
        elseif answer == "Elizabeth" then
            say("\"Elizabeth is an extremely intelligent woman who acts as Director of Special Projects. She usually works with Batlin in Britain, but she spends most of her time travelling from branch to branch.\"")
            if local2 then
                say("As the Cube vibrates, Danag adds, \"She is, uhm... also a royal she-bitch and will murder thee at a moment's notice.\"")
            end
            _RemoveAnswer("Elizabeth")
            _AddAnswer("Special Projects")
        elseif answer == "Special Projects" then
            say("\"They might be anything from building a shelter for poor peasants to creating a new branch in a town without the benefit of a Fellowship Hall.\"")
            if local2 then
                say("As the Cube vibrates, Danag proudly adds, \"Our current Special Project is building the Black Gate for The Guardian. It is located at the Isle of the Avatar in our secret underground complex!\"")
                _AddAnswer({"complex", "Black Gate"})
            end
            _RemoveAnswer("Special Projects")
        elseif answer == "Black Gate" then
            say("Danag's eyes widen with excitement. \"It is the gateway for our coming Lord and Master! He will be coming through in virtually a few hours!\"")
            _RemoveAnswer("Black Gate")
        elseif answer == "complex" then
            say("\"It is inside a dungeon within the Shrine of the Codex. A barrier keeps out unwanted visitors. A special key opens the barrier, and only a few select people have one.\"")
            _RemoveAnswer("complex")
            _AddAnswer("key")
        elseif answer == "key" then
            say("\"I do not own one. The only people that do are Elizabeth and Abraham, Batlin, and Hook himself. Hook probably keeps his key in his abode.\"")
            _RemoveAnswer("key")
        elseif answer == "Hook" then
            if local2 then
                say("The Cube vibrates.")
                say("\"Man with a Hook? That's his name! 'Hook'! He lives here on the island! In fact, his quarters are in the secret catacombs behind the House of Games! Thou canst reach it by asking Sintag the guard about Hook. Of course, thou dost know that Hook is The Fellowship's chief executioner... along with his assistant, the gargoyle Forskis.\"")
                _AddAnswer({"Forskis", "executioner"})
                call_0911H(100)
            else
                say("\"A pirate with a hook for a hand? No... I do not believe I know him. There are many pirates on this island. Many of them are missing appendages, too!\"")
            end
            _RemoveAnswer("Hook")
        elseif answer == "Elizabeth and Abraham" then
            say("\"They usually travel together. They just arrived from our Meditation Retreat near Serpent's Hold and I believe they are somewhere on the island. Abraham told me I must keep working as interim branch leader until his return.\"")
            set_flag(0x02A8, true)
            if local2 then
                say("The Cube vibrates.")
            end
            say("\"Actually, I believe they are on their way to the Isle of the Avatar to take care of our new Special Project.\"")
            _RemoveAnswer("Elizabeth and Abraham")
        elseif answer == "executioner" then
            say("\"That's right. Hook does all the dirty work for The Fellowship. He was trained by Master De Snel in Jhelom. De Snel trained all the previous executioners as well. In fact, De Snel himself was The Fellowship's first executioner!\"")
            _RemoveAnswer("executioner")
        elseif answer == "Forskis" then
            say("\"I understand the gargoyle's name means 'henchman' in Gargish. He's a tough wingless gargoyle who helps Hook out. I believe he resides in the catacombs with Hook.\"")
            _RemoveAnswer("Forskis")
        elseif answer == "bye" then
            say("\"Farewell!\"*")
            return
        end
    end

    return
end

-- Helper functions
function say(...)
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