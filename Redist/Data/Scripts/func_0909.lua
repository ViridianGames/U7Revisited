-- Function 0909: Return gender-specific title
function func_0909(eventid, itemref)
    if is_player_female() == 0 then
        set_return("milord")
    else
        set_return("milady")
    end
end