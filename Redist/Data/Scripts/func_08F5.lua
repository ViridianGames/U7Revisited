-- Manages NPC greetings, with special dialogue for specific party members.
function func_08F5(p0, p1)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15

    save_answers() -- Unmapped intrinsic
    local2 = "nobody"
    local3 = {}
    for local4, local5 in ipairs(p1) do
        local6 = local5
        table.insert(local3, get_player_name(local6)) -- Unmapped intrinsic
    end
    table.insert(local3, local2)
    local7 = false
    local8 = #local3
    if local8 > 1 then
        local9 = external_090CH(local3) -- Unmapped intrinsic
        if local9 == local8 then
            return
        end
        local10 = local3[local9]
        local11 = local10 == local2 and 0 or p1[local9]
        local0 = external_093CH(p0, local10) -- Unmapped intrinsic
        local3 = external_093CH(local3, local9) -- Unmapped intrinsic
        local12 = false
        if local11 == -1 then
            say("\"Thy good health, sir. Many campaigns sit upon thy brow. It is an honor.\"")
            switch_talk_to(1, 0)
            say("\"Avatar, this stranger grows upon me by the moment. Surely he would be a boon travelling companion.\"")
            local13 = 0
            if not external_08F7H(-3) then -- Unmapped intrinsic
                local13 = -3
            end
            if not external_08F7H(-4) then -- Unmapped intrinsic
                local13 = -4
            end
            if local13 ~= 0 then
                switch_talk_to(local13, 0)
                say("\"Oh, please.\"")
                switch_talk_to(1, 0)
                local14 = external_090FH(local13) -- Unmapped intrinsic
                say("\"Hush, " .. local14 .. ".\"")
            end
            switch_talk_to(10, 0)
            local12 = true
            local7 = true
        elseif local11 == -3 then
            say("\"How art thou, Shamino? Thy woodcraft is renowned in Britannia.\"")
            switch_talk_to(3, 0)
            say("\"Renown follows those who travel with the Avatar. I thank thee.\"")
            switch_talk_to(10, 0)
            local12 = true
            local7 = true
        elseif local11 == -2 then
            say("\"Greetings young man. How comes one so young into such company?\"")
            switch_talk_to(2, 0)
            say("\"I am an orphan! My father has been most cruelly murdered, mutilated in the stables of Trinsic.\"")
            switch_talk_to(10, 0)
            say("\"That is a grievous tale! But surely the time for grief is past. Thou art in the company of great companions.\"")
            switch_talk_to(2, 0)
            say("\"Thou speakest rightly. I shall bring my father's murderer to justice or die in the attempt.\"")
            switch_talk_to(10, 0)
            local12 = true
        end
        if not local12 then
            local14 = external_090FH(local10) -- Unmapped intrinsic
            say("\"Greetings " .. local14 .. ".\"")
            local15 = {"May good fortune be thine.", "Good health to thee.", "Thou art looking quite well today."}
            say("\"" .. local15[get_random(1, 3)] .. "\"")
            switch_talk_to(local11, 0)
            say("\"Glad to make thine aquaintance.\"")
            switch_talk_to(10, 0)
            local12 = true
        end
        if local7 and not get_flag(353) then
            say("\"But did I hear thee say 'Avatar?' Say not that thy leader is the one -true- Avatar!\"")
            switch_talk_to(local11, 0)
            say("\"It is indeed true.\"")
            switch_talk_to(10, 0)
            say("\"'Tis an honor to meet thee, Avatar.\"")
            set_flag(353, true)
        end
        hide_npc(local11)
        local8 = #local3
    end
    restore_answers() -- Unmapped intrinsic
    if local8 == 1 then
        set_flag(351, true)
    end
    return local0
end