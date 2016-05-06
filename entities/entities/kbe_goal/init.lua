ENT.Type = "brush"
ENT.Base = "base_brush"

function ENT:StartTouch( ent )
	if ent:GetClass() == "kbe_ball" then
		
	end
end

function ENT:KeyValue(k, v)
	if k == "team" then
		self.Entity
	end
end

function ENT:EndTouch( ent )
	if ent:GetClass() == "kbe_ball" then
		
	end
end