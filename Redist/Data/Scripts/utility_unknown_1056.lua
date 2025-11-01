function utility_unknown_1056(eventid, objectref)
    debug_print("Starting func_0920")
    local var_0000
    var_0000 = select_party_member_by_name("\"Which of you wishes to train?\"")
    debug_print("Party member selected" .. var_0000)
    return var_0000
end