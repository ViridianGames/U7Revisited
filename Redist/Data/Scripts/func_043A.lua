--- Best guess: Manages Gordon’s dialogue, handling his fish and chips business, Fellowship membership, and aspirations to visit Buccaneer’s Den, with flag-based transactions and random vendor calls.
function func_043A(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    if eventid ~= 1 then
        if eventid == 0 then
            var_0002 = unknown_003BH()
            var_0003 = unknown_001CH(unknown_001BH(58))
            var_0009 = random2(4, 1)
            if var_0003 == 7 then
                if var_0009 == 1 then
                    var_000A = "@Fish 'n' chips!@"
                elseif var_0009 == 2 then
                    var_000A = "@Hot fish 'n' chips!@"
                elseif var_0009 == 3 then
                    var_000A = "@Fish 'n' chippies!@"
                elseif var_0009 == 4 then
                    var_000A = "@Fish 'n' chips here!@"
                end
                bark(var_000A, 58)
            else
                unknown_092EH(58)
            end
        end
        add_dialogue("\"Have a pleasant day, " .. get_lord_or_lady() .. ".\"")
        return
    end

    start_conversation()
    switch_talk_to(0, 58)
    var_0000 = get_lord_or_lady()
    var_0001 = unknown_0067H()
    var_0002 = unknown_003BH()
    var_0003 = unknown_001CH(unknown_001BH(58))
    if var_0002 == 7 then
        var_0004 = unknown_08FCH(26, 58)
        if var_0004 then
            add_dialogue("Gordon is too involved in listening to the Fellowship meeting to hear you.")
            return
        elseif get_flag(218) then
            add_dialogue("\"Where oh where is Batlin? He is late for the meeting!\"")
        else
            add_dialogue("\"Oh, my! I must leave immediately! I am late for the Fellowship meeting!\"")
            return
        end
    end
    add_answer({"bye", "job", "name"})
    if not get_flag(187) then
        add_dialogue("You see a friendly face looking back at you.")
        set_flag(187, true)
    else
        add_dialogue("\"How art thou this fine day, " .. var_0000 .. "?\" asks Gordon.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"My name is Gordon.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I sell fish and chips from my wagon.\"")
            add_answer({"wagon", "fish and chips"})
        elseif cmps("fish and chips") then
            if var_0003 ~= 7 then
                add_dialogue("\"Come back later when I am open for business.\"")
                return
            else
                add_dialogue("\"I have the best fish and chips thou shalt taste in all of Britannia. My price is only 8 gold coins per serving. Wouldst thou like to have some?\"")
                var_0005 = unknown_090AH()
                if var_0005 then
                    var_0006 = unknown_002BH(359, 359, 644, 8)
                    if var_0006 then
                        var_0007 = unknown_002CH(true, 30, 359, 377, 1)
                        if var_0007 then
                            add_dialogue("He hands you a plate.")
                            add_dialogue("\"They are indeed the best fish and chips in all of Britannia.\"")
                        else
                            add_dialogue("\"Thou art carrying too many things to take thy fish and chips from me!\"")
                        end
                    else
                        add_dialogue("\"Thou dost not have enough gold to get any fish and chips. Sorry!\"")
                    end
                else
                    add_dialogue("\"Come back again when thou art hungry and I am sure thou shalt change thy mind.\"")
                end
            end
            remove_answer("fish and chips")
        elseif cmps("wagon") then
            add_dialogue("\"I just painted my wagon recently. It receives more attention. Business is much better now. I am saving my money to travel to Buccaneer's Den.\"")
            remove_answer("wagon")
            add_answer({"Buccaneer's Den", "business"})
        elseif cmps("business") then
            add_dialogue("\"Ever since I became a member of The Fellowship, business has been increasing steadily. I have refined and improved the recipe for my fish batter and it has since become a favorite meal of nearly everyone in Britain. I have even served my fish and chips to Lord British himself.\"")
            add_answer({"Lord British", "Fellowship"})
            remove_answer("business")
        elseif cmps("Lord British") then
            add_dialogue("\"Thou dost know-- the bloke who wears a crown and acts like a king.\"")
            remove_answer("Lord British")
        elseif cmps("Fellowship") then
            if var_0001 then
                add_dialogue("\"I am glad to see that thou art a member. Will I see thee at the next meeting?\"")
                var_0008 = unknown_090AH()
                if var_0008 then
                    add_dialogue("\"Then I shall see thee at nine o'clock sharp!\"")
                else
                    add_dialogue("\"Thou shouldst apply thyself more stringently to the ways of The Fellowship! Our meeting is at nine o'clock. I can see thou dost certainly need to attend.\"")
                end
            else
                unknown_0919H()
            end
            remove_answer("Fellowship")
        elseif cmps("philosophy") then
            unknown_091AH()
            remove_answer("philosophy")
        elseif cmps("Buccaneer's Den") then
            add_dialogue("\"I wish to win some money at Buccaneer's Den. It is a pirate resort and they have a fabulous House of Games there.\"")
            add_answer({"House of Games", "pirate resort"})
            remove_answer("Buccaneer's Den")
        elseif cmps("pirate resort") then
            add_dialogue("\"As I am certain thou knowest, Buccaneer's Den was once a den of thieves and villains. As such, it held a romantic appeal for those who longed for a taste of such an adventurous existence. I confess, I am one of those people. When thou dost spend thy life selling fish from a wagon, thou art in need of excitement. The pirates eventually realized just how much they are secretly envied, and so they have turned their island into a place of thrilling amusements.\"")
            remove_answer("pirate resort")
        elseif cmps("House of Games") then
            add_dialogue("\"It is said they have several games of chance there! Gold can be won wagering on the outcome of a race of fine stallions.\"")
            remove_answer("House of Games")
        elseif cmps("Fellowship") then
            add_dialogue("\"I saw thee receive thy medallion. I can certainly say the Fellowship has done wonders for my life and I know it will be the same for thee as well.\" He gives thee a knowing grin.")
            remove_answer("Fellowship")
        elseif cmps("bye") then
            break
        end
    end
    return
end