-- RandomCharacter v1.0.0
-- SmoothSpatula
Helper = require("./helper")

-- Parameters
local tick_delay = 8
local max_survivor_id = 15

-- ========== ImGui ==========

local roll_character_enabled = true
gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Enable Character Roll", roll_character_enabled)
    if clicked then
        roll_character_enabled = new_value
    end
end)

gui.add_to_menu_bar(function()
    local new_value, isChanged = ImGui.InputInt("Set animation delay", tick_delay, 1, 2, 0)
    if isChanged then
        tick_delay = new_value
    end
end)

-- ========== Utils ==========

-- selects the character with the specified id
function set_char(sMenu, id)
    if Helper.does_instance_exist(sMenu) then
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

-- ========== Main ==========

local choice_set = 0
local end_choice = 0
-- plays the roll animation
gm.pre_script_hook(gm.constants.__input_system_tick, function()
    if not roll_character_enabled then return end
    local sMenu = Helper.find_active_instance(gm.constants.oSelectMenu)
    if Helper.does_instance_exist(sMenu) and choice_set <= end_choice then
        choice_set = choice_set + 1
        if choice_set%tick_delay == 0 then
            set_char(sMenu, choice_set/tick_delay)
        end
    end
end)

-- resets the animation and random character on entering lobby
gm.pre_script_hook(gm.constants.PlayerLobbyChoiceInfo, function(self, other, result, args)
    if not roll_character_enabled then return end
    choice_set = 0
    end_choice = choose_rand_char() * tick_delay
end)






