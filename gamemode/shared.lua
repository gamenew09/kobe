GM.Name = "KOBE"
GM.Author = "Gamenew09"
GM.Email = "gamenew09@gmail.com"
GM.Website = "gamenew09.com"

include("glogs.lua")

include("roundmanager/roundmanager.lua")
include("kbpowerup.lua")

local multiplier = 3

GM.InitPostEntityDone = false

function GM:InitPostEntity()
	self.InitPostEntityDone = true
	self.BaseClass.InitPostEntity( self )
end

function GM:Initialize()
	kbpowerup.Add("Speed", "models/pickups/pickup_powerup_agility.mdl", function (ent, ply)
		local originalRun = ply:GetRunSpeed()
		local originalWalk = ply:GetWalkSpeed()
		local originalCrouch = ply:GetCrouchedWalkSpeed()
		ply:SetRunSpeed(originalRun * multiplier)
		ply:SetWalkSpeed(originalWalk * multiplier)
		ply:SetCrouchedWalkSpeed(originalCrouch * multiplier)
		
		timer.Simple(15, function ()
			ply:SetRunSpeed(originalRun)
			ply:SetWalkSpeed(originalWalk)
			ply:SetCrouchedWalkSpeed(originalCrouch)
		end)
	end)
	glogs.Write("Initialized")
	self.BaseClass.Initialize( self )
end

if SERVER then
	util.AddNetworkString("KOBE_IntermissionStart")
	util.AddNetworkString("KOBE_IntermissionEnd")

	kbe_intermissiontime = CreateConVar("kbe_intermissiontime", "5", { FCVAR_NOTIFY, FCVAR_REPLICATED }, "How long, in seconds, are the rounds.")
	function GM:ReloadPlayers()
		for i,v in pairs(player.GetAll()) do
			v:UnSpectate()
			v:Spawn()
			self:PlayerSpawn(v)
		end
	end
	
	function GM:AllPlayerSpectate()
		for i,v in pairs(player.GetAll()) do
			self:PlayerSpawnAsSpectator( v )
		end
	end
	
	function GM:PlayerSpawnAsSpectator( pl )

		pl:StripWeapons()
		
		if ( pl:Team() == TEAM_UNASSIGNED ) then
		
			pl:Spectate( OBS_MODE_FIXED )
			return
			
		end

		pl:SetTeam( TEAM_SPECTATOR )
		pl:Spectate( OBS_MODE_ROAMING )

	end
	
	GM.IntermissionStartTime = 0
	GM.InIntermission = false
	
	function GM:StartIntermission()
		self.InIntermission = true
		self.IntermissionStartTime = CurTime()
		hook.Call("IntermissionStart", nil)
		net.Start( "KOBE_IntermissionStart" )
			net.WriteFloat(self.IntermissionStartTime)
			net.WriteFloat(kbe_intermissiontime:GetInt())
		net.Broadcast()
		timer.Simple(kbe_intermissiontime:GetInt(), function ()
			self.InIntermission = false
			hook.Call("IntermissionOver", nil)
			net.Start( "KOBE_IntermissionEnd" )
			net.Broadcast()
		end)
	end
	
	function GM:GetIntermissionTime()
		return math.Round((IntermissionStartTime+kbe_intermissiontime:GetInt())-CurTime())
	end
end

function GM:GoalScore( goalEnt, ballEnt, teamNum )
	local shouldScore = hook.Call("GoalScore", nil, goalEnt, ballEnt, teamNum)
	if not shouldScore then
		if SERVER then
			roundmanager.End()
			ballEnt:Remove()
			ballEnt = nil
			self:AllPlayerSpectate()
			self:StartIntermission()
		end
	else
		glogs.Write("Ignoring Goal Score.")
	end
end

GM.NetMsgPrefix = "KOBE_" 

TEAM_RED = 2
TEAM_BLUE = 3

team.SetUp( TEAM_RED, "Red Team", Color( 255, 0, 0 ) )
team.SetUp( TEAM_BLUE, "Blue Team", Color( 0, 0, 255 ) )