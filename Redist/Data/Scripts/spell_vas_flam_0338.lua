--- Fire Blast (Vas Flam). Oracle: usecode.dc Func0652 object#(0x652).
--- Second Circle. Cast script: face_dir, sfx(65), up, out, strike2×2, attack, standing.
--- set_to_attack stores the bolt; UC_ATTACK (0x7A) fires it mid-anim (not immediately).

function spell_vas_flam_0338(eventid, objectref)
    if eventid ~= 1 and eventid ~= 4 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Flam@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    if is_npc(target) and is_dead(target) then
        return
    end

    local dir = find_direction(objectref, target)
    begin_casting_mode(objectref, 859)
    -- Exult order: set_to_attack(caster, target, weaponShape 856). UC_ATTACK fires mid-anim.
    set_to_attack(objectref, target, 856)
    -- Success: face,dir,sfx 65,up,out,strike2,strike2,attack,standing
    -- UC_ATTACK fires on the tick after the last strike, while that pose still shows.
    execute_usecode_array(objectref, {17505, 17530, 17514, 17514, 17520, 8047, 65, 7768, dir, 7769})
end
