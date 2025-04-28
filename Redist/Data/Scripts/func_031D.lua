require "U7LuaFuncs"
-- Function 031D: Manages scroll text display
function func_031D(itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    local0 = callis_0014(itemref)
    if local0 == 45 then
        calle_0710H(itemref)
    end
    callis_0086(itemref, 14)
    callis_0055(itemref)
    if local0 > 51 then
        say("This is not a valid scroll")
    elseif local0 == 0 then
        say("From the Desk of Lord British")
    elseif local0 == 1 then
        say("How to keep the Avatar busy for hours looking for a clue--")
        say("(please scroll forward)*")
        say("How to keep the Avatar very busy for hours looking for a clue--")
        say("(please scroll forward)*")
        say("How to keep the Avatar very very busy for hours looking for a clue --")
        say("(please scroll forward)*")
        say("How to keep the Avatar very -very- very busy for hours looking for a clue --")
        say("(please scroll forward)*")
        say("How to keep the Avatar so very -very- very incredibly busy for hours looking for a clue --")
        say("(please scroll forward)*")
        say("How to keep the Avatar so very -very- absolutely unbelievably and incredibly busy for hours looking for a clue --")
        say("(please scroll forward)*")
        say("When thou art not so busy, thou shouldst seek out Margareta the gypsy in Minoc and have thy fortune told!")
        say("Signed - Chuckles")
    elseif local0 == 2 then
        say("KEEP BRITANNIA CLEAN -- SEND THE GARGOYLES BACK! ~~ ~~ ~~ Paid for by the Britannian Purity League")
    elseif local0 == 3 then
        if get_flag(299) then
            say("The cutting down of Silverleaf Trees will be done no longer by you. Your compliance is desired. You are thanked, Woodsman.~~Salamon")
        else
            say("The cutting down of Silverleaf Trees will be done no longer by you. Your compliance is desired. You are thanked, Woodsman.~~Salamon~~ ~~Ben, the logger")
        end
    elseif local0 == 4 then
        say("Bill of Punative Action for the Distribution of Waste Products in Lock Lake~~78934979.S3, section 835~~")
        say("Whereby the members of the offending party shall be immersed in the lake, heretofore refered to as Lock Lake, up to their necks for not more than three consecutive days and not fewer than...")
    elseif local0 == 5 then
        say("\"Thou hast received payment. Make the delivery tonight.\"")
    elseif local0 == 6 then
        say("Once the construction is complete, store the blackrock in the hold of The Crown Jewel.")
    elseif local0 == 7 then
        local1 = call_0908H()
        say("Finster - Britain (x)")
        say("Duncan - Buccaneer's Den (x)")
        say("Christopher - Trinsic (x)")
        say("Frederico - Minoc (x)")
        say("Tania - Minoc (x)")
        say("Alagner - New Magincia (x)")
        say("Lord British - Britain ( )")
        say(", the Avatar - ( )", local1)
    elseif local0 == 8 then
        say("The stone pedestal should be four feet high, three feet wide and two feet deep. Atop each of the three pedestals shall be set the three receptacles: the tetrahedron, the sphere, and the cube.~~All of these items for the defense mechanism of the portal have already been constructed by the Trinsic blacksmith.")
    elseif local0 == 9 then
        say("Crown Jewel~~Sunrise tomorrow - sail for the Isle of the Avatar!")
    elseif local0 == 10 then
        set_flag(575, true)
        say("To tell you the amount of explosives is quite adequate to destroy the altars. To remind you of the need for silence, and of the punishment it will help you avoid.~~--Runeb")
    elseif local0 == 11 then
        say("The Narwhal shall be a fine, fine vessel, measuring 100 cubits from bow to stern. She shall be constructed of the finest Yew wood, with a ballast of thirty-seven cubits. After the planks are retrograded, I shall preceriprocate the bottom decks to insure their verbosity.~Each bunk shall fit exactly within the 3 foot by four 14 cubit cabin, except for the first mate and sergeant's quarters, which will be octagnal the size...~~ ~~Owen of Minoc")
    elseif local0 == 12 then
        say("BRITANNIAN TAX COUNCIL")
        say("TAX DECLARATION")
        say("To insure the proper record-keeping of thine income and spending, first replicate in triplicate the files numbered 37-A through 1204-W of the forms. Following each copy, compile the aggregate number of expenditures and multiply by tables 3, 69, 106. The next involves...")
    elseif local0 == 13 then
        say("First thou must needs fill a crucible with metal. Then, using the bellows, make the fire as hot as possible. When the flame no longer continues to glow, thou art ready to proceed by setting the crucible on the fire to melt the metal.~~ Afterwards, pour the molten metal into the blade mold and let it cool. Be warned! The crucible is at an extremely high temperature. Do not burn thyself.~~ With the tongs, lift the cooled blade from the mold. Again heat up the fire and set the blade within. Be careful not to let it lose its shape though. Just set it in there long enough to become malleable.~~ When it is ready, take it to the anvil and finish shaping it with the hammer. When thou hast the desired blade, find the quenching barrel and plunge the sword in the cool water. It will quickly harden.~~ All that thou must needs do now is to put the pommel over the tang. It takes some doing to make a fine, sturdy sword, but the finished weapon is well worth it!")
    elseif local0 == 14 then
        say("By proclamation of Lord British this is an official document denoting ownership of the heretofore mentioned sailing vessel. Forgery of this title is prohibited under law no. 1989832.A5, section 809.")
        say("     DEED~~SHIP NAME: The Scaly Eel~~COMPLETION DATE: 7-21-0355~~ INSPECTION DATE: 8-2-0355~~SHIPWRIGHT: Gargan of Trinsic")
    elseif local0 == 15 then
        say("By proclamation of Lord British this is an official document denoting ownership of the heretofore mentioned sailing vessel. Forgery of this title is prohibited under law no. 1989832.A5, section 809.")
        say("     DEED~~SHIP NAME: The Beast~~COMPLETION DATE: 3-12-0358~~ INSPECTION DATE: 3-19-0358~~SHIPWRIGHT: Clint of Britain")
    elseif local0 == 16 then
        say("By proclamation of Lord British this is an official document denoting ownership of the heretofore mentioned sailing vessel. Forgery of this title is prohibited under law no. 1989832.A5, section 809.")
        say("     DEED~~SHIP NAME: The Excellencia~~COMPLETION DATE:~~ INSPECTION DATE:~~SHIPWRIGHT: Owen of Minoc")
    elseif local0 == 17 then
        say("By proclamation of Lord British this is an official document denoting ownership of the heretofore mentioned sailing vessel. Forgery of this title is prohibited under law no. 1989832.A5, section 809.")
        say("     DEED~~SHIP NAME: The Nymphet~~COMPLETION DATE: 12-22-0357~~ INSPECTION DATE: 1-3-0358~~SHIPWRIGHT: Russell of New Magincia")
    elseif local0 == 18 then
        say("By proclamation of Lord British this is an official document denoting ownership of the heretofore mentioned sailing vessel. Forgery of this title is prohibited under law no. 1989832.A5, section 809.")
        say("     DEED~~SHIP NAME: The Lusty Wench~~COMPLETION DATE: 6-14-0327~~ INSPECTION DATE: 6-24-0359~~SHIPWRIGHT: Kethron of Moonglow")
    elseif local0 == 19 then
        say("By proclamation of Lord British this is an official document denoting ownership of the heretofore mentioned sailing vessel. Forgery of this title is prohibited under law no. 1989832.A5, section 809.")
        say("     DEED~~SHIP NAME: The Dragon's Breath~~COMPLETION DATE: 5-18-0342~~ INSPECTION DATE: 5-23-0342~~SHIPWRIGHT: Rohden of Britain")
    elseif local0 == 20 then
        say("ZARA's DANCE~For the lute.")
    elseif local0 == 21 then
        say("WINDY NIGHT~For the harp.")
    elseif local0 == 22 then
        say("ONE OF THE BEAST~For the harpsichord.")
    elseif local0 == 23 then
        say("SPRING FIRE~For the xylophone.")
    elseif local0 == 24 then
        say("By proclamation of Lord British this is an official document denoting ownership of the heretofore mentioned sailing vessel. Forgery of this title is prohibited under law no. 1989832.A5, section 809.")
        say("DEED~~SHIP NAME:~~COMPLETION DATE:~~INSPECTION DATE:~~ SHIPWRIGHT:")
    elseif local0 == 25 then
        say("Bill of Underwater Scavenging and Cricket Playing~~23568976.Y7, section 069~~Whereby the participants belonging to the first party of the first team may also engage in supplementary treasure seeking within the bounds of two-hundred and thirty-nine feet from the docks. ~~Whereby the participants belonging to the second party of the second team may follow accordingly provided they use no handkerchiefs within the bounds of seven and one-half feet of the first party of the first part. ~~Be it known the second party of the first part may not involve outside...")
    elseif local0 == 26 then
        say("G.J.'S SKETCH PAD")
    elseif local0 == 27 then
        say("~~Between these columns, upon this pedestal, once sat the CODEX OF ULTIMATE WISDOM.~~Now it lies in the infinite darkness of the Void, forever shining as a beacon of knowledge to the races of man and gargoyle.~~Those who would seek the wisdom contained therein must unite the mystic lenses in the same manner as the Avatar did more than two hundred years ago.~~Lord British~~To search for Singularity through Control, Passion, and Dilligence.~~Lord Draxinusom")
    elseif local0 == 28 then
        say("~     Ownership of Horse and Carriage~~This writ entitles the bearer to ownership and use of the wagon and its accompanying horse, Fletcher. Misuse of this writ by those not in full ownership of aforementioned wagon and horse is punishable under section 7890.3D5 of the Private Ownership of Goods and Livestock Act, as enforced by the Britannian Tax Council.")
    elseif local0 == 29 then
        say("~     Ownership of Horse and Carriage~~This writ entitles the bearer to ownership and use of the wagon and its accompanying horse, Brikabrak. Misuse of this writ by those not in full ownership of aforementioned wagon and horse is punishable under section 7890.3D5 of the Private Ownership of Goods and Livestock Act, as enforced by the Britannian Tax Council.")
    elseif local0 == 30 then
        say("Bill of Indoor Animal Housing~~89634510.P4, section 402~~")
        say("Whereby the participants belonging to the owning party are permitted to store both animal and goods related to the care of said animal indoors, providing...")
    elseif local0 == 31 then
        say("Bill of Carriage Construction ~~48382745.F3, section 058~~")
        say("Whereby wood-builders and metal-workers may cross skills without the need for guild officiation limited by the following principles...")
    elseif local0 == 32 then
        say("Bill of Cabin Construction Near Granite Zoned Districts~~ 48923013.Q4, section 193~~")
        say("Whereby the participants belonging to the Stone Masons's Guild may register complaints unto the party of the Cabin Builders, represented here as and/or by members for the Wood-Builders Guild with the intent of...")
    elseif local0 == 33 then
        say("By proclamation of Lord British this is an official document denoting ownership of the heretofore mentioned sailing vessel. Forgery of this title is prohibited under law no. 1989832.A5, section 809.")
        say("     DEED~~SHIP NAME: Anne's Revenge~~COMPLETION DATE:11-23-0198 ~~INSPECTION DATE: 1-17-0199~~SHIPWRIGHT: Alluria of New Magincia")
    elseif local0 == 34 then
        say("By proclamation of Lord British this is an official document denoting ownership of the heretofore mentioned sailing vessel. Forgery of this title is prohibited under law no. 1989832.A5, section 809.")
        say("     DEED~~SHIP NAME: Golden Hinde~~COMPLETION DATE: 7-08-0105 ~~INSPECTION DATE: 7-12-0105~~SHIPWRIGHT: Gendra of Trinsic")
    elseif local0 == 35 then
        say("By proclamation of Lord British this is an official document denoting ownership of the heretofore mentioned sailing vessel. Forgery of this title is prohibited under law no. 1989832.A5, section 809.")
        say("     DEED~~SHIP NAME: Bounty~~COMPLETION DATE: 5-27-0185 ~~INSPECTION DATE: 6-04-0185~~SHIPWRIGHT: Gibson of Minoc")
    elseif local0 == 36 then
        local1 = call_0908H()
        say("Dearest Iolo,~     In Buccaneer's Den I came across an old pirate who told me he had sailed across the waters of Britannia more times than I was summers old. On a gamble, I asked if he had ever heard of the legendary Serpent Isle. He had! And he even had a map that would tell how to locate the island. I bought the map and have already begun my search. However, I made a copy so that thou mayest follow me after thy current adventures have ended. I have left the copy with Lord British, but he promised he wouldst not give it to thee until thou hast completed thy explorations with ", local1)
        say(".~~     'Til I see thee again, my love!~     Gwenno")
    elseif local0 == 37 then
        say("~~All is not as it seems...")
    elseif local0 == 38 then
        say("~     Ownership of Horse and Carriage~~This writ entitles the bearer to ownership and use of the wagon and its accompanying horse, ____________. Misuse of this writ by those not in full ownership of aforementioned wagon and horse is punishable under section 7890.3D5 of the Private Ownership of Goods and Livestock Act, as enforced by the Britannian Tax Council.")
    elseif local0 == 39 then
        say("~Very well. It is agreed that we attack Lord British's castle at the dawning of the seventh day.~~Fransisa~Corwin~ Brax~ Athelas")
    elseif local0 == 40 then
        say("~     Selwyn's Last Will:~~")
        say("     I do hearby bequeath my firedoom staff to anyone who is mighty and cunning enough to penetrate the defenses of my fortress and slay my pet.~~")
        say("     May all who read this rot in death!~")
        say("          Selwyn")
    elseif local0 == 41 then
        say("     Throne of `Change' keeps thee at bay, but `Virtue' shall show the way!")
    elseif local0 == 42 then
        say("     I have been here for more days than I am able to remember, though I have not forgotten the day I entered this forsaken cave which has become my tomb. That was 2-29-0227. But my food ran out long ago, and the rats are more interested in eating me than letting me eat them. My strength is gone, as is my will. If thou dost find this, please tell Mythra I love her.")
        say("     --Denyel")
    elseif local0 == 43 then
        say("~     Lord British's Last Will and Testament:~~")
        say("     Being of sound mind and body, I hereby bequeath all of my belongings to... Nell, my beloved chambermaid. She has kept me warm so many nights, which is more than I can say for most of my bloody subjects! And to our unborn child, I bequeath my crown. Long live the king. Or queen, whichever it shall be!~~")
        say("          Lord British")
    elseif local0 == 44 then
        say("By proclamation of Lord British this is an official document denoting ownership of the heretofore mentioned sailing vessel. Forgery of this title is prohibited under law no. 1989832.A5, section 809.")
        say("     DEED~~SHIP NAME: Golden Ankh~~COMPLETION DATE: 3-8-0338~~ INSPECTION DATE: 3-18-0338~~SHIPWRIGHT: Clint of Britain")
    elseif local0 == 45 then
        calle_0710H(itemref)
    elseif local0 == 47 then
        say("Day 1: I circumvented the living statues and made it through the gate. Despite the long boat ride, I feel no weakness. I suspect the excitement of the quest gives my strength. I will rest soon.")
        say("Day 2: In the large room I encountered the lightening at the \"X.\" Very clever that -- predicting I would not trust the marking. I will not be so foolish again.")
        say("Day 3: I found a large chamber, one in which I can see fully its entire contents. Yet, there are invisible barriers that prevent me from entering.")
        say("Day 4: The barriers are not what I first suspected. They are walls. I can see the exit, and yet I cannot reach it. This is maddening!")
        say("Day 5: I wish I had brought more rations. I did not expect to be caught like this. I will starve soon if I do not find the way out... and food and water!")
        say("Day: I am still without food and whales... I seee but cannot... well hilp arrive in time!? I think but am thoughtful...")
    elseif local0 == 48 then
        say("... I have been in this wretched place for more weeks than I care to remember -- than I COULD remember were I to try. I have seen far too much in the way of deception and falsehood. I am forced to wonder how this maze of tunnels can demonstrate Truth. There is one lesson I can claim to have learned, thou I wonder with whom I can ever share it: I am not the Avatar. I wish with my last breath good luck to he... or she... who can truly claim the Avatarhood. As I lay here dying, I ask but one request of the finder: remember well my strug...")
    elseif local0 == 49 then
        say("... I write this with what little hope I have left. Frenke has now died -- killed by shooting balls of flame. I will attempt to navigate the treacherous tunnel of fire alone. Should my quest succeed, I will emerge the Avatar. I relflect not upon my other destiny...")
        say("     This will be my last entry. My ink is all but gone, much like my will. I no longer marvel at how a man can give up, like the poor fool we found at the end of the invisible maze. But I refuse to succumb to the call of my weary bones. I will trudge on.")
    elseif local0 == 50 then
        say("SCROLL OF INFINITY~~ artifact TalismanOfInfinity -~ if Reality is Magic -~ if Locale(Artifact) is Void -~ Convex is FindInBritannia(ConvexLens)~ Concave is FindInBritannia(ConcaveLens)~ ~ if DoLightTest(Concave, Convex) -~ TalismanList is BritanniaSearch(Talisman)~ ~~ Counter is 0~ foreach Talisman in TalismanList -~ if KnowType(Talisman) is Truth -~ Counter is Counter and 1~ --~ if KnowType(Talisman) is Love -~ Counter is Counter and 1~ --~ if KnowType(Talisman) is Courage -~ Counter is Counter and 1~ --~ ~ if Counter is 3 -~ DoVoidAccess()~ ~~ InifinityAction is Action(Instance,~ aPlanarTravel, Britannia,~ aCallBack, TalismanOfInfinity)~ --~ if Reality is PseudoScience -~ EvilEntity is EntitySearch(All, Powerful, Evil)~ if EvilEntity -~ Check is PushReality(EvilEntity)~ if not Check -~ Test(\"Thou shalt never see this!\")")
    elseif local0 == 51 then
        say("The Diary of Erethian:~~")
        say("Entry #1:")
        say("     Perhaps someday I shall have the time and inclination to write on this parchment, but for now it pleases me not to.")
    end
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function get_flag(id)
    return false -- Placeholder
end

function set_flag(id, value)
    -- Placeholder
end

function eventid()
    return 0 -- Placeholder
end