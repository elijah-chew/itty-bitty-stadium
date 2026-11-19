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
local Pitch = load("Pitch")
local Venue = load("Venue")

local Events = {}

function Events.missing(profile, competitionId)
	local competition = Catalog.competitions[competitionId]
	if competition == nil then
		return { "unknown competition" }
	end
	local missing = {}
	local pitch = Pitch.inspect(profile)
	if not pitch.valid then
		table.insert(missing, pitch.reason)
	end
	if pitch.valid then
		local got = Pitch.sizeClass(pitch.width, pitch.height)
		if Pitch.rank(got) < Pitch.rank(competition.format) then
			table.insert(missing, competition.format)
		end
	end
	if Venue.capacity(profile) < competition.capacity then
		table.insert(missing, "capacity")
	end
	local have = Venue.facilities(profile)
	for _, facility in ipairs(competition.requires) do
		if not have[facility] then
			table.insert(missing, facility)
		end
	end
	if competition.jersey and (profile.jersey == nil or profile.jersey == "") then
		table.insert(missing, "jersey")
	end
	return missing
end

function Events.eligible(profile, competitionId)
	if Catalog.competitions[competitionId] == nil then
		return false, "unknown competition"
	end
	local missing = Events.missing(profile, competitionId)
	if #missing > 0 then
		return false, missing[1]
	end
	return true
end

function Events.best(profile)
	local bestId = nil
	local bestOrder = -1
	for competitionId, competition in pairs(Catalog.competitions) do
		if Events.eligible(profile, competitionId) and competition.order > bestOrder then
			bestOrder = competition.order
			bestId = competitionId
		end
	end
	return bestId
end

return Events
