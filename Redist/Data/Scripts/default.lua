function default(eventid, itemref)
    local0 = get_object_shape(itemref)
    local1 = get_object_frame(itemref)
    debug_print("This is object " .. local0 .. ", frame " .. local1 .. " and it is using the default script.")
    debug_print("It needs to be replaced with a real script.")
end