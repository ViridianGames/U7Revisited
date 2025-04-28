require "U7LuaFuncs"
-- Manages dialogue for Gargan, including coughing and pipe-smoking.
function func_088D()
    local local0, local1

    local0 = external_08F7H(-1) -- Unmapped intrinsic
    if not local0 then
        switch_talk_to(-1, 0)
        say("\"Feeling all right, man?\"*")
        switch_talk_to(-21, 0)
        say("Gargan coughs, wheezes, and then lights his pipe. On inhaling, he has a coughing spasm until he finally catches his breath.")
        say("\"Never felt better.\"*")
        hide_npc(-1)
        switch_talk_to(-21, 0)
        local1 = 0
    end
    return
end