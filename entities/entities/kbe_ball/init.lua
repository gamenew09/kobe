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

function ENT:Use( activator, caller )
    local velAng = activator:EyeAngles():Forward()
	self:GetPhysicsObject():SetVelocity( velAng * self.VelocityPush )
	activator:ViewPunch( Angle( math.random( -10, 10 ), math.random( -10, 10 ), 0 ) )
end

function ENT:Think()
    -- We don't need to think, we are just a prop after all!
	if self:GetPhysicsObject():IsPenetrating() then
		print("OH GOD WE NEED RESPAWN, GET LAST VALID POINT AND TELEPORT")
		if self:GetPhysicsObject():IsPenetrating() then
			self:GetPhysicsObject():SetPos(self.Entity:GetTable()["lastPos"])
			local maxadd = 100
			local i = 0
			while self:GetPhysicsObject():IsPenetrating() and i < maxadd do
				self:GetPhysicsObject():SetPos(self.Entity:GetTable()["lastPos"] + Vector(0, i, 0))
				i = i + 1
			end
			self.Entity:EmitSound("AlyxEMP.Discharge")
		end
	else
		self.Entity:SetVar("lastPos", self:GetPhysicsObject():GetPos())
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS -- We want the glow to be shown always, this should work.
end