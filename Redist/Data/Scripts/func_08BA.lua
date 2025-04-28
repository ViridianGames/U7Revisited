require "U7LuaFuncs"
-- Function 08BA: Manages fortune-telling dialogue
function func_08BA()
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    local0 = callis_005A()
    say("The fortune vill cost thee 20 gold. All right?")
    local1 = call_090AH()

    if local1 then
        local2 = callis_002B(true, -359, -359, 644, 20)
        if local2 then
            say("Margareta takes your money.")
        else
            say("Thou dost not have enough gold.")
            say("Margareta turns away from you.")
            abort()
        end
    else
        say("Never mind, then.")
        say("Margareta turns away from you.")
        abort()
    end

    callis_002E(0, 31)
    say("The gypsy woman peers into her crystal ball.")
    if not local0 then
        if not get_flag(0x00E2) then
            say("I see a voman standing by a shrine. She is in love vith thee. I do not see more on this subject.")
        else
            say("I see a voman standing by a shrine. She vill play an important role in thy life.")
        end
    end
    say("Hmmm... The crystal ball is very murky...")
    if not get_flag(0x0006) then
        say("I see that thou must join The Fellowship if thou vantest to learn more about them and discover their true nature.")
    else
        say("Now that thou art a Fellowship member, thou vilt learn more about them and discover their true nature in due time.")
    end
    say("It is not very clear... ah, yes... there is a new evil that threatens Britannia. I see that thou shalt have to reckon vith it in the future.")
    say("The crystal ball tells me that the ether ov the vorld -- the substance that controls magic -- has been affected by this new evil presence.")
    say("I see further that this evil presence vill gain greater power during an event in the near future. This event has something to do vith the planets. Seek out a man at the observatory in Moonglow to learn more about this. I see that he has a device which will be very useful to thee. See him soon, for this event is drawing near.")
    say("Vhat is this? I see... I see... thou dost seek a Man vith a Hook. He is not thy true adversary, but finding him vill be necessary to complete thine ultimate quest.")
    say("Vait! I see that thou must seek audience vith the Time Lord. He is in trouble, although I cannot see vhat that trouble is. The Time Lord knows much about this new evil, so do not fail to seek him out.")
    say("To find the Time Lord, thou must first meet the Visps who live in the forest ov Yew. They are thy best link to him. The monks ov Empath Abbey may know how to contact the Visps.")
    say("The ball has grown dark. I see no more.")
    say("Margareta looks up at you and says, \"Thou dost face many dangers ahead. Take care.\"")
    say("With those words, Margareta slumps and closes her eyes to rest. She is obviously exhausted.")

    if not get_flag(0x0100) then
        call_0911H(50)
    end
    set_flag(0x0100, true)

    return
end

-- Helper functions
function say(...)
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