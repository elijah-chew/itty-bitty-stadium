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
local Venue = load("Venue")

local SideTasks = {}

function SideTasks.complete(profile, taskId)
	local task = Catalog.sideTasks[taskId]
	if task == nil then
		return false, "unknown task"
	end
	if task.facility ~= nil and not Venue.facilities(profile)[task.facility] then
		return false, "facility"
	end
	if profile.sideTasks[taskId] == profile.matchesHosted then
		return false, "already done"
	end
	profile.sideTasks[taskId] = profile.matchesHosted
	local amount = task.cash * Monetisation.multiplier(profile)
	profile.cash = profile.cash + amount
	return true, amount
end

return SideTasks
