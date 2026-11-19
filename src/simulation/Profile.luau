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

local Profile = {}

function Profile.new()
	local sponsors = {}
	for _, contract in ipairs(Catalog.sponsors) do
		sponsors[contract.id] = {
			required = contract.matches,
			paid = false,
		}
	end

	return {
		version = 1,
		cash = Catalog.starterCash,
		fans = 0,
		reputation = 0,
		lifetimeReputation = 0,
		doubleMoney = false,
		receipts = {},
		expansions = 0,
		width = Catalog.gridWidth,
		height = Catalog.gridHeight,
		cells = {},
		matchesHosted = 0,
		sponsors = sponsors,
		objectives = {
			host_match = false,
			build_stand = false,
			expand_once = false,
		},
		activeMatch = nil,
		jersey = nil,
		club = nil,
		league = nil,
		pitchPass = false,
		sideTasks = {},
	}
end

return Profile
