ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()
	
end

-- Updates the bounds of this collision box
function ENT:SetBounds(min, max)
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionBounds(min, max)
    self:SetTrigger(true)
end

function ENT:KeyValue(k, v)
	if k == "playersShould" then
		self.Entity:SetVar("playersShould", v)
	end
end

function ENT:Think()
	local mins = self:LocalToWorld(self:OBBMins())
	local maxs = self:LocalToWorld(self:OBBMaxs())

	for _,ent in pairs(ents.FindInBox(mins, maxs)) do
		if IsValid(ent) and ent:GetClass() == "kbe_ball" then
			GAMEMODE:TeleportBallToCenter()
		elseif (IsValid(ent) and ent:IsPlayer() and self.Entity:GetVar("playersShould", 0) == 1) then
			ent:SetPos(GAMEMODE:PlayerSelectSpawn( pl ):GetPos())
		end
	end
end