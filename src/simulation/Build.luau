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

local Pitch = load("Pitch")

local Build = {}

local function key(x, y)
	return string.format("%d,%d", x, y)
end

local function add(slots, profile, x, y, slot)
	if x < 1 or y < 1 or x > profile.width or y > profile.height then
		return
	end
	slot.x = x
	slot.y = y
	slots[key(x, y)] = slot
end

function Build.slots(profile)
	local pitch = Pitch.inspect(profile)
	if not pitch.valid then
		return nil, pitch.reason
	end
	local slots = {}
	local minX, minY, maxX, maxY = pitch.minX, pitch.minY, pitch.maxX, pitch.maxY

	for x = minX, maxX do
		local atEnd = x == minX or x == maxX
		add(slots, profile, x, minY - 1, { edge = true, angle = atEnd, facing = "south" })
		add(slots, profile, x, maxY + 1, { edge = true, angle = atEnd, facing = "north" })
	end
	for y = minY, maxY do
		local atEnd = y == minY or y == maxY
		add(slots, profile, minX - 1, y, { edge = true, angle = atEnd, facing = "east" })
		add(slots, profile, maxX + 1, y, { edge = true, angle = atEnd, facing = "west" })
	end

	add(slots, profile, minX - 1, minY - 1, { corner = "nw" })
	add(slots, profile, maxX + 1, minY - 1, { corner = "ne" })
	add(slots, profile, maxX + 1, maxY + 1, { corner = "se" })
	add(slots, profile, minX - 1, maxY + 1, { corner = "sw" })
	return slots
end

local function fits(slot, shape)
	if shape == "corner" then
		return slot.corner ~= nil
	end
	if shape == "angle" then
		return slot.angle == true
	end
	if shape == "straight" then
		return slot.edge == true
	end
	return false
end

function Build.resolve(profile, x, y, shape)
	local slots, reason = Build.slots(profile)
	if slots == nil then
		return nil, reason
	end
	local exact = slots[key(x, y)]
	if exact ~= nil and fits(exact, shape) then
		return exact
	end

	local best = nil
	for _, slot in pairs(slots) do
		if fits(slot, shape) then
			local dx = math.abs(slot.x - x)
			local dy = math.abs(slot.y - y)
			local distance = math.max(dx, dy)
			local diagonal = if dx > 0 and dy > 0 then 1 else 0
			if distance <= 1 then
				local better = best == nil
					or distance < best.distance
					or (distance == best.distance and diagonal < best.diagonal)
					or (distance == best.distance and diagonal == best.diagonal and (slot.y < best.slot.y or (slot.y == best.slot.y and slot.x < best.slot.x)))
				if better then
					best = { slot = slot, distance = distance, diagonal = diagonal }
				end
			end
		end
	end
	if best == nil then
		return nil, "off the pitch"
	end
	return best.slot
end

return Build
