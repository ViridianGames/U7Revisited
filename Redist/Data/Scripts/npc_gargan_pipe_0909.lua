--- Best guess: Manages a brief dialogue with Gargan, who coughs and smokes a pipe, responding to a health inquiry.
function utility_unknown_0909()
    local var_0000, var_0001
    debug_print("In Unknown 0909")
    var_0000 = npc_id_in_party(1)
    if not var_0000 then
        second_speaker(1, 0, "\"Feeling all right, man?\"")
        add_dialogue("Gargan coughs, wheezes, and then lights his pipe. On inhaling, he has a coughing spasm until he finally catches his breath.")
        add_dialogue("\"Never felt better.\"")
    end
end