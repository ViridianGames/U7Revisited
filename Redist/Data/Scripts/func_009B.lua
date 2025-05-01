-- Function 009B: Manages Ferryman's dialogue
function func_009B(itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid() == 1 then
        callis_0003(0, -285)
        local0 = call_08F7H(-2)
        local1 = call_08F7H(-3)
        local2 = call_0908H()
        if not get_flag(0x01B3) then
            add_dialogue("The hooded figure in the boat ignores you completely.")
            abort()
        end
        if not get_flag(0x0198) then
            callis_0005("sacrifice")
        end
        if not get_flag(0x01C3) then
            add_dialogue("Before you stands a tall, skeletal figure in a ghostly boat. He holds out his hand to you, and says in a sepulchral voice, \"I am the Ferryman of Skara Brae... Thou must pay two coins... to cross the Misty Channel.\"")
            set_flag(0x01C3, true)
        else
            if not get_flag(0x0197) then
                add_dialogue("The Ferryman of Skara Brae stands in his spectral boat, holding out his hand for any who would pay his price.")
            else
                add_dialogue("The Ferryman of Skara Brae stands in his spectral boat, holding his pole across his chest. He notices your approach. \"You need not pay... to return to the mainland.\"")
                callis_0005("return")
            end
            if not get_flag(0x01A3) then
                add_dialogue("He seems a bit disgruntled. \"I told you I would be here... until the end of eternity.\"")
            end
        end
        callis_0005({"bye", "Skara Brae", "Misty Channel", "Ferryman", "job", "name"})
        if not get_flag(0x0197) then
            callis_0005("pay")
        end
        while true do
            if cmp_strings("name", 0x00B5) then
                add_dialogue("\"I am... the Ferryman.\" His voice creaks like the rocking of the boat.")
                callis_0006("name")
            elseif cmp_strings("job", 0x00C1) then
                add_dialogue("The Ferryman doesn't respond at first, shaking his head from side to side in puzzlement. \"I am... the Ferryman.\"")
            elseif cmp_strings("Ferryman", 0x00D4) then
                add_dialogue("\"Yes, if you pay me... I can take you across the Misty Channel.\"")
                callis_0006("Ferryman")
            elseif cmp_strings("Misty Channel", 0x00E7) then
                add_dialogue("He turns to the side and waves his skeletal hand in a sweeping gesture over the water upon which his boat rests. \"This... is the Misty Channel.\"")
                callis_0006("Misty Channel")
            elseif cmp_strings("Skara Brae", 0x019A) then
                if not get_flag(0x0197) then
                    add_dialogue("He turns all the way around and points across the water to the west. \"There... \"")
                    if local0 and local1 then
                        callis_0003(0, -3)
                        add_dialogue("\"Er... ", local2, ", art thou sure we need to go over there?\"")
                        callis_0004(-3)
                        callis_0003(0, -2)
                        add_dialogue("\"What's the matter, Shamino? Art thou -afraid-?\"")
                        callis_0004(-2)
                        callis_0003(0, -3)
                        add_dialogue("\"Of course not! I just... well, I... oh, never mind! Let's go!\"")
                        callis_0004(-3)
                        local3 = call_08F7H(-1)
                        if local3 then
                            callis_0003(0, -1)
                            add_dialogue("Iolo's eyes narrow as he adopts a patronizing look on his face.~~\"And I suppose thou art without fear?\" he says to Spark.")
                            callis_0004(-1)
                            callis_0003(0, -2)
                            add_dialogue("\"No, sir. I am not afraid of a skeleton,\" he says. As he looks at the ferryman, however, he gulps.")
                            callis_0004(-2)
                        end
                        callis_0003(0, -285)
                    end
                else
                    add_dialogue("The gaunt figure looks around as if perplexed. \"This... is Skara Brae.\"")
                end
                callis_0006("Skara Brae")
            elseif cmp_strings("pay", 0x024F) then
                if not get_flag(0x0197) then
                    add_dialogue("\"Wilt thou pay my price... for passage to Skara Brae?\"")
                    local4 = call_090AH()
                    if local4 then
                        local5 = callis_002B(true, -359, -359, 644, 2)
                        if local5 then
                            add_dialogue("You place the coins in the shade's palm and his bony fingers close over them. \"Step aboard... if thou wouldst go... to the Isle of the Dead.\"")
                            call_0882H(itemref)
                        else
                            add_dialogue("\"I'll not cross... without proper payment.\"")
                        end
                    else
                        add_dialogue("\"Very well.\" He seems a little disappointed.")
                    end
                else
                    add_dialogue("\"Dost thou wish... to return to the mainland?\"")
                    local4 = call_090AH()
                    if local4 then
                        local6 = callis_001B(-144)
                        local7 = callis_0023()
                        local8 = callis_001B(-147)
                        if contains(local6, local7) or contains(local8, local7) then
                            add_dialogue("The Ferryman seems to smile beneath his hood as he motions for you to once more board his spectral boat.")
                            call_0882H(itemref)
                        else
                            add_dialogue("\"I may not carry spirits to the mainland.\" He holds his pole in front of himself, blocking your way onto the boat.")
                        end
                    else
                        add_dialogue("You think you see pale flames flicker in the depths of his cowl where his eyes should be. They fade as he sighs, \"No matter...\"")
                    end
                end
                callis_0006({"return", "pay"})
            elseif cmp_strings("sacrifice", 0x027B) then
                if not get_flag(0x0199) then
                    add_dialogue("Just for a moment you think you see a fleeting expression of hope cross the Ferryman's skeletal features, then it's gone. \"I must perform my duty... until the end of eternity.\"")
                    callis_0006("sacrifice")
                    set_flag(0x0199, true)
                else
                    add_dialogue("\"Do not taunt me... with hopes of release. I must perform my duty... until the end of eternity.\"")
                    callis_0006("sacrifice")
                end
            elseif cmp_strings("bye", 0x0288) then
                add_dialogue("Without acknowledging your goodbye, the Ferryman lowers his head and holds his pole across his chest.")
                abort()
            end
            break
        end
    elseif eventid() == 0 then
        abort()
    end
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end

function abort()
    -- Placeholder
end

function cmp_strings(str, addr)
    return false -- Placeholder
end

function contains(item, list)
    return false -- Placeholder
end

function eventid()
    return 0 -- Placeholder
end