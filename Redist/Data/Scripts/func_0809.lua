-- Function 0809: Handle cart interaction
function func_0809(eventid, itemref)
    local local0, local1, local2, local3, local4

    local1 = check_sitting(eventid)
    if not local1 then
        if call_0088H(10, eventid) then
            call_008AH(10, eventid)
            call_008AH(26, eventid)
            call_0904H("@Whoa!@", -356)
        else
            local2 = check_position(0, 16, 796, eventid)
            if not local2 then
                local3 = check_gold(-359, _GetItemQuality(local2), 797, -357)
                if not local3 then
                    if call_080DH() then
                        call_0089H(10, eventid)
                        call_0089H(26, local1)
                        call_0904H("@Giddy-up!@", -356)
                    else
                        local4 = call_08B3H(eventid)
                    end
                else
                    if _ArraySize(_GetPartyMembers()) == 1 then
                        say(itemref, "@The title for this cart must first be purchased.@")
                    else
                        say(itemref, "@We must first purchase the title for this cart.@")
                    end
                end
            end
        end
    end
end