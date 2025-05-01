-- Function 0919: Describe The Fellowship
function func_0919(eventid, itemref)
    local local0, local1

    local0 = get_game_time()
    local1 = _Random2(4, 1)
    if local1 == 1 then
        add_dialogue(itemref, "\"The Fellowship is a society of spiritual seekers who strive to reach the highest levels of human potential and to share this philosophy freely with all people. The Fellowship was formed twenty years ago by Batlin with the full approval and support of Lord British.\"")
    elseif local1 == 2 then
        add_dialogue(itemref, "\"The Fellowship is a wonderful organization that is open to all the people of Britannia. I have learned so much through studying its philosophy and it has helped me to live my life to the fullest. Through The Fellowship I am able to achieve what I have set out to do in life and I am a better person for having joined.\"")
    elseif local1 == 3 then
        add_dialogue(itemref, "\"The Fellowship is the philosophical group devoted to the teachings of a truly great man named Batlin. In the absence of the Avatar, Batlin has become a sort of spiritual father for the people of Britannia. Through his speeches and writings he has changed the lives of many people, including my own.\"")
    elseif local1 == 4 then
        add_dialogue(itemref, "\"The Fellowship is a group that has been gaining much popularity in recent years with the people of Britannia. While on the surface it may simply appear to be a scholarly society studying its particular philosophy, its teachings have the power to forever alter the shape of Britannian society. Its ceremonies are deeply moving experiences.\"")
    end
    add_answer("philosophy")
    return
end