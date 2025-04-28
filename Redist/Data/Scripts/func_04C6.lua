require "U7LuaFuncs"
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

    _SwitchTalkTo(0, -198)
    local0 = call_0909H()
    local1 = call_0908H()
    local2 = ""
    local3 = call_08F7H(-1)
    local4 = call_08F7H(-3)
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x025A) then
        local2 = local1
    elseif not get_flag(0x025B) then
        local2 = "Avatar"
    end

    if not get_flag(0x026F) then
        say("You see a man who, despite being blind, quickly acknowledges you.~~\"I am Jordan. Sir Jordan. And thou art?\"")
        local6 = call_090BH({local0, local1})
        if local6 == local1 then
            say("\"My pleasure, ", local1, ".\" He shakes your hand.")
            set_flag(0x025A, true)
        else
            say("He laughs. \"Yes, but of course thou art.\"")
            set_flag(0x025B, true)
            if local3 then
                _SwitchTalkTo(0, -1)
                say("\"'Tis true, Sir Jordan. He is the Avatar.\"*")
                _HideNPC(-1)
                _SwitchTalkTo(0, -198)
                say("Jordan smiles. \"I see. And who wouldst thou be? Shamino?\"*")
                if not local4 then
                    _SwitchTalkTo(0, -1)
                    say("\"No.\" He points to Shamino. \"He is. I am Iolo!\"*")
                    _HideNPC(-1)
                    _SwitchTalkTo(0, -198)
                else
                    _SwitchTalkTo(0, -1)
                    say("\"No. I am Iolo, not Shamino!\"*")
                    _HideNPC(-1)
                    _SwitchTalkTo(0, -198)
                end
                say("\"Of course!\" He says, patronizingly. \"How could I not recognize the great Iolo.\"")
            end
        end
        set_flag(0x026F, true)
    else
        say("\"Greetings, ", local2, ".\"")
    end

    if get_flag(0x025E) and not get_flag(0x0261) then
        _AddAnswer("statue")
    end

    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x025A) then
        local2 = local1
    elseif not get_flag(0x025B) then
        local2 = "Avatar"
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"As I told thee, my name is Sir Jordan.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I sell bows and crossbows here at Iolo's South.\"")
            _AddAnswer({"sell", "Iolo's South"})
        elseif answer == "Iolo's South" then
            say("\"The original branch is in Britain. But I do fine business here in the Hold.\"")
            _RemoveAnswer("Iolo's South")
            _AddAnswer({"Hold", "original branch"})
        elseif answer == "Hold" then
            say("\"Serpent's Hold, ", local0, ". I have sold many quality bows to the knights here.\"")
            _RemoveAnswer("Hold")
            _AddAnswer("knights")
        elseif answer == "original branch" then
            say("\"The great archer himself, Iolo, started that branch more than two hundred years ago.\"")
            if local3 then
                say("*")
                _SwitchTalkTo(0, -1)
                say("\"I, er, thank thee for thy compliment.\"*")
                _SwitchTalkTo(0, -198)
                say("\"'Twould mean more wert thou Iolo!\"*")
                _SwitchTalkTo(0, -1)
                say("\"Listen, here, rogue, I truly -am-...\"*")
                _SwitchTalkTo(0, -198)
                say("\"Yes, yes, I know. Thou really -art- Iolo... And I am Lord British!\"*")
                _HideNPC(-1)
            end
            _RemoveAnswer("original branch")
        elseif answer == "knights" then
            say("\"There are many who live within the walls of the Hold. Sir Denton, the bartender at the Hallowed Dock, knows them all.\"")
            _RemoveAnswer("knights")
        elseif answer == "sell" then
            local7 = callis_001C(callis_001B(-198))
            if local7 == 7 then
                say("\"Weapons or missiles?\"")
                _SaveAnswers()
                _AddAnswer({"missiles", "weapons"})
            else
                say("\"I am sorry, ", local0, ", but I can only sell things during my shop hours -- from 6 in the morning 'til 6 at night.\"")
            end
            _RemoveAnswer("sell")
        elseif answer == "weapons" then
            call_08A4H()
            _RemoveAnswer("weapons")
        elseif answer == "missiles" then
            call_08A3H()
            _RemoveAnswer("missiles")
        elseif answer == "statue" then
            say("He looks defensive. \"I had nothing to do with that.~~ \"But, I will tell thee that, on the night of the incident, I heard the sounds of scuffling in the commons. And, later on in the evening, I heard a woman cry out, as if in surprise!\"")
            _AddAnswer("woman")
            _RemoveAnswer("statue")
        elseif answer == "woman" then
            say("\"I am not positive, ", local2, ", but I believe the voice was that of Lady Jehanne.\" He nods his head knowingly. \"Someone has lost their sense of unity.\"")
            _RemoveAnswer("woman")
            set_flag(0x025C, true)
        elseif answer == "bye" then
            say("\"I hope to see thee again, ", local2, ".\"*")
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