-- RandomCharacter v1.1.1
-- SmoothSpatula

mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true)
require("randomChar.lua") -- load custom char 

-- ========== Parameters ==========

local params = {
    enabled  = false,
    randomize_skills = true,
    randomize_skin = true,
    overwrite_locked_skills = false,
    animation_delay = 8,
    randomize_artifacts = false,
    artifacts_nb = 1
}

mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.tomlfuncs then 
    Toml = v
    params = Toml.config_update(_ENV["!guid"], params)
    Toml.save_cfg(_ENV["!guid"], params)
end end end)

-- ========== ImGui ==========

local options = {"enabled", "randomize_skills", "randomize_skin","overwrite_locked_skills" , "randomize_artifacts"}
local options_names = {"Roll character on startup", "Randomize skills", "Randomize Skin", "You can get locked skills", "Randomize Artifacts" }

for i=1, 4 do  -- change back to 5 after
    gui.add_to_menu_bar(function()
        local new_value, clicked = ImGui.Checkbox(options_names[i], params[options[i]])
        if clicked then
            params[options[i]] = new_value
            Toml.save_cfg(_ENV["!guid"], params)
        end
    end)
end

-- gui.add_to_menu_bar(function()
--     if params['randomize_artifacts'] then
--         local new_value, isChanged = ImGui.InputInt("Number or Artifacts ", params['artifacts_nb'], 1, 2, 0)
--         if isChanged then
--             if new_value >= 1 then
--                 params['artifacts_nb'] = new_value
--             else
--                 params['artifacts_nb'] = 1
--             end
--             Toml.save_cfg(_ENV["!guid"], params)
--         end
--     end
-- end)

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

local max_survivor_id = 15

-- selects the character with the specified id
function set_char(sMenu, id)
    gm.call(sMenu.value.set_choice.script_name, sMenu.value, sMenu.value, id)
end

function set_artifact(id)
    gm.call("gml_Script_anon_gml_Object_oSelectMenu_Create_0_200742116_gml_Object_oSelectMenu_Create_0", id)
end
-- the random selection is done by generating until a correct value is found

-- selects a random character that is unlocked and not hidden with id < max_survivor_id
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
            --is_hidden = survivor[33]
        end
    until survivor and is_unlocked --and not is_hidden
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

-- selects n artifacts
function choose_rand_artifacts()


end

-- ========== Main ==========

local random_id = 0 -- id for the dice survivor
local anim_frame = 0 -- current animation frame
local anim_end = 0 -- end animation frame
local is_animating = "no"

local artifacts = {}
local artifacts_multi = {} -- check using oServer Instance
local arti_nb = 14

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
    -- if it is not the last survivor in the display_list, make it
    if random_id < size-1 then
        gm.ds_list_delete(sdl, random_id)
        gm.ds_list_add(sdl, random_id)
    end
    max_survivor_id = size - 2

    -- get the artifact save data (there has to be a better way to do this honestly but it works ¯\_(ツ)_/¯ )
    -- local save = gm.variable_global_get("save_file")
    -- local i = 0
    -- for _, v in pairs(gm.struct_get_names(save.lobby_votes)) do
    --     print(v, save.lobby_votes[v])
    --     local a, nsp, name = string.match(v, "(%w+):(%w+):(%w+)")
    --     if nsp and name and Artifact.find(nsp, name) then
    --         gm.artifact_get_lobby_rule_key(i)
    --         artifacts[i] = save.lobby_votes[gm.artifact_get_lobby_rule_key(i)]
    --         artifacts_multi[i] = save.lobby_votes_multi[gm.artifact_get_lobby_rule_key(i)]
    --         i = i + 1
    --     end
    -- end
    -- arti_nb = i
    -- for i, n in ipairs(artifacts) do
    --     print(i, n) 
    -- end
end

Initialize(init, true)
-- plays the roll animation
gm.pre_script_hook(gm.constants._ui_draw_button, function()
    local sMenu = Instance.find(gm.constants.oSelectMenu) -- find the selectMenu instance
    if not sMenu:exists() then return end -- check if we are in the selectMenu

    if is_animating=="character" then -- animation running
        anim_frame = anim_frame + 1
        if anim_frame%params['animation_delay'] == 0 then -- change selection
            if anim_frame == random_id * params['animation_delay'] then -- skip random char
                anim_frame = anim_frame + params['animation_delay'] 
            end
            set_char(sMenu, anim_frame/params['animation_delay'])
        elseif anim_frame > anim_end then
            is_animating = "no"
            local chosen_survivor = gm.variable_global_get("class_survivor")[anim_end/params['animation_delay']+1]
            if params['randomize_skin'] then 
                local skin = choose_rand_skin(chosen_survivor)
                sMenu.choice_loadout.family_choice_index.skin = skin 
            end
            if params['randomize_skills'] then
                for i=0, 3 do sMenu.value.choice_loadout.family_choice_index["skill"..tostring(i)] = choose_rand_skill(chosen_survivor, i) end
            end
        end
    end
    if sMenu.value.choice == random_id and is_animating == "no" then -- Check if random character is selected
        anim_frame = 0
        anim_end = choose_rand_char() * params['animation_delay'] -- roll end char
        set_char(sMenu, 0) -- start at first char
        is_animating = "character"
    end
end)

-- Roll character on startup if enabled
gm.pre_script_hook(gm.constants.PlayerLobbyChoiceInfo, function(self, other, result, args)
    if not params['enabled'] then return end
    anim_end = choose_rand_char() * params['animation_delay']
    anim_frame = 0
    is_animating = "character"
end)

-- gm.pre_script_hook(gm.constants["anon_gml_Object_oSelectMenu_Create_0_200742116_gml_Object_oSelectMenu_Create_0"], function(self, other, result, args)
--     if self ~= nil then -- no context when force clicking with gm.call
--         local oServer = Instance.find(gm.constants.oServer)
--         if oServer and oServer:exists() then
--             artifacts_multi[args[1].value] = (1 - (artifacts_multi[args[1].value] or 0))%3 -- in  multiplayer, this has 3 states?
--         else
--             artifacts[args[1].value] = 1 - (artifacts[args[1].value] or 0)
--         end
--     end
-- end)