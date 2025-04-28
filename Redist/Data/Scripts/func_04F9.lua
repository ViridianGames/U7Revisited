require "U7LuaFuncs"
-- Function 04F9: Nelson's Lycaeum dialogue and romantic subplot
function func_04F9(eventid, itemref)
    -- Local variables (20 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19

    if eventid == 0 then
        call_092EH(-249)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -249)
    local0 = call_0908H()
    local1 = call_0909H()
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x01F9) then
        say("You see a scholarly-looking man with a friendly expression.")
        set_flag(0x01F9, true)
        set_flag(0x01F7, true)
    else
        say("\"Salutations, ", local0, ".\"")
        if not get_flag(0x01F6) then
            _AddAnswer("North East sea")
        end
        if not get_flag(0x01E3) then
            _AddAnswer("Zelda's response")
        end
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"Thou mayest call me Nelson.\"")
            _RemoveAnswer("name")
            if not get_flag(0x01F6) then
                _AddAnswer("North East sea")
            end
        elseif answer == "job" then
            say("\"I am the Lycaeum head here in Moonglow, but,\" he leans close to you, \"mine assistant, Zelda, does most of the work.\"")
            _AddAnswer({"Zelda", "Moonglow"})
        elseif answer == "Zelda" then
            say("\"She is an excellent assistant. The Lycaeum has never performed better. However, she is a little too stern, I believe, and,\" he leans in again, \"I think she is quite beautiful.\"")
            _AddAnswer({"beautiful", "stern"})
            _RemoveAnswer("Zelda")
        elseif answer == "North East sea" then
            say("\"I have heard the rumors of an island, but I know nothing else about it, I am afraid. Thou mightest wish to speak with Jillian -- she should know a little about the area.\"")
            _RemoveAnswer("North East sea")
        elseif answer == "stern" then
            say("\"She has put an extraordinary amount of time and effort into ensuring the activities in this edifice happen smoothly. And,\" he adds, \"she takes it personally when they do not!\"")
            _RemoveAnswer("stern h
            _RemoveAnswer("stern")
        elseif answer == "beautiful" then
            say("\"Dost thou not agree? I am flushed whenever her fair presence passes by. But!\" he holds up his index finger, \"I fear she does not share a mutual attraction. And she is far too serious for me to feel comfortable with a proposal.\"")
            set_flag(0x01DC, true)
            if not get_flag(0x01DA) then
                _AddAnswer("Zelda's feelings")
            end
            _RemoveAnswer("beautiful")
        elseif answer == "Moonglow" then
            say("\"I love the island and the people. Mostly the people.\"")
            _AddAnswer("people")
            _RemoveAnswer("Moonglow")
        elseif answer == "people" then
            say("\"Hast thou met my twin brother? He heads the Observatory here. And somewhere in the Lycaeum thou canst find Mariah. Sadly, she is not well up here.\" He touches his head.~~\"Jillian, the sage, also studies here in the Lycaeum. A good person to see about other residents of Moonglow would be the bartender at the Friendly Knave. Phearcy knows almost all of us here on the island.~~\"Oh, and thou must not forget the legend of Penumbra. 'Twas two hundred years ago she cast herself into a deep slumber. Now that I think about it, ", local0, ", thou art the one she predicted would awaken her.~~\"Better hasten, ", local1, ",\" he chuckles.")
            _AddAnswer({"Penumbra", "Phearcy", "Jillian", "Mariah", "twin"})
            _RemoveAnswer("people")
        elseif answer == "twin" then
            say("\"His name is Brion. People often mistake us for each other, but I think we are nothing alike -- he got all the looks -and- the brains!\"")
            _RemoveAnswer("twin")
        elseif answer == "Mariah" then
            say("\"She was once an adept mage, but ever since the wizards began losing their, er, faculties, she followed suit.\"")
            _RemoveAnswer("Mariah")
        elseif answer == "Jillian" then
            say("\"She rarely has time for visitors, but I know she takes on students every now and then.\"")
            _RemoveAnswer("Jillian")
        elseif answer == "Phearcy" then
            say("\"That one keeps up on his politics, or rather, his gossip,\" he says, grinning. \"If thou dost want to learn about a resident of Moonglow, visit him.\"")
            _RemoveAnswer("Phearcy")
        elseif answer == "Penumbra" then
            say("\"Interestingly enough, no one has ever discovered how to enter her house. I believe those mysterious signs on the door require one to have specific items to place next to the plaques.\"")
            _RemoveAnswer("Penumbra")
        elseif answer == "Zelda's response" then
            say("He smiles broadly. \"Truly that was her response? I am pleased to no end! I thank thee, ", local0, ", for bringing this joyful message.\"")
            _RemoveAnswer("Zelda's response")
        elseif answer == "Zelda's feelings" then
            say("\"Oh. Oh well,\" he shrugs in an attempt at indifference. \"She was not truly important anyway.\"")
            _RemoveAnswer("Zelda's feelings")
        elseif answer == "bye" then
            if not get_flag(0x01E4) and not get_flag(0x01E5) and not get_flag(0x01E6) and not get_flag(0x01E7) then
                say("\"Good day, ", local1, ". Thou of course dost have free reign of the Lycaeum.\"*")
                return
            else
                say("\"Of course thou mayest have free reign of the building. But first,\" he grins, \"let me show thee my...\"")
                _SaveAnswers()
                _AddAnswer({"nothing", "book", "quill holder", "bookmark", "bookstand"})
            end
        elseif answer == "bookstand" then
            local2 = callis_000E(-1, 697, -356)
            if local2 then
                say("\"This solid brass bookstand has matching, overhanging candleholder for late-night exploration in literature. I invented it myself.\"")
            else
                say("\"'Twas just here...\" he scratches his chin. \"Oh well, never mind.\"")
            end
            _RemoveAnswer("bookstand")
            set_flag(0x01E4, true)
        elseif answer == "bookmark" then
            local3 = false
            local4 = callis_0035(0, 20, 675, itemref)
            while true do
                local7 = call_GetItemFrame(local4)
                if local7 == 4 then
                    local3 = true
                end
                if not sloop() then break end
            end
            if local3 then
                say("\"This,\" he says, holding a solid-gold sheet shaped like a maple leaf, \"I purchased at an auction for only half of its value.\"")
            else
                say("He appears upset. \"I knew someday that would be stolen,\" he says angrily.~~\"I should have known better than to show it to every person who comes to visit.\"")
            end
            _RemoveAnswer("bookmark")
            set_flag(0x01E5, true)
        elseif answer == "quill holder" then
            local8 = false
            local9 = callis_0035(0, 20, 675, itemref)
            while true do
                local7 = call_GetItemFrame(local9)
                if local7 == 3 then
                    local8 = true
                end
                if not sloop() then break end
            end
            local12 = false
            local13 = callis_0035(0, 20, 675, itemref)
            while true do
                local7 = call_GetItemFrame(local13)
                if local7 == 5 then
                    local12 = true
                end
                if not sloop() then break end
            end
            if local8 then
                if local12 then
                    say("He shows you a serpent-shaped, oaken quill holder and its matching scroll opener. \"This I picked up while travelling through -- thou canst guess it -- Serpent's Hold.\"")
                else
                    say("He shows you a serpent-shaped, oaken quill holder. \"This I picked up while travelling through -- thou canst guess it -- Serpent's Hold. But,\" he appears puzzled, \"I could have sworn the matching letter opener was here as well. How odd.\"")
                end
            else
                say("\"The quill holder is gone?\" he exclaims. \"And what about the...\" he seems to be searching for something.~~\"The matching scroll opener is also missing!\"")
            end
            _RemoveAnswer("quill holder")
            set_flag(0x01E6, true)
        elseif answer == "book" then
            local16 = false
            local17 = callis_0035(0, 20, 675, itemref)
            while true do
                local10 = call_GetItemQuality(local16)
                if local10 == 4 then
                    local16 = true
                end
                if not sloop() then break end
            end
            if local16 then
                say("He gingerly pulls out a leatherbound tome. From his robe, he removes a handkerchief and meticulously wipes away the dust.~~\"This was given to me by Lord British himself. See, 'tis the first edition.\"~~The book he carefully places in your palms is very old, and the gold leaf plating of the title has been almost entirely rubbed off. Turning the book right side up, you can read the title: \"Stranger in a Strange Land.\"")
            else
                say("\"'Tis not here... Oh well, Zelda must have put it back on the shelf.\" He sighs.")
            end
            _RemoveAnswer("book")
            set_flag(0x01E7, true)
        elseif answer == "nothing" then
            _RestoreAnswers()
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

function sloop()
    return false -- Placeholder
end