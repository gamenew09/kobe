AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

AddCSLuaFile("glogs.lua")

AddCSLuaFile("roundmanager/roundmanager.lua")
AddCSLuaFile("kbpowerup.lua") 

include( "shared.lua" )

local kbe_allowpowerups = CreateConVar("kbe_allowpowerups", "1", { FCVAR_NOTIFY, FCVAR_REPLICATED }, "Enables or disables powerups in KOBE.")
local kbe_falldamage = CreateConVar("kbe_falldamage", "1", { FCVAR_NOTIFY, FCVAR_REPLICATED }, "Enables or disables fall damage in KOBE, usefull for maps that have durastic height changes that require to take damage.")
local kbe_poweruprespawn = CreateConVar("kbe_poweruprespawn", "5", { FCVAR_NOTIFY, FCVAR_REPLICATED }, "How much time in seconds, before another powerup respawns.")


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

--[[
hook.Add("InitPostEntity", "KOBE_PostEnt", function ()
	if #ents.FindByClass( "kbe_ballspawn" ) == 0 then
		glogs.Write("There are no ball spawns!!! This map will not work with KOBE!!!")
	end
	if #ents.FindByClass( "kbe_poweruprespawn" ) == 0 then
		glogs.Write("There are no powerup spawns!!! This map will not work with KOBE!!!")
	end
end)
--]]

GM.SpawnPowerup = {}

function GM:RespawnPowerupOnTime( ind )
	if not GAMEMODE.SpawnPowerup[ind] then
		timer.Simple(kbe_poweruprespawn.GetInt(), function ()
			local spawn = GAMEMODE.PowerupSpawns[math.random(1, #GAMEMODE.PowerupSpawns)]
			
			GAMEMODE.SpawnPowerup[ind] = SpawnRandomPowerup(spawn:GetPos())
			GAMEMODE.SpawnPowerup[ind]:SetVar("PowerupSpawnID", ind)
		end)
	end
end

function GM:CauseRespawnPowerup( ent )
	if GAMEMODE.SpawnPowerup[ent:GetTable()["PowerupSpawnID"]]:EntIndex() == ent:EntIndex() then
		GAMEMODE.SpawnPowerup[ent:GetTable()["PowerupSpawnID"]] = nil
		GAMEMODE:RespawnPowerupOnTime( ent:GetTable()["PowerupSpawnID"] )
	end
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
	
	self.BaseClass.PlayerSpawn( self, ply )
end

function GM:Think()
	--self.BaseClass.Think( self )
	if not ballEnt then
		ballEnt = SpawnBall(GetBallSpawn())
	end
end

function GM:PlayerLoadout( ply )
	self.BaseClass.PlayerLoadout( self, ply )
	ply:Give("weapon_crowbar")
end