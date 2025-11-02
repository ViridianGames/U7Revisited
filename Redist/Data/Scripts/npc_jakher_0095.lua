--- Best guess: Manages Jakher's dialogue, a combat trainer in Minoc, discussing local murders, his colleague Karenna, Owen's past, and the gypsies, with flag-based training sessions and companion interactions.
function npc_jakher_0095(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid ~= 1 then
        if eventid == 0 then
            utility_unknown_1070(95)
        end
        add_dialogue("\"It has been a pleasure speaking with thee.\"")
        return
    end

    start_conversation()
    switch_talk_to(95)
    var_0000 = get_lord_or_lady()
    var_0001 = get_schedule(95)
    var_0002 = get_schedule_type(get_npc_name(95))
    add_answer({"bye", "job", "name"})
    if get_flag(246) then
        add_answer("cute")
    end
    if not get_flag(282) then
        add_dialogue("You see a stern but friendly-looking man, dressed in a military fashion. As you watch him, you get the feeling he is sizing you up as well.")
        set_flag(282, true)
    else
        add_dialogue("\"How may I be of service to thee?\" says Jakher.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am Jakher, named after a great general from the ancient times of Sosaria. Welcome to Minoc.\"")
            remove_answer("name")
            add_answer("Minoc")
        elseif cmps("job") then
            if not get_flag(287) then
                add_dialogue("\"Along with Karenna, I am a trainer in the fighting arts. My specialty is strength and strategy. On the field of battle, if one does not use his head while using one's muscles, he is in danger of losing it.\"")
                add_answer({"trainer", "Karenna"})
            else
                add_dialogue("\"Perhaps that is something of which we should speak in a more appropriate time. Right now our concern should be to discover who could have been responsible for the two murders that have just been discovered in William's sawmill.\"")
                set_flag(287, true)
                add_answer("murders")
            end
        elseif cmps("trainer") then
            if var_0002 == 27 then
                add_dialogue("\"My price is 20 gold for each training session. Art thou still interested?\"")
                if ask_yes_no() then
                    utility_unknown_0927(20, 0, {2})
                else
                    add_dialogue("\"The true value of what I teach is beyond measure. My time is precious to me and therefore valuable. If thou didst pay me a paltry sum and I trained thee anyway, it would be an insult to us both.")
                    add_dialogue("\"'Tis a pity few truly comprehend the value of strategy and tactics. Thou mayest hack and slash with thy sword all that thou wilt, but it cannot do thy thinking for thee.\"")
                end
            else
                add_dialogue("\"I am not in the habit of running training sessions at this particular time.\"")
                remove_answer("trainer")
            end
        elseif cmps("Minoc") then
            add_dialogue("\"Ours is a city of commerce, although lately its primary trade seems to be gossip and envy. Before these murders, the latest local scandal had been the statue to be built of Owen, the shipwright.\"")
            remove_answer("Minoc")
            add_answer({"Owen", "murders"})
        elseif cmps("murders") then
            add_dialogue("\"I suspect the killer -- or killers -- are from out of town, and probably long gone by now. There has not been a local murder for some time before today. Our fair measure of prosperity has made the people here mostly tolerant of each other. That is why the gypsies settled here. The apparent lack of motive is puzzling.\"")
            remove_answer("murders")
            add_answer({"gypsies", "gone"})
        elseif cmps("gone") then
            add_dialogue("\"I doubt that anyone in our community is the killer. If the stranger, or strangers, involved were to remain for long after the crime, they would soon be revealed. Therefore, the killers are no longer in town.\"")
            remove_answer("gone")
        elseif cmps("Karenna") then
            add_dialogue("\"A skillful and fierce battler, but a bit short-sighted when it comes to tactics, I'm afraid. Still, a woman as attractive as she is diverting enough when encountered. But do not mention to her that I said that. It would just encourage her. It is uncomfortable enough sharing the same roof with her as it is.\"")
            var_0003 = npc_id_in_party(-94)
            if var_0003 then
                switch_talk_to(-94)
                add_dialogue("\"What art thou whispering about over there?\"")
                switch_talk_to(95)
                add_dialogue("\"Nothing! Nothing at all!\" Jakher winks at you.")
                --syntax error hide_npc94)
                switch_talk_to(95)
            end
            set_flag(245, true)
            remove_answer("Karenna")
            add_answer({"roof", "short-sighted"})
        elseif cmps("short-sighted") then
            add_dialogue("\"She is the sort of person who labors under the belief that all problems can be solved in one of three ways. Hit them harder. Hit them faster. Or, hit them some more.\"")
            var_0003 = npc_id_in_party(-94)
            if var_0003 then
                switch_talk_to(-94)
                add_dialogue("\"Art thou talking about me? I feel mine ears burning!\"")
                switch_talk_to(95)
                add_dialogue("\"Thou art dreaming, Karenna. Why would I talk about thee?\" He giggles conspiratorially at you.")
                --syntax error hide_npc94)
                switch_talk_to(95)
            end
            remove_answer("short-sighted")
        elseif cmps("roof") then
            add_dialogue("\"There used to be two training halls in Minoc but one of them burned down after being struck by lightning. Now we are both forced to share this one.\"")
            remove_answer("roof")
        elseif cmps("cute") then
            add_dialogue("\"Ah, so Karenna said I was cute, did she? Yes, I have known she has had her sights set on me for years.\"")
            remove_answer("cute")
        elseif cmps("Owen") then
            add_dialogue("\"I have known Owen as long as anyone in this town. Several years ago, three ships that he built sank. The brother of Karl, one of our more colorful local residents, was killed. No investigation was ever made into the cause of the sinkings, but Owen once confided to me that he secretly blamed himself. He started drinking heavily, and eventually took up with The Fellowship.\"")
            remove_answer("Owen")
            set_flag(248, true)
        elseif cmps("gypsies") then
            add_dialogue("\"Thou wouldst do better to ask Karenna. She is a good friend of the gypsies and would know more about them than I.\"")
            remove_answer("gypsies")
            set_flag(244, true)
        elseif cmps("bye") then
            break
        end
    end
    return
end