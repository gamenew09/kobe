ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName= "KOBE Powerup"
ENT.Author= "Gamenew09"
ENT.Contact= "STEAM Profile: Toenail Clipper"
ENT.Purpose= "A Ball used in KOBE."
ENT.Instructions= "Only use in KOBE."
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar( "String", kbpowerup.RandomPowerupName(), "PowerupName" )
	if SERVER then
		self:SetModel( kbpowerup.GetModel(self.Entity) )
	end
end