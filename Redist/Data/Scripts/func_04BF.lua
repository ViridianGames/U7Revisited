require "U7LuaFuncs"
-- Function 04BF: Martingo's eccentric Sultan dialogue and Ethereal Ring quest
function func_04BF(eventid, itemref)
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid == 0 then
        call_092EH(-191)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -191)
    local0 = callis_IsPlayerFemale()
    local1 = call_0908H()
    _AddAnswer({"bye", "job", "name"})

    if get_flag(0x023B) then
        _AddAnswer({"Ethereal Ring"})
    end

    if not get_flag(0x0256) then
        say("You see a nobleman, all alone, with a demented gleam in his eye.~~\"Who in blazes art thou?\" the man asks. His attitude is that of someone who was just interrupted from something terribly important.")
        local2 = call_090BH({"I am the Avatar", local1})
        if local2 == local1 then
            say("Martingo shakes your hand but acts thoroughly disinterested. \"I'm thrilled.\"")
            say("He turns to his right and speaks to no one.")
            say("\"What? Oh, really! I do not think ", local1, " looks particularly brainless. We shall have to see, shall we not?\"")
            say("He turns back to you and grins.")
        else
            say("\"Of course thou art! And I am the evil spirit of Mondain, come back to wreak havoc over all Britannia. Funny, thou dost not look like an Avatar -- thou dost look like a fool.\"")
            if local0 then
                say("\"What can I do for thee, Miss Fool?\"")
            else
                say("\"What can I do for thee, Mr. Fool?\"")
            end
            say("He turns to his right and speaks to no one.")
            say("\"What? Oh, really! Thou dost think this Avatar looks like the real thing? I doubt it, Lucinda. I doubt it very much.\"")
            say("He turns back to you and grins.")
        end
        set_flag(0x0256, true)
    else
        say("\"What'chu want?\" Martingo asks, belligerently.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("The nobleman looks at you with impatience. \"I am Martingo, the Sultan of Spektran. Is that all right with thee?\" He rolls his eyes. He turns to his right side and whispers again to an imaginary person, \"I believe we have an ignoramus on our hands.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am the Sultan of Spektran! What, is thy brain the size of a pea? Do not answer, 'twas a rhetorical question.\"")
            if local0 then
                say("He turns to his left side and whispers to no one, \"Dost thou not think her brain is the size of a pea? I do!\" He giggles conspiratorially with his invisible friend.")
            else
                say("He turns to his left side and whispers again to an imaginary person, \"Dost thou not think his brain is the size of a pea? I do!\" He giggles conspiratorially with his invisible friend.")
            end
            say("Martingo then pulls out a banana and begins to peel it.")
            _AddAnswer({"banana", "Spektran", "Sultan"})
        elseif answer == "Sultan" then
            say("\"Come on, do not insult mine intelligence. Surely thou dost know what a Sultan is! Canst not thou see mine harem?\"")
            local3 = call_090AH()
            if local3 then
                say("\"Lovely, are they not?\"")
            else
                say("Martingo looks bewildered. \"Then thou must have thine eyes examined! I am surrounded by ten...\" He looks around quickly. \"No, -eleven- beautiful women!\"")
            end
            say("\"Each day I enjoy a different one. Thou canst not imagine how much fun being a Sultan really is!\" He leans over and kisses an invisible cheek. \"Today, I am enjoying Lucinda.\" He grins broadly.")
            _AddAnswer("Lucinda")
            if local0 then
                say("Martingo looks you up and down lecherously. \"Hmmm. Wouldst thou like to join mine harem?\"")
                local4 = call_090AH()
                if local4 then
                    say("Your answer takes Martingo by surprise. \"Thou wouldst?\" He looks around nervously. \"Oh, uhm, I had better consult mine astrologer about this matter. I shall get back to thee, all right?\"")
                else
                    say("\"Pity.\"")
                end
            end
            _RemoveAnswer("Sultan")
        elseif answer == "Spektran" then
            say("\"'Tis the island thou dost stand upon!\" He turns to the invisible person on his left and whispers, \"Thou art correct -- this person really is a fool!\" ~~Martingo turns back to you. \"As I said, I am the Sultan here. I am the master of all of these subjects.\" He gestures around the room.")
            local5 = call_08F7H(-1)
            if local5 then
                _SwitchTalkTo(0, -1)
                say("Iolo whispers to you. \"This fellow is quite daft. Be careful.\"")
                call_092FH(-1)
                _SwitchTalkTo(0, -191)
            end
            _RemoveAnswer("Spektran")
        elseif answer == "Lucinda" then
            say("\"She is beautiful, is she not?\" Martingo leans over and sticks his tongue in an ear that isn't there.")
            _RemoveAnswer("Lucinda")
        elseif answer == "banana" then
            if not get_flag(0x0258) then
                say("\"Oh, forgive my manners! Wouldst thou like a banana?\"")
                local6 = call_090AH()
                if local6 then
                    say("\"Well, it shall cost thee 3 gold coins. Still want one?\"")
                    local7 = call_090AH()
                    if local7 then
                        local8 = callis_0028(-359, -359, 644, -357)
                        if local8 >= 3 then
                            local9 = callis_002C(true, 17, -359, 377, 1)
                            if local9 then
                                say("\"Here thou art.\" Martingo hands you a banana and takes your gold. He turns to 'Lucinda' and whispers, \"That rotter took my last banana!\"")
                                set_flag(0x0258, true)
                            else
                                say("\"Thou dost have wheat for brains! Thou hast not room for a single banana!\"")
                            end
                        else
                            say("\"Broke, art thou? Too bad.\" Martingo sniffs. \"Well, I am very rich, I must say.\"")
                        end
                    else
                        say("\"That's a relief. I only had one left.\"")
                    end
                else
                    say("\"That's a relief. I only had one left.\"")
                end
            else
                say("\"I already sold thee my last banana!\"")
            end
            _RemoveAnswer("banana")
        elseif answer == "Ethereal Ring" then
            say("Martingo looks suspicious. \"Art thou wanting to steal mine Ethereal Ring?\" He turns to his imaginary friend and whispers, \"Thou wert right. Our guest looks like a thief.\" He turns back to you and smiles. \"Yes, I do have an Ethereal Ring. I purchased it from the King of the Gargoyles. What was his name?\" He leans toward the invisible companion on his right. \"What? Oh yes, Draxinusom. I knew it all the time.\" He turns back to you. \"It is in my vault.\"")
            _RemoveAnswer("Ethereal Ring")
            _AddAnswer("vault")
        elseif answer == "vault" then
            say("Martingo's eyes light up. \"My vault is the most protected vault in all Britannia. No one, and I repeat, -no one- can steal anything from my vault. I have many fine treasures there.\" He turns to 'Lucinda' and bites an nonexistent ear lobe.")
            _RemoveAnswer("vault")
            _AddAnswer({"protected", "treasures"})
        elseif answer == "treasures" then
            say("\"I collect magical items. The vault is full of them. Including this ring thou dost mention.\"")
            _RemoveAnswer("treasures")
        elseif answer == "protected" then
            say("\"The vault's security is my secret. Feel free to try and enter it. In fact, I dare thee! If thou canst succeed in getting inside, thou art welcome to take anything!\" Martingo laughs. \"All thou dost need is the key!\" He laughs with his imaginary harem, as if they were all laughing with him. \"I'm sure thou wilt find it!\" He breaks up, laughing so hard that tears begin to fall down his cheeks.")
            _RemoveAnswer("protected")
        elseif answer == "bye" then
            say("\"Fine. Go away. It shall do thee good!\"*")
            break
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