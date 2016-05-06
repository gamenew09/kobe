kbpowerup = {}

local powerups = {}

function kbpowerup.Add(name, model, touchedfunc)
	powerups[tostring(name)] = {
		["Model"] = model,
		["Touched"] = touchedfunc
	}
end

function kbpowerup.CallTouch(ent, ply)
	if not powerups[ent:GetPowerupName()] then
		return false
	end
	powerups[ent:GetPowerupName()]["Touched"](ent, ply)
	ent:Kill()
	return true
end

function kbpowerup.RandomPowerupName()
	local c = 0
	local rnd = math.random(1, table.Count(powerups))
	for i,v in pairs(powerups) do
		c = c + 1
		if c == rnd then
			return i
		end
	end
	return "WHAT_THE_HECK"
end

function kbpowerup.GetModel(ent)
	if not powerups[ent:GetPowerupName()] then
		return
	end
	return powerups[ent:GetPowerupName()]["Model"]
end