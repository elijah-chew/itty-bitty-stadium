local Map = {}

local CELL = 8
local PITCH = Color3.fromRGB(46, 132, 62)
local PITCH_DARK = Color3.fromRGB(38, 112, 54)
local CREAM = Color3.fromRGB(244, 239, 228)
local INK = Color3.fromRGB(28, 32, 30)
local NAVY = Color3.fromRGB(24, 42, 86)
local WHITE = Color3.fromRGB(246, 246, 242)
local CONCRETE = Color3.fromRGB(214, 210, 200)

local DIR = {
	south = Vector3.new(0, 0, 1),
	north = Vector3.new(0, 0, -1),
	east = Vector3.new(1, 0, 0),
	west = Vector3.new(-1, 0, 0),
}

local BILLBOARD = {
	goal = 6.4,
	stand_small = 5.5,
	stand_medium = 8.5,
	stand_corner = 5.5,
	stand_angle = 5.5,
	changing_room = 6,
	food_stand = 5.2,
	floodlights = 16,
	ticket_office = 5.5,
	medical = 6,
	scoreboard = 8,
	club_shop = 6.5,
	gym = 8,
	amenities = 6,
	club_hotel = 14,
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
	if shape ~= nil then
		block.Shape = shape
	end
	block.Parent = parent
	return block
end

local function sign(parent, text, size, face)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.Parent = parent
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = CREAM
	label.Text = text
	label.Parent = gui
	parent.Size = size
end

local function facingFrame(position, facing)
	local forward = DIR[facing] or DIR.south
	local up = Vector3.yAxis
	local right = up:Cross(forward)
	return CFrame.fromMatrix(position, right, up, -forward)
end

local function dress(parent)
	local Lighting = game:GetService("Lighting")
	Lighting.ClockTime = 16.6
	Lighting.Brightness = 2.4
	Lighting.Ambient = Color3.fromRGB(86, 96, 104)
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 156, 148)
	Lighting.EnvironmentDiffuseScale = 0.45
	Lighting.EnvironmentSpecularScale = 0.55
	local atmosphere = Lighting:FindFirstChild("StadiumAir")
	if atmosphere == nil then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Name = "StadiumAir"
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = 0.3
	atmosphere.Offset = 0.12
	atmosphere.Color = Color3.fromRGB(206, 220, 230)
	atmosphere.Decay = Color3.fromRGB(150, 168, 150)
	atmosphere.Glare = 0.12
	atmosphere.Haze = 1.1
end

local function tree(parent, position)
	part(parent, "Trunk", Vector3.new(1.4, 7, 1.4), CFrame.new(position + Vector3.new(0, 3.5, 0)), Color3.fromRGB(92, 64, 42), Enum.Material.Wood)
	part(parent, "Crown", Vector3.new(8, 8, 8), CFrame.new(position + Vector3.new(0, 8.5, 0)), Color3.fromRGB(42, 120, 58), Enum.Material.Grass, Enum.PartType.Ball)
end

local function flag(parent, position, color)
	local pole = part(parent, "Pole", Vector3.new(0.4, 14, 0.4), CFrame.new(position + Vector3.new(0, 7, 0)), Color3.fromRGB(230, 230, 226), Enum.Material.Metal)
	part(parent, "Flag", Vector3.new(0.2, 3.2, 5), pole.CFrame * CFrame.new(0, 4.2, 2.6), color, Enum.Material.Fabric)
end

local function line(parent, center, size)
	local mark = part(parent, "Line", size, CFrame.new(center + Vector3.new(0, 0.12, 0)), WHITE, Enum.Material.SmoothPlastic)
	mark.CanCollide = false
	return mark
end

local function pitchMarkings(parent, originX, originZ)
	local width = 12 * CELL
	local depth = 16 * CELL
	local cx = originX + width / 2
	local cz = originZ + depth / 2
	line(parent, Vector3.new(cx, 0, cz), Vector3.new(width - 10, 0.08, 0.45))
	line(parent, Vector3.new(cx, 0, originZ + 6), Vector3.new(width - 10, 0.08, 0.45))
	line(parent, Vector3.new(cx, 0, originZ + depth - 6), Vector3.new(width - 10, 0.08, 0.45))
	line(parent, Vector3.new(originX + 6, 0, cz), Vector3.new(0.45, 0.08, depth - 10))
	line(parent, Vector3.new(originX + width - 6, 0, cz), Vector3.new(0.45, 0.08, depth - 10))
	local spot = part(parent, "Spot", Vector3.new(0.08, 3.2, 3.2), CFrame.new(cx, 0.14, cz) * CFrame.Angles(0, 0, math.rad(90)), WHITE, Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
	spot.CanCollide = false
	local boxDepth = 22
	local boxWidth = 40
	line(parent, Vector3.new(cx, 0, originZ + 6 + boxDepth / 2), Vector3.new(boxWidth, 0.08, 0.4))
	line(parent, Vector3.new(cx - boxWidth / 2, 0, originZ + 6 + boxDepth / 2), Vector3.new(0.4, 0.08, boxDepth))
	line(parent, Vector3.new(cx + boxWidth / 2, 0, originZ + 6 + boxDepth / 2), Vector3.new(0.4, 0.08, boxDepth))
	line(parent, Vector3.new(cx, 0, originZ + depth - 6 - boxDepth / 2), Vector3.new(boxWidth, 0.08, 0.4))
	line(parent, Vector3.new(cx - boxWidth / 2, 0, originZ + depth - 6 - boxDepth / 2), Vector3.new(0.4, 0.08, boxDepth))
	line(parent, Vector3.new(cx + boxWidth / 2, 0, originZ + depth - 6 - boxDepth / 2), Vector3.new(0.4, 0.08, boxDepth))
end

local function fence(parent, originX, originZ)
	local width = 24 * CELL
	local depth = 16 * CELL
	local y = 1.6
	local north = originZ
	local south = originZ + depth
	local west = originX
	local east = originX + width
	part(parent, "Fence", Vector3.new(width, 3.2, 0.6), CFrame.new((west + east) / 2, y, north), CONCRETE, Enum.Material.Concrete)
	part(parent, "Fence", Vector3.new(0.6, 3.2, depth), CFrame.new(west, y, (north + south) / 2), CONCRETE, Enum.Material.Concrete)
	part(parent, "Fence", Vector3.new(0.6, 3.2, depth), CFrame.new(east, y, (north + south) / 2), CONCRETE, Enum.Material.Concrete)
	local gap = 18
	local side = (width - gap) / 2
	part(parent, "Fence", Vector3.new(side, 3.2, 0.6), CFrame.new(west + side / 2, y, south), CONCRETE, Enum.Material.Concrete)
	part(parent, "Fence", Vector3.new(side, 3.2, 0.6), CFrame.new(east - side / 2, y, south), CONCRETE, Enum.Material.Concrete)
end

local function goal(parent, cf)
	local white = WHITE
	part(parent, "Post", Vector3.new(0.45, 5.4, 0.45), cf * CFrame.new(-3.1, 2.7, 0), white, Enum.Material.SmoothPlastic)
	part(parent, "Post", Vector3.new(0.45, 5.4, 0.45), cf * CFrame.new(3.1, 2.7, 0), white, Enum.Material.SmoothPlastic)
	part(parent, "Bar", Vector3.new(6.6, 0.4, 0.4), cf * CFrame.new(0, 5.3, 0), white, Enum.Material.SmoothPlastic)
	local net = part(parent, "Net", Vector3.new(6.2, 5, 1.6), cf * CFrame.new(0, 2.6, -0.9), Color3.fromRGB(236, 236, 232), Enum.Material.Fabric)
	net.Transparency = 0.35
end

local function stand(parent, cf, rows, seat)
	part(parent, "Plinth", Vector3.new(7.4, 1, 7.2), cf * CFrame.new(0, 0.5, 0), Color3.fromRGB(176, 176, 170), Enum.Material.Concrete)
	for index = 1, rows do
		local rise = 1.15 + (index - 1) * 1.05
		local back = -1.5 + (index - 1) * 0.85
		part(parent, "Seats", Vector3.new(7.1, 0.7, 1.5), cf * CFrame.new(0, rise, back), seat, Enum.Material.Fabric)
	end
	if rows >= 4 then
		part(parent, "Roof", Vector3.new(7.6, 0.35, 6.4), cf * CFrame.new(0, 1.2 + rows * 1.05, -0.4), Color3.fromRGB(230, 232, 228), Enum.Material.Metal)
	end
end

local function building(parent, cf, size, color, material, door)
	local block = part(parent, "Walls", size, cf * CFrame.new(0, size.Y / 2, 0), color, material)
	if door then
		part(parent, "Door", Vector3.new(2.2, 3.2, 0.3), cf * CFrame.new(0, 1.7, size.Z / 2), Color3.fromRGB(48, 36, 28), Enum.Material.Wood)
	end
	return block
end

local function windows(parent, cf, floors, width)
	for level = 1, floors do
		part(parent, "Glass", Vector3.new(width, 1.1, 0.25), cf * CFrame.new(0, 2.2 + (level - 1) * 2.4, 3.7), Color3.fromRGB(186, 214, 224), Enum.Material.Glass)
	end
end

local function assemble(parent, kind, cf)
	if kind == "grass" then
		local stripe = (math.floor(cf.Position.X / CELL) + math.floor(cf.Position.Z / CELL)) % 2 == 0
		local colour = if stripe then PITCH else Color3.fromRGB(62, 156, 74)
		part(parent, "Turf", Vector3.new(CELL - 0.35, 0.35, CELL - 0.35), cf * CFrame.new(0, 0.2, 0), colour, Enum.Material.Grass)
		return
	end
	if kind == "goal" then
		goal(parent, cf)
		return
	end
	if kind == "stand_small" then
		stand(parent, cf, 3, NAVY)
		return
	end
	if kind == "stand_medium" then
		stand(parent, cf, 5, Color3.fromRGB(150, 32, 40))
		return
	end
	if kind == "stand_corner" then
		stand(parent, cf, 3, Color3.fromRGB(36, 78, 64))
		part(parent, "Corner", Vector3.new(3.2, 3.4, 3.2), cf * CFrame.new(2, 2.2, -2), Color3.fromRGB(28, 60, 50), Enum.Material.Fabric)
		return
	end
	if kind == "stand_angle" then
		stand(parent, cf, 3, Color3.fromRGB(196, 150, 48))
		return
	end
	if kind == "food_stand" then
		part(parent, "Counter", Vector3.new(6.6, 2.4, 3.2), cf * CFrame.new(0, 1.2, 0.6), Color3.fromRGB(214, 122, 48), Enum.Material.Wood)
		part(parent, "Awning", Vector3.new(7.2, 0.3, 3.6), cf * CFrame.new(0, 3.5, 0.2), Color3.fromRGB(196, 48, 42), Enum.Material.Fabric)
		part(parent, "Stripe", Vector3.new(1.1, 0.32, 3.6), cf * CFrame.new(-2.2, 3.52, 0.2), WHITE, Enum.Material.Fabric)
		part(parent, "Stripe", Vector3.new(1.1, 0.32, 3.6), cf * CFrame.new(0, 3.52, 0.2), WHITE, Enum.Material.Fabric)
		part(parent, "Stripe", Vector3.new(1.1, 0.32, 3.6), cf * CFrame.new(2.2, 3.52, 0.2), WHITE, Enum.Material.Fabric)
		return
	end
	if kind == "floodlights" then
		local mast = part(parent, "Mast", Vector3.new(0.7, 15, 0.7), cf * CFrame.new(0, 7.5, 0), Color3.fromRGB(70, 74, 78), Enum.Material.Metal)
		local head = mast.CFrame * CFrame.new(0, 7.2, 1.4)
		part(parent, "Gantry", Vector3.new(4.6, 0.4, 1.4), head, Color3.fromRGB(50, 54, 58), Enum.Material.Metal)
		part(parent, "Lamp", Vector3.new(1.5, 0.7, 0.8), head * CFrame.new(-1.3, -0.5, 0), Color3.fromRGB(255, 244, 210), Enum.Material.Neon)
		part(parent, "Lamp", Vector3.new(1.5, 0.7, 0.8), head * CFrame.new(1.3, -0.5, 0), Color3.fromRGB(255, 244, 210), Enum.Material.Neon)
		return
	end
	if kind == "changing_room" then
		building(parent, cf, Vector3.new(7.2, 5, 6.4), Color3.fromRGB(196, 164, 92), Enum.Material.Brick, true)
		return
	end
	if kind == "gym" then
		building(parent, cf, Vector3.new(7.2, 7, 6.6), Color3.fromRGB(150, 56, 52), Enum.Material.Brick, true)
		windows(parent, cf, 2, 5.4)
		return
	end
	if kind == "amenities" then
		building(parent, cf, Vector3.new(7.4, 4.6, 6.8), Color3.fromRGB(78, 122, 108), Enum.Material.Concrete, true)
		return
	end
	if kind == "ticket_office" then
		building(parent, cf, Vector3.new(6.4, 4.4, 4.4), Color3.fromRGB(196, 112, 64), Enum.Material.WoodPlanks, true)
		part(parent, "Window", Vector3.new(3.4, 1.2, 0.2), cf * CFrame.new(0, 2.8, 2.2), Color3.fromRGB(186, 214, 224), Enum.Material.Glass)
		return
	end
	if kind == "medical" then
		building(parent, cf, Vector3.new(6.8, 5, 5.6), WHITE, Enum.Material.SmoothPlastic, true)
		part(parent, "Cross", Vector3.new(0.5, 2.2, 0.2), cf * CFrame.new(2.2, 3.4, 2.8), Color3.fromRGB(196, 48, 48), Enum.Material.Neon)
		part(parent, "Cross", Vector3.new(2.2, 0.5, 0.2), cf * CFrame.new(2.2, 3.4, 2.8), Color3.fromRGB(196, 48, 48), Enum.Material.Neon)
		return
	end
	if kind == "club_shop" then
		building(parent, cf, Vector3.new(7.2, 5.4, 6), Color3.fromRGB(36, 78, 168), Enum.Material.SmoothPlastic, false)
		part(parent, "Front", Vector3.new(6.4, 3.2, 0.25), cf * CFrame.new(0, 2.4, 3), Color3.fromRGB(198, 224, 232), Enum.Material.Glass)
		return
	end
	if kind == "club_hotel" then
		building(parent, cf, Vector3.new(7.2, 12, 6.6), Color3.fromRGB(108, 86, 140), Enum.Material.Concrete, true)
		windows(parent, cf, 4, 5.2)
		return
	end
	if kind == "scoreboard" then
		local board = part(parent, "Board", Vector3.new(7.2, 4.2, 0.6), cf * CFrame.new(0, 6.2, 0), INK, Enum.Material.SmoothPlastic)
		part(parent, "Leg", Vector3.new(0.5, 4.4, 0.5), cf * CFrame.new(-2.4, 2.2, 0), Color3.fromRGB(60, 64, 68), Enum.Material.Metal)
		part(parent, "Leg", Vector3.new(0.5, 4.4, 0.5), cf * CFrame.new(2.4, 2.2, 0), Color3.fromRGB(60, 64, 68), Enum.Material.Metal)
		sign(board, "0  -  0", Vector3.new(7.2, 4.2, 0.6), Enum.NormalId.Front)
		return
	end
	part(parent, kind, Vector3.new(CELL - 0.4, 6, CELL - 0.4), cf * CFrame.new(0, 3, 0), Color3.fromRGB(180, 180, 180), Enum.Material.SmoothPlastic)
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
	dress(workspace)

	local baseplate = workspace:FindFirstChild("Baseplate")
	if baseplate ~= nil then
		baseplate:Destroy()
	end
	for _, child in ipairs(workspace:GetChildren()) do
		if child:IsA("SpawnLocation") then
			child:Destroy()
		end
	end

	local oldLobby = workspace:FindFirstChild("Lobby")
	if oldLobby ~= nil then
		oldLobby:Destroy()
	end
	local oldPlots = workspace:FindFirstChild("Plots")
	if oldPlots ~= nil then
		oldPlots:Destroy()
	end

	local lobby = Instance.new("Folder")
	lobby.Name = "Lobby"
	lobby.Parent = workspace

	part(lobby, "Lawn", Vector3.new(140, 2, 110), CFrame.new(0, -1.2, 6), Color3.fromRGB(58, 120, 64), Enum.Material.Grass)
	part(lobby, "Floor", Vector3.new(86, 2, 58), CFrame.new(0, -0.7, 4), Color3.fromRGB(54, 58, 56), Enum.Material.Slate)
	part(lobby, "Carpet", Vector3.new(16, 0.2, 40), CFrame.new(0, 0.35, 8), Color3.fromRGB(36, 92, 62), Enum.Material.Fabric)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Arrival"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.CFrame = CFrame.new(0, 0.5, 14)
	spawn.Color = Color3.fromRGB(47, 158, 98)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.Parent = lobby

	part(lobby, "Pillar", Vector3.new(2.2, 12, 2.2), CFrame.new(-16, 6, -16), CONCRETE, Enum.Material.Concrete)
	part(lobby, "Pillar", Vector3.new(2.2, 12, 2.2), CFrame.new(16, 6, -16), CONCRETE, Enum.Material.Concrete)
	part(lobby, "Lintel", Vector3.new(36, 1.4, 2.4), CFrame.new(0, 12.2, -16), CONCRETE, Enum.Material.Concrete)
	local board = part(lobby, "Board", Vector3.new(28, 8, 1), CFrame.new(0, 8.2, -16), INK, Enum.Material.SmoothPlastic)
	sign(board, "ITTY BITTY STADIUM", Vector3.new(28, 8, 1), Enum.NormalId.Back)

	flag(lobby, Vector3.new(-28, 0, -8), Color3.fromRGB(196, 42, 48))
	flag(lobby, Vector3.new(28, 0, -8), NAVY)
	tree(lobby, Vector3.new(-42, 0, 18))
	tree(lobby, Vector3.new(42, 0, 18))
	tree(lobby, Vector3.new(-36, 0, -24))
	tree(lobby, Vector3.new(36, 0, -24))

	local plotsFolder = Instance.new("Folder")
	plotsFolder.Name = "Plots"
	plotsFolder.Parent = workspace

	local models = {}
	for index = 1, 6 do
		local model = Instance.new("Model")
		model.Name = "Plot" .. index
		local originX = -660 + (index - 1) * 240
		local originZ = 40
		local width = 24 * CELL
		local depth = 16 * CELL
		part(
			model,
			"Ground",
			Vector3.new(width, 1, depth),
			CFrame.new(originX + width / 2, -0.5, originZ + depth / 2),
			PITCH_DARK,
			Enum.Material.Grass
		)
		pitchMarkings(model, originX, originZ)
		fence(model, originX, originZ)
		local origin = part(model, "Origin", Vector3.new(0.4, 0.4, 0.4), CFrame.new(originX, 0.2, originZ), Color3.fromRGB(230, 210, 140))
		origin.Transparency = 1
		origin.CanCollide = false
		local gateX = originX + 12 * CELL
		local gateZ = originZ + depth + 14
		local claim = part(model, "Claim", Vector3.new(18, 1, 12), CFrame.new(gateX, 0.5, gateZ), Color3.fromRGB(36, 92, 168), Enum.Material.Concrete)
		part(model, "GateLeft", Vector3.new(1.4, 8, 1.4), CFrame.new(gateX - 8, 4, gateZ), CONCRETE, Enum.Material.Concrete)
		part(model, "GateRight", Vector3.new(1.4, 8, 1.4), CFrame.new(gateX + 8, 4, gateZ), CONCRETE, Enum.Material.Concrete)
		local marker = part(model, "Number", Vector3.new(14, 4, 0.6), CFrame.new(gateX, 7.2, gateZ - 8), INK, Enum.Material.SmoothPlastic)
		sign(marker, "PLOT " .. index, Vector3.new(14, 4, 0.6), Enum.NormalId.Back)
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
			local lift = BILLBOARD[cell.kind]
			if lift ~= nil and cell.kind ~= "grass" then
				local anchor = part(built, "LabelAnchor", Vector3.new(0.2, 0.2, 0.2), CFrame.new(base + Vector3.new(0, lift, 0)), WHITE)
				anchor.Transparency = 1
				anchor.CanCollide = false
				local gui = Instance.new("BillboardGui")
				gui.Size = UDim2.fromOffset(90, 22)
				gui.StudsOffset = Vector3.new(0, 1.2, 0)
				gui.AlwaysOnTop = true
				gui.Parent = anchor
				local label = Instance.new("TextLabel")
				label.BackgroundTransparency = 0.25
				label.BackgroundColor3 = INK
				label.Size = UDim2.fromScale(1, 1)
				label.Font = Enum.Font.GothamBold
				label.TextScaled = true
				label.TextColor3 = CREAM
				label.Text = string.upper(string.gsub(cell.kind, "_", " "))
				label.Parent = gui
				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 6)
				corner.Parent = label
			end
		end
	end
end

function Map.teleport(player, plotModel)
	local character = player.Character
	local claim = plotModel:FindFirstChild("Claim")
	if character == nil or claim == nil then
		return
	end
	character:PivotTo(claim.CFrame + Vector3.new(0, 4, 0))
end

return Map
