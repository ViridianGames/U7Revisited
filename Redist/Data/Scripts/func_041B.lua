-- Function 041B: Manages Raymundo's dialogue and interactions
function func_041B(itemref)
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid() == 1 then
        switch_talk_to(27, 0)
        local0 = callis_003B()
        local1 = callis_001B(-27)
        local2 = callis_001C(local1)
        _AddAnswer({"bye", "job", "name"})
        if not get_flag(104) then
            _AddAnswer("audition")
        end
        if not get_flag(105) then
            _AddAnswer({"Max", "Miranda"})
        end
        if not get_flag(156) then
            say("You can see the creativity literally flowing in abundance from this fellow. He looks at you with interest.")
            set_flag(156, true)
        else
            say("\"Yes, yes?\" Raymundo snaps. \"What dost thou want? I'm busy!\"")
        end
        while true do
            if cmp_strings("name", 1) then
                say("\"I am Raymundo.\"")
                _RemoveAnswer("name")
            elseif cmp_strings("job", 1) then
                say("\"Why, I am famous throughout the land! Hast thou not heard of me?\"")
                local3 = call_090AH()
                if local3 then
                    say("\"I told thee so!\"")
                else
                    say("\"-Really-!? I am surprised! But never mind...\"")
                end
                say("\"I am the Director of the Royal Theatre here in Britain. I am also Playwright-in-Residence. I compose a tune now and then as well. I sometimes act, but it is not wise to act in something that one directs.\"")
                if local2 == 7 then
                    say("\"We are working on a play at the moment.\"")
                else
                    say("\"Come by the theatre during the day and watch the rehearsals for our play.\"")
                end
                _AddAnswer({"play", "Royal Theatre"})
            elseif cmp_strings("play", 1) then
                say("\"It's a little something I wrote entitled 'The Trials of the Avatar'. It's about a legendary figure in Britannian history.\" The artist looks you up and down.")
                say("\"Hmmm. Thou dost have a certain quality... hast thou ever acted on stage?\"")
                local4 = call_090AH()
                if local4 then
                    say("\"I thought so!\"")
                else
                    say("\"Well, it does not matter. I am sure thou couldst quickly adapt.\"")
                end
                say("\"Officially, auditions have closed and the play is already cast. However, we need someone to understudy the role of the Avatar. Wouldst thou like to audition?\"")
                local5 = call_090AH()
                if local5 then
                    say("\"Excellent! What thou needest to do is to visit Gaye's Clothier Shoppe and purchase an Avatar costume. I can audition thee once I see thee in -proper- attire. Run along and do that, quickly now, I'm a busy man.\"*")
                    set_flag(103, true)
                    abort()
                else
                    say("\"No? Thou hast never dreamed of performing on the stage? Seeing thy name in torches? Donning the olde grease paint and wig? Bowing to thunderous applause? Well, begone then, I have not the time for chatting with the public.\"*")
                    abort()
                end
            elseif cmp_strings("Royal Theatre", 1) then
                say("\"'Tis a wonderful space, dost thou not think? 'Twas opened only last year, thanks to the sponsorship of a few wealthy citizens of our great city.\"")
                _RemoveAnswer("Royal Theatre")
                _AddAnswer({"citizens", "sponsorship"})
            elseif cmp_strings("sponsorship", 1) then
                say("\"The construction of the actual theatre building was paid for by the Royal Mint, but the theatre company relies solely on the support of individuals such as thyself. Wouldst thou like to make a modest contribution of, say, ten gold pieces to our theatre company?\"")
                local6 = call_090AH()
                if local6 then
                    local7 = callis_002B(true, -359, 644, 10)
                    if not local7 then
                        say("\"I thank thee. Thou hast shown thyself to be a true patron of the arts and a person of culture and refinement.\"")
                    else
                        say("\"Thine unconvincing performance gave thy game away! Thou dost not have ten gold pieces!\"")
                    end
                else
                    say("\"Give a man a loaf of bread and thou hast fed him for a day, give a man a play and perhaps thou hast fed his soul for a lifetime! Once thou hast seen one of our productions I am certain thou shalt reconsider.\"")
                end
                _RemoveAnswer("sponsorship")
            elseif cmp_strings("audition", 1) then
                if local2 == 7 then
                    local8 = call_0931H(-359, 838, 1, -356)
                    if local8 then
                        say("\"I see thou art ready? Very well. Take center stage, wouldst thou?\"")
                        call_08D1H()
                    else
                        say("\"Where is thy costume? Thou cannot audition without a costume!\"*")
                        abort()
                    end
                else
                    say("\"Come to the theatre during rehearsal hours, wouldst thou?\"*")
                    abort()
                end
            elseif cmp_strings("Miranda", 1) then
                say("Raymundo takes a deep breath and smiles.")
                say("\"Ah, lovely woman. 'Tis a pity she is more interested in politics than the stage. But I must say that we get along famously!\"")
                _RemoveAnswer("Miranda")
            elseif cmp_strings("Max", 1) then
                say("\"He is quite a character, is he not?\" Raymundo's face fills with pride.")
                say("\"Takes after his old man, I must say. He is sure to be a great actor. Or writer. Or director. Or producer.\"")
                _RemoveAnswer("Max")
            elseif cmp_strings("citizens", 1) then
                say("\"Well, I am really not at liberty to divulge the names of our patrons. But most of them belong to The Fellowship.\"")
                _RemoveAnswer("citizens")
                _AddAnswer({"Fellowship", "patrons"})
            elseif cmp_strings("patrons", 1) then
                say("\"These are people who contribute to our theatre. They come from all walks of life and have little in common besides a love of fine theatre.\"")
                _RemoveAnswer("patrons")
            elseif cmp_strings("Fellowship", 1) then
                say("\"For non-artists, they have given generous contributions to the theatre. They are -fine- people in my book!\" He rubs his hands with glee.")
                say("\"I am not a member, though.\"")
                _RemoveAnswer("Fellowship")
            elseif cmp_strings("bye", 1) then
                say("\"Leaving? Sorry, I do not give autographs.\"*")
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
            _ItemSay(local9, -27)
        else
            call_092EH(-27)
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