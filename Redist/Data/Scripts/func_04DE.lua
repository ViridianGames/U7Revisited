-- Function 04DE: Glenno's manager dialogue and Fellowship slip
function func_04DE(eventid, itemref)
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid == 0 then
        local0 = callis_003B()
        local7 = callis_001C(callis_001B(-222))
        local8 = callis_Random2(4, 1)
        if local7 == 11 and (local0 == 5 or local0 == 7 or local0 == 0) then
            if local8 == 1 then
                local9 = "@Wine and women!@"
            elseif local8 == 2 then
                local9 = "@Need a girl, sailor?@"
            elseif local8 == 3 then
                local9 = "@How about a stud, lady?@"
            elseif local8 == 4 then
                local9 = "@Relax here in The Baths!@"
            end
            _ItemSay(local9, -222)
        else
            call_092EH(-222)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(222, 0)
    local0 = callis_003B()
    local1 = callis_0067()
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x02AB) then
        say("You see a handsome, muscular man with an air of mischief about him.")
        set_flag(0x02AB, true)
    else
        say("\"Yes, may I help thee?\" Glenno asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"Glenno at thy service!\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am the manager of The Baths.\"")
            if local0 == 6 or local0 == 7 or local0 == 0 then
                say("\"The entrance fee is 300 gold. Everything is included in this fixed price. No tips are necessary. Dost thou want to enter?\"")
                local2 = call_090AH()
                if not local2 then
                    say("\"Well, some other time, then! Thou wilt not be sorry if thou dost! It is well worth the price.\"*")
                    return
                end
                local3 = callis_0028(-359, -359, 644, -357)
                if local3 >= 300 then
                    local4 = callis_002C(false, 4, 251, 641, 1)
                    if local4 then
                        say("\"Excellent! Here is thy key!\"")
                        callis_002B(true, -359, -359, 644, 300)
                    else
                        say("\"Thine hands are too full to carry the key!\"*")
                        return
                    end
                else
                    say("\"What art thou trying to pull? Thou hast not 300 gold!\"*")
                    return
                end
                say("\"Enter! Please relax! Enjoy thyself! Allow one of our hosts or hostesses to make thy stay more comfortable.\"")
                if not local1 then
                    say("He notices your medallion. \"Fellowship members are especially welcome!\"")
                    _AddAnswer("Fellowship")
                end
                say("\"Please! Make thyself at home. If thou dost want a drink, let me know.\"")
                local5 = call_08F7H(-2)
                if not local5 then
                    say("\"Uhm, wait a minute. How old art thou, boy?\"*")
                    switch_talk_to(2, 0)
                    say("\"Uhm, eighteen.\"*")
                    switch_talk_to(222, 0)
                    say("\"Thou dost not look eighteen.\"*")
                    switch_talk_to(2, 0)
                    say("\"All right, I am sixteen.\"*")
                    switch_talk_to(222, 0)
                    say("\"Thou dost not look sixteen either. Well, never mind. Thou canst enter. But make sure the management doth not see thee.\" Glenno scratches his head. \"Yes, but... no! I am the management! All right, come on. Just don't cause any trouble.\"*")
                    switch_talk_to(2, 0)
                    say("\"All right! Wenches!\"*")
                    _HideNPC(-2)
                    local6 = call_08F7H(-1)
                    if not local6 then
                        switch_talk_to(1, 0)
                        say("Iolo whispers to you, \"Methinks young Spark hath learned a lot whilst adventuring with thee!\"*")
                        _HideNPC(-1)
                    end
                    switch_talk_to(222, 0)
                end
                _AddAnswer({"drink", "The Baths"})
            else
                say("\"Please come visit in the late evening hours when our hosts and hostesses are here!\"")
            end
        elseif answer == "The Baths" then
            say("\"The Baths exist for the pleasure of visitors to Buccaneer's Den. Thou canst bathe in our spring pools. Thou canst lounge in our Community Room and socialize with our attractive hosts or hostesses. Thou canst drink fine wine and ale. Thou canst view our collection of fine artwork. Thou canst... escape into a dream-world!\"")
            _AddAnswer({"fine artwork", "Community Room", "hosts or hostesses", "spring pools"})
            _RemoveAnswer("The Baths")
        elseif answer == "drink" then
            call_088FH()
        elseif answer == "hosts or hostesses" then
            say("\"They have come from all over Britannia to serve thine every wish! I, Glenno, have assured them that The Baths is the most prestigious establishment of its kind anywhere in the known world. It is probably the only establishment of its kind in the known world!\"")
            _RemoveAnswer("hosts or hostesses")
        elseif answer == "spring pools" then
            say("\"The water is guaranteed to be pure, warm and cleansing.\"")
            _RemoveAnswer("spring pools")
        elseif answer == "Community Room" then
            say("\"Thou canst lie in comfort among the many soft cushions and pillows. Get to know thy neighbor. Get to know thy neighbor 'very well'!\"")
            _RemoveAnswer("Community Room")
        elseif answer == "fine artwork" then
            say("\"Ah, yes, those are erotic masterpieces from the brush of Britannian artist Glen Johnson. Notice how the curves on that one are extremely naturalistic, dost thou not agree?\"")
            _RemoveAnswer("fine artwork")
        elseif answer == "Fellowship" then
            say("\"Yes, I am a member. If it were not for The Fellowship, I would not be manager of The Baths! I served the group well, trusted my many brothers, strived for unity, and... well, my worthiness preceded my reward! And all of this... was my reward!\" Glenno smiles as if he were a tomcat who had just swallowed a mouse.")
            _AddAnswer("reward")
            _RemoveAnswer("Fellowship")
        elseif answer == "reward" then
            say("\"Yes, The Fellowship gave me this place. They own it, thou knowest.\" Suddenly Glenno holds his hand to his mouth, as if he has said something he shouldn't. \"I mean, The Fellowship only owns the -land- on which it was built. I -built- The Baths with money with which I was rewarded by The Fellowship. So, enough of that -- enjoy thyself. I must tend to business!\" With that, Glenno turns away from you.*")
            _RemoveAnswer("reward")
            return
        elseif answer == "bye" then
            say("\"Leaving so soon?\"*")
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