--- Best guess: Sets an NPC's training level for a given property.
---@param property_id integer The property ID to set (0=strength, 1=dexterity, 2=intelligence, 3=health, 4=combat, 5=mana, 6=magic, 7=training, 8=exp, 9=food_level, 10=sex_flag)
---@param value integer The value to set for the property
---@param object_id integer The object ID whose owner's property will be set
function utility_unknown_1042(property_id, value, object_id)
    local var_0000, var_0001, var_0002, var_0003

    var_0003 = set_npc_property(property_id, get_object_owner(object_id), value) --- Guess: Sets NPC property
end