-- Function 042C: Manages Carrocio's dialogue and interactions
function func_042C(itemref)
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid() == 1 then
        switch_talk_to(44, 0)
        local0 = call_0909H()
        local1 = callis_003B()
        local2 = callis_001B(-44)
        local3 = callis_001C(local2)
        local4 = callis_005A()
        local5 = call_08F7H(-2)
        _AddAnswer({"bye", "job", "name"})
        if not get_flag(122) then
            _AddAnswer("Nell with child")
        end
        if not get_flag(137) then
            _AddAnswer("Charles is angry")
        end
        if not get_flag(173) then
            say("You see a flamboyant-looking gentleman. He is very cheerful and outgoing, greeting you with a smile and a wave.")
            set_flag(173, true)
        else
            if not local4 then
                say("\"In a wink, in a word, I do greet thee, Milord.\"")
            else
                say("\"To greet thee, On this day, 'Tis my pleasure, Milady.\"")
            end
        end
        while true do
            if cmp_strings("name", 1) then
                say("\"From out the dawn, when sun doth rise, Until next morn when moon must go, I answer to thy beck and cries, thine humble servant, Carrocio!\"")
                _RemoveAnswer("name")
            elseif cmp_strings("job", 1) then
                say("\"The puppet's curtain I unfurl, And from mine hands the story's told, For pleasure of a boy or girl, To see doth cost one coin of gold. To take good measure of thy power, Forged in fire of virtue's heart, To ring the bell this very hour, Do test thy strength 'til thy muscles smart.\"")
                if not local4 then
                    say("\"And perhaps impress thine own sweetheart!\" Carrocio winks at you.")
                end
                say("\"Or dost thou wish to be a king? Yonder sticks a sword in stone. If thou canst only pull it out Thou wilt be the next upon the throne!\"")
                _AddAnswer({"strength test", "see", "puppet show"})
            elseif cmp_strings("puppet show", 1) then
                say("\"My childhood's eye spied father's toil, A puppet's show of splendor royal. Time's breeze has blown, My father's gone, His child has grown, Regrets anon, Gears and wheels move the moppets now, in need of no one, And so I keep his carnival song playing on and on alone.\"")
                _RemoveAnswer("puppet show")
                _AddAnswer({"gears and wheels", "regrets"})
            elseif cmp_strings("strength test", 1) then
                if local3 ~= 7 then
                    say("\"I am sorry to say I have called it a day. Come to the grounds to test thy fitness when I am, yea verily, open for business.\"")
                else
                    say("\"Take the hammer in thine hands and strike a blow upon the ground, If thine arms be possessed of might then thou shalt hear a ringing sound. Once thou hast struck if thou hearest naught then thou dost know thy strength is flagging. But if thou dost win the strength test game thou shalt receive a stuffed dragon.\"")
                end
                _RemoveAnswer("strength test")
            elseif cmp_strings("gears and wheels", 1) then
                say("\"I fear an end to my family craft, where the show is run by human heart, But bones do age, not so machines, and we cannot simply replace a part. I carry on as best I can, A machine to play my father's role, Control the marionettes unseen, struggling to imbue them with a soul.\"")
                _RemoveAnswer("gears and wheels")
            elseif cmp_strings("regrets", 1) then
                say("\"The faces pressed before me, fleeting moments chance of glee, From the lowly mongrel beggar to the resident of throne, Each know their place and gave me chase to find the one for me, Woman whom my life may share, this heart that waits alone.\"")
                _RemoveAnswer("regrets")
                _AddAnswer({"woman", "resident of throne", "mongrel beggar"})
            elseif cmp_strings("mongrel beggar", 1) then
                say("\"A beggar man called Snaz will come to watch my show, to steal and sell all my best jokes, mine own personal foe.\"")
                _RemoveAnswer("mongrel beggar")
            elseif cmp_strings("resident of throne", 1) then
                say("\"Thine ignorance doth make me skittish, surely thou hast heard of wise Lord British.\"")
                _RemoveAnswer("resident of throne")
            elseif cmp_strings("woman", 1) then
                say("\"The awakening of mine heart's idyll, Lies 'neath me for I see her still, No bard could e'er describe nor tell, the tenderness of my fair Nell.\"")
                _RemoveAnswer("woman")
                _AddAnswer("Nell")
            elseif cmp_strings("Nell", 1) then
                say("\"'Tis said love is a fiery angel, Riding soft silk wings of pure redemption, My puppet's heart still as an anvil, At the wicked thrill of her attention. By mine angel Nell I am anointed, Humble cowardice felled by Passion's blade, As her beloved I was hence appointed, Perchance through destiny a marriage made.\"")
                _RemoveAnswer("Nell")
                _AddAnswer({"marriage", "wicked thrill"})
            elseif cmp_strings("wicked thrill", 1) then
                say("Carrocio looks as if he is lost in a memory. After a moment he returns to reality. \"I would not be a gentleman if I spoke of this more, Forgive me the candor of mine heart's open door.\" He appears somewhat embarrassed and clears his throat loudly several times.")
                _RemoveAnswer("wicked thrill")
            elseif cmp_strings("marriage", 1) then
                say("\"My coins are arrows rushing to make good, 'Til the day when the jeweller sells his ring, For my sure heart is not but carved from wood, And she doth tend to the bed of a king.\"")
                _RemoveAnswer("marriage")
                if not get_flag(122) then
                    _AddAnswer("Nell with child")
                end
            elseif cmp_strings("Nell with child", 1) then
                say("Carrocio gives you a shocked look and drops to his knees before you. \"I beseech thee, " .. local0 .. ", Keep still thy tongue, My Nell has ne'er harmed anyone, It would cause grievous injury to her reputation, Through the town's wagging lips our secret to spread, 'Twould make a permanent end of mine occupation, And kill our hope of a happy life dead.\" He looks you in the eyes, pleadingly. \"In thee I must place mine hope and trust, Part, parcel and whole. To ne'er again speak of the spoils of my lust, Thou must not tell a soul!\"")
                if not get_flag(137) then
                    say("He looks at you awaiting some sort of indication. Will you keep his secret?")
                    local6 = call_090AH()
                    if local6 then
                        say("\"Thou dost walk with honor, I know thou wilt not tell, Of dignity's stains I do not bother, My concerns are none save for Nell.\"")
                    else
                        say("\"Reconsider, I must insist of thee, Thou art too thin of hide, If he knew, Nell's brother would murder me, And I would not see Nell widowed before having the chance to become a bride.\"")
                    end
                end
                _RemoveAnswer("Nell with child")
            elseif cmp_strings("Charles is angry", 1) then
                say("\"I am grateful for thine honesty about thy lack of care, But why hast thou placed thyself in the center of our affair? For Nell's sake I could not bring myself to cause harm to her brother, I shall convince him of mine intentions, I love Nell and no other. Leave me now for I must use this time to properly prepare.\"")
                abort()
            elseif cmp_strings("see", 1) then
                if local3 ~= 7 then
                    say("\"I am sorry to say I have called it a day. Come to the grounds at daybreak when the puppets are, yea verily, up and awake.\"")
                else
                    say("\"See foolish pride and love, brutality and sin, Carrocio's tiny world of moving dolls, Enough to make thee gasp, or cry or grin, All who wish to see 'tis time to hear my calls, For now the puppet show is about to begin!\"*")
                    local7 = callis_0030(503)
                    local8 = aidx(local7, 1)
                    callis_005C(local8)
                    local9 = callis_0002(15, {7765}, local8)
                end
                _RemoveAnswer("see")
                abort()
            elseif cmp_strings("bye", 1) then
                say("\"Perchance to find in mercy's ear, A voice to know as gentle friend, I bid thee well, but hark return, If thou wouldst see the puppet's play or test thy strength again.\"")
                break
            end
        end
    elseif eventid() == 0 then
        local1 = callis_003B()
        local2 = callis_001B(-44)
        local3 = callis_001C(local2)
        local8 = callis_0010(4, 1)
        if local3 == 7 then
            if local1 == 3 or local1 == 4 or local1 == 5 or local1 == 6 then
                if local8 == 1 then
                    local9 = "@See the puppets!@"
                elseif local8 == 2 then
                    local9 = "@Canst thou ring the bell?@"
                elseif local8 == 3 then
                    local9 = "@Next show starts soon!@"
                elseif local8 == 4 then
                    local9 = "@Measure thy might!@"
                end
                _ItemSay(local9, -44)
            end
        else
            call_092EH(-44)
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function say(...)
    print(table.concat({...}))
end

function get_flag(id)
    return false -- Placeholder
end

function set_flag(id, value)
    -- Placeholder
end

function cmp_strings(str, count)
    return false -- Placeholder
end

function abort()
    -- Placeholder
end