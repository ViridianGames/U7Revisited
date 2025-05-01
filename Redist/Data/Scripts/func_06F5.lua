-- Function 06F5: Manages Erethian's sword handoff
function func_06F5(eventid, itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    switch_talk_to(286, 1)
    add_dialogue("Erethian's face begins to take on an ashen palor, but he looks contented with a job well done. \"As I have said, I myself once attempted to create an artifact of great power. I crafted the hilt from a dark substance that is immutable, save by magical means. The blade, however, is cast of an alloy of this substance and the purest metals known to Britannia. My artistic skills served me well enough to fashion the hilt but, alas, the strength was not in my arm to beat a good temper into the blade. Perhaps, thou canst finish this great artifact for me...\" He pulls a poorly worked blade with a fine hilt out of thin air. \"Fear not to touch the hilt when the blade is hot, for heat apparently does not travel well across the medium of the pure, black substance. I wish thee good luck.\"")

    local0 = callis_0024(668)
    _SetItemFrame(13, local0)
    local1 = callis_0036(callis_001B(-356))
    if not local1 then
        add_dialogue("He hands the sword to you and wearily turns away.*")
    else
        add_dialogue("He places the sword upon the firepit and wearily turns away.*")
        local2 = callis_000E(10, 739, itemref)
        local3 = callis_0018(local2)
        local4 = {local3[2] - 1, local3[1] + 2, local3[3] + 2}
        callis_0026(local4)
    end

    _HideNPC(-286)
    callis_001D(29, callis_001B(-356))
    callis_008A(16, callis_001B(-356))
    local5 = callis_0001({13, 7719}, itemref)
    local6 = call_0881H()
    local7 = callis_0002(13, {17453, 7724}, local6)
    local8 = callis_0001({1693, 8021, 11, 7719}, callis_001B(-356))
    set_flag(0x0312, true)

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function set_flag(flag, value)
    -- Placeholder
end