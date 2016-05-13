include( "shared.lua" )

surface.CreateFont( "RoundHeader",
{
	font		= "Roboto",
	size		= 32,
	weight		= 500
})

hook.Add("PreDrawHalos", "PreDrawHalos_KBEBall", function ()
	halo.Add( ents.FindByClass( "kbe_ball" ), Color( 255, 0, 0 ), 3, 3, 2, true, true )
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