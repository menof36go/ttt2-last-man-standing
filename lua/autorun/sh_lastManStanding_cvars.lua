if SERVER then
	AddCSLuaFile()
	if file.Exists("scripts/sh_convarutil.lua", "LUA") then
		AddCSLuaFile("scripts/sh_convarutil.lua")
		print("[INFO][Last Man Standing] Using the utility plugin to handle convars instead of the local version")
	else
		AddCSLuaFile("scripts/sh_convarutil_local.lua")
		print("[INFO][Last Man Standing] Using the local version to handle convars instead of the utility plugin")
	end
end

if file.Exists("scripts/sh_convarutil.lua", "LUA") then
	include("scripts/sh_convarutil.lua")
else
	include("scripts/sh_convarutil_local.lua")
end

-- Must run before hook.Add
local cg = ConvarGroup("LastManStanding", "Last Man Standing")
Convar(cg, true, "ttt_lms_easteregg", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Enable the secret easter egg", "bool")
Convar(cg, true, "ttt_lms_doDamageOnFail", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Innocent gets damage if they are not the last man standing", "bool")
Convar(cg, true, "ttt_lms_damageOnFail", 50, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Damage the innocent gets if they are not the last man standing", "int", 1, 400)
Convar(cg, true, "ttt_lms_give_traitorCase", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Reward the innocent by giving them a traitor case", "bool")
Convar(cg, true, "ttt_lms_give_radar", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Reward the innocent by giving them a radar", "bool")
Convar(cg, true, "ttt_lms_give_tracker", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Reward the innocent by giving them a tracker", "bool")
Convar(cg, true, "ttt_lms_give_armor", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Reward the innocent by giving them armor", "bool")
Convar(cg, true, "ttt_lms_give_hp", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Reward the innocent by healing them", "bool")
Convar(cg, true, "ttt_lms_percentageOfMaxHp", 100, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Percentage of max health the innocent will be set to have", "float", 0.1, 200, 1)
Convar(cg, true, "ttt_lms_success_sound", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Enable the success sound", "bool")
Convar(cg, true, "ttt_lms_hurt_sound", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Enable the hurt sound", "bool")
Convar(cg, true, "ttt_lms_show_debug", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Show debug information", "bool")
--