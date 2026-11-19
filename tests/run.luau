local Profile = require("../src/simulation/Profile")
local Grid = require("../src/simulation/Grid")
local Events = require("../src/simulation/Events")
local Match = require("../src/simulation/Match")
local Venue = require("../src/simulation/Venue")
local Session = require("../src/simulation/Session")
local Monetisation = require("../src/simulation/Monetisation")
local Save = require("../src/simulation/Save")
local Objectives = require("../src/simulation/Objectives")

local failures = 0

local function check(name, condition)
	if condition then
		print("ok  " .. name)
	else
		failures = failures + 1
		print("FAIL " .. name)
	end
end

local function rich()
	local profile = Profile.new()
	profile.cash = 1000000
	return profile
end

local function kickaboutPitch(profile)
	for x = 2, 7 do
		for y = 2, 11 do
			local ok, reason = Grid.place(profile, x, y, "grass")
			if not ok then
				error(reason)
			end
		end
	end
	local north, northReason = Grid.place(profile, 4, 1, "goal", "south")
	local south, southReason = Grid.place(profile, 4, 12, "goal", "north")
	if not north or not south then
		error(northReason or southReason)
	end
end

local function play(profile, competitionId, seed)
	local started, reason = Session.host(profile, competitionId, seed)
	if not started then
		return nil, reason
	end
	return Session.advance(profile, 30)
end

do
	local profile = rich()
	kickaboutPitch(profile)
	local removed = Grid.remove(profile, 4, 6)
	check("holey pitch is not a rectangle", removed and not Events.eligible(profile, "kickabout"))
	local cash = profile.cash
	local started, reason = Session.host(profile, "kickabout", 1)
	check("holey pitch refuses a kickabout", started == false and reason == "not a rectangle" and profile.cash == cash and profile.activeMatch == nil)
end

do
	local profile = rich()
	kickaboutPitch(profile)
	local result = play(profile, "kickabout", 4)
	check("valid pitch hosts a kickabout", result ~= nil and result.competitionId == "kickabout" and result.cash > 0 and result.fansGained >= 5)
end

do
	local profile = rich()
	kickaboutPitch(profile)
	local placed = Grid.place(profile, 3, 1, "stand_small", "south")
	local eligible = Events.eligible(profile, "sunday")
	check("sunday league blocked without a changing room", placed and eligible == false)
	Grid.place(profile, 1, 2, "changing_room")
	check("sunday league opens with a changing room and a stand", Events.eligible(profile, "sunday") == true)
end

do
	local profile = rich()
	kickaboutPitch(profile)
	local placed = Grid.place(profile, 3, 2, "stand_small")
	profile.fans = 10
	check("attendance cannot exceed fans", placed and Venue.attendance(profile) == 10)
	profile.fans = 5000
	check("attendance cannot exceed capacity", Venue.attendance(profile) == 1000)
end

do
	local function scoreOf()
		local profile = rich()
		kickaboutPitch(profile)
		return Match.score(profile, 11)
	end
	local homeA, awayA = scoreOf()
	local homeB, awayB = scoreOf()
	check("the same seed replays the same score", homeA == homeB and awayA == awayB)
end

do
	local profile = rich()
	kickaboutPitch(profile)
	local first = play(profile, "kickabout", 2)
	local paidAfterFirst = profile.sponsors.two.paid
	local second = play(profile, "kickabout", 2)
	check(
		"a sponsor pays on the required match and not before",
		first ~= nil
			and first.sponsorCash == 0
			and paidAfterFirst == false
			and second ~= nil
			and second.sponsorCash == 2000
			and profile.sponsors.two.paid == true
	)
end

do
	local profile = rich()
	local first = Grid.expand(profile)
	local second = Grid.expand(profile)
	local third = Grid.expand(profile)
	local cash = profile.cash
	local fourth, reason = Grid.expand(profile)
	check(
		"expansion past the third strip fails",
		first and second and third and profile.width == 24 and fourth == false and reason == "expansion limit" and profile.cash == cash and profile.width == 24
	)
end

do
	local profile = rich()
	kickaboutPitch(profile)
	local started = Session.host(profile, "kickabout", 1)
	local blocked, reason = Session.host(profile, "kickabout", 1)
	local early = Session.advance(profile, 29)
	local finished = Session.advance(profile, 1)
	local again = Session.host(profile, "kickabout", 1)
	check(
		"a match in progress rejects another host",
		started == true and blocked == false and reason == "match in progress" and early == nil and finished ~= nil and again == true
	)
end

do
	local function matchCash(doubleMoney)
		local profile = rich()
		profile.doubleMoney = doubleMoney
		profile.fans = 40
		kickaboutPitch(profile)
		Grid.place(profile, 8, 2, "stand_small")
		local result = play(profile, "kickabout", 8)
		return result.cash, result.fansGained, result.reputationDelta
	end
	local plain, fansPlain, reputationPlain = matchCash(false)
	local doubled, fansDoubled, reputationDoubled = matchCash(true)
	check("2x doubles a match payout", doubled == plain * 2 and fansDoubled == fansPlain and reputationDoubled == reputationPlain)
end

do
	local profile = Profile.new()
	local start = profile.cash
	local unknownStatus, unknownAmount = Monetisation.grant(profile, "mystery", "p0")
	local cashAfterUnknown = profile.cash
	local grantedStatus, grantedAmount = Monetisation.grant(profile, "cash_10000", "p1")
	local duplicateStatus, duplicateAmount = Monetisation.grant(profile, "cash_10000", "p1")
	check("an unknown product id pays nothing", unknownStatus == "not_processed" and unknownAmount == 0 and cashAfterUnknown == start)
	check("a 10,000 pack pays once", grantedStatus == "granted" and grantedAmount == 10000 and profile.cash == start + 10000)
	check("the same purchase id does not pay twice", duplicateStatus == "duplicate" and duplicateAmount == 0 and profile.cash == start + 10000)
	local balance = profile.cash
	Monetisation.setDoubleMoney(profile, true)
	local boostedStatus, boostedAmount = Monetisation.grant(profile, "cash_10000", "p2")
	check("2x doubles a 10,000 pack and does not rewrite the old balance", profile.cash == balance + 20000 and boostedStatus == "granted" and boostedAmount == 20000)
end

local Kits = require("../src/simulation/Kits")

local function elevenPitch(profile)
	profile.pitchPass = true
	for x = 2, 9 do
		for y = 2, 15 do
			local ok, reason = Grid.place(profile, x, y, "grass")
			if not ok then
				error(reason)
			end
		end
	end
	local north, northReason = Grid.place(profile, 5, 1, "goal", "south")
	local south, southReason = Grid.place(profile, 5, 16, "goal", "north")
	if not north or not south then
		error(northReason or southReason)
	end
end

local function mediumStands(profile, count)
	for index = 1, count do
		local ok, reason = Grid.place(profile, 10, 1 + index, "stand_medium", "west")
		if not ok then
			error(reason)
		end
	end
end

do
	local profile = rich()
	elevenPitch(profile)
	mediumStands(profile, 1)
	local missing = Events.missing(profile, "town")
	local closed = Events.eligible(profile, "town")
	local opened = Grid.place(profile, 11, 2, "gym")
	check("town club needs a training gym", missing[1] == "gym" and closed == false)
	check("town club opens once the gym is built", opened == true and Events.eligible(profile, "town") == true)
end

do
	local profile = rich()
	elevenPitch(profile)
	mediumStands(profile, 4)
	Grid.place(profile, 11, 2, "ticket_office")
	Grid.place(profile, 12, 2, "medical")
	local beforeHotel = Events.eligible(profile, "national")
	local hotel = Grid.place(profile, 11, 3, "club_hotel")
	check("national league needs a club hotel", beforeHotel == false and hotel and Events.eligible(profile, "national") == true)
end

do
	local profile = rich()
	elevenPitch(profile)
	mediumStands(profile, 7)
	Grid.place(profile, 11, 2, "scoreboard")
	Grid.place(profile, 12, 2, "club_shop")
	local missing = Events.missing(profile, "cup_final")
	local bought = Kits.buy(profile, "stripes")
	check("cup final needs a jersey", missing[1] == "jersey" and bought and profile.jersey == "stripes" and Events.eligible(profile, "cup_final") == true)
end

do
	local profile = rich()
	kickaboutPitch(profile)
	play(profile, "kickabout", 1)
	local before = profile.cash
	local claimed, amount = Objectives.claim(profile, "host_match")
	local again = Objectives.claim(profile, "host_match")
	check("hosting objective pays once", claimed == true and amount == 1000 and profile.cash == before + 1000 and again == false)
	local exported = Save.export(profile)
	exported.cash = 1
	local imported = Save.import(Save.export(profile))
	check(
		"save round trip keeps the stadium",
		profile.cash == before + 1000 and imported ~= nil and imported.cash == profile.cash and imported.matchesHosted == 1 and Save.import({ version = 2 }) == nil
	)
end

local Build = require("../src/simulation/Build")
local Club = require("../src/simulation/Club")
local Season = require("../src/simulation/Season")

do
	local profile = rich()
	kickaboutPitch(profile)
	local snapped = Grid.place(profile, 3, 2, "stand_small")
	local cell = Grid.get(profile, 3, 1)
	local corner = Grid.place(profile, 2, 2, "stand_corner")
	local cornerCell = Grid.get(profile, 1, 1)
	local angle = Grid.place(profile, 2, 1, "stand_angle")
	local middle = Grid.place(profile, 5, 1, "stand_angle")
	check(
		"stands snap to the pitch, with corners and angles",
		snapped and cell ~= nil and cell.kind == "stand_small" and cell.facing == "south" and Grid.get(profile, 3, 2).kind == "grass" and corner and cornerCell.facing == "nw" and angle and middle == false
	)
end

local function foundSunday(profile)
	kickaboutPitch(profile)
	Grid.place(profile, 3, 1, "stand_small", "south")
	Grid.place(profile, 1, 2, "changing_room")
	return Club.found(profile, "Elijah FC", "navy", "white")
end

do
	local profile = rich()
	local founded = foundSunday(profile)
	local badName = Club.found(profile, "No", "navy", "white")
	for _ = 1, 6 do
		Season.record(profile, "sunday", 0, 2)
	end
	check("sunday cannot be relegated", founded and badName == false and profile.league.tier == "sunday" and profile.league.last == "stay")
end

do
	local profile = rich()
	foundSunday(profile)
	for _ = 1, 6 do
		Season.record(profile, "sunday", 3, 0)
	end
	local blocked = profile.league.last == "blocked" and profile.league.tier == "sunday"
	local ready = rich()
	elevenPitch(ready)
	Grid.place(ready, 10, 2, "stand_medium", "west")
	Grid.place(ready, 11, 2, "changing_room")
	Grid.place(ready, 11, 3, "gym")
	Club.found(ready, "Elijah FC", "navy", "white")
	for _ = 1, 6 do
		Season.record(ready, "sunday", 3, 0)
	end
	check("promotion into town needs the gym, then the points", blocked and ready.league.last == "promoted" and ready.league.tier == "town")
end

do
	local profile = rich()
	foundSunday(profile)
	profile.league.tier = "regional"
	for _ = 1, 6 do
		Season.record(profile, "regional", 0, 1)
	end
	local relegated = profile.league.last == "relegated" and profile.league.tier == "town"
	profile.league.tier = "premier"
	for _ = 1, 6 do
		Season.record(profile, "premier", 4, 0)
	end
	check("higher leagues relegate, and the top league does not promote", relegated and profile.league.last == "stay" and profile.league.tier == "premier")
end

local SideTasks = require("../src/simulation/SideTasks")

do
	local profile = rich()
	for x = 4, 7 do
		for y = 4, 9 do
			Grid.place(profile, x, y, "grass")
		end
	end
	Grid.place(profile, 5, 3, "goal", "south")
	Grid.place(profile, 5, 10, "goal", "north")
	local sundayMissing = Events.missing(profile, "sunday")
	check("kickabout is 5v5 and sunday needs 7v7", Events.eligible(profile, "kickabout") == true and sundayMissing[1] == "7v7")
end

do
	local profile = rich()
	kickaboutPitch(profile)
	for y = 12, 15 do
		for x = 2, 7 do
			Grid.place(profile, x, y, "grass")
		end
	end
	for y = 2, 15 do
		Grid.place(profile, 8, y, "grass")
	end
	local blocked, reason = Grid.place(profile, 9, 2, "grass")
	local cash = profile.cash
	Monetisation.setPitchPass(profile, true)
	local opened = Grid.place(profile, 9, 2, "grass")
	check("the pitch pass is required to grow an 11v11 pitch", blocked == false and reason == "pitch pass" and opened == true and profile.cash == cash - 250)
end

do
	local profile = rich()
	local closed = SideTasks.complete(profile, "grill")
	Grid.place(profile, 1, 1, "food_stand")
	local paid, amount = SideTasks.complete(profile, "grill")
	local repeatTask = SideTasks.complete(profile, "grill")
	profile.matchesHosted = 1
	local again = SideTasks.complete(profile, "grill")
	local coaching = SideTasks.complete(profile, "coaching")
	check(
		"side tasks pay, and a grill shift needs the food stand",
		closed == false and paid == true and amount == 800 and repeatTask == false and again == true and coaching == true
	)
end

do
	local plain = rich()
	kickaboutPitch(plain)
	local fed = rich()
	kickaboutPitch(fed)
	Grid.place(fed, 1, 1, "food_stand")
	local without = Match.preview(plain, "kickabout", 1).beforeMultiplier
	local withFood = Match.preview(fed, "kickabout", 1).beforeMultiplier
	Grid.place(fed, 1, 3, "club_shop")
	Kits.buy(fed, "hoops")
	local withMerch = Match.preview(fed, "kickabout", 1).beforeMultiplier
	check("food stands and the club shop add matchday profit", withFood == without + 200 and withMerch == withFood + 400 + 250)
end

do
	local server = Session.newServer()
	local open = Session.list(server)
	local chosen = Session.claim(server, 7, 3)
	local taken, takenReason = Session.claim(server, 8, 3)
	local again = Session.claim(server, 7, 3)
	local other, otherReason = Session.claim(server, 7, 1)
	check(
		"a player picks an open plot and keeps it",
		open[3].owner == nil and chosen == 3 and taken == nil and takenReason == "taken" and again == 3 and other == nil and otherReason == "already claimed"
	)
end

if failures > 0 then
	error(tostring(failures) .. " test(s) failed")
end

print("all tests passed")
