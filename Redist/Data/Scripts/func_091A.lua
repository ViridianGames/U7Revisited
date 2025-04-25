-- Delivers Fellowship philosophy dialogue and offers membership.
function func_091A()
    local local0, local1

    say("\"The Fellowship advances the philosophy of 'sanguine cognition', a way to apply a confident order of thought to one's life, through what is called the Triad of Inner Strength. The Triad is simply three basic principles that, when applied in unison, enable one to be more creative, satisfied, and successful in life. They are: Strive For Unity, Trust Thy Brother, and Worthiness Precedes Reward. Strive For Unity basically means that people should cooperate and work together. Trust Thy Brother implies that we are all the same and that we should not hate or fear each other. Worthiness Precedes Reward suggests that we must each strive to be worthy of that which we want out of life.\"")
    local0 = external_0067H() -- Unmapped intrinsic
    if not local0 then
        say("\"Dost thou want to join?\"")
        local1 = external_090AH() -- Unmapped intrinsic
        if local1 then
            say("\"Then thou shouldst go immediately to see Batlin at the Fellowship Hall headquarters in Britain.\"")
        else
            say("\"Oh. Well, perhaps thou canst become enlightened another time.\"")
        end
    else
        say("\"Oh! I just now noticed thy medallion! Thou dost already know all of this! Thou art one of us! Excuse me for going on and on about it!\"")
    end
    return
end