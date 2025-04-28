require "U7LuaFuncs"
-- Function 0880: Adjust item position
function func_0880(eventid, itemref)
    local local0, local1, local2

    local2 = _GetItemType(itemref)
    local3 = _GetItemFrame(itemref)
    local4 = eventid
    local4[1] = local4[1] + 1
    local4[2] = local4[2] + 1
    if not call_0085H(local3, local2, local4) then
        local4[1] = local4[1] + 1
        local4[2] = local4[2]
        if not call_0085H(local3, local2, local4) then
            local4[1] = local4[1]
            local4[2] = local4[2] + 1
            if not call_0085H(local3, local2, local4) then
                local4[1] = local4[1] + 1
                local4[2] = local4[2] - 1
                if not call_0085H(local3, local2, local4) then
                    local4[1] = local4[1] - 1
                    local4[2] = local4[2] + 1
                    if not call_0085H(local3, local2, local4) then
                        local4[1] = local4[1] + 1
                        local4[2] = local4[2] - 2
                        if not call_0085H(local3, local2, local4) then
                            local4[1] = local4[1] - 2
                            local4[2] = local4[2] + 1
                            if not call_0085H(local3, local2, local4) then
                                local4[1] = local4[1] + 1
                                local4[2] = local4[2] - 3
                                if not call_0085H(local3, local2, local4) then
                                    local4[1] = local4[1] - 3
                                    local4[2] = local4[2] + 1
                                    if not call_0085H(local3, local2, local4) then
                                        local4[1] = local4[1] + 1
                                        local4[2] = local4[2] - 4
                                        if not call_0085H(local3, local2, local4) then
                                            local4[1] = local4[1] - 4
                                            local4[2] = local4[2] + 1
                                            if not call_0085H(local3, local2, local4) then
                                                local4[1] = local4[1] + 1
                                                local4[2] = local4[2] + 1
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    call_003EH(local4, itemref)
    return
end