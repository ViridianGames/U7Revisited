--- Best guess: Adjusts an item’s frame based on player gender and current frame, likely for visual customization.
function func_087D()
    local var_0000, var_0001, var_0002

    var_0000 = create_item(854) --- Guess: Creates item
    set_item_owner(get_item_owner(356), 16) --- Guess: Sets item owner
    if not is_player_female() then
        if get_item_frame(get_item_owner(356)) < 16 then
            set_item_frame(var_0000, 18) --- Guess: Sets frame for male
        else
            set_item_frame(var_0000, 19) --- Guess: Sets alternative frame for male
        end
    else
        if get_item_frame(get_item_owner(356)) < 16 then
            set_item_frame(var_0000, 20) --- Guess: Sets frame for female
        else
            set_item_frame(var_0000, 21) --- Guess: Sets alternative frame for female
        end
    end
    var_0001 = get_position_data(get_item_owner(356)) --- Guess: Gets position data
    var_0002 = get_item_position(var_0001) --- Guess: Gets item position
end