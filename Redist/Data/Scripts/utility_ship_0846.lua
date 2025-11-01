--- Best guess: Conducts The Fellowship's examination, presenting eight hypothetical questions to assess the player's character, concluding with membership approval.
function utility_ship_0846()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    switch_talk_to(-26)
    var_0000 = get_player_name()
    add_dialogue("These questions are all hypothetical. Do not let them confuse or upset thee.")
    add_dialogue("Question One: Thou art feeling depressed right now. Is it more likely because -")
    add_dialogue("A: Thou hast disappointed a friend, or")
    add_dialogue("B: A friend has disappointed thee?")
    var_0001 = utility_unknown_1035({"B: Friend has disappointed me", "A: I disappointed a friend"})
    if var_0001 == "A: I disappointed a friend" then
        add_dialogue("\"I can tell from thine answer that thou art a person who takes their responsibilities to others very seriously, and perhaps tends to put too much pressure on oneself to please others.\" Batlin smiles and nods.")
    else
        add_dialogue("\"I can tell from thine answer thou art a person who tends to trust people and is often willing to give people another chance - even after ample demonstration that they are not worthy of one.\" Batlin smiles and nods.")
    end
    clear_answers()
    add_dialogue("\"Question Two: Thou art at a feast hosted by a very high-ranking local official. Thou dost believe the food he has ordered to be served is little more than swill, and thou dost notice that the other guests certainly think so. When thine host asks if thou dost like the food, dost thou")
    add_dialogue("A: tell the truth, or")
    add_dialogue("B: lie to him?\"")
    var_0002 = utility_unknown_1035({"B: Lie to him", "A: Tell the truth"})
    if var_0002 == "A: Tell the truth" then
        add_dialogue("\"Thy response shows thou art a bluntly honest person, who mayest occasionally say things that people may not like hearing, but thine intentions are noble ones.\" Batlin makes a sweeping gesture with his hand.")
    else
        add_dialogue("\"Thy response shows thou art a person who is deeply concerned with the feelings of others, a person to whom manners and graciousness are of the highest import.\" Batlin makes a sweeping gesture with his hand.")
    end
    clear_answers()
    add_dialogue("\"Question Three: Thou hast taken the last room available at an inn. Upon entering it thou dost find that it is filthy. It is the middle of the night, there is no one to clean it and there is nowhere else to stay. Dost thou")
    add_dialogue("A: clean up the room thyself, at least somewhat, before reposing in it, or")
    add_dialogue("B: dost thou just go to sleep, letting the room remain as thou hast found it?\"")
    var_0003 = utility_unknown_1035({"B: Leave the room as is", "A: Clean the room myself"})
    if var_0003 == "A: Clean the room myself" then
        add_dialogue("\"Thou hast revealed that thou art a person who instinctively believes they are responsible for anything that goes wrong and that it falls to thee to put the whole world right.\" Batlin sighs.")
    else
        add_dialogue("\"Thou hast revealed that thou art a person who tends to accept their fate complacently whenever life appears to be unfair. Thou dost naturally assume that life will be unkind as a protection against when it is.\" Batlin sighs.")
    end
    clear_answers()
    add_dialogue("\"Question Four: At a festive gathering thou dost tell a humorous anecdote, and thou dost tell it very well, creating much amusement. Didst thou tell this comedic story because")
    add_dialogue("A: thou didst enjoy the response that thou didst receive from thine audience, or")
    add_dialogue("B: because thou didst want to please thy friends?\"")
    var_0004 = utility_unknown_1035({"B: I wanted to please friends", "A: I enjoyed the response"})
    if var_0004 == "A: I enjoyed the response" then
        add_dialogue("\"Thine answer shows thou art a person who instinctively sees friends as tools to be used for thine own gratification.\" Batlin frowns slightly.")
    else
        add_dialogue("\"Thine answer shows thou art a person who instinctively feels unworthy of having friends. Thou must continuously buy their attentions by amusing them.\" Batlin frowns slightly.")
    end
    clear_answers()
    add_dialogue("\"Question Five: If thou wert to become a person of leisure, one who had amassed a fantastic fortune of wealth, would it most likely be because")
    add_dialogue("A: thou hadst discovered an infallible method of stealing the money of others, or")
    add_dialogue("B: thou hadst discovered an infallible method of illicitly duplicating the coin of the realm?\"")
    var_0005 = utility_unknown_1035({"B: I duplicated the coin", "A: I stole the money"})
    if var_0005 == "A: I stole the money" then
        add_dialogue("\"From Question Five we learn that thou art a person who instinctively believes that they are incapable of achieving success, someone who feels that they can only profit through the exploitation of others.\" Batlin slowly shakes his head.")
    else
        add_dialogue("\"From Question Five we learn that thou art a person who instinctively believes that they are incapable of achieving success, at best only presenting the illusion of success.\" Batlin slowly shakes his head.")
    end
    clear_answers()
    add_dialogue("\"Question Six: While travelling thou dost find a man in terrible pain. His arm has been grievously injured. A healer tending to him tells thee that the man's arm will have to be removed and that he will require thine assistance to do it. The man says he will recover from his injury and asks thee not to let the healer amputate his arm. Dost thou")
    add_dialogue("A: heed the words of the healer, or")
    add_dialogue("B: respect the wishes of the injured man?\"")
    var_0006 = utility_unknown_1035({"B: Respect the man", "A: Heed the healer"})
    if var_0006 == "A: Heed the healer" then
        add_dialogue("\"By thine answer thou art a person who believes in mercy even when it is not an easy thing, and a person who tries to have the courage of thy convictions.\" Batlin gives thee a knowing look.")
    else
        add_dialogue("\"By thine answer thou art a person who deeply believes in the value of human life and who has a strong sense of faith in the possibilities that life continuously gives us.\" Batlin gives thee a knowing look.")
    end
    clear_answers()
    add_dialogue("\"Question Seven: Thou hast just killed a small dog by throwing a rock at it. Is it more likely that thou hast done this because")
    add_dialogue("A: the dog was going to attack thee, or")
    add_dialogue("B: the dog was going to attack someone else?\"")
    var_0007 = utility_unknown_1035({"B: It was to attack another", "A: It was to attack me"})
    if var_0007 == "A: It was to attack me" then
        add_dialogue("\"This question tells us that thou art an overly defensive person. Thou dost need to stop assuming that the world around thee exists only to bring thee potential harm.\" Batlin strokes his chin thoughtfully.")
    else
        add_dialogue("\"This question tells us that thou art an overly aggressive person. Thou dost need to stop trying to solve all of thy problems through violence.\" Batlin strokes his chin thoughtfully.")
    end
    clear_answers()
    add_dialogue("\"Question Eight: Thou art in a boat with thy betrothed and thy mother. The boat capsizes. In the choppy waters thou canst only save thyself and one other person. Who dost thou save from drowning,")
    add_dialogue("A: thy betrothed, or")
    add_dialogue("B: thy mother?\"")
    var_0008 = utility_unknown_1035({"B: My mother", "A: My betrothed"})
    if var_0008 == "A: My betrothed" then
        add_dialogue("\"While risking thy life to save the life of thy betrothed is admirable, I cannot help but wonder what suppressed hostility thou dost have towards thy mother as thou wouldst simply let her drown.\" Batlin shrugs.")
    else
        add_dialogue("\"While risking thy life to save the life of thy mother is admirable, I cannot help but wonder if thou mightest have a problem getting along with the opposite gender as thou wouldst simply let thy betrothed drown.\" Batlin shrugs.")
    end
    clear_answers()
    add_dialogue("\"Thou art a person of strong character, Avatar, but one who is troubled by deep personal problems that prevent thee from achieving thy true potential for greatness. In short, thou art precisely the type of person for which The Fellowship was created.")
    add_dialogue("\"I welcome thee to our fold. Know that the path of the Triad is not an easy one but its rewards are bountiful. I will, of course, waive the usual sabbatical of study that is required before one achieves membership. Thou art, after all, the Avatar.")
    add_dialogue("\"However, as one of our tenets prescribes, Worthiness Precedes Reward. Thou must embark on a task or two for The Fellowship before thou can be properly inducted and receive thy medallion.\"")
    set_flag(150, true)
    utility_unknown_0849()
end