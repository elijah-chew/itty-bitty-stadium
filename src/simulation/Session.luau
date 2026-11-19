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
local Match = load("Match")
local Monetisation = load("Monetisation")
local Sponsors = load("Sponsors")
local Season = load("Season")

local Session = {}

function Session.host(profile, competitionId, seed)
	if profile.activeMatch ~= nil then
		return false, "match in progress"
	end
	if competitionId == nil or competitionId == "" then
		if profile.league ~= nil then
			competitionId = profile.league.tier
		else
			competitionId = "kickabout"
		end
	end
	local eligible, reason = Events.eligible(profile, competitionId)
	if not eligible then
		return false, reason
	end
	if Catalog.pyramid[competitionId] ~= nil then
		if profile.club == nil then
			return false, "no club"
		end
		if profile.league.tier ~= competitionId then
			return false, "not your league"
		end
	end
	if competitionId == "cup_final" and (profile.league == nil or profile.league.tier ~= "premier") then
		return false, "not your league"
	end

	local preview = Match.preview(profile, competitionId, seed)
	profile.activeMatch = {
		competitionId = competitionId,
		seed = math.floor(math.abs(seed or 1)),
		elapsed = 0,
		home = preview.home,
		away = preview.away,
		attendance = preview.attendance,
		beforeMultiplier = preview.beforeMultiplier,
		fanGain = preview.fanGain,
		reputationDelta = preview.reputationDelta,
	}
	return true, profile.activeMatch
end

function Session.advance(profile, dt)
	local active = profile.activeMatch
	if active == nil then
		return nil
	end
	if type(dt) == "number" and dt > 0 then
		active.elapsed = active.elapsed + dt
	end
	if active.elapsed < Catalog.matchSeconds then
		return nil
	end

	local amount = active.beforeMultiplier * Monetisation.multiplier(profile)
	profile.cash = profile.cash + amount
	profile.fans = profile.fans + active.fanGain
	profile.reputation = profile.reputation + active.reputationDelta
	if active.reputationDelta > 0 then
		profile.lifetimeReputation = profile.lifetimeReputation + active.reputationDelta
	end
	profile.matchesHosted = profile.matchesHosted + 1
	local seasonOutcome = Season.record(profile, active.competitionId, active.home, active.away)
	local sponsorCash = Sponsors.collect(profile)
	local result = {
		competitionId = active.competitionId,
		home = active.home,
		away = active.away,
		cash = amount,
		fansGained = active.fanGain,
		reputationDelta = active.reputationDelta,
		sponsorCash = sponsorCash,
		attendance = active.attendance,
		season = seasonOutcome,
	}
	profile.activeMatch = nil
	return result
end

function Session.newServer()
	local plots = {}
	for index = 1, Catalog.plotCount do
		plots[index] = nil
	end
	return { plots = plots }
end

function Session.list(server)
	local rows = {}
	for index = 1, Catalog.plotCount do
		rows[index] = {
			index = index,
			owner = server.plots[index],
		}
	end
	return rows
end

function Session.claim(server, userId, plotIndex)
	for index = 1, Catalog.plotCount do
		if server.plots[index] == userId then
			if plotIndex == nil or plotIndex == index then
				return index
			end
			return nil, "already claimed"
		end
	end
	if type(plotIndex) ~= "number" or plotIndex < 1 or plotIndex > Catalog.plotCount or plotIndex ~= math.floor(plotIndex) then
		return nil, "no plot"
	end
	if server.plots[plotIndex] ~= nil then
		return nil, "taken"
	end
	server.plots[plotIndex] = userId
	return plotIndex
end

function Session.rank(profiles)
	local rows = {}
	for userId, profile in pairs(profiles) do
		table.insert(rows, {
			userId = userId,
			lifetimeReputation = profile.lifetimeReputation,
		})
	end
	table.sort(rows, function(a, b)
		if a.lifetimeReputation == b.lifetimeReputation then
			return tostring(a.userId) < tostring(b.userId)
		end
		return a.lifetimeReputation > b.lifetimeReputation
	end)
	return rows
end

return Session
