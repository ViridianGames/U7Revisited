--- Decrement stackable item quantity by 1, or remove the object at quantity 1.
--- Oracle: usecode.dc Func0925 (also used as pick-break helper from Func0273H).
function utility_item_quantity_adjust_1061(objectref)
    local quantity = get_item_quantity(objectref)
    if quantity == nil then
        quantity = 1
    end
    if quantity <= 1 then
        remove_item(objectref)
    else
        set_item_quantity(objectref, quantity - 1)
    end
end
