function default(eventid, objectref)
    local0 = get_object_shape(objectref)
    local1 = get_object_frame(objectref)
    debug_print("This is object " .. local0 .. ", frame " .. local1 .. " and it is using the default script.")
    debug_print("It needs to be replaced with a real script.")
end