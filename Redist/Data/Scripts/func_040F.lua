require "U7LuaFuncs"
-- Function 040F: Manages Eiko's dialogue and interactions
function func_040F(itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid() == 0 then
        abort()
    end
    _SwitchTalkTo(0, -15)
    local0 = call_0909H()
    local1 = call_08F7H(-48)
    if not get_flag(708) then
        say("You see a stunningly attractive oriental woman. She is armed to the teeth.")
        set_flag(708, true)
    else
        say("\"Thou dost wish to speak with me again?\" asks Eiko.")
    end
    if get_flag(732) and not get_flag(733) then
        _AddAnswer("Stay thine hand!")
    end
    _AddAnswer({"bye", "job", "name"})
    while true do
        if cmp_strings("name", 1) then
            say("\"My name is Eiko.\"")
            _RemoveAnswer("name")
        elseif cmp_strings("job", 1) then
            if not get_flag(733) then
                say("\"I have no job. I have a quest. My quest is shared with mine half-sister, Amanda.\"")
                _AddAnswer("quest")
            else
                say("\"We are leaving this dungeon now that our quest is over.\"")
            end
            _AddAnswer("Amanda")
        elseif cmp_strings("quest", 1) then
            say("\"Eighteen years ago my father was murdered by a cyclops called Iskander Ironheart. Mine half-sister Amanda and I are his only surviving kin and we have vowed to avenge him.\"")
            set_flag(731, true)
            _RemoveAnswer("quest")
            _AddAnswer({"Iskander", "father"})
        elseif cmp_strings("father", 1) then
            say("\"Our father was a mage named Kalideth. He was working to find a cause of the disturbances of the ethereal waves that have been preventing magic from working for the past twenty years and more, as well as the madness that has afflicted all mages since then.\"")
            if local1 then
                _SwitchTalkTo(0, -48)
                say("\"Our father was a wise and kind man. His death was a loss for all of Britannia.\" She sniffs.")
                if not get_flag(733) then
                    say("\"His killer deserves to die.\"")
                end
                _HideNPC(-48)
                _SwitchTalkTo(0, -15)
            end
            _RemoveAnswer("father")
        elseif cmp_strings("Amanda", 1) then
            say("\"Neither one of us knew that the other existed until after the death of our father.\"")
            if local1 then
                _SwitchTalkTo(0, -48)
                say("\"I had always felt like I had a sister somewhere. But I attributed those feelings to the natural loneliness a child feels upon losing a father. Learning about each other has been the only good thing that has happened to me since father's death.\"")
                _HideNPC(-48)
                _SwitchTalkTo(0, -15)
            end
            _RemoveAnswer("Amanda")
        elseif cmp_strings("Iskander", 1) then
            say("\"Yes, I know I am not pronouncing it correctly. I understand he has a more human nickname that is actually a translation from the ancient cyclops language. But I do not know what it is.\"")
            _RemoveAnswer("Iskander")
        elseif cmp_strings("Stay thine hand!", 1) then
            say("You explain to Eiko what you have learned. Kalideth had gone mad when he fought with Iskander and the source of what is causing the problems with magic and the mage's minds was the thing that really killed Kalideth!")
            say("\"Then if thou hast discovered the true force that killed my father, my vengeance against Kalideth would be unjust.\"")
            if local1 then
                _SwitchTalkTo(0, -48)
                if not get_flag(734) then
                    say("\"How canst thou say that? I thought that thou wert my sister? Thou art a traitor!\"")
                    _HideNPC(-48)
                    _SwitchTalkTo(0, -15)
                end
                set_flag(733, true)
            end
            _RemoveAnswer("Stay thine hand!")
        elseif cmp_strings("bye", 1) then
            say("\"Farewell.\"")
            break
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function say(...)
    print(table.concat({...}))
end

function get_flag(id)
    return false -- Placeholder
end

function set_flag(id, value)
    -- Placeholder
end

function cmp_strings(str, count)
    return false -- Placeholder
end

function abort()
    -- Placeholder
end