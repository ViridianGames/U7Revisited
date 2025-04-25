-- Handles Forsythe's decision to sacrifice himself, with party size checks.
function func_088A()
    local local0, local1, local2, local3, local4

    local0 = external_0909H() -- Unmapped intrinsic
    say("After learning that none of the townsfolk are willing to sacrifice themselves for a greater good, an odd light comes into Forsythe's eyes. His chin firms and his shoulders square.~~\"Well, then. It has got to be done! And since no other brave soul will do it, perhaps I shall have to show them all what real courage is.\" He strides forward like a lord and plants his feet. \"Please be kind enough to lead me to the well, " .. local0 .. ".\"*")
    remove_answer("sacrifice") -- Unmapped intrinsic
    local1 = 0
    local2 = get_party_members()
    local3 = external_001BH(-8) -- Unmapped intrinsic
    local4 = external_001BH(-9) -- Unmapped intrinsic
    for local5 in ipairs(local2) do
        local6 = local5
        local7 = local6
        local1 = local1 + 1
    end
    if local1 < 8 then
        say("He steps in line and motions for you to lead on.*")
        external_001EH(-147) -- Unmapped intrinsic
        set_flag(408, false)
        abort()
    else
        say("\"Thou hast so many companions that I may not follow thee at this time.\"")
        abort()
    end
    return
end