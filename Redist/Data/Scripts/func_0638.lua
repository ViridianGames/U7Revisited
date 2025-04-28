require "U7LuaFuncs"
-- Manages book reading, displaying content based on item quality, with special handling for specific books and flags.
function func_0638(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    local0 = get_item_quality(itemref)
    if eventid ~= 1 and eventid ~= 2 then
        return
    end

    if eventid == 2 then
        if local0 == 144 and get_item_type(itemref) == 642 then
            say("@Odd. The page is smudged with dirt here. I cannot make out this text.@")
            local1 = set_item_quality(itemref, 145)
            local1 = add_item(itemref, {1592, 7765})
        end
        if switch_talk_to(itemref, -356) then
            if not get_flag(805) then
                set_flag(805, true)
                say("@Why, a page has fallen out of the book!@")
            end
        end
    end

    set_flag(itemref, 14, true)
    external_0055H(itemref) -- Unmapped intrinsic
    if local0 > 148 then
        say("This is @not a @valid book")
    elseif local0 == 100 then
        say("~~ ~~THE DRAGON COMPENDIUM~~ ~~by Perrin*")
        say("     Found almost exclusively in the dungeon Destard, dragons are an ancient race of large reptiles. They possess great intelligence, and a few also use magic, sometimes summoning other creatures to fight with -- or for -- them in battle.")
        say("     However, in combat, they are quite formidable without any aid, for in addition to their sharp claws and the rows of razor-like teeth that fill their maws, they are capable of producing large clouds of fiery death. That, combined with their ability to become invisible makes them more than a match for any foolish enough to cross one.")
        say("     Shouldst one ever be found that is willing to bargain with thee, I strongly suggest doing so, for very few can survive a battle with one of these terrible lizards, and even fewer can emerge victorious.")
    elseif local0 == 101 then
        say("~~ ~~THE JOURNAL OF GARRET MOORE*")
        say("Day 1: I arrived upon this forsaken isle.")
        say("Day 3: Found the ruins of an edifice. A tower?")
        say("Day 4: Need shelter. Beginning to rebuild the tower.")
        say("Day 7: Tower.")
        say("Day 12: Tower.")
        say("Day 21: Basic support foundation almost completed. Moving from temporary shelter tomorrow.")
        say("Day 29: Expanding tower. Began research and experiments to produce livestock breeds for food.")
        say("Day 45: Tower complete. Near miss with experiments. Life soon, I am sure of it!")
        say("Day 73: I have done it! A combination of cells that reproduce without my assistance! Self-sustaining life is not far away!")
        say("Day 97: I am near the answer, there is no doubt. But there are others who would see me fail! They change the sky to purple and hurl bolts of lightning towards me.")
        say("Day 111: The others still seek to thwart me! I hear their voices commanding me to cease. I will never rest until I am done!")
        say("Day 101: Again they come. They have sent a succubus to tempt me. \"Kiss me, kiss me,\" is all she would say. \"Nay\" was my reply. I will be strong!")
        say("Day 40232: Hah! The voices now beg, but I will not finish until he is gone. The night is my haven and the dogs will bark!")
    elseif local0 == 102 then
        say("~~ ~~THE TRANSITIVE VAMPIRE, by Karen Elizabeth Gordon*")
        say("     This richly-detailed tome is a \"handbook of grammar for the Innocent, the Eager, and the Doomed.\"")
    elseif local0 == 103 then
        say("~~ ~~THE TOME OF THE DEAD~~ ~~by Suvol Shadowface*")
        say("     The crinkled pages of this book appear to be made of an odd sort of leather. It contains various essays concerning the treatment of the deceased, especially the bodily remains.")
        say("     One chapter is entitled 101 uses for the human heart. Another passage describes the method by which human skin is tanned and pressed for use as writing material...")
    elseif local0 == 104 then
        say("~~ ~~ARTIFACTS OF DARKNESS~~ ~~by Mordra Morgaelin*")
        say("     Within the pages of this handwritten book are many references to devices of destructive power. Amongst them are Mondain's Skull and Gem of Immortality, Minax's Crystal Ring, and the Dark Core of Exodus' memories.")
        say("     More recent entries describe the Crown of the Liche King, the Well of Souls, and a mysterious Blackrock Sword which apparently has the power to slay even one so powerful as Lord British.")
        say("     A short essay, involving a metal plate hung above a door, explains what seems to be a far simpler method of dispatching the noble monarch.")
    elseif local0 == 105 then
        say("~~ ~~THE LIGHT UNTIL DAWN~~ ~~by Drennal*")
        say("     Herein is the short book that discusses both moons of Britannia, Trammel and Felucca, in detail, explaining their orbits, approximate sizes, and expected compositions. In addition, there is a short essay about the possibility of people who live on these moons, and how to contact them. The work also includes a short story about a sorceress who discovers a way to change the color of Felucca. After testing her observations, she quickly learns that the changes have little affect on anything or anyone.")
    elseif local0 == 106 then
        say("~~ ~~CODAVAR~~ ~~by Nexa*")
        say("     Within the pages of this novel is the parable of an usurping lord seemingly inspired by Blackthorn's tyrranical rule during Lord British's disappearance more than two hundred years ago.")
    elseif local0 == 107 then
        say("~~ ~~RITUAL MAGIC~~ ~~by Nicodemus*")
        say("     The ability to combine one's power with that of another mage's is fundamental to the casting of enchantments. While standing in an outer triangle of a pentagram, up to five wizards may enhance the effects of their spells. The bloodletting from either a goat, sheep, or cat -- one per mage -- is necessary, in addition to the consumption of the secretion of a type three acid slug.")
        say("     Once all the materials are gathered, each mage must stand within one of the five corners of a pentagram drawn from the dust of a dragon's thigh bone...")
    elseif local0 == 108 then
        say("~~ ~~PATHWAYS OF PLANAR TRAVEL~~ ~~by Nicodemus*")
        say("     Herein are the many complex formulae necessary for travel between and through the many diverse planes of existence. Each plane is accessed by a moongate, and even our very own Lord British came to Britannia from one of these planes via a moongate.")
        say("     However, this also leads to some concern. To this point, every individual who has entered Britannia from another plane has been benevolent (most notably Lord British and the Avatar). But if they have the ability to employ these gates, is there not the chance that other, evil beings might, too, be able to venture into our fair lands at their whimsy? A thought to be considered for the future.")
    elseif local0 == 109 then
        say("~~ ~~ENCHANTING ITEMS FOR HOUSEHOLD USE~~ ~~by Nicodemus*")
        say("     Found upon the pages of this tome are many a recipe for the creation of \"mundane\" magic utensils and apparatuses, including such items as the SELF-PROPELLED BROOM, the GHOST WRITING QUILL, and the ALARM GEM.")
        say("Toward the unfinished end of the book, the entries become erratic and almost unreadable, as if written down in a hurry. Many of the latter items seem a little demented: the GIANT OBSIDIAN FLYSWATTER, the EXPLODING CORNCOB HOLDER, and the COMB OF MANY BLADES. It would seem that this mage was not conjuring with all of his reagents.")
    elseif local0 == 110 then
        say("~~ ~~MISCELLANEOUS CANTRIPS~~ ~~Anonymous*")
        say("     As the title says, this book describes the minor spells that fall into the bailiwick of charlatans and prestidigitators.")
    elseif local0 == 111 then
        say("~~ ~~MODERN NECROMANCY~~ ~~by Horance*")
        say("     The author of this poetic treatise attempts to show how necromancy has been maligned throughout the years and explains the beneficial knowledge that can be garnered by studying the effects of magic on a lifeless corpse, including the more recent art of returning life to a dead companion, known as resurrection.")
    elseif local0 == 112 then
        say("~~ ~~THE SYMBOLOGY OF RUNES~~ ~~by Smidgeon the Green*")
        say("     Found within is the complete dictionary of terms for understanding and translating runes. In addition, the work discusses in depth the relation between runes and magic. Based on the intense text within, it would seem that the author is either a profound dolt or a simple genius.")
    elseif local0 == 113 then
        say("~~ ~~THE BUNK AND STOOL")
        say("~~ ~~Register*")
        say("~ ~Dosklin of Vesper~~Lord Shamino~~Erstran of Moonglow~~Aaron of Britain~~Karman of Buccaneer's Den~~The Avatar...")
    elseif local0 == 114 then
        say("~~ ~~THE MODEST DAMSEL")
        say("~~ ~~Register*")
        say("~ ~Sir Dupre~~Lord Iolo~~Rasmereng of Britain~~Hetteth of Paws~~Dukat of New Magincia~~Newon of Britain...")
    elseif local0 == 115 then
        say("~~ ~~THE CHECQUERED CORK")
        say("~~ ~~Register*")
        say("~ ~Sars of Yew~~Lord Shamino~~Sir Dupre~~Keth of Moonglow~~Darek~~ Vinder of Jhelom...")
    elseif local0 == 116 then
        say("~~ ~~THE HONORABLE HOUND")
        say("~~ ~~Register*")
        say("~ ~Walter of Britain~~Jaffe of Yew~~Jaana~~Atans of Serpent's Hold...")
    elseif local0 == 117 then
        say("~~ ~~THE OUT'N'INN")
        say("~~ ~~Register*")
        say("~ ~Tyors of Britain~~Kellin of Buccaneer's Den~~Sir Dupre~~Wentok of Trinsic~~Uberak of Minok...")
    elseif local0 == 118 then
        say("~~ ~~THE WAYFARERER'S INN")
        say("~~ ~~Register*")
        say("~ ~John-Paul of Serpent's Hold~~Horffe of Serpent's Hold~~Featherbank of Moonglow~~Tervis of Buccaneer's Den~~Lord Shamino...")
    elseif local0 == 119 then
        say("~~ ~~THE FALLEN VIRGIN")
        say("~~ ~~Register*")
        say("~ ~Carson of Minoc~~Lord Iolo~~Lady Gwenno~~Yethrod of Britain~~Addom of Yew...")
    elseif local0 == 120 then
        say("BRITANNIAN MINING COMPANY ~~ ~~log.")
        say("... Iron Ore -- 30 tons~~Lead -- 24 tons~~Iron Ore -- 27 tons~~ B.R. -- 2 tons~~Lead -- 14 tons~~Lead -- 37 tons~~Iron Ore -- 26 tons ~~B.R. -- 3 tons~~Iron Ore -- 31 tons...")
    elseif local0 == 121 then
        say("~~ ~~THE SALTY DOG")
        say("~~ ~~Register*")
        say("~ ~Addom of Yew~~The Avatar~~Jalal of Britain~~Tim of Yew~~Blorn of Vesper~~Sir Dupre~~Penelope of Cove...")
    elseif local0 == 122 then
        say("~~ ~~A GUIDE TO CHILDCARE FOR THE RICH AND FAMOUS~~ ~~by Lady M ~~ ~~with love for Samantha Meng Ling*")
        say("     Within is the extensive guide for nannies, describing contemporary techniques and the latest in trouble shooting with children of all ages.")
        say("     A special chapter details the art of diaper changing, and adds a touch of humor by describing (for the more soldierly sorts who may be reading) the effects of hurling soiled diapers at one's enemies.")
    elseif local0 == 123 then
        say("~~ ~~ ~~ALAGNER'S BOOK OF MARVELOUS AND ASTONISHING THINGS")
        say("~~A compiled volume of items of interest both magical and mundane~~by Alagner*")
        say("     In this volume, compiled for easy reference, are some of the many fascinating constructions I have found during my researches. These items range from interesting uses for mundane items to fascinating miscarriages of magic. Please read and enjoy the varied realm of My Brittannia.")
        say("Potions: An historical point of interest from the last several hundred years.")
        say("     Circa 0207 there was a rather infamous case of a resourceful peeping-tom. One may ask what this has to do with potions, but the publicity generated from this trail about the use and misuse of magical potions of X-ray vision encouraged all honorable mages and alchemists to cease making the amazing potions. And, as these potions fell into disuse, the affectation of calling them white potions also slowly ceased, and a lesser known concoction (which, ironically, is appreciably more white than the original X-ray potion I was able to view (see Alagners Index of Treasures, entry 15, for more information), that of common illumination, became its replacement.")
        say("Flying Carpets: A recurring magic.")
        say("     As many of you undoubtedly know the Flying Carpet was essential to the Avatar in his legendary quest to save Lord British from the Three Shadowlords. However,few people realize that this fascinating piece of lore has been rediscovered and, according to my sources, hidden just inside the dungeon Destard, (or is it Despise, I always get those mixed up (NOTE: look this up before publication)). This amazing carpet could fly over water and swamps with no adverse effects, a marvelous tool for the common adventurer and essential for the Avatar. (An interesting side note: according to an ancient tome, the carpet was actual believed a failure by its creator for its inability to rise more than a few inches off the ground)")
        say("Wands: A trio of terrible weaponry.")
        say("     The three identified varieties of magical wand all seem to have been made for the express purpose of changing the combat-weak spellcaster into a killing machine. And, for those with the ability to keep them from wearing out (no small feat of magic, mind you, but simple for anyone capable of crafting the wand in the first place), they are perhaps the most formidable weapons of their size.")
        say("Fire Wand: This wand fires a bolt of flaming death. According to all known texts on the subject, the carnage was called \"amazing.\"")
        say("Lightning Wand: The effects of a bolt of lightning as it bursts forth from the wand is as devastating, as its counterpart, the fire wand. However, according to one of its proponents, \"the corpses look and smell much less offensive.\"")
        say("Magicians Wand: While only slightly more lethal than the typical bow, this wand is rendered quite effective due to two interesting facets: Its damage is of a most magical nature and more than quite powerful against monsters likely to hassle a mage, and, it NEVER runs out of charges. If thou art interested in power and duration, this is the wand for thee.")
        say("Silver Serpent venom: mage's dream, youth's bane.~Once upon a time, the ability to gather this reagent was heralded as the beginning of a new era of magicry. It was the epitome of High Wizardry, but alas, as frequently happens, the promise paid but little. While direct doses of this reagent give a boost to strength, the permanent damage done to the body far outweighs any temporary advantage. Unfortunately, these adverse effects tend to carry over to the spells cast using this reagent.~ Before his illness, Garok Al-Mat, a mage of the high mountains, was experimenting with the vemom in conjunction with spider silk and giant bee pollen. His hope was to bind the qualities into an effective casting reagent for divination. But his work is now lost forever.")
        say("Hoe of Destruction: accidental glory. One of the most recent magic items created, this once ordinary hoe dates back to only a few years ago when one of the first mages (a bush mage of no real merit) to succumb to the illness that now plagues all mages, was asked to both repair a broken hoe for a local farmer and enchant a sword for a warrior. Unfortunately, his perhaps-never-to-be-repeated- enchantment has made this hoe one of the better melee weapons around today. This hoe can be distinguished by it distinctive red, glowing head. Be wary if thou dost ever face it.")
        say("(Items below this point need more research before publication.)")
        say("FireDoom Staff: lethality personified.")
        say("This staff, which hurls exploding fireballs that actually seek out a target, is perhaps the most lethal of all magic weapons created in the era of human-gargoyle cooperation. But, as with most of the more powerful magic weapons, its limited life span means it may fail thee at the worst of times.")
        say("Great Dagger: A great idea but shy of a wonder.")
        say("This dagger is perhaps one of the most ingeniously economical items ever produced. It appears to be naught more than an ordinary dagger, save for large, red stone for a pommel. However, when one strikes with it, it is magically transormed into a two-handed sword. It hides well, and is light on the belt, but no more dangerous that an ordinary two-handed sword (which, of course, is in no way feeble).")
        say("Glass Swords : A historical legacy of death.")
        say("These single-use swords will almost always kill any creature in a single blow, but they are seldom useful for a second opponent.")
        say("Other Miscellaneous Magical Weaponry.")
        say("As a general case, any person with a modicum of magical talent can identify magical weapons, armour and other apparatuses by their pulsating glow. Often, however, the color indicates even more about the item than just the existence of the enchantment. For example, a green field often denotes a poisoning weapon.")
        say("Starbursts: clouds of flying death.")
        say("Originally designed as a small transportable weapon, this magically laminated throwing star bursts into a cloud of similar stars upon contact with its target. Although not terribly devasting, it is the tiny size that makes it such an effective defence. Its small size also makes it a valuable backup missile weapon, for many can be carried together.")
        say("Burst Arrows: an area effect arrow.")
        say("The arrow functions as a regular arrow, but upon impact, explodes into a thousand flying shards of death.")
        say("Magic Boomerangs: there and back again.")
        say("These magical boomerangs are to the gargoyle race as the magical sword it to human warriors. Their most common weapon, boomerangs have the amazing ability to pass through walls and other solid objects and still return to the thrower. Excellent for hunting in the mountains")
        say("Venom Dagger : the assassins tool.")
        say("This shimmering green dagger is actually the enchanted tooth of a poisonous sea serpent, joined to the hilt of a regular dagger. Its envenomed blade injects the slow poison into its victim, but it frequently breaks. It is the perfect assassination weapon (see Alagners History, Assassination of Baron Johann IV (page 54)).")
        say("Stone Harpy: The Stone harpy is the creation of the twisted mind of the magus and paranoid lord of Spectran. It is reputed to be magically triggered by the approaching close approach of any creature.")
    elseif local0 == 124 then
        say("BATHS - PROFITS~~...April, 0360 - 9000~May, 0360 - 8700~June, 0360 - 8300~July, 0360 - 8000~August, 0630 - 6300~September, 0630 - 7600~ October, 0360 - 10,000...~...January, 0361 - 9600")
    elseif local0 == 125 then
        say("~~ ~~THE HISTORY OF STONEGATE~~ ~~by Shazle*")
        say("     The story of Stonegate Castle is, indeed, an interesting one. At one time the keep was occupied by the Shadowlords, during Lord British's disappearance and Blackthorn's evil rule. However, once the Avatar returned our noble monarch to his throne, eliminating the Shadowlords from Britannia, a family of cyclops made the castle their home.")
        say("     Not more than three decades from then the walls were abandoned. This lasted but for a short time, however, for a small colony of wingless gargoyles found refuge within the confines of the keep. Three years later they were driven out by Lord Vemelon of Jhelom , who chose to retain the castle for his own purposes")
        say("     For several generations ownership was passed down the Vemelon line until one day the very mountains nearby opened up, and the swamps engulfed the castle.")
        say("     Now, rumors purport that a colony of trolls have taken up residence amongst the ruins, along with an ancient wizard, but no one has ever confirmed their existence.")
    elseif local0 == 126 then
        say("~~ ~~THE WAY OF THE SWALLOW~~ ~~by Foiles*")
        say("     Within the pages of this tome lies the story of a mother who loved, and was deeply loved by, her family. Though the work ends sadly with the death of the mother, her family gains comfort in the knowledge that her inner spirit has found a better place to rest.")
    elseif local0 == 127 then
        say("~~ ~~VETRONS GUIDE TO WEAPONS AND ARMOUR~~ ~~Their effectiveness and value*")
        say("Here is listed, for easy comparison, the various weapons and their effect upon opponents:~~Axe, two-handed: 10~~Blowgun: 1, can be used with poison or sleep~~ Bow: 8~~Cannon: 90~~Club 2~~Crossbow: 10~~Dagger: 1~~Halberd: 10~~ Hammer: 4~~Hammer, two-handed: 9~~Knife: 2~~Mace: 5~~Main gauche: 2~~ Morningstar: 5~~Powder keg: 16~~Sling: 3~~Sword: 6~~Sword, two-handed: 11~~ Throwing axe: 4~~Torch: 3~~Triple crossbow: 28~~Whip: 4*")
        say("Armour and shields and their protection effectiveness are described here to permit the informed soldier the opportunity to select the armour best suited to his or her fighting style:~~Buckler: 1~~ Chain armour: 2~~Chain coif: 2~~Chain leggings: 2~~Crested helm: 3~~ Curved heater: 3~~Gauntlets: 2~~Gorget: 3~~Great helm: 4~~Greaves: 2~~ Kidney belt: 1~~Leather armour: 1~~Leather boots: 1~~Leather collar: 1~~ Leather gloves: 1~~Leather helm: 1~~Leather leggings: 1~~Plate armour: 4~~ Plate leggings: 3~~Scale armour: 2~~Spiked shield: 2~~Wooden shield: 2*")
        say("Here is a list of the better-known enchanted weapons:~~Magic arrow: +4~~Magic axe: 8, can be thrown~~ Magic bow: 12~~Magic sword: 7, very accurate~~Glass sword: 127, breaks*")
        say("Enchanted armour:~~Magic armour: 5,~~Magic gauntlets: 3,~~Magic gorget: 4,~~Magic helm: 5,~~Magic leggings: 4,~~Magic shield: 4*")
        say("Rarities and oddities of Britannia.~~Fellowship staff: 6~~Fire sword: 8~~Musket: 9~~ B.R. sword: unknown")
        say("     All of the items listed in the final category are either unique items, or legendary items. Their usefulness in combat has not yet been explored fully.")
    elseif local0 == 128 then
        say("~~ ~~VARGAZ'S STORIES OF LEGEND~~Reasons why one should never build doors facing north or west.*")
        say("     Many centuries ago, the prophet, Father Antos, foretold the coming of a plaque of Locust that would arrive from the lands to the north.  He predicted that their source area was so important that it would indicate who would survive the attack, and who would not. He predicted that anyone living in a house having a door with a northern exposure would perish under the onslaught. Two days later, the locusts came, and in the aftermath, it was discoverd that only the houses with doors on the north wall were destroyed.")
        say("     ...The naturalist, Ergan, incorporating Algarth's discovery that the sun rises from the east, theorized that the nightly path of many dark-dwelling nasties could be traced. As the sun moves slowly to the west, Ergan contends, shadows increase in the east, forcing monsters to move that direction to stay out of the sun. Therefore, as denizens of the dark travel from the west, they are more likely to invade households with doors that directly cross their paths... ")
    elseif local0 == 129 then
        say("~~ ~~ONE HUNDRED AND ONE WAYS TO CHEAT AT NIM~~ ~~by Dr. Cat*")
        say("     Within the pages of this tome are all the many ways to earn supplementary gold by gambling at Nim. Written by the originator of the game, himself, this book covers in depth such strategies as, \"claw first, question later\" and \"there are no ways to skin a cat.\"")
    elseif local0 == 130 then
        say("~~ ~~PLAY DIRECTING: ANALYSIS, COMMUNICATION AND STYLE~~ ~~by Francis Hodge*")
        say("     Within the pages of this highly respected textbook one can find the highly touted, and sometimes controversial, methods of staging a play. Written by an eminent Professor Emeritus from a university in a distant land, this book is considered by most thespians as the definitive source book on directing.")
    elseif local0 == 131 then
        say("~~ ~~ON ACTING~~ ~~by Laurence Olivier*")
        say("     Within the pages of this tome are the theories and philosophies of acting, as well as personal anecdotes, written by a noted thespian of a distant land. Apparently this book was one of the many brought to Britannia by Lord British.")
    elseif local0 == 132 then
        say("~~ ~~THOU ART WHAT THEE EATS~~ ~~by Fordras*")
        say("     Within these pages thou wilt find the comparitive analysis of many of things we, humans, place in our bodies in the name of food. I will attempt to provide for thee information on what constitutes \"good\" food and what constitutes \"bad,\" and will display the information by mentioning each type from best to worst, first in terms of nutritional value and second by taste.")
        say("     A large chop of fine meat, including mutton, fowl, ham, or ribs, is by far the most nourishing.  This does not include other forms of beef, however, for they are usually served in smaller portions. Pork and sausage are also lower on the proverbial \"scale,\" for they are not quite as filling. In place of meat, I would recommend flounder, cheese, or potatoes, for they are also quite good for thee.~     In some instances, trout, fish and chips, and some breads will pass for a meal. An egg and most any other fruit and vegetable, including: an apple, a banana, a carrot, a pumpkin, a bunch of grapes, and various cakes, will suffice in a pinch. However, despite its delectible taste and extravagant price, Silverleaf meals have absolutely no value on this chart at all. The moral is, my friend, never pass up meats when thou hast the chance to dine upon them!")
        say("     Obviously, not everything that tastes good is nourishing. At the top of this list, I must put down Silverleaf. The taste is absolutely exquisite! Short of that, I recommend roast mutton with a lovely Minoxian glaze sauce. Add a potato as a side course, with the whole meal preceeded by a few raw vegetables, and thou truly hast a wonderful feast!~     For a second course, I would suggest...")
    elseif local0 == 133 then
        say("~~ ~~MAN VERSUS FISH: THE ULTIMATE CONFLICT~~ ~~by Aquastyr*")
        say("     Thou might consider fishing to be an activity designed simply to feed thy familty. Daily thou takest thy fishing pole and trod to the lake in hopes of catching thy dinner. However, say I, fishing is much more!")
        say("     A fisherman is much like a knight, off to conquer the terrible dragon. Certainly, the terrain is familiar, just as the knight's homeland is to him, but the contest is where the real comparison lies. While a knight carries with him a great and powerful sword, and fisherman must arm himself with a sturdy pole.")
        say("     Of course, another important weapon for the fisherman is his mind. He will need a keen sense of observation to aid him in his struggle against the slippery opponents. The first thing he must do is search for a body of water where the fish are so common that they are forced to jump above the water simply to have room for the others. A lake or pond filled with fish will provide the wise fisherman a better opportunity for an encounter.")
        say("     And how does a fisherman catch his prey. Not by sitting idly by and waiting for them to jump into his pail! For once the creature grabs hold of the bait, the fisherman must fight and thrash his way, as if attacking the very beast, itself. Minutes seem to turn to hours as the warrior battles with his fish, until finally, all energy spent from both sides, the fish is dragged unwillingly into the waiting bucket.")
        say("     And then, the process must begin anew...")
    elseif local0 == 134 then
        say("~~ ~~KNIGHT'S BRIDGE IN A NUTSHELL~~ ~~by Nicodemus*")
        say("     This is a board game for two players.  Each player begins with three pieces. The object is to move thy three pieces in concert in order to force the treasure from the center of the board to thine own side. All the while, thine opponent shall be attempting to do the same.")
        say("Each turn consists of a player either \"moving\" or \"pushing\" a piece followed by a similar action by the opposing player.")
        say("A legal \"move\" consists of placing one's piece in any adjacent, unoccupied black or white square. A legal \"push\" is performed when a player forces a piece, either an opponent's or the treasure, one space directly away from his piece.")
        say("The exception to the latter rule, making a \"push\" illegal, occurs when a player wishes to \"push\" a piece into the space from which it just left in the preceding turn.")
        say("If any piece, excluding the treasure, is \"pushed\" onto a blue square or off the board, that piece is considered lost, and is removed from play. The treasure may not be \"pushed\" off the board.")
        say("To win the game, a player must \"push\" the treasure to the back row of squares on his side of the board.")
    elseif local0 == 135 then
        say("~~ ~~MEMPTO RAYS~~A qualitative study in metaparaphilosophical radiation~~ ~~by Mempto*")
        say("     Despite Felcrodan's theory of 0335, there are, indeed, rays of energy that constantly bombard Britannia. In fact, these very same rays permeate of all the known space between Britannia and the stars. Recent experiments have proven my theory that these rays, known hereafter as `Mempto Rays,' are lethal to all non-living matter. In fact, Mempto rays have demonstrated their ability numerous times, once killing an entire boulder in a matter of a few hours. It is my recommendation...")
    elseif local0 == 136 then
        say("~~ ~~THE BOOK OF CIRCLES~~ ~~Translated from Gargish to Britannian by Jillian*")
        say("     All begins with the three principles: Control, Passion and Diligence.")
        say("     From Control springs Direction. From Passion springs Feeling. From Diligence springs Persistence.")
        say("     But these three virtues are no more important than the other five: Control combines with Passion to give Balance. Passion combines with Diligence to yield Achievement. And Diligence joins with Control to provide Precision.")
        say("     The absence of Control, Passion and Diligence is Chaos.")
        say("     The three principles, when mastered, lead to the Eighth Virtue, which is Singularity.")
        say("     A circle has no end. It continues forever, turning upon itself in a continuous, endless cycle.")
        say("     Our society is a circle, continuing forever, turning upon itself in an endless cycle. We are the circle, and the circle is us.")
    elseif local0 == 137 then
        say("~~ ~~CHICKEN RAISING FOR FUN AND PROFIT~~ ~~by Lady Leigh*")
        say("     While handling poultry might appear to be a simple task, I assure thee that such is not the case. As with any other creature, thou must be aware of several important factors when raising chickens, or any other type of fowl.")
        say("     In addition, thou must be aware of the best methods of feeding thy flock, and what to do when they cease laying eggs. In fact, one of the more delicate operations is the proper removal of the chicken's neck feathers, shouldst thou decide to use the creature for a meal.")
    elseif local0 == 138 then
        say("~~ ~~THE ART OF FIELD DRESSING~~ ~~by Lady Leigh*")
        say("     Though I personally find the entire concept utterly distasteful, I have oft been asked how one should go about preparing a recently-slain creature for the table. Therefore, I have consented to describe the process, though I must warn thee that the details are not for the weak of stomach.")
        say("-- Lady Leigh of Serpent's Hold")
        say("     As long as one is careful to keep the knife away from the intestines, one should have little difficulty in preparing the meat for cooking. Be especially careful around the heart, for there is a small gland located nearby that, if pierced, will ruin the meat.")
    elseif local0 == 139 then
        say("~~ ~~WATER ON THE ROCKS~~ ~~by Felcrodan*")
        say("     (This text is heavily water damaged and mostly unreadable. Only a few sections remain that are still legible.)")
        say("     The using of sextants is no longer necessary for finding one's way around Britannia, for the recent advances in cartography have provided us with maps of the entire continent. However, there are still some mariners who prefer the old ways, plotting their courses by the stars and using their trusty sextants to pinpoint their locations.")
    elseif local0 == 140 then
        say("~~ ~~A SHORT TREATISE ON THE HIERARCHY OF THE FELLOWSHIP~~ ~~by Batlin*")
        say("     The hierarchy of The Fellowship is quite simple. At the top is the voice of the Guardian. Below him is myself, the head of The Fellowship, and my two assistants, Elizabeth and Abraham.")
        say("     All citizens of Britannia are welcome to join the ranks of The Fellowship as brothers and sisters. One must merely express a desire to join, and then prove one's worth by accomplishing the directives that are given by me or my assistants.")
        say("     Members of The Fellowship are expected to live by the philosophy of the Triad of Inner Strength, and to spread the message of The Fellowship to others.")
        say("     Just below the brothers and sisters are the candidates for membership, those who have expressed a desire to join, but have yet to prove their worth.")
        say("     Much of the financing for the various activities of The Fellowship comes from the generous donations of its members. Those who are able are expected to tithe a portion of their income to the cause.")
    elseif local0 == 141 then
        say("~~ ~~A BAKER'S HANDBOOK~~ ~~by F. Frederickson*")
        say("     The fundamental ingredient in any baker's arsenal is flour. Without it, thou hast no chance of creating even the simplest of breads. Fortunately, flour is quite easy to come by, for any miller will sell it to thee by the sack.")
        say("     It is important to realize that not all flours are created equal. The best flour comes from the mills of Minoc, for they use a special process that removes the chaff and other impurities from the grain before it is ground.")
        say("     To the four, thou must add water, and perhaps a pinch of salt for taste. Some bakers also add a bit of yeast, but this is not necessary if thou art in a hurry. Mix the ingredients together in a bowl, and then knead the dough until it is smooth and elastic. Once this is done, place it near the hearth and bake it. After but a few minutes, thou wilt have quite tasty bread to eat.")
        say("     Now, the next item will prove a true treat for thy loved ones...")
    elseif local0 == 142 then
        say("~~ Logbook~~ Astelleron*")
        say("... I have grown lonely here on the island. Despite my golems, I have no one with whom I can converse, no one with any personality. Even the animals spend less time here than on the main island.~Each day I look upon the horizon for a sign of someone. I have no fear of strangers, for either I will meet the Avatar, or the golems I created to protect the Shrines will fend off hostile visitors...")
        say("... I am exhilirated! Today, while on the main island, I happened by a tree. While this is not inherently odd, I noticed that the tree seemed to grow not out of the ground, but from a large rock. Equally unusual was the five stones surrounding it, each located the same distance from each other and from the center stone. They looked much like they could represent vertices of a five-pointed star.~And then I realized to what I was a witness: the legendary Stone of Castambre. Even had I not noticed the Tree of Life springing forth from the boulder, the Pentacle of rocks gave all away...")
        say("... The first test was a success. I used a pick to chip away a bit of the stone. I was startled at first by the bleeding, but as I heard not a whit of any sound indicating pain, I continued. I am about to confer with the book to determine my next action...")
        say("... I am afraid I will have little time to continue this journal for the moment. I realize that a true scientist would record daily with the utmost accuracy what he has done and witnessed, but the amount of work each day requires leaves me long past the point of exhaustion...")
        say("... I have done it! My newest two golems can actually speak! And they offer original comments, not mere echoes of my own thought. The instructions in the book are correct. Bollux, my first attempt, succeeded, but my inexperience left him a little less intelligent than I would have preferred. However, his \"brother,\" Adjhar, benefited from my mistake with the other, and has full speech capabilities. As I sit now, writing this, I can hear them discussing weather! I must go now and talk with them. Oddly enough, the sky no longer seems overcast...")
    elseif local0 == 143 then
        say("~~ ~~GOLEMS: FROM CLAY TO STONE~~ ~~by Castadon*")
        say("... Stone golems can be created from any hard rock. However, it is important to note that the enchantments require they be anthropomorphic in shape. Any other construct, or an incomplete one, will not be able to hold the creature together or permit locomotion.")
        say("     Once the sufficient amount of stone has been gathered and placed roughly in the shape of a man, thou must cast the Vas Rel Ailem spell (see appendix QQ for spell description) to form the rock into a person. Needless to record, perhaps, the creature will barely resemble anything human, but will be able to function similarly.")
        say("     The next enchantment is Kal Mani (appendix QQ). This will \"breathe life\" into the newly created golems, or rather, breathe animation into them. Once created, each golem will have enough rudimentary intelligence to obey and respond to three single-word commands, or one extensive request of any length.*")
        say("*")
        say("     Appendix K~     The Stone of Castambre")
        say("~~     This mythological rock has legendary powers that permits one to shape and enchant stone -- and only stone -- to create golems by following only a single, short ritual instead of the lengthy and time-consuming process described in previous chapters. Though the Stone's existence has never been confirmed, there are also other purported powers that could make a risky investigation quite worth while. For additional information, see \"The Stone of Castambre,\" by MacCuth.")
    elseif local0 == 144 then
        say("~~ ~~THE STONE OF CASTAMBRE~~ ~~by MacCuth*")
        say("     Legendary rock? Perhaps. Powerful relic? Definitely.~The Stone Of Castambre -- named for the mage who is rumored to have enchanted and placed it -- is said to be located on the Isle of Fire, also the location of the Shrines of the Three Principles. Of course, since knowledge of the Isle has long since disappeared, knowledge of the infamous Stone is equally mysterious. However, through research and study of Castambre's diary I have brought to light a few clues to the Stone's whereabouts.")
        say("     The major purpose of the Stone's power is to animate inanimate objects: statues, golems, tools, etc. In addition, shouldst the desired object be one already imbued with the power of conversation, the Stone will enhance such powers, giving the object, or rather, creature, independent thought. Historians claim that it is with this stone that Castambre concocted creatures of such deep personalities that, from behind a curtain, it was impossible to differentiated between a person and one of his creations.")
        say("     But how do I capture this ability, I hear thee ask.  First, assuming thou hast already discovered the Isle of Fire (no mean feat, I assure thee), thou must then search for the \"pentacle of rocks\" -- five boulders arranged as though they were vertices in a pentagram. In the center thou shouldst notice a sixth rock, from which grows a large, healthy tree -- the Tree of Life. This sixth rock is Castambre's Stone.")
        say("     However, finding the Stone is only half the battle, for now thou must perform magicks beyonds the abilities of normal men. With a ... thou must.........")
        external_007EH() -- Unmapped intrinsic
        local1 = add_item(itemref, {1592, 7765})
    elseif local0 == 145 then
        say("... Once the the \"heart\" has been placed within the \"chest\" of the creature, the ritual may begin. First, using perhaps the same pick, thou must strike the Tree hard enough to draw blood. Blood from a Tree, questions thee? Aye, I say, for this Tree is one of life and energy -- collected from the nutrients of the Stone, and bleed it does. Some say thou wilt be able to hear the shrieks of pain from Castambre's Stone, but that rumor is waning. Thou wilt need enough of the Tree's life force to fill a bucket.")
        say("     After the blood has been properly contained, it must be spilled in five spots about the body of the stone creature as if the creature were Castambre's Stone and the puddles of blood the five rocks of the pentacle. In fact, it is necessary to set down five such small rocks to mark the location upon which the blood must be spilled. Then must thou cast Vas Flam Uus (see detachable page at end of volume), setting fire to each of the puddles of blood. Following that must be chanted the sacred words gleaned from Castambre's journals (also on detachable page).")
        say("     Now that the creature is enchanted, of course, it will become necessary to instruct it, much as one educates a child. However, a stone golem will learn much more quickly...")
        local2 = set_item_quality(itemref, 144)
        if not get_flag(805) then
            local3 = get_item_frame(797)
            local4 = set_item_quality(local3, 45)
            local5 = get_item_data(-356)
            local6 = set_item_data(local5)
        end
        local6 = add_item(-356, {1592, 17493, 7715})
    elseif local0 == 146 then
        say("~~ ~~THE DARK CORE OF EXODUS~~ ~~by Erethian*")
        say("    Exodus was a mixture of etherial being and magical mechanism. Its living portion, or psyche, was comprised of its ambitions, desires, curiosity, in total, its personality. The subject matter of this tome, however, lies upon a part of its more physical manifestation.")
        say("    The Core was the receptacle of Exodus' memories and mental force. The psyche was almost like a parasite, feeding off the world around and depositing what it gained within the Core. What was Exodus' purpose? Who or what did it serve? This is matter of which I write.")
        say("    Exodus served none other than...")
        say("~~(The text remains unfinished.)")
    elseif local0 == 147 then
        say("~~ ~~Ethical Hedonism~~ ~~by R. Allen G.*")
        say("    This handbook details a non-religous religion in which people live for the joy of living and make it their responsibility to keep the entire world out of disrepair.")
    elseif local0 == 148 then
        say("~~ ~~CONVERTING MOONGATES TO THINE OWN USE~~ ~~by Erethian*")
        say("    Moongates come in four known varieties: blue, a gate across a land, red, a gate connecting worlds, black, a gate that traverses dimensions, and the theoretical silver, time gate.")
        say("    These gates, to a lesser or greater degree, owe their power to the force exerted by large bodies of matter, moving through the space around us. Therefore, I postulate that if one can know what forces are being exerted, one can manipulate the destination of any given moongate by changing these forces.")
        say("    The book goes on to describe certain methods of manipulation, and save for the prohibitively large amounts of power required to effect even the weakest of moongates, the logic seems sound...")
    end
    return
end