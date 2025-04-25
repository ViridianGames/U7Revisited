-- Function 04ED: Kessler's apothecary dialogue and venom transactions
function func_04ED(eventid, itemref)
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid == 0 then
        call_092EH(-237)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -237)
    local0 = callis_003B()
    local1 = callis_001C(callis_001B(-237))
    local2 = call_0909H()
    _AddAnswer({"bye", "job", "name"})
    local3 = call_0931H(1, -359, 649, 1, -357)
    if local3 then
        _AddAnswer("venom")
    end

    if not get_flag(0x00B1) then
        say("You see a very authoritative-looking older man who looks at you with thoughtful concern.")
        set_flag(0x00B1, true)
    else
        say("\"I am very glad thou hast come to see me again,\" says Kessler.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"My name is Kessler.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I run the apothecary shop here in Britain.\"")
            _AddAnswer("apothecary")
        elseif answer == "apothecary" then
            say("\"While the normal function of an apothecary is to administer potions and magical reagents, I am nowadays working almost exclusively for Lord British trying to study a specific problem.\"")
            _RemoveAnswer("apothecary")
            _AddAnswer({"problem", "study", "potions"})
        elseif answer == "potions" then
            say("\"They are certainly not a recent invention here in Britannia! Potions are liquids that possess certain magical qualities which are used for all sorts of purposes, such as the treatment of injury and disease. I have a quantity of them for sale if thou art interested.\"")
            _RemoveAnswer("potions")
            _AddAnswer({"buy potions", "magical qualities"})
        elseif answer == "magical qualities" then
            say("\"Since the mages have become so ineffective, we have been forced to develop other ways to accomplish all the things we used to be able to depend on mages to do. Unfortunately, many of these new methods are as yet untested.\"")
            _RemoveAnswer("magical qualities")
            _AddAnswer("untested")
        elseif answer == "untested" then
            say("\"We still know very little about the effects of most of the substances we use. Many cause more problems than they solve, or react differently if taken in unison with other elements. Some might cause thee to become dependent on them for thine health and some may simply be poisonous.\"")
            _RemoveAnswer("untested")
        elseif answer == "study" then
            say("\"I am studying the effects of a particular substance known as silver snake venom. But I am encountering a number of difficulties.\"")
            _RemoveAnswer("study")
            _AddAnswer({"difficulties", "silver snake"})
        elseif answer == "silver snake" then
            say("\"As one may surmise from the name it is the venom taken from the dangerous silver snake. The fascination that many people possess for these creatures has created a great deal of curiosity about the venom itself.\"")
            _RemoveAnswer("silver snake")
            _AddAnswer("curiosity")
        elseif answer == "curiosity" then
            say("\"There are those who claim that gargoyles take the venom which results in their becoming enhanced in combat and such. Now this may be just a myth, but the curiosity people feel is real enough.\"")
            _RemoveAnswer("curiosity")
        elseif answer == "difficulties" then
            say("\"My greatest difficulty is in finding any significant quantity of silver snake venom. But it is by no means mine only difficulty.\"")
            _RemoveAnswer("difficulties")
            _AddAnswer({"other difficulties", "finding"})
        elseif answer == "finding" then
            say("\"If by any chance thou wouldst come across any silver snake venom bring it back to me here. I shall pay thee fifty gold coins for every vial of it thou canst supply.\"")
            local4 = true
            _RemoveAnswer("finding")
        elseif answer == "other difficulties" then
            say("\"People need to be alerted to how dangerous silver snake venom is. To this end I wish to announce my findings before Lord British and a consortium of lords and mayors, but to do that I must first finish my study.\"")
            _RemoveAnswer("other difficulties")
        elseif answer == "problem" then
            say("\"Recently there has been a dramatic rise in the use of a very strange substance. People have begun to purposefully ingest the venom of the silver snake.\"")
            _RemoveAnswer("problem")
            _AddAnswer("ingest")
        elseif answer == "ingest" then
            say("\"The silver snake produces a venom that is extremely poisonous, but when taken in less than lethal amounts, it causes a variety of strange effects.\"")
            _RemoveAnswer("ingest")
            _AddAnswer("effects")
        elseif answer == "effects" then
            say("\"For a time the venom will heighten one's physical and mental performance, such as allowing one to work harder, for example. But after the effects have worn off, it will impair the user permanently.\"")
            _RemoveAnswer("effects")
            _AddAnswer("impair")
        elseif answer == "impair" then
            say("\"It first makes the user feel extremely tired and eventually causes a sloughing of the skin. The venom is a dangerous substance and thou shouldst not partake of it under any circumstances.\"")
            _RemoveAnswer("impair")
        elseif answer == "venom" then
            local5 = callis_0028(-359, -359, 649, -357)
            local6 = local5 * 50
            if local5 == 0 then
                say("\"Thou dost not have any vials of venom!\"")
            else
                if local5 == 1 then
                    say("Kessler examines the vial carefully. ")
                else
                    say("Kessler examines the vials carefully. ")
                end
                say("He looks up at you and nods. \"This is indeed silver snake venom. I shall pay thee 50 gold coins per vial. All right?\"")
                if call_090AH() then
                    local7 = callis_002B(true, -359, -359, 649, local5)
                    if local7 then
                        local8 = callis_002C(true, -359, -359, 644, local6)
                        if local8 then
                            say("Kessler opens his coinpurse and pays you ", local6, " gold coins.")
                        else
                            say("\"Thou art too burdened to carry any more money.\"")
                        end
                    else
                        say("\"I see thou dost have a quantity of silver snake venom in thy possession. Perhaps we should talk further.\"")
                    end
                else
                    say("\"Very well.\"")
                end
            end
            _RemoveAnswer("venom")
        elseif answer == "buy potions" then
            if local1 ~= 7 then
                say("\"The Apothecary is closed. It is open from noon until midnight. Thou mayest return then.\"")
            else
                say("\"I always keep a fresh stock of ingredients and an inventory of prepared potions in case anyone should be in need of them. Wouldst thou like to buy one?\"")
                local9 = call_090AH()
                if local9 then
                    call_08A8H()
                else
                    say("\"Be sure to come back if thou dost ever need any potions.\"")
                end
            end
            _RemoveAnswer("buy potions")
        elseif answer == "bye" then
            say("\"It was good speaking with thee, ", local2, ".\"*")
            return
        end
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end