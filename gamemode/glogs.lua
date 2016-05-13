glogs = {}

glogs.Prefix = "KOBE"
glogs.FileName = "kobe.txt"

function glogs.Clear()
	file.Write(glogs.FileName, "")
end

function glogs.Write(msg)
	file.Append( glogs.FileName, "[INFO] ["..glogs.Prefix.."] "..tostring(msg) )
	print("["..glogs.Prefix.."] "..tostring(msg))
end

function glogs.ErrorNoHalt(msg)
	file.Append( glogs.FileName, "[ERROR] ["..glogs.Prefix.."] "..tostring(msg) )
	ErrorNoHalt("["..glogs.Prefix.."] "..tostring(msg))
end

glogs.Clear()