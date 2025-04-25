-- Function 042A: Manages Cynthia's dialogue and interactions
function func_042A(itemref)
    -- Local variables (16 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14, local15

    if eventid() == 1 then
        _SwitchTalkTo(0, -42)
        local0 = call_0909H()
        local1 = callis_003B()
        _AddAnswer({"bye", "job", "name"})
        if not get_flag(220) then
            _AddAnswer("exchange")
        end
        if not get_flag(175) then
            _AddAnswer("James")
        end
        if not get_flag(171) then
            say("You see a helpful and efficient-looking woman.")
            say("\"How may I help thee?\" asks Cynthia.")
            set_flag(171, true)
        else
            say("\"How may I help thee?\" asks Cynthia.")
        end
        while true do
            if cmp_strings("name", 1) then
                say("\"My name is Cynthia.\"")
                _RemoveAnswer("name")
            elseif cmp_strings("job", 1) then
                say("\"I am the teller at the Mint. I am also a member of the Britannian Tax Council.\"")
                _AddAnswer({"Britannian Tax Council", "Mint"})
            elseif cmp_strings("Mint", 1) then
                say("\"Here at the Mint we store gold, oversee production of coins and keep an accurate count of how much money the kingdom has available for such things as farming, building the roads, developing sources of fresh water, seeing to the health of the citizenry, maintaining the estates of nobles, raising the guard militia and carrying out the decrees of Lord British.\"")
                _RemoveAnswer("Mint")
                _AddAnswer({"guards", "estates", "health", "water", "roads", "farms", "money"})
            elseif cmp_strings("Britannian Tax Council", 1) then
                say("\"The Britannian Tax Council is in charge of the accounting, assessment and collection of the taxes. If thou wilt be earning any money here in Britannia thou wilt need to take this paper.\"")
                local2 = callis_002C(true, -359, 797, 1)
                if not local2 then
                    say("\"Fill it out and return it here at the end of the year when thou dost come back to pay thy taxes.\"")
                else
                    say("\"Thou art carrying too much. Come back and I will give thee thy paper when thou art not so greatly encumbered.\"")
                end
                _RemoveAnswer("Britannian Tax Council")
            elseif cmp_strings("money", 1) then
                say("\"In order to keep the standard of money constant, we also operate as an exchange for those who possess quantities of gold. We supply the equivalent value of their gold in spendable coin of the realm and then transform the gold we receive into more money. So, as thou canst see, it is a very efficient system.\"")
                set_flag(220, true)
                _RemoveAnswer("money")
                _AddAnswer({"system", "exchange"})
            elseif cmp_strings("farms", 1) then
                say("\"As I am certain thou dost know, the seven year drought, which thankfully ended several years ago, has left much of the farming in the Kingdom in disarray. That is why the cost of food is so expensive. But without the support of the Royal Treasury, the prices would be even higher.\"")
                _RemoveAnswer("farms")
            elseif cmp_strings("roads", 1) then
                say("\"The increased use of wagons has caused many of the roads throughout Britannia to rapidly deteriorate. It costs a lot of money to build new roads and keep them all repaired.\"")
                _RemoveAnswer("roads")
            elseif cmp_strings("water", 1) then
                say("\"It is of the utmost importance to the Kingdom to insure its populous a clean water supply, and that requires a regular supply of new and fresh wells.\"")
                _RemoveAnswer("water")
            elseif cmp_strings("health", 1) then
                say("\"As Britannia's population has greatly increased in the last two hundred years, so has the risk of infectious diseases, such as the mysterious skin deterioration that afflicts those who partake in the venom of the silver serpent. The number of healers that the Kingdom needs has risen dramatically.\"")
                _RemoveAnswer("health")
            elseif cmp_strings("estates", 1) then
                say("\"The local Lords and Mayors all have residences that are maintained through the auspices of the Kingdom.\"")
                _RemoveAnswer("estates")
            elseif cmp_strings("guards", 1) then
                say("\"The military training is conducted at Serpent's Hold, where the guards that protect all of the towns and cities of Britannia are instructed. 'Tis funded by the Royal Treasury.\"")
                _RemoveAnswer("guards")
            elseif cmp_strings("system", 1) then
                say("\"It not only applies to gold but it also applies to all minerals. We oversee the sale and rate of exchange for precious ores extracted by the Britannian Mining Company. But we do not handle the sale of gems. There is a jeweler in town who handles that.\"")
                _RemoveAnswer("system")
            elseif cmp_strings("exchange", 1) then
                local3 = callis_001B(-42)
                local4 = callis_001C(local3)
                if local4 == 30 then
                    say("\"Dost thou have some gold that thou wouldst like to exchange?\"")
                    local5 = call_090AH()
                    if local5 then
                        local6 = call_0931H(-359, 645, 1, -357)
                        local7 = call_0931H(-359, 646, 1, -357)
                        if not local6 and not local7 then
                            local8 = true
                        else
                            local8 = false
                        end
                        if not local8 then
                            say("\"I can see thou hast no nuggets or bars of gold. Whatever gold thou mayest possess is already the coin of the realm. I cannot help thee anymore than that.\"")
                        else
                            say("\"We can exchange thy gold nuggets and bars into spendable coin for thee. I will give thee ten gold coins for each gold nugget and one-hundred gold coins for each gold bar.\"")
                            local9 = callis_0028(-359, 645, -357)
                            local10 = callis_0028(-359, 646, -357)
                            local11 = local9 * 10
                            local12 = local10 * 100
                            local13 = local11 + local12
                            local14 = callis_002C(true, -359, 644, local13)
                            if local14 then
                                say("\"Oh, my. Thou canst not possibly carry that many gold coins. Thou must return when thou dost have more space in thy pack.\"")
                            else
                                local15 = callis_002B(true, -359, 645, local9)
                                local15 = callis_002B(true, -359, 646, local10)
                                say("\"And here are " .. local13 .. " gold coins for thee in return, " .. local0 .. ". I thank thee for thy business.\"")
                            end
                        end
                    else
                        say("\"Very well. Mayhaps another time.\"")
                    end
                else
                    say("\"Please come to The Mint during regular daytime hours.\"")
                end
                _RemoveAnswer("exchange")
            elseif cmp_strings("James", 1) then
                say("\"James is mine husband and I am very worried about him. I know he is feeling very unhappy lately and he dislikes his job. If thou dost speak to him please tell him that even though we have not been speaking very much lately, that I am still thinking of him and that I still care about him.\"")
                _RemoveAnswer("James")
                set_flag(146, true)
            elseif cmp_strings("bye", 1) then
                say("\"Good day, " .. local0 .. ".\"*")
                break
            end
        end
    elseif eventid() == 0 then
        call_092EH(-42)
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