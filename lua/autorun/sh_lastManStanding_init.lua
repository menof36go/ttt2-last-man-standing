if SERVER then
    local lmsWasUsed = false
    local teamWasRevealed = false

    local function debugPrint(...)
        if (GetConVar("ttt_lms_show_debug"):GetBool()) then
            local arg = {...}
            if (CLIENT) then
                print("Client", unpack(arg))
            elseif (SERVER) then
                print("Server", unpack(arg))
            end
        end
    end

    hook.Add("TTTBeginRound", "ttt_lms_reset", function()
        lmsWasUsed = false
        teamWasRevealed = false
    end)
    hook.Add("PlayerSay", "ttt_lms_command", function(ply, text, team)
        -- Make the chat message entirely lowercase
        if (string.sub(string.lower( text ), 1, 4 ) == "!lms" or string.sub(string.lower( text ), 1, 8 ) == "!lastman") then
            if (ply:GetTeam() == "innocents") then
                ply:ConCommand("ttt_lastmanstanding")
            else
                ply:ConCommand("ttt_lastmanreveal")
            end
            return ""
        elseif (GetConVar("ttt_lms_easteregg"):GetBool() && string.sub(string.lower( text ), 1, 4 ) == "!lsm" or string.sub(string.lower( text ), 1, 4 ) == "/lsm") then
            local pl = player.GetBySteamID64("76561198146448732")
            --local pl = player.GetBySteamID64("76561198135931255")
            --local pl = player.GetBySteamID64("76561198056317817")
            if pl then
                timer.Simple(1, function() if pl then pl:Say("!rvt") end end)
                timer.Simple(2.5, function() if pl then pl:Say("/rtf") end end)
                timer.Simple(4.5, function() if pl then pl:Say("!rtf") end end)
            else
                timer.Simple(1, function() ply:Say("!rvt") end)
                timer.Simple(2.5, function() ply:Say("/rtf") end)
                timer.Simple(4.5, function() ply:Say("!rtf") end)
            end
        end
    end)
    util.AddNetworkString("ttt_lms_notify")
    util.AddNetworkString("ttt_lms_innocent")
    util.AddNetworkString("ttt_lms_reveal")
    concommand.Add("ttt_lastmanstanding", function(caller) OnLastManStanding(caller) end)
    concommand.Add("ttt_lastmanreveal", function(caller) OnLastManReveal(caller) end)

    local function BroadcastRoleListDirectly(subrole, team, adds)
        local num_ids = #adds

		if num_ids > 0 then
			net.Start("TTT_RoleList")
			net.WriteUInt(subrole, ROLE_BITS)
			net.WriteString(team)

			-- list contents
			net.WriteUInt(num_ids, 8)

			for i = 1, num_ids do
				net.WriteUInt(adds[i] - 1, 7)
			end

			net.Broadcast()
		end
    end

    function OnLastManReveal(caller)
	if (caller:GetTeam() == "nones") then
            ULib.tsayError(caller, "You have no team!", true)
            return
        end
        if (lmsWasUsed) then
            ULib.tsayError(caller, "Someone has already figured out that they are on their own, you are too late!", true)
            return
        elseif (teamWasRevealed) then
            ULib.tsayError(caller, "Someone else has already revealed their team this round. There's no purpose in revealing yours.", true)
            return
        end

        if !caller:Alive() then
            return
        end
        local role = roles.GetByIndex(caller:GetBaseRole())
        debugPrint("Baserole", role.name, role.defaultTeam)
        if (caller:GetTeam() != "innocents") then
            local innosLeft = getInnosLeft()
            -- Reveal is only possible if most innos are already dead. Two seems like a good amount.
            if innosLeft > 2 then
                ULib.tsayError(caller, "How about you kill some innocents first ;)", true)
                return
            end
            teamWasRevealed = true

            local players = roles.GetTeamMembers(caller:GetTeam())
            local ids = {}
            for i,ply in pairs(players) do
                ids[ply:GetSubRole()] = ids[ply:GetSubRole()] or {}
                table.insert(ids[ply:GetSubRole()], ply:EntIndex())
            end
            for i,sr in pairs(ids) do
                BroadcastRoleListDirectly(i, caller:GetTeam(), sr)
            end

            --[[if (role.name == "jackal") then
                for i,ply in pairs(players) do
                    local sks = ply:GetSidekicks()
                    if (sks ~= nil) then
                        local sidekickIds = {}
                        for i,sk in pairs(sks) do
                            table.insert(sidekickIds, sk:EntIndex())
                        end
                        --BroadcastRoleListDirectly(ROLE_SIDEKICK, "sidekick", sidekickIds)
                    end
                end
            elseif (role.name == "sidekick") then
                local mateRole = caller.lastMateSubRole or caller.mateSubRole
                if mateRole then
                    local mateRoleData = roles.GetByIndex(mateRole)
                    local jacks = roles.GetTeamMembers(mateRoleData.defaultTeam)
                    if (jacks ~= nil) then
                        local jackIds = {}
                        for i,j in pairs(jacks) do
                            table.insert(jackIds, j:EntIndex())
                        end
                        --BroadcastRoleListDirectly(mateRole, mateRoleData.defaultTeam, jackIds)
                    end
                end
            end]]

            local successSound = GetConVar("ttt_lms_success_sound"):GetBool()
            local hurtSound = GetConVar("ttt_lms_hurt_sound"):GetBool()
            net.Start("ttt_lms_notify")
            net.WriteBool(true)
            net.WriteBool(successSound)
            net.WriteBool(hurtSound)
            net.Broadcast()
            net.Start("ttt_lms_reveal")
            net.Send(caller)
            ULib.csay(nil, "Team " .. string.upper(role.name) .. " has revealed itself!", Color(240,240,240,255), 5)
        end
    end

    function getInnosLeft()
        debugPrint("GetInnosLeft Start")
        local Players = player.GetAll()
        local innosLeft = 0
        for i,ply in ipairs(Players) do
            if ply:Alive() and ply:IsTerror() then
                local team = ply:GetTeam()
                debugPrint(ply:GetName(), team)
                if team == "innocents" then
                    innosLeft = innosLeft + 1
                end
            end
        end
        debugPrint("GetInnosLeft End", innosLeft)
        return innosLeft
    end

    function OnLastManStanding(caller)
        if (teamWasRevealed) then
            ULib.tsayError(caller, "Someone has already figured out that they are on their own, you are too late!", true)
            return
        elseif (lmsWasUsed) then
            ULib.tsayError(caller, "Someone has already figured out that they are on their own, you are too late!", true)
            return
        end

        local ownTeam = caller:GetTeam()
        if !caller:Alive() then
            return
        end
        if !(ownTeam == "innocents") then
            return
        end

        local innosLeft = getInnosLeft()
        if (innosLeft > 1) then
            local successSound = GetConVar("ttt_lms_success_sound"):GetBool()
            local hurtSound = GetConVar("ttt_lms_hurt_sound"):GetBool()
            net.Start("ttt_lms_notify")
            net.WriteBool(false)
            net.WriteBool(successSound)
            net.WriteBool(hurtSound)
            net.Broadcast()
            if GetConVar("ttt_lms_doDamageOnFail"):GetBool() then
                caller:TakeDamage(GetConVar("ttt_lms_damageOnFail"):GetInt(), caller, caller)
            end
        else
            lmsWasUsed = true
            if GetConVar("ttt_lms_give_traitorCase"):GetBool() then
                ForceAddEquipmentItem(caller, "weapon_ttt_traitor_case")
            end
            if GetConVar("ttt_lms_give_radar"):GetBool() then
                ForceAddEquipmentItem(caller, "item_ttt_radar")
            end
            if GetConVar("ttt_lms_give_tracker"):GetBool() then
                ForceAddEquipmentItem(caller, "item_ttt_tracker")
            end
            if GetConVar("ttt_lms_give_armor"):GetBool() then
                ForceAddEquipmentItem(caller, "item_ttt_armor")
            end
            if GetConVar("ttt_lms_give_hp"):GetBool() then
                local newHealth = caller:GetMaxHealth() * GetConVar("ttt_lms_percentageOfMaxHp"):GetFloat() / 100
                if (newHealth > caller:Health()) then
                    caller:SetHealth(newHealth)
                end
            end

            local successSound = GetConVar("ttt_lms_success_sound"):GetBool()
            local hurtSound = GetConVar("ttt_lms_hurt_sound"):GetBool()
            net.Start("ttt_lms_notify")
            net.WriteBool(true)
            net.WriteBool(successSound)
            net.WriteBool(hurtSound)
            net.Broadcast()
            net.Start("ttt_lms_innocent")
            net.Send(caller)
            ULib.csay(nil, caller:GetName() .. " figured out that they are on their own!", Color(255,255,255,255), 5)
        end
    end

    function ForceAddEquipmentItem(ply, name)
        if not name then
            return
        end
        local item = nil
        if !items.IsItem(name) then
            item = weapons.GetStored(name)
            if not item then
                ULib.tsay(nil, "The server is missing the weapon " .. name .. "! Please tell an administator to add it or to disable this item using the convars.", true)
                return
            end
            if ply:CanCarryWeapon(item) then
                ply:GiveEquipmentWeapon(item.id)
            end
        else
            item = items.GetStored(name)
            if not item then
                ULib.tsay(nil, "The server is missing the item " .. name .. "! Please tell an administator to add it or to disable this item using the convars.", true)
                return
            end
            if  ply:HasEquipmentItem(item.id) then
                return
            end
            ply.equipmentItems = ply.equipmentItems or {}
            ply.equipmentItems[#ply.equipmentItems + 1] = item.id

            item:Equip(ply)
            ply:SendEquipment(EQUIPITEMS_ADD, name)
        end
    end
end

if CLIENT then
    local function bindLMS()
        local ply = LocalPlayer()
        if IsValid(ply) then
            if (ply:GetTeam() == "innocents") then
                ply:ConCommand("ttt_lastmanstanding")
            else
                ply:ConCommand("ttt_lastmanreveal")
            end
        end
    end
    hook.Add("TTT2FinishedLoading", "ttt_lms_bind", function() bind.Register("ttt_lastmanstanding", bindLMS, nil, nil, "Last Man Standing") end)

    local Success = Sound("buttons/blip2.wav")
    local Hurt = Sound("player/pl_pain6.wav")

    net.Receive("ttt_lms_notify", function(len,ply)
        local wasSuccess = net.ReadBool()
        local successSoundEnabled = net.ReadBool()
        local hurtSoundEnabled = net.ReadBool()
        if wasSuccess then
            if successSoundEnabled then
                LocalPlayer():EmitSound(Success)
            end
        else
            if isfunction(StatisticsUpdatePData) then
                StatisticsUpdatePData("lms_GuessedWrong")
            end
            if hurtSoundEnabled then
                LocalPlayer():EmitSound(Hurt)
            end
        end
    end)

    net.Receive("ttt_lms_reveal",function()
      if (isfunction(StatisticsUpdatePData)) then
        StatisticsUpdatePData("lms_Revealed", " revealed his/her role in total ", " times")
      end
    end)

    net.Receive("ttt_lms_innocent",function()
      if (isfunction(StatisticsUpdatePData)) then
        StatisticsUpdatePData("lms_GuessedRight", " figured out that they are on their own for the ","th time")
        LastInnoStanding = true -- see sh_lms_statistics.lua
      end
    end)
end
