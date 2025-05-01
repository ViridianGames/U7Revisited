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

    switch_talk_to(196, 0)
    local0 = call_0909H()
    local1 = call_0908H()
    local2 = ""
    local3 = callis_001B(-196)
    local4 = callis_001C(local3)
    add_answer({"bye", "Fellowship", "job", "name"})

    if not get_flag(0x0266) then
        local2 = local1
    elseif not get_flag(0x0267) then
        local2 = local0
    end

    if not get_flag(0x026D) then
        add_dialogue("You see a dashing young man, who turns to greet you.~~\"I am Richter, a knight of the Hold. Who wouldst thou be?\"")
        local5 = call_090BH({local0, local1})
        if local5 == local1 then
            add_dialogue("\"I am happy to meet thee, ", local1, ".\"")
            local2 = local1
            set_flag(0x0266, true)
        else
            add_dialogue("\"I see,\" he eyes you suspiciously. \"Thou art back for more, then? Thou'lt not trick me again, I warn thee.\"")
            local2 = local0
            set_flag(0x0267, true)
            add_answer("more")
        end
        set_flag(0x026D, true)
    else
        add_dialogue("\"Hello, ", local2, ",\" says Richter.")
    end

    if get_flag(0x025E) and not get_flag(0x0261) then
        add_answer("statue")
    end
    if get_flag(0x025F) and not get_flag(0x0265) and not get_flag(0x027B) and not get_flag(0x0279) then
        add_answer("gargoyle blood")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"As I have told thee, I am called Richter.\"")
            set_flag(0x027B, true)
            remove_answer("name")
            if get_flag(0x025F) and not get_flag(0x0265) and not get_flag(0x0279) then
                add_answer("gargoyle blood")
            end
        elseif answer == "more" then
            add_dialogue("He clears his throat and examines you more closely.~~\"Ah, thou shouldst not mind my mumblings, ", local2, ".\"")
            add_answer("I mind")
            remove_answer("more")
        elseif answer == "job" then
            add_dialogue("\"I am the armourer of the Hold.\"")
            add_answer({"Hold", "weapons", "armour"})
        elseif answer == "Hold" then
            add_dialogue("\"Yes, thou art in Serpent's Hold, home to many noble and valiant knights.\"")
            remove_answer("Hold")
            add_answer("knights")
        elseif answer == "knights" then
            add_dialogue("\"Lord John-Paul is charged with overseeing the Hold, though Sir Horffe is actually the captain of the guard. The rest of us, of course, are here to serve Lord British and the needs of Britannia.\"")
            remove_answer("knights")
            add_answer({"needs", "Horffe", "John-Paul"})
        elseif answer == "gargoyle blood" then
            add_dialogue("\"I should have known 'twould be Horffe.\" His eyes narrow. \"He has continually demonstrated an overall lack of morals and sense of unity. I will speak with John-Paul about this.\"")
            local6 = true
            remove_answer("gargoyle blood")
        elseif answer == "John-Paul" then
            add_dialogue("\"I trust his ability as I trust no other. I cannot tell thee how proud I was when he chose me to be his second in command!\"")
            remove_answer("John-Paul")
        elseif answer == "Horffe" then
            add_dialogue("He appears thoughtful. \"I know the others trust him, and I, myself, do not doubt his fighting skills. But I cannot escape this feeling that he needs more moral discipline. I feel obligated to watch him at times.\"")
            remove_answer("Horffe")
            add_answer({"watch", "others"})
        elseif answer == "watch" then
            add_dialogue("\"I am not certain what it is that I am watching for. However, I expect him to fall into ways either aggressive or thieving. He simply does not seem to truly believe in the unity of the Hold.\"")
            remove_answer("watch")
        elseif answer == "others" then
            add_dialogue("\"Well, it is obvious that John-Paul respects his abilities. Lady Tory has told me that she can sense his honesty, but I am not without skepticism.\"")
            remove_answer("others")
            add_answer({"sense", "Tory"})
        elseif answer == "sense" then
            add_dialogue("\"Lady Tory has the uncanny ability to empathize with others. She can determine another's intentions and emotions by doing nothing more than passing a simple greeting.\"")
            remove_answer("sense")
        elseif answer == "Tory" then
            add_dialogue("\"She is the Hold advisor, often giving guidance to the knights.\" His expression becomes wistful. \"She is also quite, quite beautiful.\"")
            remove_answer("Tory")
        elseif answer == "needs" then
            add_dialogue("\"Well, obviously there is many a vile beast looking to terrorize the countryside on the mainland. 'Tis our duty to protect the common man. In addition, we are here to provide examples of proper behavior to the general populace.\"")
            remove_answer("needs")
        elseif answer == "I mind" then
            add_dialogue("Looking down, he shifts his weight from foot to foot for a moment. Glancing back up, eyes narrowed, he says, ~~\"Not long ago a man entered mine armoury who claimed to be the Avatar, just as thou dost claim. When I turned to reach for a weapon he had requested, he purloined several items and ran away.~~\"I assume,\" he says carefully, \"thou art not that rogue.\"")
            remove_answer("I mind")
        elseif answer == "armour" or answer == "weapons" then
            if local4 == 7 or local4 == 13 then
                if answer == "armour" then
                    call_08D4H()
                else
                    call_08D3H()
                end
            else
                add_dialogue("\"I am sorry. A better time to discuss this would be when my shop is open.\"")
            end
            remove_answer(answer)
        elseif answer == "Fellowship" then
            local7 = callis_0067()
            if local7 then
                add_dialogue("\"Why, yes, I see thou art a member too.\"")
            else
                call_0919H()
            end
            remove_answer("Fellowship")
            add_answer("philosophy")
        elseif answer == "philosophy" then
            call_091AH()
            remove_answer("philosophy")
        elseif answer == "statue" then
            add_dialogue("A look of disgust appears on his face.~~\"Obviously, someone who doth not seek unity did this! He is not worthy of reward!\"~~After a moment, he calms down.")
            if not get_flag(0x0259) then
                add_dialogue("\"Art thou investigating this crime against mankind?\"")
                local8 = call_090AH()
                if local8 then
                    add_dialogue("\"Then let me give thee these.\" He holds up some stone chips. \"They were found at the base of the statue. Thou wilt notice that they are stained red in some places. I believe it to be blood.\"")
                    local9 = callis_002C(false, 4, -359, 815, 1)
                    if local9 then
                        set_flag(0x0259, true)
                    else
                        add_dialogue("\"Mayhap when thou hast more room I can give them to thee.\"")
                    end
                else
                    add_dialogue("\"I see.\"")
                end
            end
            remove_answer("statue")
        elseif answer == "bye" then
            add_dialogue("\"Pleasant journeys. Remember, trust thy brother.\"*")
            return
        end
    end

    return
end

-- Helper functions
function add_dialogue(...)
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