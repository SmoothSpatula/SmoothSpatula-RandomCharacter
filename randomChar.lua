-- -- Adapted this from cginc-Ghost_Survivor
-- -- This serves as the display for the "random character button". it does not function as an actual character
-- -- Since it is never chosen, it shouldnt appear on the stats, but it might still cause issues in some other mod

-- log.info("Loading ".._ENV["!guid"]..".") --logging our mod being loaded.
-- --mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true) --what the mod knows to use.

-- local RAPI = mods["ReturnsAPI-ReturnsAPI"].auto{
--     namespace = "random",
--     mp = true
-- }

-- local PATH = _ENV["!plugins_mod_folder_path"]--This variable is just the path where our mod is
-- local NAMESPACE = "random"--the Namespace

-- local initialise = function()--We need this to make sure the game loads before our mod does.
--     local random = RAPI.Survivor.new("Random")

--     -- local load_sprite = function (id, filename, frames, orig_x, orig_y, speed, left, top, right, bottom)
--     --     local sprite_path = path.combine(PATH, "Sprites",  filename)
--     --     return Resources.sprite_load(Random, id, sprite_path, frames, orig_x, orig_y, speed, left, top, right, bottom)
--     -- end
--     --     local spr_skills = load_sprite("no_skill", "noSkill.png", 5, 0, 0) 
--     --     local spr_portrait = load_sprite("random_portrait", "portrait.png",1)
--     --     local spr_loadout = load_sprite("random_loadout", "loadout.png", 1, 28, 0) 

-- --#region Survivor setup
--     --local randomCharacter = Survivor.new(Random, "RandomCharacter")

--     randomCharacter.primary_color = Color.from_rgb(8, 253, 142) --This is used for a variety of things in game
--     -- randomCharacter.sprite_loadout = spr_loadout
--     -- randomCharacter.sprite_portrait = spr_portrait
--     -- randomCharacter.sprite_portrait_small = spr_portrait
--     -- randomCharacter.sprite_title = spr_portrait
--     -- randomCharacter.sprite_idle = spr_portrait

-- --#region Initial skill setup (icons and stats)
--     --randomCharacter:get_primary(1):set_skill_icon(spr_skills, 0)
--     --randomCharacter:get_secondary(1):set_skill_icon(spr_skills, 0)
--     --randomCharacter:get_utility(1):set_skill_icon(spr_skills, 0)
-- --#endregion

-- end
-- Initialize.add(initialise)


-- -- Animation gm.ui_set_element_value("main_page_scroll", i%300) 


-- randomCharacter
-- good morning morioh-cho
-- i tried leaving comments here and there to clear some things up, plus some old comments from copying dixie's tutorial (skull emoji)
-- if you have questions let me know so i can try to expand my comments more

log.info("Loading ".._ENV["!guid"]..".")
local envy = mods["LuaENVY-ENVY"]
envy.auto()
mods["ReturnsAPI-ReturnsAPI"].auto{
    namespace = "random",
    mp = true
}

local PATH = _ENV["!plugins_mod_folder_path"]
local NAMESPACE = "SmoothSpatula"

-- ========== Main ==========

local initialize = function()
    hotload = true
    local randomCharacter = Survivor.new("RandomCharacter")

    --all the upgrades are hidden items
        --Callback.add(gravsuit.on_removed, function(actor, stack)
        --    actor.image_blend = Color.WHITE
        --end)

    -- Utility function for getting paths concisely
    local rapi_sprite = function(identifier, filename, image_number, x_origin, y_origin) 
        local sprite_path = path.combine(PATH, "Sprites",  filename)
        return Sprite.new(identifier, sprite_path, image_number, x_origin, y_origin)
    end
    local rapi_sound = function(id, filename)
        local sound_path = path.combine(PATH, "Sounds", filename)
        return Sound.new(id, sound_path)
    end
    
    -- Load the common survivor sprites into a table
    local spr_skills = rapi_sprite("no_skill", "noSkill.png", 5, 0, 0) 
    local spr_portrait = rapi_sprite("random_portrait", "portrait.png",1, 0, 0)
    local spr_loadout = rapi_sprite("random_loadout", "loadout.png", 1, 28, 0) 

    
    -- Colour for the character's skill names on character select
    randomCharacter.primary_color = Color.from_rgb(8, 253, 142)

    -- Assign sprites to various survivor fields
    randomCharacter.sprite_loadout = spr_loadout
    randomCharacter.sprite_portrait = spr_portrait
    randomCharacter.sprite_portrait_small = spr_portrait
    randomCharacter.sprite_portrait_palette = spr_portrait
    randomCharacter.sprite_palette = spr_portrait

end
Initialize.add(initialize)
