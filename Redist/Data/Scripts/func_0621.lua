-- Manages party member banter, delivering location-specific or context-sensitive dialogue during exploration.
function func_0621(eventid, itemref)
    local local0, local1, local2, local3, local4

    if eventid ~= 3 then
        return
    end

    local0 = ""
    local1 = get_item_quality(itemref)
    local2 = itemref
    local3 = 0

    if local1 == 0 then
        local0 = "@Welcome, Avatar.@"
        local3 = 0
    elseif local1 == 1 then
        if not get_flag(343) then
            local0 = "Perhaps thou shouldst use the crystal ball."
            local2 = -357
            local3 = 1
        else
            return
        end
    elseif local1 == 2 then
        local0 = "Are we there yet?"
        local2 = -2
        local3 = 0
    elseif local1 == 3 then
        local0 = "I could use a drink."
        local2 = -4
        local3 = 0
    elseif local1 == 4 then
        local0 = "I am too old for this."
        local2 = -1
        local3 = 0
    elseif local1 == 5 then
        local0 = "I heard something!"
        local2 = -357
        local3 = 0
    elseif local1 == 6 then
        local0 = "Oh no! Not more rain!"
        local2 = -1
        local3 = 0
    elseif local1 == 7 then
        local0 = "We could use swamp boots!"
        local2 = -1
        local3 = 0
    elseif local1 == 8 then
        local0 = "When can we rest?"
        local2 = -2
        local3 = 0
    elseif local1 == 9 then
        local0 = "This is Dungeon Destard."
        local2 = -3
        local3 = 0
    elseif local1 == 10 then
        local0 = "This is Dungeon Despise."
        local2 = -3
        local3 = 0
    elseif local1 == 11 then
        local0 = "This is Dungeon Deceit."
        local2 = -3
        local3 = 0
    elseif local1 == 12 then
        local0 = "This is Bee Cave."
        local2 = -3
        local3 = 0
    elseif local1 == 13 then
        local0 = "This is the Minoc Mine."
        local2 = -3
        local3 = 0
    elseif local1 == 14 then
        local0 = "This is the Vesper Mine."
        local2 = -3
        local3 = 0
    elseif local1 == 15 then
        local0 = "This looks interesting."
        local2 = -3
        local3 = 0
    elseif local1 == 16 then
        local0 = "This place is creepy."
        local2 = -357
        local3 = 0
    elseif local1 == 17 then
        local0 = "Wow...!"
        local2 = -357
        local3 = 0
    elseif local1 == 18 then
        local0 = "Let's sing a sea shanty!"
        local2 = -1
        local3 = 0
    elseif local1 == 19 then
        local0 = "Let us win some gold!"
        local2 = -4
        local3 = 0
    elseif local1 == 20 then
        local0 = "Avatar, they are doing a play about thee!"
        local2 = -1
        local3 = 1
    elseif local1 == 21 then
        local0 = "Britain sure is big!"
        local2 = -2
        local3 = 0
    elseif local1 == 22 then
        local0 = "Be most careful. Who knows what may be lurking amongst the trees..."
        local2 = -357
        local3 = 1
    elseif local1 == 23 then
        local0 = "Brushed up on thy Gargish?"
        local2 = -357
        local3 = 0
    elseif local1 == 24 then
        local0 = "Real fighters live here!"
        local2 = -4
        local3 = 0
    elseif local1 == 25 then
        local0 = "Thy old relics are here!"
        local2 = -1
        local3 = 0
    elseif local1 == 26 then
        local0 = "That bread smells good..."
        local2 = -2
        local3 = 0
    elseif local1 == 27 then
        local0 = "That food smells good..."
        local2 = -2
        local3 = 0
    elseif local1 == 28 then
        local0 = "That fruit looks good..."
        local2 = -2
        local3 = 0
    elseif local1 == 29 then
        local0 = "I am getting sleepy..."
        local2 = -2
        local3 = 0
    elseif local1 == 30 then
        local0 = "The Shrine of Compassion!"
        local2 = -3
        local3 = 0
    elseif local1 == 31 then
        local0 = "The Shrine of Honesty!"
        local2 = -3
        local3 = 0
    elseif local1 == 32 then
        local0 = "The Shrine of Justice!"
        local2 = -3
        local3 = 0
    elseif local1 == 33 then
        local0 = "The Shrine of Spirituality!"
        local2 = -3
        local3 = 0
    elseif local1 == 34 then
        local0 = "The Shrine of Honor!"
        local2 = -3
        local3 = 0
    elseif local1 == 35 then
        local0 = "The Shrine of Valor!"
        local2 = -3
        local3 = 0
    elseif local1 == 36 then
        local0 = "The Shrine of Sacrifice!"
        local2 = -3
        local3 = 0
    elseif local1 == 37 then
        local0 = "The Shrine of Humility!"
        local2 = -3
        local3 = 0
    elseif local1 == 38 then
        local0 = "Watch for bridge trolls."
        local2 = -357
        local3 = 0
    elseif local1 == 39 then
        local0 = "Ah, home sweet home."
        local2 = -1
        local3 = 0
    elseif local1 == 40 then
        local0 = "The noise! Agh! It hurts!"
        local2 = -357
        local3 = 0
    elseif local1 == 41 then
        if not check_item(-359, 0, 981, 1, -357) and get_flag(4) then
            local0 = "You left the small sphere!"
            local2 = -357
            local3 = 1
        else
            return
        end
    elseif local1 == 42 then
        if not check_item(-359, 1, 981, 1, -357) and get_flag(5) then
            local0 = "You left the small cube!"
            local2 = -357
            local3 = 1
        else
            return
        end
    elseif local1 == 43 then
        if not check_item(-359, 2, 981, 1, -357) and get_flag(3) then
            local0 = "You left the small tetrahedron!"
            local2 = -357
            local3 = 1
        else
            return
        end
    end

    if local2 == -357 then
        local2 = get_player_name()
        if local2 == -356 then
            return
        end
    end

    if local3 == 0 then
        local0 = "@" .. local0 .. "@"
        local4 = switch_talk_to(local2)
        if local4 then
            item_say(local0, local2)
        end
    else
        local4 = switch_talk_to(local2)
        if local4 then
            switch_talk_to(local2, 0)
            say(local0)
            hide_npc(local2)
        end
    end

    return
end