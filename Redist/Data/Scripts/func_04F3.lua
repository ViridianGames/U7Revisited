-- Function 04F3: Malloy's miner dialogue and tunnel project
function func_04F3(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid == 0 then
        return
    end

    switch_talk_to(243, 0)
    local0 = call_0909H()
    local1 = call_08F7H(-239)
    local2 = call_08F7H(-1)
    local3 = call_08F7H(-3)
    local4 = call_08F7H(-4)
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x02BD) then
        say("You see before you a short, roly-poly man with a pompous smirk on his face. He is holding a lantern in one hand and a dirty spoon in the other.")
        set_flag(0x02BD, true)
    else
        say("\"Hello, good friend,\" says Malloy. \"A pleasure to see thee again.\"")
    end

    if not get_flag(0x02D9) then
        _AddAnswer("helmet on foot")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            if not get_flag(0x02DA) then
                say("\"My name is Malloy. Pleased to make thine acquaintance.\" Malloy bows politely.")
                if local1 then
                    if not get_flag(0x02BC) then
                        say("Malloy's face carries an exasperated smirk. \"My partner over there is Owings,\" he says, pointing to Owings, the skinny man digging away next to him. \"Where are thy manners?! Say hello to our visitor!\"")
                    else
                        say("\"Thou dost already know my partner over there,\" he says, pointing to Owings.")
                    end
                    switch_talk_to(239, 0)
                    say("\"Hello there!\" says Owings, giving you a big smile. The front of his mining helmet falls down over his eyes. Blinded, he gropes the air around him.*")
                    _HideNPC(-239)
                    switch_talk_to(243, 0)
                    say("Malloy shakes his head sadly.*")
                end
            else
                say("Malloy regains his composure. \"Hello there, I am Malloy. I do apologize for my partner's childish antics.\"")
            end
            _RemoveAnswer("name")
        elseif answer == "job" then
            if not local1 then
                say("\"Normally my job is to dig, but as my partner Owings seems to be missing I suppose my job is to look for him. I hope nothing has happened to the little fellow.\"")
            else
                say("\"Owings and myself are working as mining engineers, a position we were fortunate enough to have acquired quite recently. We are working on a special project for the Britannian Mining Company.\"*")
                switch_talk_to(239, 0)
                if not get_flag(0x02DA) then
                    say("Owings gives a big nod, throwing his head back and snapping it straight down. \"That is absolutely right, Malloy.\"*")
                else
                    say("\"That is absolutely right, Malloy,\" says Owings. He gives a big nod which causes his helmet to fall down over his eyes.*")
                end
                _HideNPC(-239)
                switch_talk_to(243, 0)
                _AddAnswer({"special project", "mining engineers"})
            end
        elseif answer == "mining engineers" then
            say("\"My partner and I are not exactly mining engineers, although we did travel to Minoc to become miners. We came here with a map...\"*")
            switch_talk_to(239, 0)
            say("\"It was the map that the funny man dressed like the Avatar sold us!\"*")
            _HideNPC(-239)
            switch_talk_to(243, 0)
            say("\"That is correct. But when we got here we discovered that the Britannian Mining Company owned the rights to this area of land already!\"*")
            switch_talk_to(239, 0)
            say("\"That funny man dressed like the Avatar lied to us.\" Owings scratches his head thoughtfully. \"The Britannian Mining Company wanted to throw us in the prisons of Yew for claim jumping!\"*")
            _HideNPC(-239)
            switch_talk_to(243, 0)
            say("\"I was able to convince them that we would be more valuable to the Britannian Mining Company if we could come to work for them.\" Malloy beams proudly.*")
            _RemoveAnswer("mining engineers")
            _AddAnswer({"funny man", "map"})
        elseif answer == "map" then
            say("\"We paid nearly a hundred gold pieces for that map. It was supposed to lead to a spot of valuable minerals found over a hundred years ago. It was a terrific investment. The map was an antique, but it looked like it could not have been more than a few years old! Thou dost not see preservation like that every day!\"")
            _RemoveAnswer("map")
        elseif answer == "funny man" then
            say("\"Someone told us his name. Let me see if I can remember it... Sullivan, I think it was. Funny name for an Avatar, but there thou art!\"")
            _RemoveAnswer("funny man")
        elseif answer == "special project" then
            say("\"Owings and myself are now involved in a very important special project, but it is a secret. Can we trust thee?\"")
            local5 = call_090AH()
            if not local5 then
                say("\"In that case I thank thee for thine honesty. I do not really mind if a person is untrustworthy. But someone who is untrustworthy and dishonest about it, that is something that I cannot abide.\"*")
                switch_talk_to(239, 0)
                say("You see Owings nod his head most enthusiastically. A second later he has a very confused expression on his face.*")
                _HideNPC(-239)
                switch_talk_to(243, 0)
            else
                say("\"The Britannian Mining Company has asked us to dig a tunnel to New Magincia! It will revolutionize the mining industry.\"")
                switch_talk_to(239, 0)
                say("\"They do not want anybody to find out about it. They said that bringing more mining equipment over here would just make people suspicious, so they told us to start by using these spoons!\" Owings proudly holds up his spoon to show it to you. He smiles.")
                _HideNPC(-239)
                switch_talk_to(243, 0)
                say("\"Yes, it was such a special project they told us we were the only ones they could think of who would even attempt to do such a thing!\" Malloy beams proudly. \"Well come on, Owings, we had best get back to work. We have a schedule to meet.\"")
                _RemoveAnswer("special project")
                _AddAnswer({"schedule", "tunnel"})
            end
        elseif answer == "tunnel" then
            say("Malloy looks at you and puts a finger to his lips. \"Shhhhhhhh!!! I asked thee not to speak of this to anyone!\"")
            _RemoveAnswer("tunnel")
        elseif answer == "schedule" then
            say("\"Owings, have a look at that schedule and find out how we are doing.\"")
            switch_talk_to(239, 0)
            say("Owings bends over and goes to pick up a very large scroll. As he touches the tip of it he sends it rolling away down the mineshaft. As it rolls away it is unravelling leaving a lengthy trail of paper behind it. Owings chases after it but succeeds in doing little else but tangling up his legs in the long roll of the paper. When at last he has the other end, it is an unreadable mess.")
            _HideNPC(-239)
            switch_talk_to(243, 0)
            say("\"Give me that!\" says Malloy as he snatches a piece of the scroll away. He examines it for a moment. \"According to this we shall be finished in... one hundred and seventy three years! Owings, we have got to start working faster!\" The two of them go back to digging with their spoons. As they dig Malloy turns to Owings and says, \"This is another fine mess thou hast gotten me into!\"")
            _RemoveAnswer("schedule")
        elseif answer == "helmet on foot" then
            say("Malloy kicks out with his foot, trying to dislodge the helmet which is stuck there. He looks at Owings and pouts, \"Why dost thou not do something to help me?!\"")
            switch_talk_to(239, 0)
            say("Owings grabs the helmet on Malloy's foot and attempts to dislodge it. After several fierce tugs it comes off with a loud popping noise. Owings pulls the helmet right into his own face and this makes a loud knocking noise.")
            call_000FH(83)
            _HideNPC(-239)
            switch_talk_to(243, 0)
            say("Malloy goes hurling backwards, crying out in panic. He smacks the back of his head on the rock wall behind him. He takes off his crumpled helmet and points to it. \"A good thing I was wearing this or I might have been hurt!\" With that a loose rock tumbles down from the ceiling landing squarely on his head. Malloy says \"Ooooooh!\" Owings breaks into a giggling fit. Malloy flashes you an incredulous pouting grimace.")
            call_000FH(15)
            _RemoveAnswer("helmet on foot")
        elseif answer == "bye" then
            if local1 then
                say("Both Malloy and Owings stop what they are doing and give you a friendly goodbye wave.*")
            else
                say("\"Good day to thee, ", local0, ".\"*")
            end
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