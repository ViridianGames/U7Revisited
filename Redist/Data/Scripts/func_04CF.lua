require "U7LuaFuncs"
-- Function 04CF: Yongi's bartender dialogue and anti-gargoyle stance
function func_04CF(eventid, itemref)
    -- Local variables (14 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    if eventid == 0 then
        local10 = callis_003B()
        local11 = callis_001C(callis_001B(-207))
        local12 = callis_Random2(4, 1)
        local13 = ""
        if local10 >= 1 and local10 <= 3 and local11 == 14 then
            local13 = "Zzzzz . . ."
        elseif local10 >= 4 and local10 <= 7 or local10 == 0 then
            if local11 == 11 then
                if local12 == 1 then
                    local13 = "Refreshments here!"
                elseif local12 == 2 then
                    local13 = "Get a fine cup o' wine here!"
                elseif local12 == 3 then
                    local13 = "We have the best spirits here!"
                elseif local12 == 4 then
                    local13 = "No gargoyles allowed!"
                end
            end
        end
        _ItemSay(local13, -207)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -207)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = "the Avatar"
    local3 = call_08F7H(-4)
    local4 = false
    local5 = false
    local6 = false
    _AddAnswer({"bye", "job", "name"})

    if local3 then
        say("\"Ah, me good friend, Dupre. What kinna do fer ye this fine day?\"")
        _SwitchTalkTo(0, -4)
        say("\"Ah, master Yongi, always ready to offer a tankard of thy finest.\"")
        _HideNPC(-4)
        _SwitchTalkTo(0, -207)
    end

    if not get_flag(0x028C) then
        say("Tending the bar is a jovial-looking man. \"Welcome ta the Gilded Lizard.\"")
        local6 = true
        set_flag(0x028C, true)
    else
        say("\"Welcome back ta the Gilded Lizard. What may I do fer ye?\" asks Yongi.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"Me name is Yongi, ", local1, ".\"")
            _RemoveAnswer("name")
            if not local6 then
                say("\"And ye are?\"")
                local7 = call_090BH({local1, local2, local0})
                if local7 == local2 then
                    say("\"Aye, ", local1, ". Right ye are. If ye dinna care ta tell me, I don't mind a bit.\" He winks.")
                elseif local7 == local0 then
                    say("\"Welcome ta me tavern, ", local0, ".\"")
                elseif local7 == local1 then
                    say("\"Right ye are, ", local1, ". There's no need ta tell anyone yer name.\"")
                end
            end
        elseif answer == "job" then
            say("\"Why, I tend me bar. And lend me ear ta the customers,\" he adds, touching his right ear for emphasis.")
            _AddAnswer({"buy", "customers"})
        elseif answer == "Vesper" then
            say("\"Why, I wouldna wanna live anyplace else. 'Course, this town would be a better place if we could rid ourselves of those jackals, the gargoyles.\"")
            if not local5 then
                _AddAnswer("gargoyles")
            end
            _RemoveAnswer("Vesper")
        elseif answer == "gargoyles" then
            say("\"Gargoyles! What about them? They be the vilest, evilest, cruelest, most despicable things ever ta crawl upon this great land. I kinna tell ye too well ta stay away from them. I kin only imagine whata fine town this'd be if there weren't na more gargoyles. 'Course, I know those dogs are probably sayin' the same about us. Everybody knows they're gonna come an' kill allus in our sleep one evenin'.\"")
            if not local4 then
                say("\"Why, only the other day one attacked Blorn. G'won, ask him about it.\"")
                local4 = true
                _AddAnswer("Blorn")
            end
            local5 = true
            set_flag(0x0283, true)
            _RemoveAnswer("gargoyles")
        elseif answer == "customers" then
            say("\"Well, all I really know in Vesper are me regulars: Cador, Mara, and Blorn. Ye might be wantin' ta talk to Auston, the mayor, or his clerk, Liana. Ah, now there's a fine, young lass.\" He winks at you.")
            _AddAnswer({"Vesper", "Blorn", "Mara", "Cador"})
            _RemoveAnswer("customers")
        elseif answer == "Cador" then
            local8 = callis_0037(callis_001B(-203))
            if local8 then
                say("\"He be in here every night after work. Good man, hard worker.\"")
            else
                say("\"He used ta come here every night, 'til he was killed in a brawl.\" The bartender's eyes narrow as he talks.")
            end
            _RemoveAnswer("Cador")
        elseif answer == "Mara" then
            local9 = callis_0037(callis_001B(-204))
            if local9 then
                say("\"She works with Cador at the mines. Hard as stone, that one. She be more man than most of the men in town.\"")
            else
                say("\"She worked with Cador at the mines. She was more man than most men, that one was. An' she died like it, too -- in a brawl here at the tavern!\" He says, eyeing you suspiciously.")
            end
            _RemoveAnswer("Mara")
        elseif answer == "Blorn" then
            say("\"There be one who knows what's what. He knows what be wrong with this town! Gargoyles! That is what be wrong. He hates 'em, 'e does.\"")
            if not local4 then
                say("\"He was even accosted by one of those jackals not too long ago. Ask 'im about it, why don't ye.\"")
                local4 = true
            end
            if not get_flag(0x0283) and not local5 then
                _AddAnswer("gargoyles")
            end
            set_flag(0x0283, true)
            _RemoveAnswer("Blorn")
        elseif answer == "buy" then
            say("\"Be ye wantin' food or drink?\"")
            _AddAnswer({"food", "drink"})
            _RemoveAnswer("buy")
        elseif answer == "food" then
            call_094DH()
            _RemoveAnswer("food")
        elseif answer == "drink" then
            call_094EH()
            _RemoveAnswer("drink")
        elseif answer == "bye" then
            say("\"May the road rise up ta meet ye!\"*")
            return
        end
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end