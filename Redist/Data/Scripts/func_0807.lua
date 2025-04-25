-- Function 0807: Initialize ship
function func_0807(eventid, itemref)
    local local0, local1, local2

    if not get_flag(5) then
        _SetItemType(981, eventid)
        local1 = {2784, 1767, 0}
        call_003EH(local1, eventid)
        local1[2] = local1[2] + 2
        call_003EH(local1, -356)
        call_0808H()
        local2 = call_0002H(8, 1565, {17493, 7715}, -356)
        set_flag(5, true)
    end
end