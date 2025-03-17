-- RandomCharacter v1.1.0
-- SmoothSpatula

mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true)
require("randomChar.lua") -- load custom char 

-- ========== Parameters ==========

local max_survivor_id = 15
local params = {
    enabled  = false,
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
    local new_value, clicked = ImGui.Checkbox("Roll character on startup", params['enabled'])
    if clicked then
        params['enabled'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)
gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Randomize skills", params['randomize_skills'])
    if clicked then
        params['randomize_skills'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)
gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("You can get locked skills", params['overwrite_locked_skills'])
    if clicked then
        params['overwrite_locked_skills'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)
gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Randomize Skin", params['randomize_skin'])
    if clicked then
        params['randomize_skin'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)

gui.add_to_menu_bar(function()
    local new_value, isChanged = ImGui.InputInt("Set animation delay ", params['animation_delay'], 1, 2, 0)
    if isChanged then
        if new_value >= 2 then
            params['animation_delay'] = new_value
        else
            params['animation_delay'] = 2
        end
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)

-- ========== Utils ==========

-- selects the character with the specified id
function set_char(sMenu, id)
    gm.call(sMenu.value.set_choice.script_name, sMenu.value, sMenu.value, id)
end

-- the random selection is done by generating until a correct value is found

-- selects a random character that is unlocked and not hidden
function choose_rand_char()
    local survivor = nil
    local is_unlocked = false
    local is_hidden = true
    local rand_id = nil
    repeat
        rand_id = math.random(0, max_survivor_id)
        survivor = gm.variable_global_get("class_survivor")[rand_id +1]
        if survivor then
            if survivor[26] then
                is_unlocked = gm.achievement_is_unlocked(survivor[26])
            else is_unlocked = true end
            is_hidden = survivor[33]
        end
    until survivor and is_unlocked and not is_hidden
    return rand_id
end

-- selects skills
function choose_rand_skill(survivor, skill_slot) 
    local skill = gm.array_get(survivor, 6+skill_slot)
    local count = gm.array_length(skill.elements)
    if count <=1 then return 0 end
    local rand_skill = nil
    repeat 
        rand_skill = math.random(0, count-1)
    until gm.array_get(skill.elements, rand_skill).achievement_id == -1.0 or 
        params['overwrite_locked_skills'] or 
        gm.achievement_is_unlocked(gm.array_get(skill.elements, rand_skill).achievement_id)
    return rand_skill
end

-- selects a skin
function choose_rand_skin(survivor)
    local skin_family = gm.array_get(survivor, 10)
    local count = gm.array_length(skin_family.elements)
    if count <= 1 then return 0 end
    local rand_skin = nil
    repeat 
        rand_skin = math.random(0, count-1)
    until gm.array_get(skin_family.elements, rand_skin).achievement_id == -1 or 
        gm.achievement_is_unlocked(gm.array_get(skin_family.elements, rand_skin).achievement_id)
    return rand_skin
end

-- ========== Main ==========
local random_id = 0
function init()
    local sdl = gm.variable_global_get("survivor_display_list")
    local size = gm.ds_list_size(sdl)
    local survivors = gm.variable_global_get("class_survivor")
    -- get the Random survivor id
    for i=0, gm.array_length(survivors) do 
        if survivors[i+1] and survivors[i+1][1] == "Random" then
            random_id = i
        end
    end
    -- if it is not the last survivor in the display_list, make it last
    if random_id < size-1 then
        gm.ds_list_delete(sdl, random_id)
        gm.ds_list_add(sdl, random_id)
    end
    max_survivor_id = size - 2
end

Initialize(init, true)

local choice_set = 0
local end_choice = 0
-- plays the roll animation
gm.pre_script_hook(gm.constants._ui_draw_button, function()
    local sMenu = Instance.find(gm.constants.oSelectMenu) -- find the selectMenu instance
    if sMenu:exists() then -- check if we are in the selectMenu
        
        if choice_set <= end_choice then -- animation running
            choice_set = choice_set + 1
            if choice_set%params['animation_delay'] == 0 then -- change selection
                if choice_set == random_id * params['animation_delay'] then -- skip random char
                    choice_set = choice_set + params['animation_delay'] 
                end
                set_char(sMenu, choice_set/params['animation_delay'])
            end
        end
        if choice_set == end_choice +1 then -- ## maybe change this, or use elseif
            choice_set = choice_set + 1
            local chosen_survivor = gm.variable_global_get("class_survivor")[end_choice/params['animation_delay']+1]

            if params['randomize_skin'] then 
                local skin = choose_rand_skin(chosen_survivor)
                sMenu.choice_loadout.family_choice_index.skin = skin 
            end
            if params['randomize_skills'] then
                sMenu.value.choice_loadout.family_choice_index.skill0 = choose_rand_skill(chosen_survivor, 0)
                sMenu.value.choice_loadout.family_choice_index.skill1 = choose_rand_skill(chosen_survivor, 1)
                sMenu.value.choice_loadout.family_choice_index.skill2 = choose_rand_skill(chosen_survivor, 2)
                sMenu.value.choice_loadout.family_choice_index.skill3 = choose_rand_skill(chosen_survivor, 3)
            end
        end
        if sMenu.value.choice == random_id then -- Check if random character is selected
            choice_set = 0
            set_char(sMenu, 0)
            end_choice = choose_rand_char() * params['animation_delay']
        end
    end
end)

-- Roll character on startup if enabled
gm.pre_script_hook(gm.constants.PlayerLobbyChoiceInfo, function(self, other, result, args)
    if not params['enabled'] then return end
    choice_set = 0
    end_choice = choose_rand_char() * params['animation_delay']
end)
