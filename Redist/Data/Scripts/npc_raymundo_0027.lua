--- Best guess: Manages Raymundo's dialogue, handling Royal Theatre operations, auditions for the Avatar role, and sponsorship requests, with flag-based progression.
function npc_raymundo_0027(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid ~= 1 then
        if eventid == 0 then
            var_0000 = get_schedule()
            var_0001 = get_schedule_type(get_npc_name(-27))
            var_0008 = random2(4, 1)
            if var_0001 == 7 then
                if var_0008 == 1 then
                    var_0009 = "@Louder! I can't hear thee!@"
                elseif var_0008 == 2 then
                    var_0009 = "@Move stage right, please.@"
                elseif var_0008 == 3 then
                    var_0009 = "@Try that scene again.@"
                elseif var_0008 == 4 then
                    var_0009 = "@From the top, please.@"
                end
                bark(-27, var_0009)
            else
                utility_unknown_1070(-27)
            end
        end
        add_dialogue("\"Leaving? Sorry, I do not give autographs.\"")
        return
    end

    start_conversation()
    switch_talk_to(0, -27)
    var_0000 = get_schedule()
    var_0001 = get_schedule_type(get_npc_name(-27))
    add_answer({"bye", "job", "name"})
    if not get_flag(104) then
        add_answer("audition")
    end
    if not get_flag(105) then
        add_answer({"Max", "Miranda"})
    end
    if not get_flag(156) then
        add_dialogue("You can see the creativity literally flowing in abundance from this fellow. He looks at you with interest.")
        set_flag(156, true)
    else
        add_dialogue("\"Yes, yes?\" Raymundo snaps. \"What dost thou want? I'm busy!\"")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am Raymundo.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"Why, I am famous throughout the land! Hast thou not heard of me?\"")
            var_0002 = ask_yes_no()
            if not var_0002 then
                add_dialogue("\"I told thee so!")
            else
                add_dialogue("\"-Really-!? I am surprised! But never mind...")
            end
            add_dialogue("\"I am the Director of the Royal Theatre here in Britain. I am also Playwright-in-Residence. I compose a tune now and then as well. I sometimes act, but it is not wise to act in something that one directs.")
            if var_0001 == 7 then
                add_dialogue("\"We are working on a play at the moment.\"")
            else
                add_dialogue("\"Come by the theatre during the day and watch the rehearsals for our play.\"")
            end
            add_answer({"play", "Royal Theatre"})
        elseif cmps("play") then
            add_dialogue("\"It's a little something I wrote entitled 'The Trials of the Avatar'. It's about a legendary figure in Britannian history.\" The artist looks you up and down.")
            add_dialogue("\"Hmmm. Thou dost have a certain quality... hast thou ever acted on stage?\"")
            var_0003 = ask_yes_no()
            if var_0003 then
                add_dialogue("\"I thought so!")
            else
                add_dialogue("\"Well, it does not matter. I am sure thou couldst quickly adapt.")
            end
            add_dialogue("\"Officially, auditions have closed and the play is already cast. However, we need someone to understudy the role of the Avatar. Wouldst thou like to audition?\"")
            var_0004 = ask_yes_no()
            if var_0004 then
                add_dialogue("\"Excellent! What thou needest to do is to visit Gaye's Clothier Shoppe and purchase an Avatar costume. I can audition thee once I see thee in -proper- attire. Run along and do that, quickly now, I'm a busy man.\"")
                set_flag(103, true)
                return
            else
                add_dialogue("\"No? Thou hast never dreamed of performing on the stage? Seeing thy name in torches? Donning the olde grease paint and wig? Bowing to thunderous applause? Well, begone then, I have not the time for chatting with the public.\"")
                return
            end
        elseif cmps("Royal Theatre") then
            add_dialogue("\"'Tis a wonderful space, dost thou not think? 'Twas opened only last year, thanks to the sponsorship of a few wealthy citizens of our great city.\"")
            remove_answer("Royal Theatre")
            add_answer({"citizens", "sponsorship"})
        elseif cmps("sponsorship") then
            add_dialogue("\"The construction of the actual theatre building was paid for by the Royal Mint, but the theatre company relies solely on the support of individuals such as thyself. Wouldst thou like to make a modest contribution of, say, ten gold pieces to our theatre company?\"")
            var_0005 = ask_yes_no()
            if var_0005 then
                var_0006 = remove_party_items(359, 359, 644, 10)
                if var_0006 then
                    add_dialogue("\"I thank thee. Thou hast shown thyself to be a true patron of the arts and a person of culture and refinement.\"")
                else
                    add_dialogue("\"Thine unconvincing performance gave thy game away! Thou dost not have ten gold pieces!\"")
                end
            else
                add_dialogue("\"Give a man a loaf of bread and thou hast fed him for a day, give a man a play and perhaps thou hast fed his soul for a lifetime! Once thou hast seen one of our productions I am certain thou shalt reconsider.\"")
            end
            remove_answer("sponsorship")
        elseif cmps("audition") then
            if var_0001 == 7 then
                var_0007 = utility_unknown_1073(359, 359, 838, 1, -356)
                if var_0007 then
                    add_dialogue("\"I see thou art ready? Very well. Take center stage, wouldst thou?\"")
                    utility_unknown_0977()
                else
                    add_dialogue("\"Where is thy costume? Thou cannot audition without a costume!\"")
                    return
                end
            else
                add_dialogue("\"Come to the theatre during rehearsal hours, wouldst thou?\"")
                return
            end
        elseif cmps("Miranda") then
            add_dialogue("Raymundo takes a deep breath and smiles.")
            add_dialogue("\"Ah, lovely woman. 'Tis a pity she is more interested in politics than the stage. But I must say that we get along famously!\"")
            remove_answer("Miranda")
        elseif cmps("Max") then
            add_dialogue("\"He is quite a character, is he not?\" Raymundo's face fills with pride.")
            add_dialogue("\"Takes after his old man, I must say. He is sure to be a great actor. Or writer. Or director. Or producer.\"")
            remove_answer("Max")
        elseif cmps("citizens") then
            add_dialogue("\"Well, I am really not at liberty to divulge the names of our patrons. But most of them belong to The Fellowship.\"")
            remove_answer("citizens")
            add_answer({"Fellowship", "patrons"})
        elseif cmps("patrons") then
            add_dialogue("\"These are people who contribute to our theatre. They come from all walks of life and have little in common besides a love of fine theatre.\"")
            remove_answer("patrons")
        elseif cmps("Fellowship") then
            add_dialogue("\"For non-artists, they have given generous contributions to the theatre. They are -fine- people in my book!\" He rubs his hands with glee.")
            add_dialogue("\"I am not a member, though.\"")
            remove_answer("Fellowship")
        elseif cmps("bye") then
            break
        end
    end
    return
end