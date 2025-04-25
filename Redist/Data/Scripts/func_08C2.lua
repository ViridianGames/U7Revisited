-- Function 08C2: Manages Forsythe's sacrifice dialogue
function func_08C2()
    -- Local variables (2 as per .localc)
    local local0, local1

    local0 = call_0909H()
    local1 = call_0908H()
    say("Well, hello, Mayor Forsythe. Thou has finally decided to assist in the salvation of our town.\" She gives him a pointed look.")
    callis_0003(0, -147)
    say("Look here, I wasn't the one who gave that fool recipe to Caine, now was I?")
    callis_0004(-147)
    callis_0003(0, -143)
    say("That fool recipe just got rid of Horance for us.\" Mistress Mordra speaks through clenched teeth.")
    callis_0003(0, -147)
    say("Hmmph. Thou hast taken thy sweet time, madam. And now I am off to jump in a well.")
    callis_0004(-147)
    callis_0003(0, -143)
    say("Ignorant fool!")
    callis_0003(0, -147)
    say("Old biddy!")
    callis_0004(-147)
    callis_0003(0, -143)
    say("Thou wilt regret that, Toad.\" Fire flares in the depths of her eyes and electricity crackles in her hair. She lifts her arms as if to cast some dreadful spell, but Forsythe whimpers and hides behind you. She sees the look on your face and slowly lowers her arms. The flames and lightning flicker, and die.~~\"Forgive my behavior, ", local0, ". What was that about a well.\" You explain that Forsythe has volunteered to sacrifice himself for the spirits of the others. She looks him in the eyes. He brushes himself off and stands up straight. \"I didst not think that thou had it in thee, Mayor. I am in thy debt.\"")
    callis_0003(0, -147)
    say("Yes, well. Thou art welcome, I guess.\" He looks as if his dignity has been somewhat replenished.")
    callis_0004(-147)
    callis_0003(0, -143)
    say("I suppose thou hadst better get thee hence, then. Fare thee well, Forsythe. 'Tis not all that bad, roaming the ether. At least not once thou becomest accustomed to it.\"~~She turns to you. \"Goodbye, ", local1, ". If thou art successful, I will not see thee again. May thy fortunes be good.\"")
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