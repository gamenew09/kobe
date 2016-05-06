glogs = {}

glogs.Prefix = "KOBE"
glogs.FileName = "kobe.txt"

function glogs.Clear()
	file.Write(glogs.FileName, "")
end

function glogs.Write(msg)
	file.Append( glogs.FileName, "["..glogs.Prefix.."] "..tostring(msg) )
	print("["..glogs.Prefix.."] "..tostring(msg))
end

glogs.Clear()