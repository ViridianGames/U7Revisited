require "U7LuaFuncs"
-- Function 04C4: Richter's armourer dialogue and blood evidence
function func_04C4(eventid, itemref)
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid == 0 then
        call_092EH(-196)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -196)
    local0 = call_0909H()
    local1 = call_0908H()
    local2 = ""
    local3 = callis_001B(-196)
    local4 = callis_001C(local3)
    _AddAnswer({"bye", "Fellowship", "job", "name"})

    if not get_flag(0x0266) then
        local2 = local1
    elseif not get_flag(0x0267) then
        local2 = local0
    end

    if not get_flag(0x026D) then
        say("You see a dashing young man, who turns to greet you.~~\"I am Richter, a knight of the Hold. Who wouldst thou be?\"")
        local5 = call_090BH({local0, local1})
        if local5 == local1 then
            say("\"I am happy to meet thee, ", local1, ".\"")
            local2 = local1
            set_flag(0x0266, true)
        else
            say("\"I see,\" he eyes you suspiciously. \"Thou art back for more, then? Thou'lt not trick me again, I warn thee.\"")
            local2 = local0
            set_flag(0x0267, true)
            _AddAnswer("more")
        end
        set_flag(0x026D, true)
    else
        say("\"Hello, ", local2, ",\" says Richter.")
    end

    if get_flag(0x025E) and not get_flag(0x0261) then
        _AddAnswer("statue")
    end
    if get_flag(0x025F) and not get_flag(0x0265) and not get_flag(0x027B) and not get_flag(0x0279) then
        _AddAnswer("gargoyle blood")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"As I have told thee, I am called Richter.\"")
            set_flag(0x027B, true)
            _RemoveAnswer("name")
            if get_flag(0x025F) and not get_flag(0x0265) and not get_flag(0x0279) then
                _AddAnswer("gargoyle blood")
            end
        elseif answer == "more" then
            say("He clears his throat and examines you more closely.~~\"Ah, thou shouldst not mind my mumblings, ", local2, ".\"")
            _AddAnswer("I mind")
            _RemoveAnswer("more")
        elseif answer == "job" then
            say("\"I am the armourer of the Hold.\"")
            _AddAnswer({"Hold", "weapons", "armour"})
        elseif answer == "Hold" then
            say("\"Yes, thou art in Serpent's Hold, home to many noble and valiant knights.\"")
            _RemoveAnswer("Hold")
            _AddAnswer("knights")
        elseif answer == "knights" then
            say("\"Lord John-Paul is charged with overseeing the Hold, though Sir Horffe is actually the captain of the guard. The rest of us, of course, are here to serve Lord British and the needs of Britannia.\"")
            _RemoveAnswer("knights")
            _AddAnswer({"needs", "Horffe", "John-Paul"})
        elseif answer == "gargoyle blood" then
            say("\"I should have known 'twould be Horffe.\" His eyes narrow. \"He has continually demonstrated an overall lack of morals and sense of unity. I will speak with John-Paul about this.\"")
            local6 = true
            _RemoveAnswer("gargoyle blood")
        elseif answer == "John-Paul" then
            say("\"I trust his ability as I trust no other. I cannot tell thee how proud I was when he chose me to be his second in command!\"")
            _RemoveAnswer("John-Paul")
        elseif answer == "Horffe" then
            say("He appears thoughtful. \"I know the others trust him, and I, myself, do not doubt his fighting skills. But I cannot escape this feeling that he needs more moral discipline. I feel obligated to watch him at times.\"")
            _RemoveAnswer("Horffe")
            _AddAnswer({"watch", "others"})
        elseif answer == "watch" then
            say("\"I am not certain what it is that I am watching for. However, I expect him to fall into ways either aggressive or thieving. He simply does not seem to truly believe in the unity of the Hold.\"")
            _RemoveAnswer("watch")
        elseif answer == "others" then
            say("\"Well, it is obvious that John-Paul respects his abilities. Lady Tory has told me that she can sense his honesty, but I am not without skepticism.\"")
            _RemoveAnswer("others")
            _AddAnswer({"sense", "Tory"})
        elseif answer == "sense" then
            say("\"Lady Tory has the uncanny ability to empathize with others. She can determine another's intentions and emotions by doing nothing more than passing a simple greeting.\"")
            _RemoveAnswer("sense")
        elseif answer == "Tory" then
            say("\"She is the Hold advisor, often giving guidance to the knights.\" His expression becomes wistful. \"She is also quite, quite beautiful.\"")
            _RemoveAnswer("Tory")
        elseif answer == "needs" then
            say("\"Well, obviously there is many a vile beast looking to terrorize the countryside on the mainland. 'Tis our duty to protect the common man. In addition, we are here to provide examples of proper behavior to the general populace.\"")
            _RemoveAnswer("needs")
        elseif answer == "I mind" then
            say("Looking down, he shifts his weight from foot to foot for a moment. Glancing back up, eyes narrowed, he says, ~~\"Not long ago a man entered mine armoury who claimed to be the Avatar, just as thou dost claim. When I turned to reach for a weapon he had requested, he purloined several items and ran away.~~\"I assume,\" he says carefully, \"thou art not that rogue.\"")
            _RemoveAnswer("I mind")
        elseif answer == "armour" or answer == "weapons" then
            if local4 == 7 or local4 == 13 then
                if answer == "armour" then
                    call_08D4H()
                else
                    call_08D3H()
                end
            else
                say("\"I am sorry. A better time to discuss this would be when my shop is open.\"")
            end
            _RemoveAnswer(answer)
        elseif answer == "Fellowship" then
            local7 = callis_0067()
            if local7 then
                say("\"Why, yes, I see thou art a member too.\"")
            else
                call_0919H()
            end
            _RemoveAnswer("Fellowship")
            _AddAnswer("philosophy")
        elseif answer == "philosophy" then
            call_091AH()
            _RemoveAnswer("philosophy")
        elseif answer == "statue" then
            say("A look of disgust appears on his face.~~\"Obviously, someone who doth not seek unity did this! He is not worthy of reward!\"~~After a moment, he calms down.")
            if not get_flag(0x0259) then
                say("\"Art thou investigating this crime against mankind?\"")
                local8 = call_090AH()
                if local8 then
                    say("\"Then let me give thee these.\" He holds up some stone chips. \"They were found at the base of the statue. Thou wilt notice that they are stained red in some places. I believe it to be blood.\"")
                    local9 = callis_002C(false, 4, -359, 815, 1)
                    if local9 then
                        set_flag(0x0259, true)
                    else
                        say("\"Mayhap when thou hast more room I can give them to thee.\"")
                    end
                else
                    say("\"I see.\"")
                end
            end
            _RemoveAnswer("statue")
        elseif answer == "bye" then
            say("\"Pleasant journeys. Remember, trust thy brother.\"*")
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