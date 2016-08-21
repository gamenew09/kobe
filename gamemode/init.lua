AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

AddCSLuaFile("glogs.lua")

AddCSLuaFile("roundmanager/roundmanager.lua")
AddCSLuaFile("kbpowerup.lua") 

include( "shared.lua" )

util.AddNetworkString("KOBE_CleanUpMap")
util.AddNetworkString("KOBE_PlayerPickup")
util.AddNetworkString("KOBE_PowerupPickupFailed")

local kbe_allowpowerups = CreateConVar("kbe_allowpowerups", "1", { FCVAR_NOTIFY, FCVAR_REPLICATED }, "Enables or disables powerups in KOBE.")
local kbe_falldamage = CreateConVar("kbe_falldamage", "1", { FCVAR_NOTIFY, FCVAR_REPLICATED }, "Enables or disables fall damage in KOBE, usefull for maps that have durastic height changes that require to take damage.")
local kbe_poweruprespawn = CreateConVar("kbe_poweruprespawn", "5", { FCVAR_NOTIFY, FCVAR_REPLICATED }, "How much time in seconds, before another powerup respawns.")
local kbe_timelimit = CreateConVar("kbe_timelimit", "200", { FCVAR_NOTIFY, FCVAR_REPLICATED }, "How long, in seconds, are the rounds.")

local kbe_redplayermodel = CreateConVar("kbe_redplayermodel", "models/player/phoenix.mdl", { FCVAR_NOTIFY, FCVAR_REPLICATED }, "The model red team uses.")
local kbe_blueplayermodel = CreateConVar("kbe_blueplayermodel", "models/player/phoenix.mdl", { FCVAR_NOTIFY, FCVAR_REPLICATED }, "The model blue team uses.")

function SpawnRandomPowerup(position)
	if GAMEMODE.InitPostEntityDone then
		local ent = ents.Create("kbe_powerup")
		ent:SetPos(position)
		
		ent:Spawn()
		return ent
	end
end

function SpawnBall(position)
	if GAMEMODE.InitPostEntityDone then
		local ent = ents.Create("kbe_ball")
		ent:SetPos(position)
		
		ent:Spawn()
		return ent
	end
end

local ballEnt = nil

local function GetBallSpawn()
	return ents.FindByClass( "kbe_ballspawn" )[1]:GetPos()
end

hook.Add("InitPostEntity", "KOBE_PostEnt", function ()
	if #ents.FindByClass( "kbe_ballspawn" ) == 0 then
		glogs.Write("There are no ball spawns!!! This map will not work with KOBE!!!")
	end
	if #ents.FindByClass( "kbe_powerupspawn" ) == 0 then
		glogs.Write("There are no powerup spawns!!! This map will not work with KOBE!!!")
	end
	
	GAMEMODE.PowerupSpawns = ents.FindByClass("kbe_powerupspawn")
	for i,v in pairs(GAMEMODE.PowerupSpawns) do
		v:SetVar("SpawnID", i)
	end
end)

GM.SpawnPowerup = {}

--[[
function GM:RespawnPowerupOnTime( ind )
	if not GAMEMODE.SpawnPowerup[ind] then
		timer.Simple(kbe_poweruprespawn:GetInt(), function ()
			local spawn = GAMEMODE.PowerupSpawns[math.random(1, #GAMEMODE.PowerupSpawns)]
			
			GAMEMODE.SpawnPowerup[ind] = SpawnRandomPowerup(spawn:GetPos())
			GAMEMODE.SpawnPowerup[ind]:SetNetworkedInt("PowerupSpawnID", ind)
		end)
	end
end

function GM:CauseRespawnPowerup( ent )
	if GAMEMODE.SpawnPowerup[ent:GetTable()["PowerupSpawnID"] ]:EntIndex() == ent:EntIndex() then
		glogs.Write("CauseRespawnPowerup ["..ent:EntIndex().."]")
		GAMEMODE.SpawnPowerup[ent:GetTable()["PowerupSpawnID"] ] = nil
		GAMEMODE:RespawnPowerupOnTime( ent:GetTable()["PowerupSpawnID"] )
	end
end
--]]

function GM:RespawnPowerupOnTime(spawnIndex, time)
	timer.Simple(time or kbe_poweruprespawn:GetInt(), function ()
		GAMEMODE:RespawnPowerup( spawnIndex )
	end)
end

function GM:RespawnPowerup( spawnIndex )
	local spawn
	if not spawnIndex then
		spawnIndex = math.random(1, #GAMEMODE.PowerupSpawns)
		spawn = GAMEMODE.PowerupSpawns[spawnIndex]
	else
		spawn = GAMEMODE.PowerupSpawns[spawnIndex]
		if not spawn then
			return -1
		end
	end
	local ent = SpawnRandomPowerup(spawn:GetPos())
	ent:SetVar("SpawnID", spawn:GetVar("SpawnID"))
	ent:SetVar("PowerupID", #GAMEMODE.SpawnPowerup + 1)
	
	if GAMEMODE.SpawnPowerup[spawnIndex] then
		GAMEMODE.SpawnPowerup[spawnIndex]:Remove()
	end
	
	GAMEMODE.SpawnPowerup[spawnIndex] = ent
	
	return #GAMEMODE.SpawnPowerup
end

function GM:EntityTakeDamage( target, dmginfo )
	if dmginfo:IsDamageType(DMG_CRUSH) then
		dmginfo:SetDamage( 0 )
	end
	if not kbe_falldamage:GetBool() then
		if dmginfo:IsFallDamage() then
			dmginfo:SetDamage( 0 )
		end
	end
end

-- Net Messages

function GM:PlayerSpawn( ply )
	if not roundmanager.InRound() then
		self:PlayerSpawnAsSpectator( ply )
		return
	end
	
	ply:SetTeam(team.BestAutoJoinTeam())
	
	self.BaseClass.PlayerSpawn( self, ply )
end

function GM:TeleportBallToCenter()
	if not ballEnt then
		return false
	end
	
	ballEnt:SetPos(GetBallSpawn())
	
	return true
end

GM.PlayerCarryingBall = nil

function GM:StartCarryBall( ply )
	if self.PlayerCarryingBall then return false end
	local shouldntCarry = hook.Call("StartCarryBall", nil, ply)
	if not shouldntCarry then
		self.PlayerCarryingBall = ply
		self.PlayerCarryingBall:SetNetworkedBool("CarryingBall", true)
		ballEnt:Remove()
		return true
	else
		return false
	end
end

function GM:StopCarryBall()
	if not self.PlayerCarryingBall then return false end
	local ply = self.PlayerCarryingBall
	self.PlayerCarryingBall:SetNetworkedBool("CarryingBall", false)
	self.PlayerCarryingBall = nil
	hook.Call("StopCarryBall", nil, ply)
end

function GM:PlayerSetModel( ply )
	if ply:Team() == TEAM_RED then
		ply:SetModel(kbe_redplayermodel:GetString())
	elseif ply:Team() == TEAM_BLUE then
		ply:SetModel(kbe_blueplayermodel:GetString())
	end
end

--[[
hook.Add("IntermissionOver", "KOBE_IntermissionOver_Hook_1", function ()
	
end)
--]]

function GM:Think()
	if not self.InIntermission then
		if not roundmanager.InRound() and #player.GetHumans() >= 1 then
			roundmanager.Start(kbe_timelimit:GetInt())
			self:ReloadPlayers()
			for _,v in pairs(GAMEMODE.PowerupSpawns) do
				self:RespawnPowerup(v:GetVar("SpawnID"))
			end
		end
		if roundmanager.InRound() then
			if not ballEnt or not ballEnt:IsValid() and not self.PlayerCarryingBall then
				ballEnt = SpawnBall(GetBallSpawn())
			end
		end
	end
end

function GM:PlayerLoadout( ply )
	self.BaseClass.PlayerLoadout( self, ply )
	ply:Give("weapon_kobehands")
end