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

local Objectives = {}

function Objectives.ready(profile, objectiveId)
	if objectiveId == "host_match" then
		return profile.matchesHosted >= 1
	end
	if objectiveId == "build_stand" then
		for _, cell in pairs(profile.cells) do
			if cell.kind == "stand_small" or cell.kind == "stand_medium" then
				return true
			end
		end
		return false
	end
	if objectiveId == "expand_once" then
		return profile.expansions >= 1
	end
	return false
end

function Objectives.claim(profile, objectiveId)
	local reward = Catalog.objectives[objectiveId]
	if reward == nil then
		return false, "unknown objective"
	end
	if profile.objectives[objectiveId] then
		return false, "claimed"
	end
	if not Objectives.ready(profile, objectiveId) then
		return false, "not ready"
	end
	profile.objectives[objectiveId] = true
	local amount = reward.cash * Monetisation.multiplier(profile)
	profile.cash = profile.cash + amount
	profile.reputation = profile.reputation + reward.reputation
	if reward.reputation > 0 then
		profile.lifetimeReputation = profile.lifetimeReputation + reward.reputation
	end
	return true, amount
end

return Objectives
