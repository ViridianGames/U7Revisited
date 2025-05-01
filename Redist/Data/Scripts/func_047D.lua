-- Manages Vokes's dialogue in Jhelom, covering his fighting career, the honor flag, and Sprellic's duel.
function func_047D(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 1 then
        switch_talk_to(125, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = get_item_type(-125)
        local3 = get_item_type(-127)
        local4 = get_item_type(-126)
        local5 = switch_talk_to(126)
        local6 = switch_talk_to(127)

        add_answer({"bye", "job", "name"})

        if not get_flag(375) then
            add_dialogue("You see a fighting man. His voice booms like thunder as he greets you. \"Hail to thee, " .. local0 .. "!\"")
            set_flag(375, true)
        else
            add_dialogue("\"So, once again, I am at thy service,\" bellows Vokes.")
        end

        if not get_flag(360) and not get_flag(356) then
            add_dialogue("\"If thou wouldst return the honor flag of the Library of Scars, then it is only proper that is turned back over to Syria, who was guarding it when it was stolen. Please do so.\"*")
            return
        elseif get_flag(368) then
            if local1 == 4 then
                add_dialogue("\"So, thou wishest to fight for the cowardly Sprellic! Then I have no choice but to finish thee myself!\"*")
                apply_effect(100) -- Unmapped intrinsic 0911
                set_schedule(3, local2)
                set_schedule(3, local4)
                set_schedule(3, local3)
                set_schedule(0, local2)
                set_schedule(0, local3)
                set_schedule(0, local4)
                return
            else
                add_dialogue("\"So, thou wishes to fight for the cowardly Sprellic! Meet us at the duelling area at next noon!\"")
            end
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"My name is Vokes, " .. local0 .. ". As big as a mountain, as strong as an ox, as fierce as... well, more fierce than anything thou hast ever fought!\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"Job! I am not in the habit of plowing fields or peddling vegetables, " .. local0 .. "! I earn my gold with this sword arm,\" he says as he flexes a mighty bicep. \"Right now I am in Jhelom continuing my studies in my trade with De Snel, and when I am finished my price is going to go up!\"")
                add_answer("Jhelom")
            elseif answer == "Jhelom" then
                add_dialogue("\"I was born here! Is it not magnificent?! Why, in any hour of any day thou canst get into a duel with anyone for no reason at all! Now that is what I call the benefits of civilization!\"")
                add_answer("duel")
                remove_answer("Jhelom")
            elseif answer == "duel" then
                add_dialogue("\"A responsibility, yes, even a necessity. The cost of being honorable is that one must defend one's honor. There is no telling just where or when the next stain on one's honor may appear. Like this Sprellic fool, for instance. The perfect example!\"*")
                if local5 then
                    switch_talk_to(126, 0)
                    add_dialogue("\"I'll make a stain on his honor, that's for sure. A blood red one!\"*")
                    hide_npc(126)
                    switch_talk_to(125, 0)
                end
                add_answer("Sprellic")
                remove_answer("duel")
            elseif answer == "Sprellic" then
                if not get_flag(356) then
                    add_dialogue("\"The bloody idiot had no idea that when he took our honor flag he would be seen doing it. Hence, he never considered the fact that he would have to fight a duel over our sullied honor. But now that the whole town is talking of the incident there is no way that we could refrain from standing up for ourselves. Especially since he has refused to return what he has taken from us.\"*")
                    if local6 then
                        switch_talk_to(127, 0)
                        add_dialogue("\"Were he not such a cad, he would see the foolishness of his actions. 'Tis now up to us to show him!\"*")
                        hide_npc(127)
                        switch_talk_to(125, 0)
                    end
                    add_answer({"honor flag", "misunderstanding"})
                else
                    add_dialogue("\"If he had not returned the honor flag to us we would have had to kill him dead as sure as I am standing here.\"")
                end
                remove_answer("Sprellic")
            elseif answer == "honor flag" then
                add_dialogue("\"There is a widely known and long-standing tradition concerning the honor flag of the Library of Scars. It is said that taking the flag from the wall is a signal meaning that the person who takes the flag can beat anyone who studies at the school in a fight. It is also a grossly insulting way of saying that thou dost think the method of fighting a school teaches is inferior, which the Library of Scars most certainly is not!\"")
                add_answer("Library of Scars")
                remove_answer("honor flag")
            elseif answer == "misunderstanding" then
                add_dialogue("\"I have heard that rot about it all being a misunderstanding. The only thing misunderstood is how bad Sprellic will look when we finish with him!\"")
                remove_answer("misunderstanding")
            elseif answer == "Library of Scars" then
                add_dialogue("\"The Library of Scars teaches the supreme fighting style! One that enables thee to get the advantage against thine opponents and soundly defeat them through the brilliantly conceived subterfuge of Master De Snel!\"")
                add_answer("De Snel")
                remove_answer("Library of Scars")
            elseif answer == "De Snel" then
                add_dialogue("\"He is a genius. Perhaps the greatest military mind that ever lived. He told us so!\"")
                remove_answer("De Snel")
            elseif answer == "bye" then
                add_dialogue("\"If I am not killed and thou art not killed perhaps we may raise a glass together some day!\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(125)
    end
    return
end