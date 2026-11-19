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

local Match = {}

local function hashString(text)
	local hash = 0
	for index = 1, #text do
		hash = (hash * 33 + string.byte(text, index)) % 2147483647
	end
	return hash
end

function Match.venueKey(profile)
	local pitch = Pitch.inspect(profile)
	local names = {}
	for facility in pairs(Venue.facilities(profile)) do
		table.insert(names, facility)
	end
	table.sort(names)
	return string.format(
		"%d,%d,%d,%s,%s",
		pitch.width or 0,
		pitch.height or 0,
		Venue.capacity(profile),
		table.concat(names, ","),
		profile.jersey or ""
	)
end

function Match.score(profile, seed)
	local safeSeed = math.floor(math.abs(seed or 1))
	local venueHash = hashString(Match.venueKey(profile))
	local home = (safeSeed * 1103515245 + venueHash) % 6
	local away = (safeSeed * 1664525 + venueHash * 3) % 6
	return home, away
end

function Match.preview(profile, competitionId, seed)
	local competition = Catalog.competitions[competitionId]
	local home, away = Match.score(profile, seed)
	local attendance = Venue.attendance(profile)
	local ticketCash = math.floor(attendance * competition.ticketPrice / Catalog.spectatorsPerTicket)
	local winBonus = 0
	local reputationDelta = Catalog.reputation.loss
	if home > away then
		winBonus = competition.winBonus
		reputationDelta = Catalog.reputation.win
	elseif home == away then
		reputationDelta = Catalog.reputation.draw
	end
	return {
		home = home,
		away = away,
		attendance = attendance,
		beforeMultiplier = competition.baseCash + ticketCash + winBonus + Venue.matchdayProfit(profile, attendance),
		fanGain = math.max(competition.minFans, math.floor(attendance / 2)),
		reputationDelta = reputationDelta,
	}
end

return Match
