kbpowerup = {}

local powerups = {}

function kbpowerup.Add(name, model, touchedfunc, printName)
	powerups[tostring(name)] = {
		["Model"] = model,
		["Touched"] = touchedfunc,
		["PrintName"] = (printName or "Unknown")
	}
end

function kbpowerup.CallTouch(ent, ply)
	if not powerups[ent:GetPowerupName()] then
		return false
	end
	powerups[ent:GetPowerupName()]["Touched"](ent, ply)
	ent:Remove()
	return true
end

function kbpowerup.PlayerHasPowerup(ply)
	if ply:IsPlayer() then
		return hook.Call("PlayerHasPowerup", GAMEMODE, ply)
	end
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

function kbpowerup.GetPrintName(name)
	if not powerups[name] then
		return
	end
	return powerups[name]["PrintName"]
end

function kbpowerup.GetModelByName(name)
	if not powerups[name] then
		return
	end
	return powerups[name]["Model"]
end

function kbpowerup.GetModel(ent)
	if not powerups[ent:GetPowerupName()] then
		return
	end
	return powerups[ent:GetPowerupName()]["Model"]
end