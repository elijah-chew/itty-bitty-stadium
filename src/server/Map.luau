local Map = {}

local CELL = 8
local GRASS = Color3.fromRGB(108, 186, 78)
local GRASS_DARK = Color3.fromRGB(86, 164, 68)
local STRIPE = Color3.fromRGB(126, 204, 92)
local CREAM = Color3.fromRGB(245, 241, 230)
local INK = Color3.fromRGB(32, 36, 42)
local WHITE = Color3.fromRGB(248, 248, 244)
local PATH = Color3.fromRGB(222, 216, 204)
local ROAD = Color3.fromRGB(96, 102, 108)
local NAVY = Color3.fromRGB(36, 78, 168)
local RED = Color3.fromRGB(196, 58, 52)
local WOOD = Color3.fromRGB(186, 132, 74)
local SKIN = Color3.fromRGB(242, 206, 168)
local GLASS = Color3.fromRGB(166, 214, 228)

local DIR = {
	south = Vector3.new(0, 0, 1),
	north = Vector3.new(0, 0, -1),
	east = Vector3.new(1, 0, 0),
	west = Vector3.new(-1, 0, 0),
}

local function part(parent, name, size, cf, color, material, shape)
	local block = Instance.new("Part")
	block.Name = name
	block.Anchored = true
	block.Size = size
	block.CFrame = cf
	block.Color = color
	block.Material = material or Enum.Material.SmoothPlastic
	block.TopSurface = Enum.SurfaceType.Smooth
	block.BottomSurface = Enum.SurfaceType.Smooth
	block.CastShadow = true
	if shape ~= nil then
		block.Shape = shape
	end
	block.Parent = parent
	return block
end

local function sign(parent, text, colour, face)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.PixelsPerStud = 40
	gui.Parent = parent
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = colour or CREAM
	label.Text = text
	label.Parent = gui
end

local function facingFrame(position, facing)
	local forward = DIR[facing] or DIR.south
	local up = Vector3.yAxis
	local right = up:Cross(forward)
	return CFrame.fromMatrix(position, right, up, -forward)
end

local function dress()
	local Lighting = game:GetService("Lighting")
	Lighting.ClockTime = 14.2
	Lighting.Brightness = 2.8
	Lighting.Ambient = Color3.fromRGB(190, 198, 206)
	Lighting.OutdoorAmbient = Color3.fromRGB(210, 216, 214)
	Lighting.EnvironmentDiffuseScale = 0.35
	Lighting.EnvironmentSpecularScale = 0.2
	Lighting.GlobalShadows = true
	pcall(function()
		Lighting.Technology = Enum.Technology.ShadowMap
	end)
	local atmosphere = Lighting:FindFirstChild("StadiumAir")
	if atmosphere == nil then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Name = "StadiumAir"
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = 0.08
	atmosphere.Offset = 0.2
	atmosphere.Color = Color3.fromRGB(220, 232, 242)
	atmosphere.Decay = Color3.fromRGB(210, 220, 206)
	atmosphere.Glare = 0.02
	atmosphere.Haze = 0.15
end

local function tree(parent, position, scale)
	scale = scale or 1
	local trunk = part(
		parent,
		"Trunk",
		Vector3.new(4.2 * scale, 1.1 * scale, 1.1 * scale),
		CFrame.new(position + Vector3.new(0, 2.1 * scale, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		WOOD,
		Enum.Material.SmoothPlastic,
		Enum.PartType.Cylinder
	)
	part(
		parent,
		"Crown",
		Vector3.new(6.4, 6.4, 6.4) * scale,
		CFrame.new(position + Vector3.new(0, 6.2 * scale, 0)),
		Color3.fromRGB(72, 168, 74),
		Enum.Material.SmoothPlastic,
		Enum.PartType.Ball
	)
	part(
		parent,
		"Crown",
		Vector3.new(4.2, 4.2, 4.2) * scale,
		CFrame.new(position + Vector3.new(1.4 * scale, 8.1 * scale, 0.4 * scale)),
		Color3.fromRGB(98, 190, 86),
		Enum.Material.SmoothPlastic,
		Enum.PartType.Ball
	)
end

local function person(parent, position, shirt, pants)
	part(parent, "Legs", Vector3.new(1.6, 1.5, 0.8), CFrame.new(position + Vector3.new(0, 0.75, 0)), pants)
	part(parent, "Torso", Vector3.new(1.8, 1.7, 0.9), CFrame.new(position + Vector3.new(0, 2.3, 0)), shirt)
	part(parent, "Head", Vector3.new(1.15, 1.15, 1.15), CFrame.new(position + Vector3.new(0, 3.55, 0)), SKIN, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
end

local function flag(parent, position, color)
	local pole = part(parent, "Pole", Vector3.new(0.35, 12, 0.35), CFrame.new(position + Vector3.new(0, 6, 0)), WHITE)
	part(parent, "Flag", Vector3.new(0.15, 2.6, 4.2), pole.CFrame * CFrame.new(0, 3.6, 2.2), color)
end

local function line(parent, center, size)
	local mark = part(parent, "Line", size, CFrame.new(center + Vector3.new(0, 0.08, 0)), WHITE)
	mark.CanCollide = false
	mark.CanQuery = false
	return mark
end

local function pitchMarkings(parent, originX, originZ)
	local width = 12 * CELL
	local depth = 16 * CELL
	local cx = originX + width / 2
	local cz = originZ + depth / 2
	line(parent, Vector3.new(cx, 0.24, cz), Vector3.new(width - 8, 0.06, 0.45))
	line(parent, Vector3.new(cx, 0.24, originZ + 5), Vector3.new(width - 8, 0.06, 0.45))
	line(parent, Vector3.new(cx, 0.24, originZ + depth - 5), Vector3.new(width - 8, 0.06, 0.45))
	line(parent, Vector3.new(originX + 5, 0.24, cz), Vector3.new(0.45, 0.06, depth - 8))
	line(parent, Vector3.new(originX + width - 5, 0.24, cz), Vector3.new(0.45, 0.06, depth - 8))
	local spot = part(parent, "Spot", Vector3.new(0.08, 2.4, 2.4), CFrame.new(cx, 0.36, cz) * CFrame.Angles(0, 0, math.rad(90)), WHITE, Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
	spot.CanCollide = false
	spot.CanQuery = false
end

local function along(position, direction)
	local axis = Vector3.new(direction.X, 0, direction.Z).Unit
	return CFrame.fromMatrix(position, axis, Vector3.yAxis, axis:Cross(Vector3.yAxis))
end

local function fenceRun(parent, a, b)
	local delta = b - a
	local length = delta.Magnitude
	local mid = (a + b) / 2
	part(parent, "Rail", Vector3.new(length, 0.28, 0.28), along(mid + Vector3.new(0, 1.15, 0), delta), WHITE)
	part(parent, "Rail", Vector3.new(length, 0.28, 0.28), along(mid + Vector3.new(0, 2.35, 0), delta), WHITE)
	part(parent, "Post", Vector3.new(0.4, 2.8, 0.4), CFrame.new(a + Vector3.new(0, 1.4, 0)), WHITE)
	part(parent, "Post", Vector3.new(0.4, 2.8, 0.4), CFrame.new(b + Vector3.new(0, 1.4, 0)), WHITE)
end

local function building(parent, cf, size, wall, roof)
	part(parent, "Walls", size, cf * CFrame.new(0, size.Y / 2, 0), wall)
	part(parent, "Fascia", Vector3.new(size.X + 0.5, 0.55, size.Z + 0.5), cf * CFrame.new(0, size.Y + 0.15, 0), roof)
	part(parent, "Roof", Vector3.new(size.X - 0.8, 0.28, size.Z - 0.8), cf * CFrame.new(0, size.Y + 0.45, 0), Color3.fromRGB(236, 232, 222))
	part(parent, "Step", Vector3.new(2.6, 0.35, 1.1), cf * CFrame.new(0, 0.2, size.Z / 2 + 0.4), PATH)
	part(parent, "Door", Vector3.new(1.7, 2.7, 0.18), cf * CFrame.new(0, 1.45, size.Z / 2 + 0.02), Color3.fromRGB(58, 44, 34))
	part(parent, "Sill", Vector3.new(size.X - 1.4, 0.16, 0.22), cf * CFrame.new(0, 2.55, size.Z / 2 + 0.02), roof)
end

local function windows(parent, cf, floors, width, depth)
	for level = 1, floors do
		local glass = part(parent, "Glass", Vector3.new(width, 0.9, 0.16), cf * CFrame.new(0, 2.2 + (level - 1) * 2.15, depth / 2 + 0.04), GLASS)
		glass.Transparency = 0.15
	end
end

local function goal(parent, cf)
	part(parent, "Post", Vector3.new(0.35, 4.6, 0.35), cf * CFrame.new(-3.15, 2.3, 0), WHITE)
	part(parent, "Post", Vector3.new(0.35, 4.6, 0.35), cf * CFrame.new(3.15, 2.3, 0), WHITE)
	part(parent, "Bar", Vector3.new(6.65, 0.32, 0.32), cf * CFrame.new(0, 4.5, 0), WHITE)
	local back = part(parent, "Net", Vector3.new(6.1, 4.2, 0.12), cf * CFrame.new(0, 2.2, -1.5), Color3.fromRGB(236, 240, 236))
	back.Transparency = 0.28
	back.CanCollide = false
	local sideL = part(parent, "NetSide", Vector3.new(0.12, 4.2, 1.5), cf * CFrame.new(-3.05, 2.2, -0.75), Color3.fromRGB(236, 240, 236))
	sideL.Transparency = 0.28
	sideL.CanCollide = false
	local sideR = part(parent, "NetSide", Vector3.new(0.12, 4.2, 1.5), cf * CFrame.new(3.05, 2.2, -0.75), Color3.fromRGB(236, 240, 236))
	sideR.Transparency = 0.28
	sideR.CanCollide = false
end

local function stand(parent, cf, rows, seat)
	part(parent, "Plinth", Vector3.new(7.3, 0.7, 7), cf * CFrame.new(0, 0.35, 0), Color3.fromRGB(214, 214, 208))
	for index = 1, rows do
		local rise = 0.85 + (index - 1) * 0.72
		local back = -2.2 + (index - 1) * 0.85
		part(parent, "Riser", Vector3.new(7.1, 0.72, 0.9), cf * CFrame.new(0, rise, back), Color3.fromRGB(186, 186, 180))
		part(parent, "Seats", Vector3.new(6.7, 0.28, 0.7), cf * CFrame.new(0, rise + 0.35, back + 0.05), seat)
	end
	local roofY = 1.3 + rows * 0.72
	part(parent, "Post", Vector3.new(0.28, roofY, 0.28), cf * CFrame.new(-3.2, roofY / 2, -2.4), WHITE)
	part(parent, "Post", Vector3.new(0.28, roofY, 0.28), cf * CFrame.new(3.2, roofY / 2, -2.4), WHITE)
	part(parent, "Roof", Vector3.new(7.6, 0.22, 6.2), cf * CFrame.new(0, roofY, -0.6), CREAM)
end

local function fansOnStand(parent, cf, rows, shirt)
	local count = math.min(rows, 2)
	for index = 1, count do
		local rise = 0.85 + (index - 1) * 0.72
		local back = -2.2 + (index - 1) * 0.85
		local spot = cf * CFrame.new(index == 1 and -1.4 or 1.5, rise + 0.9, back)
		person(parent, spot.Position, shirt, Color3.fromRGB(36, 40, 48))
	end
end

local function assemble(parent, kind, cf)
	if kind == "grass" then
		local stripe = (math.floor(cf.Position.X / CELL) + math.floor(cf.Position.Z / CELL)) % 2 == 0
		local tile = part(parent, "Turf", Vector3.new(CELL - 0.2, 0.28, CELL - 0.2), cf * CFrame.new(0, 0.16, 0), if stripe then STRIPE else GRASS)
		tile.CanQuery = true
		return
	end
	if kind == "goal" then
		goal(parent, cf)
		return
	end
	if kind == "stand_small" then
		stand(parent, cf, 3, NAVY)
		fansOnStand(parent, cf, 3, Color3.fromRGB(230, 70, 64))
		return
	end
	if kind == "stand_medium" then
		stand(parent, cf, 5, RED)
		fansOnStand(parent, cf, 4, NAVY)
		return
	end
	if kind == "stand_corner" then
		stand(parent, cf, 3, Color3.fromRGB(46, 130, 92))
		return
	end
	if kind == "stand_angle" then
		stand(parent, cf, 3, Color3.fromRGB(214, 164, 54))
		return
	end
	if kind == "food_stand" then
		part(parent, "Counter", Vector3.new(6.2, 2.2, 2.8), cf * CFrame.new(0, 1.1, 0.4), CREAM)
		part(parent, "Roof", Vector3.new(7, 0.35, 3.6), cf * CFrame.new(0, 3.2, 0.1), RED)
		part(parent, "Stripe", Vector3.new(0.9, 0.38, 3.6), cf * CFrame.new(-2, 3.22, 0.1), WHITE)
		part(parent, "Stripe", Vector3.new(0.9, 0.38, 3.6), cf * CFrame.new(0, 3.22, 0.1), WHITE)
		part(parent, "Stripe", Vector3.new(0.9, 0.38, 3.6), cf * CFrame.new(2, 3.22, 0.1), WHITE)
		return
	end
	if kind == "floodlights" then
		local mast = part(parent, "Mast", Vector3.new(0.55, 14, 0.55), cf * CFrame.new(0, 7, 0), Color3.fromRGB(70, 76, 82))
		local head = mast.CFrame * CFrame.new(0, 6.6, 1.2)
		part(parent, "Gantry", Vector3.new(4.4, 0.3, 1.1), head, Color3.fromRGB(54, 58, 64))
		part(parent, "Lamp", Vector3.new(1.3, 0.55, 0.7), head * CFrame.new(-1.2, -0.4, 0), Color3.fromRGB(255, 246, 214), Enum.Material.Neon)
		part(parent, "Lamp", Vector3.new(1.3, 0.55, 0.7), head * CFrame.new(1.2, -0.4, 0), Color3.fromRGB(255, 246, 214), Enum.Material.Neon)
		return
	end
	if kind == "changing_room" then
		building(parent, cf, Vector3.new(6.8, 4.4, 5.6), Color3.fromRGB(232, 214, 168), WOOD)
		return
	end
	if kind == "gym" then
		building(parent, cf, Vector3.new(6.8, 6.2, 5.8), CREAM, RED)
		windows(parent, cf, 2, 4.8, 5.8)
		return
	end
	if kind == "amenities" then
		building(parent, cf, Vector3.new(6.8, 4.2, 5.8), Color3.fromRGB(168, 206, 184), Color3.fromRGB(64, 110, 86))
		return
	end
	if kind == "ticket_office" then
		building(parent, cf, Vector3.new(5.8, 4, 4.2), CREAM, Color3.fromRGB(214, 120, 64))
		part(parent, "Window", Vector3.new(3.2, 1.1, 0.16), cf * CFrame.new(0, 2.6, 2.15), GLASS)
		return
	end
	if kind == "medical" then
		building(parent, cf, Vector3.new(6.2, 4.6, 5.2), WHITE, RED)
		part(parent, "Cross", Vector3.new(0.4, 1.8, 0.16), cf * CFrame.new(1.8, 3.2, 2.65), RED)
		part(parent, "Cross", Vector3.new(1.8, 0.4, 0.16), cf * CFrame.new(1.8, 3.2, 2.65), RED)
		return
	end
	if kind == "club_shop" then
		building(parent, cf, Vector3.new(6.6, 4.8, 5.4), NAVY, CREAM)
		part(parent, "Front", Vector3.new(4.8, 2.4, 0.16), cf * CFrame.new(0, 2.2, 2.75), GLASS)
		return
	end
	if kind == "club_hotel" then
		building(parent, cf, Vector3.new(6.4, 11, 5.6), CREAM, NAVY)
		windows(parent, cf, 4, 4.4, 5.6)
		return
	end
	if kind == "scoreboard" then
		local board = part(parent, "Board", Vector3.new(6.8, 3.6, 0.45), cf * CFrame.new(0, 5.6, 0), INK)
		part(parent, "Leg", Vector3.new(0.4, 3.8, 0.4), cf * CFrame.new(-2.2, 1.9, 0), Color3.fromRGB(70, 74, 78))
		part(parent, "Leg", Vector3.new(0.4, 3.8, 0.4), cf * CFrame.new(2.2, 1.9, 0), Color3.fromRGB(70, 74, 78))
		sign(board, "0  -  0", Color3.fromRGB(120, 230, 140), Enum.NormalId.Front)
		return
	end
	part(parent, kind, Vector3.new(CELL - 0.4, 4, CELL - 0.4), cf * CFrame.new(0, 2, 0), CREAM)
end

local function clearName(name)
	local existing = workspace:FindFirstChild(name)
	if existing ~= nil then
		existing:Destroy()
	end
end

local function skyline(parent)
	local towers = {
		{ -420, 28, 16, Color3.fromRGB(186, 206, 220) },
		{ -360, 46, 18, Color3.fromRGB(120, 156, 196) },
		{ -300, 34, 14, Color3.fromRGB(230, 232, 228) },
		{ -230, 58, 20, Color3.fromRGB(92, 132, 176) },
		{ 230, 40, 16, Color3.fromRGB(210, 216, 214) },
		{ 300, 62, 18, Color3.fromRGB(70, 112, 160) },
		{ 370, 36, 15, Color3.fromRGB(176, 198, 214) },
		{ 440, 24, 14, Color3.fromRGB(230, 230, 226) },
	}
	for _, tower in ipairs(towers) do
		local x, height, width, color = tower[1], tower[2], tower[3], tower[4]
		local block = part(parent, "Tower", Vector3.new(width, height, width), CFrame.new(x, height / 2 - 1, -340), color)
		for level = 1, math.floor(height / 6) do
			part(parent, "Band", Vector3.new(width + 0.2, 0.6, width + 0.2), block.CFrame * CFrame.new(0, -height / 2 + level * 6, 0), GLASS)
		end
	end
end

function Map.fault(message)
	local lobby = workspace:FindFirstChild("Lobby")
	local board = lobby and lobby:FindFirstChild("Board")
	if board == nil then
		return
	end
	local gui = board:FindFirstChildOfClass("SurfaceGui")
	local label = gui and gui:FindFirstChildOfClass("TextLabel")
	if label ~= nil then
		label.TextScaled = false
		label.TextSize = 28
		label.TextWrapped = true
		label.Text = message
	end
end

function Map.build()
	dress()
	local baseplate = workspace:FindFirstChild("Baseplate")
	if baseplate ~= nil then
		baseplate:Destroy()
	end
	for _, child in ipairs(workspace:GetChildren()) do
		if child:IsA("SpawnLocation") then
			child:Destroy()
		end
	end
	clearName("Lobby")
	clearName("Plots")
	clearName("Field")
	clearName("Skyline")

	local field = Instance.new("Folder")
	field.Name = "Field"
	field.Parent = workspace
	part(field, "Grass", Vector3.new(2200, 4, 1600), CFrame.new(0, -2.2, 160), GRASS_DARK)
	part(field, "Road", Vector3.new(1600, 0.4, 18), CFrame.new(0, 0.15, 36), ROAD)
	part(field, "Path", Vector3.new(14, 0.35, 70), CFrame.new(0, 0.2, 0), PATH)

	local horizon = Instance.new("Folder")
	horizon.Name = "Skyline"
	horizon.Parent = workspace
	skyline(horizon)

	local lobby = Instance.new("Folder")
	lobby.Name = "Lobby"
	lobby.Parent = workspace

	building(lobby, CFrame.new(0, 0, -18), Vector3.new(28, 8, 14), CREAM, RED)
	windows(lobby, CFrame.new(0, 0, -18), 2, 16, 14)
	local board = part(lobby, "Board", Vector3.new(24, 5, 0.6), CFrame.new(0, 11.2, -10.6), INK)
	sign(board, "ITTY BITTY STADIUM", CREAM, Enum.NormalId.Front)
	sign(board, "ITTY BITTY STADIUM", CREAM, Enum.NormalId.Back)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Arrival"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.CFrame = CFrame.new(0, 0.5, 8)
	spawn.Color = Color3.fromRGB(72, 176, 96)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.Parent = lobby

	flag(lobby, Vector3.new(-18, 0, -6), RED)
	flag(lobby, Vector3.new(18, 0, -6), NAVY)
	goal(lobby, CFrame.new(-34, 0, 6))
	tree(lobby, Vector3.new(-48, 0, 16), 1.15)
	tree(lobby, Vector3.new(46, 0, 14), 1)
	tree(lobby, Vector3.new(-28, 0, -28), 0.85)
	tree(lobby, Vector3.new(32, 0, -30), 1.05)
	tree(lobby, Vector3.new(58, 0, -8), 0.75)
	person(lobby, Vector3.new(-8, 0, 12), NAVY, Color3.fromRGB(40, 44, 52))
	person(lobby, Vector3.new(7, 0, 16), RED, WHITE)
	person(lobby, Vector3.new(12, 0, 10), CREAM, NAVY)

	local plotsFolder = Instance.new("Folder")
	plotsFolder.Name = "Plots"
	plotsFolder.Parent = workspace

	local models = {}
	for index = 1, 6 do
		local model = Instance.new("Model")
		model.Name = "Plot" .. index
		local originX = -660 + (index - 1) * 240
		local originZ = 80
		local width = 24 * CELL
		local depth = 16 * CELL
		local ground = part(model, "Ground", Vector3.new(width, 2, depth), CFrame.new(originX + width / 2, -1, originZ + depth / 2), GRASS_DARK)
		ground.CanQuery = true
		local openWidth = 12 * CELL
		local pitch = part(model, "Pitch", Vector3.new(openWidth, 0.25, depth), CFrame.new(originX + openWidth / 2, 0.12, originZ + depth / 2), GRASS)
		pitch.CanCollide = false
		pitch.CanQuery = false
		for stripe = 0, 15 do
			if stripe % 2 == 0 then
				local band = part(
					model,
					"Stripe",
					Vector3.new(openWidth - 1.2, 0.06, CELL - 0.35),
					CFrame.new(originX + openWidth / 2, 0.28, originZ + stripe * CELL + CELL / 2),
					STRIPE
				)
				band.CanCollide = false
				band.CanQuery = false
			end
		end
		for column = 0, 12 do
			local mark = line(model, Vector3.new(originX + column * CELL, 0.22, originZ + depth / 2), Vector3.new(0.12, 0.04, depth))
			mark.Transparency = 0.45
		end
		for row = 0, 16 do
			local mark = line(model, Vector3.new(originX + openWidth / 2, 0.22, originZ + row * CELL), Vector3.new(openWidth, 0.04, 0.12))
			mark.Transparency = 0.45
		end
		local locked = part(model, "Locked", Vector3.new(width - openWidth, 0.2, depth), CFrame.new(originX + openWidth + (width - openWidth) / 2, 0.12, originZ + depth / 2), Color3.fromRGB(72, 118, 64))
		locked.CanCollide = false
		locked.CanQuery = false
		pitchMarkings(model, originX, originZ)
		local west, east = originX, originX + width
		local north, south = originZ, originZ + depth
		local gate = 16
		fenceRun(model, Vector3.new(west, 0, north), Vector3.new(east, 0, north))
		fenceRun(model, Vector3.new(west, 0, north), Vector3.new(west, 0, south))
		fenceRun(model, Vector3.new(east, 0, north), Vector3.new(east, 0, south))
		fenceRun(model, Vector3.new(west, 0, south), Vector3.new(originX + width / 2 - gate, 0, south))
		fenceRun(model, Vector3.new(originX + width / 2 + gate, 0, south), Vector3.new(east, 0, south))

		local origin = part(model, "Origin", Vector3.new(0.4, 0.4, 0.4), CFrame.new(originX, 0, originZ), Color3.fromRGB(230, 210, 140))
		origin.Transparency = 1
		origin.CanCollide = false
		origin.CanQuery = false

		local gateX = originX + 6 * CELL
		local gateZ = originZ + depth + 10
		local claim = part(model, "Claim", Vector3.new(12, 1, 8), CFrame.new(gateX, 0.5, gateZ), Color3.fromRGB(64, 168, 96))
		part(model, "GateLeft", Vector3.new(1.2, 6, 1.2), CFrame.new(gateX - 8, 3, originZ + depth), CREAM)
		part(model, "GateRight", Vector3.new(1.2, 6, 1.2), CFrame.new(gateX + 8, 3, originZ + depth), CREAM)
		local marker = part(model, "Number", Vector3.new(12, 3, 0.5), CFrame.new(gateX, 6.2, originZ + depth - 1), INK)
		sign(marker, "PLOT " .. index, CREAM, Enum.NormalId.Back)
		sign(marker, "PLOT " .. index, CREAM, Enum.NormalId.Front)

		tree(model, Vector3.new(originX - 10, 0, originZ + 20), 0.9)
		tree(model, Vector3.new(originX + width + 10, 0, originZ + 30), 1)
		tree(model, Vector3.new(originX + width + 8, 0, originZ + depth - 10), 0.8)

		local built = Instance.new("Folder")
		built.Name = "Built"
		built.Parent = model
		model.Parent = plotsFolder
		models[index] = model
	end

	return models
end

function Map.redraw(plotModel, profile)
	local built = plotModel:FindFirstChild("Built")
	local origin = plotModel:FindFirstChild("Origin")
	if built == nil or origin == nil then
		return
	end
	local openColumns = if profile ~= nil then profile.width else 12
	local pitch = plotModel:FindFirstChild("Pitch")
	local locked = plotModel:FindFirstChild("Locked")
	if pitch ~= nil and locked ~= nil then
		local depth = 16 * CELL
		local total = 24 * CELL
		local openWidth = math.clamp(openColumns, 1, 24) * CELL
		local corner = origin.Position
		pitch.Size = Vector3.new(openWidth, 0.25, depth)
		pitch.CFrame = CFrame.new(corner.X + openWidth / 2, 0.12, corner.Z + depth / 2)
		local rest = total - openWidth
		locked.Transparency = if rest <= 0.2 then 1 else 0
		if rest > 0.2 then
			locked.Size = Vector3.new(rest, 0.2, depth)
			locked.CFrame = CFrame.new(corner.X + openWidth + rest / 2, 0.12, corner.Z + depth / 2)
		end
	end
	built:ClearAllChildren()
	if profile == nil then
		return
	end
	local corner = origin.Position
	for key, cell in pairs(profile.cells) do
		local xText, yText = string.match(key, "^(%d+),(%d+)$")
		local x = tonumber(xText)
		local y = tonumber(yText)
		if x ~= nil and y ~= nil then
			local base = corner + Vector3.new((x - 1) * CELL + CELL / 2, 0, (y - 1) * CELL + CELL / 2)
			local cf = facingFrame(base, cell.facing)
			assemble(built, cell.kind, cf)
		end
	end
end

function Map.teleport(player, plotModel)
	local character = player.Character
	local claim = plotModel:FindFirstChild("Claim")
	if character == nil or claim == nil then
		return
	end
	character:PivotTo(CFrame.new(claim.Position + Vector3.new(0, 4, 6)))
end

return Map
