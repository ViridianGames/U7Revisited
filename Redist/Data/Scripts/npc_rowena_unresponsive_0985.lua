--- Best guess: Manages Rowena's unresponsive state in Skara Brae, displaying different messages based on a flag, indicating she cannot respond.
function utility_unknown_0985()
    start_conversation()
    if not get_flag(457) then
        add_dialogue("The beautiful ghost appears to be incapable of responding to you at the current time, or in fact anyone else for that matter.")
    else
        add_dialogue("Rowena appears to be incapable of responding to you at the current time, or in fact anyone else for that matter.")
    end
    return
end