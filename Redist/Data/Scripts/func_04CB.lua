-- Function 04CB: Cador's miner dialogue and Fellowship enthusiasm
function func_04CB(eventid, itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(203, 0)
    local0 = call_0909H()
    local1 = call_0908H()
    local2 = "the Avatar"
    local3 = callis_003B()
    local4 = callis_001B(-203)
    local5 = callis_001B(-204)
    local6 = callis_001C(local4)
    local7 = callis_003C(local4)
    _AddAnswer({"Fellowship", "bye", "job", "name"})

    if local7 == 2 then
        calli_001D(0, local4)
        calli_001D(0, local5)
    end

    if not get_flag(0x0284) then
        _AddAnswer("Elizabeth and Abraham")
    end

    if not get_flag(0x0288) then
        say("You see a broad-shouldered man with a solemn look about him.")
        set_flag(0x0288, true)
    else
        say("\"Yes, ", local0, "?\" says Cador.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("The man shakes your hand. \"I am Cador.\"")
            if local6 == 26 then
                say("\"And thy name is?\"")
                local8 = call_090BH({local0, local1, local2})
                if local8 == local2 then
                    say("\"What? Dost thou mean to tell me that thou art the one who brought those gargoyles to our precious land?\" He turns quite angry.~~\"Daemon lover!\"*")
                    calli_001D(0, local4)
                    calli_003D(2, local4)
                    calli_001D(0, local5)
                    calli_003D(2, local5)
                    return
                else
                    say("\"I am happy to make thine acquaintance, ", local0, ".\"")
                end
            end
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I oversee the local branch of the Britannian Mining Company in Vesper. We mine many different minerals.\"")
            _AddAnswer({"minerals", "We", "Vesper"})
        elseif answer == "minerals" then
            say("\"Gold and lead.\"")
            _RemoveAnswer("minerals")
        elseif answer == "Vesper" then
            say("\"That is the name of our town. Liana at town hall can give thee any more information that thou mightest need, but I have lived here with my family since the branch opened.\"")
            _AddAnswer({"family", "Liana"})
            _RemoveAnswer("Vesper")
        elseif answer == "Fellowship" then
            say("\"It is a wonderful organization. They perform many works of charity and special events -- parades and such.\" He points to his medallion. \"As thou canst see, I am a member. I fully believe in the triad of inner strength.\"")
            if not get_flag(0x0284) then
                say("\"As a matter of fact, two Fellowship officials were just here. They said it was important to see how a town's economy worked before starting a branch in that town. Dost thou realize what that means?\" He smiles proudly. \"They are going to build a Fellowship branch here in Vesper.\"")
            end
            _AddAnswer("triad")
            _RemoveAnswer("Fellowship")
        elseif answer == "triad" then
            say("\"Those are The Fellowship's three basic principles: Strive for Unity, Trust thy Brother, and Worthiness Precedes Reward.\"")
            _RemoveAnswer("triad")
        elseif answer == "Elizabeth and Abraham" then
            say("\"They were the two Fellowship officials that were here! They only stayed for a minute or two. I have no idea where they are now.\"")
            _RemoveAnswer("Elizabeth and Abraham")
        elseif answer == "We" then
            say("\"I work with Mara and a gargoyle named Lap-Lem.\"")
            _AddAnswer({"Lap-Lem", "Mara"})
            _RemoveAnswer("We")
        elseif answer == "Mara" then
            say("\"She is a fantastic worker. Better than most men I have mined with.\"")
            _RemoveAnswer("Mara")
        elseif answer == "Lap-Lem" then
            say("\"Well, for a gargoyle, he is not too lazy. He works much harder than that other one who left, Anmanivas. But I would fain let him go if we did not need the extra hand.\"")
            _RemoveAnswer("Lap-Lem")
        elseif answer == "Liana" then
            say("\"She keeps the records at town hall.\"")
            _RemoveAnswer("Liana")
        elseif answer == "family" then
            say("\"Yes, my wife, Yvella, and my daughter, Catherine.\"")
            _RemoveAnswer("family")
        elseif answer == "bye" then
            say("\"It has been a pleasure, ", local0, ".\"*")
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