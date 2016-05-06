include( "shared.lua" )

hook.Add("PreDrawHalos", "PreDrawHalos_KBEBall", function ()
	halo.Add( ents.FindByClass( "kbe_ball" ), Color( 255, 0, 0 ), 3, 3, 2, true, true )
end)
