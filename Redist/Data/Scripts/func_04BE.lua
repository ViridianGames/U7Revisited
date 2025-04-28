require "U7LuaFuncs"
-- Function 04BE: Betra's provisioner dialogue and Fellowship skepticism
function func_04BE(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid == 0 then
        call_092FH(-190)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -190)
    local0 = false
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x024F) then
        say("The gargoyle welcomes you by making a sweeping motion with his open hand.")
        set_flag(0x024F, true)
    else
        say("\"To welcome you again, human,\" says Betra.")
    end

    if not get_flag(0x0251) and get_flag(0x023E) then
        _AddAnswer("Quaeven")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be named Betra. To be new to Terfin?\"")
            local1 = call_090AH()
            if local1 then
                say("\"To tell you to talk to Teregus, the sage or Forbrak, the tavernkeeper, for information about town. To help with building locations and residents.\"")
            else
                say("\"To welcome you back to Terfin.\"")
            end
            _RemoveAnswer("name")
            _AddAnswer({"Betra", "Terfin"})
            set_flag(0x0251, true)
            if get_flag(0x023E) and not local0 then
                _AddAnswer("Quaeven")
            end
        elseif answer == "Betra" then
            say("\"To be the word for `small valor.'\"")
            _RemoveAnswer("Betra")
        elseif answer == "job" then
            say("\"To be the seller of provisions.\"")
            _AddAnswer("buy")
        elseif answer == "Terfin" then
            say("\"To be the town set aside for us gargoyles who wish to reside in our own culture.\"")
            _AddAnswer({"culture", "set aside"})
            _RemoveAnswer("Terfin")
        elseif answer == "culture" then
            say("\"To have many things unique to our race -- other than our appearance -- that distinguish us from humans. To be different, but also equal.\"")
            _RemoveAnswer("culture")
        elseif answer == "set aside" then
            say("\"To have been put here by the humans. To be permitted to leave, and also to reside elsewhere, but to know that many humans do not like us.\"")
            _AddAnswer("dislike")
            _RemoveAnswer("set aside")
        elseif answer == "dislike" then
            say("\"To be very ironic. To say that the only town with an equal number of humans and gargoyles is the one where most racial conflicts occur.\" ~~He shrugs. \"To have been unwise, perhaps, to put so many differences together. To be sad times.\"")
            _RemoveAnswer("dislike")
        elseif answer == "buy" then
            local2 = callis_001C(callis_001B(-190))
            if local2 == 7 then
                call_0853H()
            else
                say("\"To sell to you during the hours of 9 in the morning and 6 in the evening. To be sorry, but to sell nothing before or after those hours.\"")
            end
        elseif answer == "Quaeven" then
            say("He smiles at the mention of the name.~~ \"To be a likable young gargoyle.\"")
            local0 = true
            _AddAnswer("join Fellowship?")
            _RemoveAnswer("Quaeven")
        elseif answer == "join Fellowship?" then
            say("\"To join The Fellowship?\" He shakes his head. \"To be an organization not for me. To be quite happy as I am, devoted to the altars. To believe Quaeven to have been misled by the others in The Fellowship. To not trust them, especially Sarpling.\"")
            _AddAnswer({"altars", "Sarpling", "misled"})
            _RemoveAnswer("join Fellowship?")
        elseif answer == "misled" then
            say("\"To believe that there is deceit from The Fellowship, and to expect that is not what it appears. To believe promises of happiness made when Quaeven first joined came true from Quaeven, himself, not The Fellowship.\"")
            _RemoveAnswer("misled")
        elseif answer == "Sarpling" then
            say("\"To trust him as far as I could throw him, and to certainly throw him as far as I could.\"")
            _RemoveAnswer("Sarpling")
        elseif answer == "altars" then
            say("\"To have heard the rumors about destroying the altars. To be upset, but to have no evidence.~~ \"To know that only two gargoyles have easy access to such weapons. To be one of those gargoyles, and to know Sarpling is the other.\"")
            _RemoveAnswer("altars")
        elseif answer == "bye" then
            say("\"To wish you safe travels, human.\"*")
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