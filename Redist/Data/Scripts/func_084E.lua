-- Conducts the Fellowship examination, presenting questions and responses.
function func_084E()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    switch_talk_to(26, 0)
    local0 = external_0908H() -- Unmapped intrinsic
    add_dialogue("\"These questions are all hypothetical. Do not let them confuse or upset thee.~~\"Question One: Thou art feeling depressed right now. Is it more likely because -~A: Thou hast disappointed a friend, or~B: A friend has disappointed thee?\"")
    local1 = external_090BH({"B: Friend has disappointed me", "A: I disappointed a friend"}) -- Unmapped intrinsic
    if local1 == "A: I disappointed a friend" then
        add_dialogue("\"I can tell from thine answer that thou art a person who takes their responsibilities to others very seriously, and perhaps tends to put too much pressure on oneself to please others.\" Batlin smiles and nods.")
    else
        add_dialogue("\"I can tell from thine answer thou art a person who tends to trust people and is often willing to give people another chance - even after ample demonstration that they are not worthy of one.\" Batlin smiles and nods.")
    end
    external_0009H() -- Unmapped intrinsic
    add_dialogue("\"Question Two: Thou art at a feast hosted by a very high-ranking local official. Thou dost believe the food he has ordered to be served is little more than swill, and thou dost notice that the other guests certainly think so. When thine host asks if thou dost like the food, dost thou~A: tell the truth, or~B: lie to him?\"")
    local2 = external_090BH({"B: Lie to him", "A: Tell the truth"}) -- Unmapped intrinsic
    if local2 == "A: Tell the truth" then
        add_dialogue("\"Thy response shows thou art a bluntly honest person, who mayest occasionally say things that people may not like hearing, but thine intentions are noble ones.\" Batlin makes a sweeping gesture with his hand.")
    else
        add_dialogue("\"Thy response shows thou art a person who is deeply concerned with the feelings of others, a person to whom manners and graciousness are of the highest import.\" Batlin makes a sweeping gesture with his hand.")
    end
    external_0009H() -- Unmapped intrinsic
    add_dialogue("\"Question Three: Thou hast taken the last room available at an inn. Upon entering it thou dost find that it is filthy. It is the middle of the night, there is no one to clean it and there is nowhere else to stay. Dost thou~A: clean up the room thyself, at least somewhat, before reposing in it, or~B: dost thou just go to sleep, letting the room remain as thou hast found it?\"")
    local3 = external_090BH({"B: Leave the room as is", "A: Clean the room myself"}) -- Unmapped intrinsic
    if local3 == "A: Clean the room myself" then
        add_dialogue("\"Thou hast revealed that thou art a person who instinctively believes they are responsible for anything that goes wrong and that it falls to thee to put the whole world right.\" Batlin sighs.")
    else
        add_dialogue("\"Thou hast revealed that thou art a person who tends to accept their fate complacently whenever life appears to be unfair. Thou dost naturally assume that life will be unkind as a protection against when it is.\" Batlin sighs.")
    end
    external_0009H() -- Unmapped intrinsic
    add_dialogue("\"Question Four: At a festive gathering thou dost tell a humorous anecdote, and thou dost tell it very well, creating much amusement. Didst thou tell this comedic story because~A: thou didst enjoy the response that thou didst receive from thine audience, or~B: because thou didst want to please thy friends?\"")
    local4 = external_090BH({"B: I wanted to please friends", "A: I enjoyed the response"}) -- Unmapped intrinsic
    if local4 == "A: I enjoyed the response" then
        add_dialogue("\"Thine answer shows thou art a person who instinctively sees friends as tools to be used for thine own gratification.\" Batlin frowns slightly.")
    else
        add_dialogue("\"Thine answer shows thou art a person who instinctively feels unworthy of having friends. Thou must continuously buy their attentions by amusing them.\" Batlin frowns slightly.")
    end
    external_0009H() -- Unmapped intrinsic
    add_dialogue("\"Question Five: If thou wert to become a person of leisure, one who had amassed a fantastic fortune of wealth, would it most likely be because~A: thou hadst discovered an infallible method of stealing the money of others, or~B: thou hadst discovered an infallible method of illicitly duplicating the coin of the realm?\"")
    local5 = external_090BH({"B: I duplicated the coin", "A: I stole the money"}) -- Unmapped intrinsic
    if local5 == "A: I stole the money" then
        add_dialogue("\"From Question Five we learn that thou art a person who instinctively believes that they are incapable of achieving success, someone who feels that they can only profit through the exploitation of others.\" Batlin slowly shakes his head.")
    else
        add_dialogue("\"From Question Five we learn that thou art a person who instinctively believes that they are incapable of achieving success, at best only presenting the illusion of success.\" Batlin slowly shakes his head.")
    end
    external_0009H() -- Unmapped intrinsic
    add_dialogue("\"Question Six: While travelling thou dost find a man in terrible pain. His arm has been grievously injured. A healer tending to him tells thee that the man's arm will have to be removed and that he will require thine assistance to do it. The man says he will recover from his injury and asks thee not to let the healer amputate his arm. Dost thou~A: heed the words of the healer, or~B: respect the wishes of the injured man?\"")
    local6 = external_090BH({"B: Respect the man", "A: Heed the healer"}) -- Unmapped intrinsic
    if local6 == "A: Heed the healer" then
        add_dialogue("\"By thine answer thou art a person who believes in mercy even when it is not an easy thing, and a person who tries to have the courage of thy convictions.\" Batlin gives thee a knowing look.")
    else
        add_dialogue("\"By thine answer thou art a person who deeply believes in the value of human life and who has a strong sense of faith in the possibilities that life continuously gives us.\" Batlin gives thee a knowing look.")
    end
    external_0009H() -- Unmapped intrinsic
    add_dialogue("\"Question Seven: Thou hast just killed a small dog by throwing a rock at it. Is it more likely that thou hast done this because~A: the dog was going to attack thee, or~B: the dog was going to attack someone else?\"")
    local7 = external_090BH({"B: It was to attack another", "A: It was to attack me"}) -- Unmapped intrinsic
    if local7 == "A: It was to attack me" then
        add_dialogue("\"This question tells us that thou art an overly defensive person. Thou dost need to stop assuming that the world around thee exists only to bring thee potential harm.\" Batlin strokes his chin thoughtfully.")
    else
        add_dialogue("\"This question tells is that thou art an overly aggressive person. Thou dost need to stop trying to solve all of thy problems through violence.\" Batlin strokes his chin thoughtfully.")
    end
    external_0009H() -- Unmapped intrinsic
    add_dialogue("\"Question Eight: Thou art in a boat with thy betrothed and thy mother. The boat capsizes. In the choppy waters thou canst only save thyself and one other person. Who dost thou save from drowning,~A: thy betrothed, or~B: thy mother?\"")
    local8 = external_090BH({"B: My mother", "A: My betrothed"}) -- Unmapped intrinsic
    if local8 == "A: My betrothed" then
        add_dialogue("\"While risking thy life to save the life of thy betrothed is admirable, I cannot help but wonder what suppressed hostility thou dost have towards thy mother as thou wouldst simply let her drown.\" Batlin shrugs.")
    else
        add_dialogue("\"While risking thy life to save the life of thy mother is admirable, I cannot help but wonder if thou mightest have a problem getting along with the opposite gender as thou wouldst simply let thy betrothed drown.\" Batlin shrugs.")
    end
    external_0009H() -- Unmapped intrinsic
    add_dialogue("\"Thou art a person of strong character, Avatar, but one who is troubled by deep personal problems that prevent thee from achieving thy true potential for greatness. In short, thou art precisely the type of person for which The Fellowship was created.\"")
    add_dialogue("\"I welcome thee to our fold. Know that the path of the Triad is not an easy one but its rewards are bountiful. I will, of course, waive the usual sabbatical of study that is required before one achieves membership. Thou art, after all, the Avatar.\"")
    add_dialogue("\"However, as one of our tenets prescribes, Worthiness Precedes Reward. Thou must embark on a task or two for The Fellowship before thou can be properly inducted and receive thy medallion.\"")
    set_flag(150, true)
    external_0851H() -- Unmapped intrinsic
    return
end