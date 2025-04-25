-- Manages Robin's dialogue in New Magincia, covering his schemes, the stolen locket, and plans to kidnap Constance.
function func_0486(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10

    if eventid == 1 then
        switch_talk_to(-134, 0)
        local0 = get_player_name()
        local1 = get_item_type(-134)
        local2 = get_item_type(-136)
        local3 = get_item_type(-135)
        local4 = check_item(2, -359, 955, 1, -356) -- Unmapped intrinsic 0931
        local5 = get_item_type()

        add_answer({"bye", "job", "name"})
        if not get_flag(381) then
            add_answer("locket")
        end
        if local4 then
            add_answer("show locket")
        end
        if local5 then
            add_answer("Fellowship")
        end

        if not get_flag(399) then
            say("You see a roguish man dressed in what appears to be some nobleman's ratty hand-me-downs.")
            set_flag(399, true)
            if not get_flag(384) then
                add_answer("strangers")
            end
        else
            say("\"Greetings, and how may I be of service to thee?\" asks Robin.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"My name, " .. local0 .. ", is Robin. A pleasure to meet thee. I have come to New Magincia only recently.\"")
                set_flag(399, true)
                remove_answer("name")
                add_answer("New Magincia")
            elseif answer == "job" then
                say("\"My father, a well-respected nobleman whose name I will not defame by mentioning, bastardized and disowned me. But he did teach me mine occupation.\"")
                add_answer("occupation")
            elseif answer == "occupation" then
                say("\"Why, that most glamorous and respected of occupations, " .. local0 .. ". Winning at games of chance.\"")
                remove_answer("occupation")
            elseif answer == "New Magincia" then
                say("\"I am not from here. My colleagues and I had to quickly leave Buccaneer's Den after a dispute with the casino owner. And a rough voyage it was, too.\"")
                add_answer({"voyage", "dispute", "Buccaneer's Den", "colleagues"})
                remove_answer("New Magincia")
            elseif answer == "colleagues" then
                say("\"My friends are Battles and Leavell. Their job is to protect me and my winnings. In exchange they share in my profits.\"")
                add_answer({"Leavell", "Battles"})
                remove_answer("colleagues")
            elseif answer == "Battles" then
                say("\"I rescued him from his captain who was about to make him walk the plank. I diced with that Captain for the lad's life. Later, Battles led a mutiny that took the ship, and... well, that is another story.\"")
                remove_answer("Battles")
            elseif answer == "Leavell" then
                say("\"I rescued him from a gaggle of angry noblemen's daughters who had just discovered he was courting all of them simultaneously. If not for me he would have certainly perished! But I am ahead of myself.\"")
                remove_answer("Leavell")
            elseif answer == "Buccaneer's Den" then
                say("\"It is where we live most of the year. There are a lot of rough characters there and it is not a place to be seen carrying large amounts of money.\"")
                add_answer("rough characters")
                remove_answer("Buccaneer's Den")
            elseif answer == "dispute" then
                say("\"I won a vulgar amount of the casino's gold and 'The Mister' of the place, Gordy, accused me of cheating. He sent his legbreaker, Sintag, after us. Pirates do not like to lose!\"")
                remove_answer("dispute")
                add_answer("The Mister")
            elseif answer == "The Mister" then
                say("\"Do not ask me why he is called that! Everyone there calls him that, though!\"")
                remove_answer("The Mister")
            elseif answer == "voyage" then
                say("\"We took the first ship out, but before we got back to the mainland it had sunk. The three of us barely managed to make it to New Magincia with our lives. Now we are marooned here.\"")
                remove_answer("voyage")
                add_answer("marooned")
            elseif answer == "strangers" then
                say("\"I do not know of any. I only just arrived here myself.\"")
                remove_answer("strangers")
            elseif answer == "rough characters" then
                say("\"One rough character in particular to stay away from is a man called Hook. He would kill thee for a trifle. Thou canst tell him by the hook he has for a hand.\"")
                add_answer("Hook")
                remove_answer("rough characters")
            elseif answer == "Hook" then
                say("\"I know nothing more. If thou thinkest that I would willingly cross paths with the likes of him thou must have me mistaken for someone else!\"")
                remove_answer("Hook")
            elseif answer == "locket" then
                say("\"We are trying to return to Buccaneer's Den. I was hoping to sell a gold locket which came into my possession to buy our passage back, but I fear it is lost. If thou dost come across it be sure to let me know.\"")
                remove_answer("locket")
            elseif answer == "Fellowship" then
                say("\"Thou art a member of The Fellowship! For years I have been seeing Fellowship members winning heavy stakes at the House of Games. Canst thou tell me their secret?\"")
                local6 = get_answer()
                if local6 then
                    say("\"Of course thou canst. But I do not suspect that thou wilt.\" Robin shrugs his shoulders.")
                else
                    say("\"Forgive me if I do not believe thee.\"")
                end
                remove_answer("Fellowship")
            elseif answer == "marooned" then
                say("\"That is right. We cannot afford the stinking ship sold by the shipwright.\"")
                say("\"But say, thou must have gotten here in some manner! Dost thou have some manner of ship on which we could leave the island?\"")
                local7 = get_answer()
                if local7 then
                    say("\"I could pay thee well if thou wouldst take us back to Buccaneer's Den.\"")
                    add_answer("pay")
                else
                    say("\"If thou shouldst come across a way off this island please permit us to leave with thee.\"")
                end
                remove_answer("marooned")
            elseif answer == "pay" then
                say("\"Of course, I cannot pay thee right now at this moment. But when we reach Buccaneer's Den, I promise thee, I shall be able to get mine hands on a lot of money.\"")
                remove_answer("pay")
                add_answer("money")
            elseif answer == "money" then
                say("\"Yes, money! For I have found something here in New Magincia that will be worth more than gold in Buccaneer's Den.\"")
                remove_answer("money")
                add_answer("something")
            elseif answer == "something" then
                say("\"Before I tell thee what it is, wilt thou promise to take me and my mates back to Buccaneer's Den?\"")
                local8 = get_answer()
                if local8 then
                    local9 = true
                    say("Robin looks you in the eye. \"Thou art truly a kind friend. I suppose then I should tell thee what it is we are planning on bringing back from New Magincia.\"")
                    add_answer("bringing back")
                else
                    say("\"Then I cannot trust thee enough to tell thee of my plans. Go away.\"")
                    return
                end
                remove_answer("something")
            elseif answer == "bringing back" then
                if not local4 then
                    say("\"Since thou art truly a friend then I know that I can ask a favor of thee. Why dost thou not bring back that lost locket to me and we shall speak of these things some more.\" He flashes you a wicked grin.")
                else
                    say("\"Since thou hast brought my locket back here, I suppose that I can trust thee. I intend to take Constance back with us and sell her to the operator of the baths.\"")
                end
                remove_answer("bringing back")
            elseif answer == "show locket" then
                say("\"Now that I know I can trust thee, I can let thee in on our plan. I intend to take another passenger in thy boat back with us to Buccaneer's Den. Her name is Constance and she should fetch a goodly price from Glenno, operator of the baths. Enough to pay my debts, pay thee for passage and still have plenty left over for another go at the House of Games!\"")
                apply_effect(100) -- Unmapped intrinsic 0911
                set_flag(388, true)
                add_answer("boat")
                remove_answer("show locket")
            elseif answer == "boat" then
                say("\"Thou must get thy boat ready to leave this place immediately. My lads and I shall get Constance and then we shall join thee. But wilt thou tell me where thy boat is located?\"")
                local10 = get_answer()
                if local10 then
                    say("You give Robin the location of your boat. He slowly breaks into an evil laugh. \"I thank thee, friend. All that is left for us is to eliminate one remaining loose end. Now that we know where thy boat is we will collect more on our investment by simply killing thee and taking it.\"*")
                else
                    say("\"Thou hast lost thy stomach for our game, eh? If that is the case then my lads and I have no choice but to kill thee dead to protect our secret!\"*")
                end
                set_schedule(0, local1)
                set_schedule(0, local2)
                set_schedule(0, local3)
                return
            elseif answer == "bye" then
                say("\"It has been a pleasure speaking with thee, " .. local0 .. ".\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(-134)
    end
    return
end