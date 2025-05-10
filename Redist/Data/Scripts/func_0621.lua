--- Best guess: Handles party member banter for various locations (e.g., dungeons, shrines) and events, with checks for missing quest items (sphere, cube, tetrahedron).
function func_0621(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    start_conversation()
    if eventid == 3 then
        var_0000 = ""
        var_0001 = get_object_quality(objectref) --- Guess: Gets item quality
        var_0002 = objectref
        var_0003 = 0
        if var_0001 == 0 then
            var_0000 = "@Welcome, Avatar.@"
            var_0003 = 0
        elseif var_0001 == 1 then
            if not get_flag(343) then
                var_0000 = "Perhaps thou shouldst use the crystal ball."
                var_0002 = 357
                var_0003 = 1
            else
                abort()
            end
        elseif var_0001 == 2 then
            var_0000 = "Are we there yet?"
            var_0002 = 2
            var_0003 = 0
        elseif var_0001 == 3 then
            var_0000 = "I could use a drink."
            var_0002 = 4
            var_0003 = 0
        elseif var_0001 == 4 then
            var_0000 = "I am too old for this."
            var_0002 = 1
            var_0003 = 0
        elseif var_0001 == 5 then
            var_0000 = "I heard something!"
            var_0002 = 357
            var_0003 = 0
        elseif var_0001 == 6 then
            var_0000 = "Oh no! Not more rain!"
            var_0002 = 1
            var_0003 = 0
        elseif var_0001 == 7 then
            var_0000 = "We could use swamp boots!"
            var_0002 = 1
            var_0003 = 0
        elseif var_0001 == 8 then
            var_0000 = "When can we rest?"
            var_0002 = 2
            var_0003 = 0
        elseif var_0001 == 9 then
            var_0000 = "This is Dungeon Destard."
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 10 then
            var_0000 = "This is Dungeon Despise."
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 11 then
            var_0000 = "This is Dungeon Deceit."
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 12 then
            var_0000 = "This is Bee Cave."
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 13 then
            var_0000 = "This is the Minoc Mine."
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 14 then
            var_0000 = "This is the Vesper Mine."
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 15 then
            var_0000 = "This looks interesting."
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 16 then
            var_0000 = "This place is creepy."
            var_0002 = 357
            var_0003 = 0
        elseif var_0001 == 17 then
            var_0000 = "Wow...!"
            var_0002 = 357
            var_0003 = 0
        elseif var_0001 == 18 then
            var_0000 = "Let's sing a sea shanty!"
            var_0002 = 1
            var_0003 = 0
        elseif var_0001 == 19 then
            var_0000 = "Let us win some gold!"
            var_0002 = 4
            var_0003 = 0
        elseif var_0001 == 20 then
            var_0000 = "Avatar, they are doing a play about thee!"
            var_0002 = 1
            var_0003 = 1
        elseif var_0001 == 21 then
            var_0000 = "Britain sure is big!"
            var_0002 = 2
            var_0003 = 0
        elseif var_0001 == 22 then
            var_0000 = "Be most careful. Who knows what may be lurking amongst the trees..."
            var_0002 = 357
            var_0003 = 1
        elseif var_0001 == 23 then
            var_0000 = "Brushed up on thy Gargish?"
            var_0002 = 357
            var_0003 = 0
        elseif var_0001 == 24 then
            var_0000 = "Real fighters live here!"
            var_0002 = 4
            var_0003 = 0
        elseif var_0001 == 25 then
            var_0000 = "Thy old relics are here!"
            var_0002 = 1
            var_0003 = 0
        elseif var_0001 == 26 then
            var_0000 = "That bread smells good..."
            var_0002 = 2
            var_0003 = 0
        elseif var_0001 == 27 then
            var_0000 = "That food smells good..."
            var_0002 = 2
            var_0003 = 0
        elseif var_0001 == 28 then
            var_0000 = "That fruit looks good..."
            var_0002 = 2
            var_0003 = 0
        elseif var_0001 == 29 then
            var_0000 = "I am getting sleepy..."
            var_0002 = 2
            var_0003 = 0
        elseif var_0001 == 30 then
            var_0000 = "The Shrine of Compassion!"
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 31 then
            var_0000 = "The Shrine of Honesty!"
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 32 then
            var_0000 = "The Shrine of Justice!"
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 33 then
            var_0000 = "The Shrine of Spirituality!"
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 34 then
            var_0000 = "The Shrine of Honor!"
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 35 then
            var_0000 = "The Shrine of Valor!"
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 36 then
            var_0000 = "The Shrine of Sacrifice!"
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 37 then
            var_0000 = "The Shrine of Humility!"
            var_0002 = 3
            var_0003 = 0
        elseif var_0001 == 38 then
            var_0000 = "Watch for bridge trolls."
            var_0002 = 357
            var_0003 = 0
        elseif var_0001 == 39 then
            var_0000 = "Ah, home sweet home."
            var_0002 = 1
            var_0003 = 0
        elseif var_0001 == 40 then
            var_0000 = "The noise! Agh! It hurts!"
            var_0002 = 357
            var_0003 = 0
        elseif var_0001 == 41 then
            if not unknown_0931H(0, 359, 981, 1, 357) and get_flag(4) then
                var_0000 = "You left the small sphere!"
                var_0002 = 357
                var_0003 = 1
            else
                abort()
            end
        elseif var_0001 == 42 then
            if not unknown_0931H(1, 359, 981, 1, 357) and get_flag(5) then
                var_0000 = "You left the small cube!"
                var_0002 = 357
                var_0003 = 1
            else
                abort()
            end
        elseif var_0001 == 43 then
            if not unknown_0931H(2, 359, 981, 1, 357) and get_flag(3) then
                var_0000 = "You left the small tetrahedron!"
                var_0002 = 357
                var_0003 = 1
            else
                abort()
            end
        end
        if var_0002 == 357 then
            var_0002 = get_player_id()
            if var_0002 == 356 then
                abort()
            end
        end
        if var_0003 == 0 then
            var_0000 = "@" .. var_0000 .. "@"
            var_0004 = unknown_08F7H(var_0002) --- Guess: Checks player status
            if var_0004 then
                bark(var_0002, var_0000)
            end
        else
            var_0004 = unknown_08F7H(var_0002) --- Guess: Checks player status
            if var_0004 then
                switch_talk_to(var_0002, 0)
                add_dialogue(var_0000)
                hide_npc(var_0002)
            end
        end
    end
end