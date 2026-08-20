--- Func0815 / 0x815: toggle door lock with a key (usecode Func081B/081C).
--- state 0 (closed) → lock to 2; state 2 (locked) → unlock to 0;
--- state 1 (open) / 3 (magic) → bark only.

function func_0815(door)
    if not door then
        return
    end
    local fr = get_object_frame(door) or 0
    local state = fr % 4
    local base = fr - state
    if state == 0 then
        -- Lock closed door
        set_object_frame(door, base + 2)
    elseif state == 1 then
        bark(get_avatar_ref() or door,
            "@Excuse me, the door is already open. Is it not rather futile to lock it now?@")
    elseif state == 2 then
        -- Unlock
        set_object_frame(door, base + 0)
    elseif state == 3 then
        if random and random(1, 10) == 1 then
            bark(get_avatar_ref() or door,
                "@Excuse me, the door appears magically locked. Is it not rather difficult to unlock it with a key?@")
        end
    end
end

-- Compat aliases used by decompiled scripts
utility_unknown_0815 = func_0815
utility_unknown_081B = utility_unknown_0795 -- frame % 4
function utility_unknown_081C(door, new_state)
    local fr = get_object_frame(door) or 0
    local state = fr % 4
    set_object_frame(door, (fr - state) + (new_state or 0))
end
