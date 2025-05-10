--- Best guess: Manages Sean’s dialogue, handling his jewelry business, Fellowship involvement, and gem transactions, with flag-based progression and complex gem validation loops.
function func_043B(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012

    if eventid ~= 1 then
        if eventid == 0 then
            var_0001 = unknown_003BH()
            var_0002 = unknown_001CH(unknown_001BH(59))
            var_0011 = random2(4, 1)
            if var_0002 == 7 then
                if var_0011 == 1 then
                    var_0012 = "@Fine jewelry!@"
                elseif var_0011 == 2 then
                    var_0012 = "@Need gold trinkets?@"
                elseif var_0011 == 3 then
                    var_0012 = "@Fine gems!@"
                elseif var_0011 == 4 then
                    var_0012 = "@Fine crafted jewelry!@"
                end
                bark(var_0012, 59)
            else
                unknown_092EH(59)
            end
        end
        add_dialogue("\"I am sure thou must be on thy way.\" Sean smiles.")
        return
    end

    start_conversation()
    switch_talk_to(0, 59)
    var_0000 = get_lord_or_lady()
    var_0001 = unknown_003BH()
    var_0002 = unknown_001CH(unknown_001BH(59))
    var_0003 = unknown_0067H()
    if var_0001 == 7 then
        var_0004 = unknown_08FCH(26, 59)
        if var_0004 then
            add_dialogue("Sean is deep in concentration, listening to the Fellowship meeting.")
            return
        elseif get_flag(218) then
            add_dialogue("\"I cannot imagine where Batlin is. He never misses Fellowship meeting!\"")
        else
            add_dialogue("\"I must not stop to speak now! I am late for the Fellowship meeting!\"")
            return
        end
    end
    add_answer({"bye", "job", "name"})
    if not get_flag(188) then
        add_dialogue("You see a man whose boyish face is set with scrutinizing eyes that look as if they have seen much.")
        set_flag(188, true)
    else
        add_dialogue("\"And what may I do for thee, " .. var_0000 .. "?\" asks Sean.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"My name is Sean.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"When not tending to Fellowship affairs, I am a jeweller here in Britain. If thou dost wish to buy something, say so!\"")
            add_answer({"buy", "Britain", "jeweller", "Fellowship"})
        elseif cmps("jeweller") then
            add_dialogue("\"It is very delicate work. It requires a special touch that only a few have. Thou must know precisely how to handle precious materials. Only the finest of craftsmen become jewellers and they receive the highest compensation.\"")
            remove_answer("jeweller")
            add_answer({"finest craftsmen", "precious materials"})
        elseif cmps("precious materials") then
            add_dialogue("\"I constantly require new materials with which to create my very special jewelry. I am always in the market to buy gems. If thou dost ever come across any, I am the man to come to if thou shouldst want to sell them and make money.\"")
            remove_answer("precious materials")
            add_answer("gems")
        elseif cmps("finest craftsmen") then
            add_dialogue("\"As I have told thee, only the finest of craftsmen become jewellers, and I am the finest of jewellers. Does that not tell thee something?\" Sean sniffs. \"My business makes more money than the mint!\" He laughs forcibly.")
            remove_answer("finest craftsmen")
        elseif cmps("gems") then
            if var_0002 ~= 7 then
                add_dialogue("\"The jeweller's shop is currently closed for business. Come back later!\"")
            else
                add_dialogue("\"Dost thou have a gem for sale?\"")
                var_0005 = unknown_090AH()
                if var_0005 then
                    add_dialogue("\"I will pay thee 30 gold coins per gem. Is that price agreeable?\"")
                    var_0006 = unknown_090AH()
                    if var_0006 then
                        var_0007 = {13, 12}
                        for _, item in ipairs(var_0007) do
                            if unknown_0028H(item, 359, 760, 357) then
                                if item == 12 then
                                    add_dialogue("\"Dost thou think me a fool?! This little blue bauble is worthless!\"")
                                elseif item == 13 then
                                    add_dialogue("Sean's face tightens. \"This gem is small and dark as the heart of an unholy Liche. Away with it!\"")
                                end
                                return
                            end
                        end
                        var_000B = unknown_0028H(359, 359, 760, 357)
                        var_000C = var_000B * 30
                        var_000D = unknown_002BH(359, 359, 760, var_000B)
                        if var_000B == 0 then
                            add_dialogue("\"Thou dost have no gems! Thou art a liar! I will do no business with thee!\"")
                            return
                        end
                        if var_000B == 1 then
                            add_dialogue("\"I see that thou has one gem.\"")
                        elseif var_000B > 1 then
                            add_dialogue("\"I see that thou hast " .. var_000B .. " gems.\"")
                        end
                        var_000E = unknown_002CH(true, 359, 359, 644, var_000C)
                        if var_000E then
                            add_dialogue("\"Here is thy payment.\"")
                        else
                            add_dialogue("\"Thou art carrying too much to take thy payment!\"")
                            var_000F = unknown_002CH(true, 359, 359, 760, var_000B)
                        end
                    else
                        add_dialogue("\"It seems we have little left to discuss then.\"")
                    end
                else
                    add_dialogue("\"If thou dost have no gems for sale then do not even waste my time by mentioning it!\"")
                end
            end
            remove_answer("gems")
        elseif cmps("Fellowship") then
            if var_0003 then
                add_dialogue("\"I see thou art a member!\" Sean suddenly looks at you with a bit more respect. \"I am sure The Fellowship will do thee a world of good in the future.\" He smiles condescendingly.")
            else
                add_dialogue("\"Even thou mayest join The Fellowship and I can tell thee more about it.\"")
                unknown_0919H()
                add_dialogue("\"I can tell thee about The Fellowship's philosophy if thou dost wish.\"")
            end
            remove_answer("Fellowship")
            add_answer("philosophy")
        elseif cmps("philosophy") then
            add_dialogue("\"Thou art really interested in hearing more?\"")
            var_0010 = unknown_090AH()
            if var_0010 then
                unknown_091AH()
            else
                add_dialogue("\"I thought I was wasting my breath on thee.\"")
            end
            remove_answer("philosophy")
        elseif cmps("Britain") then
            add_dialogue("\"I moved mine entire business here to Britain to be near the main branch of The Fellowship. Thou hast no idea how much my business improved after I joined The Fellowship.\"")
            remove_answer("Britain")
            add_answer("Fellowship")
        elseif cmps("buy") then
            if var_0002 == 7 then
                add_dialogue("\"Wouldst thou like to buy something?\"")
                if unknown_090AH() then
                    unknown_08E3H()
                else
                    add_dialogue("\"Then please browse if thou dost like.\"")
                end
            else
                add_dialogue("\"Please come to the shop during normal business hours.\"")
            end
            remove_answer("buy")
        elseif cmps("bye") then
            break
        end
    end
    return
end