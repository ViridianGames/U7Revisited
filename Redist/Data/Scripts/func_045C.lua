--- Best guess: Manages Rutherford’s dialogue, a one-armed barkeep in Minoc, discussing local murders, the Crown Jewel, Hook, and the Fellowship, with flag-based room rentals and a loop for party member pricing.
function func_045C(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    if eventid ~= 1 then
        if eventid == 0 then
            unknown_092EH(92)
        end
        add_dialogue("\"I shall see thee later... At least I will if thou dost stay in the front o' me good eye.\"")
        return
    end

    start_conversation()
    switch_talk_to(0, 92)
    var_0000 = get_lord_or_lady()
    var_0001 = get_schedule()
    var_0002 = unknown_001CH(get_npc_name(92))
    add_answer({"bye", "job", "name"})
    if get_flag(287) then
        add_answer("murders")
    end
    if not get_flag(64) then
        add_answer("Crown Jewel")
    end
    if not get_flag(67) then
        add_answer("Hook")
    end
    if not get_flag(279) then
        add_dialogue("You see a weary-looking man who is missing his right arm. With his one hand he scratches his head and squints in your general direction.")
        set_flag(279, true)
    else
        add_dialogue("\"Oy, how ye been, " .. var_0000 .. "?\" Rutherford calls out to you.")
    end
    while true do
        if cmps("name") then
            add_dialogue("He lets out a sharp cough to clear his throat. \"Rutherford's me name. Pleased ta meet 'chur.\"~~ He extends his greasy hand for you to shake and does not retract it until it is clasped.")
            remove_answer("name")
        elseif cmps("job") then
            if not get_flag(287) then
                add_dialogue("\"Why I be the barkeep of The Checquered Cork. No better place in Minoc to discuss the events of the day.\"")
                if var_0002 == 23 then
                    add_dialogue("He coughs into the rag he had just been using to polish the bar.")
                    var_0003 = npc_id_in_party(-4)
                    if var_0003 then
                        add_dialogue("\"Hello again, Sir Dupre! Didst thou enjoy mine establishment so much that thou hast returned?\"")
                        switch_talk_to(0, -4)
                        add_dialogue("\"My dear Rutherford, this is not a reflection on The Checquered Cork, but I simply like a good drink!\"")
                        hide_npc4)
                        switch_talk_to(0, 92)
                    end
                    add_answer({"room", "buy", "events", "Minoc"})
                else
                    add_dialogue("\"'Tis no time for idle chatter! There have been two people murdered over at William's sawmill!\"")
                    set_flag(287, true)
                end
            else
                add_dialogue("\"'Tis no time for idle chatter! There have been two people murdered over at William's sawmill!\"")
                set_flag(287, true)
            end
        elseif cmps("buy") then
            if var_0002 == 23 then
                add_dialogue("\"We have a cornucopian variety of elixirs to quench thy tongue and gourmet dishes to appease thy palate.\"")
                unknown_08DEH()
            else
                add_dialogue("\"As I have finished my workday, I ask thee to come back another time. Thou dost have my thanks.\"")
            end
            remove_answer("buy")
        elseif cmps("room") then
            if var_0002 == 23 then
                add_dialogue("\"A room for the night is quite reasonable. Only 8 gold per person. Want one?\"")
                if ask_yes_no() then
                    var_0004 = get_party_members()
                    var_0005 = 0
                    for i = 1, var_0004 do
                        var_0005 = var_0005 + 1
                    end
                    var_0009 = var_0005 * 8
                    var_000A = unknown_0028H(359, 359, 644, 357)
                    if var_000A >= var_0009 then
                        var_000B = unknown_002CH(true, 359, 255, 641, 1)
                        if not var_000B then
                            add_dialogue("\"Thou art carrying too much to take the room key, " .. var_0000 .. "!\"")
                        else
                            add_dialogue("\"Here is thy room key. It is good only until thou dost leave.\"")
                            var_000C = unknown_002BH(359, 359, 644, var_0009)
                        end
                    else
                        add_dialogue("\"Thou dost not have enough gold, eh? That be right bad.\"")
                    end
                else
                    add_dialogue("\"Mayhaps another night, then.\"")
                end
            else
                add_dialogue("\"If thou wouldst please make thy request at a time that was during my normal business hours, I would be most grateful.\"")
            end
            remove_answer("room")
        elseif cmps("Minoc") then
            add_dialogue("\"Yep, this town's usually bloody quiet. That was until recently!\" His squinting eye suddenly opens wide and stares straight at you.")
            if var_0002 == 23 then
                add_dialogue("\"Say, when exackly again didst thou say thou didst arrive in town, stranger?\"~~After a moment of carefully observing you, he shrugs his shoulders and goes back to wiping off the bar.")
            end
            remove_answer("Minoc")
        elseif cmps("events") then
            add_dialogue("\"Before all this evil at the sawmill, the buzz were all about the monument.\"")
            remove_answer("events")
            add_answer({"sawmill", "monument"})
        elseif cmps("murders") then
            add_dialogue("\"Well, I suppose that clears thee from the list o' possible murderers. If'n thou wert the murderer, thou wouldst not have to be askin' questions o'people about wha' 'appened regardin' the murders. Thou wouldst already know, havin' been there.\"")
            remove_answer("murders")
        elseif cmps("sawmill") then
            add_dialogue("\"Say, thou be not from around here?\" He looks at you skeptically. \"Thou art not from the Fellowship by any chance, art thou?\"")
            var_000D = ask_yes_no()
            if var_000D then
                add_dialogue("\"I thought so!\"")
                add_answer({"Fellowship", "murders"})
            else
                add_dialogue("\"Just askin'! Thou dost not have to take any offense!\"")
                add_answer({"Fellowship", "murders"})
            end
            remove_answer("sawmill")
        elseif cmps("Hook") then
            add_dialogue("\"I know him! He be a pirate who lives in Buccaneer's Den. They say Hook is so mean he'd kill his own mudder for the right price, an' I would wager they's right.~~\"Why, I got into a fight with this Hook once. I was lucky and I escaped losin' only my right arm and still with one good eye left. It was somewhere around that time that I started having second thoughts about my career as a pirate and now here I be.")
            add_dialogue("\"I have not seen him recently, but the description of the murder scene certainly sounds like his handiwork!\"")
            set_flag(260, true)
            unknown_0911H(10)
            remove_answer("Hook")
        elseif cmps("Crown Jewel") then
            add_dialogue("\"That ship was, indeed, here of late. In fact, 'twas the night of the murders! Could there be a connection? Hmmm...\"")
            remove_answer("Crown Jewel")
        elseif cmps("Fellowship") then
            add_dialogue("\"Thank goodness that with all the town at each others' throats in recent weeks we have the Fellowship tryin' to hold the town together. I be no member or nothin', but I just a'heared of all the good things they done. Feedin' the poor an' such.\"")
            remove_answer("Fellowship")
        elseif cmps("monument") then
            add_dialogue("\"Oh, thou must mean thet statuer they are goin' ta build of our shipwright. His name is Owen, a local boy. I understan' it is to be as tall as a man on horseback and shows Owen gazin' through a telerscope or some such thing like that.\"")
            remove_answer("monument")
        elseif cmps("bye") then
            break
        end
    end
    return
end