--- Func0820 / 0x820: close/lock a secret door piece by transforming it to shape 828.
--- Kept as a named helper; lock_door() in door_lock_unlock_0790.lua is the shared implementation.

function door_lock_if_clear_0800(objectref)
    return lock_door(objectref)
end
