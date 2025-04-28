require "U7LuaFuncs"
-- Manages sword crafting outcomes, updating flags and displaying messages based on a random quality check.
function func_0691(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 2 then
        local0 = external_000EH(2, 668, -356) -- Unmapped intrinsic
        local1 = get_item_data(local0)
        local2 = add_item(itemref, {45, 7768})
        local2 = add_item(itemref, {1680, 8021, 1, 17447, 7715})
    elseif eventid == 1 then
        local3 = external_0000H(100) -- Unmapped intrinsic
        if not get_flag(813) then
            if local3 > 66 then
                set_flag(813, true)
                external_005AH() -- Unmapped intrinsic
                switch_talk_to(-356, external_005AH())
                say("After a short while you notice that the edge has definitely improved.")
                hide_npc(-356)
            end
        elseif not get_flag(814) then
            if local3 > 66 then
                set_flag(814, true)
                external_005AH() -- Unmapped intrinsic
                switch_talk_to(-356, external_005AH())
                say("You feel that you've done the best job that you can, but the sword doesn't feel quite right. It's much too heavy and cumbersome to wield as a weapon.")
                set_flag(823, true)
                hide_npc(-356)
            elseif local3 < 20 then
                set_flag(813, false)
                external_005AH() -- Unmapped intrinsic
                switch_talk_to(-356, external_005AH())
                say("That last blow was perhaps a bit too hard, It'll take a while to hammer out the flaws.")
                hide_npc(-356)
            end
        else
            external_005AH() -- Unmapped intrinsic
            switch_talk_to(-356, external_005AH())
            say("The blade has been worked as well as it can be. It will take some form of magic to make this sword blank into a usable weapon.")
            hide_npc(-356)
        end
    end
    return
end