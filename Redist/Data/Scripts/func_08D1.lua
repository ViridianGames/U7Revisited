require "U7LuaFuncs"
-- Function 08D1: Manages acting lesson dialogue
function func_08D1()
    -- Local variables (2 as per .localc)
    local local0, local1

    callis_0009()
    local0 = callis_005A()
    callis_0003(0, -27)
    say("Raymundo hands you a script and you take center stage. The lights feel hot on your face. Although you are a little nervous, you clear your throat and begin to read the lines on the page.")

    while true do
        callis_0005({"I am the -Avatar-!", "I am -the- Avatar!", "I -am- the Avatar!", "-I- am the Avatar!"})
        say("\"No, no, no! That is all wrong! Thou art the 'Avatar'! Thou must feel like the Avatar! Thou must sound like the Avatar! Thou must -be- the Avatar! Try it again.\"")
        callis_0009()
        callis_0005({"I am the -Avatar-!", "I am -the- Avatar!", "I -am- the Avatar!", "-I- am the Avatar!"})
        say("\"Better... better... but I think perhaps thou dost need a prop.\"")
        callis_0009()
        local1 = call_08F7H(-28)
        if not local1 then
            say("\"Jesse, hand our friend thy staff.\"")
            if not local0 then
                callis_0003(1, -28)
                say("\"Here it is, milady.\"")
                callis_0004(-28)
            else
                callis_0003(0, -28)
                say("\"Here it is, milord.\"")
                callis_0004(-28)
            end
        else
            say("Raymundo hands you a staff.")
        end
        callis_0003(0, -27)
        say("With the staff in hand, you try the lines once more. This time you feel like a true actor. The lines flow from your lips as if the Avatar were really saying them. You feel an excitement you have never before felt. You like this 'acting' thing. You crave more! You anxiously await Raymundo's critique...")
        say("Raymundo takes the staff and says, \"Hmmmm. Yes, that's fine. I thank thee. Fine. We shall be in touch, yes? Thank thee for coming in. If thou hast a resume, just leave it by the door, yes? Thank thee.\"")
        call_0911H(20)
        abort()
        break
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function abort()
    -- Placeholder
end