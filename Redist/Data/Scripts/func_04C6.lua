-- Function 04C6: Jordan's bow seller dialogue and statue witness
function func_04C6(eventid, itemref)
    -- Local variables (8 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid == 0 then
        call_092EH(-198)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(198, 0)
    local0 = call_0909H()
    local1 = call_0908H()
    local2 = ""
    local3 = call_08F7H(-1)
    local4 = call_08F7H(-3)
    add_answer({"bye", "job", "name"})

    if not get_flag(0x025A) then
        local2 = local1
    elseif not get_flag(0x025B) then
        local2 = "Avatar"
    end

    if not get_flag(0x026F) then
        add_dialogue("You see a man who, despite being blind, quickly acknowledges you.~~\"I am Jordan. Sir Jordan. And thou art?\"")
        local6 = call_090BH({local0, local1})
        if local6 == local1 then
            add_dialogue("\"My pleasure, ", local1, ".\" He shakes your hand.")
            set_flag(0x025A, true)
        else
            add_dialogue("He laughs. \"Yes, but of course thou art.\"")
            set_flag(0x025B, true)
            if local3 then
                switch_talk_to(1, 0)
                add_dialogue("\"'Tis true, Sir Jordan. He is the Avatar.\"*")
                _HideNPC(-1)
                switch_talk_to(198, 0)
                add_dialogue("Jordan smiles. \"I see. And who wouldst thou be? Shamino?\"*")
                if not local4 then
                    switch_talk_to(1, 0)
                    add_dialogue("\"No.\" He points to Shamino. \"He is. I am Iolo!\"*")
                    _HideNPC(-1)
                    switch_talk_to(198, 0)
                else
                    switch_talk_to(1, 0)
                    add_dialogue("\"No. I am Iolo, not Shamino!\"*")
                    _HideNPC(-1)
                    switch_talk_to(198, 0)
                end
                add_dialogue("\"Of course!\" He says, patronizingly. \"How could I not recognize the great Iolo.\"")
            end
        end
        set_flag(0x026F, true)
    else
        add_dialogue("\"Greetings, ", local2, ".\"")
    end

    if get_flag(0x025E) and not get_flag(0x0261) then
        add_answer("statue")
    end

    add_answer({"bye", "job", "name"})

    if not get_flag(0x025A) then
        local2 = local1
    elseif not get_flag(0x025B) then
        local2 = "Avatar"
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"As I told thee, my name is Sir Jordan.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I sell bows and crossbows here at Iolo's South.\"")
            add_answer({"sell", "Iolo's South"})
        elseif answer == "Iolo's South" then
            add_dialogue("\"The original branch is in Britain. But I do fine business here in the Hold.\"")
            remove_answer("Iolo's South")
            add_answer({"Hold", "original branch"})
        elseif answer == "Hold" then
            add_dialogue("\"Serpent's Hold, ", local0, ". I have sold many quality bows to the knights here.\"")
            remove_answer("Hold")
            add_answer("knights")
        elseif answer == "original branch" then
            add_dialogue("\"The great archer himself, Iolo, started that branch more than two hundred years ago.\"")
            if local3 then
                add_dialogue("*")
                switch_talk_to(1, 0)
                add_dialogue("\"I, er, thank thee for thy compliment.\"*")
                switch_talk_to(198, 0)
                add_dialogue("\"'Twould mean more wert thou Iolo!\"*")
                switch_talk_to(1, 0)
                add_dialogue("\"Listen, here, rogue, I truly -am-...\"*")
                switch_talk_to(198, 0)
                add_dialogue("\"Yes, yes, I know. Thou really -art- Iolo... And I am Lord British!\"*")
                _HideNPC(-1)
            end
            remove_answer("original branch")
        elseif answer == "knights" then
            add_dialogue("\"There are many who live within the walls of the Hold. Sir Denton, the bartender at the Hallowed Dock, knows them all.\"")
            remove_answer("knights")
        elseif answer == "sell" then
            local7 = callis_001C(callis_001B(-198))
            if local7 == 7 then
                add_dialogue("\"Weapons or missiles?\"")
                _SaveAnswers()
                add_answer({"missiles", "weapons"})
            else
                add_dialogue("\"I am sorry, ", local0, ", but I can only sell things during my shop hours -- from 6 in the morning 'til 6 at night.\"")
            end
            remove_answer("sell")
        elseif answer == "weapons" then
            call_08A4H()
            remove_answer("weapons")
        elseif answer == "missiles" then
            call_08A3H()
            remove_answer("missiles")
        elseif answer == "statue" then
            add_dialogue("He looks defensive. \"I had nothing to do with that.~~ \"But, I will tell thee that, on the night of the incident, I heard the sounds of scuffling in the commons. And, later on in the evening, I heard a woman cry out, as if in surprise!\"")
            add_answer("woman")
            remove_answer("statue")
        elseif answer == "woman" then
            add_dialogue("\"I am not positive, ", local2, ", but I believe the voice was that of Lady Jehanne.\" He nods his head knowingly. \"Someone has lost their sense of unity.\"")
            remove_answer("woman")
            set_flag(0x025C, true)
        elseif answer == "bye" then
            add_dialogue("\"I hope to see thee again, ", local2, ".\"*")
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