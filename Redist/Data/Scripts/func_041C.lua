-- Function 041C: Manages Jesse's dialogue and interactions
function func_041C(itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid() == 1 then
        local0 = callis_005A()
        if local0 then
            switch_talk_to(28, 1)
        else
            switch_talk_to(28, 0)
        end
        _AddAnswer({"bye", "job", "name"})
        if not get_flag(157) then
            say("This is a tall, skinny actor with knobby knees.")
            if local0 then
                say("He wears a woman's wig and is dressed in drag.")
            end
            set_flag(157, true)
        else
            if local0 then
                local1 = " he says in falsetto."
            else
                local1 = ""
            end
            say("Jesse clears his throat. \"Hello again!\"" .. local1)
        end
        while true do
            if cmp_strings("name", 1) then
                if local0 then
                    say("The actor speaks in falsetto.")
                end
                say("\"I am Jesse and I am a star.\"")
                _RemoveAnswer("name")
                if local0 then
                    say("He slaps his own face and speaks in a normal register, \"Oops, sorry! I am so entrenched in the role that I sometimes forget that I am not a woman!\"")
                end
            elseif cmp_strings("job", 1) then
                say("\"I work at the Royal Theatre as an actor. I have played -all- the great roles in my career. I now have the chance to play the part of a lifetime -- the Avatar!\"")
                _AddAnswer({"Avatar", "Royal Theatre"})
            elseif cmp_strings("Royal Theatre", 1) then
                say("\"Because it must cater to the masses, we never have the opportunity to do experimental works -- only the traditional gruel of mediocrity. But 'tis a wonderful space and it has marvelous acoustics.\"")
                _AddAnswer({"experimental works", "masses"})
                _RemoveAnswer("Royal Theatre")
            elseif cmp_strings("masses", 1) then
                say("\"People like to see tales of heroic adventures, knights in armour, beautiful princesses, wise kings, wizards, evil monsters. All that rot.\"")
                _RemoveAnswer("masses")
            elseif cmp_strings("Avatar", 1) then
                say("\"The role is very challenging. I have a plethora of lines and I had to work with a trainer for weeks to prepare for the enormous amount of activity required. This role will make 'Jesse' a household name!\"")
                _AddAnswer({"lines", "challenging"})
                _RemoveAnswer("Avatar")
            elseif cmp_strings("challenging", 1) then
                say("\"It is easily the most ambitious theatrical production ever conceived. There is over a hundred hours of play time. That is a long time for an audience.\"")
                _RemoveAnswer("challenging")
            elseif cmp_strings("lines", 1) then
                say("\"My biggest lines are:~~\"Name!\"~~\"Job!\"~~\"Bye!\"")
                _RemoveAnswer("lines")
            elseif cmp_strings("experimental works", 1) then
                say("\"My favorite piece is something Raymundo wrote for me entitled 'Three on a Codpiece'. I stand on stage and invite the audience to join me in tearing an undergarment into tiny pieces, after which they are placed in funeral urns and mixed with wheat paste. The pieces of cloth, not the audience members. Then the audience may glue the pieces anywhere on my body that they wish.\"")
                _RemoveAnswer("experimental works")
            elseif cmp_strings("bye", 1) then
                say("\"Goodbye. Be sure to come to the show when it opens!\"*")
                break
            end
        end
    elseif eventid() == 0 then
        local2 = callis_003B()
        local3 = callis_001B(-28)
        local4 = callis_001C(local3)
        local5 = callis_0010(4, 1)
        if local4 == 29 then
            if local5 == 1 then
                local1 = "@Name!@"
            elseif local5 == 2 then
                local1 = "@Job!@"
            elseif local5 == 3 then
                local1 = "@Yes! Er, I mean No!@"
            elseif local5 == 4 then
                local1 = "@Bye!@"
            end
            _ItemSay(local1, -28)
        else
            call_092EH(-28)
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function say(...)
    print(table.concat({...}))
end

function get_flag(id)
    return false -- Placeholder
end

function set_flag(id, value)
    -- Placeholder
end

function cmp_strings(str, count)
    return false -- Placeholder
end

function abort()
    -- Placeholder
end