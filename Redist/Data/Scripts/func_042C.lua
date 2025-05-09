--- Best guess: Manages Carrocio’s dialogue, handling his puppet show, strength test, and personal life with Nell, with poetic responses and flag-based secrecy about Nell’s pregnancy.
function func_042C(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid ~= 1 then
        if eventid == 0 then
            var_0001 = unknown_003BH()
            var_0002 = unknown_001CH(unknown_001BH(44))
            var_0008 = random2(4, 1)
            if var_0002 == 7 and (var_0001 == 3 or var_0001 == 4 or var_0001 == 5 or var_0001 == 6) then
                if var_0008 == 1 then
                    var_0009 = "@See the puppets!@"
                elseif var_0008 == 2 then
                    var_0009 = "@Canst thou ring the bell?@"
                elseif var_0008 == 3 then
                    var_0009 = "@Next show starts soon!@"
                elseif var_0008 == 4 then
                    var_0009 = "@Measure thy might!@"
                end
                bark(var_0009, 44)
            else
                unknown_092EH(44)
            end
        end
        add_dialogue("\"Perchance to find in mercy's ear, A voice to know as gentle friend, I bid thee well, but hark return, If thou wouldst see the puppet's play or test thy strength again.\"")
        return
    end

    start_conversation()
    switch_talk_to(0, 44)
    var_0000 = unknown_0909H()
    var_0001 = unknown_003BH()
    var_0002 = unknown_001CH(unknown_001BH(44))
    var_0003 = _IsPlayerFemale()
    var_0004 = unknown_08F7H(-2)
    add_answer({"bye", "job", "name"})
    if not get_flag(122) then
        add_answer("Nell with child")
    end
    if not get_flag(137) then
        add_answer("Charles is angry")
    end
    if not get_flag(173) then
        add_dialogue("You see a flamboyant-looking gentleman. He is very cheerful and outgoing, greeting you with a smile and a wave.")
        set_flag(173, true)
    else
        if not var_0003 then
            add_dialogue("\"In a wink, in a word, I do greet thee, Milord.\"")
        else
            add_dialogue("\"To greet thee, On this day, 'Tis my pleasure, Milady.\"")
        end
    end
    while true do
        if cmps("name") then
            add_dialogue("\"From out the dawn, when sun doth rise, Until next morn when moon must go, I answer to thy beck and cries, thine humble servant, Carrocio!\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"The puppet's curtain I unfurl, And from mine hands the story's told, For pleasure of a boy or girl, To see doth cost one coin of gold.")
            add_dialogue("To take good measure of thy power, Forged in fire of virtue's heart, To ring the bell this very hour, Do test thy strength 'til thy muscles smart.\"")
            if not var_0003 then
                add_dialogue("\"And perhaps impress thine own sweetheart!\" Carrocio winks at you.")
            end
            add_dialogue("\"Or dost thou wish to be a king? Yonder sticks a sword in stone. If thou canst only pull it out Thou wilt be the next upon the throne!\"")
            add_answer({"strength test", "see", "puppet show"})
        elseif cmps("puppet show") then
            add_dialogue("\"My childhood's eye spied father's toil, A puppet's show of splendor royal. Time's breeze has blown, My father's gone, His child has grown, Regrets anon, Gears and wheels move the moppets now, in need of no one, And so I keep his carnival song playing on and on alone.\"")
            remove_answer("puppet show")
            add_answer({"gears and wheels", "regrets"})
        elseif cmps("strength test") then
            if var_0002 ~= 7 then
                add_dialogue("\"I am sorry to say I have called it a day. Come to the grounds to test thy fitness when I am, yea verily, open for business.\"")
            else
                add_dialogue("\"Take the hammer in thine hands and strike a blow upon the ground, If thine arms be possessed of might then thou shalt hear a ringing sound. Once thou hast struck if thou hearest naught then thou dost know thy strength is flagging. But if thou dost win the strength test game thou shalt receive a stuffed dragon.\"")
            end
            remove_answer("strength test")
        elseif cmps("gears and wheels") then
            add_dialogue("\"I fear an end to my family craft, where the show is run by human heart, But bones do age, not so machines, and we cannot simply replace a part. I carry on as best I can, A machine to play my father's role, Control the marionettes unseen, struggling to imbue them with a soul.\"")
            remove_answer("gears and wheels")
        elseif cmps("regrets") then
            add_dialogue("\"The faces pressed before me, fleeting moments chance of glee, From the lowly mongrel beggar to the resident of throne, Each know their place and gave me chase to find the one for me, Woman whom my life may share, this heart that waits alone.\"")
            remove_answer("regrets")
            add_answer({"woman", "resident of throne", "mongrel beggar"})
        elseif cmps("mongrel beggar") then
            add_dialogue("\"A beggar man called Snaz will come to watch my show, to steal and sell all my best jokes, mine own personal foe.\"")
            remove_answer("mongrel beggar")
        elseif cmps("resident of throne") then
            add_dialogue("\"Thine ignorance doth make me skittish, surely thou hast heard of wise Lord British.\"")
            remove_answer("resident of throne")
        elseif cmps("woman") then
            add_dialogue("\"The awakening of mine heart's idyll, Lies 'neath me for I see her still, No bard could e'er describe nor tell, the tenderness of my fair Nell.\"")
            remove_answer("woman")
            add_answer("Nell")
        elseif cmps("Nell") then
            add_dialogue("\"'Tis said love is a fiery angel, Riding soft silk wings of pure redemption, My puppet's heart still as an anvil, At the wicked thrill of her attention. By mine angel Nell I am anointed, Humble cowardice felled by Passion's blade, As her beloved I was hence appointed, Perchance through destiny a marriage made.\"")
            remove_answer("Nell")
            add_answer({"marriage", "wicked thrill"})
        elseif cmps("wicked thrill") then
            add_dialogue("Carrocio looks as if he is lost in a memory. After a moment he returns to reality.")
            add_dialogue("\"I would not be a gentleman if I spoke of this more, Forgive me the candor of mine heart's open door.\"")
            add_dialogue("He appears somewhat embarrassed and clears his throat loudly several times.")
            remove_answer("wicked thrill")
        elseif cmps("marriage") then
            add_dialogue("\"My coins are arrows rushing to make good, 'Til the day when the jeweller sells his ring, For my sure heart is not but carved from wood, And she doth tend to the bed of a king.\"")
            remove_answer("marriage")
            if not get_flag(122) then
                add_answer("Nell with child")
            end
        elseif cmps("Nell with child") then
            add_dialogue("Carrocio gives you a shocked look and drops to his knees before you. \"I beseech thee, " .. var_0000 .. ", Keep still thy tongue, My Nell has ne'er harmed anyone, It would cause grievous injury to her reputation, Through the town's wagging lips our secret to spread, 'Twould make a permanent end of mine occupation, And kill our hope of a happy life dead.\" He looks you in the eyes, pleadingly. \"In thee I must place mine hope and trust, Part, parcel and whole. To ne'er again speak of the spoils of my lust, Thou must not tell a soul!\"")
            if not get_flag(137) then
                add_dialogue("He looks at you awaiting some sort of indication. Will you keep his secret?")
                var_0005 = unknown_090AH()
                if var_0005 then
                    add_dialogue("\"Thou dost walk with honor, I know thou wilt not tell, Of dignity's stains I do not bother, My concerns are none save for Nell.\"")
                else
                    add_dialogue("\"Reconsider, I must insist of thee, Thou art too thin of hide, If he knew, Nell's brother would murder me, And I would not see Nell widowed before having the chance to become a bride.\"")
                end
            end
            remove_answer("Nell with child")
        elseif cmps("Charles is angry") then
            add_dialogue("\"I am grateful for thine honesty about thy lack of care, But why hast thou placed thyself in the center of our affair? For Nell's sake I could not bring myself to cause harm to her brother, I shall convince him of mine intentions, I love Nell and no other. Leave me now for I must use this time to properly prepare.\"")
            return
        elseif cmps("see") then
            if var_0002 ~= 7 then
                add_dialogue("\"I am sorry to say I have called it a day. Come to the grounds at daybreak when the puppets are, yea verily, up and awake.\"")
            else
                add_dialogue("\"See foolish pride and love, brutality and sin, Carrocio's tiny world of moving dolls, Enough to make thee gasp, or cry or grin, All who wish to see 'tis time to hear my calls, For now the puppet show is about to begin!\"")
                var_0006 = unknown_0030H(503)
                unknown_005CH(var_0006[1])
                var_0007 = unknown_0002H(15, 503, 7765, var_0006[1])
            end
            remove_answer("see")
            return
        elseif cmps("bye") then
            break
        end
    end
    return
end