-- Function 08C7: Manages Fellowship play dialogue
function func_08C7()
    -- Local variables (2 as per .localc)
    local local0, local1

    callis_0003(0, -233)
    local0 = call_08F7H(-1)
    local1 = call_08F7H(-2)
    add_dialogue("As the actors take their places and don masks, you settle down to watch the action.")
    if not local1 then
        callis_0003(0, -2)
        add_dialogue("Spark whispers to you, \"I wish there was a confectioner that sold candied apples!\"")
        callis_0004(-2)
        callis_0003(0, -233)
    end
    add_dialogue("The music starts the play, as Paul takes center stage and addresses the audience.")
    add_dialogue("\"Welcome to Our Tale, ~A tale so true to life. ~'Tis a tale of tragedy ~A man has lost his wife.")
    add_dialogue("\"But the story need not be sad ~When The Fellowship is here. ~The Triad of Inner Strength ~Gives one no cause to fear.\"")
    callis_0004(-233)
    callis_0003(0, -235)
    add_dialogue("Dustin takes the stage as Paul moves away. Meryl lies on the ground in front of him and assumes a death-like pose.")
    add_dialogue("\"'Tis doom! 'Tis despair! 'Tis death! ~My beloved wife is gone! ~Disease has taken her away ~And left me with but a song.\"")
    add_dialogue("Dustin puts his head in his hands and mimes sobbing. As he sobs, Meryl rises from her \"death\" in a ghost-like fashion, then addresses Dustin.")
    callis_0003(0, -234)
    add_dialogue("\"Mine husband, my love! ~Do not despair! 'Tis not doom! ~Thou shalt rise above ~All this melancholy and gloom!\"")
    callis_0003(0, -235)
    add_dialogue("\"Who doth speak to me? ~Could it be she? ~Or have I indeed gone mad? ~But who else -could- it be?\"")
    callis_0003(0, -234)
    add_dialogue("\"Mine husband, thou must listen. ~Thou hast thy comfort within thy grip. ~Thou must only seek them out -- ~Those that can help -- The Fellowship!\"")
    callis_0004(-234)
    callis_0003(0, -235)
    add_dialogue("Meryl drifts off stage, leaving Dustin alone.")
    add_dialogue("\"The Fellowship, she said? ~But what do I need with it? ~I have mine eight virtues and mine healers ~With these nothing else will fit!\"")
    callis_0003(0, -233)
    add_dialogue("Paul enters the stage with Meryl, who now wears a different mask.")
    add_dialogue("\"But that is where thou art wrong! ~The Fellowship exists to help thee! ~The Triad of Inner Strength is here ~To give thee a sense of unity!\"")
    add_dialogue("\"Join us now and thou wilt see. ~Join thy brothers and our plan ~To promote the tenets of our group -- ~Thou wilt be a better man.\"")
    add_dialogue("At this point, an elaborate mimed sequence reveals how Dustin joins The Fellowship, receives his medallion from a \"branch leader\", portrayed by Paul, and receives congratulations from Meryl.")
    add_dialogue("\"Strive for Unity at all times, ~And Trust Thy Brother through all ill, ~For Worthiness Precedes thine own Reward ~Hark to our words -- it surely will!\"")
    callis_0003(0, -235)
    add_dialogue("\"I shall give half my wealth to thee! ~I shall do thy bidding and then wait. ~My reward shall come one day ~And free me from mine awful fate.\"")
    add_dialogue("Dustin mimes giving Paul some money. Paul exits, then Dustin lies down on the stage and mimes going to sleep. After a moment, Meryl enters the stage, dances around Dustin's body, sprinkling some kind of sparkling dust on him.")
    if not local0 then
        callis_0004(-233)
        callis_0003(0, -1)
        add_dialogue("Iolo whispers to you. \"I am particularly enjoying the visual effects. The script is a little weak, dost thou not think?\"")
        callis_0004(-1)
        callis_0003(0, -235)
    end
    add_dialogue("Meryl leaves the stage and Dustin 'wakes up'. Lo and behold, he finds a bag near his place of sleep. Upon opening it, he finds a bundle of gold!")
    add_dialogue("\"By Lord British I declare! ~'Tis my reward! From the air! ~The voice I heard at night was right ~About my wretched life I will not care!")
    add_dialogue("\"The voice came to me in a dream ~'Twas mine 'inner' voice, so fair. ~I now have a companion and provider, ~And a master about whom I care.\"")
    add_dialogue("You are jarred by the actor's choice of words -- 'companion', 'provider', and 'master'. You realize you have heard them before.")
    if not local1 then
        callis_0003(0, -2)
        add_dialogue("\"This is really awful.\"")
        callis_0004(-2)
        callis_0003(0, -235)
    end
    add_dialogue("Paul and Meryl join Dustin on stage and they all hold hands.")
    callis_0003(0, -233)
    add_dialogue("\"The Fellowship can give thee purpose ~To join is thine only choice ~Commit thyself to our just cause ~And find thine inner voice.\"")
    add_dialogue("At that point, the actors bow, and you realize it is the end. You give them polite applause.")
    set_flag(0x000A, true)
    if not local0 then
        callis_0004(-233)
        callis_0003(0, -1)
        add_dialogue("\"What do they mean about the voice? I am not sure I understand. 'Twas a confusing play. I did not like it at all. We have wasted our time and money! That is the last time that I let thee decide how best we entertain ourselves!\"")
        callis_0004(-1)
    end
    abort()

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function set_flag(flag, value)
    -- Placeholder
end

function abort()
    -- Placeholder
end