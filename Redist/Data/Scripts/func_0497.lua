-- Manages Kissme's dialogue in Ambrosia, as a flirtatious fairy spreading love dust, discussing the island's history and Caddellite guarded by the hydra.
function func_0497(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid ~= 1 then
        local7 = get_random(1, 4)
        switch_talk_to(-151, 0)
        set_schedule(-151, 11)
        local5 = get_schedule(-151)
        if local5 == 4 then
            if local7 == 1 then
                local9 = "@I love thee!@"
            elseif local7 == 2 then
                local9 = "@I want to kiss thee!@"
            elseif local7 == 3 then
                local9 = "@I love thee, yes, I do!@"
            elseif local7 == 4 then
                local9 = "@Thou art my love!@"
            end
            item_say(local9, -151)
        else
            apply_effect(-151) -- Unmapped intrinsic
        end
        return
    end

    switch_talk_to(-151, 0)
    local0 = switch_talk_to(-1)
    local1 = switch_talk_to(-2)
    local2 = switch_talk_to(-4)
    local3 = switch_talk_to(-3)
    local4 = get_player_name()
    local5 = get_schedule(-151)
    local6 = is_player_female()
    add_answer({"bye", "job", "name"})

    if not get_flag(710) then
        say("This spritely fairy flutters around you, sprinkling some kind of sparkling dust on your head as she giggles.~~ \"I love thee! Yes, I do! I love thee!\"")
        set_flag(710, true)
    else
        say("\"Yes, my love?\" Kissme asks.")
    end

    while true do
        local answer = get_answer()
        if answer == "name" then
            say("\"Kissme! Kissme!\" She giggles.")
            if local0 then
                switch_talk_to(-1, 0)
                say("\"Don't do it, " .. local4 .. "! Who knows what evil this strange creature might possess!\" He inspects the sprite more closely. \"Mayhaps I should try it first to be sure it is safe...\"*")
                hide_npc(-1)
            end
            if local1 then
                switch_talk_to(-2, 0)
                say("\"Hey, -I'll- kiss her! She doesn't scare me!\"*")
                hide_npc(-2)
            end
            if local3 then
                switch_talk_to(-3, 0)
                say("\"She -doth- look rather inviting, doth she not?\"*")
                hide_npc(-3)
            end
            if local2 then
                switch_talk_to(-4, 0)
                say("\"My liege has asked thee thy -name-, foul creature!\"*")
                hide_npc(-4)
            end
            switch_talk_to(-151, 0)
            say("\"But that -is- my name! Kissme! Kissme! It is true!\"")
            remove_answer("name")
        elseif answer == "job" then
            say("\"My purpose is to spread love dust all around and welcome thee to Ambrosia! I love thee! Yes, I do!\"")
            if local3 then
                say("She flutters over Shamino's head.~~\"I love -thee-, as well!\"*")
                switch_talk_to(-3, 0)
                say("\"If only thou wert a little larger...\"*")
                hide_npc(-3)
                switch_talk_to(-151, 0)
            end
            if local1 then
                say("Then she flies around Spark.~~\"Oooh, and I love -thee-, too!\"*")
                switch_talk_to(-2, 0)
                say("Spark blushes. \"Aww, cut it out!\"*")
                hide_npc(-2)
                switch_talk_to(-151, 0)
            end
            if local2 then
                say("Kissme then flies near Dupre.~~\"Handsome man! Handsome man! I love thee! It's true! It's true!\"*")
                switch_talk_to(-4, 0)
                say("Dupre swats at the fairy. \"Away with thee! Thou dost not love me! Thou dost not even -know- me!\"*")
                hide_npc(-4)
                switch_talk_to(-151, 0)
            end
            if local0 then
                say("Kissme glides over to Iolo and plants a big kiss on his cheek.~~\"Yes! I love thee! Yes, I do!\"*")
                switch_talk_to(-1, 0)
                say("Iolo makes a sour face and wipes his cheek.~~ \"Avatar, that was the sloppiest, wettest, most... -disgusting- kiss I have ever felt!\"*")
                hide_npc(-1)
                switch_talk_to(-151, 0)
            end
            add_answer({"love dust", "Ambrosia"})
        elseif answer == "Ambrosia" then
            say("\"That is where thou art! It is true! Oh, yes! Ambrosia!\"")
            if local0 then
                switch_talk_to(-1, 0)
                say("\"Ambrosia! Then it really does exist!\"*")
                hide_npc(-1)
                switch_talk_to(-151, 0)
            end
            say("\"Ambrosia, the lost isle of Britannia! Thou art really here!\"")
            remove_answer("Ambrosia")
            add_answer("lost isle")
        elseif answer == "love dust" then
            say("\"It does nothing that I know of! But it's pretty!\" Kissme giggles like a child. \"It's how I show thee I love thee! It's true!\"")
            remove_answer("love dust")
        elseif answer == "lost isle" then
            say("\"Ambrosia was hit by stones from the sky hundreds of years ago! Oh, yes indeed! The entire island was battered to bits! It is true!\"")
            remove_answer("lost isle")
            add_answer({"years ago", "stones"})
        elseif answer == "stones" then
            say("\"I believe it is called Caddellite. Yes, I believe it's true!~~\"And I -do- love thee, it is so true!\"")
            remove_answer("stones")
            add_answer("Caddellite")
        elseif answer == "Caddellite" then
            say("\"Most of it is collected in the pit where the hydra sits. Thou shalt have to ask the hydra about it. It is true!\"")
            remove_answer("Caddellite")
            add_answer("hydra")
        elseif answer == "hydra" then
            say("\"The hydra is made up of three brothers -- all dragons! It is true! Thou shalt be careful not to make them angry, for they have a temper! Oh, yes indeed, they do! They are very protective of their Caddellite, so speak to them about it first!\"")
            remove_answer("hydra")
        elseif answer == "years ago" then
            say("\"Ambrosia was once very beautiful! Yes, it was! All of mine ancestors lived here then! Love dust was all around, and every day was like a jewel! Yes, it's true! Yes, thou wilt!~~\"Oh, I must kiss thee again!\"")
            if not local6 then
                say("\"It does not matter whether thou art male or female! No, it does not! I shall kiss thee anyway!\"")
            end
            remove_answer("years ago")
            add_answer("kiss")
        elseif answer == "kiss" then
            if local0 then
                switch_talk_to(-1, 0)
                say("\"No! Don't do it, " .. local4 .. ".\"*")
                hide_npc(-1)
            end
            if local1 then
                switch_talk_to(-2, 0)
                say("\"Sheesh, here we go again!\"*")
                hide_npc(-2)
            end
            if local3 then
                switch_talk_to(-3, 0)
                say("\"Hey, I think she's cute!\"*")
                hide_npc(-3)
            end
            if local2 then
                switch_talk_to(-4, 0)
                say("\"If thou wouldst do it, " .. local4 .. ", do it quickly. We have not time to waste with such foolishness.\" Dupre looks distinctly disgusted with the whole affair.*")
                hide_npc(-4)
            end
            switch_talk_to(-151, 0)
            say("Do you allow Kissme to kiss you?")
            local8 = get_answer()
            if not local8 then
                say("Kissme places the wettest, sloppiest, oozingest, and mushiest smack you have ever felt on your mouth. ~~\"Oh, yes! That was fun! I love thee! Yes, it's true!\"")
            else
                say("\"I love thee anyway! It is true!\" Kissme giggles and sprinkles more love dust in your hair.")
            end
            remove_answer("kiss")
        elseif answer == "bye" then
            say("\"Goodbye, my love! Oh yes! I love thee! It is true!\"*")
            break
        end
    end
    return
end