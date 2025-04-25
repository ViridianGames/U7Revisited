-- Function 0848: Check item types
function func_0848(eventid, itemref)
    local local0 = eventid

    if local0 == 504 or local0 == 505 or local0 == 230 or local0 == 381 or local0 == 375 or local0 == 382 or local0 == 534 or local0 == 501 or local0 == 380 or local0 == 480 or local0 == 465 or local0 == 487 or local0 == 488 or local0 == 489 or local0 == 506 or local0 == 445 or local0 == 446 or local0 == 154 then
        set_return(1)
    else
        set_return(0)
    end
end