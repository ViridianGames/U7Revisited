--- Best guess: Manages a scripted Fellowship sermon focusing on trust, with NPC interactions and an option to leave early prompted by Iolo.
function func_08CF()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = unknown_08F7H(-156)
    var_0001 = unknown_08F7H(-157)
    var_0002 = unknown_08F7H(-1)
    var_0003 = unknown_08F7H(-4)
    add_dialogue("\"Fellow members, each of thee has faced -- and doubtless shall face again -- a moment in which thou dost feel the heat of the fever. A moment when thy mind has been clouded with illusory thoughts and visions. A moment when thy recognition has simply vanished, without rhyme or reason. A moment when, perhaps, thou hast even doubted the very words of The Fellowship itself!\"")
    if not var_0000 then
        switch_talk_to(156, 0)
        add_dialogue("You see the clerk gasp, her eyes widening in disbelief.")
        hide_npc(-156)
        switch_talk_to(250, 0)
    end
    add_dialogue("\"The second principle of the Triad is `trust thy brother.' 'Tis a simple practice when thou dost know thy brother. But The Fellowship was not always known to thee. It may, at one time, have been difficult to put thy trust in something as large as The Fellowship.~~ However, to gain full knowledge of thine inner strength, one must have the courage to walk on the fire of trust!\"")
    if not var_0001 then
        switch_talk_to(157, 0)
        add_dialogue("\"'Tis true! Trust was the key to my freedom!\"")
        hide_npc(-157)
        switch_talk_to(250, 0)
    end
    add_dialogue("\"Trust requires great courage, and that courage exists within thyself.\"")
    if not var_0002 then
        switch_talk_to(1, 0)
        add_dialogue("Iolo leans toward you.~~ \"I believe we have heard enough of this, no?\"")
        var_0004 = ask_yes_no()
        if var_0004 then
            add_dialogue("\"Good. Let us leave.\"")
            return
        end
        add_dialogue("Iolo sighs deeply.")
        hide_npc(-1)
        switch_talk_to(250, 0)
    end
    add_dialogue("\"But as long as one remains aware, this problem will not plague thee.\"")
    if not var_0003 then
        switch_talk_to(4, 0)
        add_dialogue("\"Come, friend. That is enough of this. Drinks are on me.\"~~ As you make your way out of the Hall, the leader's voice continues to drone on and on.")
        return
    end
    return
end