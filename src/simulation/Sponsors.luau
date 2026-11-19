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
local Monetisation = load("Monetisation")

local Sponsors = {}

function Sponsors.collect(profile)
	local paid = 0
	for _, contract in ipairs(Catalog.sponsors) do
		local state = profile.sponsors[contract.id]
		if state ~= nil and not state.paid and profile.matchesHosted >= contract.matches then
			state.paid = true
			local amount = contract.cash * Monetisation.multiplier(profile)
			profile.cash = profile.cash + amount
			paid = paid + amount
		end
	end
	return paid
end

return Sponsors
