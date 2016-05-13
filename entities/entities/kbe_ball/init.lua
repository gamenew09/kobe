AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')
 
function ENT:Initialize()
 
	self:SetModel( "models/props_phx/misc/soccerball.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

ENT.VelocityPush = 750
ENT.MaxTeleportTries = 50

function ENT:Use( activator, caller )
    local velAng = activator:EyeAngles():Forward()
	self:GetPhysicsObject():SetVelocity( velAng * self.VelocityPush )
	activator:ViewPunch( Angle( math.random( -5, 5 ), math.random( -5, 5 ), 0 ) )
end

function ENT:PhysicsCollide( data, phys )
	if ( data.Speed > 50 and data.Speed < 250 ) then 
		self:EmitSound( Sound( "Rubber_Tire.ImpactSoft" ) ) 
	elseif data.Speed >= 250 then	
		self:EmitSound( Sound( "Rubber_Tire.ImpactHard" ) ) 
	end
end

function ENT:Think()
    -- We don't need to think, we are just a prop after all!
	if self:GetPhysicsObject():IsPenetrating() then
		self:GetPhysicsObject():SetPos(self.Entity:GetTable()["lastPos"])
		local i = 0
		while self:GetPhysicsObject():IsPenetrating() and i < self.MaxTeleportTries do
			self:GetPhysicsObject():SetPos(self.Entity:GetTable()["lastPos"] + Vector(0, i, 0))
			i = i + 1
		end
		if i == self.MaxTeleportTries - 1 then
			GAMEMODE:TeleportBallToCenter()
		end
		self.Entity:EmitSound("AlyxEMP.Discharge")
	else
		self.Entity:SetVar("lastPos", self:GetPhysicsObject():GetPos())
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS -- We want the glow to be shown always.
end