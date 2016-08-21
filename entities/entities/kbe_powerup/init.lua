AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')
 
function ENT:Initialize()
 
	--self:SetModel( "models/pickups/pickup_powerup_agility.mdl" )
	
	self:SetModel( kbpowerup.GetModelByName(self.PowerupName) )
	
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
	end
end

function ENT:PhysicsCollide( data, physobj)
	local entity = data.HitEntity
	
	if entity:IsPlayer() then
		local hasPowerup, currentPowerup = kbpowerup.PlayerHasPowerup(entity)
		
		if not hasPowerup then
			kbpowerup.CallTouch(self.Entity, entity)
			GAMEMODE:RespawnPowerupOnTime(self.Entity:GetVar("SpawnID"))
		elseif entity:IsPlayer() then
			net.Start("KOBE_PowerupPickupFailed")
				net.WriteString(kbpowerup.GetPrintName(self.PowerupName))
				net.WriteString(kbpowerup.GetPrintName(currentPowerup))
			net.Send(entity)
		end
	end
end

function ENT:Use( activator, caller )
    return 
end

function ENT:Think()
    -- We don't need to think, we are just a prop after all!
	self.Entity:SetAngles(self.Entity:GetAngles() + Angle(0, 3,0))
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS -- If we have glows, we should have this. Otherwise... I don't know.
end