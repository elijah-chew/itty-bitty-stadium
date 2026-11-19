local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local early = Instance.new("ScreenGui")
early.Name = "IttyBittyLoading"
early.ResetOnSpawn = false
early.IgnoreGuiInset = true
early.DisplayOrder = 20
early.Parent = player:WaitForChild("PlayerGui")
local earlyCard = Instance.new("TextLabel")
earlyCard.AnchorPoint = Vector2.new(0.5, 0)
earlyCard.Position = UDim2.new(0.5, 0, 0, 18)
earlyCard.Size = UDim2.fromOffset(280, 36)
earlyCard.BackgroundColor3 = Color3.fromRGB(245, 241, 230)
earlyCard.TextColor3 = Color3.fromRGB(32, 36, 42)
earlyCard.Font = Enum.Font.GothamBold
earlyCard.TextSize = 16
earlyCard.Text = "ITTY BITTY STADIUM"
earlyCard.Parent = early
local earlyRound = Instance.new("UICorner")
earlyRound.CornerRadius = UDim.new(0, 12)
earlyRound.Parent = earlyCard

local loaded, Simulation = pcall(function()
	return require(ReplicatedStorage:WaitForChild("Simulation"))
end)
if not loaded then
	earlyCard.Text = "Game data failed to load"
	return
end
local Catalog = Simulation.Catalog
local Events = Simulation.Events

local remotes = ReplicatedStorage:WaitForChild("Remotes", 20)
if remotes == nil then
	earlyCard.Text = "Server did not start. Press Stop, then Play."
	return
end
local actionRemote = remotes:WaitForChild("Action")
local stateRemote = remotes:WaitForChild("State")

local INK = Color3.fromRGB(28, 30, 34)
local CREAM = Color3.fromRGB(245, 241, 230)
local PAPER = Color3.fromRGB(236, 232, 220)
local GREEN = Color3.fromRGB(46, 168, 86)
local RED = Color3.fromRGB(214, 64, 54)
local BLUE = Color3.fromRGB(46, 110, 210)
local GOLD = Color3.fromRGB(214, 164, 54)
local MUTED = Color3.fromRGB(110, 106, 98)
local CELL = 8

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

local selectedKind = "grass"
local selectedGroup = "Pitch"
local facing = "south"
local removeMode = false
local page = "title"
local menuOpen = false
local state = { profile = nil, plots = {}, plotIndex = nil }

local gui = Instance.new("ScreenGui")
gui.Name = "IttyBittyStadium"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")
early:Destroy()

local function money(amount)
	local digits = tostring(math.floor(amount or 0))
	local reversed = string.reverse(digits)
	local grouped = string.gsub(reversed, "(%d%d%d)", "%1,")
	if string.sub(grouped, -1) == "," then
		grouped = string.sub(grouped, 1, -2)
	end
	return string.reverse(grouped)
end

local function corner(parent, radius)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius or 12)
	item.Parent = parent
	return item
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
	item.TextSize = 15
	item.TextColor3 = CREAM
	item.BackgroundColor3 = colour or BLUE
	item.Text = text
	item.AutoLocalize = false
	item.Parent = parent
	corner(item, 10)
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
	corner(frame, 16)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(32, 36, 42)
	stroke.Transparency = 0.88
	stroke.Thickness = 1
	stroke.Parent = frame
	return frame
end

local REASONS = {
	["no grass"] = "Lay a rectangle of grass first.",
	["goals"] = "Put one goal in the middle of each end.",
	["not a rectangle"] = "The grass has to be one solid rectangle.",
	["too small"] = "That pitch is too small for a match.",
	["off the pitch"] = "Stands sit on the edge, after the pitch is valid.",
	["out of bounds"] = "That square is outside your land. Expand to open more.",
	["occupied"] = "Something is already on that square.",
	["not enough cash"] = "Not enough cash.",
	["pitch pass"] = "An 11v11 pitch needs the expansion pass.",
	["claim a plot"] = "Claim a plot first.",
	["no club"] = "Start a club first.",
	["facing"] = "Turn the piece with Face.",
	["empty"] = "That square is already empty.",
}

local function call(name, a, b, c, d)
	local result = actionRemote:InvokeServer(name, a, b, c, d)
	if type(result) == "table" and result.state ~= nil then
		state = result.state
	end
	return result
end

local function shade()
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 0.35
	frame.BorderSizePixel = 0
	frame.Parent = gui
	return frame
end

local titleShade = shade()
local titleCard = panel(gui, CREAM)
titleCard.AnchorPoint = Vector2.new(0.5, 0.5)
titleCard.Position = UDim2.fromScale(0.5, 0.5)
titleCard.Size = UDim2.fromOffset(420, 300)
titleCard.ZIndex = 2
local kicker = label(titleCard, "A FOOTBALL GROUND", 13, GREEN)
kicker.Position = UDim2.fromOffset(28, 28)
kicker.Size = UDim2.new(1, -56, 0, 18)
local titleHeading = label(titleCard, "ITTY BITTY\nSTADIUM", 40, INK)
titleHeading.Position = UDim2.fromOffset(28, 50)
titleHeading.Size = UDim2.new(1, -56, 0, 96)
local blurb = label(titleCard, "Lay the pitch. Fill the stands. Keep the club in profit.", 16, MUTED)
blurb.Position = UDim2.fromOffset(28, 156)
blurb.Size = UDim2.new(1, -56, 0, 44)
blurb.TextWrapped = true
blurb.Font = Enum.Font.Gotham

local clubShade = shade()
clubShade.Visible = false
local clubCard = panel(gui, CREAM)
clubCard.AnchorPoint = Vector2.new(0.5, 0.5)
clubCard.Position = UDim2.fromScale(0.5, 0.5)
clubCard.Size = UDim2.fromOffset(640, 280)
clubCard.Visible = false
clubCard.ZIndex = 2
local clubHeading = label(clubCard, "Your club", 28, INK)
clubHeading.Position = UDim2.fromOffset(24, 18)
clubHeading.Size = UDim2.fromOffset(280, 34)

local continueTitle = label(clubCard, "No save this visit", 18, INK)
continueTitle.Position = UDim2.fromOffset(24, 70)
continueTitle.Size = UDim2.fromOffset(280, 28)
local continueBody = label(clubCard, "Start a club, then pick a plot.", 14, MUTED)
continueBody.Position = UDim2.fromOffset(24, 104)
continueBody.Size = UDim2.fromOffset(270, 60)
continueBody.TextWrapped = true
continueBody.Font = Enum.Font.Gotham

local plotShade = shade()
plotShade.Visible = false
local plotCard = panel(gui, CREAM)
plotCard.AnchorPoint = Vector2.new(0.5, 0.5)
plotCard.Position = UDim2.fromScale(0.5, 0.5)
plotCard.Size = UDim2.fromOffset(760, 460)
plotCard.Visible = false
plotCard.ZIndex = 2
local plotTitle = label(plotCard, "Select a plot", 26, INK)
plotTitle.Position = UDim2.fromOffset(24, 16)
plotTitle.Size = UDim2.fromOffset(320, 32)
local plotHint = label(plotCard, "Six grounds. An open plot is yours.", 14, MUTED)
plotHint.Position = UDim2.fromOffset(24, 50)
plotHint.Size = UDim2.fromOffset(400, 22)
plotHint.Font = Enum.Font.Gotham

local plotCards = {}
for index = 1, 6 do
	local column = (index - 1) % 3
	local row = math.floor((index - 1) / 3)
	local card = panel(plotCard, PAPER)
	card.Position = UDim2.fromOffset(24 + column * 240, 88 + row * 170)
	card.Size = UDim2.fromOffset(224, 154)
	local plotName = label(card, "Plot " .. index, 18, INK)
	plotName.Position = UDim2.fromOffset(14, 12)
	plotName.Size = UDim2.new(1, -28, 0, 24)
	local owner = label(card, "Open", 14, MUTED)
	owner.Position = UDim2.fromOffset(14, 44)
	owner.Size = UDim2.new(1, -28, 0, 36)
	owner.TextWrapped = true
	owner.Font = Enum.Font.Gotham
	local claimButton = button(card, "Claim", GREEN)
	claimButton.Position = UDim2.fromOffset(14, 100)
	claimButton.Size = UDim2.fromOffset(110, 36)
	plotCards[index] = { owner = owner, button = claimButton }
end

local top = Instance.new("Frame")
top.Size = UDim2.fromScale(1, 1)
top.BackgroundTransparency = 1
top.Visible = false
top.Active = false
top.Parent = gui

local function pill(text, colour, x)
	local item = label(top, text, 16, INK)
	item.BackgroundColor3 = CREAM
	item.BackgroundTransparency = 0
	item.Position = UDim2.fromOffset(x, 16)
	item.Size = UDim2.fromOffset(150, 40)
	item.TextXAlignment = Enum.TextXAlignment.Center
	corner(item, 12)
	return item
end

local menuButton = button(top, "MENU", INK)
menuButton.Position = UDim2.fromOffset(16, 16)
menuButton.Size = UDim2.fromOffset(92, 40)
local cashLabel = pill("£0", GREEN, 120)
local fansLabel = pill("0 fans", GOLD, 282)
local statusLabel = label(top, "", 15, CREAM)
statusLabel.Position = UDim2.new(0.5, -160, 0, 22)
statusLabel.Size = UDim2.fromOffset(320, 28)
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.BackgroundColor3 = INK
statusLabel.BackgroundTransparency = 0.15
corner(statusLabel, 10)
statusLabel.Visible = false
statusLabel.Active = false

local sideCard = panel(top, CREAM)
sideCard.AnchorPoint = Vector2.new(1, 0)
sideCard.Position = UDim2.new(1, -16, 0, 70)
sideCard.Size = UDim2.fromOffset(230, 210)
local sideTitle = label(sideCard, "Kickabout", 16, INK)
sideTitle.Position = UDim2.fromOffset(14, 12)
sideTitle.Size = UDim2.new(1, -28, 0, 40)
sideTitle.TextWrapped = true
local sideBody = label(sideCard, "Point at your land to build.", 13, MUTED)
sideBody.Position = UDim2.fromOffset(14, 54)
sideBody.Size = UDim2.new(1, -28, 0, 80)
sideBody.TextWrapped = true
sideBody.Font = Enum.Font.Gotham
sideBody.TextYAlignment = Enum.TextYAlignment.Top

local dock = panel(top, CREAM)
dock.AnchorPoint = Vector2.new(0.5, 1)
dock.Position = UDim2.new(0.5, 0, 1, -16)
dock.Size = UDim2.new(0.94, 0, 0, 176)
local dockLimit = Instance.new("UISizeConstraint")
dockLimit.MaxSize = Vector2.new(1040, 176)
dockLimit.Parent = dock
local buildHeader = label(dock, "Grass    £250", 16, INK)
buildHeader.Position = UDim2.fromOffset(16, 10)
buildHeader.Size = UDim2.new(1, -32, 0, 22)

local groupRow = Instance.new("Frame")
groupRow.BackgroundTransparency = 1
groupRow.Position = UDim2.fromOffset(16, 38)
groupRow.Size = UDim2.new(1, -32, 0, 34)
groupRow.Parent = dock
local pieceRow = Instance.new("ScrollingFrame")
pieceRow.BackgroundTransparency = 1
pieceRow.BorderSizePixel = 0
pieceRow.Position = UDim2.fromOffset(16, 76)
pieceRow.Size = UDim2.new(1, -32, 0, 40)
pieceRow.ScrollBarThickness = 4
pieceRow.ScrollingDirection = Enum.ScrollingDirection.X
pieceRow.AutomaticCanvasSize = Enum.AutomaticSize.X
pieceRow.CanvasSize = UDim2.fromOffset(0, 0)
pieceRow.Parent = dock
local pieceLayout = Instance.new("UIListLayout")
pieceLayout.FillDirection = Enum.FillDirection.Horizontal
pieceLayout.Padding = UDim.new(0, 8)
pieceLayout.SortOrder = Enum.SortOrder.LayoutOrder
pieceLayout.Parent = pieceRow
local toolRow = Instance.new("Frame")
toolRow.BackgroundTransparency = 1
toolRow.Position = UDim2.fromOffset(16, 122)
toolRow.Size = UDim2.new(1, -32, 0, 34)
toolRow.Parent = dock

local hint = label(top, "Point at your land to build", 14, INK)
hint.AnchorPoint = Vector2.new(0.5, 1)
hint.Position = UDim2.new(0.5, 0, 1, -196)
hint.Size = UDim2.fromOffset(560, 36)
hint.TextWrapped = true
hint.BackgroundColor3 = CREAM
hint.BackgroundTransparency = 0
hint.TextXAlignment = Enum.TextXAlignment.Center
hint.Font = Enum.Font.Gotham
hint.Active = false
corner(hint, 10)

local HINTS = {
	grass = "Click the pale squares. Keep the grass as one rectangle.",
	goal = "One goal in the middle of each end, facing onto the pitch.",
	stand_small = "Stands snap to the touchline once the pitch is valid.",
	stand_medium = "Stands snap to the touchline once the pitch is valid.",
	stand_corner = "Corner stands snap to the four corners of the pitch.",
	stand_angle = "Angle stands snap to the ends of each touchline.",
}

local menu = Instance.new("Frame")
menu.Size = UDim2.fromScale(1, 1)
menu.BackgroundTransparency = 1
menu.Visible = false
menu.ZIndex = 5
menu.Parent = gui

local nav = Instance.new("Frame")
nav.Size = UDim2.new(0, 220, 1, -40)
nav.Position = UDim2.fromOffset(20, 20)
nav.BackgroundColor3 = INK
nav.BorderSizePixel = 0
nav.Parent = menu
corner(nav, 18)
label(nav, "YOUR CLUB", 12, GOLD).Position = UDim2.fromOffset(16, 18)
local navClub = label(nav, "Unnamed", 16, CREAM)
navClub.Position = UDim2.fromOffset(16, 36)
navClub.Size = UDim2.new(1, -32, 0, 24)

local sheet = panel(menu, CREAM)
sheet.Position = UDim2.fromOffset(256, 20)
sheet.Size = UDim2.new(1, -276, 1, -40)
local sheetTitle = label(sheet, "Overview", 26, INK)
sheetTitle.Position = UDim2.fromOffset(24, 18)
sheetTitle.Size = UDim2.new(1, -160, 0, 34)
local sheetCash = label(sheet, "£0", 14, GREEN)
sheetCash.AnchorPoint = Vector2.new(1, 0)
sheetCash.Position = UDim2.new(1, -24, 0, 22)
sheetCash.Size = UDim2.fromOffset(140, 24)
sheetCash.TextXAlignment = Enum.TextXAlignment.Right

local pages = {}
local function addPage(name)
	local frame = Instance.new("ScrollingFrame")
	frame.Name = name
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Position = UDim2.fromOffset(24, 68)
	frame.Size = UDim2.new(1, -48, 1, -84)
	frame.CanvasSize = UDim2.fromOffset(0, 0)
	frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	frame.ScrollBarThickness = 6
	frame.Visible = false
	frame.Parent = sheet
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = frame
	pages[name] = frame
	return frame
end

local PAGE_TITLES = {
	overview = "Overview",
	events = "Events",
	objectives = "Objectives",
	sponsors = "Sponsors",
	upgrades = "Upgrades",
	customise = "Customise",
	shop = "Shop",
	changelog = "Changelog",
}
for name in pairs(PAGE_TITLES) do
	addPage(name)
end

local navButtons = {}
local function showSection(name)
	for id, frame in pairs(pages) do
		frame.Visible = id == name
	end
	sheetTitle.Text = PAGE_TITLES[name] or name
	for id, navButton in pairs(navButtons) do
		navButton.BackgroundColor3 = if id == name then CREAM else INK
		navButton.TextColor3 = if id == name then INK else CREAM
	end
end

local function showPage(name)
	page = name
	titleShade.Visible = name == "title"
	titleCard.Visible = name == "title"
	clubShade.Visible = name == "club"
	clubCard.Visible = name == "club"
	plotShade.Visible = name == "plots"
	plotCard.Visible = name == "plots"
	top.Visible = name == "play"
	if name ~= "play" then
		menuOpen = false
		menu.Visible = false
	end
end

local function setStatus(text, bad)
	statusLabel.Text = text or ""
	statusLabel.Visible = text ~= nil and text ~= ""
	statusLabel.TextColor3 = if bad then Color3.fromRGB(255, 186, 176) else CREAM
end

local function applyResult(result)
	if result == nil then
		setStatus("No answer from the server", true)
		return
	end
	if result.ok then
		setStatus("")
	else
		local reason = tostring(result.reason or "not allowed")
		setStatus(REASONS[reason] or reason, true)
	end
	if result.state ~= nil and result.state.lastMatch ~= nil then
		local match = result.state.lastMatch
		setStatus(string.format("%d-%d    +£%s", match.home, match.away, money(match.cash)))
	end
end

local playButton = button(titleCard, "Play", GREEN, function()
	showPage("club")
end)
playButton.Position = UDim2.fromOffset(28, 214)
playButton.Size = UDim2.new(1, -56, 0, 48)

local continueButton = button(clubCard, "Continue", GREEN, function()
	if state.profile == nil then
		setStatus("Start a new club first", true)
		showPage("play")
		return
	end
	if state.plotIndex == nil then
		showPage("plots")
	else
		showPage("play")
	end
end)
continueButton.Position = UDim2.fromOffset(24, 190)
continueButton.Size = UDim2.fromOffset(140, 44)

local newButton = button(clubCard, "New club", BLUE, function()
	applyResult(call("NewClub"))
	showPage("plots")
end)
newButton.Position = UDim2.fromOffset(340, 190)
newButton.Size = UDim2.fromOffset(140, 44)
local newNote = label(clubCard, "£12,000 to start. This save lasts for the server visit.", 14, MUTED)
newNote.Position = UDim2.fromOffset(340, 104)
newNote.Size = UDim2.fromOffset(260, 60)
newNote.TextWrapped = true
newNote.Font = Enum.Font.Gotham

menuButton.MouseButton1Click:Connect(function()
	menuOpen = not menuOpen
	menu.Visible = menuOpen
	if menuOpen then
		showSection("overview")
	end
end)

local closeMenu = button(sheet, "Close", INK, function()
	menuOpen = false
	menu.Visible = false
end)
closeMenu.AnchorPoint = Vector2.new(1, 0)
closeMenu.Position = UDim2.new(1, -24, 0, 16)
closeMenu.Size = UDim2.fromOffset(80, 34)

local NAV = {
	{ id = "overview", text = "Overview" },
	{ id = "events", text = "Events" },
	{ id = "objectives", text = "Objectives" },
	{ id = "sponsors", text = "Sponsors" },
	{ id = "upgrades", text = "Upgrades" },
	{ id = "customise", text = "Customise" },
	{ id = "shop", text = "Shop" },
}
for index, item in ipairs(NAV) do
	local navButton = button(nav, item.text, INK, function()
		showSection(item.id)
	end)
	navButton.Size = UDim2.new(1, -24, 0, 36)
	navButton.Position = UDim2.fromOffset(12, 78 + (index - 1) * 42)
	navButton.TextXAlignment = Enum.TextXAlignment.Left
	navButtons[item.id] = navButton
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 12)
	pad.Parent = navButton
end

local backButton = button(nav, "Back to ground", Color3.fromRGB(48, 52, 58), function()
	menuOpen = false
	menu.Visible = false
end)
backButton.Position = UDim2.new(0, 12, 1, -56)
backButton.Size = UDim2.new(1, -24, 0, 40)

local function line(parent, text, order)
	local item = label(parent, text, 15, INK)
	item.Size = UDim2.new(1, 0, 0, 28)
	item.LayoutOrder = order or 1
	item.TextWrapped = true
	return item
end

line(pages.changelog, "Kickabout is 5v5. Sunday league is 7v7. Every league after that is 11v11.", 1).Size = UDim2.new(1, 0, 0, 48)
line(pages.changelog, "Food stands and the club shop pay on top of the gate.", 2).Size = UDim2.new(1, 0, 0, 40)
line(pages.shop, "Robux prices are set on the Creator Dashboard. Pass and product ids are still 0, so nothing is charged yet.", 1).Size = UDim2.new(1, 0, 0, 56)
line(pages.shop, "2x Money doubles match, sponsor, objective, and pack cash.", 2).Size = UDim2.new(1, 0, 0, 40)
line(pages.shop, "Pitch Expansion unlocks an 11v11 grass pitch.", 3)
line(pages.shop, "Packs: £10,000, £50,000, £250,000.", 4)
line(pages.upgrades, "Buy a building here, then click an empty cell on your ground.", 1).Size = UDim2.new(1, 0, 0, 48)

local overviewLines = {}
for index = 1, 6 do
	overviewLines[index] = line(pages.overview, "", index)
	overviewLines[index].Size = UDim2.new(1, 0, 0, 26)
end

local eventRows = {}
for index, competitionId in ipairs(ORDER) do
	local row = Instance.new("Frame")
	row.BackgroundColor3 = PAPER
	row.Size = UDim2.new(1, 0, 0, 68)
	row.LayoutOrder = index
	row.Parent = pages.events
	corner(row, 10)
	local title = label(row, NAMES[competitionId], 16, INK)
	title.Position = UDim2.fromOffset(12, 8)
	title.Size = UDim2.new(1, -130, 0, 22)
	local detail = label(row, "", 13, MUTED)
	detail.Position = UDim2.fromOffset(12, 32)
	detail.Size = UDim2.new(1, -130, 0, 28)
	detail.Font = Enum.Font.Gotham
	detail.TextWrapped = true
	local start = button(row, "Start", GREEN, function()
		applyResult(call("HostMatch", competitionId))
	end)
	start.Position = UDim2.new(1, -108, 0, 14)
	start.Size = UDim2.fromOffset(92, 40)
	eventRows[competitionId] = { detail = detail, start = start }
end

local objectiveButtons = {}
for index, objectiveId in ipairs({ "host_match", "build_stand", "expand_once" }) do
	local reward = Catalog.objectives[objectiveId]
	local row = button(pages.objectives, objectiveId, BLUE, function()
		applyResult(call("ClaimObjective", objectiveId))
	end)
	row.Size = UDim2.new(1, 0, 0, 44)
	row.LayoutOrder = index
	row.Text = string.format("%s    £%s", string.gsub(objectiveId, "_", " "), money(reward.cash))
	objectiveButtons[objectiveId] = row
end

local sponsorLines = {}
for index, contract in ipairs(Catalog.sponsors) do
	sponsorLines[contract.id] = line(pages.sponsors, "", index)
	sponsorLines[contract.id].Size = UDim2.new(1, 0, 0, 28)
end

local hostBest = button(sideCard, "Host", GREEN, function()
	local profile = state.profile
	local competitionId = if profile ~= nil and profile.league ~= nil then profile.league.tier else "kickabout"
	applyResult(call("HostMatch", competitionId))
end)
hostBest.Position = UDim2.fromOffset(14, 164)
hostBest.Size = UDim2.new(1, -28, 0, 34)

local nameBox = Instance.new("TextBox")
nameBox.PlaceholderText = "Club name"
nameBox.Text = ""
nameBox.Font = Enum.Font.GothamBold
nameBox.TextSize = 16
nameBox.BackgroundColor3 = Color3.fromRGB(255, 252, 246)
nameBox.TextColor3 = INK
nameBox.Size = UDim2.new(1, 0, 0, 40)
nameBox.LayoutOrder = 1
nameBox.Parent = pages.customise
corner(nameBox, 8)

local primary = "navy"
local secondary = "white"
local colourRow = Instance.new("Frame")
colourRow.BackgroundTransparency = 1
colourRow.Size = UDim2.new(1, 0, 0, 44)
colourRow.LayoutOrder = 2
colourRow.Parent = pages.customise
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

local foundButton = button(pages.customise, "Found club", GREEN, function()
	applyResult(call("FoundClub", nameBox.Text, primary, secondary))
end)
foundButton.Size = UDim2.new(1, 0, 0, 44)
foundButton.LayoutOrder = 3

for index, kitId in ipairs({ "stripes", "hoops", "night" }) do
	local kit = Catalog.jerseys[kitId]
	local row = button(pages.customise, kit.name .. "  £" .. money(kit.cost), BLUE, function()
		applyResult(call("BuyJersey", kitId))
	end)
	row.Size = UDim2.new(1, 0, 0, 44)
	row.LayoutOrder = 3 + index
end

local taskRow = Instance.new("Frame")
taskRow.BackgroundTransparency = 1
taskRow.Size = UDim2.new(1, 0, 0, 44)
taskRow.LayoutOrder = 8
taskRow.Parent = pages.overview
for index, taskId in ipairs({ "grill", "merch", "coaching" }) do
	local task = Catalog.sideTasks[taskId]
	local row = button(taskRow, taskId, GOLD, function()
		applyResult(call("CompleteSideTask", taskId))
	end)
	row.TextColor3 = INK
	row.Size = UDim2.fromOffset(150, 36)
	row.Position = UDim2.fromOffset((index - 1) * 158, 4)
	row.Text = string.format("%s  £%s", taskId, money(task.cash))
end

local facingButton
local removeButton

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
			removeButton.Text = "Remove"
			paintPieces()
		end)
		chip.TextSize = 13
		chip.Size = UDim2.fromOffset(128, 32)
		chip.LayoutOrder = index
	end
	local piece = Catalog.pieces[selectedKind]
	if piece ~= nil then
		buildHeader.Text = string.format("%s    £%s", pieceName(selectedKind), money(piece.cost))
	end
	if not removeMode then
		hint.Text = HINTS[selectedKind] or "Point at the pale squares on your land."
	end
end

for index, group in ipairs(GROUPS) do
	local chip = button(groupRow, group.name, INK, function()
		selectedGroup = group.name
		selectedKind = group.pieces[1]
		removeMode = false
		removeButton.Text = "Remove"
		paintPieces()
	end)
	chip.Size = UDim2.fromOffset(110, 30)
	chip.Position = UDim2.fromOffset((index - 1) * 116, 0)
end

facingButton = button(toolRow, "Face south", INK, function()
	local cycle = { south = "west", west = "north", north = "east", east = "south" }
	facing = cycle[facing] or "south"
	facingButton.Text = "Face " .. facing
end)
facingButton.Size = UDim2.fromOffset(130, 32)
facingButton.Position = UDim2.fromOffset(0, 0)

removeButton = button(toolRow, "Remove", RED, function()
	removeMode = not removeMode
	removeButton.Text = if removeMode then "Removing" else "Remove"
	hint.Text = if removeMode then "Click a piece to sell it" else "Point at your land to build"
end)
removeButton.Size = UDim2.fromOffset(120, 32)
removeButton.Position = UDim2.fromOffset(140, 0)

local expandButton = button(toolRow, "Expand land", BLUE, function()
	applyResult(call("ExpandLand"))
	refresh()
end)
expandButton.Size = UDim2.fromOffset(140, 32)
expandButton.Position = UDim2.fromOffset(270, 0)

paintPieces()

local ghost = Instance.new("Part")
ghost.Name = "BuildGhost"
ghost.Anchored = true
ghost.CanCollide = false
ghost.CanQuery = false
ghost.Size = Vector3.new(CELL - 0.4, 0.4, CELL - 0.4)
ghost.Color = GREEN
ghost.Material = Enum.Material.SmoothPlastic
ghost.Transparency = 0.45
ghost.Parent = workspace

local function plotFromHit(instance)
	local current = instance
	while current ~= nil and current ~= workspace do
		if current:IsA("Model") and string.match(current.Name, "^Plot%d$") then
			return current
		end
		current = current.Parent
	end
	return nil
end

local function cellFromHit(hitPosition, plotModel)
	local origin = plotModel:FindFirstChild("Origin")
	if origin == nil then
		return nil
	end
	local delta = hitPosition - origin.Position
	local x = math.floor(delta.X / CELL) + 1
	local y = math.floor(delta.Z / CELL) + 1
	return x, y
end

local function inLand(x, y)
	local profile = state.profile
	if profile == nil or x == nil or y == nil then
		return false
	end
	local width = profile.width or 12
	local height = profile.height or 16
	return x >= 1 and y >= 1 and x <= width and y <= height
end

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
		end
	end)
end

function refresh()
	local profile = state.profile
	if profile == nil then
		continueTitle.Text = "No save this visit"
		continueBody.Text = "Start a club, then pick a plot."
		cashLabel.Text = "£0"
		fansLabel.Text = "0 fans"
		navClub.Text = "No club"
		sheetCash.Text = "£0"
	else
		local clubName = if profile.club ~= nil then profile.club.name else "Unnamed club"
		continueTitle.Text = clubName
		continueBody.Text = string.format("£%s    %d fans    %d matches", money(profile.cash), profile.fans, profile.matchesHosted)
		cashLabel.Text = "£" .. money(profile.cash)
		fansLabel.Text = string.format("%d fans", profile.fans)
		navClub.Text = clubName
		sheetCash.Text = "£" .. money(profile.cash)
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
		overviewLines[1].Text = clubName
		overviewLines[2].Text = string.format("Cash £%s", money(profile.cash))
		overviewLines[3].Text = string.format("Fans %d    Seats %d", profile.fans, profile.capacity or 0)
		overviewLines[4].Text = string.format("Reputation %d", profile.reputation)
		local tierName = if profile.league ~= nil then NAMES[profile.league.tier] or profile.league.tier else "Kickabout friendlies"
		overviewLines[5].Text = tierName
		local nextId = if profile.league ~= nil then profile.league.tier else "kickabout"
		local gaps = Events.missing(profile, nextId)
		overviewLines[6].Text = if #gaps == 0 then "Nothing missing for this fixture." else "Missing: " .. table.concat(gaps, ", ")
		for _, competitionId in ipairs(ORDER) do
			local row = eventRows[competitionId]
			local missingNow = Events.missing(profile, competitionId)
			local competition = Catalog.competitions[competitionId]
			if #missingNow == 0 then
				row.detail.Text = string.format("£%s base", money(competition.baseCash))
				row.start.BackgroundColor3 = GREEN
				row.start.Text = "Start"
			else
				row.detail.Text = table.concat(missingNow, ", ")
				row.start.BackgroundColor3 = Color3.fromRGB(120, 116, 108)
				row.start.Text = "Closed"
			end
		end
		for objectiveId, claim in pairs(objectiveButtons) do
			claim.Text = string.format("%s    £%s%s", string.gsub(objectiveId, "_", " "), money(Catalog.objectives[objectiveId].cash), if profile.objectives[objectiveId] then "  done" else "")
		end
		for _, contract in ipairs(Catalog.sponsors) do
			local progress = profile.sponsors[contract.id]
			local paid = progress ~= nil and progress.paid
			sponsorLines[contract.id].Text = string.format("%d matches  £%s%s", contract.matches, money(contract.cash), if paid then "  paid" else "")
		end
	end
	refreshPlots()
end

stateRemote.OnClientEvent:Connect(function(nextState)
	if type(nextState) == "table" then
		state = nextState
		if nextState.lastMatch ~= nil then
			local match = nextState.lastMatch
			setStatus(string.format("%d-%d    +£%s", match.home, match.away, money(match.cash)))
		end
		refresh()
	end
end)

local function ownedPlot()
	if state.plotIndex == nil then
		return nil
	end
	local plots = workspace:FindFirstChild("Plots")
	if plots == nil then
		return nil
	end
	return plots:FindFirstChild("Plot" .. state.plotIndex)
end

RunService.RenderStepped:Connect(function()
	if page ~= "play" or menuOpen or mouse.Target == nil then
		ghost.Transparency = 1
		return
	end
	local plotModel = plotFromHit(mouse.Target)
	local mine = ownedPlot()
	if plotModel == nil or mine == nil or plotModel ~= mine then
		ghost.Transparency = 1
		return
	end
	local x, y = cellFromHit(mouse.Hit.Position, plotModel)
	if x == nil then
		ghost.Transparency = 1
		return
	end
	local origin = plotModel.Origin
	local legal = inLand(x, y)
	ghost.Transparency = 0.4
	ghost.Color = if removeMode or not legal then RED else GREEN
	ghost.CFrame = CFrame.new(origin.Position + Vector3.new((x - 0.5) * CELL, 0.6, (y - 0.5) * CELL))
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or page ~= "play" or menuOpen then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end
	if mouse.Target == nil then
		return
	end
	local plotModel = plotFromHit(mouse.Target)
	local mine = ownedPlot()
	if plotModel == nil or mine == nil or plotModel ~= mine then
		return
	end
	local x, y = cellFromHit(mouse.Hit.Position, plotModel)
	if x == nil then
		return
	end
	if not inLand(x, y) then
		setStatus(REASONS["out of bounds"], true)
		return
	end
	if removeMode then
		applyResult(call("RemovePiece", x, y))
	else
		applyResult(call("PlacePiece", x, y, selectedKind, facing))
	end
	refresh()
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
