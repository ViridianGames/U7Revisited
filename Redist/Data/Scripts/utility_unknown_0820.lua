-- Raises a portcullis automatically after giving the password
function utility_unknown_0820()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018

    debug_print("Utility_unknown_0820 - raising portcullis")
    if not get_flag(87) then
        set_flag(87, true)
    end
    -- Find nearby portcullis pieces (shape 272, and 271 if present).
    local avatar = get_avatar_ref and get_avatar_ref() or 356
    local found = find_nearby(0, 25, 272, avatar)
    if type(found) ~= "table" or not found[1] then
        found = find_nearby(0, 25, 271, avatar)
    end
    if type(found) == "table" then
        for _, id in ipairs(found) do
            local pos = get_object_position(id)
            if pos then
                debug_print("Raising portcullis object " .. tostring(id))
                set_object_position(id, pos[1] or pos.x, (pos[2] or pos.y) + 4, pos[3] or pos.z)
            end
        end
    end
    --if var_0000  0
    --var_0001 = create_array(find_nearby(0, 25, 271, 356), find_nearby(0, 25, 272, 356)) --- Guess: Sets NPC location
    --for i = 1, 5 do
        --var_0004 = ({2, 3, 4, 1, 427})[i]
        --var_0005 = get_object_lift(var_0004) --- Guess: Gets item lift
        --if var_0005 == 0 then
           -- var_0006 = add_containerobject_s(var_0004, {3, -7, 7947, 0, 8006, 1543, 8021, 32, 7768})
            --for i = 1, 5 do
              --  var_0009 = ({7, 8, 9, 0, 31})[i]
--                var_0006 = add_containerobject_s(var_0009, {3, 8006, 2, 8006, 1, 7750})
  --          end
    --    elseif var_0005 == 1 then
      --      var_0006 = add_containerobject_s(var_0004, {2, -7, 7947, 1, 8006, 1543, 8021, 32, 17496, 7715})
        --    for i = 1, 5 do
          --      var_0009 = ({10, 11, 9, 0, 26})[i]
            --    var_0006 = add_containerobject_s(var_0009, {3, 8006, 2, 7750})
            --end
        --elseif var_0005 == 2 then
          --  var_0006 = add_containerobject_s(var_0004, {1, 8006, 1543, 8021, 32, 7768})
            --for i = 1, 5 do
              --  var_0009 = ({12, 13, 9, 0, 21})[i]
                --var_0006 = add_containerobject_s(var_0009, {3, 7750})
--            end
  --      elseif var_0005 == 3 then
    --        var_0006 = add_containerobject_s(var_0004, {3, -7, 7947, 3, 8006, 1545, 8021, 32, 7768})
      --      for i = 1, 5 do
        --        var_0009 = ({14, 15, 9, 0, 31})[i]
          --      var_0006 = add_containerobject_s(var_0009, {3, 7750})
            --end
--        elseif var_0005 == 4 then
  --          var_0006 = add_containerobject_s(var_0004, {0, 8006, 1, 8006, 2, 7750})
    --        for i = 1, 5 do
      --          var_0009 = ({16, 17, 9, 0, 31})[i]
        --        var_0006 = add_containerobject_s(var_0009, {0, 8006, 1, 8006, 2, 7750})
          --  end
        --end
    --end
    --return true
end