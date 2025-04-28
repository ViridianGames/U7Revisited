require "U7LuaFuncs"
-- Function 04FE: Lasher's dialogue and virgin detection role
function func_04FE(eventid, itemref)
    -- Local variables (7 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -254)
    local0 = call_0909H()

    if not get_flag(0x02CD) then
        say("You see a creature the size and shape of a horse. From its head protrudes a single straight horn. It looks at you with eyes that shine with intelligence.")
        set_flag(0x02CD, true)
    else
        say("\"I greet thee once again, Avatar,\" says Lasher, the unicorn.")
    end

    _AddAnswer({"bye", "job", "name"})

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("The creature speaks. \"My name is Lasher.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("Lasher looks at you and blinks. \"Come now, Avatar! I do not live by the rules that govern the society of Mankind. There is what I am, which is a unicorn. Then there is my purpose, which is another thing altogether.\"")
            _AddAnswer({"purpose", "unicorn"})
        elseif answer == "unicorn" then
            say("Lasher stares at you, stupefied. \"Tell me, dost thou know what a unicorn is?\"")
            local1 = call_090AH()
            if not local1 then
                say("Lasher stares blankly at you. His mouth hangs open. \"Very well. Then I shall tell thee what a unicorn is.\"")
            else
                say("Lasher shakes his head sadly. \"No, thou merely thinks thou dost know what a unicorn is, but I shall tell thee the truth.\"")
            end
            say("\"A unicorn is one of a family of nature spirits that were once called upon to aid a very powerful wizard many, many years ago.\"")
            _RemoveAnswer("unicorn")
            _AddAnswer("wizard")
        elseif answer == "purpose" then
            say("\"Oh, do not be coy with me, Avatar. Thou dost know very well the purpose of a unicorn. ~~We are foolproof virgin detectors!\"")
            _RemoveAnswer("purpose")
            _AddAnswer("virgin detector")
        elseif answer == "wizard" then
            say("\"I do not remember the wizard's name, for much time has passed since then, but suffice it to say that he was a royal bastard. Anyway, for one reason or another, the chieftain of our clan, who at that time was a horse's ass named Sharp-Hoof, decided that rather than heed this wizard's rightful and properly performed ritual of calling, he was going to take the herd and chase after this bevy of really fine fillies.\"")
            _RemoveAnswer("wizard")
            _AddAnswer("Sharp-Hoof")
        elseif answer == "Sharp-Hoof" then
            say("\"Where was I? Oh, yes, Sharp-Hoof! The next morning, after we had had our way with these fillies, this wizard called us again. This time Sharp-Hoof realized that we had best answer, and were we sorry that we did! The wizard was horribly angry! And, well, I will just say that our agreements with such people are very, very binding.\"")
            _RemoveAnswer("Sharp-Hoof")
            _AddAnswer("binding")
        elseif answer == "binding" then
            say("\"Not only were we bound in service to this wizard for a thousand years, but he also placed a dreadful curse upon us.\"")
            _RemoveAnswer("binding")
            _AddAnswer({"curse", "service"})
        elseif answer == "service" then
            say("\"As it fell out, we did not actually have to serve the wizard for a thousand years. He reduced the time by a few weeks after placing that curse on us.\" Lasher snorts sarcastically, \"I was heartbroken.\"")
            _RemoveAnswer("service")
        elseif answer == "curse" then
            say("\"We nature spirits used to be renowned for our randiness, and this wizard had called upon us to assist him in the seduction of some maiden. When we stood him up... Well, let us just say that he was one magician who was having a problem convincing his magic wand to work. Anyway, in a pathetic attempt to bolster his diminished feelings of manhood, he ruined us with an awesomely powerful Curse of Chastity.\"")
            _RemoveAnswer("curse")
            _AddAnswer("Chastity")
        elseif answer == "Chastity" then
            say("\"It was a terrible curse. First, it drove us to kill all of the female members of our clan. Then it afflicted us with the particular sensitivity for which we have become known.\"")
            _RemoveAnswer("Chastity")
        elseif answer == "virgin detector" then
            say("\"That is correct. So sensitive are members of my race to all forms of sexual energy that we can only tolerate physical contact with one who has not yet had any experience in that form of procreation - or recreation, if thou dost prefer.\"")
            _RemoveAnswer("virgin detector")
            _AddAnswer("sensitive")
        elseif answer == "sensitive" then
            say("\"Yes, I find it most unpleasant to actually come into physical contact with anyone who is not a virgin, and I will avoid doing so whenever possible.\"")
            _RemoveAnswer("sensitive")
            _AddAnswer({"unpleasant", "avoid"})
        elseif answer == "unpleasant" then
            say("\"Actually, the part of being a virgin detector that I find the most intolerable is having to perform upon demand for some clever mage or bard or hero who wants a potential wife to try to touch me.\"")
            _RemoveAnswer("unpleasant")
            _AddAnswer("wife")
        elseif answer == "wife" then
            say("\"It is a tragedy. The man always gets nervous, then places a condition on the marriage that his bride must be a virgin. They call me to put her to the test, and the man's bachelorhood is granted a reprieve. I have destroyed more engagements than the Bubonic Plague.\"")
            _RemoveAnswer("wife")
            if not get_flag(0x02D1) then
                _AddAnswer("bachelorhood")
            end
        elseif answer == "bachelorhood" then
            say("\"Just like those fools who are wandering around down here looking for me for the same reason, I would wager. Well, they can lose that notion. I like women, I truly do, and frankly, I am sick and tired of being used as the instrument of their humiliation.\"")
            _RemoveAnswer("marriages")
            if get_flag(0x02E0) then
                _AddAnswer("male virginity test")
            else
                _AddAnswer("fools")
            end
            _RemoveAnswer("bachelorhood")
        elseif answer == "fools" then
            say("\"I am a magical creature. I can avoid them down here as long as I want. They will die of old age before they catch me. I refuse to assist them in weaseling out of some breach of promise. Thou canst tell them that if thou dost see them.\"")
            set_flag(0x02D0, true)
            _RemoveAnswer("fools")
        elseif answer == "male virginity test" then
            say("\"They want the virginity test for a man who is getting married?!\" Lasher lets out a long surprised laugh. \"In all mine existence, I have never heard of such a thing!\"")
            _RemoveAnswer("male virginity test")
            _AddAnswer("getting married")
        elseif answer == "getting married" then
            say("\"Oh, she must be quite a ravishing maiden if he is willing to risk life and limb to come down here and prove his virtue.\"")
            _RemoveAnswer("getting married")
            _AddAnswer("ravishing maiden")
        elseif answer == "ravishing maiden" then
            say("\"This boy must be smitten something fierce by this maid. I suppose that I should go and investigate this further. If he is as sincere about this as thou dost say, then perhaps I will help the poor lad.\"")
            _RemoveAnswer("ravishing maiden")
            set_flag(0x02D1, true)
        elseif answer == "avoid" then
            say("\"Yes, well, I did not wish to get this personal with thee, but if thou does not mind, art thou a virgin?\"")
            local2 = call_090AH()
            if not local2 then
                if not get_flag(0x029D) and not get_flag(0x029C) and not get_flag(0x029E) then
                    say("\"I thought as much!\" Lasher starts to pace nervously. \"If thou wouldst not mind standing back a bit, I would be most appreciative.\"")
                else
                    say("Lasher slowly shakes his head. \"Thou dost not have to brag in order to impress me, or fear any sort of verbal chastisements, honestly. By the way, I have an itch right betwixt my shoulder blades. Wouldst thou mind scratching it for me?\" Lasher stretches out toward you. \"Thank thee so much.\"")
                    local3 = _IsPlayerFemale()
                    local4 = call_08F7H(-1)
                    local5 = call_08F7H(-3)
                    local6 = call_08F7H(-4)
                    if not local3 then
                        if local4 then
                            _SwitchTalkTo(0, -1)
                            say("\"There's no shame in it, milord,\" says Iolo, looking very serious.*")
                            _HideNPC(-1)
                            _SwitchTalkTo(0, -254)
                        end
                        if local5 then
                            _SwitchTalkTo(0, -3)
                            say("\"No, it is perfectly understandable. Thou hast been so busy lately,\" says Shamino. You sense he is struggling to maintain a straight face.*")
                            _HideNPC(-3)
                            _SwitchTalkTo(0, -254)
                        end
                        if local6 then
                            _SwitchTalkTo(0, -4)
                            say("\"Why dost thou not go and pet the nice horsey. We would do it, but I think he prefers thee.\" With that, you hear an explosion of snorts and giggles.*")
                            _HideNPC(-4)
                            _SwitchTalkTo(0, -254)
                        end
                        _AddAnswer("virginity")
                    end
                end
            else
                if not get_flag(0x029D) and not get_flag(0x029C) and not get_flag(0x029E) then
                    say("\"I beg thy pardon, but perhaps thou shouldst go to the Lycaeum and have someone look up the definition of the word 'virginity' for thee. Wouldst thou mind stepping back, please?! Thou dost make me nervous.\"")
                else
                    say("\"Yes, I could tell the answer to my question before thou didst even speak it. Art thou a virgin by choice or by circumstance?\"")
                    _AddAnswer({"circumstance", "choice"})
                end
            end
            _RemoveAnswer("avoid")
        elseif answer == "virginity" then
            say("\"Surely, Avatar, thou knowest that thou dost magically regain thy virginity each time upon returning to Britannia! Hast thou remained a virgin since then by choice or by circumstance?\"")
            _RemoveAnswer("virginity")
            _AddAnswer({"circumstance", "choice"})
        elseif answer == "choice" then
            say("\"Well, I am sure thou wilt find the right person one day.\"")
            _RemoveAnswer({"circumstance", "choice"})
        elseif answer == "circumstance" then
            say("\"That is too bad, I am very sorry. I would love to be able to help thee, but that is no longer my purpose.\"")
            _RemoveAnswer({"choice", "circumstance"})
            _AddAnswer("help")
        elseif answer == "help" then
            say("\"Oh, I do not know. It has been so long since I was personally involved in such matters. Art thou seeking love or art thou seeking lust?\"")
            _AddAnswer({"lust", "love"})
            _RemoveAnswer("help")
        elseif answer == "love" then
            say("\"Hmmm, love is usually a very elusive quarry. I suppose that thou canst try thy luck in the city of Cove. It is a city of lovers, or so I have heard.\"")
            _RemoveAnswer({"lust", "love"})
        elseif answer == "lust" then
            say("\"If quenching thy lust is thine only concern, then thou shouldst find satisfaction at the Baths, in Buccaneer's Den. But be sure to take a full purse.\"")
            _RemoveAnswer({"lust", "love"})
        elseif answer == "bye" then
            say("\"Fare thee well, Avatar.\"*")
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