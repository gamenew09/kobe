roundmanager = {}

local rndstart_netmsg = "rnm_start"
local rndend_netmsg   = "rnm_end"

if SERVER then
	util.AddNetworkString(rndstart_netmsg)
	util.AddNetworkString(rndend_netmsg)
end

local timeStarted = 0
local timeLength = 0
local inround = false

if SERVER then
	function roundmanager.Start(length)
		if inround then return false end
		timeLength = length
		timeStarted = CurTime()
		inround = true
		hook.Call( "RoundStart", nil, timeStarted )
		timer.Create( "roundmanager_TimerTick", timeLength, 1, function ()
			hook.Call( "RoundEnd", nil, CurTime(), true )
			net.Start( rndend_netmsg )
				net.WriteBool( true )
			net.Broadcast()
		end)
		net.Start( rndstart_netmsg )
			net.WriteInt(timeStarted)
			net.WriteInt(timeLength)
		net.Broadcast()
		return true
	end

	function roundmanager.End()
		if not inround then return false end
		timer.Remove( "roundmanager_TimerTick" )
		inround = false
		hook.Call( "RoundEnd", nil, CurTime(), false )
		net.Start( rndend_netmsg )
			net.WriteBool( false )
		net.Broadcast()
		return true
	end
end

function roundmanager.InRound()
	return inround
end

function roundmanager.GetTime()
	return math.Round((timeStarted+timeLength)-CurTime())
end

if CLIENT then
	net.Receive( rndstart_netmsg, function( len, pl )
		timeStarted = net.ReadInt()
		timeLength = net.ReadInt()
		inround = true
		hook.Call( "RoundStart", nil, timeStarted )
	end)
	net.Receive( rndend_netmsg, function( len, pl )
		timeStarted = 0
		timeLength = 0
		inround = false
		hook.Call( "RoundEnd", nil, CurTime(), false )
	end)
end
