-- Manages Burnside's dialogue in Minoc, covering town governance, murders, monument plans, and Fellowship membership.
function func_045B(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        switch_talk_to(91, 0)
        local0 = switch_talk_to(91)
        local1 = get_party_size()
        local3 = get_player_name()
        local4 = get_item_type()

        if local1 == 7 and local0 ~= 16 then
            local2 = apply_effect(-81, -91) -- Unmapped intrinsic 08FC
            if local2 then
                add_dialogue("The Fellowship meeting is in progress, and Burnside will not speak with you now.*")
                return
            else
                add_dialogue("\"I cannot speak now! I am late for the Fellowship meeting!\"*")
                return
            end
        end

        add_answer({"bye", "job", "name"})

        if not get_flag(253) then
            add_answer("plans")
        end

        if not get_flag(278) then
            add_dialogue("You see an elderly man struggling to maintain a regal posture.")
            add_dialogue("His eyes widen at the sight of you.")
            add_dialogue("\"I had heard thou were travelling in Britannia again, but it took mine own eyes to believe it! Welcome, Avatar!\"")
            set_flag(278, true)
        else
            add_dialogue("\"Ahh, Avatar. Good to see thee again.\" says Burnside.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Burnside is my name.\"")
                remove_answer("name")
            elseif answer == "job" then
                if not get_flag(287) then
                    add_dialogue("\"I am Mayor of Minoc and have been lo these past twenty years and more.\"")
                    add_answer("Minoc")
                else
                    add_dialogue("\"I beseech thee, " .. local3 .. ", do show some respect for the two poor souls who have been found murdered there in William's sawmill.\"")
                    set_flag(287, true)
                    add_answer("murders")
                end
            elseif answer == "Minoc" then
                add_dialogue("\"Apart from this business of the murders we are a town run by commerce. Gold runs this town. As goes the money, so goes Minoc. Take this monument affair, for instance.\"")
                remove_answer("Minoc")
                add_answer({"monument", "murders"})
            elseif answer == "murders" then
                add_dialogue("\"As Frederico and Tania were not actually residents of Minoc there is little I can do as Mayor other than increase the town guard. The investigation falls somewhat beyond my jurisdiction. It would appear the killer or killers were from out of town and are probably long gone by now. Thank goodness.\"")
                remove_answer("murders")
            elseif answer == "monument" then
                if not get_flag(247) then
                    add_dialogue("\"I am sure thou art aware of the plans for a monument of Owen, the shipwright. He is paying for it himself. I am usually against such public vanity but The Fellowship is very much in favor of it.\"")
                    add_answer({"Fellowship", "vanity"})
                else
                    add_dialogue("\"This town would have been ruined if I had allowed that monument to be built, so I immediately forbade it, of course.\"")
                end
                remove_answer("monument")
            elseif answer == "vanity" then
                add_dialogue("\"But in this special case it does immeasurable good for the town. It increases our prestige. People will come from all over Britannia for the unveiling.\"")
                remove_answer("vanity")
                add_answer("unveiling")
            elseif answer == "unveiling" then
                add_dialogue("\"Why, even Lord British himself will be in attendance! It is a special opportunity when one gets a private audience.\"")
                remove_answer("unveiling")
            elseif answer == "Fellowship" then
                if local4 then
                    add_dialogue("\"Ah, I see thou art wearing thy Fellowship medallion. I received mine from Elynor when The Fellowship branch was first opened here a few years ago.\"")
                else
                    add_dialogue("\"Yes, I wear the Fellowship medallion, given to me by Elynor. Do not worry thyself. I shall not try to make thee join!\" He laughs nervously at his own little joke.")
                end
                remove_answer("Fellowship")
                add_answer("Elynor")
            elseif answer == "Elynor" then
                if local4 then
                    add_dialogue("\"Elynor tells me The Fellowship will be doing good works here in the future. I am proud to be a member of thy society although I must confess to being fairly ignorant concerning thy, umm, our philosophy.\"")
                    add_answer("member")
                    remove_answer("Elynor")
                else
                    add_dialogue("\"Elynor says The Fellowship could bring much money into Minoc. It would be wonderful for trade. I could never let my personal feelings get in the way of the good of this town.\"")
                    add_answer("feelings")
                    remove_answer("Elynor")
                end
            elseif answer == "member" then
                add_dialogue("\"I was given an honorary membership when the Fellowship branch was first opened in Minoc. I do not attend regular meetings. I hope thou'rt not disappointed in me?\"")
                local5 = get_answer()
                if local5 then
                    add_dialogue("\"I am sorry, Avatar. I will try to do well and be a more valuable member of the Fellowship. I beg thee, do not speak of this to Elynor.\"")
                else
                    add_dialogue("\"Thank heaven! I wear this medallion mainly for ceremonial purposes, as I suspect thou dost. We both see that support of The Fellowship is currently the wisest course of action politically, no matter our personal feelings.\"")
                    add_answer("feelings")
                end
                remove_answer("member")
            elseif answer == "feelings" then
                add_dialogue("\"Avatar, may I tell thee a secret?\"")
                local5 = get_answer()
                if local5 then
                    add_dialogue("\"Avatar, I must confess to thee that I feel The Fellowship promotes a philosophy that is dubious at best, and its membership seems to be comprised chiefly of fools and emotional weaklings.\"")
                else
                    add_dialogue("\"Hrmph! Well, then, kindly forget mine ill-considered words!\"")
                end
                remove_answer("feelings")
            elseif answer == "plans" then
                add_dialogue("You show the Mayor the plans Owen had drawn, making sure to carefully point out the flaws discovered by Julia. The Mayor is aghast.~~\"This is terrible! No one must see this! It would ruin Owen and cause irreparable damage to our town if it became known that our shipwright caused those deaths!\"")
                remove_answer("plans")
                add_answer({"deaths", "damage"})
            elseif answer == "damage" then
                add_dialogue("\"But very few suspect the deaths are attributable to Owen's shipbuilding! We can destroy the plans and the truth would never get out! It would save the town from disgrace and possible ruin!\"")
                remove_answer("damage")
            elseif answer == "deaths" then
                add_dialogue("\"Then again, the ships Owen builds will continue to sink. It would harm Minoc even more if it were to become known as the place where the \"death ships\" are made. A town that built a monument to an incompetent.\"")
                remove_answer({"damage", "deaths"})
                add_answer("statue")
            elseif answer == "statue" then
                add_dialogue("\"There are no two ways about it. The statue must be stopped. I am hereby cancelling the erection of the statue.\"")
                add_dialogue("\"Oh, and...er, Avatar... couldst thou please go inform Owen of this bad news for me? I am a bit busy at the moment. Besides, I think he will take it much better hearing it from thee.\"")
                set_flag(247, true)
                remove_answer("statue")
            elseif answer == "bye" then
                add_dialogue("\"A pleasure, friend Avatar. A pleasure.\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(91)
    end
    return
end