require "U7LuaFuncs"
-- Handles a confrontation scene where Fellowship members (Hook, Forskis, Abraham, Elizabeth) sentence the Avatar to death, adjusting NPC alignments and triggering actions.
function func_0608(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    if eventid ~= 3 then
        return
    end

    set_schedule(-26, 13)
    local0 = is_player_female()
    switch_talk_to(-26, 0)
    say("\"Avatar! Stop where thou art! Thou shalt not succeed in thy quest to destroy the Black Gate! Art thou mad??! The Guardian is much too powerful for thee! He shall crush thee like an insect! The fate of Britannia now belongs to him and to The Fellowship! The Guardian is the land's true ruler! Bow down to him, Avatar, and perhaps he shall give thee a place at his side. Bow down to him -now-!\"*")
    hide_npc(-26)

    if local0 then
        local1 = "She"
        local2 = "her"
        local3 = "her"
    else
        local1 = "He"
        local2 = "his"
        local3 = "him"
    end

    switch_talk_to(-273, 0)
    say("Hook points to you.")
    say("\"I say -kill- the Avatar! " .. local1 .. " is dangerous! Cut " .. local2 .. " throat! I say we attack -now-!\"*")
    hide_npc(-273)

    switch_talk_to(-274, 0)
    say("Forskis shouts, \"To kill! To kill!\"*")
    hide_npc(-274)

    switch_talk_to(-275, 0)
    say("Abraham yells, \"Let us make fish bait out of " .. local3 .. "!\"*")
    hide_npc(-275)

    switch_talk_to(-276, 0)
    say("\"Death to the Avatar! Long live The Guardian!\" screams Elizabeth.*")
    hide_npc(-276)

    switch_talk_to(-26, 0)
    say("\"So be it! The Fellowship hereby sentences the Avatar to immediate death! Kill " .. local3 .. " now!\"*")
    hide_npc(-26)

    local4 = {881, 882, 805, 506, 403}
    for local6 in ipairs(local4) do
        local7 = local6
        local8 = add_item(0, 30, local7, itemref)
    end

    for local10 in ipairs(local4) do
        local11 = local10
        apply_effect(0, local11) -- Unmapped intrinsic
    end

    apply_effect(10000) -- Unmapped intrinsic
    return
end