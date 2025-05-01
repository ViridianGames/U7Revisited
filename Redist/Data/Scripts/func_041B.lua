-- Function 041B: Manages Raymundo's dialogue and interactions
function func_041B(itemref)
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid() == 1 then
        switch_talk_to(27, 0)
        local0 = callis_003B()
        local1 = callis_001B(-27)
        local2 = callis_001C(local1)
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
            if cmp_strings("name", 1) then
                add_dialogue("\"I am Raymundo.\"")
                remove_answer("name")
            elseif cmp_strings("job", 1) then
                add_dialogue("\"Why, I am famous throughout the land! Hast thou not heard of me?\"")
                local3 = call_090AH()
                if local3 then
                    add_dialogue("\"I told thee so!\"")
                else
                    add_dialogue("\"-Really-!? I am surprised! But never mind...\"")
                end
                add_dialogue("\"I am the Director of the Royal Theatre here in Britain. I am also Playwright-in-Residence. I compose a tune now and then as well. I sometimes act, but it is not wise to act in something that one directs.\"")
                if local2 == 7 then
                    add_dialogue("\"We are working on a play at the moment.\"")
                else
                    add_dialogue("\"Come by the theatre during the day and watch the rehearsals for our play.\"")
                end
                add_answer({"play", "Royal Theatre"})
            elseif cmp_strings("play", 1) then
                add_dialogue("\"It's a little something I wrote entitled 'The Trials of the Avatar'. It's about a legendary figure in Britannian history.\" The artist looks you up and down.")
                add_dialogue("\"Hmmm. Thou dost have a certain quality... hast thou ever acted on stage?\"")
                local4 = call_090AH()
                if local4 then
                    add_dialogue("\"I thought so!\"")
                else
                    add_dialogue("\"Well, it does not matter. I am sure thou couldst quickly adapt.\"")
                end
                add_dialogue("\"Officially, auditions have closed and the play is already cast. However, we need someone to understudy the role of the Avatar. Wouldst thou like to audition?\"")
                local5 = call_090AH()
                if local5 then
                    add_dialogue("\"Excellent! What thou needest to do is to visit Gaye's Clothier Shoppe and purchase an Avatar costume. I can audition thee once I see thee in -proper- attire. Run along and do that, quickly now, I'm a busy man.\"*")
                    set_flag(103, true)
                    abort()
                else
                    add_dialogue("\"No? Thou hast never dreamed of performing on the stage? Seeing thy name in torches? Donning the olde grease paint and wig? Bowing to thunderous applause? Well, begone then, I have not the time for chatting with the public.\"*")
                    abort()
                end
            elseif cmp_strings("Royal Theatre", 1) then
                add_dialogue("\"'Tis a wonderful space, dost thou not think? 'Twas opened only last year, thanks to the sponsorship of a few wealthy citizens of our great city.\"")
                remove_answer("Royal Theatre")
                add_answer({"citizens", "sponsorship"})
            elseif cmp_strings("sponsorship", 1) then
                add_dialogue("\"The construction of the actual theatre building was paid for by the Royal Mint, but the theatre company relies solely on the support of individuals such as thyself. Wouldst thou like to make a modest contribution of, say, ten gold pieces to our theatre company?\"")
                local6 = call_090AH()
                if local6 then
                    local7 = callis_002B(true, -359, 644, 10)
                    if not local7 then
                        add_dialogue("\"I thank thee. Thou hast shown thyself to be a true patron of the arts and a person of culture and refinement.\"")
                    else
                        add_dialogue("\"Thine unconvincing performance gave thy game away! Thou dost not have ten gold pieces!\"")
                    end
                else
                    add_dialogue("\"Give a man a loaf of bread and thou hast fed him for a day, give a man a play and perhaps thou hast fed his soul for a lifetime! Once thou hast seen one of our productions I am certain thou shalt reconsider.\"")
                end
                remove_answer("sponsorship")
            elseif cmp_strings("audition", 1) then
                if local2 == 7 then
                    local8 = call_0931H(-359, 838, 1, -356)
                    if local8 then
                        add_dialogue("\"I see thou art ready? Very well. Take center stage, wouldst thou?\"")
                        call_08D1H()
                    else
                        add_dialogue("\"Where is thy costume? Thou cannot audition without a costume!\"*")
                        abort()
                    end
                else
                    add_dialogue("\"Come to the theatre during rehearsal hours, wouldst thou?\"*")
                    abort()
                end
            elseif cmp_strings("Miranda", 1) then
                add_dialogue("Raymundo takes a deep breath and smiles.")
                add_dialogue("\"Ah, lovely woman. 'Tis a pity she is more interested in politics than the stage. But I must say that we get along famously!\"")
                remove_answer("Miranda")
            elseif cmp_strings("Max", 1) then
                add_dialogue("\"He is quite a character, is he not?\" Raymundo's face fills with pride.")
                add_dialogue("\"Takes after his old man, I must say. He is sure to be a great actor. Or writer. Or director. Or producer.\"")
                remove_answer("Max")
            elseif cmp_strings("citizens", 1) then
                add_dialogue("\"Well, I am really not at liberty to divulge the names of our patrons. But most of them belong to The Fellowship.\"")
                remove_answer("citizens")
                add_answer({"Fellowship", "patrons"})
            elseif cmp_strings("patrons", 1) then
                add_dialogue("\"These are people who contribute to our theatre. They come from all walks of life and have little in common besides a love of fine theatre.\"")
                remove_answer("patrons")
            elseif cmp_strings("Fellowship", 1) then
                add_dialogue("\"For non-artists, they have given generous contributions to the theatre. They are -fine- people in my book!\" He rubs his hands with glee.")
                add_dialogue("\"I am not a member, though.\"")
                remove_answer("Fellowship")
            elseif cmp_strings("bye", 1) then
                add_dialogue("\"Leaving? Sorry, I do not give autographs.\"*")
                break
            end
        end
    elseif eventid() == 0 then
        local0 = callis_003B()
        local1 = callis_001B(-27)
        local2 = callis_001C(local1)
        local8 = callis_0010(4, 1)
        if local2 == 7 then
            if local8 == 1 then
                local9 = "@Louder! I can't hear thee!@"
            elseif local8 == 2 then
                local9 = "@Move stage right, please.@"
            elseif local8 == 3 then
                local9 = "@Try that scene again.@"
            elseif local8 == 4 then
                local9 = "@From the top, please.@"
            end
            bark(27, local9)
        else
            call_092EH(-27)
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function add_dialogue(...)
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