--- Introduce party companions to Tseramed (NPC 10).
--- Presents each non-Avatar / non-Tseramed party member until the player picks "nobody".
---@param party_members table Array of party member names from get_party_members()
---@return table party_members Unchanged party name list
function utility_unknown_1013(party_members, _unused)
    save_answers()

    local remaining = {}
    if type(party_members) == "table" then
        for _, name in ipairs(party_members) do
            local npc_id = get_npc_id_from_name(name)
            if npc_id ~= 0 and npc_id ~= 10 then
                table.insert(remaining, { name = name, id = npc_id })
            end
        end
    end

    local heard_avatar_title = false

    while #remaining > 0 do
        local choices = {}
        for _, member in ipairs(remaining) do
            table.insert(choices, member.name)
        end
        table.insert(choices, "nobody")

        local choice = ask_answer(choices)
        if type(choice) ~= "string" or choice == "nobody" then
            break
        end

        local idx = nil
        local member = nil
        for i, entry in ipairs(remaining) do
            if entry.name == choice then
                idx = i
                member = entry
                break
            end
        end
        if not member then
            break
        end
        table.remove(remaining, idx)

        local greeted = false
        if member.id == 1 then
            add_dialogue("\"Thy good health, sir. Many campaigns sit upon thy brow. It is an honor.\"")
            second_speaker(1, 0, "\"Avatar, this stranger grows upon me by the moment. Surely he would be a boon travelling companion.\"")
            local quipper = nil
            if npc_id_in_party(3) then
                quipper = 3
            elseif npc_id_in_party(4) then
                quipper = 4
            end
            if quipper then
                second_speaker(quipper, 0, "\"Oh, please.\"")
                second_speaker(1, 0, "\"Hush, " .. utility_unknown_1039(quipper) .. ".\"")
            end
            greeted = true
            heard_avatar_title = true
        elseif member.id == 3 then
            add_dialogue("\"How art thou, Shamino? Thy woodcraft is renowned in Britannia.\"")
            second_speaker(3, 0, "\"Renown follows those who travel with the Avatar. I thank thee.\"")
            greeted = true
            heard_avatar_title = true
        elseif member.id == 2 then
            add_dialogue("\"Greetings young man. How comes one so young into such company?\"")
            second_speaker(2, 0, "\"I am an orphan! My father has been most cruelly murdered, mutilated in the stables of Trinsic.\"")
            add_dialogue("\"That is a grievous tale! But surely the time for grief is past. Thou art in the company of great companions.\"")
            second_speaker(2, 0, "\"Thou speakest rightly. I shall bring my father's murderer to justice or die in the attempt.\"")
            greeted = true
        end

        if not greeted then
            add_dialogue("\"Greetings " .. member.name .. ".\"")
            local greetings = {
                "May good fortune be thine.",
                "Good health to thee.",
                "Thou art looking quite well today.",
            }
            add_dialogue("\"" .. greetings[math.random(1, #greetings)] .. "\"")
            second_speaker(member.id, 0, "\"Glad to make thine aquaintance.\"")
            greeted = true
        end

        if heard_avatar_title and not get_flag(353) then
            add_dialogue("\"But did I hear thee say 'Avatar?' Say not that thy leader is the one -true- Avatar!\"")
            second_speaker(member.id, 0, "\"It is indeed true.\"")
            add_dialogue("\"'Tis an honor to meet thee, Avatar.\"")
            set_flag(353, true)
            heard_avatar_title = false
        end
    end

    restore_answers()
    if #remaining == 0 then
        set_flag(351, true)
    end
    return party_members
end
