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

function GM:GoalScore( goalEnt, ballEnt, teamNum )
	local shouldScore = hook.Call("GoalScore", nil, goalEnt, ballEnt, teamNum)
	if not shouldScore then
		
	else
		glogs.Write("Ignoring Goal Score.")
	end
end

GM.NetMsgPrefix = "KOBE_" 

TEAM_RED = 2
TEAM_BLUE = 3

team.SetUp( TEAM_RED, "Red Team", Color( 255, 0, 0 ) )
team.SetUp( TEAM_BLUE, "Blue Team", Color( 0, 0, 255 ) )