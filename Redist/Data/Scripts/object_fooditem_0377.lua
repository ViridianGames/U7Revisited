--- Best guess: Manages consumption of food items by mapping item frames to quantities and processing the item, likely for hunger or gameplay effects.
function object_fooditem_0377(eventid, objectref)
    -- i suspect this script should really call utility_unknown_0787
    -- but that script is a disaster atm, so this is a placeholder for now
    local var_0000, var_0001, eater_object

    eater_object = object_select_modal()
    local npc_id = get_npc_number(eater_object)
    if not npc_id_in_party(npc_id) then
        -- i added this check here because it doesn't make
        -- sense to allow non party members to eat food
        -- or things like a lamppost
        console_log("Food only works on party members.")
        return
    end
    -- no clue what this lookup is doing
    var_0000 = {
        6, 8, 31, 2, 9, 1, 3, 24, 1, 3,
        4, 1, 2, 3, 2, 6, 16, 8, 4, 24,
        24, 16, 24, 12, 1, 3, 3, 5, 2, 6,
        4
    }
    var_0001 = var_0000[get_object_frame(objectref) + 1] --- Guess: Gets quantity based on item frame
    consume_object(91, var_0001, objectref, npc_id)
    console_log("Nom nom nom")
end