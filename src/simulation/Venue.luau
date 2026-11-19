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

local Venue = {}

function Venue.capacity(profile)
	local total = 0
	for _, cell in pairs(profile.cells) do
		local piece = Catalog.pieces[cell.kind]
		if piece ~= nil and piece.capacity ~= nil then
			total = total + piece.capacity
		end
	end
	return total
end

function Venue.facilities(profile)
	local have = {}
	for _, cell in pairs(profile.cells) do
		local piece = Catalog.pieces[cell.kind]
		if piece ~= nil and piece.facility ~= nil then
			have[piece.facility] = true
		end
	end
	return have
end

function Venue.attendance(profile)
	return math.min(Venue.capacity(profile), profile.fans)
end

function Venue.count(profile, kind)
	local total = 0
	for _, cell in pairs(profile.cells) do
		if cell.kind == kind then
			total = total + 1
		end
	end
	return total
end

function Venue.matchdayProfit(profile, attendance)
	local food = Venue.count(profile, "food_stand") * (Catalog.foodPerStand + math.floor(attendance / 50) * Catalog.foodPerFifty)
	local merch = 0
	if Venue.facilities(profile).club_shop then
		merch = Catalog.merchBase + math.floor(profile.fans / 100) * Catalog.merchPerHundred
		if profile.jersey ~= nil and profile.jersey ~= "" then
			merch = merch + Catalog.jerseyMerch
		end
	end
	return food + merch
end

return Venue
