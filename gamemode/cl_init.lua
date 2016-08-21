include( "shared.lua" )

surface.CreateFont( "RoundHeader",
{
	font		= "Roboto",
	size		= 32,
	weight		= 500
})

GM.PlayerCarryingBall = nil

net.Receive("KOBE_PlayerPickup", function (len, sender)
	if sender ~= nil then return end
	local reset = net.ReadBool()
	if not reset then
		local ply = net.ReadEntity()
		if ply:IsPlayer() then
			GM.PlayerCarryingBall = ply
		end
	else
		GM.PlayerCarryingBall = nil
	end
end)

local middleString = ""

net.Receive("KOBE_PowerupPickupFailed", function (len, sender)
	local printName = net.ReadString()
	local currentPowerup = net.ReadString()
	if printName == currentPowerup then
		middleString = string.format("You cannot pickup \"%s\" powerup! You already have the same powerup!", printName)
	else
		middleString = string.format("You cannot pickup \"%s\" powerup! You already have \"%s\" powerup!", printName, currentPowerup)
	end
	timer.Simple(5, function ()
		middleString = ""
	end)
end)

--[[
	tr=fraction red
	tg=fraction green (nil = tr)
	tb=fraction blue (nil = tr)

	from=Color from
	to=Color to
--]]

function LerpColor (tr,tg,tb,from,to)
	tg = tg || tr
	tb = tb || tr
	return Color(Lerp(tr,from.r,to.r),Lerp(tg,from.g,to.g),Lerp(tb,from.b,to.b))
end

hook.Add("PreDrawHalos", "PreDrawHalos_KBEBall", function ()
	if IsValid(GAMEMODE.PlayerCarryingBall) then
		halo.Add( ply, team.GetColor(GM.PlayerCarryingBall:Team()), 3, 3, 2, true, true )
	else
		halo.Add( ents.FindByClass( "kbe_ball" ), Color(255,0,0,255), 3, 3, 2, true, true )
	end
end)

net.Receive( "KOBE_CleanUpMap", function( len, pl )
	GM:CleanUpMap()
end)

local IntermissionStartTime = 0
local InIntermission = false
local IntermissionLength = 0

net.Receive( "KOBE_IntermissionStart", function( len, pl )
	IntermissionStartTime = net.ReadFloat()
	IntermissionLength = net.ReadFloat()
	InIntermission = true
end)

net.Receive( "KOBE_IntermissionEnd", function( len, pl )
	IntermissionLength = 0
	IntermissionStartTime = 0
	InIntermission = false
end)

function GM:HUDPaint()
	if roundmanager.InRound() then
		draw.DrawText( "Round Time:"..roundmanager.GetTime(), "RoundHeader", ScrW() * 0.5, ScrH() * 0.05, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end
	if InIntermission then
		draw.DrawText( "Intermision:"..math.Round((IntermissionStartTime+IntermissionLength)-CurTime()), "RoundHeader", ScrW() * 0.5, ScrH() * 0.05, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end
	
	if middleString then
		draw.DrawText( middleString, "RoundHeader",  ScrW() * 0.5, ScrH() * 0.1, Color(255,0,0,255), TEXT_ALIGN_CENTER)
	end
end

function GM:CleanUpMap()
   -- Ragdolls sometimes stay around on clients. Deleting them can create issues
   -- so all we can do is try to hide them.
   for _, ent in pairs(ents.FindByClass("prop_ragdoll")) do
      if IsValid(ent) and CORPSE.GetPlayerNick(ent, "") != "" then
         ent:SetNoDraw(true)
         ent:SetSolid(SOLID_NONE)
         ent:SetColor(Color(0,0,0,0))

         -- Horrible hack to make targetid ignore this ent, because we can't
         -- modify the collision group clientside.
         ent.NoTarget = true
      end
   end

   -- This cleans up decals since GMod v100
   game.CleanUpMap()
end