-- Adapted this from cginc-Ghost_Survivor
-- This serves as the display for the "random character button". it does not function as an actual character
-- Since it is never chosen, it shouldnt appear on the stats, but it might still cause issues in some other mod

log.info("Loading ".._ENV["!guid"]..".") --logging our mod being loaded.
mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true) --what the mod knows to use.

local PATH = _ENV["!plugins_mod_folder_path"]--This variable is just the path where our mod is
local Random = "Random"--the Namespace

local initialise = function()--We need this to make sure the game loads before our mod does.

--#region Assets
    --helper function for getting sprite paths concisely, just saves having to write long lines like:
    --Resources.sprite_load(Namespace,"Animation",path.combine(SPRITE_PATH,"Animation.png"),Frames,X,Y)
    --Its usage is load_sprite("Animation","Animation.png",Frames,X,Y)
    local load_sprite = function (id, filename, frames, orig_x, orig_y, speed, left, top, right, bottom)
        local sprite_path = path.combine(PATH, "Sprites",  filename)
        return Resources.sprite_load(Random, id, sprite_path, frames, orig_x, orig_y, speed, left, top, right, bottom)
    end
    --#region Sprites
        local spr_skills = load_sprite("no_skill", "noSkill.png", 5, 0, 0) 
        local spr_portrait = load_sprite("random_portrait", "portrait.jpg",1)
        local spr_loadout = load_sprite("random_loadout", "loadout.jpg", 1, 28, 0) 
    --#endregion
--#endregion

--#region Survivor setup
    local randomCharacter = Survivor.new(Random, "RandomCharacter")

    randomCharacter:set_primary_color(Color.from_rgb(180, 32, 46)) --This is used for a variety of things in game
    randomCharacter.sprite_loadout = spr_loadout
    randomCharacter.sprite_portrait = spr_portrait
    randomCharacter.sprite_portrait_small = spr_portrait
    randomCharacter.sprite_title = spr_portrait
    randomCharacter.sprite_idle = spr_portrait

--#region Initial skill setup (icons and stats)
    randomCharacter:get_primary(1):set_skill_icon(spr_skills, 0)
    randomCharacter:get_secondary(1):set_skill_icon(spr_skills, 0)
    randomCharacter:get_utility(1):set_skill_icon(spr_skills, 0)
--#endregion

end
Initialize(initialise)