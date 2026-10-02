--- Best guess: Retrieves an NPC's training level for a given property.
---@param property_id integer The property ID to retrieve (0=strength, 1=dexterity, 2=intelligence, 3=health, 4=combat, 5=mana, 6=magic, 7=training, 8=exp, 9=food_level, 10=sex_flag)
---@param object_id integer The object ID whose owner's property will be retrieved
---@return integer value The property value
function utility_unknown_1040(property_id, object_id)
    return get_npc_property(property_id, get_object_owner(object_id)) --- Guess: Gets NPC property
end