--- Best guess: Manages Kessler’s dialogue in Britain, an apothecary studying silver snake venom, offering to buy vials and sell potions, with warnings about venom’s dangers.
function func_04ED(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 1 then
        switch_talk_to(0, 237)
        var_0000 = unknown_003BH()
        var_0001 = unknown_001CH(unknown_001BH(237))
        var_0002 = get_lord_or_lady()
        var_0003 = unknown_0931H(359, 359, 649, 1, 357)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if var_0003 then
            add_answer("venom")
        end
        if not get_flag(177) then
            add_dialogue("You see a very authoritative-looking older man who looks at you with thoughtful concern.")
            set_flag(177, true)
        else
            add_dialogue("\"I am very glad thou hast come to see me again,\" says Kessler.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"My name is Kessler.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I run the apothecary shop here in Britain.\"")
                add_answer("apothecary")
            elseif answer == "apothecary" then
                add_dialogue("\"While the normal function of an apothecary is to administer potions and magical reagents, I am nowadays working almost exclusively for Lord British trying to study a specific problem.\"")
                remove_answer("apothecary")
                add_answer({"problem", "study", "potions"})
            elseif answer == "potions" then
                add_dialogue("\"They are certainly not a recent invention here in Britannia! Potions are liquids that possess certain magical qualities which are used for all sorts of purposes, such as the treatment of injury and disease. I have a quantity of them for sale if thou art interested.\"")
                remove_answer("potions")
                add_answer({"buy potions", "magical qualities"})
            elseif answer == "magical qualities" then
                add_dialogue("\"Since the mages have become so ineffective, we have been forced to develop other ways to accomplish all the things we used to be able to depend on mages to do. Unfortunately, many of these new methods are as yet untested.\"")
                remove_answer("magical qualities")
                add_answer("untested")
            elseif answer == "untested" then
                add_dialogue("\"We still know very little about the effects of most of the substances we use. Many cause more problems than they solve, or react differently if taken in unison with other elements. Some might cause thee to become dependent on them for thine health and some may simply be poisonous.\"")
                remove_answer("untested")
            elseif answer == "study" then
                add_dialogue("\"I am studying the effects of a particular substance known as silver snake venom. But I am encountering a number of difficulties.\"")
                remove_answer("study")
                add_answer({"difficulties", "silver snake"})
            elseif answer == "silver snake" then
                add_dialogue("\"As one may surmise from the name it is the venom taken from the dangerous silver snake. The fascination that many people possess for these creatures has created a great deal of curiosity about the venom itself.\"")
                remove_answer("silver snake")
                add_answer("curiosity")
            elseif answer == "curiosity" then
                add_dialogue("\"There are those who claim that gargoyles take the venom which results in their becoming enhanced in combat and such. Now this may be just a myth, but the curiosity people feel is real enough.\"")
                remove_answer("curiosity")
            elseif answer == "difficulties" then
                add_dialogue("\"My greatest difficulty is in finding any significant quantity of silver snake venom. But it is by no means mine only difficulty.\"")
                remove_answer("difficulties")
                add_answer({"other difficulties", "finding"})
            elseif answer == "finding" then
                add_dialogue("\"If by any chance thou wouldst come across any silver snake venom bring it back to me here. I shall pay thee fifty gold coins for every vial of it thou canst supply.\"")
                var_0004 = true
                remove_answer("finding")
            elseif answer == "other difficulties" then
                add_dialogue("\"People need to be alerted to how dangerous silver snake venom is. To this end I wish to announce my findings before Lord British and a consortium of lords and mayors, but to do that I must first finish my study.\"")
                remove_answer("other difficulties")
            elseif answer == "problem" then
                add_dialogue("\"Recently there has been a dramatic rise in the use of a very strange substance. People have begun to purposefully ingest the venom of the silver snake.\"")
                remove_answer("problem")
                add_answer("ingest")
            elseif answer == "ingest" then
                add_dialogue("\"The silver snake produces a venom that is extremely poisonous, but when taken in less than lethal amounts, it causes a variety of strange effects.\"")
                remove_answer("ingest")
                add_answer("effects")
            elseif answer == "effects" then
                add_dialogue("\"For a time the venom will heighten one's physical and mental performance, such as allowing one to work harder, for example. But after the effects have worn off, it will impair the user permanently.\"")
                remove_answer("effects")
                add_answer("impair")
            elseif answer == "impair" then
                add_dialogue("\"It first makes the user feel extremely tired and eventually causes a sloughing of the skin. The venom is a dangerous substance and thou shouldst not partake of it under any circumstances.\"")
                remove_answer("impair")
            elseif answer == "venom" then
                var_0005 = unknown_0028H(359, 359, 649, 357)
                var_0006 = var_0005 * 50
                if var_0005 == 0 then
                    add_dialogue("\"Thou dost not have any vials of venom!\"")
                elseif var_0005 == 1 then
                    add_dialogue("Kessler examines the vial carefully.")
                else
                    add_dialogue("Kessler examines the vials carefully.")
                end
                add_dialogue("He looks up at you and nods. \"This is indeed silver snake venom. I shall pay thee 50 gold coins per vial. All right?\"")
                if unknown_090AH() then
                    var_0007 = unknown_002BH(true, 359, 359, 649, var_0005)
                    if not var_0007 then
                        var_0008 = unknown_002CH(true, 359, 359, 644, var_0006)
                        if not var_0008 then
                            add_dialogue("Kessler opens his coinpurse and pays you " .. var_0006 .. " gold coins.")
                        else
                            add_dialogue("\"Thou art too burdened to carry any more money.\"")
                        end
                    else
                        add_dialogue("\"I see thou dost have a quantity of silver snake venom in thy possession. Perhaps we should talk further.\"")
                    end
                else
                    add_dialogue("\"Very well.\"")
                end
                remove_answer("venom")
            elseif answer == "buy potions" then
                if var_0001 ~= 7 then
                    add_dialogue("\"The Apothecary is closed. It is open from noon until midnight. Thou mayest return then.\"")
                else
                    add_dialogue("\"I always keep a fresh stock of ingredients and an inventory of prepared potions in case anyone should be in need of them. Wouldst thou like to buy one?\"")
                    var_0009 = unknown_090AH()
                    if var_0009 then
                        unknown_08A8H()
                    else
                        add_dialogue("\"Be sure to come back if thou dost ever need any potions.\"")
                    end
                end
                remove_answer("buy potions")
            elseif answer == "bye" then
                add_dialogue("\"It was good speaking with thee, " .. var_0002 .. ".\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(237)
    end
    return
end