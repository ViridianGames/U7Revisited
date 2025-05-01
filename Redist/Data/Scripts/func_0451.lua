-- func_0451.lua
-- Wislem's dialogue as a mage advisor in Castle British


function func_0451(eventid)
    local answers = {}
    local flag_00C7 = get_flag(0x00C7) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00D6 = get_flag(0x00D6) -- Magic topic
    local npc_id = -70 -- Wislem's NPC ID

    if eventid == 1 then
        _SwitchTalkTo(0, npc_id)
        local var_0000 = call_extern(0x0909, 0) -- Unknown interaction
        local var_0001 = call_extern(0x090A, 1) -- Item interaction
        local var_0002 = call_extern(0x0919, 2) -- Fellowship interaction
        local var_0003 = call_extern(0x091A, 3) -- Philosophy interaction
        local var_0004 = call_extern(0x092E, 4) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00D6 then
            add_answer( "magic")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00C7 then
            add_dialogue("You see a robed figure with a staff, surrounded by flickering arcane runes.")
            set_flag(0x00C7, true)
        else
            add_dialogue("\"Greetings, \" .. get_player_name() .. \",\" Wislem says, his eyes glowing faintly.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Wislem dismisses a rune. \"What wisdom dost thou seek?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Wislem, mage advisor to Lord British, guardian of Britannia’s arcane secrets.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I counsel Lord British on matters of magic and guard the ether’s balance. The Fellowship’s rise disrupts this balance, troubling me greatly.\"")
                add_answer( "magic")
                add_answer( "Fellowship")
                set_flag(0x00D6, true)
            elseif choice == "magic" then
                add_dialogue("\"The ether flows unevenly, as Rudyom’s research into blackrock confirms. The Fellowship’s meddling with magical forces risks chaos.\"")
                add_answer( "blackrock")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("magic")
            elseif choice == "blackrock" then
                add_dialogue("\"Blackrock, a mineral of great power, is studied by mages like Rudyom. Its misuse could unravel the ether. I suspect the Fellowship covets it.\"")
                add_answer( "Fellowship")
                remove_answer("blackrock")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship speaks of harmony, but their rituals hint at tampering with the ether. Their secrecy mirrors forbidden cults of old—thou must uncover their intent, Avatar.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou believest in their cause? I’ll study their rites, but with care.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Thy vigilance is wise. Probe their secrets, lest Britannia’s magic falters.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"May the ether guide thee, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0451