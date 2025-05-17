--- Best guess: Handles dialogue with Kissme, a flirtatious fairy in Ambrosia, spreading love dust and discussing the island's history, Caddellite, and the hydra. Includes an option to accept a kiss.
function func_0497(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    start_conversation()
    if eventid == 1 then
        switch_talk_to(151, 0)
        var_0000 = unknown_08F7H(1) --- Guess: Checks player status
        var_0001 = unknown_08F7H(2) --- Guess: Checks player status
        var_0002 = unknown_08F7H(4) --- Guess: Checks player status
        var_0003 = unknown_08F7H(3) --- Guess: Checks player status
        var_0004 = get_lord_or_lady()
        var_0005 = unknown_001CH(151) --- Guess: Gets schedule
        var_0006 = is_player_female()
        add_answer({"bye", "job", "name"})
        if not get_flag(710) then
            add_dialogue("This spritely fairy flutters around you, sprinkling some kind of sparkling dust on your head as she giggles.")
            add_dialogue("\"I love thee! Yes, I do! I love thee!\"")
            set_flag(710, true)
        else
            add_dialogue("\"Yes, my love?\" Kissme asks.")
        end
        while true do
            var_0007 = get_answer()
            if var_0007 == "name" then
                add_dialogue("\"Kissme! Kissme!\" She giggles.")
                if var_0000 then
                    switch_talk_to(1, 0)
                    add_dialogue("\"Don't do it, " .. var_0004 .. "! Who knows what evil this strange creature might possess!\" He inspects the sprite more closely. \"Mayhaps I should try it first to be sure it is safe...\"")
                    hide_npc(1)
                end
                if var_0001 then
                    switch_talk_to(2, 0)
                    add_dialogue("\"Hey, -I'll- kiss her! She doesn't scare me!\"")
                    hide_npc(2)
                end
                if var_0003 then
                    switch_talk_to(3, 0)
                    add_dialogue("\"She -doth- look rather inviting, doth she not?\"")
                    hide_npc(3)
                end
                if var_0002 then
                    switch_talk_to(4, 0)
                    add_dialogue("\"My liege has asked thee thy -name-, foul creature!\"")
                    hide_npc(4)
                end
                switch_talk_to(151, 0)
                add_dialogue("\"But that -is- my name! Kissme! Kissme! It is true!\"")
                remove_answer("name")
            elseif var_0007 == "job" then
                add_dialogue("\"My purpose is to spread love dust all around and welcome thee to Ambrosia! I love thee! Yes, I do!\"")
                if var_0003 then
                    add_dialogue("She flutters over Shamino's head.")
                    add_dialogue("\"I love -thee-, as well!\"")
                    switch_talk_to(3, 0)
                    add_dialogue("\"If only thou wert a little larger...\"")
                    hide_npc(3)
                    switch_talk_to(151, 0)
                end
                if var_0001 then
                    add_dialogue("Then she flies around Spark.")
                    add_dialogue("\"Oooh, and I love -thee-, too!\"")
                    switch_talk_to(2, 0)
                    add_dialogue("Spark blushes. \"Aww, cut it out!\"")
                    hide_npc(2)
                    switch_talk_to(151, 0)
                end
                if var_0002 then
                    add_dialogue("Kissme then flies near Dupre.")
                    add_dialogue("\"Handsome man! Handsome man! I love thee! It's true! It's true!\"")
                    switch_talk_to(4, 0)
                    add_dialogue("Dupre swats at the fairy. \"Away with thee! Thou dost not love me! Thou dost not even -know- me!\"")
                    hide_npc(4)
                    switch_talk_to(151, 0)
                end
                if var_0000 then
                    add_dialogue("Kissme glides over to Iolo and plants a big kiss on his cheek.")
                    add_dialogue("\"Yes! I love thee! Yes, I do!\"")
                    switch_talk_to(1, 0)
                    add_dialogue("Iolo makes a sour face and wipes his cheek.")
                    add_dialogue("\"Avatar, that was the sloppiest, wettest, most... -disgusting- kiss I have ever felt!\"")
                    hide_npc(1)
                    switch_talk_to(151, 0)
                end
                add_answer({"love dust", "Ambrosia"})
            elseif var_0007 == "Ambrosia" then
                add_dialogue("\"That is where thou art! It is true! Oh, yes! Ambrosia!\"")
                if var_0000 then
                    switch_talk_to(1, 0)
                    add_dialogue("\"Ambrosia! Then it really does exist!\"")
                    hide_npc(1)
                    switch_talk_to(151, 0)
                end
                add_dialogue("\"Ambrosia, the lost isle of Britannia! Thou art really here!\"")
                remove_answer("Ambrosia")
                add_answer("lost isle")
            elseif var_0007 == "love dust" then
                add_dialogue("\"It does nothing that I know of! But it's pretty!\" Kissme giggles like a child. \"It's how I show thee I love thee! It's true!\"")
                remove_answer("love dust")
            elseif var_0007 == "lost isle" then
                add_dialogue("\"Ambrosia was hit by stones from the sky hundreds of years ago! Oh, yes indeed! The entire island was battered to bits! It is true!\"")
                remove_answer("lost isle")
                add_answer({"years ago", "stones"})
            elseif var_0007 == "stones" then
                add_dialogue("\"I believe it is called Caddellite. Yes, I believe it's true!\"")
                add_dialogue("\"And I -do- love thee, it is so true!\"")
                remove_answer("stones")
                add_answer("Caddellite")
            elseif var_0007 == "Caddellite" then
                add_dialogue("\"Most of it is collected in the pit where the hydra sits. Thou shalt have to ask the hydra about it. It is true!\"")
                remove_answer("Caddellite")
                add_answer("hydra")
            elseif var_0007 == "hydra" then
                add_dialogue("\"The hydra is made up of three brothers -- all dragons! It is true! Thou shalt be careful not to make them angry, for they have a temper! Oh, yes indeed, they do! They are very protective of their Caddellite, so speak to them about it first!\"")
                remove_answer("hydra")
            elseif var_0007 == "years ago" then
                add_dialogue("\"Ambrosia was once very beautiful! Yes, it was! All of mine ancestors lived here then! Love dust was all around, and every day was like a jewel! Yes, it's true! Yes, thou wilt!\"")
                add_dialogue("\"Oh, I must kiss thee again!\"")
                if not var_0006 then
                    add_dialogue("\"It does not matter whether thou art male or female! No, it does not! I shall kiss thee anyway!\"")
                end
                remove_answer("years ago")
                add_answer("kiss")
            elseif var_0007 == "kiss" then
                if var_0000 then
                    switch_talk_to(1, 0)
                    add_dialogue("\"No! Don't do it, " .. var_0004 .. ".\"")
                    hide_npc(1)
                end
                if var_0001 then
                    switch_talk_to(2, 0)
                    add_dialogue("\"Sheesh, here we go again!\"")
                    hide_npc(2)
                end
                if var_0003 then
                    switch_talk_to(3, 0)
                    add_dialogue("\"Hey, I think she's cute!\"")
                    hide_npc(3)
                end
                if var_0002 then
                    switch_talk_to(4, 0)
                    add_dialogue("\"If thou wouldst do it, " .. var_0004 .. ", do it quickly. We have not time to waste with such foolishness.\" Dupre looks distinctly disgusted with the whole affair.")
                    hide_npc(4)
                end
                switch_talk_to(151, 0)
                add_dialogue("Do you allow Kissme to kiss you?")
                if select_option() then
                    add_dialogue("Kissme places the wettest, sloppiest, oozingest, and mushiest smack you have ever felt on your mouth.")
                    add_dialogue("\"Oh, yes! That was fun! I love thee! Yes, it's true!\"")
                else
                    add_dialogue("\"I love thee anyway! It is true!\" Kissme giggles and sprinkles more love dust in your hair.")
                end
                remove_answer("kiss")
            elseif var_0007 == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye, my love! Oh yes! I love thee! It is true!\"")
    elseif eventid == 0 then
        var_0007 = get_schedule() --- Guess: Checks game state
        var_0005 = unknown_001CH(151) --- Guess: Gets schedule
        if var_0005 == 4 then
            var_0008 = random(1, 4)
            if var_0008 == 1 then
                var_0009 = "@I love thee!@"
            elseif var_0008 == 2 then
                var_0009 = "@I want to kiss thee!@"
            elseif var_0008 == 3 then
                var_0009 = "@I love thee, yes, I do!@"
            elseif var_0008 == 4 then
                var_0009 = "@Thou art my love!@"
            end
            bark(151, var_0009)
        end
    end
end