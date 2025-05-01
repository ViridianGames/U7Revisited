-- Function 08CF: Manages human Fellowship sermon dialogue
function func_08CF()
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    local0 = call_08F7H(-156)
    local1 = call_08F7H(-157)
    local2 = call_08F7H(-1)
    local3 = call_08F7H(-4)

    add_dialogue("\"Fellow members, each of thee has faced -- and doubtless shall face again -- a moment in which thou dost feel the heat of the fever. A moment when thy mind has been clouded with illusory thoughts and visions. A moment when thy recognition has simply vanished, without rhyme or reason. A moment when, perhaps, thou hast even doubted the very words of The Fellowship itself!\"")
    if not local0 then
        callis_0003(0, -156)
        add_dialogue("You see the clerk gasp, her eyes widening in disbelief.")
        callis_0004(-156)
        callis_0003(0, -250)
    end
    add_dialogue("\"The second principle of the Triad is `trust thy brother.' 'Tis a simple practice when thou dost know thy brother. But The Fellowship was not always known to thee. It may, at one time, have been difficult to put thy trust in something as large as The Fellowship.~~ \"However, to gain full knowledge of thine inner strength, one must have the courage to walk on the fire of trust!\"")
    if not local1 then
        callis_0003(0, -157)
        add_dialogue("\"'Tis true! Trust was the key to my freedom!\"")
        callis_0004(-157)
        callis_0003(0, -250)
    end
    add_dialogue("\"Trust requires great courage, and that courage exists within thyself.\"")
    if not local2 then
        callis_0003(0, -1)
        add_dialogue("Iolo leans toward you.~~ \"I believe we have heard enough of this, no?\"")
        local4 = call_090AH()
        if local4 then
            add_dialogue("\"Good. Let us leave.\"")
            abort()
        end
        add_dialogue("Iolo sighs deeply.")
        callis_0004(-1)
        callis_0003(0, -250)
    end
    add_dialogue("\"But as long as one remains aware, this problem will not plague thee.\"")
    if not local3 then
        callis_0003(0, -4)
        add_dialogue("\"Come, friend. That is enough of this. Drinks are on me.\"~~ As you make your way out of the Hall, the leader's voice continues to drone on and on.")
        abort()
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function abort()
    -- Placeholder
end