-- Function 06F8: Manages Forge entry and Erethian's spell mishap
function func_06F8(eventid, itemref)
    -- Local variables (49 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14, local15, local16, local17, local18, local19
    local local20, local21, local22, local23, local24, local25, local26, local27, local28, local29
    local local30, local31, local32, local33, local34, local35, local36, local37, local38, local39
    local local40, local41, local42, local43, local44, local45, local46, local47, local48

    if eventid == 3 then
        local0 = call_GetItemQuality(itemref)
        if local0 == 0 then
            local1 = callis_000E(10, 848, itemref)
            local2 = call_GetItemFrame(local1)
            if local2 ~= 9 then
                _SetItemFrame(3, local1)
            end
        elseif local0 == 1 then
            local3 = callis_0035(0, 1, 726, itemref)
            if not local3 then
                set_flag(0x033F, true)
            else
                set_flag(0x033F, false)
            end
            if not (get_flag(0x033F) and get_flag(0x033C)) then
                return
            end
        elseif local0 == 2 then
            local3 = callis_0035(0, 1, 726, itemref)
            if not local3 then
                set_flag(0x033C, true)
            else
                set_flag(0x033C, false)
            end
            if not (get_flag(0x033C) and get_flag(0x033F)) then
                return
            end
        elseif local0 == 4 and not (get_flag(0x033C) and get_flag(0x033F)) then
            return
        end

        local4 = callis_000E(10, 990, itemref)
        if not local4 then
            return
        end

        local5 = callis_0018(local4)
        local6 = callis_0035(0, 1, 955, local4)
        local7 = 0
        while sloop() do
            local10 = local6
            local11 = call_GetItemFrame(local10)
            local12 = callis_0018(local10)
            if local11 == 8 and local12[1] == local5[1] - 1 and local12[2] == local5[2] and local12[3] == 4 then
                local7 = local7 + 1
            elseif local11 == 9 and local12[1] == local5[1] and local12[2] == local5[2] - 1 and local12[3] == 4 then
                local7 = local7 + 1
            elseif local11 == 10 and local12[1] == local5[1] and local12[2] == local5[2] and local12[3] == 4 then
                local7 = local7 + 1
            end
        end

        if local7 == 3 then
            local13 = false
            local14 = callis_0035(0, 40, 435, callis_001B(-356))
            while sloop() do
                local17 = local14
                local18 = callis_0018(local17)
                if (local18[1] == 2208 or local18[1] == 2221) and local18[2] == 1514 and local18[3] == 1 then
                    local13 = local13 + 1
                end
            end

            if local13 == 2 then
                call_087DH()
                local19 = callis_0018(callis_001B(-356))
                if local19[2] > local5[2] then
                    if not _IsPlayerFemale() then
                        _SetItemFrame(20, call_0881H())
                    else
                        _SetItemFrame(18, call_0881H())
                    end
                else
                    if not _IsPlayerFemale() then
                        _SetItemFrame(21, call_0881H())
                    else
                        _SetItemFrame(19, call_0881H())
                    end
                end
                local20 = callis_0024(955)
                _SetItemFrame(7, local20)
                _SetItemFrame(1, local4)
                local21 = {local5[1] - 1, local5[2] - 1, local5[3] + 2}
                callis_0026(local21)
                callis_0053(-1, 0, 0, 0, local5[2] - 2, local5[1] - 2, 7)
                call_000FH(68)
                local22 = callis_0001({1784, 17493, 7937, 31, 8006, 24, -1, 17419, 8014, 5, 7750}, local4)
            end
        end
    elseif eventid == 2 then
        if not get_flag(0x030C) then
            if not get_flag(0x02EE) then
                call_08FFH("@'Tis sad that Erethian's lust for power has brought him to this evil pass.@")
                call_08FFH("@Perhaps, at last, he is at rest.@")
            end
            if not callis_0037(-23) then
                call_08FFH("@I am sure that Lord British even now awaits news of Exodus' exile.@")
            end
            call_08FFH("@It is time to leave this barren island behind.@")
            abort()
        end

        local5 = callis_0018(itemref)
        local13 = callis_0018(callis_001B(-356))
        if get_flag(0x033F) and get_flag(0x033C) then
            if not get_flag(0x02EE) then
                local23 = false
                local24 = false
                local25 = callis_0035(8, 80, 154, itemref)
                while sloop() do
                    if not call_GetContainerItems(4, 240, 797, local28) then
                        local23 = local28
                        local29 = callis_0018(local23)
                        if callis_0019(itemref, local23, itemref) <= 8 then
                            callis_0053(-1, 0, 0, 0, local29[2] - 1, local29[1] - 1, 13)
                            call_08E6H(local23)
                        else
                            local24 = local23
                        end
                    end
                end
                if not local24 then
                    local24 = callis_0024(154)
                    _SetItemFrame(18, local24)
                    local30 = callis_0018(callis_001B(-356))
                    if local30[2] > local13[2] then
                        _SetItemFrame(19, local24)
                        local31 = {1510, local30[2], local30[1] - 1}
                    else
                        _SetItemFrame(3, local24)
                        local31 = {1518, local30[2], local30[1] - 1}
                    end
                    callis_0026(local31)
                    callis_0053(-1, 0, 0, 0, local31[2] - 1, local31[1] - 1, 13)
                    local16 = callis_0001({8048, 5, 8487, local31[2], 7769}, local24)
                end
                callis_0059(1)
                callis_0053(-1, 0, 0, 0, local13[2], local13[1], 17)
                call_000FH(62)
                set_flag(0x033C, false)
                callis_0002(7, {1784, 7765}, itemref)
                abort()
            end

            switch_talk_to(286, 1)
            add_dialogue("\"No! Thou must not do this!\" Erethian's voice is full of anguish. He raises his arms and begins a powerful spell.")
            add_dialogue("\"Vas Ort Rel Tym...\"")
            add_dialogue("He stops mid-spell and begins another, pointing towards the Talisman of Infinity.")
            add_dialogue("\"Vas An Ort Ailem!\"")
            add_dialogue("You immediately recognize the resonance of a spell gone awry, and apparently so does Erethian. A look of horror comes to his wrinkled features which appear to become more lined by the second.*")
            local28 = callis_000E(10, 154, itemref)
            local16 = callis_0001({8045, 2, 17447, 8044, 2, 7719}, local28)
            callis_0059(1)
            local34 = callis_0035(16, 10, 275, itemref)
            while sloop() do
                local37 = local34
                if call_GetItemFrame(local37) == 7 and call_GetItemQuality(local37) == 1 then
                    local38 = callis_0018(local37)
                    callis_0053(3, 0, 0, 0, local38[2], local38[1], 17)
                end
            end
            callis_0053(-1, 0, 0, 0, local5[2] - 2, local5[1] - 2, 17)
            set_flag(0x033F, false)
            set_flag(0x033C, true)
            callis_0002(7, {1784, 7765}, itemref)
            abort()
        elseif not get_flag(0x02EE) then
            local28 = callis_000E(10, 528, itemref)
            local39 = callis_006B(local28)
            local40 = callis_0024(892)
            _SetItemFrame(18, local40)
            callis_006C(local39, local40)
            callis_0026(callis_0018(local28))
            call_08E6H(local28)
        else
            local28 = callis_000E(10, 528, itemref)
            local41 = call_GetItemFrame(local28)
            local42 = callis_0024(892)
            _SetItemFrame(18, local42)
            if local41 == 12 then
                _SetItemFrame(14, local42)
            elseif local41 == 28 then
                _SetItemFrame(22, local42)
            end
            callis_0026(callis_0018(local28))
            set_flag(0x02EE, true)
            _PlayMusic(0, 17)
            callis_0053(-1, 0, 0, 0, local5[2] - 2, local5[1] - 2, 17)
            callis_0053(-1, 0, 0, 0, local5[2] - 2, local5[1] - 2, 8)
            call_000FH(9)
            local43 = callis_0035(0, 1, 955, itemref)
            while sloop() do
                local46 = local43
                local47 = call_GetItemFrame(local46)
                if local47 == 7 then
                    callis_006F(local46)
                elseif local47 == 8 then
                    callis_006F(local46)
                elseif local47 == 9 then
                    callis_006F(local46)
                elseif local47 == 10 then
                    callis_006F(local46)
                end
            end
            callis_008A(16, callis_001B(-356))
            local48 = call_0881H()
            callis_0002(14, {17453, 7724}, local48)
            local16 = callis_0001({1693, 8021, 12, 7719}, callis_001B(-356))
            local49 = callis_000E(10, 726, itemref)
            if not local49 then
                local16 = callis_0001({1784, 8021, 16, 7719}, local49)
            end
            callis_006F(itemref)
            set_flag(0x030C, true)
        end
    end

    return
end

-- Helper functions
function sloop()
    return false -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end

function add_dialogue(...)
    print(table.concat({...}))
end

function call_08FFH(message)
    print(message) -- Placeholder
end

function abort()
    -- Placeholder
end