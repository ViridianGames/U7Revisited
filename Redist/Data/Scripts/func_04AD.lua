-- Function 04AD: Beverlea's antique shop dialogue and sales
function func_04AD(eventid, itemref)
    -- Local variables (20 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14, local15, local16, local17, local18, local19

    if eventid == 0 then
        local2 = callis_001B(-173)
        local3 = callis_001C(local2)
        if local3 == 7 then
            local13 = callis_Random2(4, 1)
            if local13 == 1 then
                bark(173, "@Antiques?@")
            elseif local13 == 2 then
                bark(173, "@Curios? Knick knacks?@")
            elseif local13 == 3 then
                bark(173, "@Trinkets? Antiques?@")
            elseif local13 == 4 then
                bark(173, "@Collectibles? Antiques?@")
            end
        else
            call_092EH(-173)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(173, 0)
    local0 = call_0909H()
    local1 = callis_003B()
    local2 = callis_001B(-173)
    local3 = callis_000E(-1, 839, -356)
    add_answer({"bye", "job", "name"})

    if not get_flag(0x0226) then
        add_dialogue("You see an old woman who gives you a smile of grandmotherly sweetness. You can see immediately that her vision is poor.")
        set_flag(0x0226, true)
    else
        add_dialogue("\"Why, hello again, ", local0, ". It is so good to see thee!\" says Beverlea.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"My name is Beverlea.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"Why, I run the House of Items here in Paws.\"")
            add_answer({"Paws", "House of Items"})
        elseif answer == "House of Items" then
            add_dialogue("\"It is a shop that sells antiques and previously used items. Running this shop allows me to remain youthful and active. It is heartening to sell things to the poor people of this town that they might not otherwise be able to afford.\"")
            remove_answer("House of Items")
            add_answer("buy")
        elseif answer == "Paws" then
            add_dialogue("\"Here in Paws the people have very little money, but it matters not, because they care for each other.\"")
            remove_answer("Paws")
        elseif answer == "buy" then
            if local2 == 7 then
                add_dialogue("\"There are many rare and fine things to be bought here in my shop. Bargains to be had nowhere else in all of Britannia.\"")
                add_answer("many fine things")
            else