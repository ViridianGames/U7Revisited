-- Manages a shop for spell scrolls by magic circle.
function func_094C()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    save_answers() -- Unmapped intrinsic
    local0 = true
    local1 = {140, 120, 90, 70, 50, 30}
    while local0 do
        say("\"To be interested in which circle?\"")
        local2 = external_090CH({"Sixth", "Fifth", "Fourth", "Third", "Second", "First", "none"}) -- Unmapped intrinsic
        local2 = local2 - 1
        if local2 == 0 then
            if get_flag(3) then
                say("\"To wonder why you bother me so!\"")
            else
                say("\"To understand.\"")
            end
            break
        elseif local2 == 1 then
            local3 = {"Light", "Locate", "Great Douse", "Great Ignite", "nothing"}
            local4 = {13, 14, 11, 12, 0}
        elseif local2 == 2 then
            local3 = {"Great Light", "Destroy Trap", "Enchant", "Fire Blast", "nothing"}
            local4 = {19, 16, 17, 18, 0}
        elseif local2 == 3 then
            local3 = {"Swarm", "Curse", "Poison", "Paralyze", "nothing"}
            local4 = {26, 24, 30, 28, 0}
        elseif local2 == 4 then
            local3 = {"Conjure", "Reveal", "Mass Curse", "Lightning", "nothing"}
            local4 = {32, 37, 35, 33, 0}
        elseif local2 == 5 then
            local3 = {"Fire Field", "Dispel Field", "Explosion", "Mass Sleep", "nothing"}
            local4 = {46, 42, 43, 47, 0}
        else
            local3 = {"Tremor", "Flame Strike", "Clone", "Fire Ring", "nothing"}
            local4 = {55, 51, 49, 50, 0}
        end
        say("\"To buy which spell?\"")
        local5 = external_090CH(local3) -- Unmapped intrinsic
        local6 = local4[local5]
        local7 = local1[local2]
        local8 = local3[local5]
        say("\"To cost " .. local7 .. " gold for " .. local8 .. " spell.\"")
        local9 = external_0924H(local7, local6) -- Unmapped intrinsic
        if local9 == 1 then
            say("\"To agree!\"")
        elseif local9 == 2 then
            say("\"To be without a spellbook, human.\"")
            local0 = false
        elseif local9 == 3 then
            say("\"To have not have enough gold for that!\"")
        elseif local9 == 4 then
            say("\"To see you already have that spell.\"")
        end
        say("\"To be interested in another spell?\"")
        local0 = external_090AH() -- Unmapped intrinsic
    end
    restore_answers() -- Unmapped intrinsic
    return
end