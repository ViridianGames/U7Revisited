# SCRIPTS

Here are all the script functions that still need to be fixed up.


# TODO - things in scripts left to clean up

aidx() - get/set array index. this can be replaced by arr[x] or arr[x] = y lua, doesn't need a function

set_object_type - i think maybe this should be set_object_shape? but many scripts seem to have reversed the arguments

clear_flag - many scripts seem to have reversed the arguments

get_item_flag - many scripts seem to have reversed the arguments

clear_item_flag - many scripts seem to have reversed the arguments

buy_object / purchase_object - don't think we need two diff funcs for the same thing??

add_party_items - scripts seem to have args in wrong order

remove_party_items - scripts seem to have args in wrong order

select_option - not positive what this should map to yet

get_schedule_type(get_npc_name(-30)) - not sure what this is supposed to call and/or why it would take an npc name and not id. this is in tons of npc scripts.

execute_usecode_array({23, 17494, 7715}, objectref) - none of the scripts call this with 3 args

cmps("Brom") - many NPC scripts use, don't know what it is yet.

format_price_message() - dont know how this works

show_purchase_options() - don't know

add_containerobject_s(objectref, {50, 1536, 17493, 7715}) - don't know how this works??

unknown_XXXXH - a lot of these lingering, would have to go back to the beginning to see what they were originally

get_gold

spend_gold

set_stat

say_with_newline

compare_answer

check_npc_status

get_conversation_target

get_cont_items

npc_in_party

set_object_attributes

destroy_object_silent

click_on_item

create_array(x) - can this just be {x} ???

or ... - various scripts had this for some reason? commented out with a TODO

get_random(x) - the normal random(min,max) but this takes only one arg, so 0-x?

display_sign() - this same as open_book()?

# DONE

fixed lua docs for input_numeric_value()
fixed lua docs for spawn_object()
fixed lua docs for set_model_animation_frame()
added wait() to lua docs
get_npc_name_from_id => get_npc_name
get_npc_training_level => get_training_level