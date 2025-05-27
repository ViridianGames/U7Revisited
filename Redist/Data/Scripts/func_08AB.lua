--- Best guess: Manages a Fellowship meeting dialogue led by Klog in Trinsic, with multiple NPCs giving testimonials and player reactions, advancing a narrative sequence.
function func_08AB()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0000 = unknown_08F7H(-14)
    var_0001 = unknown_08F7H(-236)
    var_0002 = unknown_08F7H(-18)
    var_0003 = unknown_08F7H(-22)
    var_0004 = unknown_08F7H(-1)
    var_0005 = unknown_08F7H(-2)
    switch_talk_to(16, 0)
    add_dialogue("Klog is leading the town members in a Fellowship meeting.")
    add_dialogue("\"Thank you, Fellowship members of Trinsic, for attending our meeting this evening.\"~~\"I am certain you are all sorely aware of the crimes that have been committed in our city. Now is a time to mourn those whom we have lost. We will always remember Christopher, our blacksmith, as a valuable citizen of our town as well as a dear friend. Inamo was an amiable and hard-working gargoyle. As their deaths show us, Britannia needs The Fellowship now more than ever.\"")
    add_dialogue("\"The Fellowship was created to advance a philosophy, a method of applying an optimistic order of thought to one's life. How dost thou follow this method? By applying the Triad of Inner Strength to thy life. The Triad is composed of three principles that, when applied in unison to thy life, can soothe the fever of a society that teaches thee to accept failure and banishes the destructive illusory thoughts and feelings from thy spirit.\"")
    add_dialogue("\"The first principle is to Strive For Unity. This means that we should reject divisiveness, put aside our differences and work together for the good of us all.\"")
    add_dialogue("\"The second principle is to Trust Thy Brother. Trust is essential, for what will you accomplish if you must be divided by constantly watching each other?\"")
    add_dialogue("\"The third and final principle is Worthiness Precedes Reward. One must strive to be worthy of the rewards each of us seeks, for if one is not worthy of reward, why should you believe they should receive it?\"")
    add_dialogue("\"We must spread the philosophy to everyone who can hear it. For who is there to lift the disunited, mistrustful, and unworthy Britannia up from its sad state but we of The Fellowship?\"")
    add_dialogue("\"And now is the time we ask each of our members to give testimonial aloud, and tell how walking with The Fellowship has affected their life.\"")
    if var_0001 then
        switch_talk_to(236, 0)
        add_dialogue("\"The Fellowship has enabled me to reach out and help people where before I have been too preoccupied.\"")
        hide_npc(-236)
    end
    if var_0000 then
        switch_talk_to(14, 0)
        add_dialogue("\"The Fellowship has made me more alert and thorough in the execution of my job as a Trinsic guard.\"")
        hide_npc(-14)
    end
    if var_0002 then
        switch_talk_to(18, 0)
        add_dialogue("\"The Fellowship has made me a happier, more agreeable person.\"")
        switch_talk_to(16, 0)
        add_dialogue("\"Thank thee for sharing, brother!\"")
        hide_npc(-18)
    end
    if var_0003 then
        switch_talk_to(22, 0)
        add_dialogue("\"As a Fellowship member, I feel as if I am doing some good for Britannia.\"")
        hide_npc(-22)
    end
    if var_0005 then
        switch_talk_to(2, 0)
        add_dialogue("Spark whispers to no one in particular, \"This is the most boring pile of horse manure in which I have ever had the pleasure to wallow!\"")
        hide_npc(-2)
    end
    if var_0004 then
        switch_talk_to(1, 0)
        add_dialogue("Iolo slaps his own cheek to keep himself from dozing off. ~~\"Avatar, I do believe that we have heard enough of this.\"")
        hide_npc(-1)
    end
    switch_talk_to(16, 0)
    add_dialogue("It is apparent that the meeting will be continuing for some time... You decide you have more important matters to attend to.")
    return
end