-- Function 04A7: Feridwyn's Fellowship dialogue and venom theft quest
function func_04A7(eventid, itemref)
    -- Local variables (8 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid == 0 then
        call_092EH(-167)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(167, 0)
    local0 = call_0909H()
    local1 = callis_0067()
    local2 = false
    local5 = call_0931H(1, -359, 981, 1, -357)
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0105) then
        _AddAnswer("Elizabeth and Abraham")
    end
    if local5 then
        _AddAnswer({"case solved", "found venom"})
        local2 = true
    end
    if not get_flag(0x0218) then
        _AddAnswer({"case solved", "Tobias", "take action", "Garritt caught", "found venom"})
    end

    if not get_flag(0x0220) then
        if not get_flag(0x0212) then
            say("\"Avatar! Didst thou know that the merchant Morfin had a quantity of silver serpent venom stolen? This theft has caused the community no small amount of distress.\"")
        else
            say("\"Avatar! Oh Avatar! I have news!\"")
        end
        say("\"Garritt, my son, told me that Tobias was in possession of some silver snake venom. I went to investigate and found Tobias with it!\"*")
        local4 = call_08F7H(-170)
        if local4 then
            switch_talk_to(170, 0)
            say("\"That is correct! I am a witness that what Feridwyn has said is the truth!\"*")
            _HideNPC(-170)
            switch_talk_to(167, 0)
        end
        say("\"I have often said that Tobias was no good. Now here is proof. He is the thief that has been praying upon one of our honest merchants! And to think I let him come into contact with my son! I hope he shall be dealt with in a manner appropriate to one who is leading youth astray from the way of The Fellowship.\"")
        say("\"I suggest that thou go and speak with his mother at once! Camille should keep a tighter rein on her offspring!\"*")
        set_flag(0x0213, true)
        set_flag(0x021C, true)
        calli_001D(3, callis_001B(-177))
        calli_001D(11, callis_001B(-167))
        return -- abrt
    else
        say("You see a small man with twisted, sloped posture. He looks you up and down before deciding he will speak to you.")
        say("\"I had gotten word that thou wert coming to our town. I have been expecting thee. I must admit, though, that I find it difficult to believe that thou art truly the Avatar.\"")
        set_flag(0x0220, true)
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"My name is Feridwyn.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I run the Fellowship shelter with my wife Brita and my son Garritt here in Paws.\"")
            _AddAnswer({"Paws", "Garritt", "Brita", "shelter", "Fellowship"})
        elseif answer == "Fellowship" then
            if local1 and not get_flag(0x0006) then
                say("\"Wouldst thou like to join?\"")
                local6 = call_090AH()
                if local6 then
                    say("\"Then thou must see Batlin of Britain. He is the founder of The Fellowship.\"")
                else
                    say("\"Thou dost not yet comprehend how much thy life could be improved through the guidance of The Fellowship.\"")
                end
            else
                say("\"Gentle Avatar, it is good of thee to come to our humble town. Thou canst well see that The Fellowship has much work to do if it is to alleviate the suffering of the unfortunate of Britannia.\"")
            end
            _RemoveAnswer("Fellowship")
        elseif answer == "shelter" then
            say("\"This is the only place in all of Britannia designed for the aid and care of the poor. It is hard work, but then one strives to be worthy of that which we wish to receive.\"")
            _RemoveAnswer("shelter")
        elseif answer == "Brita" then
            if not get_flag(0x0221) then
                say("\"A wonderful woman. Thou shouldst meet her.\"")
                local7 = call_08F7H(-168)
                if local7 then
                    switch_talk_to(168, 0)
                    say("\"Mine husband is such a flatterer. The truth is that our work for The Fellowship has brought us closer together.\"*")
                    _HideNPC(-168)
                    switch_talk_to(167, 0)
                end
            else
                say("\"As thou dost already know my wife Brita, I am certain thou wilt agree that thou couldst not find a more dedicated practitioner of The Fellowship's teachings.\"")
            end
            _RemoveAnswer("Brita")
        elseif answer == "Garritt" then
            say("\"Thankfully, we have been able to raise our son properly by emphasizing the teachings of The Fellowship. Garritt shall not be trapped in the poverty of his surroundings. He shall be intellectually, spiritually, and morally superior. He's talented, too!\"")
            _RemoveAnswer("Garritt")
            _AddAnswer("talented")
        elseif answer == "talented" then
            say("\"He plays the whistle panpipes extremely well for a lad his age! Brita and I are very proud. He could probably attend The Music Hall in Britain when he is older!\"")
            _RemoveAnswer("talented")
        elseif answer == "Paws" then
            say("\"As this is a small town with few privileges and little privacy, our family has come to know everyone in Paws quite well. Is there someone thou dost wish to hear about? I am well acquainted with these people.\"")
            _RemoveAnswer("Paws")
            _AddAnswer({"beggars", "shelter residents", "farmers", "merchants"})
        elseif answer == "merchants" then
            say("\"They would be Morfin, Andrew, Thurston, and Beverlea.\"")
            _AddAnswer({"Beverlea", "Thurston", "Andrew", "Morfin"})
            _RemoveAnswer("merchants")
        elseif answer == "Beverlea" then
            say("\"She is a nearly blind elderly woman who runs the antique shoppe on the east side of the river.\"")
            _RemoveAnswer("Beverlea")
        elseif answer == "farmers" then
            say("\"That would be Camille and her son Tobias.\"")
            _AddAnswer({"Tobias", "Camille"})
            _RemoveAnswer("farmers")
        elseif answer == "beggars" then
            say("\"Oh. Them. Komor and Fenn.\" Feridwyn rolls his eyes.")
            _AddAnswer({"Fenn", "Komor"})
            _RemoveAnswer("beggars")
        elseif answer == "shelter residents" then
            say("\"Our residents include Alina and her child, and Merrick.\"")
            _AddAnswer({"Merrick", "Alina"})
            _RemoveAnswer("shelter residents")
        elseif answer == "Alina" then
            say("\"Her husband is currently in Britain somewhere. I do not know the details. She has a small child.\"")
            _RemoveAnswer("Alina")
        elseif answer == "Elizabeth and Abraham" then
            if not get_flag(0x016B) then
                say("\"I am so sorry! Thou hast just missed them! Elizabeth and Abraham were here delivering funds, but they have gone now to Jhelom. There is currently no Fellowship branch there, so they are taking the Triad of Inner Strength to lands west!\"")
                set_flag(0x0217, true)
            else
                say("\"I have not seen Elizabeth and Abraham for many days now.\"")
            end
            _RemoveAnswer("Elizabeth and Abraham")
        elseif answer == "Thurston" then
            say("\"Thurston owns the mill. He could do better if he ran his business with more of an eye toward profit.\"")
            _RemoveAnswer("Thurston")
        elseif answer == "Camille" then
            say("\"She's a sad woman -- a widow -- who is living in the past. 'Tis a pity, really. Fortunately her husband left her the farm which does happen to turn a profit.\"")
            _RemoveAnswer("Camille")
        elseif answer == "Merrick" then
            say("\"A splendid example of The Fellowship turning someone's life around. Presently he resides in our shelter.\"")
            _RemoveAnswer("Merrick")
        elseif answer == "Morfin" then
            say("\"Morfin is a clever and industrious member of The Fellowship. He runs the local slaughterhouse and is also a snake venom merchant.\"")
            _AddAnswer("snake venom")
            _RemoveAnswer("Morfin")
        elseif answer == "Andrew" then
            say("\"Andrew is such a happy young man. He doth not notice the myriad of personal problems that he is afflicted with.\"")
            _RemoveAnswer("Andrew")
        elseif answer == "Tobias" then
            if not get_flag(0x0218) then
                say("\"A local rascal. I normally would not allow Garritt to associate with such a troublemaker, but The Fellowship has taught me to be a tolerant parent. Besides, associating with my son might do the lad some good. Who knows?\"")
            else
                say("\"No matter that Tobias did not personally steal the venom himself. He caused the theft by means of his corrupting influence on my son. While his actions are just short of criminal, I still blame Tobias.\"")
            end
            _RemoveAnswer("Tobias")
        elseif answer == "Fenn" then
            say("\"Fenn is a beggar who refuses all aid from The Fellowship. A pathetic case. Not even his former friend Merrick can reach him any more.\"")
            _RemoveAnswer("Fenn")
        elseif answer == "Komor" then
            say("\"Komor is the most hateful man I have ever met. He is a bundle of bitterness. In all the time I have known him, Komor has never spoken a word to me that was not at best a thinly veiled insult.\"")
            _RemoveAnswer("Komor")
        elseif answer == "case solved" then
            if get_flag(0x0218) or local2 then
                say("\"Thankfully we can now put this business of snake venom thefts behind us, thanks to thy thorough efforts. I shall deal with my son. Let us speak of this no more.\"")
            else
                say("\"Thank goodness Garritt, my sharp eyed boy, got to the bottom of this business of the snake venom thefts. Frankly, I had my suspicions about Tobias myself.\"")
            end
            _RemoveAnswer("case solved")
        elseif answer == "snake venom" then
            say("\"Morfin, the local merchant, informs me that a quantity of silver serpent venom was stolen from him. The thief is still at large, so be wary! Of course, I do not know why anyone would want the vile substance. It is surely not good for one's health.\"")
            set_flag(0x0212, true)
            _RemoveAnswer("snake venom")
        elseif answer == "take action" then
            say("\"I promise thee, I shall apply the necessary discipline to my son to insure that this bad habit he has picked up from the local riffraff will not trouble this community again.\"")
            _RemoveAnswer("take action")
        elseif answer == "found venom" then
            if not get_flag(0x0218) then
                say("\"Thou didst find the venom vial in Garritt's belongings? I am amazed! I am astonished! I am-- sorry.\"")
            else
                say("\"Thou art a resourceful person. Unfortunately, thy discovery has upset me a great deal.\"")
            end
            _RemoveAnswer("found venom")
        elseif answer == "Garritt caught" then
            say("\"Thou dost say my son has admitted to stealing the venom?! I do not know what to say. My thanks, Avatar, for uncovering the truth.\"")
            _RemoveAnswer("Garritt caught")
        elseif answer == "bye" then
            say("\"Mayest thou walk with the Fellowship.\"*")
            if local5 then
                say("You realize that the Cube did not bring out anything that Feridwyn did not actually believe himself. He is one of the innocent followers of The Guardian.")
            end
            break
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