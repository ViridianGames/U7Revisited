--- Best guess: Displays a blocked door message, likely for interaction feedback.
---@param objectref integer The object reference that displays the message
function utility_msg_door_blocked_0792(objectref)
    bark(objectref, "@The door appears blocked.@") --- Guess: Item says dialogue
end