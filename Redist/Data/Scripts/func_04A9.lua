require "U7LuaFuncs"
-- Function 04A9: Alina's shelter dialogue and Weston's plight
function func_04A9(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid == 0 then
        call_092EH(-169)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -169)
    local0 = call_0909H()
    local1 = callis_0067()
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0222) then
        say("You see a simple peasant woman. Her face is etched with sorrow.")
        set_flag(0x0222, true)
    else
        say("\"Good day, ", local0, ",\" says Alina.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Alina.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I have none, ", local0, ", save for being the mother of my child. I am waiting for mine husband, Weston, to return from Britain.\"")
            _AddAnswer({"Weston", "child"})
        elseif answer == "child" then
            say("\"Cassie is my daughter. Just a wee babe, she is mine only joy.\"")
            _RemoveAnswer("child")
        elseif answer == "Weston" then
            if get_flag(0x00CC) then
                say("\"Good news, ", local0, "! Mine husband was pardoned by Lord British. He even provided Weston with short-term employment so that he may return to me with money enough in his pockets to feed us for some time!~~\"Excellent news, no?\"")
            else
                say("\"Mine husband is imprisoned in Britain for stealing fruit from the Royal Orchards.\"")
                _AddAnswer("stealing")
            end
            _RemoveAnswer("Weston")
        elseif answer == "stealing" then
            say("\"Mine husband is no thief, ", local0, ". He went there to buy fruit for the child and me so that we would have enough to eat. He has been wrongfully accused, I am certain of it!\"")
            _AddAnswer("eat")
            _RemoveAnswer("stealing")
        elseif answer == "eat" then
            say("\"We are very poor. My baby and I are presently living in the Fellowship shelter because we have nowhere else to go.\"")
            _AddAnswer({"shelter", "Fellowship"})
            _RemoveAnswer("eat")
        elseif answer == "Fellowship" then
            if local1 then
                say("\"It was a member of The Fellowship that has accused mine husband. Now they wish for me to join them.\"")
                _AddAnswer({"accused", "join them"})
            else
                say("\"Mine husband is innocent, I know it!. He intended to buy the fruit. Why must I join thy society in order for me to be taken at my word?\"")
            end
            _RemoveAnswer("Fellowship")
        elseif answer == "shelter" then
            say("\"We are fortunate that we are able to live by The Fellowship's good graces, but I do not know how long we will be allowed to stay.\"")
            _AddAnswer("allowed")
            _RemoveAnswer("shelter")
        elseif answer == "join them" then
            say("\"I cannot join The Fellowship without feeling that I am betraying mine husband. How could I become one of those who have falsely accused him? Yet, if I do not, they will not allow my child and me to live here.\"~~She sobs and covers her face with her hands. \"It is so unfair. I must choose between starvation and betrayal. If only Weston were here. I do not know what to do!\"")
            _RemoveAnswer("join them")
        elseif answer == "accused" then
            say("\"They say if I join they will attempt to free mine husband. But it was they who unjustly accused him. I cannot trust them, but I fear I may have no choice.\"")
            _RemoveAnswer("accused")
        elseif answer == "allowed" then
            say("\"They tell me the shelter is only for members of The Fellowship. Unless I join soon, I shall be asked to leave. And I have nowhere else to go.\"")
            _RemoveAnswer("allowed")
        elseif answer == "bye" then
            say("\"Pleasant day to thee, ", local0, ".\"*")
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