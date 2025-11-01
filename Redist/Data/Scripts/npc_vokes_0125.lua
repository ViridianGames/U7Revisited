--- Best guess: Manages Vokes's dialogue, a fighter at the Library of Scars in Jhelom, discussing his role, the honor flag theft, and duels with Sprellic, with flag-based combat triggers and banter with Syria.
function npc_vokes_0125(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid ~= 1 then
        if eventid == 0 then
            utility_unknown_1070(125)
        end
        return
    end

    start_conversation()
    switch_talk_to(0, 125)
    var_0000 = get_lord_or_lady()
    var_0001 = get_schedule()
    var_0002 = get_npc_name(125)
    var_0003 = get_npc_name(127)
    var_0004 = get_npc_name(126)
    var_0005 = npc_id_in_party(126)
    var_0006 = npc_id_in_party(127)
    if not get_flag(375) then
        add_dialogue("You see a fighting man. His voice booms like thunder as he greets you. \"Hail to thee, " .. var_0000 .. "!\"")
        set_flag(375, true)
    else
        add_dialogue("\"So, once again, I am at thy service,\" bellows Vokes.")
    end
    if not get_flag(360) then
        add_dialogue("\"If thou wouldst return the honor flag of the Library of Scars, then it is only proper that is turned back over to Syria, who was guarding it when it was stolen. Please do so.\"")
        return
    end
    if get_flag(368) then
        if var_0001 == 4 then
            add_dialogue("\"So, thou wishest to fight for the cowardly Sprellic! Then I have no choice but to finish thee myself!\"")
            utility_unknown_1041(100)
            set_alignment(3, var_0002)
            set_alignment(3, var_0004)
            set_alignment(3, var_0003)
            set_schedule_type(0, var_0002)
            set_schedule_type(0, var_0003)
            set_schedule_type(0, var_0004)
            return
        else
            add_dialogue("\"So, thou wishes to fight for the cowardly Sprellic! Meet us at the duelling area at next noon!\"")
        end
    end
    add_answer({"bye", "job", "name"})
    while true do
        if cmps("name") then
            add_dialogue("\"My name is Vokes, " .. var_0000 .. ". As big as a mountain, as strong as an ox, as fierce as... well, more fierce than anything thou hast ever fought!\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"Job! I am not in the habit of plowing fields or peddling vegetables, " .. var_0000 .. "! I earn my gold with this sword arm,\" he says as he flexes a mighty bicep. \"Right now I am in Jhelom continuing my studies in my trade with De Snel, and when I am finished my price is going to go up!\"")
            add_answer("Jhelom")
        elseif cmps("Jhelom") then
            add_dialogue("\"I was born here! Is it not magnificent?! Why, in any hour of any day thou canst get into a duel with anyone for no reason at all! Now that is what I call the benefits of civilization!\"")
            add_answer("duel")
            remove_answer("Jhelom")
        elseif cmps("duel") then
            add_dialogue("\"A responsibility, yes, even a necessity. The cost of being honorable is that one must defend one's honor. There is no telling just where or when the next stain on one's honor may appear. Like this Sprellic fool, for instance. The perfect example!\"")
            if var_0005 then
                switch_talk_to(0, 126)
                add_dialogue("\"I'll make a stain on his honor, that's for sure. A blood red one!\"")
                _hide_npc(126)
                switch_talk_to(0, 125)
            end
            add_answer("Sprellic")
            remove_answer("duel")
        elseif cmps("Sprellic") then
            if not get_flag(356) then
                add_dialogue("\"The bloody idiot had no idea that when he took our honor flag he would be seen doing it. Hence, he never considered the fact that he would have to fight a duel over our sullied honor. But now that the whole town is talking of the incident there is no way that we could refrain from standing up for ourselves. Especially since he has refused to return what he has taken from us.\"")
                if var_0006 then
                    switch_talk_to(0, 127)
                    add_dialogue("\"Were he not such a cad, he would see the foolishness of his actions. 'Tis now up to us to show him!\"")
                    _hide_npc(127)
                    switch_talk_to(0, 125)
                end
                add_answer("honor flag")
                if not get_flag(390) then
                    add_answer("misunderstanding")
                end
            else
                add_dialogue("\"If he had not returned the honor flag to us we would have had to kill him dead as sure as I am standing here.\"")
            end
            remove_answer("Sprellic")
        elseif cmps("honor flag") then
            add_dialogue("\"There is a widely known and long-standing tradition concerning the honor flag of the Library of Scars. It is said that taking the flag from the wall is a signal meaning that the person who takes the flag can beat anyone who studies at the school in a fight. It is also a grossly insulting way of saying that thou dost think the method of fighting a school teaches is inferior, which the Library of Scars most certainly is not!\"")
            add_answer("Library of Scars")
            remove_answer("honor flag")
        elseif cmps("misunderstanding") then
            add_dialogue("\"I have heard that rot about it all being a misunderstanding. The only thing misunderstood is how bad Sprellic will look when we finish with him!\"")
            remove_answer("misunderstanding")
        elseif cmps("Library of Scars") then
            add_dialogue("\"The Library of Scars teaches the supreme fighting style! One that enables thee to get the advantage against thine opponents and soundly defeat them through the brilliantly conceived subterfuge of Master De Snel!\"")
            add_answer("De Snel")
            remove_answer("Library of Scars")
        elseif cmps("De Snel") then
            add_dialogue("\"He is a genius. Perhaps the greatest military mind that ever lived. He told us so!\"")
            remove_answer("De Snel")
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"If I am not killed and thou art not killed perhaps we may raise a glass together some day!\"")
    return
end