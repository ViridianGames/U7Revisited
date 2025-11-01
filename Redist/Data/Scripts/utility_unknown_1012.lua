--- Best guess: Manages a dialogue with Shamino, forgiving past deception, commenting on invisibility, and offering assistance, with topic selection for leaving or discussing bees.
function utility_unknown_1012(var_0000, var_0001)
    start_conversation()
    local var_0002

    var_0002 = "thee"
    if var_0000 > 2 then
        var_0002 = "the party"
    end
    if not get_flag(349) then
        add_dialogue("^" .. var_0001 .. ", I have weighed thine actions against thy former conduct. Now that I am travelling with " .. var_0002 .. "...")
        add_dialogue("I forgive thy misrepresentation at our first meeting.")
        set_flag(349, false)
    end
    if math.random(1, 3) == 1 then
        add_dialogue("\"I enjoy travelling with " .. var_0002 .. ".\"")
    end
    if get_item_flag(0, 356) then
        add_dialogue("\"Avatar! 'Tis strange to converse yet not see the speaker. Invisibility is queer magic.\"")
    end
    add_dialogue("\"How may I assist " .. var_0002 .. ", " .. var_0001 .. "?\"")
    add_answer({"leave", "bees"})
    return
end