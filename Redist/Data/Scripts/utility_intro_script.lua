--- Best guess: Handles dialogue with Iolo in Trinsic, discussing the murder, companions, and quest progression, with options to join or leave.
function utility_intro_script()
    local player_name, player_member_names, party_member_1_name, lord_or_lady, player_female, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012


    set_flag(20, true)
    hide_ui_elements()
    jump_camera_angle(315)
    -- Intro cast must not wander on schedules until this script finishes.
    stop_npc_schedule(1)  -- Iolo (also kept off via party)
    stop_npc_schedule(11) -- Petre
    stop_npc_schedule(12) -- Finnigan
    --set_npc_pos(12, 1065, 0, 2215)
    set_npc_dest(11, 1068, 0, 2215)
    set_npc_override_frame(11, 12)
    set_npc_visibility(0, false)
    --set_npc_pos(0, 16, 0, 16)
    block_input()
    -- Fade-in + music are handled by MainState after the title fades out.
    wait(2)
    bark_npc(1, "\"There, there...\"")
    wait(2)
    bark_npc(11, "\"'Tis horrible!\"")
    wait(2)
    bark_npc(1, "\"I know, 'tis shocking!\"")
    wait(2)
    bark_npc(11, "\"Who could have done it?\"")
    wait(2)
    bark_npc(1, "\"I know not...'\"")
    wait(2)
    bark_npc(11, "\"He had no enemies...\"")
    wait(2)
    bark_npc(1, "\"Poor man.\"")
    wait(2)
    bark_npc(11, "\"What is to be done?\"")
    wait(2)
    clear_npc_override_frame(11)
    set_camera_destination_angle(270)
    bark_npc(1, "\"I know not...\"")
    set_flag(92, true)
    local moongate_id = spawn_object(157, 0, 1080, 0, 2214)
    set_model_animation_frame(moongate_id, "idle", 4)
    play_looping_sound_effect(moongate_id, 77, -1, true)
    wait(1)
    set_npc_dest(0, 1071, 0, 2214)
    set_npc_visibility(0, true)
    wait(1)
    stop_looping_sound_effect(moongate_id)
    destroy_object(moongate_id)
    wait(1)
    utility_intro_iolo()
    add_to_party(1)
    set_camera_destination_angle(0)
    set_npc_dest(12, 1065, 0, 2215)
    wait(0.25) -- let pathfinding start before we poll arrival
    bark_npc(12, "I would have words with thee.")
    -- get_npc_position returns x,y,z as floats; comparing to 1065 never matched and hung the intro
    -- (input stayed blocked). Wait for path end / proximity instead.
    local timeout = 40
    while timeout > 0 do
        local fx, fy, fz = get_npc_position(12)
        if math.abs(fx - 1065) < 1.25 and math.abs(fz - 2215) < 1.25 then
            break
        end
        if wait_move_end(12) and not is_npc_moving(12) then
            break
        end
        wait(0.25)
        timeout = timeout - 0.25
    end
    -- Snap so conversation starts even if pathfinding stopped short.
    set_npc_pos(12, 1065, 0, 2215)
    debug_print("About to start finnigan's conversation")
    utility_intro_finnigan()
    debug_print("Back from finnigan's conversation")
    -- Intro over: Petre and Finnigan may resume normal schedules.
    -- Iolo stays schedule-off while in the party.
    start_npc_schedule(11)
    start_npc_schedule(12)
    resume_input()
    show_ui_elements()
end