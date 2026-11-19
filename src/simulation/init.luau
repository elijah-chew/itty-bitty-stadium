local load
do
	local ok, current = pcall(function()
		return script
	end)
	if ok and current ~= nil then
		local child = current:FindFirstChild("load")
		if child == nil and current.Parent ~= nil then
			child = current.Parent:FindFirstChild("load")
		end
		if child ~= nil then
			load = require(child)
		end
	end
	if load == nil then
		load = require("./load")
	end
end

return {
	Catalog = load("Catalog"),
	Profile = load("Profile"),
	Grid = load("Grid"),
	Pitch = load("Pitch"),
	Venue = load("Venue"),
	Events = load("Events"),
	Match = load("Match"),
	Sponsors = load("Sponsors"),
	Objectives = load("Objectives"),
	Monetisation = load("Monetisation"),
	Kits = load("Kits"),
	Build = load("Build"),
	Club = load("Club"),
	Season = load("Season"),
	SideTasks = load("SideTasks"),
	Save = load("Save"),
	Session = load("Session"),
}
