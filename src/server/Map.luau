local Map = {}

local CELL = 8
local COLOURS = {
	grass = Color3.fromRGB(74, 150, 62),
	goal = Color3.fromRGB(245, 245, 245),
	stand_small = Color3.fromRGB(70, 96, 140),
	stand_medium = Color3.fromRGB(48, 70, 112),
	stand_corner = Color3.fromRGB(90, 110, 150),
	stand_angle = Color3.fromRGB(80, 100, 138),
	changing_room = Color3.fromRGB(196, 164, 92),
	floodlights = Color3.fromRGB(230, 220, 140),
	ticket_office = Color3.fromRGB(196, 112, 64),
	medical = Color3.fromRGB(214, 92, 92),
	scoreboard = Color3.fromRGB(40, 44, 52),
	club_shop = Color3.fromRGB(47, 111, 237),
	gym = Color3.fromRGB(168, 64, 64),
	amenities = Color3.fromRGB(92, 140, 120),
	club_hotel = Color3.fromRGB(120, 96, 160),
	food_stand = Color3.fromRGB(214, 122, 48),
}

local HEIGHTS = {
	grass = 0.4,
	goal = 6,
	stand_small = 8,
	stand_medium = 14,
	stand_corner = 8,
	stand_angle = 8,
	food_stand = 5,
	floodlights = 16,
	scoreboard = 10,
}

local function part(parent, name, size, cf, color, material)
	local block = Instance.new("Part")
	block.Name = name
	block.Anchored = true
	block.Size = size
	block.CFrame = cf
	block.Color = color
	block.Material = material or Enum.Material.SmoothPlastic
	block.TopSurface = Enum.SurfaceType.Smooth
	block.BottomSurface = Enum.SurfaceType.Smooth
	block.Parent = parent
	return block
end

local function sign(parent, text, size)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = parent
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(244, 239, 228)
	label.Text = text
	label.Parent = gui
	parent.Size = size
end

function Map.build()
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

	part(lobby, "Floor", Vector3.new(96, 2, 72), CFrame.new(0, -1, 0), Color3.fromRGB(28, 36, 32), Enum.Material.Slate)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Arrival"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.CFrame = CFrame.new(0, 0.5, 8)
	spawn.Color = Color3.fromRGB(47, 158, 98)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.Parent = lobby

	local board = part(lobby, "Board", Vector3.new(28, 10, 1), CFrame.new(0, 8, -24), Color3.fromRGB(28, 25, 21))
	sign(board, "ITTY BITTY STADIUM", Vector3.new(28, 10, 1))

	local plotsFolder = Instance.new("Folder")
	plotsFolder.Name = "Plots"
	plotsFolder.Parent = workspace

	local models = {}
	for index = 1, 6 do
		local model = Instance.new("Model")
		model.Name = "Plot" .. index
		local originX = -660 + (index - 1) * 240
		local originZ = 40
		part(
			model,
			"Ground",
			Vector3.new(24 * CELL, 1, 16 * CELL),
			CFrame.new(originX + 12 * CELL, -0.5, originZ + 8 * CELL),
			Color3.fromRGB(92, 122, 70),
			Enum.Material.Grass
		)
		local origin = part(
			model,
			"Origin",
			Vector3.new(0.4, 0.4, 0.4),
			CFrame.new(originX, 0.2, originZ),
			Color3.fromRGB(230, 210, 140)
		)
		origin.Transparency = 1
		origin.CanCollide = false
		local claim = part(
			model,
			"Claim",
			Vector3.new(16, 1, 10),
			CFrame.new(originX + 12 * CELL, 0.5, originZ + 16 * CELL + 14),
			Color3.fromRGB(47, 111, 237)
		)
		local marker = part(model, "Number", Vector3.new(8, 4, 1), claim.CFrame * CFrame.new(0, 4, -6), Color3.fromRGB(28, 25, 21))
		sign(marker, "PLOT " .. index, Vector3.new(8, 4, 1))
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
			local height = HEIGHTS[cell.kind] or 7
			local colour = COLOURS[cell.kind] or Color3.fromRGB(180, 180, 180)
			local center = corner + Vector3.new((x - 1) * CELL + CELL / 2, height / 2, (y - 1) * CELL + CELL / 2)
			local block = part(built, cell.kind, Vector3.new(CELL - 0.4, height, CELL - 0.4), CFrame.new(center), colour)
			if cell.kind ~= "grass" then
				local gui = Instance.new("BillboardGui")
				gui.Size = UDim2.fromOffset(72, 22)
				gui.StudsOffset = Vector3.new(0, height / 2 + 1.2, 0)
				gui.AlwaysOnTop = true
				gui.Parent = block
				local label = Instance.new("TextLabel")
				label.BackgroundTransparency = 1
				label.Size = UDim2.fromScale(1, 1)
				label.Font = Enum.Font.GothamBold
				label.TextScaled = true
				label.TextColor3 = Color3.new(1, 1, 1)
				label.TextStrokeTransparency = 0.4
				label.Text = string.gsub(cell.kind, "_", " ")
				label.Parent = gui
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
