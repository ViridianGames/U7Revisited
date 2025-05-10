--- Best guess: Manages Meryl’s brief actress dialogue, displaying random promotional messages for the Passion Play when examined (event 0) or a focused actress message when spoken to (event 1).
function func_04EA(eventid, objectref)
    local local0, local1, local2, local3

    if eventid == 0 then
        local0 = unknown_003BH()
        local1 = unknown_001CH(unknown_001BH(-234))
        local2 = random2(4, 1)
        if local1 == 29 then
            if local2 == 1 then
                local3 = "@See the Passion Play!@"
            elseif local2 == 2 then
                local3 = "@The Fellowship presents...@"
            elseif local2 == 3 then
                local3 = "@Come view the Passion Play!@"
            elseif local2 == 4 then
                local3 = "@We shall entertain thee!@"
            end
            bark(234, local3)
        else
            unknown_092EH(-234)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(0, -234)
    add_dialogue("You see a middle-aged actress with a very serious expression. She is unable to speak with you because she is concentrating on her part in the Passion Play. Perhaps you should speak to Paul.")
end