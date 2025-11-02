--- Best guess: Handles dialogue with Robin, a gambler stranded in New Magincia, discussing his gambling profession, his bodyguards Battles and Leavell, a lost locket, and a sinister plan to kidnap Constance for profit in Buccaneer's Den.
function npc_robin_0134(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    start_conversation()
    if eventid == 1 then
        switch_talk_to(134)
        var_0000 = get_lord_or_lady()
        var_0001 = get_npc_name(134) --- Guess: Gets object ref
        var_0002 = get_npc_name(136) --- Guess: Gets object ref
        var_0003 = get_npc_name(135) --- Guess: Gets object ref
        var_0004 = utility_unknown_1073(2, 359, 955, 1, 356) --- Guess: Checks item in inventory
        var_0005 = is_player_wearing_fellowship_medallion() --- Guess: Checks Fellowship membership
        add_answer({"bye", "job", "name"})
        if not get_flag(381) then
            add_answer("locket")
        end
        if var_0004 then
            add_answer("show locket")
        end
        if var_0005 then
            add_answer("Fellowship")
        end
        if not get_flag(399) then
            add_dialogue("You see a roguish man dressed in what appears to be some nobleman's ratty hand-me-downs.")
            set_flag(399, true)
            if not get_flag(384) then
                add_answer("strangers")
            end
        else
            add_dialogue("\"Greetings, and how may I be of service to thee?\" asks Robin.")
        end
        while true do
            var_0006 = get_answer()
            if var_0006 == "name" then
                add_dialogue("\"My name, " .. var_0000 .. ", is Robin. A pleasure to meet thee. I have come to New Magincia only recently.\"")
                set_flag(399, true)
                add_answer("New Magincia")
                remove_answer("name")
            elseif var_0006 == "job" then
                add_dialogue("\"My father, a well-respected nobleman whose name I will not defame by mentioning, bastardized and disowned me. But he did teach me mine occupation.\"")
                add_answer("occupation")
            elseif var_0006 == "occupation" then
                add_dialogue("\"Why, that most glamorous and respected of occupations, " .. var_0000 .. ". Winning at games of chance.\"")
                remove_answer("occupation")
            elseif var_0006 == "New Magincia" then
                add_dialogue("\"I am not from here. My colleagues and I had to quickly leave Buccaneer's Den after a dispute with the casino owner. And a rough voyage it was, too.\"")
                add_answer({"voyage", "dispute", "Buccaneer's Den", "colleagues"})
                remove_answer("New Magincia")
            elseif var_0006 == "colleagues" then
                add_dialogue("\"My friends are Battles and Leavell. Their job is to protect me and my winnings. In exchange they share in my profits.\"")
                add_answer({"Leavell", "Battles"})
                remove_answer("colleagues")
            elseif var_0006 == "Battles" then
                add_dialogue("\"I rescued him from his captain who was about to make him walk the plank. I diced with that Captain for the lad's life. Later, Battles led a mutiny that took the ship, and... well, that is another story.\"")
                remove_answer("Battles")
            elseif var_0006 == "Leavell" then
                add_dialogue("\"I rescued him from a gaggle of angry noblemen's daughters who had just discovered he was courting all of them simultaneously. If not for me he would have certainly perished! But I am ahead of myself.\"")
                remove_answer("Leavell")
            elseif var_0006 == "Buccaneer's Den" then
                add_dialogue("\"It is where we live most of the year. There are a lot of rough characters there and it is not a place to be seen carrying large amounts of money.\"")
                add_answer("rough characters")
                remove_answer("Buccaneer's Den")
            elseif var_0006 == "dispute" then
                add_dialogue("\"I won a vulgar amount of the casino's gold and 'The Mister' of the place, Gordy, accused me of cheating. He sent his legbreaker, Sintag, after us. Pirates do not like to lose!\"")
                remove_answer("dispute")
                add_answer("The Mister")
            elseif var_0006 == "The Mister" then
                add_dialogue("\"Do not ask me why he is called that! Everyone there calls him that, though!\"")
                remove_answer("The Mister")
            elseif var_0006 == "voyage" then
                add_dialogue("\"We took the first ship out, but before we got back to the mainland it had sunk. The three of us barely managed to make it to New Magincia with our lives. Now we are marooned here.\"")
                remove_answer("voyage")
                add_answer("marooned")
            elseif var_0006 == "strangers" then
                add_dialogue("\"I do not know of any. I only just arrived here myself.\"")
                remove_answer("strangers")
            elseif var_0006 == "rough characters" then
                add_dialogue("\"One rough character in particular to stay away from is a man called Hook. He would kill thee for a trifle. Thou canst tell him by the hook he has for a hand.\"")
                add_answer("Hook")
                remove_answer("rough characters")
            elseif var_0006 == "Hook" then
                add_dialogue("\"I know nothing more. If thou thinkest that I would willingly cross paths with the likes of him thou must have me mistaken for someone else!\"")
                remove_answer("Hook")
            elseif var_0006 == "locket" then
                add_dialogue("\"We are trying to return to Buccaneer's Den. I was hoping to sell a gold locket which came into my possession to buy our passage back, but I fear it is lost. If thou dost come across it be sure to let me know.\"")
                remove_answer("locket")
            elseif var_0006 == "Fellowship" then
                add_dialogue("\"Thou art a member of The Fellowship! For years I have been seeing Fellowship members winning heavy stakes at the House of Games. Canst thou tell me their secret?\"")
                var_0007 = select_option()
                if var_0007 then
                    add_dialogue("\"Of course thou canst. But I do not suspect that thou wilt.\" Robin shrugs his shoulders.")
                else
                    add_dialogue("\"Forgive me if I do not believe thee.\"")
                end
                remove_answer("Fellowship")
            elseif var_0006 == "marooned" then
                add_dialogue("\"That is right. We cannot afford the stinking ship sold by the shipwright.\"")
                add_dialogue("\"But say, thou must have gotten here in some manner! Dost thou have some manner of ship on which we could leave the island?\"")
                var_0008 = select_option()
                if var_0008 then
                    add_dialogue("\"I could pay thee well if thou wouldst take us back to Buccaneer's Den.\"")
                    add_answer("pay")
                else
                    add_dialogue("\"If thou shouldst come across a way off this island please permit us to leave with thee.\"")
                end
                remove_answer("marooned")
            elseif var_0006 == "pay" then
                add_dialogue("\"Of course, I cannot pay thee right now at this moment. But when we reach Buccaneer's Den, I promise thee, I shall be able to get mine hands on a lot of money.\"")
                remove_answer("pay")
                add_answer("money")
            elseif var_0006 == "money" then
                add_dialogue("\"Yes, money! For I have found something here in New Magincia that will be worth more than gold in Buccaneer's Den.\"")
                remove_answer("money")
                add_answer("something")
            elseif var_0006 == "something" then
                add_dialogue("\"Before I tell thee what it is, wilt thou promise to take me and my mates back to Buccaneer's Den?\"")
                var_0009 = select_option()
                if var_0009 then
                    var_000A = true
                    add_dialogue("Robin looks you in the eye. \"Thou art truly a kind friend. I suppose then I should tell thee what it is we are planning on bringing back from New Magincia.\"")
                    add_answer("bringing back")
                else
                    add_dialogue("\"Then I cannot trust thee enough to tell thee of my plans. Go away.\"")
                    abort()
                end
                remove_answer("something")
            elseif var_0006 == "bringing back" then
                if not var_0004 then
                    add_dialogue("\"Since thou art truly a friend then I know that I can ask a favor of thee. Why dost thou not bring back that lost locket to me and we shall speak of these things some more.\" He flashes you a wicked grin.")
                else
                    add_dialogue("\"Since thou hast brought my locket back here, I suppose that I can trust thee. I intend to take Constance back with us and sell her to the operator of the baths.\"")
                end
                remove_answer("bringing back")
            elseif var_0006 == "show locket" then
                add_dialogue("\"Now that I know I can trust thee, I can let thee in on our plan. I intend to take another passenger in thy boat back with us to Buccaneer's Den. Her name is Constance and she should fetch a goodly price from Glenno, operator of the baths. Enough to pay my debts, pay thee for passage and still have plenty left over for another go at the House of Games!\"")
                utility_unknown_1041(100) --- Guess: Submits item or advances quest
                set_flag(388, true)
                add_answer("boat")
                remove_answer("show locket")
            elseif var_0006 == "boat" then
                add_dialogue("\"Thou must get thy boat ready to leave this place immediately. My lads and I shall get Constance and then we shall join thee. But wilt thou tell me where thy boat is located?\"")
                var_000A = select_option()
                if var_000A then
                    add_dialogue("You give Robin the location of your boat. He slowly breaks into an evil laugh. \"I thank thee, friend. All that is left for us is to eliminate one remaining loose end. Now that we know where thy boat is we will collect more on our investment by simply killing thee and taking it.\"")
                else
                    add_dialogue("\"Thou hast lost thy stomach for our game, eh? If that is the case then my lads and I have no choice but to kill thee dead to protect our secret!\"")
                end
                set_schedule_type(0, var_0001) --- Guess: Sets object behavior
                set_schedule_type(0, var_0002) --- Guess: Sets object behavior
                set_schedule_type(0, var_0003) --- Guess: Sets object behavior
                abort()
            elseif var_0006 == "bye" then
                break
            end
        end
        add_dialogue("\"It has been a pleasure speaking with thee, " .. var_0000 .. ".\"")
    elseif eventid == 0 then
        utility_unknown_1070(134) --- Guess: Triggers a game event
    end
end