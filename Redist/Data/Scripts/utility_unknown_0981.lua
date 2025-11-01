--- Best guess: Manages a dialogue with a healer explaining how the player was rescued and brought to their shelter, with location-specific details based on flags.
function utility_unknown_0981()
    start_conversation()
    local var_0000

    if not get_flag(58) then
        var_0000 = "It is most fortunate that thou fell so near our shelter. Thou must have a protector watching over thee."
    else
        var_0000 = "It was Elizabeth and Abraham who found thee and delivered thee to us."
    end
    add_dialogue("\"Thank goodness thou art with us again! We were all very worried over thy condition.~~Thou hast been unconscious for so long that we thought thou hadst lost thy life!~~" .. var_0000 .. "*")
    if not get_flag(58) then
        return
    end
    if not get_flag(135) then
        add_dialogue("\"They brought thee here along their way to Britain.\"")
    end
    if get_flag(135) and not get_flag(261) then
        add_dialogue("\"They brought thee here along their way to Minoc.\"")
    end
    if get_flag(261) and not get_flag(535) then
        add_dialogue("\"They brought thee to us as they were on their way here to Paws, but they have since left for Jhelom.\"")
        set_flag(535, true)
    end
    if get_flag(535) and not get_flag(363) then
        add_dialogue("\"They brought thee here along their way to Jhelom.\"")
    end
    if get_flag(363) and not get_flag(136) then
        add_dialogue("\"They brought thee here along their way to Britain.\"")
    end
    if get_flag(136) and not get_flag(644) then
        add_dialogue("\"They brought thee here along their way to Vesper.\"")
    end
    if get_flag(644) and not get_flag(495) then
        add_dialogue("\"They brought thee here along their way to Moonglow.\"")
    end
    if get_flag(495) and not get_flag(579) then
        add_dialogue("\"They brought thee here along their way to Terfin.\"")
    end
    if get_flag(579) and not get_flag(612) then
        add_dialogue("\"They brought thee here along their way to the Fellowship meditation retreat near Serpent's Hold.\"")
    end
    if get_flag(612) and not get_flag(680) then
        add_dialogue("\"They brought thee here along their way to Buccaneer's Den.\"")
    end
    if get_flag(680) then
        add_dialogue("\"They brought thee here and then returned to Buccaneer's Den.\"")
    end
    if get_flag(38) then
        add_dialogue("\"It is truly mysterious how this continues to happen to thee!\"")
    end
    return
end