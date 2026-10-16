--- Best guess: Manages a quest item, triggering specific effects when used in a particular state (frame 3), setting a flag for quest progression.
--- Arcadion mirror. Frame 3 is the idle mirror. Double-click plays sfx 67
--- and steps frames 4, 5, 6, 7 and 8, then opens the dialogue on frame 8.
function object_mirror_0848(eventid, objectref)
    if eventid == 1 then
        if get_object_frame(objectref) == 3 then
            -- Original appear: sfx 67, then frames 4, 5, 6, 7, 8, then the dialogue.
            execute_usecode_array(objectref, {1782, 8021, 2, 7975, 4, -3, 7947, 4, 17447, 17486, 7937, 67, 7768})
        end
    elseif eventid == 2 then
        -- Using the Ether Gem on the mirror triggers event 2. The original
        -- fn_0350 sets this transition before Arcadion begins speaking.
        set_flag(815, true)
        npc_arcadion_dialogue_0502(objectref)
    end
end
