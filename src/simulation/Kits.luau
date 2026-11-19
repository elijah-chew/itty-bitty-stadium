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

local Kits = {}

function Kits.buy(profile, kitId)
	local kit = Catalog.jerseys[kitId]
	if kit == nil then
		return false, "unknown jersey"
	end
	if profile.cash < kit.cost then
		return false, "not enough cash"
	end
	profile.cash = profile.cash - kit.cost
	profile.jersey = kitId
	return true
end

return Kits
