ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()
	self.Entity:SetVar("TempBool", false)
end

-- Updates the bounds of this collision box
function ENT:SetBounds(min, max)
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionBounds(min, max)
    self:SetTrigger(true)
end

function ENT:StartTouch( ent )
	if ent:GetClass() == "kbe_ball" and not self.Entity:GetTable()["TempBool"] then
		self.Entity:SetVar("TempBool", true)
		GAMEMODE:GoalScore( self.Entity, ent, self.Entity:GetTable()["Team"] )
	end
end

function ENT:KeyValue(k, v)
	if k == "team" then
		self.Entity:SetVar("Team", v)
	end
end

function ENT:EndTouch( ent )
	if ent:GetClass() == "kbe_ball" and self.Entity:GetTable()["TempBool"] then
		self.Entity:SetVar("TempBool", false)
	end
end