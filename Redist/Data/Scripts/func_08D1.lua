--- Best guess: Manages an acting audition with Raymundo, where the player rehearses lines as the Avatar, receiving a staff prop to improve performance.
function func_08D1()
    start_conversation()
    local var_0000, var_0001

    unknown_0009H()
    var_0000 = unknown_005AH()
    switch_talk_to(27, 0)
    add_dialogue("Raymundo hands you a script and you take center stage. The lights feel hot on your face. Although you are a little nervous, you clear your throat and begin to read the lines on the page.")
    while true do
        add_answer({"I am the -Avatar-!", "I am -the- Avatar!", "I -am- the Avatar!", "-I- am the Avatar!"})
        if not unknown_XXXXH() then
            add_dialogue("\"No, no, no! That is all wrong! Thou art the 'Avatar'! Thou must feel like the Avatar! Thou must sound like the Avatar! Thou must -be- the Avatar! Try it again.\"")
            unknown_0009H()
            add_answer({"I am the -Avatar-!", "I am -the- Avatar!", "I -am- the Avatar!", "-I- am the Avatar!"})
            if not unknown_XXXXH() then
                add_dialogue("\"Better... better... but I think perhaps thou dost need a prop.\"")
                unknown_0009H()
                var_0001 = npc_id_in_party(-28)
                if not var_0001 then
                    add_dialogue("\"Jesse, hand our friend thy staff.\"")
                    if var_0000 then
                        switch_talk_to(28, 1)
                        add_dialogue("\"Here it is, milady.\"")
                        hide_npc(-28)
                    else
                        switch_talk_to(28, 0)
                        add_dialogue("\"Here it is, milord.\"")
                        hide_npc(-28)
                    end
                else
                    add_dialogue("Raymundo hands you a staff.")
                end
                switch_talk_to(27, 0)
                add_dialogue("With the staff in hand, you try the lines once more. This time you feel like a true actor. The lines flow from your lips as if the Avatar were really saying them. You feel an excitement you have never before felt. You like this 'acting' thing. You crave more! You anxiously await Raymundo's critique...")
                add_dialogue("Raymundo takes the staff and says, \"Hmmmm. Yes, that's fine. I thank thee. Fine. We shall be in touch, yes? Thank thee for coming in. If thou hast a resume, just leave it by the door, yes? Thank thee.\"")
                unknown_0911H(20)
                return
            end
        end
    end
    return
end