--- Cloth (shape 851).
--- Double-click: examine. Cut into bandages with shears (698) — see object_shears_0698.

function object_cloth_0851(eventid, objectref)
    if eventid == 1 then
        if utility_unknown_1023 then
            utility_unknown_1023(
                "@That appears to be fine cloth, no doubt it would fetch a fair price in Minoc. Or, perhaps, thou couldst cut it into bandages with shears.@")
        else
            item_say(
                "@That appears to be fine cloth, no doubt it would fetch a fair price in Minoc. Or, perhaps, thou couldst cut it into bandages with shears.@",
                objectref)
        end
    end
end
