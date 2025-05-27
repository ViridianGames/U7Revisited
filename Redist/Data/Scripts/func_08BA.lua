--- Best guess: Manages Margareta’s fortune-telling dialogue, providing quest-related prophecies for 20 gold, with gender-specific dialogue and flag progression.
function func_08BA()
    start_conversation()
    local var_0000, var_0001, var_0002

    var_0000 = unknown_005AH()
    add_dialogue("\"The fortune vill cost thee 20 gold. All right?\"")
    var_0001 = ask_yes_no()
    if not var_0001 then
        var_0002 = unknown_002BH(true, 359, 359, 644, 20)
        if var_0002 then
            add_dialogue("Margareta takes your money.")
        else
            add_dialogue("\"Thou dost not have enough gold.\"")
            add_dialogue("Margareta turns away from you.")
            return
        end
    else
        add_dialogue("\"Never mind, then.\"")
        add_dialogue("Margareta turns away from you.")
        return
    end
    unknown_002EH(0, 31)
    add_dialogue("The gypsy woman peers into her crystal ball.")
    if not var_0000 then
        if get_flag(226) then
            add_dialogue("\"I see a voman standing by a shrine. She is in love vith thee. I do not see more on this subject.\"")
        else
            add_dialogue("\"I see a voman standing by a shrine. She vill play an important role in thy life.\"")
        end
    end
    add_dialogue("\"Hmmm... The crystal ball is very murky...\"")
    if not get_flag(6) then
        add_dialogue("\"I see that thou must join The Fellowship if thou vantest to learn more about them and discover their true nature.\"")
    else
        add_dialogue("\"Now that thou art a Fellowship member, thou vilt learn more about them and discover their true nature in due time.\"")
    end
    add_dialogue("\"It is not very clear... ah, yes... there is a new evil that threatens Britannia. I see that thou shalt have to reckon vith it in the future.\"")
    add_dialogue("\"The crystal ball tells me that the ether ov the vorld -- the substance that controls magic -- has been affected by this new evil presence.\"")
    add_dialogue("\"I see further that this evil presence vill gain greater power during an event in the near future. This event has something to do vith the planets. Seek out a man at the observatory in Moonglow to learn more about this. I see that he has a device which will be very useful to thee. See him soon, for this event is drawing near.\"")
    add_dialogue("\"Vhat is this? I see... I see... thou dost seek a Man vith a Hook. He is not thy true adversary, but finding him vill be necessary to complete thine ultimate quest.\"")
    add_dialogue("\"Vait! I see that thou must seek audience vith the Time Lord. He is in trouble, although I cannot see vhat that trouble is. The Time Lord knows much about this new evil, so do not fail to seek him out.\"")
    add_dialogue("\"To find the Time Lord, thou must first meet the Visps who live in the forest ov Yew. They are thy best link to him. The monks ov Empath Abbey may know how to contact the Visps.\"")
    add_dialogue("\"The ball has grown dark. I see no more.\"")
    add_dialogue("Margareta looks up at you and says, \"Thou dost face many dangers ahead. Take care.\"")
    add_dialogue("With those words, Margareta slumps and closes her eyes to rest. She is obviously exhausted.")
    if not get_flag(256) then
        unknown_0911H(50)
    end
    set_flag(256, true)
    return
end