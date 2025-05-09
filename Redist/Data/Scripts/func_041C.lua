--- Best guess: Manages Jesse’s dialogue, discussing his role as the Avatar in the Royal Theatre’s play, his experimental works, and stage persona, with gender-based dialogue variations.
function func_041C(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid ~= 1 then
        if eventid == 0 then
            var_0002 = unknown_003BH()
            var_0003 = unknown_001CH(unknown_001BH(-28))
            var_0004 = random2(4, 1)
            if var_0003 == 29 then
                if var_0004 == 1 then
                    var_0005 = "@Name!@"
                elseif var_0004 == 2 then
                    var_0005 = "@Job!@"
                elseif var_0004 == 3 then
                    var_0005 = "@Yes! Er, I mean No!@"
                elseif var_0004 == 4 then
                    var_0005 = "@Bye!@"
                end
                bark(var_0005, -28)
            else
                unknown_092EH(-28)
            end
        end
        add_dialogue("\"Goodbye. Be sure to come to the show when it opens!\"")
        return
    end

    start_conversation()
    var_0000 = _IsPlayerFemale()
    if var_0000 then
        switch_talk_to(1, -28)
    else
        switch_talk_to(0, -28)
    end
    add_answer({"bye", "job", "name"})
    if not get_flag(157) then
        add_dialogue("This is a tall, skinny actor with knobby knees.")
        if var_0000 then
            add_dialogue("He wears a woman's wig and is dressed in drag.")
        end
        set_flag(157, true)
    else
        if var_0000 then
            var_0001 = " he says in falsetto."
        else
            var_0001 = ""
        end
        add_dialogue("Jesse clears his throat. \"Hello again!\"" .. var_0001)
    end
    while true do
        if cmps("name") then
            if var_0000 then
                add_dialogue("The actor speaks in falsetto.")
            end
            add_dialogue("\"I am Jesse and I am a star.\"")
            remove_answer("name")
            if var_0000 then
                add_dialogue("He slaps his own face and speaks in a normal register, \"Oops, sorry! I am so entrenched in the role that I sometimes forget that I am not a woman!\"")
            end
        elseif cmps("job") then
            add_dialogue("\"I work at the Royal Theatre as an actor. I have played -all- the great roles in my career. I now have the chance to play the part of a lifetime -- the Avatar!\"")
            add_answer({"Avatar", "Royal Theatre"})
        elseif cmps("Royal Theatre") then
            add_dialogue("\"Because it must cater to the masses, we never have the opportunity to do experimental works -- only the traditional gruel of mediocrity. But 'tis a wonderful space and it has marvelous acoustics.\"")
            add_answer({"experimental works", "masses"})
            remove_answer("Royal Theatre")
        elseif cmps("masses") then
            add_dialogue("\"People like to see tales of heroic adventures, knights in armour, beautiful princesses, wise kings, wizards, evil monsters. All that rot.\"")
            remove_answer("masses")
        elseif cmps("Avatar") then
            add_dialogue("\"The role is very challenging. I have a plethora of lines and I had to work with a trainer for weeks to prepare for the enormous amount of activity required. This role will make 'Jesse' a household name!\"")
            add_answer({"lines", "challenging"})
            remove_answer("Avatar")
        elseif cmps("challenging") then
            add_dialogue("\"It is easily the most ambitious theatrical production ever conceived. There is over a hundred hours of play time. That is a long time for an audience.\"")
            remove_answer("challenging")
        elseif cmps("lines") then
            add_dialogue("\"My biggest lines are:")
            add_dialogue("\"Name!\"")
            add_dialogue("\"Job!\"")
            add_dialogue("\"Bye!\"")
            remove_answer("lines")
        elseif cmps("experimental works") then
            add_dialogue("\"My favorite piece is something Raymundo wrote for me entitled 'Three on a Codpiece'. I stand on stage and invite the audience to join me in tearing an undergarment into tiny pieces, after which they are placed in funeral urns and mixed with wheat paste. The pieces of cloth, not the audience members. Then the audience may glue the pieces anywhere on my body that they wish.\"")
            remove_answer("experimental works")
        elseif cmps("bye") then
            break
        end
    end
    return
end