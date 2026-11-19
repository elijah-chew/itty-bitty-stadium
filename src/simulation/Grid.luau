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
local Build = load("Build")
local Pitch = load("Pitch")

local Grid = {}

local FACINGS = {
	north = true,
	east = true,
	south = true,
	west = true,
}

function Grid.key(x, y)
	return string.format("%d,%d", x, y)
end

function Grid.get(profile, x, y)
	return profile.cells[Grid.key(x, y)]
end

local function inBounds(profile, x, y)
	return x == math.floor(x) and y == math.floor(y) and x >= 1 and y >= 1 and x <= profile.width and y <= profile.height
end

function Grid.place(profile, x, y, kind, facing)
	local piece = Catalog.pieces[kind]
	if piece == nil then
		return false, "unknown piece"
	end
	if piece.shape ~= nil then
		local slot, snapReason = Build.resolve(profile, x, y, piece.shape)
		if slot == nil then
			return false, snapReason
		end
		x = slot.x
		y = slot.y
		facing = slot.facing or slot.corner
	end
	if not inBounds(profile, x, y) then
		return false, "out of bounds"
	end
	local key = Grid.key(x, y)
	if profile.cells[key] ~= nil then
		return false, "occupied"
	end
	if kind == "grass" and not profile.pitchPass and Pitch.spansEleven(profile, x, y) then
		return false, "pitch pass"
	end
	if piece.facing and not FACINGS[facing] then
		return false, "facing"
	end
	if profile.cash < piece.cost then
		return false, "not enough cash"
	end

	profile.cash = profile.cash - piece.cost
	local cell = { kind = kind }
	if piece.facing or piece.shape ~= nil then
		cell.facing = facing
	end
	profile.cells[key] = cell
	return true
end

function Grid.remove(profile, x, y)
	if not inBounds(profile, x, y) then
		return false, "out of bounds"
	end
	local key = Grid.key(x, y)
	local cell = profile.cells[key]
	if cell == nil then
		return false, "empty"
	end
	local piece = Catalog.pieces[cell.kind]
	local refund = if piece then piece.cost else 0
	profile.cash = profile.cash + refund
	profile.cells[key] = nil
	return true, refund
end

function Grid.expand(profile)
	if profile.expansions >= Catalog.maxExpansions then
		return false, "expansion limit"
	end
	local cost = Catalog.expansionCosts[profile.expansions + 1]
	if profile.cash < cost then
		return false, "not enough cash"
	end
	profile.cash = profile.cash - cost
	profile.expansions = profile.expansions + 1
	profile.width = profile.width + Catalog.expansionStrip
	return true
end

return Grid
