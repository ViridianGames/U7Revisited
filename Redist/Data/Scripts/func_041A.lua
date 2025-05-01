-- Function 041A: Manages Batlin's dialogue and interactions
function func_041A(itemref)
    -- Local variables (14 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13

    if eventid() == 1 then
        switch_talk_to(26, 0)
        local0 = callis_001B(-26)
        local1 = callis_001C(local0)
        local2 = call_0931H(-359, 981, 1, -357)
        if local2 then
            add_dialogue("Batlin's eyes narrow to red slits as he peers practically through you.")
            add_dialogue("\"Thou hast the Cube! Thou cannot use it against -me-!\"")
            add_dialogue("With that, Batlin turns with a flourish, and vanishes before your eyes!*")
            set_flag(218, true)
            callis_001B(-26)
            callis_003F(-26)
            abort()
        end
        if get_flag(30) then
            add_dialogue("Batlin looks at you and his gaze returns to the Armageddon winter storm. \"Many years ago, Avatar, I went to Skara Brae, the ghost city. The way the world is now reminds me of that dead place. In Skara Brae I had a spiritual experience so profound that I have never spoken of to another soul. I would like to share that experience with thee now, Avatar.")
            add_dialogue("\"There at Skara Brae I saw a man who was called The Tortured One. I asked this dead man, pray tell, what is the answer to the question of Life and Death? He gave me no reply, and I asked him again. I beseeched him to impart some small parcel of wisdom upon me. What is the answer to the question of Life and Death?! He said nothing, but in his eyes... In his eyes I could see, Avatar, that he could not answer me for there was no answer to give. No answers to the question of Life and Death! It was then I understood. No meanings! No virtues! No values!!!... I commend thee, Avatar, for reaching that same liberating illumination!*\"")
            abort()
        end
        if get_flag(56) then
            add_dialogue("\"Art thou ready to answer questions from the Book of Fellowship?\"")
            if call_090AH() then
                call_0852H()
                if not get_flag(56) then
                    if local0 == 28 then
                        add_dialogue("\"Excellent, Avatar!\"")
                        add_dialogue("Fighting a tremble of hesitation you take a long deep drink from the goblet. Batlin steps up to you. \"May the news spread far and wide that our newest member is none other than the Avatar!\"")
                        add_dialogue("The other Fellowship members cheer with pleasure.")
                    else
                        add_dialogue("\"Very good, Avatar.\"")
                    end
                    local2 = callis_002C(false, -359, 955, 1)
                    set_flag(145, true)
                    set_flag(6, true)
                    call_0911H(500)
                    if not local2 then
                        add_dialogue("\"Allow me to present thee with thy Fellowship medallion.\" Batlin gives you the medallion. \"Please -- wear thy medallion at all times for it shall be a symbol to all who see it that thou dost walk with the Fellowship. Ready it to thy neck immediately! Oh, and... welcome to The Fellowship, Avatar.\"*\"")
                        set_flag(144, true)
                    else
                        add_dialogue("\"Thou art too encumbered to receive thy Fellowship medallion. Thou must lighten thy load.\"*\"")
                    end
                    local3 = callis_0001({17494, 7715}, itemref)
                    abort()
                else
                    add_dialogue("\"My dear Avatar. Thou must realize that thou must know everything there is to know about The Fellowship before I can induct thee. Please study thy Book of Fellowship and return to me.\"")
                    add_dialogue("Your mind seems unclear. I would not be surprised if thou dost not understand another soul with whom thou dost speak.\"")
                    callis_0089(25, itemref)
                    abort()
                end
            else
                add_dialogue("\"Come back when thou art ready.\"*\"")
                abort()
            end
        end
        local4 = call_0909H()
        local5 = callis_0067()
        local6 = callis_003B()
        local0 = callis_001B(-26)
        local1 = callis_001C(local0)
        local7 = call_0908H()
        if local0 == 28 then
            if get_flag(141) and not get_flag(145) then
                call_084FH()
            else
                call_0850H()
            end
        end
        add_answer({"bye", "job", "name"})
        if not get_flag(65) then
            add_answer("Elizabeth and Abraham")
        end
        if not get_flag(6) and not get_flag(150) then
            add_answer("join")
        end
        if get_flag(215) or (get_flag(214) and not get_flag(265)) then
            add_answer("package")
        end
        if get_flag(265) then
            add_answer("delivered package")
            remove_answer("package")
        end
        if get_flag(258) then
            add_answer("package delivered")
        end
        if get_flag(286) then
            add_answer("package delivered")
            remove_answer({"package delivered", "delivered package"})
            if not get_flag(151) then
                add_answer("chest")
            end
        end
        if get_flag(141) then
            remove_answer("chest")
        end
        if get_flag(145) and not get_flag(144) then
            add_answer("medallion")
        end
        if get_flag(148) then
            add_answer("apples")
        end
        if not get_flag(10) or get_flag(140) or get_flag(142) then
            add_answer("voice")
        end
        if not get_flag(139) then
            add_answer("Meditation Retreat")
        end
        if not get_flag(155) then
            add_dialogue("You see a rotund older gentleman, who is at once humble yet dignified. His gentle eyes exude caring for his fellow person.")
            set_flag(155, true)
            if local5 and not get_flag(6) then
                add_dialogue("The man's eyes focus on the Fellowship medallion around your neck.")
                add_dialogue("\"My dear friend, thou art falsely impersonating a Fellowship member! Remove that medallion at once!\"*\"")
                abort()
            end
        else
            if local5 and not get_flag(6) then
                add_dialogue("\"I shall not speak to thee unless thou dost remove that Fellowship medallion. Thou art falsely impersonating a Fellowship member!\"*\"")
                abort()
            end
            add_dialogue("\"" .. local7 .. ", my dear, dear friend! How wonderful to see thee again!\" says Batlin.")
        end
        while true do
            if cmp_strings("name", 1) then
                add_dialogue("\"My name, good friend, is Batlin. And indeed it is truly a privilege to meet the Avatar in the flesh.\"")
                remove_answer("name")
            elseif cmp_strings("job", 1) then
                add_dialogue("\"I was once a druid. Now I am the leader and the originator of The Fellowship. It is rapidly growing throughout Britannia and keeps me very busy, as thou canst well imagine. Ha! Ha! Ha!\"")
                add_answer("Fellowship")
            elseif cmp_strings("Fellowship", 1) then
                add_dialogue("\"The Fellowship was formed twenty years ago with the full approval and support of Lord British. It is a society of spiritual seekers who strive to reach the highest levels of human potential and to share this knowledge freely with all people.\"")
                remove_answer("Fellowship")
                add_answer("spiritual")
            elseif cmp_strings("spiritual", 1) then
                add_dialogue("\"The Fellowship advances the philosophy of sanguine cognition, a way to apply a positive order of thought to one's life through what is called the Triad of Inner Strength.\"")
                remove_answer("spiritual")
                add_answer({"Triad", "sanguine cognition"})
            elseif cmp_strings("sanguine cognition", 1) then
                add_dialogue("\"We strive to avoid the mistakes made by mystics and sages since the dawn of time. They apply the standards of the past, such as the virtues, for example, to qualify the present, and thus they do not perceive it correctly. We seek to examine our present lives each on our own terms and see the world the way it is.\"")
                remove_answer("sanguine cognition")
                add_answer("virtues")
            elseif cmp_strings("virtues", 1) then
                add_dialogue("\"They are perfectly adequate for those who feel that they still need them for whatever reason. But no one, not even thyself, thou must admit, Avatar, can fulfill them perfectly. Therefore they are a philosophy that is ultimately based upon failure. We have never claimed that our teachings are a substitute for the virtues. However, ours is a belief that is based upon success, not failure.\"")
                remove_answer("virtues")
            elseif cmp_strings("Triad", 1) then
                add_dialogue("\"The Triad of Inner Strength is simply three basic values that, when applied in unison, enable one to be more creative, satisfied and successful in life.\"")
                remove_answer("Triad")
                add_answer("values")
            elseif cmp_strings("values", 1) then
                add_dialogue("\"The three values of the Triad of Inner Strength are Strive For Unity, Trust Thy Brother and Worthiness Precedes Reward.\"")
                remove_answer("values")
                add_answer({"Worthiness", "Trust", "Unity"})
            elseif cmp_strings("Unity", 1) then
                add_dialogue("\"When we say Strive For Unity, it is simply our way of expressing how the people of Britannia should all cooperate and work together. A worthwhile sentiment, I am certain thou wouldst concur.\"")
                remove_answer("Unity")
                add_answer("join")
            elseif cmp_strings("Trust", 1) then
                add_dialogue("\"What The Fellowship means by this is that people are all the same and the world is, generally speaking, a supportive, nurturing place. The trust we place in each other is like the pinions that hold our society together. Quite true, wouldst thou not say?\"")
                remove_answer("Trust")
                add_answer("join")
            elseif cmp_strings("Worthiness", 1) then
                add_dialogue("\"Allow me to explain the meaning of Worthiness Precedes Reward. Each one of us seeks something which we desire from life and we must strive to be worthy of that which we seek. It would be difficult for thee to disagree I am quite sure.\"")
                remove_answer("Worthiness")
                add_answer("join")
            elseif cmp_strings("Elizabeth and Abraham", 1) then
                if not get_flag(261) then
                    add_dialogue("\"Ah, my good colleagues Elizabeth and Abraham were just here. They left this morning for Minoc on Fellowship business. They deal with the distribution and collection of funds.\"")
                    set_flag(135, true)
                elseif not get_flag(363) then
                    add_dialogue("\"I have not seen my colleagues since they were last here. They are busy folk.\"")
                elseif not get_flag(644) then
                    add_dialogue("\"I have not seen my colleagues since they were last here. They are busy folk.\"")
                elseif not get_flag(644) then
                    add_dialogue("Batlin smiles and shakes his head. \"Thou art not having much luck tracking them down, art thou? They were here, having done some work in Jhelom, but now they have gone to Vesper to see about starting a branch there.\"")
                    set_flag(136, true)
                else
                    add_dialogue("\"I have not seen my colleagues since they were last here. They are busy folk.\"")
                end
                remove_answer("Elizabeth and Abraham")
            elseif cmp_strings("join", 1) then
                if get_flag(6) then
                    add_dialogue("\"But thou art already a member, Avatar! One can only join once!\"")
                elseif not get_flag(150) and not get_flag(151) then
                    add_dialogue("\"Thou hast not completed thy tasks. Remember that Worthiness Precedes Reward. Once thou hast completed the missions, thou mayest join.\"")
                else
                    call_084DH()
                end
                remove_answer("join")
            elseif cmp_strings("package", 1) then
                if get_flag(215) and not get_flag(143) then
                    add_dialogue("\"Ah! I do hope thine hands are not too full to take the package.\"")
                    local8 = callis_0029(-359, 798, -26)
                    local9 = callis_0025(local8)
                    local10 = callis_0036(-356)
                    if local10 then
                        add_dialogue("\"Excellent! Here it is. Thou must now be on thy way!\"*")
                        set_flag(143, true)
                        abort()
                    else
                        local10 = callis_0036(-26)
                        add_dialogue("\"Avatar! I am tired of this! Please make room in thine inventory for the package!\"*")
                        abort()
                    end
                else
                    call_0851H()
                end
            elseif cmp_strings("delivered package", 1) then
                add_dialogue("\"Congratulations, Avatar, and our thanks to thee for successfully delivering our package to Elynor of Minoc. Now we have another task at hand before thou canst join The Fellowship. Because thou didst deliver the package thou hast proven thyself worthy of performing another mission.\"")
                remove_answer("delivered package")
                add_answer("mission")
            elseif cmp_strings("package delivered", 1) then
                add_dialogue("\"Avatar, didst thou deliver the package to Elynor of Minoc?\"")
                local11 = call_090AH()
                if local11 then
                    add_dialogue("\"Didst thou open the package?\"")
                    local12 = call_090AH()
                    if local12 then
                        add_dialogue("\"Thou knew that thou wast instructed not to open it. We put trust in thee to carry out our instructions to the letter and that trust was broken.\"")
                        add_answer("mission")
                    else
                        add_dialogue("\"That is not what Elynor of Minoc tells us. We put trust in thee to carry out our instructions to the letter and that trust was broken.\"")
                    end
                    if get_flag(286) then
                        add_dialogue("\"I understand that the contents of the package were missing as well, and this is very serious indeed!\"")
                    end
                    add_dialogue("\"I am afraid that thou must carry out a mission for us as a test of trust if thou art to begin truly walking with The Fellowship.\"")
                    add_answer("mission")
                else
                    add_dialogue("Batlin's eyes open wide in surprise.")
                    add_dialogue("\"What has happened? Hast thou lost the package?\"")
                    local13 = call_090AH()
                    if local13 then
                        add_dialogue("\"Tsk. Tsk. Tsk. That is most unfortunate. We put trust in thee to deliver the package and that trust was broken. I am afraid that thou must carry out a mission for us as a test of trust if thou art to begin truly walking with The Fellowship.\"")
                        add_answer("mission")
                    else
                        add_dialogue("\"Please deliver our package, Avatar. We have more business to discuss once thou art finished.\"*")
                        abort()
                    end
                end
                remove_answer("package delivered")
            elseif cmp_strings("mission", 1) then
                add_dialogue("\"Thou shalt visit the dungeon of Destard, which is in the mountains just west of Trinsic. Do not worry, it is completely deserted. There thou shalt find a chest of Fellowship funds which was hidden for safekeeping just a few days ago. Thou wilt know the chest because it will contain not only gold but two Fellowship medallions. The site is also most likely marked with a Fellowship staff. Bring these funds back to us without losing a single coin and thou wilt have successfully completed thy mission. No need to bring the chest, just the gold. Now, thou must be on thy way!\"*")
                set_flag(142, true)
                call_0911H(100)
                remove_answer("mission")
                abort()
            elseif cmp_strings("chest", 1) then
                add_dialogue("\"Ah yes, thou hast returned from Dungeon Destard! But wait! I do not see the Fellowship funds that thou wast to bring back! What has happened?!\"")
                add_answer({"ship sunk", "pirates", "monsters", "a highwayman"})
                remove_answer("chest")
            elseif cmp_strings("a highwayman", 1) then
                add_dialogue("\"Why, thy tale is outlandish! I refuse to believe it!\" Batlin sniffs in irritation.")
                remove_answer("a highwayman")
                add_answer("join")
            elseif cmp_strings("monsters", 1) then
                add_dialogue("\"Monsters! There are monsters lurking in dungeon Destard?! Well then, I do apologize for thine inconvenience.\"")
                remove_answer({"pirates", "ship sunk", "a highwayman", "monsters"})
                add_answer("join")
            elseif cmp_strings("pirates", 1) then
                add_dialogue("\"Surely thou canst do better than that! If thou simply dost not wish to answer my question why dost thou not say so?\"")
                remove_answer("pirates")
                add_answer("join")
            elseif cmp_strings("ship sunk", 1) then
                add_dialogue("Batlin slowly rolls his eyes. \"Thou ought to have been a bard, thou dost regale me with such stories!\"")
                remove_answer("ship sunk")
                add_answer("join")
            elseif cmp_strings("medallion", 1) then
                local2 = callis_002C(false, -359, 955, 1)
                if not local2 then
                    add_dialogue("\"Allow me to present thee with thy Fellowship medallion.\" Batlin gives you the medallion. \"Please -- wear the medallion at all times. Ready it to thy neck immediately! Oh, and... welcome to The Fellowship, Avatar.\"")
                    set_flag(144, true)
                    remove_answer("medallion")
                else
                    add_dialogue("\"Thou cannot receive thy Fellowship medallion. Thou art too encumbered!\"*")
                end
            elseif cmp_strings("apples", 1) then
                add_dialogue("\"While thou art here, please feel free to enjoy an apple. The finest in all of Britannia, I am certain thou wilt find. They are provided to The Fellowship by the Royal Orchards.\"")
                remove_answer("apples")
            elseif cmp_strings("voice", 1) then
                if get_flag(150) then
                    add_dialogue("\"Once a person has walked with The Fellowship long enough and applied the Triad of Inner Strength to his life, he has cleared his mind of all conflicting, counterproductive thoughts to the point where he may actually hear his internal voice of reason. This voice of reason is the core of thine inner mind which guides thee through pure instinct, wisdom and irreproachable logic. Once one starts to listen to it and follow its guidance, one has achieved the height of enlightenment. Perhaps thou shalt hear it one day.\"")
                    call_0911H(20)
                else
                    add_dialogue("\"Only active or potential Fellowship members are privy to the concept of 'the voice'. I can tell thee more when thou dost take the Fellowship test.\"")
                    add_answer("test")
                end
                remove_answer("voice")
            elseif cmp_strings("test", 1) then
                add_dialogue("\"Oh, art thou ready to join The Fellowship?\"")
                if call_090AH() then
                    call_084DH()
                else
                    add_dialogue("\"Until thou art ready to join, I cannot tell thee any more about the test.\"")
                    add_answer("join")
                end
                remove_answer("test")
            elseif cmp_strings("Meditation Retreat", 1) then
                add_dialogue("\"It is a retreat from the pressures and distractions of everyday life where new members of The Fellowship may go and study the philosophies of The Fellowship. It is located on an island east of Serpent's Hold.\"")
                remove_answer("Meditation Retreat")
            elseif cmp_strings("bye", 1) then
                add_dialogue("\"Until we meet again, Avatar.\"*")
                break
            end
        end
    elseif eventid() == 0 then
        call_092EH(-26)
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function add_dialogue(...)
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