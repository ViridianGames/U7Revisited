--- Best guess: Manages a dialogue with Rowena in Skara Brae, where she asks to be escorted to Trent, joining the party if space is available, with options to discuss Trent or end the conversation.
function func_08D8()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    var_0000 = get_lord_or_lady()
    var_0001 = unknown_0023H()
    var_0002 = unknown_001BH(-144)
    if var_0002 and table.contains(var_0001, var_0002) then
        unknown_001FH(-144)
        add_dialogue("The starcrossed lovers rush into each other's ghostly embrace. For a time it's hard to see where one spirit ends and the other begins, then the two slowly turn to face you. \"Thou hast done so much for us, I hope that in helping us, thou hast been assisted in thine own quest.\" Rowena performs a curtsey then turns to regard her handsome husband.")
        unknown_001DH(15, unknown_001BH(-144))
        set_flag(422, true)
        return
    end
    add_dialogue("\"How can I help thee, " .. var_0000 .. "? I must get to Trent quickly.\" She looks impatient to be with her husband.")
    while true do
        add_answer({"bye", "Trent"})
        if not unknown_XXXXH() then
            if string.lower(unknown_XXXXH()) == "trent" then
                add_dialogue("Her face lights up as you say her husband's name. \"He is the town smith. He hand crafted that music box thou didst use to awaken me from Horance's dark power.\"")
                remove_answer("Trent")
            elseif string.lower(unknown_XXXXH()) == "sacrifice" then
                add_dialogue("\"I cannot do that to my poor Trent, at least not without seeing him one more time.\" She shakes her head in negation.")
                set_flag(413, true)
            elseif string.lower(unknown_XXXXH()) == "bye" then
                add_dialogue("\"Yes, we must be getting to the smithy. Trent will be worrying about me.\"")
                return
            end
        end
    end
    add_dialogue("\"This place is horrible. Wouldst thou be so kind as to take me to mine husband, Trent? He has a tendency to worry about me.\"")
    var_0004 = unknown_090AH()
    if var_0004 then
        var_0005 = false
        add_dialogue("Rowena smiles radiantly, \"Thank thee, " .. var_0000 .. ". Thy spirit is a generous one, indeed.\"")
        var_0006 = 0
        var_0001 = unknown_0023H()
        for _, _ in ipairs(var_0001) do
            var_0006 = var_0006 + 1
        end
        if var_0006 < 8 then
            add_dialogue("She steps in line and motions for you to lead on.")
            unknown_001EH(-144)
            var_0005 = true
            return
        else
            add_dialogue("\"Thou hast too many people in thy party at the moment for me to travel with thee.\"")
            return
        end
    end
    add_dialogue("\"Then I shall wait here for one of virtue who would safeguard my well being, and help me to return to mine husband.\" She seems distanced as she turns away from you.")
    return
end