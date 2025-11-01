--- Best guess: Manages Lasher's dialogue, a unicorn in a dungeon who detects virgins, sharing his cursed history and reluctance to aid virginity tests, especially for Cosmo's quest.
function npc_lasher_0254(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 0 then
        return
    end
    switch_talk_to(0, 254)
    var_0000 = get_lord_or_lady()
    start_conversation()
    if not get_flag(717) then
        add_dialogue("You see a creature the size and shape of a horse. From its head protrudes a single straight horn. It looks at you with eyes that shine with intelligence.")
        set_flag(717, true)
    else
        add_dialogue("\"I greet thee once again, Avatar,\" says Lasher, the unicorn.")
    end
    add_answer({"bye", "job", "name"})
    while true do
        local answer = get_answer()
        if answer == "name" then
            add_dialogue("The creature speaks. \"My name is Lasher.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("Lasher looks at you and blinks. \"Come now, Avatar! I do not live by the rules that govern the society of Mankind. There is what I am, which is a unicorn. Then there is my purpose, which is another thing altogether.\"")
            add_answer({"purpose", "unicorn"})
        elseif answer == "unicorn" then
            add_dialogue("Lasher stares at you, stupefied. \"Tell me, dost thou know what a unicorn is?\"")
            var_0001 = ask_yes_no()
            if not var_0001 then
                add_dialogue("Lasher stares blankly at you. His mouth hangs open. \"Very well. Then I shall tell thee what a unicorn is.\"")
            else
                add_dialogue("Lasher shakes his head sadly. \"No, thou merely thinks thou dost know what a unicorn is, but I shall tell thee the truth.\"")
            end
            add_dialogue("\"A unicorn is one of a family of nature spirits that were once called upon to aid a very powerful wizard many, many years ago.\"")
            remove_answer("unicorn")
            add_answer("wizard")
        elseif answer == "purpose" then
            add_dialogue("\"Oh, do not be coy with me, Avatar. Thou dost know very well the purpose of a unicorn.\"")
            add_dialogue("We are foolproof virgin detectors!")
            remove_answer("purpose")
            add_answer("virgin detector")
        elseif answer == "wizard" then
            add_dialogue("\"I do not remember the wizard's name, for much time has passed since then, but suffice it to say that he was a royal bastard. Anyway, for one reason or another, the chieftain of our clan, who at that time was a horse's ass named Sharp-Hoof, decided that rather than heed this wizard's rightful and properly performed ritual of calling, he was going to take the herd and chase after this bevy of really fine fillies.\"")
            remove_answer("wizard")
            add_answer("Sharp-Hoof")
        elseif answer == "Sharp-Hoof" then
            add_dialogue("\"Where was I? Oh, yes, Sharp-Hoof! The next morning, after we had had our way with these fillies, this wizard called us again. This time Sharp-Hoof realized that we had best answer, and were we sorry that we did! The wizard was horribly angry! And, well, I will just say that our agreements with such people are very, very binding.\"")
            remove_answer("Sharp-Hoof")
            add_answer("binding")
        elseif answer == "binding" then
            add_dialogue("\"Not only were we bound in service to this wizard for a thousand years, but he also placed a dreadful curse upon us.\"")
            remove_answer("binding")
            add_answer({"curse", "service"})
        elseif answer == "service" then
            add_dialogue("\"As it fell out, we did not actually have to serve the wizard for a thousand years. He reduced the time by a few weeks after placing that curse on us.\" Lasher snorts sarcastically, \"I was heartbroken.\"")
            remove_answer("service")
        elseif answer == "curse" then
            add_dialogue("\"We nature spirits used to be renowned for our randiness, and this wizard had called upon us to assist him in the seduction of some maiden. When we stood him up... Well, let us just say that he was one magician who was having a problem convincing his magic wand to work. Anyway, in a pathetic attempt to bolster his diminished feelings of manhood, he ruined us with an awesomely powerful Curse of Chastity.\"")
            remove_answer("curse")
            add_answer("Chastity")
        elseif answer == "Chastity" then
            add_dialogue("\"It was a terrible curse. First, it drove us to kill all of the female members of our clan. Then it afflicted us with the particular sensitivity for which we have become known.\"")
            remove_answer("Chastity")
        elseif answer == "virgin detector" then
            add_dialogue("\"That is correct. So sensitive are members of my race to all forms of sexual energy that we can only tolerate physical contact with one who has not yet had any experience in that form of procreation - or recreation, if thou dost prefer.\"")
            remove_answer("virgin detector")
            add_answer("sensitive")
        elseif answer == "sensitive" then
            add_dialogue("\"Yes, I find it most unpleasant to actually come into physical contact with anyone who is not a virgin, and I will avoid doing so whenever possible.\"")
            remove_answer("sensitive")
            add_answer({"unpleasant", "avoid"})
        elseif answer == "avoid" then
            add_dialogue("\"Yes, well, I did not wish to get this personal with thee, but if thou does not mind, art thou a virgin?\"")
            var_0002 = ask_yes_no()
            if not var_0002 then
                if not get_flag(669) or not get_flag(668) or not get_flag(670) then
                    add_dialogue("\"I thought as much!\" Lasher starts to pace nervously. \"If thou wouldst not mind standing back a bit, I would be most appreciative.\"")
                else
                    add_dialogue("Lasher slowly shakes his head. \"Thou dost not have to brag in order to impress me, or fear any sort of verbal chastisements, honestly. By the way, I have an itch right betwixt my shoulder blades. Wouldst thou mind scratching it for me?\" Lasher stretches out toward you. \"Thank thee so much.\"")
                    var_0003 = is_pc_female()
                    var_0004 = npc_id_in_party(1)
                    var_0005 = npc_id_in_party(3)
                    var_0006 = npc_id_in_party(4)
                    if not var_0003 then
                        if var_0004 then
                            switch_talk_to(0, 1)
                            add_dialogue("\"There's no shame in it, milord,\" says Iolo, looking very serious.")
                            hide_npc(1)
                            switch_talk_to(0, 254)
                        end
                        if var_0005 then
                            switch_talk_to(0, 3)
                            add_dialogue("\"No, it is perfectly understandable. Thou hast been so busy lately,\" says Shamino. You sense he is struggling to maintain a straight face.")
                            hide_npc(3)
                            switch_talk_to(0, 254)
                        end
                        if var_0006 then
                            switch_talk_to(0, 4)
                            add_dialogue("\"Why dost thou not go and pet the nice horsey. We would do it, but I think he prefers thee.\" With that, you hear an explosion of snorts and giggles.")
                            hide_npc(4)
                            switch_talk_to(0, 254)
                        end
                        add_answer("virginity")
                    end
                end
            else
                if not get_flag(669) or not get_flag(668) or not get_flag(670) then
                    add_dialogue("\"I beg thy pardon, but perhaps thou shouldst go to the Lycaeum and have someone look up the definition of the word 'virginity' for thee. Wouldst thou mind stepping back, please?! Thou dost make me nervous.\"")
                else
                    add_dialogue("\"Yes, I could tell the answer to my question before thou didst even speak it. Art thou a virgin by choice or by circumstance?\"")
                    add_answer({"circumstance", "choice"})
                end
            end
            remove_answer("avoid")
        elseif answer == "virginity" then
            add_dialogue("\"Surely, Avatar, thou knowest that thou dost magically regain thy virginity each time upon returning to Britannia! Hast thou remained a virgin since then by choice or by circumstance?\"")
            remove_answer("virginity")
            add_answer({"circumstance", "choice"})
        elseif answer == "choice" then
            add_dialogue("\"Well, I am sure thou wilt find the right person one day.\"")
            remove_answer({"circumstance", "choice"})
        elseif answer == "circumstance" then
            add_dialogue("\"That is too bad, I am very sorry. I would love to be able to help thee, but that is no longer my purpose.\"")
            remove_answer({"choice", "circumstance"})
            add_answer("help")
        elseif answer == "help" then
            add_dialogue("\"Oh, I do not know. It has been so long since I was personally involved in such matters. Art thou seeking love or art thou seeking lust?\"")
            add_answer({"lust", "love"})
            remove_answer("help")
        elseif answer == "love" then
            add_dialogue("\"Hmmm, love is usually a very elusive quarry. I suppose that thou canst try thy luck in the city of Cove. It is a city of lovers, or so I have heard.\"")
            remove_answer({"lust", "love"})
        elseif answer == "lust" then
            add_dialogue("\"If quenching thy lust is thine only concern, then thou shouldst find satisfaction at the Baths, in Buccaneer's Den. But be sure to take a full purse.\"")
            remove_answer({"lust", "love"})
        elseif answer == "unpleasant" then
            add_dialogue("\"Actually, the part of being a virgin detector that I find the most intolerable is having to perform upon demand for some clever mage or bard or hero who wants a potential wife to try to touch me.\"")
            remove_answer("unpleasant")
            add_answer("wife")
        elseif answer == "wife" then
            add_dialogue("\"It is a tragedy. The man always gets nervous, then places a condition on the marriage that his bride must be a virgin. They call me to put her to the test, and the man's bachelorhood is granted a reprieve. I have destroyed more engagements than the Bubonic Plague.\"")
            remove_answer("wife")
            if not get_flag(721) then
                add_answer("bachelorhood")
            end
        elseif answer == "bachelorhood" then
            add_dialogue("\"Just like those fools who are wandering around down here looking for me for the same reason, I would wager. Well, they can lose that notion. I like women, I truly do, and frankly, I am sick and tired of being used as the instrument of their humiliation.\"")
            remove_answer("marriages")
            if get_flag(736) then
                add_answer("male virginity test")
            else
                add_answer("fools")
            end
            remove_answer("bachelorhood")
        elseif answer == "fools" then
            add_dialogue("\"I am a magical creature. I can avoid them down here as long as I want. They will die of old age before they catch me. I refuse to assist them in weaseling out of some breach of promise. Thou canst tell them that if thou dost see them.\"")
            set_flag(720, true)
            remove_answer("fools")
        elseif answer == "male virginity test" then
            add_dialogue("\"They want the virginity test for a man who is getting married?!\" Lasher lets out a long surprised laugh. \"In all mine existence, I have never heard of such a thing!\"")
            remove_answer("male virginity test")
            add_answer("getting married")
        elseif answer == "getting married" then
            add_dialogue("\"Oh, she must be quite a ravishing maiden if he is willing to risk life and limb to come down here and prove his virtue.\"")
            remove_answer("getting married")
            add_answer("ravishing maiden")
        elseif answer == "ravishing maiden" then
            add_dialogue("\"This boy must be smitten something fierce by this maid. I suppose that I should go and investigate this further. If he is as sincere about this as thou dost say, then perhaps I will help the poor lad.\"")
            remove_answer("ravishing maiden")
            set_flag(721, true)
        elseif answer == "bye" then
            add_dialogue("\"Fare thee well, Avatar.\"")
            break
        end
    end
    return
end