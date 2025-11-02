--- Best guess: Depicts a Fellowship ceremony led by Batlin, explaining the Triad of Inner Strength and featuring NPC testimonials and party reactions.
function utility_ship_0848()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    start_conversation()
    switch_talk_to(-26) --- Guess: Switches to Batlin
    var_0000 = get_player_name_context() --- Guess: Gets player name context
    var_0001 = get_lord_or_lady() --- Guess: Gets lord/lady title
    add_dialogue("@The ceremony begins as Batlin stands before the gathered Fellowship members. The hall fills with thunderous cheers. They look at him with a mixture of awe and sheer adoration. Batlin stands and basks in the warm reception for a moment, a triumphant smile on his face. With a slight gesture of his hand the crowd becomes quiet.@")
    add_dialogue("@\"It is good to see you here this evening!\" Batlin says. \"Surely you make me feel proud to be part of what we lovingly call The Fellowship.\" There is another eruption of applause.@")
    add_dialogue("@\"In thine heart be glad for thou dost walk with The Fellowship! The people of Britannia live in a fevered state of illusory thoughts and emotions. But those whom I look upon here tonight are seekers of what is good and true in the world! They walk the path which leads to becoming truly cognizant. But how dost thou find thy way? Ask any Fellowship member and they will tell thee! The path to complete awareness is easy to find. One must apply to one's life the Triad of Inner Strength.@")
    add_dialogue("@\"The Triad of Inner Strength is a series of three values that can bring the mind to a perfect state of sanguine cognition. The first value is Strive For Unity. When the totality of the people of the world want to accomplish something, then it becomes done. Thus once the people of the world all strive towards the same ends there is nothing that is impossible. Just think of it! A world where any dream can be fulfilled, any good can be achieved. But as thou canst see plainly by looking at our own sad society, when the people of the world are disunited, it is a miracle that anything gets accomplished!@")
    add_dialogue("@\"The second value is Trust Thy Brother. Thou must surrender thy fear, prejudice and suspicion. Look to thine own self! Before thou dost question anything, question thyself! The world is a place where the balances of nature are at work to protect thee every second without thee even realizing it! What canst thou accomplish in this world if thou dost spend all thy time questioning thy brother?! Is he working as hard as I? What are his true motivations? As thou dost waste thine energies wondering, he sees thee and starts wondering these same things about thee. Thus is the world diminished!@")
    add_dialogue("@\"The third value is Worthiness Precedes Reward. There is not one among us who is without desire. Much of the misery in the world can be traced to unfulfilled desires. But one moment! Why dost thou deserve what thou dost desire? Most people get what they are worthy of in this life. If thou art not worthy of thy desire then thou shouldst not be surprised if thy desires are unfulfilled. If thou dost become worthy only then hast thou become open to fulfilling thy desires. Desire is a strange thing. Many long for things they do not really want. What they really desire is worthiness itself!@")
    add_dialogue("@\"I have just told thee all that thou dost need to follow the Triad Of Inner Strength. The lessons are simple. The true measure of thine understanding comes in how absolutely thou wilt apply them to thy life. Thou now knowest all thou wilt ever need. Thou dost not need the arcane knowledge of the dying art of magic. Thou dost not need the unsure hand of the healer and his limited knowledge. All that thou wilt ever need is to continuously seek out the best in thyself and to live amongst those that would do the same. Only then art thou truly walking with The Fellowship.@")
    add_dialogue("@\"Now I think would be a good time to hear the words of our fellow members. To hear them share with us how The Fellowship has been bringing positive change to their lives.\"@")
    var_0002 = check_dialogue_target(-41) --- Guess: Checks if Candice is present
    if var_0002 then
        switch_talk_to(-41) --- Guess: Switches to Candice
        add_dialogue("@\"The Fellowship has shown me that I was afraid of myself and that I had to open myself up to life's experiences,\" says Candice.@")
        hide_npc(41) --- Guess: Hides Candice
    end
    var_0003 = check_dialogue_target(-43) --- Guess: Checks if Patterson is present
    if var_0003 then
        switch_talk_to(-43) --- Guess: Switches to Patterson
        add_dialogue("@\"The Fellowship helps me be more honest with people,\" says Patterson.@")
        switch_talk_to(-26) --- Guess: Switches to Batlin
        add_dialogue("@\"Thank thee for sharing, Patterson.\"@")
        hide_npc(43) --- Guess: Hides Patterson
    end
    var_0004 = check_dialogue_target(-45) --- Guess: Checks if Figg is present
    if var_0004 then
        switch_talk_to(-45) --- Guess: Switches to Figg
        add_dialogue("@\"The Fellowship has taught me how to better perform my duties as the Caretaker of the Royal Orchards,\" says Figg.@")
        hide_npc(45) --- Guess: Hides Figg
    end
    var_0005 = check_dialogue_target(-53) --- Guess: Checks if Gaye is present
    if var_0005 then
        switch_talk_to(-53) --- Guess: Switches to Gaye
        add_dialogue("@\"The Fellowship has taught me to, first and foremost, treat people with respect,\" says Gaye.@")
        hide_npc(53) --- Guess: Hides Gaye
    end
    var_0006 = check_dialogue_target(-55) --- Guess: Checks if Grayson is present
    if var_0006 then
        switch_talk_to(-55) --- Guess: Switches to Grayson
        add_dialogue("@\"After joining The Fellowship I learned how to be a man's man,\" says Grayson.@")
        hide_npc(55) --- Guess: Hides Grayson
    end
    var_0007 = check_dialogue_target(-58) --- Guess: Checks if Gordon is present
    if var_0007 then
        switch_talk_to(-58) --- Guess: Switches to Gordon
        add_dialogue("@\"The Fellowship is helping me back from the brink of personal and financial oblivion,\" says Gordon.@")
        switch_talk_to(-26) --- Guess: Switches to Batlin
        add_dialogue("@\"Right thou art, brother!\"@")
        hide_npc(58) --- Guess: Hides Gordon
    end
    var_0008 = check_dialogue_target(-59) --- Guess: Checks if Sean is present
    if var_0008 then
        switch_talk_to(-59) --- Guess: Switches to Sean
        add_dialogue("@\"The Fellowship has freed me from the illusory appeals of mediocrity,\" says Sean.@")
        hide_npc(59) --- Guess: Hides Sean
    end
    var_0009 = check_dialogue_target(-63) --- Guess: Checks if Millie is present
    if var_0009 then
        switch_talk_to(-63) --- Guess: Switches to Millie
        add_dialogue("@\"In The Fellowship I am learning that I need to devote my life to a special purpose,\" says Millie.@")
        hide_npc(63) --- Guess: Hides Millie
    end
    var_000A = check_dialogue_target(-2) --- Guess: Checks if Spark is present
    if var_000A then
        switch_talk_to(-2) --- Guess: Switches to Spark
        add_dialogue("@\"This whole ceremony and everyone in it doth give me the willies!\"@")
        hide_npc(2) --- Guess: Hides Spark
    end
    var_000B = check_dialogue_target(-1) --- Guess: Checks if Iolo is present
    if var_000B then
        switch_talk_to(-1) --- Guess: Switches to Iolo
        add_dialogue("@\"'Tis a sad thing to see so many people who have nothing else better in their lives than blindly following this dubious spiritual leader.\"@")
        hide_npc(1) --- Guess: Hides Iolo
    end
    var_000C = check_dialogue_target(-3) --- Guess: Checks if Shamino is present
    if var_000C then
        switch_talk_to(-3) --- Guess: Switches to Shamino
        add_dialogue("@\"'Tis a sad thing that Britannia has fallen so far as to leave itself open to a group like this Fellowship.\"@")
        hide_npc(3) --- Guess: Hides Shamino
    end
    var_000D = check_dialogue_target(-4) --- Guess: Checks if another NPC is present
    if var_000D then
        switch_talk_to(-4) --- Guess: Switches to NPC
        add_dialogue("@\"'Tis a sad thing when I cannot even keep my eyes open from the boredom of this Fellowship ceremony!\"@")
        hide_npc(4) --- Guess: Hides NPC
    end
    switch_talk_to(-26) --- Guess: Switches back to Batlin
    add_dialogue("@From watching Batlin and the others you get the feeling that the Fellowship ceremony is going to last long into the night. Now would be a good moment to slip away without drawing much attention to yourself...@")
    abort() --- Guess: Aborts script
end