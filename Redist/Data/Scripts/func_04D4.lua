-- Function 04D4: Yvella's dialogue and Catherine's arc
function func_04D4(eventid, itemref)
    -- Local variables (12 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    if eventid == 0 then
        call_092EH(-212)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(212, 0)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = false
    local3 = callis_0037(callis_001B(-203))
    local4 = "the Avatar"
    _AddAnswer({"bye", "Fellowship", "job", "name"})

    if get_flag(0x027E) and not get_flag(0x0285) then
        _AddAnswer("Catherine at noon")
    end
    if not get_flag(0x0286) then
        local5 = local0
    elseif not get_flag(0x0287) then
        local5 = local1
    end

    if not get_flag(0x0291) then
        say("The matronly woman you see has a look of concern on her face.~~\"Good day, ", local1, ". I am Yvella.\" She curtseys. \"Might I know thy name?\"")
        local6 = call_090BH({local4, local0})
        if local6 == local0 then
            say("\"Pleased to meet thee, ", local0, ".\"")
            set_flag(0x0286, true)
            local5 = local0
        elseif local6 == local4 then
            say("\"Now, now, ", local1, ", thou shouldst not lie like that.\"")
            set_flag(0x0287, true)
            local5 = local1
        end
        set_flag(0x0291, true)
    else
        say("\"Good day, ", local5, ".\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Yvella, ", local1, ".\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I take care of my daughter, Catherine, while Cador is at work.\"")
            if not local2 then
                _AddAnswer("Cador")
            end
            _AddAnswer("Catherine")
        elseif answer == "Fellowship" then
            say("\"Thou hast not heard of The Fellowship? It is a wonderful organization. They hold parades and festivals and have even built shelters for homeless folk throughout Britannia. Mine husband learned of them some time ago, and we have been happy members ever since.\"")
            if not local2 then
                _AddAnswer("husband")
            end
            _RemoveAnswer("Fellowship")
        elseif answer == "husband" or answer == "Cador" then
            if local3 then
                say("\"Cador is mine husband. He is the overseer at the Britannian Mining Company here in Vesper.\"")
                local7 = callis_003B()
                if local7 == 6 or local7 == 7 then
                    say("\"He is often at the tavern at this time. I do wish he would not go there every night with that... that... woman!\"")
                    _AddAnswer("woman")
                end
            else
                say("\"Cador was mine husband. He was the overseer at the Britannian Mining Company here in Vesper. I cannot believe he is gone,\" she sobs.~~ \"I told him again and again that tavern was a bad place to spend the evening. And now, he is dead, leaving me and Catherine without a husband and a father!\"")
            end
            _RemoveAnswer({"husband", "Cador"})
            _AddAnswer("Vesper")
            local2 = true
        elseif answer == "woman" then
            say("\"Her name is Mara. She is a fellow miner. She is very nice, but also very beautiful. I do not like mine husband spending all that time with her.\"")
            _RemoveAnswer("woman")
        elseif answer == "Vesper" then
            say("\"Well, it would be a lovely town if it were not for those... those... gargoyles. They are disgusting beings. I think Auston should have them run out of town.\"")
            _AddAnswer({"gargoyles", "Auston"})
            _RemoveAnswer("Vesper")
        elseif answer == "Auston" then
            say("\"He is our mayor. Eldroth recommended that we elect him, so, of course, we did. However, between the two of us, I think we ought to have someone new if Auston does not do something quickly. As a matter of fact, thou shouldst run for mayor, ", local1, ". What dost thou think? Wouldst thou like to run for mayor?\"")
            local8 = call_090AH()
            if local8 then
                say("\"I agree, thou ought to consider it.\"")
            else
                say("\"That is too bad. I believe thou wouldst be perfect for the office.\"")
            end
            _AddAnswer("Eldroth")
            _RemoveAnswer("Auston")
        elseif answer == "Eldroth" then
            say("\"He is our town advisor. Very wise man that Eldroth. He also sells provisions.\"")
            _RemoveAnswer("Eldroth")
        elseif answer == "gargoyles" then
            say("\"Perfectly wretched beasts. Thank goodness most of them stay on their side of the oasis. I do not know how Cador stands working with them. Well, for him, that is. There is only one who still works there.\"")
            local9 = callis_002C(true, -359, 2, 797, 1)
            if local9 then
                say("\"Here,\" she says fumbling through her robes. Finally, she finds a piece of parchment and hands it to you.")
            end
            _RemoveAnswer("gargoyles")
        elseif answer == "Catherine" then
            say("\"I worry about her. Every day at noon, she seems to disappear for a few hours. She has these foolish notions that gargoyles are friendly and honorable. I am afraid she may be visiting the other side of the oasis. Oh, I do hope not.\"")
            set_flag(0x027E, true)
            _RemoveAnswer("Catherine")
        elseif answer == "Catherine at noon" then
            say("\"Thou knowest where my daughter doth go at noon?\"")
            local10 = call_090AH()
            if local10 then
                say("\"Wilt thou tell me?\"")
                local11 = call_090AH()
                if local11 then
                    say("After you tell her, she responds, \"I knew it! That girl must be taught some sense. Associating with those vile creatures. Imagine!\" She shakes her head.")
                    if local3 then
                        say("\"Just wait until I tell her father about this! He and Mara will certainly take care of the situation.!\"")
                        calli_003F(-214)
                    else
                        say("\"If only her father were here today, he would show that loathsome creature his place!\"")
                    end
                    say("\"I thank thee, ", local5, ". I will put a stop to this right away!\"*")
                    set_flag(0x0285, true)
                    return
                else
                    say("After you tell her, she responds, \"I doubt that is true, ", local1, ", but I will look into the matter. I thank thee for thy concern.\"")
                end
            else
                say("\"Oh, well. I thank thee for thy concern.\"")
            end
            _RemoveAnswer("Catherine at noon")
        elseif answer == "bye" then
            say("\"Pleasant journey, ", local1, ".\"*")
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