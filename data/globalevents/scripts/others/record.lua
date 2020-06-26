function onRecord(current, old)

	local file = io.open("data/logs/records/records.txt", "a")
	if not file then
		print(">> Error accessing the records file.")
		return
	end
	
	io.output(file)
	io.write("------------------------------\n")
	io.write("New: " .. current .. "\n")
	io.write("Old: " .. old .. "\n")
	io.write("Time: " .. os.date('%x %X', os.time()) .. "\n")
	io.close(file)

	broadcastMessage("Novo recorde: " .. current .. " players estão online.", MESSAGE_STATUS_DEFAULT)
	return true
end
