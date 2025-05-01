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

    switch_talk_to(249, 0)
    local0 = call_0908H()
    local1 = call_0909H()
    add_answer({"bye", "job", "name"})

    if not get_flag(0x01F9) then
        add_dialogue("You see a scholarly-looking man with a friendly expression.")
        set_flag(0x01F9, true)
        set_flag(0x01F7, true)
    else
        add_dialogue("\"Salutations, ", local0, ".\"")
        if not get_flag(0x01F6) then
            add_answer("North East sea")
        end
        if not get_flag(0x01E3) then
            add_answer("Zelda's response")
        end
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"Thou mayest call me Nelson.\"")
            remove_answer("name")
            if not get_flag(0x01F6) then
                add_answer("North East sea")
            end
        elseif answer == "job" then
            add_dialogue("\"I am the Lycaeum head here in Moonglow, but,\" he leans close to you, \"mine assistant, Zelda, does most of the work.\"")
            add_answer({"Zelda", "Moonglow"})
        elseif answer == "Zelda" then
            add_dialogue("\"She is an excellent assistant. The Lycaeum has never performed better. However, she is a little too stern, I believe, and,\" he leans in again, \"I think she is quite beautiful.\"")
            add_answer({"beautiful", "stern"})
            remove_answer("Zelda")
        elseif answer == "North East sea" then
            add_dialogue("\"I have heard the rumors of an island, but I know nothing else about it, I am afraid. Thou mightest wish to speak with Jillian -- she should know a little about the area.\"")
            remove_answer("North East sea")
        elseif answer == "stern" then
            add_dialogue("\"She has put an extraordinary amount of time and effort into ensuring the activities in this edifice happen smoothly. And,\" he adds, \"she takes it personally when they do not!\"")
            remove_answer("stern")
        elseif answer == "beautiful" then
            add_dialogue("\"Dost thou not agree? I am flushed whenever her fair presence passes by. But!\" he holds up his index finger, \"I fear she does not share a mutual attraction. And she is far too serious for me to feel comfortable with a proposal.\"")
            set_flag(0x01DC, true)
            if not get_flag(0x01DA) then
                add_answer("Zelda's feelings")
            end
            remove_answer("beautiful")
        elseif answer == "Moonglow" then
            add_dialogue("\"I love the island and the people. Mostly the people.\"")
            add_answer("people")
            remove_answer("Moonglow")
        elseif answer == "people" then
            add_dialogue("\"Hast thou met my twin brother? He heads the Observatory here. And somewhere in the Lycaeum thou canst find Mariah. Sadly, she is not well up here.\" He touches his head.~~\"Jillian, the sage, also studies here in the Lycaeum. A good person to see about other residents of Moonglow would be the bartender at the Friendly Knave. Phearcy knows almost all of us here on the island.~~\"Oh, and thou must not forget the legend of Penumbra. 'Twas two hundred years ago she cast herself into a deep slumber. Now that I think about it, ", local0, ", thou art the one she predicted would awaken her.~~\"Better hasten, ", local1, ",\" he chuckles.")
            add_answer({"Penumbra", "Phearcy", "Jillian", "Mariah", "twin"})
            remove_answer("people")
        elseif answer == "twin" then
            add_dialogue("\"His name is Brion. People often mistake us for each other, but I think we are nothing alike -- he got all the looks -and- the brains!\"")
            remove_answer("twin")
        elseif answer == "Mariah" then
            add_dialogue("\"She was once an adept mage, but ever since the wizards began losing their, er, faculties, she followed suit.\"")
            remove_answer("Mariah")
        elseif answer == "Jillian" then
            add_dialogue("\"She rarely has time for visitors, but I know she takes on students every now and then.\"")
            remove_answer("Jillian")
        elseif answer == "Phearcy" then
            add_dialogue("\"That one keeps up on his politics, or rather, his gossip,\" he says, grinning. \"If thou dost want to learn about a resident of Moonglow, visit him.\"")
            remove_answer("Phearcy")
        elseif answer == "Penumbra" then
            add_dialogue("\"Interestingly enough, no one has ever discovered how to enter her house. I believe those mysterious signs on the door require one to have specific items to place next to the plaques.\"")
            remove_answer("Penumbra")
        elseif answer == "Zelda's response" then
            add_dialogue("He smiles broadly. \"Truly that was her response? I am pleased to no end! I thank thee, ", local0, ", for bringing this joyful message.\"")
            remove_answer("Zelda's response")
        elseif answer == "Zelda's feelings" then
            add_dialogue("\"Oh. Oh well,\" he shrugs in an attempt at indifference. \"She was not truly important anyway.\"")
            remove_answer("Zelda's feelings")
        elseif answer == "bye" then
            if not get_flag(0x01E4) and not get_flag(0x01E5) and not get_flag(0x01E6) and not get_flag(0x01E7) then
                add_dialogue("\"Good day, ", local1, ". Thou of course dost have free reign of the Lycaeum.\"*")
                return
            else
                add_dialogue("\"Of course thou mayest have free reign of the building. But first,\" he grins, \"let me show thee my...\"")
                _SaveAnswers()
                add_answer({"nothing", "book", "quill holder", "bookmark", "bookstand"})
            end
        elseif answer == "bookstand" then
            local2 = callis_000E(-1, 697, -356)
            if local2 then
                add_dialogue("\"This solid brass bookstand has matching, overhanging candleholder for late-night exploration in literature. I invented it myself.\"")
            else
                add_dialogue("\"'Twas just here...\" he scratches his chin. \"Oh well, never mind.\"")
            end
            remove_answer("bookstand")
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
                add_dialogue("\"This,\" he says, holding a solid-gold sheet shaped like a maple leaf, \"I purchased at an auction for only half of its value.\"")
            else
                add_dialogue("He appears upset. \"I knew someday that would be stolen,\" he says angrily.~~\"I should have known better than to show it to every person who comes to visit.\"")
            end
            remove_answer("bookmark")
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
                    add_dialogue("He shows you a serpent-shaped, oaken quill holder and its matching scroll opener. \"This I picked up while travelling through -- thou canst guess it -- Serpent's Hold.\"")
                else
                    add_dialogue("He shows you a serpent-shaped, oaken quill holder. \"This I picked up while travelling through -- thou canst guess it -- Serpent's Hold. But,\" he appears puzzled, \"I could have sworn the matching letter opener was here as well. How odd.\"")
                end
            else
                add_dialogue("\"The quill holder is gone?\" he exclaims. \"And what about the...\" he seems to be searching for something.~~\"The matching scroll opener is also missing!\"")
            end
            remove_answer("quill holder")
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
                add_dialogue("He gingerly pulls out a leatherbound tome. From his robe, he removes a handkerchief and meticulously wipes away the dust.~~\"This was given to me by Lord British himself. See, 'tis the first edition.\"~~The book he carefully places in your palms is very old, and the gold leaf plating of the title has been almost entirely rubbed off. Turning the book right side up, you can read the title: \"Stranger in a Strange Land.\"")
            else
                add_dialogue("\"'Tis not here... Oh well, Zelda must have put it back on the shelf.\" He sighs.")
            end
            remove_answer("book")
            set_flag(0x01E7, true)
        elseif answer == "nothing" then
            _RestoreAnswers()
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

function sloop()
    return false -- Placeholder
end