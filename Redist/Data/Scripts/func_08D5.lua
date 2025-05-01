-- Function 08D5: Manages rescue dialogue
function func_08D5()
    -- Local variable (1 as per .localc)
    local local0

    if not get_flag(0x003A) then
        local0 = "It is most fortunate that thou fell so near our shelter. Thou must have a protector watching over thee."
    else
        local0 = "It was Elizabeth and Abraham who found thee and delivered thee to us."
    end

    add_dialogue("\"Thank goodness thou art with us again! We were all very worried over thy condition.~~\"Thou hast been unconscious for so long that we thought thou hadst lost thy life!~~", local0, "*")
    if not get_flag(0x003A) then
        if not get_flag(0x0087) then
            add_dialogue("\"They brought thee here along their way to Britain.\"")
        end
        if get_flag(0x0087) and not get_flag(0x0105) then
            add_dialogue("\"They brought thee here along their way to Minoc.\"")
        end
        if get_flag(0x0105) and not get_flag(0x0217) then
            add_dialogue("\"They brought thee to us as they were on their way here to Paws, but they have since left for Jhelom.\"")
            set_flag(0x0217, true)
        end
        if get_flag(0x0217) and not get_flag(0x016B) then
            add_dialogue("\"They brought thee here along their way to Jhelom.\"")
        end
        if get_flag(0x016B) and not get_flag(0x0088) then
            add_dialogue("\"They brought thee here along their way to Britain.\"")
        end
        if get_flag(0x0088) and not get_flag(0x0284) then
            add_dialogue("\"They brought thee here along their way to Vesper.\"")
        end
        if get_flag(0x0284) and not get_flag(0x01EF) then
            add_dialogue("\"They brought thee here along their way to Moonglow.\"")
        end
        if get_flag(0x01EF) and not get_flag(0x0243) then
            add_dialogue("\"They brought thee here along their way to Terfin.\"")
        end
        if get_flag(0x0243) and not get_flag(0x0264) then
            add_dialogue("\"They brought thee here along their way to the Fellowship meditation retreat near Serpent's Hold.\"")
        end
        if get_flag(0x0264) and not get_flag(0x02A8) then
            add_dialogue("\"They brought thee here along their way to Buccaneer's Den.\"")
        end
        if get_flag(0x02A8) then
            add_dialogue("\"They brought thee here and then returned to Buccaneer's Den.\"")
        end
    end
    if get_flag(0x0026) then
        add_dialogue("\"It is truly mysterious how this continues to happen to thee!\"")
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end