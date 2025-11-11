--- Best guess: Manages a dialogue with Shamino, forgiving past deception, commenting on invisibility, and offering assistance, with topic selection for leaving or discussing bees.
---@param party_size integer The number of party members
---@param player_name string The player's name or title
function utility_unknown_1012(party_size, player_name)
    start_conversation()
    local var_0002

    var_0002 = "thee"
    if party_size > 2 then
        var_0002 = "the party"
    end
    if not get_flag(349) then
        add_dialogue("^" .. player_name .. ", I have weighed thine actions against thy former conduct. Now that I am travelling with " .. var_0002 .. "...")
        add_dialogue("I forgive thy misrepresentation at our first meeting.")
        set_flag(349, false)
    end
    if math.random(1, 3) == 1 then
        add_dialogue("\"I enjoy travelling with " .. var_0002 .. ".\"")
    end
    if get_item_flag(0, 356) then
        add_dialogue("\"Avatar! 'Tis strange to converse yet not see the speaker. Invisibility is queer magic.\"")
    end
    add_dialogue("\"How may I assist " .. var_0002 .. ", " .. player_name .. "?\"")
    add_answer({"leave", "bees"})
end