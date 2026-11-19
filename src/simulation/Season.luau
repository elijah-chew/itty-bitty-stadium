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

local Season = {}

local NEXT = {
	sunday = "town",
	town = "regional",
	regional = "national",
	national = "premier",
}

local PREVIOUS = {
	town = "sunday",
	regional = "town",
	national = "regional",
	premier = "national",
}

function Season.pointsFor(home, away)
	if home > away then
		return 3
	end
	if home == away then
		return 1
	end
	return 0
end

function Season.resolve(profile)
	local league = profile.league
	local rules = Catalog.pyramid[league.tier]
	local points = league.points
	local outcome = "stay"
	local destination = league.tier
	local upstairs = NEXT[league.tier]
	if rules.promote ~= nil and points >= rules.promote and upstairs ~= nil then
		if Events.eligible(profile, upstairs) then
			outcome = "promoted"
			destination = upstairs
		else
			outcome = "blocked"
		end
	elseif rules.relegate ~= nil and points <= rules.relegate then
		outcome = "relegated"
		destination = PREVIOUS[league.tier]
	end
	league.tier = destination
	league.played = 0
	league.points = 0
	league.season = league.season + 1
	league.last = outcome
	return outcome, destination
end

function Season.record(profile, competitionId, home, away)
	if profile.league == nil or Catalog.pyramid[competitionId] == nil then
		return nil
	end
	if profile.league.tier ~= competitionId then
		return nil
	end
	local rules = Catalog.pyramid[competitionId]
	profile.league.played = profile.league.played + 1
	profile.league.points = profile.league.points + Season.pointsFor(home, away)
	if profile.league.played < rules.matches then
		return nil
	end
	return Season.resolve(profile)
end

return Season
