--- Best guess: Manages Feridwyn’s dialogue in Paws, discussing a snake venom theft, The Fellowship shelter, and townspeople, with a focus on Tobias and Garritt’s involvement.
function func_04A7(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid == 1 then
        switch_talk_to(0, 167)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_0067H()
        var_0002 = false
        var_0003 = unknown_0931H(1, 357, 649, 359, 1)
        if not get_flag(566) and not get_flag(531) then
            if not get_flag(530) then
                add_dialogue("\"Avatar! Didst thou know that the merchant Morfin had a quantity of silver serpent venom stolen? This theft has caused the community no small amount of distress.\"")
            else
                add_dialogue("\"Avatar! Oh Avatar! I have news!\"")
            end
            add_dialogue("\"Garritt, my son, told me that Tobias was in possession of some silver snake venom. I went to investigate and found Tobias with it!\"")
            var_0004 = unknown_08F7H(170)
            if var_0004 then
                switch_talk_to(0, 170)
                add_dialogue("\"That is correct! I am a witness that what Feridwyn has said is the truth!\"")
                hide_npc(170)
                switch_talk_to(0, 167)
            end
            add_dialogue("\"I have often said that Tobias was no good. Now here is proof. He is the thief that has been praying upon one of our honest merchants! And to think I let him come into contact with my son! I hope he shall be dealt with in a manner appropriate to one who is leading youth astray from the way of The Fellowship.\"")
            add_dialogue("\"I suggest that thou go and speak with his mother at once! Camille should keep a tighter rein on her offspring!\"")
            set_flag(531, true)
            set_flag(540, true)
            unknown_001DH(unknown_001BH(177), 3)
            unknown_001DH(unknown_001BH(167), 11)
            return
        end
        start_conversation()
        add_answer({"bye", "job", "name"})
        if get_flag(261) then
            add_answer("Elizabeth and Abraham")
        end
        if var_0003 then
            var_0002 = true
            add_answer({"case solved", "found venom"})
        end
        if get_flag(536) then
            add_answer({"case solved", "Tobias", "take action", "Garritt caught", "found venom"})
        end
        if not get_flag(544) then
            add_dialogue("You see a small man with twisted, sloped posture. He looks you up and down before deciding he will speak to you.")
            add_dialogue("\"I had gotten word that thou wert coming to our town. I have been expecting thee. I must admit, though, that I find it difficult to believe that thou art truly the Avatar.\"")
            set_flag(544, true)
        else
            add_dialogue("\"Thou dost wish to speak with me again, Avatar?\" says Feridwyn.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"My name is Feridwyn.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I run the Fellowship shelter with my wife Brita and my son Garritt here in Paws.\"")
                add_answer({"Paws", "Garritt", "Brita", "shelter", "Fellowship"})
            elseif answer == "Fellowship" then
                if not var_0001 then
                    add_dialogue("\"Wouldst thou like to join?\"")
                    var_0005 = unknown_090AH()
                    if var_0005 then
                        add_dialogue("\"Then thou must see Batlin of Britain. He is the founder of The Fellowship.\"")
                    else
                        add_dialogue("\"Thou dost not yet comprehend how much thy life could be improved through the guidance of The Fellowship.\"")
                    end
                else
                    add_dialogue("\"Gentle Avatar, it is good of thee to come to our humble town. Thou canst well see that The Fellowship has much work to do if it is to alleviate the suffering of the unfortunate of Britannia.\"")
                end
                remove_answer("Fellowship")
            elseif answer == "shelter" then
                add_dialogue("\"This is the only place in all of Britannia designed for the aid and care of the poor. It is hard work, but then one strives to be worthy of that which we wish to receive.\"")
                remove_answer("shelter")
            elseif answer == "Brita" then
                if not get_flag(545) then
                    add_dialogue("\"A wonderful woman. Thou shouldst meet her.\"")
                    var_0006 = unknown_08F7H(168)
                    if var_0006 then
                        switch_talk_to(0, 168)
                        add_dialogue("\"Mine husband is such a flatterer. The truth is that our work for The Fellowship has brought us closer together.\"")
                        hide_npc(168)
                        switch_talk_to(0, 167)
                    end
                else
                    add_dialogue("\"As thou dost already know my wife Brita, I am certain thou wilt agree that thou couldst not find a more dedicated practitioner of The Fellowship's teachings.\"")
                end
                remove_answer("Brita")
            elseif answer == "Garritt" then
                add_dialogue("\"Thankfully, we have been able to raise our son properly by emphasizing the teachings of The Fellowship. Garritt shall not be trapped in the poverty of his surroundings. He shall be intellectually, spiritually, and morally superior. He's talented, too!\"")
                remove_answer("Garritt")
                add_answer("talented")
            elseif answer == "talented" then
                add_dialogue("\"He plays the whistle panpipes extremely well for a lad his age! Brita and I are very proud. He could probably attend The Music Hall in Britain when he is older!\"")
                remove_answer("talented")
            elseif answer == "Paws" then
                add_dialogue("\"As this is a small town with few privileges and little privacy, our family has come to know everyone in Paws quite well. Is there someone thou dost wish to hear about? I am well acquainted with these people.\"")
                remove_answer("Paws")
                add_answer({"beggars", "shelter residents", "farmers", "merchants"})
            elseif answer == "merchants" then
                add_dialogue("\"They would be Morfin, Andrew, Thurston, and Beverlea.\"")
                add_answer({"Beverlea", "Thurston", "Andrew", "Morfin"})
                remove_answer("merchants")
            elseif answer == "Beverlea" then
                add_dialogue("\"She is a nearly blind elderly woman who runs the antique shoppe on the east side of the river.\"")
                remove_answer("Beverlea")
            elseif answer == "farmers" then
                add_dialogue("\"That would be Camille and her son Tobias.\"")
                add_answer({"Tobias", "Camille"})
                remove_answer("farmers")
            elseif answer == "beggars" then
                add_dialogue("\"Oh. Them. Komor and Fenn.\" Feridwyn rolls his eyes.")
                add_answer({"Fenn", "Komor"})
                remove_answer("beggars")
            elseif answer == "shelter residents" then
                add_dialogue("\"Our residents include Alina and her child, and Merrick.\"")
                add_answer({"Merrick", "Alina"})
                remove_answer("shelter residents")
            elseif answer == "Alina" then
                add_dialogue("\"Her husband is currently in Britain somewhere. I do not know the details. She has a small child.\"")
                remove_answer("Alina")
            elseif answer == "Elizabeth and Abraham" then
                if not get_flag(363) then
                    add_dialogue("\"I am so sorry! Thou hast just missed them! Elizabeth and Abraham were here delivering funds, but they have gone now to Jhelom. There is currently no Fellowship branch there, so they are taking the Triad of Inner Strength to lands west!\"")
                    set_flag(535, true)
                else
                    add_dialogue("\"I have not seen Elizabeth and Abraham for many days now.\"")
                end
                remove_answer("Elizabeth and Abraham")
            elseif answer == "Thurston" then
                add_dialogue("\"Thurston owns the mill. He could do better if he ran his business with more of an eye toward profit.\"")
                remove_answer("Thurston")
            elseif answer == "Camille" then
                add_dialogue("\"She's a sad woman -- a widow -- who is living in the past. 'Tis a pity, really. Fortunately her husband left her the farm which does happen to turn a profit.\"")
                remove_answer("Camille")
            elseif answer == "Merrick" then
                add_dialogue("\"A splendid example of The Fellowship turning someone's life around. Presently he resides in our shelter.\"")
                remove_answer("Merrick")
            elseif answer == "Morfin" then
                add_dialogue("\"Morfin is a clever and industrious member of The Fellowship. He runs the local slaughterhouse and is also a snake venom merchant.\"")
                add_answer("snake venom")
                remove_answer("Morfin")
            elseif answer == "Andrew" then
                add_dialogue("\"Andrew is such a happy young man. He doth not notice the myriad of personal problems that he is afflicted with.\"")
                remove_answer("Andrew")
            elseif answer == "Tobias" then
                if not get_flag(536) then
                    add_dialogue("\"A local rascal. I normally would not allow Garritt to associate with such a troublemaker, but The Fellowship has taught me to be a tolerant parent. Besides, associating with my son might do the lad some good. Who knows?\"")
                else
                    add_dialogue("\"No matter that Tobias did not personally steal the venom himself. He caused the theft by means of his corrupting influence on my son. While his actions are just short of criminal, I still blame Tobias.\"")
                end
                remove_answer("Tobias")
            elseif answer == "Fenn" then
                add_dialogue("\"Fenn is a beggar who refuses all aid from The Fellowship. A pathetic case. Not even his former friend Merrick can reach him any more.\"")
                remove_answer("Fenn")
            elseif answer == "Komor" then
                add_dialogue("\"Komor is the most hateful man I have ever met. He is a bundle of bitterness. In all the time I have known him, Komor has never spoken a word to me that was not at best a thinly veiled insult.\"")
                remove_answer("Komor")
            elseif answer == "case solved" then
                if get_flag(536) or var_0002 then
                    add_dialogue("\"Thankfully we can now put this business of snake venom thefts behind us, thanks to thy thorough efforts. I shall deal with my son. Let us speak of this no more.\"")
                else
                    add_dialogue("\"Thank goodness Garritt, my sharp eyed boy, got to the bottom of this business of the snake venom thefts. Frankly, I had my suspicions about Tobias myself.\"")
                end
                remove_answer("case solved")
            elseif answer == "snake venom" then
                add_dialogue("\"Morfin, the local merchant, informs me that a quantity of silver serpent venom was stolen from him. The thief is still at large, so be wary! Of course, I do not know why anyone would want the vile substance. It is surely not good for one's health.\"")
                set_flag(530, true)
                remove_answer("snake venom")
            elseif answer == "take action" then
                add_dialogue("\"I promise thee, I shall apply the necessary discipline to my son to ensure that this bad habit he has picked up from the local riffraff will not trouble this community again.\"")
                remove_answer("take action")
            elseif answer == "found venom" then
                if not get_flag(536) then
                    add_dialogue("\"Thou didst find the venom vial in Garritt's belongings? I am amazed! I am astonished! I am-- sorry.\"")
                else
                    add_dialogue("\"Thou art a resourceful person. Unfortunately, thy discovery has upset me a great deal.\"")
                end
                remove_answer("found venom")
            elseif answer == "Garritt caught" then
                add_dialogue("\"Thou dost say my son has admitted to stealing the venom?! I do not know what to say. My thanks, Avatar, for uncovering the truth.\"")
                remove_answer("Garritt caught")
            elseif answer == "bye" then
                add_dialogue("\"Mayest thou walk with the Fellowship.\"")
                if var_0003 then
                    add_dialogue("You realize that the Cube did not bring out anything that Feridwyn did not actually believe himself. He is one of the innocent followers of The Guardian.")
                end
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(167)
    end
    return
end