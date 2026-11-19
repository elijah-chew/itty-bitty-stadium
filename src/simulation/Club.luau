local load
do
	local ok, current = pcall(function()
		return script
	end)
	if ok and current ~= nil and current.Parent ~= nil then
		local child = current.Parent:FindFirstChild("load")
		if child ~= nil then
			load = require(child)
		end
	end
	if load == nil then
		load = require("./load")
	end
end

local Catalog = load("Catalog")
local Events = load("Events")

local Club = {}

local function validName(name)
	if type(name) ~= "string" then
		return false
	end
	if #name < 3 or #name > 24 then
		return false
	end
	if string.match(name, "^[%a%d][%a%d '%-]*$") == nil then
		return false
	end
	if string.find(name, "  ", 1, true) ~= nil then
		return false
	end
	return true
end

function Club.found(profile, name, primary, secondary)
	if profile.club ~= nil then
		return false, "already founded"
	end
	if not validName(name) then
		return false, "name"
	end
	if Catalog.colours[primary] == nil or Catalog.colours[secondary] == nil then
		return false, "colour"
	end
	if not Events.eligible(profile, "sunday") then
		return false, "not ready"
	end
	profile.club = {
		name = name,
		primary = primary,
		secondary = secondary,
	}
	profile.league = {
		tier = "sunday",
		played = 0,
		points = 0,
		season = 1,
		last = nil,
	}
	return true
end

return Club
