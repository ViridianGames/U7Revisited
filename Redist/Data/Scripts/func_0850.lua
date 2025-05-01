-- Function 0850: Fellowship ceremony
function func_0850(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    switch_talk_to(26, 0)
    local0 = _GetPlayerName(eventid)
    local1 = call_0009H()
    say(itemref, "The ceremony begins as Batlin stands before the gathered Fellowship members. The hall fills with thunderous cheers. They look at him with a mixture of awe and sheer adoration. Batlin stands and basks in the warm reception for a moment, a triumphant smile on his face. With a slight gesture of his hand the crowd becomes quiet.")
    say(itemref, "\"It is good to see you here this evening!\" Batlin says. \"Surely you make me feel proud to be part of what we lovingly call The Fellowship.\" There is another eruption of applause.")
    say(itemref, "\"In thine heart be glad for thou dost walk with The Fellowship! The people of Britannia live in a fevered state of illusory thoughts and emotions. But those whom I look upon here tonight are seekers of what is good and true in the world! They walk the path which leads to becoming truly cognizant. But how dost thou find thy way? Ask any Fellowship member and they will tell thee! The path to complete awareness is easy to find. One must apply to one's life the Triad of Inner Strength.\"")
    say(itemref, "\"The Triad of Inner Strength is a series of three values that can bring the mind to a perfect state of sanguine cognition. The first value is Strive For Unity. When the totality of the people of the world want to accomplish something, then it becomes done. Thus once the people of the world all strive towards the same ends there is nothing that is impossible. Just think of it! A world where any dream can be fulfilled, any good can be achieved. But as thou canst see plainly by looking at our own sad society, when the people of the world are disunited, it is a miracle that anything gets accomplished!\"")
    say(itemref, "\"The second value is Trust Thy Brother. Thou must surrender thy fear, prejudice and suspicion. Look to thine own self! Before thou dost question anything, question thyself! The world is a place where the balances of nature are at work to protect thee every second without thee even realizing it! What canst thou accomplish in this world if thou dost spend all thy time questioning thy brother?! Is he working as hard as I? What are his true motivations? As thou dost waste thine energies wondering, he sees thee and starts wondering these same things about thee. Thus is the world diminished!\"")
    say(itemref, "\"The third value is Worthiness Precedes Reward. There is not one among us who is without desire. Much of the misery in the world can be traced to unfulfilled desires. But one moment! Why dost thou deserve what thou dost desire? Most people get what they are worthy of in this life. If thou art not worthy of thy desire then thou shouldst not be surprised if thy desires are unfulfilled. If thou dost become worthy only then hast thou become open to fulfilling thy desires. Desire is a strange thing. Many long for things they do not really want. What they really desire is worthiness itself!\"")
    say(itemref, "\"I have just told thee all that thou dost need to follow the Triad Of Inner Strength. The lessons are simple. The true measure of thine understanding comes in how absolutely thou wilt apply them to thy life. Thou now knowest all thou wilt ever need. Thou dost not need the arcane knowledge of the dying art of magic. Thou dost not need the unsure hand of the healer and his limited knowledge. All that thou wilt ever need is to continuously seek out the best in thyself and to live amongst those that would do the same. Only then art thou truly walking with The Fellowship.\"")
    say(itemref, "\"Now I think would be a good time to hear the words of our fellow members. To hear them share with us how The Fellowship has been bringing positive change to their lives.\"")
    local2 = call_08F7H(-41)
    if local2 then
        switch_talk_to(41, 0)
        say(itemref, "\"The Fellowship has shown me that I was afraid of myself and that I had to open myself up to life's experiences,\" says Candice.*")
        _HideNPC(-41)
    end
    local3 = call_08F7H(-43)
    if local3 then
        switch_talk_to(43, 0)
        say(itemref, "\"The Fellowship helps me be more honest with people,\" says Patterson.*")
        switch_talk_to(26, 0)
        say(itemref, "\"Thank thee for sharing, Patterson.\"*")
        _HideNPC(-43)
    end
    local4 = call_08F7H(-45)
    if local4 then
        switch_talk_to(45, 0)
        say(itemref, "\"The Fellowship has taught me how to better perform my duties as the Caretaker of the Royal Orchards,\" says Figg.*")
        _HideNPC(-45)
    end
    local5 = call_08F7H(-53)
    if local5 then
        switch_talk_to(53, 0)
        say(itemref, "\"The Fellowship has taught me to, first and foremost, treat people with respect,\" says Gaye.*")
        _HideNPC(-53)
    end
    local6 = call_08F7H(-55)
    if local6 then
        switch_talk_to(55, 0)
        say(itemref, "\"After joining The Fellowship I learned how to be a man's man,\" says Grayson.*")
        _HideNPC(-55)
    end
    local7 = call_08F7H(-58)
    if local7 then
        switch_talk_to(58, 0)
        say(itemref, "\"The Fellowship is helping me back from the brink of personal and financial oblivion,\" says Gordon.*")
        switch_talk_to(26, 0)
        say(itemref, "\"Right thou art, brother!\"*")
        _HideNPC(-58)
    end
    local8 = call_08F7H(-59)
    if local8 then
        switch_talk_to(59, 0)
        say(itemref, "\"The Fellowship has freed me from the illusory appeals of mediocrity,\" says Sean.*")
        _HideNPC(-59)
    end
    local9 = call_08F7H(-63)
    if local9 then
        switch_talk_to(63, 0)
        say(itemref, "\"In The Fellowship I am learning that I need to devote my life to a special purpose,\" says Millie.*")
        _HideNPC(-63)
    end
    local10 = call_08F7H(-2)
    if local10 then
        switch_talk_to(2, 0)
        say(itemref, "\"This whole ceremony and everyone in it doth give me the willies!\"*")
        _HideNPC(-2)
    end
    local11 = call_08F7H(-1)
    if local11 then
        switch_talk_to(1, 0)
        say(itemref, "\"'Tis a sad thing to see so many people who have nothing else better in their lives than blindly following this dubious spiritual leader.\"*")
        _HideNPC(-1)
    end
    local12 = call_08F7H(-3)
    if local12 then
        switch_talk_to(3, 0)
        say(itemref, "\"'Tis a sad thing that Britannia has fallen so far as to leave itself open to a group like this Fellowship.\"*")
        _HideNPC(-3)
    end
    local13 = call_08F7H(-4)
    if local13 then
        switch_talk_to(4, 0)
        say(itemref, "\"'Tis a sad thing when I cannot even keep my eyes open from the boredom of this Fellowship ceremony!\"*")
        _HideNPC(-4)
    end
    switch_talk_to(26, 0)
    say(itemref, "From watching Batlin and the others you get the feeling that the Fellowship ceremony is going to last long into the night. Now would be a good moment to slip away without drawing much attention to yourself...*")
    return
end