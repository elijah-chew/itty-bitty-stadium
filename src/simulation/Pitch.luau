local Pitch = {}

local function parseKey(key)
	local x, y = string.match(key, "^(%-?%d+),(%-?%d+)$")
	return tonumber(x), tonumber(y)
end

local function pairNorthSouth(minX, minY, maxX, maxY)
	local width = maxX - minX + 1
	local centerX = minX + math.floor((width - 1) / 2)
	return {
		{ x = centerX, y = minY - 1, facing = "south" },
		{ x = centerX, y = maxY + 1, facing = "north" },
	}
end

local function pairEastWest(minX, minY, maxX, maxY)
	local height = maxY - minY + 1
	local centerY = minY + math.floor((height - 1) / 2)
	return {
		{ x = minX - 1, y = centerY, facing = "east" },
		{ x = maxX + 1, y = centerY, facing = "west" },
	}
end

local function collectGoals(profile)
	local goals = {}
	for key, cell in pairs(profile.cells) do
		if cell.kind == "goal" then
			local x, y = parseKey(key)
			table.insert(goals, { x = x, y = y, facing = cell.facing })
		end
	end
	return goals
end

local function sameGoal(a, b)
	return a.x == b.x and a.y == b.y and a.facing == b.facing
end

local function matchesPair(goals, pair)
	if #goals ~= 2 then
		return false
	end
	local function has(target)
		for _, goal in ipairs(goals) do
			if sameGoal(goal, target) then
				return true
			end
		end
		return false
	end
	return has(pair[1]) and has(pair[2])
end

function Pitch.inspect(profile)
	local minX, minY, maxX, maxY
	local count = 0
	for key, cell in pairs(profile.cells) do
		if cell.kind == "grass" then
			local x, y = parseKey(key)
			count = count + 1
			if minX == nil or x < minX then
				minX = x
			end
			if minY == nil or y < minY then
				minY = y
			end
			if maxX == nil or x > maxX then
				maxX = x
			end
			if maxY == nil or y > maxY then
				maxY = y
			end
		end
	end

	if count == 0 then
		return { valid = false, reason = "no grass" }
	end

	local width = maxX - minX + 1
	local height = maxY - minY + 1
	local rect = {
		valid = false,
		minX = minX,
		minY = minY,
		maxX = maxX,
		maxY = maxY,
		width = width,
		height = height,
	}

	for x = minX, maxX do
		for y = minY, maxY do
			local cell = profile.cells[string.format("%d,%d", x, y)]
			if cell == nil or cell.kind ~= "grass" then
				rect.reason = "not a rectangle"
				return rect
			end
		end
	end

	local sizeOk = (width >= 4 and height >= 6) or (width >= 6 and height >= 4)
	if not sizeOk then
		rect.reason = "too small"
		return rect
	end

	local pairs = {}
	if height > width then
		table.insert(pairs, pairNorthSouth(minX, minY, maxX, maxY))
	elseif width > height then
		table.insert(pairs, pairEastWest(minX, minY, maxX, maxY))
	else
		table.insert(pairs, pairNorthSouth(minX, minY, maxX, maxY))
		table.insert(pairs, pairEastWest(minX, minY, maxX, maxY))
	end

	local goals = collectGoals(profile)
	for _, pair in ipairs(pairs) do
		if matchesPair(goals, pair) then
			rect.valid = true
			rect.reason = "ok"
			return rect
		end
	end

	rect.reason = "goals"
	return rect
end

function Pitch.sizeClass(width, height)
	local shortSide = math.min(width, height)
	local longSide = math.max(width, height)
	if shortSide >= 8 and longSide >= 14 then
		return "11v11"
	end
	if shortSide >= 6 and longSide >= 10 then
		return "7v7"
	end
	if shortSide >= 4 and longSide >= 6 then
		return "5v5"
	end
	return nil
end

function Pitch.rank(class)
	if class == "11v11" then
		return 3
	end
	if class == "7v7" then
		return 2
	end
	if class == "5v5" then
		return 1
	end
	return 0
end

function Pitch.spansEleven(profile, extraX, extraY)
	local minX, minY, maxX, maxY
	local function consider(x, y)
		if minX == nil or x < minX then
			minX = x
		end
		if minY == nil or y < minY then
			minY = y
		end
		if maxX == nil or x > maxX then
			maxX = x
		end
		if maxY == nil or y > maxY then
			maxY = y
		end
	end
	for key, cell in pairs(profile.cells) do
		if cell.kind == "grass" then
			consider(parseKey(key))
		end
	end
	if extraX ~= nil then
		consider(extraX, extraY)
	end
	if minX == nil then
		return false
	end
	return Pitch.sizeClass(maxX - minX + 1, maxY - minY + 1) == "11v11"
end

return Pitch
