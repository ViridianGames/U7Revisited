--- Best guess: Manages a book, displaying its content based on quality (ID), covering various texts from novels to journals.
function func_0282(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        var_0000 = 137
        set_object_quality(objectref, 14)
        unknown_0055H(objectref)
        var_0001 = objectref
        var_0002 = _get_object_quality(var_0001)
        if var_0002 > var_0000 then
            add_dialogue("This is @not a @valid book")
        elseif var_0002 == 0 then
            add_dialogue("MORGAN'S GUIDE TO UNIFINISHED NOVELS", "by Morgan", "An enlightening discourse on the enigma of blank tomes.", "Beginning with the heretofore unresolved mysteries of empty...")
        elseif var_0002 == 1 then
            add_dialogue("\"HOW DEATH AFFECTS THOSE WHO WORK AROUND IT WITH REGULARITY\"", "Day 1: Subject (Tiery) seems friendly enough and willing to accept my company.", "Day 2: Subject exhibiting strange sense of humor, very morbid.", "Day 3:  No contact with subject.", "Day 4: Subject makes continual references to recent conversations with cemetery occupants.", "Day 5: ...")
        elseif var_0002 == 2 then
            add_dialogue("MY NOTEBOOK by Alagner", "These are my observations concerning the organization known as The Fellowship.", "Although The Fellowship portends to be a group of optimists with a philosophy called `Triad of Inner Strength', there are many fallacies which can be gleaned by careful examination of the group's `values'.", "The first `value' is Strive For Unity. This implies that that we should all work together in harmony and towards one goal in life. However, careful examination of this tenet reveals that members of The Fellowship consider themselves an elite group, and a prejudicial one at that. They tend to believe that if one is not for them, then they are indeed against them! And if one is against them, then may fortune be with that person, for he/she may very well come to a bad end!", "The second `value' is Trust Thy Brother. This implies that each member trusts implicitly other Fellowship members, and that each will do favors or deeds for another without question. On the other hand, this might mean that a member should do what another says REGARDLESS of the implications of the act. In other words, `do as I say and do not question it!' seems to be the underlying subtext of this tenet.", "The third `value' is Worthiness Precedes Reward. If one does good deeds for The Fellowship, then one will be rewarded. The other side of the coin, of course, is that if one does NOT do good deeds for The Fellowship, then one will get his JUST reward! In The Fellowship, a `reward' can be either `good' or `bad'!", "The Fellowship has been duping the masses of Britannia now for twenty years. They are becoming stronger and stronger. After careful study, I have come to the conclusion that the group is serving some higher, malevolent entity, referred to by the organization's inner circle as `The Guardian'. More information needs to be obtained about The Guardian, but I am certain that he is very dangerous.", "The Fellowship seems to be organized into three distinct grades of members. Grade One consists of the general masses of naive innocents who have joined, thinking that their pathetic little lives will be helped in some way. Grade Two consists of the various branch leaders who make up the inner circle of Fellowship leaders.", "There is also a Grade Three -- those Fellowship leaders who are in administrative positions within the group: men such as Batlin, and the mysterious couple Elizabeth and Abraham who travel the country distributing The Fellowship's funds. (Not much is known about these two -- it is said they are twins -- brother and sister.) I believe that the few Grade Three members are in direct communication with The Guardian and believe they will be serving as his lieutenants should The Guardian ultimately gain power in the land.", "Already, The Guardian is promising to be a powerful threat. Magic in Britannia has taken a turn for the worse in the past few years. I believe that The Guardian has done something to cause this malady. Not many people have noticed that Britannia's problem with Moongates -- they're being so unreliable -- occurred around the same time. It follows that The Guardian is most likely responsible for this serious plague.", "The Guardian also possesses some kind of power which allows him to speak to and `charm' naive innocents so that they will gladly join The Fellowship and become Grade One members. These unfortunate lambs will most likely become The Guardian's slaves should he ever come into power.", "After I have obtained enough proof of my theories concerning The Fellowship, I shall present this notebook to Lord British himself and rid Britannia of these very dangerous, lying fascists.")
        elseif var_0002 == 3 then
            add_dialogue("OBSERVATIONS OF BLACK ROCK, by Rudyom The Mage", "The mysterious substance known as Black Rock is completely indestructible. Only by magical means can it be molded and shaped.", "Black Rock can be found in small quantities beneath the ground, sometimes near lodes of iron ore or lead.", "Black Rock can be excavated by conventional means, but melting it down into a malleable substance is impossible, except by magic.", "I have found that a combination of electrical energy and magnetic energy has a profound effect upon the substance. Together, these properties cause Black Rock to become permeable, that is, one can put one's hand through the substance as if it were water!", "Further study reveals that Black Rock might work as a teleportation device if magic, electrical energy, magnetic energy, and the correct alignment of heavenly bodies act together upon the substance. This theory still needs to be tested.", "The Black Rock transmuter I created out of an old wand does not work. It was meant to shoot electrical and magnetic charges into Black Rock, but all it does is make the substance explode! (I must be careful not to let the transmuter get into the wrong hands. Pointing it at a large quantity of Black Rock might produce a devastating explosion!)", "I must quit for the day. The headaches that have been plaguing me have gotten worse. I am forgetting more and more. Very soon, I am afraid, I will forget how to cast simple spells. I believe something might be affecting the magical ether. But I cannot be sure...")
        elseif var_0002 mined from the poisonous swamps.")
        elseif var_0002 == 38 then
            add_dialogue("RINGWORLD", "by Larry Niven", "Herein lie the words that tell of adventures to be had in the space between Britannia and the heavens. The work, although fictional, preposes that there are many undiscovered lands that lie between Britannia and other suns.")
        elseif var_0002 == 39 then
            add_dialogue("THE APOTHECARY'S DESK REFERENCE", "by Fetoau", "It is the author's expectation that thou art reading this to familiarize thyself with the effects of various potions based on their color. The first part of this work will discuss such aspects, with the remaining pages covering the materials and steps required to make such alchemal creations.", "Definitions:", "Black potion: Drinking this will render the individual invisible for several minutes.", "Blue potion: This mixture will put the imbiber into a deep sleep.", "Orange potion: This potion will awaken an individual who was magically put to sleep.", "Purple potion: This concoction will provide magical protection for several minutes of hard fighting.", "White potion: This potion will provide a small bit of illumination, much like a candle, for a few minutes.", "Yellow potion: This powerful mixture will give healing aid to the imbiber's wounds.", "WARNING: Green potion: This potion is a dangerous toxin, and will poison the imbiber, possibly killing the individual.", "Red potion: This fabulous drink will cure most poisons, including those acquired from the slugs in the swamps and that gained from drinking a GREEN potion.", "This next section details how one can best recreate these uncanny concoctions...")
        elseif var_0002 == 40 then
            add_dialogue("MAGIC AND THE ART OF HORSE-AND-WAGON MAINTENANCE", "This lengthy tome contains wonderous jewels of wisdom concerning all aspects of life. The words exalt the value of basic, common pleasures and denounce the relevance that material possesions have to happiness. The philosophy is simple enough to be easily grasped, yet complete enough to be quite comprehensive.", "The main irony of the title is apparent to anyone who has ever cared for a horse, for, as any stablemaster or horse owner can attest, horses need no food or rest.")
        elseif var_0002 == 41 then
            add_dialogue("JESSE'S BOOK OF PERFORMANCE ART", "by Jesse.", "This anthology is filled with many performance art scripts. The author, a controversial and eccentric Britannian actor, maintains that many aspects of both acting and performance art are quite similar.", "...Consider the actor. He uses dialogue, facial changes, and movement to convey his lines. His actions, called a PERFORMANCE, combined with the playwrite's script, express an emotion or a message. The performance artist uses the very same techniques. The one possible exception is that he is both the writer AND the performer. In fact, the practice of many facets of performance art can better an actor's skill...")
        elseif var_0002 == 42 then
            add_dialogue("THE WRITE STUFF", "by Perrin", "Within these pages is found a treatise on the value of literacy and proper writing skills. The first few chapters briefly discuss the various elements of good literature. The subsequent text analyzes the qualities of the elements to determine -why- they are integral to quality literature. The essay ends with a description of the process by which a promising writer can apply what has been learned to construct better prose.")
        elseif var_0002 == 43 then
            add_dialogue("THAT BEER NEEDS A HEAD ON IT!", "by Yongi", "Found within are many a recipe for the most delicious of alcoholic beverages. Not only are the pages filled with descriptions of the various processes by which one produces these drinks, but also with a great number of suggestions for serving methods. In addition, the back index references each drink by type -and- color.")
        elseif var_0002 == 44 then
            add_dialogue("THE PROVISIONER'S GUIDE TO USEFUL EQUIPMENT", "by Dell", "While most suppliers will rave about the effectiveness of a good sword or specially fitted armour, I personally feel that proper exploring gear is much more necessary.", "Consider this, dear reader. While thou might happen to encouter a wild bear in thy travels, or, even less likely, a troll, thou art doubtless going to be in need of much more mundane equipment.", "With thou possibly be outside city walls when darkness comes? Then buy a torch. And how wilt thou carry thy provisions? A backpack wilt prove necessary. And what about a container for thy refreshment? Purchase a jug or bucket. As for...")
        elseif var_0002 == 45 then
            add_dialogue("THE ACCEDENS OF ARMOURY", "by Legh", "This book on heraldry not only describes various houses for ease of recognition, but also demonstrates elements used in their concepton. Thus, this book will also permit the reader to formalize an heraldric symbol of his own.")
        elseif var_0002 == 46 then
            add_dialogue("THE BIOPARAPHYSICS OF THE HEALING ARTS", "by Lady Leigh", "Within this rather in-depth and complex look at healing are the ideas considered to be -the- definitive text on healing wounds, curing poison, and resurrecting the recently dead. Within can be found suggested remedies for any known sickness in Britannia, including the dreaded Zoradin's Disease, which causes a loss of vision followed by an extreme sensitivity to noise.", "In addition, the book lists a few of the after-effects of healing and curing, such as an increase in appetite, intense restlessness, and slight dizzy spells. Though not for good as an introduction to healing for beginners, the tome is perfect for the seasoned healer.")
        elseif var_0002 == 47 then
            add_dialogue("WHAT COLOR IS THY BLADE?", "by Menion", "The first step in effective sword-forging is to fill a crucible with metal. Then, with the bellows, the fire should be made extrememly hot ...", "Afterwards, it is good to have a bucket of water handy to cool the blade. This way, one can handle it without fear of being burned.", "When it is ready, thou shouldst hammer it upon an anvil. By striking it repeatedly, the metal will become flattened and begin to resemble a blade.", "All that thou hast learned up to this point will be for naught if thou dost not use a good file to sharpen thy weapon. The grinding of the file will provide an edge sharp enough to cut through flesh, bone, and even some armours!", "...is arguably the most visible. Far more popular is the Black-Tipped Grackle, but it's predilection for dark, cool areas make is considerable less visible.")
        elseif var_0002 == 48 then
            add_dialogue("THE BLACKSMITH", "by F. LaForge", "Within this book are the secrets to forging a fine blade. This text is considered to be one of the best of its kind.")
        elseif var_0002 == 49 then
            add_dialogue("THIRTEEN MONTHS ON A RAFT", "by Seyour", "This epic details the life of a sailor who survived a shipwreck, only to be cast away alone on the high seas for over a year.")
        elseif var_0002 == 50 then
            add_dialogue("THE DAY IT DIED", "by Sullivan", "This collection of short stories covers various topics. Most of the tales are witty and urbane.")
        elseif var_0002 == 51 then
            add_dialogue("NO ONE LEAVES", "by J. Dial", "The sequel to MURDER BY MONGBAT.", "This short tale is not as gory as the original, but makes up for it with suspense and a surprise ending.")
        elseif var_0002 == 52 then
            add_dialogue("A COMPLETE GUIDE TO BRITANNIAN MINERALOGY", "by W. Harod", "Herein one can find a complete listing of all known minerals and metals found within Britannia.", "...One can find gold primarily in the mountains near Minoc...", "...Blackrock, found only in small quantities, is an amazing substance that is completely indestructible except by magical means...")
        elseif var_0002 == 53 then
            add_dialogue("TREES, AND THEIR INHABITANTS", "by Brommer", "Previously thought to be nothing more than a child's book, this work has been found to be surprisingly accurate in its depiction of Britannian wildlife.", "Day seven: The trees near Trinsic are filled with more varieties of birds than I had previously thought possible.", "Day eleven: I swear I saw a new species of squirrel today. It had a red stripe down its back!", "Day sixteen: Though I have only seen it at night, there seems to be a nocturnal primate living in the trees near Britain.", "Day twenty-eight: The monkeys near Trinsic seem to have a system of communication that is almost a language!", "Day Forty: Nothing new today, just more of the same.", "I wonder why there seem to be so few insects living in these trees? Perhaps it is the salt air...")
        elseif var_0002 == 54 then
            add_dialogue("BLOODIED BLADES", "by Sir Pildar", "This illustrated work covers many aspects of maintaining a fine blade, including how to properly clean one after battle.")
        elseif var_0002 == 55 then
            add_dialogue("THE HUNDRED AND ONE USES FOR THE TROLL SKULL", "by Seyour", "Within this book are listed many of the uses for a troll skull. Most of these are practical, such as using one as a helmet.")
        elseif var_0002 == 56 then
            add_dialogue("BLACK MOON, RED DAY", "by Seyour", "This novel is considered one of Seyour's finest works. Within its pages is found a tale of suspense and intrigue.")
        elseif var_0002 == 57 then
            add_dialogue("TWO IN THE FOG", "by Seyour", "Herein lies a novel of suspense and mystery. The tale concerns two lovers caught in a web of deceit and murder.")
        elseif var_0002 == 58 then
            add_dialogue("THE FOREST OF YEW", "by Seyour", "Though once thought to be a simple child's tale, this book has been found to be surprisingly accurate in its depiction of the forest of Yew.", "As the cities of Britannia grew, the forest of Yew shrank.", "And those savages that once lived within its boundaries were pushed further and further into the remaining woods.", "Oddly enough, there seem to be fewer and fewer of these savages each year.", "Of course, Empire's rise has meant the decline of many a native creature. Consider the plight of the noble bear. Once found in great numbers, they are now quite rare.", "...and remember, the forest of Yew is a dangerous place, filled with wild creatures and even wilder men.")
        elseif var_0002 == 59 then
            add_dialogue("THIS OLDE SHIP", "by Seyour", "This tome covers the history of the ship-building industry in Britannia. Many of the facts are quite interesting.")
        elseif var_0002 == 60 then
            add_dialogue("THE CARVER CODEX", "by Seyour", "Here, finally, is the complete history of the Carver family, from their humble beginnings to their rise to power in Minoc.")
        elseif var_0002 == 61 then
            add_dialogue("HERO FERTILITY DANCES OF THE SOUTH SEA ISLES", "by Seyour", "A warrior's guide to the many tribal dances of fertility found in the south seas. The book is illustrated.")
        elseif var_0002 == 62 then
            add_dialogue("WHAT COULD BE MORE GLORIOUS THAN WAR?", "by Seyour", "Herein are the words that describe the many benefits of war. The author argues that war is not only inevitable, but necessary for the growth of a society.")
        elseif var_0002 == 63 then
            add_dialogue("THE SUMMER OF MAN", "by Seyour", "The story within these pages tells of a young man who, during one summer, learns the true meaning of love and loss.")
        elseif var_0002 == 64 then
            add_dialogue("HITHER COMES THE RAIN", "by Seyour", "Within the pages of this novel is found a tale of a man who must face his past to save his future.")
        elseif var_0002 == 65 then
            add_dialogue("WHITE RAIN", "by Seyour", "This detailed novel tells the tale of a young woman who must overcome great odds to save her family from ruin.")
        elseif var_0002 == 66 then
            add_dialogue("MILORD CONDUCTOR", "by Seyour", "Found within these pages is a novel concerning a man who rises from obscurity to become a great leader.")
        elseif var_0002 == 67 then
            add_dialogue("TO THE DEATH!", "by Seyour", "This book is filled with tales of great battles and heroic deeds. The stories are both exciting and inspiring.")
        elseif var_0002 == 68 then
            add_dialogue("BLADE OF THE HORIZON", "by Seyour", "This novel is considered one of Seyour's finest works. Within its pages is found a tale of adventure and discovery.")
        elseif var_0002 == 69 then
            add_dialogue("THE WINNING OF MISS FORTUNE", "by Seyour", "Herein is the tale of a young man who must overcome great odds to win the heart of his true love.")
        elseif var_0002 == 70 then
            add_dialogue("THE SCENT OF VALOR", "by Seyour", "Herein can be found a novel concerning a young warrior who must face his fears to save his homeland.")
        elseif var_0002 == 71 then
            add_dialogue("HOW THE WEST WAS LOST", "by Seyour", "This tome offers a detailed history of the decline of the western regions of Britannia.")
        elseif var_0002 == 72 then
            add_dialogue("THY MESSAGE OF DOOM", "by Seyour", "Within this book is found a collection of prophecies concerning the end of Britannia.", "To have noticed an increase in the number of natural disasters is to have seen the first sign.", "To have wondered at the increase in disease is to have seen the second.", "To seek communion with the dead is to invite the third sign.", "To hope for a saviour is to hope in vain.", "To hope, and to fail, is to know the final truth.")
        elseif var_0002 == 73 then
            add_dialogue("RIBALD ENCOUNTERS", "by Seyour", "Within the pages of this book are found many a bawdy tale of love and lust.")
        elseif var_0002 == 74 then
            add_dialogue("THE KNIGHT AND THE THIEF", "by Seyour", "This novel describes the unlikely friendship between a noble knight and a cunning thief.")
        elseif var_0002 == 75 then
            add_dialogue("THE TRIO", "by Seyour", "Compiled from the notes of a bard, this novel tells the tale of three friends who share many adventures.")
        elseif var_0002 == 76 then
            add_dialogue("THE BLACK CODEX", "by Seyour", "To extend one's knowledge of magic, one must first understand the basic principles of the art.", "First, thou must procure the necessary components.", "The next step is to prepare the components in the proper manner.", "Now thou shalt need a focus for thy spell.", "...and finally, thou must speak the words of power.")
        elseif var_0002 == 77 then
            add_dialogue("NO WAY TO JUMP", "by Seyour", "Herein lies a novel concerning a man who must face the consequences of his actions.")
        elseif var_0002 == 78 then
            add_dialogue("STEALING THE WIND", "by Seyour", "Kite-building is a noble art, one that requires great skill and patience.")
        elseif var_0002 == 79 then
            add_dialogue("BROMMER'S FLORA", "by Brommer", "This large tome is filled with detailed descriptions of the various plants found in Britannia.", "...The Greer plant is quite common, and can be found in many a forest.", "...The Reaper is a dangerous plant, one that can move and attack the unwary.")
        elseif var_0002 == 80 then
            add_dialogue("BROMMER'S FAUNA", "by Brommer", "Betwixt the pages of this tome one can find detailed descriptions of the animals of Britannia.", "...Deer are quite common, and can be found in many a forest.", "...The fox is a cunning creature, one that is difficult to catch.")
        elseif var_0002 == 81 then
            add_dialogue("BROMMER'S BRITANNIA", "by Brommer", "Betwixt the pages of this tome one can find detailed descriptions of the cities of Britannia.", var_0003 and unknown_0048H() or "", "Betwixt the pages of this tome one can find detailed descriptions of the cities of Britannia.")
        elseif var_0002 == 82 then
            add_dialogue("UP IS OUT", "by Seyour", "Herein is discussed the many theories concerning the shape of Britannia.")
        elseif var_0002 == 83 then
            add_dialogue("WEAVING", "by Seyour", "This is a complete guide to the art of weaving.", "...take the raw materials and spin them into thread...")
        elseif var_0002 == 84 then
            add_dialogue("FOLLOW THE STARS", "by Seyour", "This is a guide to navigation by the stars.")
        elseif var_0002 == 85 then
            add_dialogue("HOW TO CONQUER YOUR FEARS", "by Seyour", "Found within these pages are many a technique for overcoming fear.", "...and after thou hast faced thy fear, thou shalt find it diminished.")
        elseif var_0002 == 86 then
            add_dialogue("TREN I, II, AND III", "by Seyour", "This autobiography tells the tale of a man who rose from poverty to become a great leader.")
        elseif var_0002 == 87 then
            add_dialogue("SIR KILROY", "by Seyour", "This novel depicts the life of a knight who must face many challenges to prove his worth.")
        elseif var_0002 == 88 then
            add_dialogue("MY CUP RUNNETH OVER", "by Seyour", "This illustrated novel tells the tale of a man who finds true happiness in the simple pleasures of life.")
        elseif var_0002 == 89 then
            add_dialogue("SPRING PLANTING", "by Seyour", "Held within these pages is a guide to planting crops in the spring.")
        elseif var_0002 == 90 then
            add_dialogue("SHOOT THE MOON", "by Seyour", "Herein can be found a novel concerning a man who dreams of reaching the stars.")
        elseif var_0002 == 91 then
            add_dialogue("OUTPOST", "by Seyour", "Betwixt the pages of this novel one can find a tale of a man who must defend a lonely outpost.", "...and remember, the outpost is thy home, thy sanctuary.")
        elseif var_0002 == 92 then
            add_dialogue("LANDSHIPS", "by Seyour", "Not only does this book describe the many landships of Britannia, but it also offers a history of their development.")
        elseif var_0002 == 93 then
            add_dialogue("LANDSHIPS OF THE SKIES", "by Seyour", "An illustrated guide to the airships of Britannia.", "...a preferred method of travel for those who can afford it...")
        elseif var_0002 == 94 then
            add_dialogue("WHY GOOD MAGIC GOES BAD", "by Seyour", "Despite the many benefits of magic, there are times when it can go horribly wrong.")
        elseif var_0002 == 95 then
            add_dialogue("WHEN STARTS THE ADVENTURE?", "by Seyour", "Herein can be found a novel concerning a young man who seeks adventure in the wilds of Britannia.")
        elseif var_0002 == 96 then
            add_dialogue("WHAT A FOOL BELIEVES", "by Seyour", "Within the pages of this novel is found a tale of a man who must learn the hard way that not all is as it seems.")
        elseif var_0002 == 97 then
            add_dialogue("THE COMPLEAT BARD", "by Iolo Fitzowen", "Herein are the words of Iolo, the greatest bard in Britannia.", "-- Iolo Fitzowen")
        elseif var_0002 == 98 then
            add_dialogue("BIRDS OF BRITANNIA", "by Brommer", "Bound here is a complete listing of the birds of Britannia.", "...Surprisingly, the common sparrow is not the most numerous bird in Britannia, though arguably the most visible. Far more popular is the Black-Tipped Grackle, but it's predilection for dark, cool areas make is considerable less visible.")
        elseif var_0002 == 99 then
            add_dialogue("I AM NOT A DRAGON", "by Thomson", "Within these pages is a bawdy tale of Belnarth, fictional lord of Serpent's Hold. This volume is part one of a great trilogy involving the humorous exploits of the lord and his fellow knights.")
        end
    end
end