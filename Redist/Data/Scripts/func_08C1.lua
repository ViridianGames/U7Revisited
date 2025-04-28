require "U7LuaFuncs"
-- Function 08C1: Manages Rowena's reunion dialogue
function func_08C1()
    -- Local variable (1 as per .localc)
    local local0

    local0 = call_0908H()
    say("Sweet Rowena, I am so happy to see thee out of that horrid tower.\" Mordra's eyes begin to fill with tears of joy.")
    callis_0003(1, -144)
    say("It was terrible, but the worst part was being away from mine husband. The whole time I was there with Horance, I felt like a hollow shell of a person. I must be with Trent to be whole again.")
    callis_0004(-144)
    callis_0003(0, -143)
    say("Yes, thou art quite right. ", local0, ", she must needs be taken to her husband, swiftly. I trust that thou wilt do so.\" She leaves the statement hanging and says her goodbyes to Rowena.")
    abort()

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function abort()
    -- Placeholder
end