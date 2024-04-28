-- RandomCharacter v1.0.3
-- SmoothSpatula
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)

-- ========== Parameters ==========

local max_survivor_id = 15
local params = {
    enabled  = true,
    randomize_skills = true,
    randomize_skin = true,
    overwrite_locked_skills = false,
    animation_delay = 8
}

mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.tomlfuncs then 
    Toml = v
    params = Toml.config_update(_ENV["!guid"], params)
    Toml.save_cfg(_ENV["!guid"], params)
end end end)

-- ========== ImGui ==========

gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Enable Character Roll", params['enabled'])
    if clicked then
        params['enabled'] = new_value
    end
end)
gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Randomize chosen skills", params['randomize_skills'])
    if clicked then
        params['randomize_skills'] = new_value
    end
end)
gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("You can get locked skills", params['overwrite_locked_skills'])
    if clicked then
        params['overwrite_locked_skills'] = new_value
    end
end)
gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Randomize Skin", params['randomize_skin'])
    if clicked then
        params['randomize_skin'] = new_value
    end
end)

gui.add_to_menu_bar(function()
    local new_value, isChanged = ImGui.InputInt("Set animation delay", params['animation_delay'], 1, 2, 0)
    if isChanged then
        params['animation_delay'] = new_value
    end
end)

-- ========== Utils ==========

-- selects the character with the specified id
function set_char(sMenu, id)
    if Helper.instance_exists(sMenu) then
        gm.call(sMenu.set_choice.script_name, sMenu, sMenu, id)
    end
end

-- selects a random character that is unlocked and not hidden
function choose_rand_char()
    local random_survivor = nil
    local is_unlocked = false
    local is_hidden = true
    local rand_id = nil
    repeat
        rand_id = math.random(1, max_survivor_id)
        random_survivor = gm.variable_global_get("class_survivor")[rand_id +1]
        if random_survivor then
            if random_survivor[26] then
                is_unlocked = gm.achievement_is_unlocked(random_survivor[26])
            else is_unlocked = true end
            is_hidden = random_survivor[33]
        end
    until random_survivor and is_unlocked and not is_hidden
    return rand_id
end

function choose_rand_skill(random_survivor, skill_slot) 
    local possible_skills = {}
    local i = 1
    while random_survivor[7+skill_slot].elements[i] ~= nil do

        if random_survivor[7+skill_slot].elements[i].achievement_id == -1.0 or params['overwrite_locked_skills']
        then
            possible_skills[#possible_skills+1]=i
        elseif gm.achievement_is_unlocked(random_survivor[7+skill_slot].elements[i].achievement_id) then
            possible_skills[#possible_skills+1]=i
        end
        i = i + 1
    end
    return possible_skills[math.random(#possible_skills)]
end

-- ========== Main ==========

local choice_set = 0
local end_choice = 0
-- plays the roll animation
gm.pre_script_hook(gm.constants._ui_draw_button, function()
    if not params['enabled'] then return end
    local sMenu = Helper.find_active_instance(gm.constants.oSelectMenu)
    if Helper.instance_exists(sMenu) and choice_set <= end_choice then
        choice_set = choice_set + 1
        if choice_set%params['animation_delay'] == 0 then
            set_char(sMenu, choice_set/params['animation_delay'])
        end
    end
    if Helper.instance_exists(sMenu) and choice_set == end_choice +1 then
        choice_set = choice_set + 1
        local chosen_survivor = gm.variable_global_get("class_survivor")[end_choice/params['animation_delay']+1]
        if params['randomize_skins'] then Menu.choice_loadout.family_choice_index.skin = math.random(0,3) end
        if params['randomize_skills'] then 
            sMenu.choice_loadout.family_choice_index.skill0 = choose_rand_skill(chosen_survivor, 0) - 1
            sMenu.choice_loadout.family_choice_index.skill1 = choose_rand_skill(chosen_survivor, 1) - 1
            sMenu.choice_loadout.family_choice_index.skill2 = choose_rand_skill(chosen_survivor, 2) - 1
            sMenu.choice_loadout.family_choice_index.skill3 = choose_rand_skill(chosen_survivor, 3) - 1
        end
    end
end)

-- resets the animation and random character on entering lobby
gm.pre_script_hook(gm.constants.PlayerLobbyChoiceInfo, function(self, other, result, args)
    if not params['enabled'] then return end
    choice_set = 0
    end_choice = choose_rand_char() * params['animation_delay']
end)
