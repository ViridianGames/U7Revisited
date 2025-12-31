--- This function is called by Fellowship members who are asked about the Fellowship.
--- They respond with a random blurb to make the conversation feel more real.
function utility_fellowship_intro_1049()
    debug_print("utility_fellowship_intro_1049")
    local var_0000, var_0001, var_0002

    var_0001 = random(1, 4)
    if var_0001 == 1 then
        add_dialogue("\"The Fellowship is a society of spiritual seekers who strive to reach the highest levels of human potential and to share this philosophy freely with all people.\"")
        add_dialogue("\"The Fellowship was formed twenty years ago by Batlin with the full approval and support of Lord British.\"")
    elseif var_0001 == 2 then
        add_dialogue("\"The Fellowship is a wonderful organization that is open to all the people of Britannia.\"")
        add_dialogue("\"I have learned so much through studying its philosophy and it has helped me to live my life to the fullest.\"")
        add_dialogue("\"Through The Fellowship I am able to achieve what I have set out to do in life and I am a better person for having joined.\"")
    elseif var_0001 == 3 then
        add_dialogue("\"The Fellowship is the philosophical group devoted to the teachings of a truly great man named Batlin.\"")
        add_dialogue("\"In the absence of the Avatar, Batlin has become a sort of spiritual father for the people of Britannia.\"")
        add_dialogue("\"Through his speeches and writings he has changed the lives of many people, including my own.\"")
    elseif var_0001 == 4 then
        add_dialogue("\"The Fellowship is a group that has been gaining much popularity in recent years with the people of Britannia.\"")
        add_dialogue("\"While on the surface it may simply appear to be a scholarly society studying its particular philosophy, its teachings have the power to forever alter the shape of Britannian society.\"")
        add_dialogue("\"Its ceremonies are deeply moving experiences.\"")
    end
    add_answer("philosophy")
end