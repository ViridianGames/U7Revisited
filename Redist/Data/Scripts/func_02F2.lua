-- Function 02F2: Horance transformation from liche to ghost
function func_02F2(eventid, itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid ~= 1 then
        return
    end

    if _GetItemFrame(itemref) == 5 then
        local0 = _ItemSelectModal()
        local1 = _GetItemType(local0)
        if get_flag(0x01AF) or local1 == 519 or local1 == 747 then
            local2 = callis_0035(0, 40, 747, itemref)
            if not local2 then
                local3 = callis_0001({7981, 9, 8024, 7, -4, 7947, 37, 8024, 2, 7975, 45, 8024, 1, 7750}, local2)
                local4 = callis_0018(local2)
                local3 = callis_0053(-1, 0, 0, 0, local4[2] - 3, local4[1] - 2, 12)
                calli_006F(itemref)
            end
            local3 = callis_0001({754, 8021, 28, 7719}, -356)
            switch_talk_to(141, 1)
            add_dialogue("As the Soul Cage dissolves into dust, a great transformation comes upon the Liche. Where the evil spirit was caged you see the form of a familiar person. It's Horance! He's a ghost, but he much more resembles a man than an undead terror.")
            call_08ADH()
        end
    end

    return
end

-- Helper functions
function add_dialogue(message)
    print(message)
end

function get_flag(flag)
    return false -- Placeholder
end