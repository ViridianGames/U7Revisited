require "U7LuaFuncs"
-- Function 08AB: Manages Fellowship meeting dialogue
function func_08AB()
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    local0 = call_08F7H(-14)
    local1 = call_08F7H(-236)
    local2 = call_08F7H(-18)
    local3 = call_08F7H(-22)
    local4 = call_08F7H(-1)
    local5 = call_08F7H(-2)

    callis_0003(0, -16)
    say("Klog is leading the town members in a Fellowship meeting.")
    say("\"Thank you, Fellowship members of Trinsic, for attending our meeting this evening.~~I am certain you are all sorely aware of the crimes that have been committed in our city. Now is a time to mourn those whom we have lost. We will always remember Christopher, our blacksmith, as a valuable citizen of our town as well as a dear friend. Inamo was an amiable and hard-working gargoyle. As their deaths show us, Britannia needs The Fellowship now more than ever.")
    say("\"The Fellowship was created to advance a philosophy, a method of applying an optimistic order of thought to one's life. How dost thou follow this method? By applying the Triad of Inner Strength to thy life. The Triad is composed of three principles that, when applied in unison to thy life, can soothe the fever of a society that teaches thee to accept failure and banishes the destructive illusory thoughts and feelings from thy spirit.")
    say("\"The first principle is to Strive For Unity. This means that we should reject divisiveness, put aside our differences and work together for the good of us all.")
    say("\"The second principle is to Trust Thy Brother. Trust is essential, for what will you accomplish if you must be divided by constantly watching each other?")
    say("\"The third and final principle is Worthiness Precedes Reward. One must strive to be worthy of the rewards each of us seeks, for if one is not worthy of reward, why should you believe they should receive it?")
    say("\"We must spread the philosophy to everyone who can hear it. For who is there to lift the disunited, mistrustful, and unworthy Britannia up from its sad state but we of The Fellowship?")
    say("\"And now is the time we ask each of our members to give testimonial aloud, and tell how walking with The Fellowship has affected their life.\"")

    if local1 then
        callis_0003(0, -236)
        say("\"The Fellowship has enabled me to reach out and help people where before I have been too preoccupied.\"")
        callis_0004(-236)
    end
    if local0 then
        callis_0003(0, -14)
        say("\"The Fellowship has made me more alert and thorough in the execution of my job as a Trinsic guard.\"")
        callis_0004(-14)
    end
    if local2 then
        callis_0003(0, -18)
        say("\"The Fellowship has made me a happier, more agreeable person.\"")
        callis_0003(0, -16)
        say("\"Thank thee for sharing, brother!\"")
        callis_0004(-18)
    end
    if local3 then
        callis_0003(0, -22)
        say("\"As a Fellowship member, I feel as if I am doing some good for Britannia.\"")
        callis_0004(-22)
    end
    if local5 then
        callis_0003(0, -2)
        say("Spark whispers to no one in particular, \"This is the most boring pile of horse manure in which I have ever had the pleasure to wallow!\"")
        callis_0004(-2)
    end
    if local4 then
        callis_0003(0, -1)
        say("Iolo slaps his own cheek to keep himself from dozing off. ~~\"Avatar, I do believe that we have heard enough of this.\"")
        callis_0004(-1)
    end

    callis_0003(0, -16)
    say("It is apparent that the meeting will be continuing for some time... You decide you have more important matters to attend to.")
    abort()

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function abort()
    -- Placeholder
end