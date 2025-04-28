require "U7LuaFuncs"
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
                _ItemSay("@Antiques?@", -173)
            elseif local13 == 2 then
                _ItemSay("@Curios? Knick knacks?@", -173)
            elseif local13 == 3 then
                _ItemSay("@Trinkets? Antiques?@", -173)
            elseif local13 == 4 then
                _ItemSay("@Collectibles? Antiques?@", -173)
            end
        else
            call_092EH(-173)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -173)
    local0 = call_0909H()
    local1 = callis_003B()
    local2 = callis_001B(-173)
    local3 = callis_000E(-1, 839, -356)
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0226) then
        say("You see an old woman who gives you a smile of grandmotherly sweetness. You can see immediately that her vision is poor.")
        set_flag(0x0226, true)
    else
        say("\"Why, hello again, ", local0, ". It is so good to see thee!\" says Beverlea.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"My name is Beverlea.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"Why, I run the House of Items here in Paws.\"")
            _AddAnswer({"Paws", "House of Items"})
        elseif answer == "House of Items" then
            say("\"It is a shop that sells antiques and previously used items. Running this shop allows me to remain youthful and active. It is heartening to sell things to the poor people of this town that they might not otherwise be able to afford.\"")
            _RemoveAnswer("House of Items")
            _AddAnswer("buy")
        elseif answer == "Paws" then
            say("\"Here in Paws the people have very little money, but it matters not, because they care for each other.\"")
            _RemoveAnswer("Paws")
        elseif answer == "buy" then
            if local2 == 7 then
                say("\"There are many rare and fine things to be bought here in my shop. Bargains to be had nowhere else in all of Britannia.\"")
                _AddAnswer("many fine things")
            else