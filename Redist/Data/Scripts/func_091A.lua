--- Best guess: Explains The Fellowship’s philosophy and offers to join, directing the player to Batlin if interested, or noting existing membership.
function func_091A()
    local var_0000, var_0001

    add_dialogue("\"The Fellowship advances the philosophy of 'sanguine cognition', a way to apply a confident order of thought to one's life, through what is called the Triad of Inner Strength. The Triad is simply three basic principles that, when applied in unison, enable one to be more creative, satisfied, and successful in life. They are: Strive For Unity, Trust Thy Brother, and Worthiness Precedes Reward. Strive For Unity basically means that people should cooperate and work together. Trust Thy Brother implies that we are all the same and that we should not hate or fear each other. Worthiness Precedes Reward suggests that we must each strive to be worthy of that which we want out of life.\"")
    var_0000 = unknown_0067H()
    if not var_0000 then
        add_dialogue("\"Dost thou want to join?\"")
        var_0001 = _SelectOption()
        if var_0001 then
            add_dialogue("\"Then thou shouldst go immediately to see Batlin at the Fellowship Hall headquarters in Britain.\"")
        else
            add_dialogue("\"Oh. Well, perhaps thou canst become enlightened another time.\"")
        end
    else
        add_dialogue("\"Oh! I just now noticed thy medallion! Thou dost already know all of this! Thou art one of us! Excuse me for going on and on about it!\"")
    end
end