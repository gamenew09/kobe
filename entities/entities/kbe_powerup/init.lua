AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')
 
function ENT:Initialize()
 
	self:SetModel( "models/pickups/pickup_powerup_agility.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_NONE )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:PhysicsCollide( data, physobj )
	local entity = data.HitEntity
	
	if entity:IsPlayer() then
		GAMEMODE:AddToRespawn(self.Entity)
		kbpowerup.CallTouch(self.Entity, entity)
	end
end

function ENT:Use( activator, caller )
    return 
end

function ENT:Think()
    -- We don't need to think, we are just a prop after all!
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS -- We want the glow to be shown always, this should work.
end