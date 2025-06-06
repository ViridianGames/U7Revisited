--- Best guess: Manages Tiery’s dialogue, a quirky gravedigger at Empath Abbey, discussing his job, the graveyard, and local residents, with flag-based progression and humorous misunderstandings of names like “Umpeth Abby” and “Barry.”
function func_046A(eventid, objectref)
    local var_0000, var_0001

    if eventid ~= 1 then
        if eventid == 0 then
            return
        end
    end

    start_conversation()
    switch_talk_to(0, 106)
    var_0000 = get_player_name()
    var_0001 = get_lord_or_lady()
    add_answer({"bye", "job", "name"})
    if not get_flag(324) then
        add_dialogue("You see an unkempt, yet dapper man talking to himself.")
        set_flag(324, true)
    else
        add_dialogue("\"Eh, wot's that? Oh, it's you, " .. var_0001 .. ".\"")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"M'name's Tiery, " .. var_0001 .. ".\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"Eh, 'ow's that? Oh, m'job. Why, Oi take good care o' me buddies in the graveyard 'ere in Empath Abbey, Oi do.\"")
            add_answer({"buddies", "Empath Abbey"})
        elseif cmps("Empath Abbey") then
            add_dialogue("\"What do ye mean did Oi 'umpeth Abby. 'Course Oi didn't. Oi never went anywhere near Abby. 'Oo told ye that?\"")
            add_answer("'Umpeth Abby")
            remove_answer("Empath Abbey")
        elseif cmps("'Umpeth Abby") then
            add_dialogue("\"Empath Abbey? Why, this 'ere's Empath Abbey, " .. var_0001 .. ". Oi don't mean to pry, but if ye knowest not where ye be, why 'ave ye come 'ere?\" He shakes his head. \"It's just as Oi was tellin' Darek the other day, `If ye never want to be lost,' Oi said, `don't ever go nowheres.'\"")
            remove_answer("'Umpeth Abby")
        elseif cmps("buddies") then
            add_dialogue("\"What wrong with the bodies? Oi don' do nothing more than bury 'em! A fellow could get in lots o' trouble spreading rumors like that.\"")
            add_answer({"bodies", "bury"})
            remove_answer("buddies")
        elseif cmps("bury") then
            add_dialogue("\"Barry? Oh, 'im. Oi don't know what ye's talkin' about. Oi never met Barry's woife! 'Twas just a lie they's spreadin' about me.\"")
            remove_answer("bury")
            add_answer("Barry")
        elseif cmps("Barry") then
            add_dialogue("\"Oi already told ye that's m'job.\"")
            remove_answer("Barry")
        elseif cmps("bodies") then
            add_dialogue("\"That's right. M'buddies! Oi bury 'em. It's m'job.\" He squints at you. \"Unless, " .. var_0001 .. ", yer askin' about the people 'ere?\"")
            add_answer("people")
            remove_answer("bodies")
        elseif cmps("people") then
            add_dialogue("\"No! Of course Oi don't use peep holes. What sort o' question is that to ask a fellow, " .. var_0001 .. "?\"")
            add_answer("peep hole")
            remove_answer("people")
        elseif cmps("peep hole") then
            add_dialogue("\"Well, Oi only know a few people 'ere, but Oi'll try an' 'elp as best as Oi am able. 'Oo do ye want to know about? My two best friends are Garth an' Darek, but Oi often talk to Nina an' Bart when Oi get the chance.~~\"Recently, that Perrin fellow from across the way 'as been spendin' some toime with me. 'E's a real nice chap. A l'ttle brainy, perhaps, " .. var_0001 .. ", but Oi like 'im just the same. Anyone else ye'd like to know about?\"")
            if ask_yes_no() then
                add_dialogue("\"Well, that Perrin fellow'd be a better one to ask than Oi'd be, " .. var_0001 .. ". 'E knows a lot, that one does.\"")
            else
                add_dialogue("\"All right then, glad Oi could introduce ye to a few o' my friends.\"")
            end
            remove_answer("peep hole")
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"G'day, " .. var_0001 .. ". 'Ave a pleasant journey. Oi'll tell Malc 'allo for ye.\"")
    return
end