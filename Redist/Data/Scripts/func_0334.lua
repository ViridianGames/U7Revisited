--- Best guess: Manages a plaque, displaying text based on its quality ID (0-65), with specific messages for various locations or events.
function func_0334(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    var_0000 = objectref
    var_0001 = _get_object_quality(var_0000)
    if eventid == 3 then
        if get_object_shape(var_0000) ~= 820 then
            var_0000 = unknown_0035H(176, 5, 820, var_0000)
            var_0000 = unknown_093DH(var_0000)
            if not var_0000 then
                abort()
            end
        end
        var_0001 = _get_object_quality(var_0000)
        var_0002 = {}
        if var_0001 == 7 then
            var_0002 = {557, 623, 600}
        elseif var_0001 == 8 then
            var_0002 = 627
        elseif var_0001 == 9 then
            var_0002 = 640
        elseif var_0001 == 10 then
            var_0002 = 654
        elseif var_0001 == 11 then
            var_0002 = {646, 645, 644}
        end
        var_0003 = false
        for var_0004 in ipairs(var_0002) do
            if not unknown_0035H(176, 5, var_0006, var_0000) then
                if var_0001 < 11 then
                    var_0001 = var_0001 + 1
                    var_0007 = set_object_quality(var_0000, var_0001)
                    unknown_007EH()
                    var_0003 = true
                    break
                else
                    var_0008 = unknown_0018H(var_0000)
                    unknown_0053H(-1, 0, 0, 0, var_0008[2], var_0008[1], 7)
                    unknown_000FH(68)
                    unknown_006FH(var_0000)
                    unknown_007EH()
                    abort()
                end
            end
        end
        if not var_0003 then
            abort()
        end
    elseif eventid == 2 then
        unknown_0049H(-23)
        unknown_005CH(-23)
        unknown_003FH(-23)
    end
    var_0009 = unknown_0908H()
    var_000A = var_0001 > 65 and "This is not a valid plaque" or ""
    if var_0001 == 0 then
        var_000A = {"here", "recorded", "to be", "event", "important"}
    elseif var_0001 == 1 then
        var_000A = {"forgiven", "but not", "forgotten", "kronos", "tomb of"}
    elseif var_0001 == 2 then
        var_000A = {"(+tre", "royal"}
    elseif var_0001 == 3 then
        var_000A = {"HALL", "FELLOWSHIP"}
    elseif var_0001 == 4 then
        var_000A = {"STRENGTH", "OF", "TEST"}
    elseif var_0001 == 5 then
        var_000A = {"RETREAT", "MEDITATION"}
    elseif var_0001 == 6 then
        var_000A = {"THE CODEX", "SHRINE OF"}
    elseif var_0001 == 7 then
        var_000A = {"enter", "to", "here", "hammer"}
    elseif var_0001 == 8 then
        var_000A = {"goi*", "to k)p", "carefully", "pick item"}
        unknown_08FFH({"Look at it now!", "The sign appears to have changed!", "By Jove, I think thou art on the right track!"})
    elseif var_0001 == 9 then
        var_000A = {"faces ()", "tru(", "ring of", "a golden"}
    elseif var_0001 == 10 then
        var_000A = {"(r+ds", "at", "not", "grasp"}
    elseif var_0001 == 11 then
        var_000A = {"back", "hold ()", "shall not", "royal mint", "(e"}
    elseif var_0001 == 12 then
        var_000A = "GO THIS WAY"
    elseif var_0001 == 13 then
        var_000A = {"THIS WAY", "GO", "DO NOT"}
    elseif var_0001 == 14 then
        var_000A = {"WOODEN DOOR", "THE", "IN", "DO NOT GO"}
    elseif var_0001 == 15 then
        var_000A = {"DOOR", "WINDOWED", "THE", "GO IN", "DO NOT"}
    elseif var_0001 == 16 then
        var_000A = {"DOOR", "STEEL", "THE", "IN", "GO"}
    elseif var_0001 == 17 then
        var_000A = {"GREEN DOOR", "IN THE", "GO", "DO NOT"}
    elseif var_0001 == 18 then
        var_000A = {"IS TRUE", "SIGNS", "OF THESE", "ONE", "ONLY"}
    elseif var_0001 == 19 then
        var_000A = {"FALSE", "ARE", "TWO SIGNS", "AT LEAST"}
    elseif var_0001 == 20 then
        var_000A = {"BRANCH", "NATIONAL"}
    elseif var_0001 == 21 then
        var_000A = {"AVATAR?", "AN", "ART THOU"}
    elseif var_0001 == 22 then
        var_000A = {"NOW!", "SEATS", "THY", "RESERVE"}
    elseif var_0001 == 23 then
        var_000A = {"FOSSIL", "BRITANNIAN", "EARLIEST", "ZOG:", "THE BONES OF"}
    elseif var_0001 == 24 then
        var_000A = {"AVATAR", "BY THE", "ONCE WORN", "SWAMP BOOTS"}
    elseif var_0001 == 25 then
        var_000A = {"COMPOSING", "USED WHILE", "HARPSICORD", "MANITTZI'S"}
    elseif var_0001 == 26 then
        var_000A = {"SPRING ", "OF", " ANIA"}
    elseif var_0001 == 27 then
        var_000A = {"flower", "fine,", "skara braes", " marney "}
    elseif var_0001 == 28 then
        var_000A = {"inn", "wayfarers", "(e"}
    elseif var_0001 == 29 then
        var_000A = {"boar", "blue", "(e"}
    elseif var_0001 == 30 then
        var_000A = {"museum", "royal"}
    elseif var_0001 == 31 then
        var_000A = {"hall", "music", "(e"}
    elseif var_0001 == 32 then
        var_000A = {"hall", "town"}
    elseif var_0001 == 33 then
        var_000A = {"mint", "royal"}
    elseif var_0001 == 34 then
        var_000A = {"CHANGES", "MANY", "OF", "THRONE", "THE"}
    elseif var_0001 == 35 then
        var_000A = {"VIRTUE", "OF", "THRONE", "THE"}
    elseif var_0001 == 36 then
        var_000A = {"MUSKET", "BRITISH'S", "LORD"}
    elseif var_0001 == 37 then
        var_000A = {"VIRTUE", "OF", "STONES", "THE"}
    elseif var_0001 == 38 then
        var_000A = {"GARGOYLES", "BY THE", "ONCE USED", "HORN", "SILVER"}
    elseif var_0001 == 39 then
        var_000A = {"SNAKES", "SILVER", "THE", "TO SUMMON"}
    elseif var_0001 == 40 then
        var_000A = {"VIRTUES", "THE", "SYMBOL OF", "", "THE ANKH"}
    elseif var_0001 == 41 then
        var_000A = {"BRITISH", "LORD"}
    elseif var_0001 == 42 then
        var_000A = {"AVATAR", "THE"}
    elseif var_0001 == 43 then
        var_000A = {"CUBE", "VORTEX", "THE"}
    elseif var_0001 == 44 then
        var_000A = {"VIRTUES", "THE", "OF", "RUNES", "THE"}
    elseif var_0001 == 45 then
        var_000A = {"bridge", "knights", "of", "game", "(e"}
    elseif var_0001 == 46 then
        var_000A = {"ENTER", "DO NOT"}
    elseif var_0001 == 47 then
        var_000A = {"ferry", "summon", "to", "horn", "blow"}
    elseif var_0001 == 48 then
        var_0008 = unknown_0018H(var_0000)
        var_000B = unknown_0018H(-23)
        if math.abs(var_0008[1] - var_000B[1]) <= 2 and math.abs(var_0008[2] - var_000B[2]) <= 2 then
            var_0007 = unknown_0001H({7981, 1545, 8021, 1545, 8021, 1545, 7765}, var_0000)
            var_0007 = unknown_0001H({820, 17493, 17518, 7937, 86, 17496, 17517, 8033, 19, 8024, 3, 7719}, -23)
            unknown_08FEH({"@Yancey-Hausman will pay!@", "@He's dead, Avatar!@", ""})
            var_0007 = unknown_0001H({17494, 26, 7715}, -356)
        else
            var_000A = {"BRITISH", "LORD", "OF", "ROOM", "THRONE", "THE"}
        end
    elseif var_0001 == 49 then
        var_000A = {"BRITANNIA", "LORD OF", "THE NEXT", "THOU ART", "SEE IF"}
    elseif var_0001 == 50 then
        var_000A = {"mama", "of", "memory", "lovi*", "in"}
    elseif var_0001 == 51 then
        var_000A = {"DRAGON", "THE", "BEWARE"}
    elseif var_0001 == 52 then
        var_000A = {"marney", "of", "love", "(e", "for"}
    elseif var_0001 == 53 then
        var_000A = {"writer", "a gr+t", "man", "a gr+t", " j r r t "}
    elseif var_0001 == 54 then
        var_000A = {"LENS", "BRITANNIAN", "THE"}
    elseif var_0001 == 55 then
        var_000A = {"LENS", "GARGOYLE", "THE"}
    elseif var_0001 == 56 then
        var_000A = {"POR", "EX"}
    elseif var_0001 == 57 then
        var_000A = {"love", "of", "te,", "(e"}
    elseif var_0001 == 58 then
        var_000A = {"courage", "of", "te,", "(e"}
    elseif var_0001 == 59 then
        var_000A = {"way", "(e", "is", "nor("}
    elseif var_0001 == 60 then
        var_000A = {"tru(", "is", "tru("}
    elseif var_0001 == 61 then
        var_000A = {"deceptive", "are", "app+rances", "only"}
    elseif var_0001 == 62 then
        var_000A = {"done", "well"}
    elseif var_0001 == 63 then
        var_000A = {"tru(", "of", "keys", "(e"}
    elseif var_0001 == 64 then
        var_000A = {"path", "obvious", "always (e", "tru, not"}
    elseif var_0001 == 65 then
        var_000A = {"see (is", "wish to", "do, not", "(ou"}
    end
    display_sign(var_000A, 51)
end