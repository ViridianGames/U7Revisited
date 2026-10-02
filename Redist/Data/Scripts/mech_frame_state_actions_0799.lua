--- Func081F / 0x81F: open/unlock a secret door piece by transforming it to shape 845.
--- Shared implementation lives in unlock_door() (door_lock_unlock_0790.lua).

function mech_frame_state_actions_0799(objectref)
    return unlock_door(objectref)
end