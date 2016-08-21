ENT.Type = "anim"
ENT.Base = "base_anim"
 
ENT.PrintName= "KOBE Powerup"
ENT.Author= "Gamenew09"
ENT.Contact= "STEAM Profile: Toenail Clipper"
ENT.Purpose= "A Ball used in KOBE."
ENT.Instructions= "Only use in KOBE."
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.PowerupName = ""

function ENT:SetupDataTables()
	self.PowerupName = kbpowerup.RandomPowerupName()
	self.Entity:SetVar(self.PowerupName)
	self:NetworkVar( "String", 0, "PowerupName" )
	self:SetPowerupName(self.PowerupName)
end