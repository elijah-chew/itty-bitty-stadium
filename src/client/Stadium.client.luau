local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Simulation = require(ReplicatedStorage:WaitForChild("Simulation"))
local Catalog = Simulation.Catalog
local Events = Simulation.Events

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local actionRemote = remotes:WaitForChild("Action")
local stateRemote = remotes:WaitForChild("State")

local INK = Color3.fromRGB(28, 25, 21)
local CREAM = Color3.fromRGB(244, 239, 228)
local BLUE = Color3.fromRGB(47, 111, 237)
local GREEN = Color3.fromRGB(47, 158, 98)
local RED = Color3.fromRGB(196, 72, 64)
local GOLD = Color3.fromRGB(212, 164, 64)
local MUTED = Color3.fromRGB(90, 84, 74)

local NAMES = {
	kickabout = "Kickabout",
	sunday = "Sunday league",
	town = "Town club",
	regional = "Regional cup",
	national = "National league",
	cup_final = "Cup final",
	premier = "Premier league",
}
local ORDER = { "kickabout", "sunday", "town", "regional", "national", "cup_final", "premier" }
local COLOURS = { "navy", "white", "red", "gold", "green", "black" }
local COLOUR_RGB = {
	navy = Color3.fromRGB(20, 40, 90),
	white = Color3.fromRGB(244, 244, 244),
	red = Color3.fromRGB(176, 40, 40),
	gold = Color3.fromRGB(212, 164, 64),
	green = Color3.fromRGB(36, 120, 64),
	black = Color3.fromRGB(24, 24, 24),
}
local GROUPS = {
	{ name = "Pitch", pieces = { "grass", "goal" } },
	{ name = "Stands", pieces = { "stand_small", "stand_medium", "stand_corner", "stand_angle" } },
	{ name = "Buildings", pieces = { "changing_room", "food_stand", "gym", "floodlights", "amenities", "ticket_office", "medical", "club_hotel", "scoreboard", "club_shop" } },
}
local PIECE_COLOUR = {
	grass = Color3.fromRGB(74, 150, 62),
	goal = Color3.fromRGB(230, 230, 230),
	stand_small = Color3.fromRGB(70, 96, 140),
	stand_medium = Color3.fromRGB(48, 70, 112),
	stand_corner = Color3.fromRGB(90, 110, 150),
	stand_angle = Color3.fromRGB(80, 100, 138),
}

local selectedKind = "grass"
local selectedGroup = "Pitch"
local facing = "south"
local removeMode = false
local page = "title"
local section = "overview"
local state = { profile = nil, plots = {}, plotIndex = nil }

local gui = Instance.new("ScreenGui")
gui.Name = "IttyBittyStadium"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local function money(amount)
	local digits = tostring(math.floor(amount or 0))
	local reversed = string.reverse(digits)
	local grouped = string.gsub(reversed, "(%d%d%d)", "%1,")
	if string.sub(grouped, -1) == "," then
		grouped = string.sub(grouped, 1, -2)
	end
	return string.reverse(grouped)
end

local function label(parent, text, fontSize, colour)
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.Font = Enum.Font.GothamBold
	item.TextSize = fontSize or 16
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextColor3 = colour or INK
	item.Text = text or ""
	item.Parent = parent
	return item
end

local function button(parent, text, colour, onClick)
	local item = Instance.new("TextButton")
	item.AutoButtonColor = true
	item.Font = Enum.Font.GothamBold
	item.TextSize = 16
	item.TextColor3 = CREAM
	item.BackgroundColor3 = colour or BLUE
	item.Text = text
	item.AutoLocalize = false
	item.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = item
	if onClick ~= nil then
		item.MouseButton1Click:Connect(onClick)
	end
	return item
end

local function panel(parent, colour)
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = colour or CREAM
	frame.BorderSizePixel = 0
	frame.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame
	return frame
end

local function call(name, a, b, c, d)
	local result = actionRemote:InvokeServer(name, a, b, c, d)
	if type(result) == "table" and result.state ~= nil then
		state = result.state
	end
	return result
end

local titlePage = Instance.new("Frame")
titlePage.Name = "Title"
titlePage.Size = UDim2.fromScale(1, 1)
titlePage.BackgroundColor3 = INK
titlePage.BorderSizePixel = 0
titlePage.Parent = gui

local titleCard = panel(titlePage, CREAM)
titleCard.AnchorPoint = Vector2.new(0.5, 0.5)
titleCard.Position = UDim2.fromScale(0.5, 0.5)
titleCard.Size = UDim2.fromOffset(420, 360)

local titleHeading = label(titleCard, "ITTY BITTY STADIUM", 28, INK)
titleHeading.Position = UDim2.fromOffset(28, 28)
titleHeading.Size = UDim2.new(1, -56, 0, 36)
local version = label(titleCard, "Build a football ground. Host the match. Keep the club in profit.", 14, MUTED)
version.Position = UDim2.fromOffset(28, 72)
version.Size = UDim2.new(1, -56, 0, 40)
version.TextWrapped = true
version.Font = Enum.Font.Gotham

local clubPage = Instance.new("Frame")
clubPage.Name = "Club"
clubPage.Size = UDim2.fromScale(1, 1)
clubPage.BackgroundColor3 = Color3.fromRGB(232, 224, 208)
clubPage.BorderSizePixel = 0
clubPage.Visible = false
clubPage.Parent = gui

local clubHeading = label(clubPage, "Your club", 28, INK)
clubHeading.Position = UDim2.fromOffset(48, 36)
clubHeading.Size = UDim2.fromOffset(300, 36)

local continueCard = panel(clubPage, CREAM)
continueCard.Position = UDim2.fromOffset(48, 100)
continueCard.Size = UDim2.fromOffset(280, 220)
local continueTitle = label(continueCard, "No save this visit", 18, INK)
continueTitle.Position = UDim2.fromOffset(16, 16)
continueTitle.Size = UDim2.new(1, -32, 0, 28)
local continueBody = label(continueCard, "Start a club, then pick a plot.", 14, MUTED)
continueBody.Position = UDim2.fromOffset(16, 52)
continueBody.Size = UDim2.new(1, -32, 0, 72)
continueBody.TextWrapped = true
continueBody.Font = Enum.Font.Gotham

local plotPage = Instance.new("Frame")
plotPage.Name = "Plots"
plotPage.Size = UDim2.fromScale(1, 1)
plotPage.BackgroundColor3 = Color3.fromRGB(232, 224, 208)
plotPage.BorderSizePixel = 0
plotPage.Visible = false
plotPage.Parent = gui
label(plotPage, "Select a plot", 28, INK).Position = UDim2.fromOffset(40, 28)
label(plotPage, "Select a plot", 28, INK).Size = UDim2.fromOffset(320, 36)
local plotHint = label(plotPage, "Six grounds. An open plot is yours to claim.", 15, MUTED)
plotHint.Position = UDim2.fromOffset(40, 68)
plotHint.Size = UDim2.fromOffset(520, 24)
plotHint.Font = Enum.Font.Gotham

local plotCards = {}
for index = 1, 6 do
	local column = (index - 1) % 3
	local row = math.floor((index - 1) / 3)
	local card = panel(plotPage, CREAM)
	card.Position = UDim2.fromOffset(40 + column * 250, 110 + row * 200)
	card.Size = UDim2.fromOffset(230, 180)
	local heading = label(card, "Plot " .. index, 20, INK)
	heading.Position = UDim2.fromOffset(16, 16)
	heading.Size = UDim2.new(1, -32, 0, 28)
	local owner = label(card, "Open", 14, MUTED)
	owner.Position = UDim2.fromOffset(16, 52)
	owner.Size = UDim2.new(1, -32, 0, 40)
	owner.TextWrapped = true
	owner.Font = Enum.Font.Gotham
	local claimButton = button(card, "Claim", GREEN)
	claimButton.Position = UDim2.fromOffset(16, 120)
	claimButton.Size = UDim2.fromOffset(120, 40)
	plotCards[index] = { owner = owner, button = claimButton }
end

local playPage = Instance.new("Frame")
playPage.Name = "Play"
playPage.Size = UDim2.fromScale(1, 1)
playPage.BackgroundColor3 = Color3.fromRGB(232, 224, 208)
playPage.BorderSizePixel = 0
playPage.Visible = false
playPage.Parent = gui

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 56)
top.BackgroundColor3 = INK
top.BorderSizePixel = 0
top.Parent = playPage
local cashLabel = label(top, "£0", 18, CREAM)
cashLabel.Position = UDim2.fromOffset(16, 14)
cashLabel.Size = UDim2.fromOffset(160, 28)
local fansLabel = label(top, "0 fans", 16, GOLD)
fansLabel.Position = UDim2.fromOffset(180, 16)
fansLabel.Size = UDim2.fromOffset(140, 24)
local statusLabel = label(top, "", 14, CREAM)
statusLabel.Position = UDim2.new(0, 340, 0, 16)
statusLabel.Size = UDim2.new(1, -520, 0, 24)
statusLabel.Font = Enum.Font.Gotham

local nav = Instance.new("Frame")
nav.Position = UDim2.fromOffset(0, 56)
nav.Size = UDim2.new(0, 168, 1, -56)
nav.BackgroundColor3 = INK
nav.BorderSizePixel = 0
nav.Parent = playPage

local main = Instance.new("Frame")
main.Position = UDim2.fromOffset(180, 68)
main.Size = UDim2.new(1, -420, 1, -80)
main.BackgroundTransparency = 1
main.Parent = playPage

local side = panel(playPage, CREAM)
side.AnchorPoint = Vector2.new(1, 0)
side.Position = UDim2.new(1, -16, 0, 72)
side.Size = UDim2.fromOffset(210, 420)
local sideTitle = label(side, "No fixture", 16, INK)
sideTitle.Position = UDim2.fromOffset(12, 12)
sideTitle.Size = UDim2.new(1, -24, 0, 44)
sideTitle.TextWrapped = true
local sideBody = label(side, "", 13, MUTED)
sideBody.Position = UDim2.fromOffset(12, 60)
sideBody.Size = UDim2.new(1, -24, 0, 180)
sideBody.TextWrapped = true
sideBody.Font = Enum.Font.Gotham
sideBody.TextYAlignment = Enum.TextYAlignment.Top

local sections = {}
local function addSection(name)
	local frame = Instance.new("ScrollingFrame")
	frame.Name = name
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	frame.CanvasSize = UDim2.fromOffset(0, 0)
	frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	frame.ScrollBarThickness = 6
	frame.Visible = false
	frame.Parent = main
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = frame
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = frame
	sections[name] = frame
	return frame
end

for _, name in ipairs({ "overview", "events", "objectives", "sponsors", "upgrades", "customise", "build", "shop", "changelog" }) do
	addSection(name)
end

local function showSection(name)
	section = name
	for id, frame in pairs(sections) do
		frame.Visible = id == name
	end
end

local NAV = {
	{ id = "overview", text = "Overview" },
	{ id = "events", text = "Events" },
	{ id = "objectives", text = "Objectives" },
	{ id = "sponsors", text = "Sponsors" },
	{ id = "upgrades", text = "Upgrades" },
	{ id = "customise", text = "Customise" },
	{ id = "build", text = "Build" },
	{ id = "shop", text = "Shop" },
}
for index, item in ipairs(NAV) do
	local navButton = button(nav, item.text, Color3.fromRGB(48, 44, 38), function()
		showSection(item.id)
	end)
	navButton.Size = UDim2.new(1, -16, 0, 36)
	navButton.Position = UDim2.fromOffset(8, 12 + (index - 1) * 42)
	navButton.TextXAlignment = Enum.TextXAlignment.Left
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 10)
	pad.Parent = navButton
end

local function showPage(name)
	page = name
	titlePage.Visible = name == "title"
	clubPage.Visible = name == "club"
	plotPage.Visible = name == "plots"
	playPage.Visible = name == "play"
end

local menuButton = button(top, "Menu", Color3.fromRGB(48, 44, 38), function()
	showPage("title")
end)
menuButton.AnchorPoint = Vector2.new(1, 0)
menuButton.Position = UDim2.new(1, -16, 0, 10)
menuButton.Size = UDim2.fromOffset(88, 36)

local function setStatus(text, bad)
	statusLabel.Text = text or ""
	statusLabel.TextColor3 = if bad then Color3.fromRGB(255, 170, 160) else CREAM
end

local function applyResult(result)
	if result == nil then
		setStatus("No answer from the server", true)
		return
	end
	if result.ok then
		setStatus("")
	else
		setStatus(tostring(result.reason or "not allowed"), true)
	end
	if result.state ~= nil and result.state.lastMatch ~= nil then
		local match = result.state.lastMatch
		setStatus(string.format("%d-%d   +£%s", match.home, match.away, money(match.cash)))
	end
end

local playButton = button(titleCard, "Play", GREEN, function()
	showPage("club")
end)
playButton.Position = UDim2.fromOffset(28, 140)
playButton.Size = UDim2.new(1, -56, 0, 48)

local changelogButton = button(titleCard, "Changelog", INK, function()
	showPage("play")
	showSection("changelog")
end)
changelogButton.Position = UDim2.fromOffset(28, 200)
changelogButton.Size = UDim2.new(1, -56, 0, 44)

local shopButton = button(titleCard, "Shop", BLUE, function()
	showPage("play")
	showSection("shop")
end)
shopButton.Position = UDim2.fromOffset(28, 256)
shopButton.Size = UDim2.new(1, -56, 0, 44)

local continueButton = button(continueCard, "Continue", GREEN, function()
	if state.profile == nil then
		setStatus("Start a new club first", true)
		return
	end
	if state.plotIndex == nil then
		showPage("plots")
	else
		showPage("play")
		showSection("overview")
	end
end)
continueButton.Position = UDim2.fromOffset(16, 150)
continueButton.Size = UDim2.fromOffset(140, 44)

local newCard = panel(clubPage, CREAM)
newCard.Position = UDim2.fromOffset(348, 100)
newCard.Size = UDim2.fromOffset(280, 220)
local newHeading = label(newCard, "New club", 18, INK)
newHeading.Position = UDim2.fromOffset(16, 16)
newHeading.Size = UDim2.new(1, -32, 0, 28)
local newBody = label(newCard, "12,000 to start. The save lasts for this server visit.", 14, MUTED)
newBody.Position = UDim2.fromOffset(16, 52)
newBody.Size = UDim2.new(1, -32, 0, 70)
newBody.TextWrapped = true
newBody.Font = Enum.Font.Gotham
local newButton = button(newCard, "Start", BLUE, function()
	applyResult(call("NewClub"))
	showPage("plots")
end)
newButton.Position = UDim2.fromOffset(16, 150)
newButton.Size = UDim2.fromOffset(120, 44)

local lockedCard = panel(clubPage, Color3.fromRGB(226, 220, 206))
lockedCard.Position = UDim2.fromOffset(648, 100)
lockedCard.Size = UDim2.fromOffset(280, 220)
local lockedHeading = label(lockedCard, "Extra slot", 18, MUTED)
lockedHeading.Position = UDim2.fromOffset(16, 16)
lockedHeading.Size = UDim2.new(1, -32, 0, 28)
local lockedBody = label(lockedCard, "A third club slot is a later Robux unlock.", 14, MUTED)
lockedBody.Position = UDim2.fromOffset(16, 52)
lockedBody.Size = UDim2.new(1, -32, 0, 70)
lockedBody.TextWrapped = true
lockedBody.Font = Enum.Font.Gotham

local function line(parent, text, order)
	local item = label(parent, text, 15, INK)
	item.Size = UDim2.new(1, 0, 0, 28)
	item.LayoutOrder = order or 1
	item.TextWrapped = true
	return item
end

line(sections.changelog, "Kickabout is 5v5. Sunday league is 7v7. Every league after that is 11v11.", 1).Size = UDim2.new(1, 0, 0, 48)
line(sections.changelog, "Food stands and the club shop pay on top of the gate.", 2).Size = UDim2.new(1, 0, 0, 40)
line(sections.changelog, "Pick your own plot. A taken plot stays taken.", 3)

local shopNote = line(sections.shop, "Robux prices are set on the Creator Dashboard. The pass and product ids are still 0, so nothing can be charged yet.", 1)
shopNote.Size = UDim2.new(1, 0, 0, 56)
shopNote.TextWrapped = true
line(sections.shop, "2x Money doubles match, sponsor, objective, and pack cash.", 2).Size = UDim2.new(1, 0, 0, 40)
line(sections.shop, "Pitch Expansion unlocks an 11v11 grass pitch.", 3)
line(sections.shop, "Packs: £10,000, £50,000, £250,000. 2x Money doubles the pack.", 4).Size = UDim2.new(1, 0, 0, 40)

local overviewLines = {}
for index = 1, 6 do
	overviewLines[index] = line(sections.overview, "", index)
	overviewLines[index].Size = UDim2.new(1, 0, 0, 24)
end

local eventRows = {}
for index, competitionId in ipairs(ORDER) do
	local row = Instance.new("Frame")
	row.BackgroundColor3 = CREAM
	row.Size = UDim2.new(1, 0, 0, 72)
	row.LayoutOrder = index
	row.Parent = sections.events
	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 8)
	rowCorner.Parent = row
	local title = label(row, NAMES[competitionId], 16, INK)
	title.Position = UDim2.fromOffset(10, 8)
	title.Size = UDim2.new(1, -130, 0, 22)
	local detail = label(row, "", 13, MUTED)
	detail.Position = UDim2.fromOffset(10, 32)
	detail.Size = UDim2.new(1, -130, 0, 32)
	detail.Font = Enum.Font.Gotham
	detail.TextWrapped = true
	local start = button(row, "Start", GREEN, function()
		applyResult(call("HostMatch", competitionId))
	end)
	start.Position = UDim2.new(1, -108, 0, 16)
	start.Size = UDim2.fromOffset(92, 40)
	eventRows[competitionId] = { detail = detail, start = start }
end

local objectiveButtons = {}
for index, objectiveId in ipairs({ "host_match", "build_stand", "expand_once" }) do
	local reward = Catalog.objectives[objectiveId]
	local row = button(sections.objectives, objectiveId, BLUE, function()
		applyResult(call("ClaimObjective", objectiveId))
	end)
	row.Size = UDim2.new(1, 0, 0, 44)
	row.LayoutOrder = index
	row.Text = string.format("%s   £%s", string.gsub(objectiveId, "_", " "), money(reward.cash))
	objectiveButtons[objectiveId] = row
end

local sponsorLines = {}
for index, contract in ipairs(Catalog.sponsors) do
	sponsorLines[contract.id] = line(sections.sponsors, "", index)
	sponsorLines[contract.id].Size = UDim2.new(1, 0, 0, 28)
end

local taskButton = {}
for index, taskId in ipairs({ "grill", "merch", "coaching" }) do
	local task = Catalog.sideTasks[taskId]
	local row = button(side, taskId, GOLD, function()
		applyResult(call("CompleteSideTask", taskId))
	end)
	row.TextColor3 = INK
	row.Position = UDim2.fromOffset(12, 250 + (index - 1) * 48)
	row.Size = UDim2.new(1, -24, 0, 40)
	row.Text = string.format("%s  £%s", taskId, money(task.cash))
	taskButton[taskId] = row
end

local hostBest = button(side, "Host", GREEN, function()
	local profile = state.profile
	local competitionId = if profile ~= nil and profile.league ~= nil then profile.league.tier else "kickabout"
	applyResult(call("HostMatch", competitionId))
end)
hostBest.Position = UDim2.fromOffset(12, 200)
hostBest.Size = UDim2.new(1, -24, 0, 40)

local nameBox = Instance.new("TextBox")
nameBox.PlaceholderText = "Club name"
nameBox.Text = ""
nameBox.Font = Enum.Font.GothamBold
nameBox.TextSize = 16
nameBox.BackgroundColor3 = Color3.fromRGB(255, 252, 246)
nameBox.TextColor3 = INK
nameBox.Size = UDim2.new(1, 0, 0, 40)
nameBox.LayoutOrder = 1
nameBox.Parent = sections.customise
local nameCorner = Instance.new("UICorner")
nameCorner.CornerRadius = UDim.new(0, 8)
nameCorner.Parent = nameBox

local primary = "navy"
local secondary = "white"
local colourRow = Instance.new("Frame")
colourRow.BackgroundTransparency = 1
colourRow.Size = UDim2.new(1, 0, 0, 44)
colourRow.LayoutOrder = 2
colourRow.Parent = sections.customise
for index, colourName in ipairs(COLOURS) do
	local chip = button(colourRow, "", COLOUR_RGB[colourName], function()
		if primary == colourName then
			secondary = colourName
		else
			primary = colourName
		end
		setStatus(primary .. " / " .. secondary)
	end)
	chip.Size = UDim2.fromOffset(36, 36)
	chip.Position = UDim2.fromOffset((index - 1) * 42, 4)
	chip.Text = ""
end

local foundButton = button(sections.customise, "Found club", GREEN, function()
	applyResult(call("FoundClub", nameBox.Text, primary, secondary))
end)
foundButton.Size = UDim2.new(1, 0, 0, 44)
foundButton.LayoutOrder = 3

for index, kitId in ipairs({ "stripes", "hoops", "night" }) do
	local kit = Catalog.jerseys[kitId]
	local row = button(sections.customise, kit.name .. "  £" .. money(kit.cost), BLUE, function()
		applyResult(call("BuyJersey", kitId))
	end)
	row.Size = UDim2.new(1, 0, 0, 44)
	row.LayoutOrder = 3 + index
end

local upgradeNote = line(sections.upgrades, "Buy a building from Build, then place it on an empty cell off the pitch.", 1)
upgradeNote.Size = UDim2.new(1, 0, 0, 48)
upgradeNote.TextWrapped = true

local buildHeader = label(sections.build, "Pitch", 16, INK)
buildHeader.Size = UDim2.new(1, 0, 0, 24)
buildHeader.LayoutOrder = 1

local groupRow = Instance.new("Frame")
groupRow.BackgroundTransparency = 1
groupRow.Size = UDim2.new(1, 0, 0, 40)
groupRow.LayoutOrder = 2
groupRow.Parent = sections.build

local pieceRow = Instance.new("Frame")
pieceRow.BackgroundTransparency = 1
pieceRow.Size = UDim2.new(1, 0, 0, 84)
pieceRow.LayoutOrder = 3
pieceRow.Parent = sections.build

local gridHolder = Instance.new("Frame")
gridHolder.BackgroundTransparency = 1
gridHolder.Size = UDim2.new(1, 0, 0, 420)
gridHolder.LayoutOrder = 5
gridHolder.Parent = sections.build
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.fromOffset(22, 22)
gridLayout.CellPadding = UDim2.fromOffset(2, 2)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = gridHolder

local gridButtons = {}

local function pieceName(kind)
	return string.gsub(kind, "_", " ")
end

local function paintPieces()
	for _, child in ipairs(pieceRow:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	local pieces = {}
	for _, group in ipairs(GROUPS) do
		if group.name == selectedGroup then
			pieces = group.pieces
		end
	end
	for index, kind in ipairs(pieces) do
		local piece = Catalog.pieces[kind]
		local chip = button(pieceRow, pieceName(kind), if kind == selectedKind then RED else INK, function()
			selectedKind = kind
			removeMode = false
			paintPieces()
			buildHeader.Text = string.format("%s   £%s", pieceName(kind), money(piece.cost))
		end)
		chip.TextSize = 12
		chip.Size = UDim2.fromOffset(108, 36)
		chip.Position = UDim2.fromOffset((index - 1) * 114, 0)
	end
	local piece = Catalog.pieces[selectedKind]
	if piece ~= nil then
		buildHeader.Text = string.format("%s   £%s", pieceName(selectedKind), money(piece.cost))
	end
end

for index, group in ipairs(GROUPS) do
	local chip = button(groupRow, group.name, INK, function()
		selectedGroup = group.name
		selectedKind = group.pieces[1]
		removeMode = false
		paintPieces()
	end)
	chip.Size = UDim2.fromOffset(110, 34)
	chip.Position = UDim2.fromOffset((index - 1) * 116, 2)
end

local toolRow = Instance.new("Frame")
toolRow.BackgroundTransparency = 1
toolRow.Size = UDim2.new(1, 0, 0, 40)
toolRow.LayoutOrder = 4
toolRow.Parent = sections.build

local facingButton = button(toolRow, "Face south", INK, function()
	local cycle = { south = "west", west = "north", north = "east", east = "south" }
	facing = cycle[facing] or "south"
	facingButton.Text = "Face " .. facing
end)
facingButton.Size = UDim2.fromOffset(130, 34)
facingButton.Position = UDim2.fromOffset(0, 2)

local removeButton = button(toolRow, "Remove", RED, function()
	removeMode = not removeMode
	removeButton.Text = if removeMode then "Removing" else "Remove"
end)
removeButton.Size = UDim2.fromOffset(120, 34)
removeButton.Position = UDim2.fromOffset(140, 2)

local expandButton = button(toolRow, "Expand land", BLUE, function()
	applyResult(call("ExpandLand"))
	paintGrid()
end)
expandButton.Size = UDim2.fromOffset(140, 34)
expandButton.Position = UDim2.fromOffset(270, 2)

function paintGrid()
	local profile = state.profile
	local width = if profile ~= nil then profile.width else Catalog.gridWidth
	local height = if profile ~= nil then profile.height else Catalog.gridHeight
	local needed = width * height
	if #gridButtons ~= needed then
		for _, child in ipairs(gridHolder:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		gridButtons = {}
		for y = 1, height do
			for x = 1, width do
				local cellX = x
				local cellY = y
				local cell = button(gridHolder, "", Color3.fromRGB(214, 206, 190), function()
					if removeMode then
						applyResult(call("RemovePiece", cellX, cellY))
					else
						applyResult(call("PlacePiece", cellX, cellY, selectedKind, facing))
					end
					paintGrid()
				end)
				cell.Text = ""
				cell.LayoutOrder = (y - 1) * width + x
				gridButtons[(y - 1) * width + x] = { button = cell, x = x, y = y }
			end
		end
		gridHolder.Size = UDim2.fromOffset(width * 24, height * 24)
	end
	for _, entry in ipairs(gridButtons) do
		local occupied = nil
		if profile ~= nil then
			occupied = profile.cells[string.format("%d,%d", entry.x, entry.y)]
		end
		if occupied ~= nil then
			entry.button.BackgroundColor3 = PIECE_COLOUR[occupied.kind] or BLUE
		else
			entry.button.BackgroundColor3 = Color3.fromRGB(214, 206, 190)
		end
	end
end

paintPieces()

local function refreshPlots()
	for index, card in ipairs(plotCards) do
		local row = nil
		for _, item in ipairs(state.plots or {}) do
			if item.index == index then
				row = item
			end
		end
		if row == nil or row.open then
			card.owner.Text = "Open"
			card.button.Text = "Claim"
			card.button.BackgroundColor3 = GREEN
			card.button.AutoButtonColor = true
		elseif row.yours then
			card.owner.Text = "Your ground"
			card.button.Text = "Enter"
			card.button.BackgroundColor3 = BLUE
			card.button.AutoButtonColor = true
		else
			card.owner.Text = row.owner
			card.button.Text = "Taken"
			card.button.BackgroundColor3 = Color3.fromRGB(120, 116, 108)
			card.button.AutoButtonColor = false
		end
	end
end

for index, card in ipairs(plotCards) do
	card.button.MouseButton1Click:Connect(function()
		local result = call("ClaimPlot", index)
		applyResult(result)
		refreshPlots()
		if result ~= nil and result.ok then
			showPage("play")
			showSection("overview")
			paintGrid()
		end
	end)
end

local function refresh()
	local profile = state.profile
	if profile == nil then
		continueTitle.Text = "No save this visit"
		continueBody.Text = "Start a club, then pick a plot."
		cashLabel.Text = "£0"
		fansLabel.Text = "0 fans"
	else
		local clubName = if profile.club ~= nil then profile.club.name else "Unnamed club"
		continueTitle.Text = clubName
		continueBody.Text = string.format("£%s    %d fans    %d matches", money(profile.cash), profile.fans, profile.matchesHosted)
		cashLabel.Text = "£" .. money(profile.cash)
		fansLabel.Text = string.format("%d fans", profile.fans)
		local tier = if profile.league ~= nil then NAMES[profile.league.tier] or profile.league.tier else "No league yet"
		sideTitle.Text = tier
		local missing = Events.missing(profile, if profile.league ~= nil then profile.league.tier else "kickabout")
		local need = if #missing == 0 then "Ready to host." else "Still need: " .. table.concat(missing, ", ")
		local matchLine = ""
		if profile.activeMatch ~= nil then
			local left = math.max(0, Catalog.matchSeconds - math.floor(profile.activeMatch.elapsed))
			matchLine = string.format("\nLive %d-%d   %ds left", profile.activeMatch.home, profile.activeMatch.away, left)
		end
		sideBody.Text = string.format("%s\n%d seats\nReputation %d%s", need, profile.capacity or 0, profile.reputation, matchLine)
	end
	refreshPlots()
	if profile ~= nil then
		overviewLines[1].Text = if profile.club ~= nil then profile.club.name else "Club not founded"
		overviewLines[2].Text = string.format("Cash £%s", money(profile.cash))
		overviewLines[3].Text = string.format("Fans %d    Seats %d", profile.fans, profile.capacity or 0)
		overviewLines[4].Text = string.format("Reputation %d", profile.reputation)
		local tierName = if profile.league ~= nil then NAMES[profile.league.tier] or profile.league.tier else "Kickabout friendlies"
		overviewLines[5].Text = tierName
		local nextId = if profile.league ~= nil then profile.league.tier else "kickabout"
		local missing = Events.missing(profile, nextId)
		overviewLines[6].Text = if #missing == 0 then "Nothing missing for this fixture." else "Missing: " .. table.concat(missing, ", ")
		for _, competitionId in ipairs(ORDER) do
			local row = eventRows[competitionId]
			local gaps = Events.missing(profile, competitionId)
			local competition = Catalog.competitions[competitionId]
			if #gaps == 0 then
				row.detail.Text = string.format("£%s base", money(competition.baseCash))
				row.start.BackgroundColor3 = GREEN
				row.start.Text = "Start"
			else
				row.detail.Text = table.concat(gaps, ", ")
				row.start.BackgroundColor3 = Color3.fromRGB(120, 116, 108)
				row.start.Text = "Closed"
			end
		end
		for objectiveId, claim in pairs(objectiveButtons) do
			claim.Text = string.format("%s   £%s%s", string.gsub(objectiveId, "_", " "), money(Catalog.objectives[objectiveId].cash), if profile.objectives[objectiveId] then "  done" else "")
		end
		for _, contract in ipairs(Catalog.sponsors) do
			local progress = profile.sponsors[contract.id]
			local paid = progress ~= nil and progress.paid
			sponsorLines[contract.id].Text = string.format("%d matches  £%s%s", contract.matches, money(contract.cash), if paid then "  paid" else "")
		end
	end
	paintGrid()
end

stateRemote.OnClientEvent:Connect(function(nextState)
	if type(nextState) == "table" then
		state = nextState
		if nextState.lastMatch ~= nil then
			local match = nextState.lastMatch
			setStatus(string.format("%d-%d   +£%s", match.home, match.away, money(match.cash)))
		end
		refresh()
	end
end)

local function boot()
	local result = call("GetState")
	if result ~= nil and result.state ~= nil then
		state = result.state
	end
	refresh()
	showPage("title")
end

boot()
