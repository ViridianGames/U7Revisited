--- Best guess: Manages a brief dialogue with Gargan, who coughs and smokes a pipe, responding to a health inquiry.
function func_088D()
    local var_0000, var_0001

    var_0000 = unknown_08F7H(-1)
    if not var_0000 then
        switch_talk_to(0, -1)
        add_dialogue("\"Feeling all right, man?\"")
        switch_talk_to(0, -21)
        add_dialogue("Gargan coughs, wheezes, and then lights his pipe. On inhaling, he has a coughing spasm until he finally catches his breath.")
        add_dialogue("\"Never felt better.\"")
        hide_npc1)
        switch_talk_to(0, -21)
        var_0001 = 0
    end
end