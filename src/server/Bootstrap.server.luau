local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Simulation = require(ReplicatedStorage:WaitForChild("Simulation"))
local Map = require(script.Parent:WaitForChild("Map"))

local Catalog = Simulation.Catalog
local Club = Simulation.Club
local Grid = Simulation.Grid
local Kits = Simulation.Kits
local Objectives = Simulation.Objectives
local Profile = Simulation.Profile
local Save = Simulation.Save
local Session = Simulation.Session
local SideTasks = Simulation.SideTasks
local Events = Simulation.Events
local Venue = Simulation.Venue

local plots = Map.build()
local server = Session.newServer()
local profiles = {}

local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local actionRemote = Instance.new("RemoteFunction")
actionRemote.Name = "Action"
actionRemote.Parent = remotes

local stateRemote = Instance.new("RemoteEvent")
stateRemote.Name = "State"
stateRemote.Parent = remotes

local function plotIndexOf(userId)
	for index = 1, Catalog.plotCount do
		if server.plots[index] == userId then
			return index
		end
	end
	return nil
end

local function release(userId)
	local index = plotIndexOf(userId)
	if index ~= nil then
		server.plots[index] = nil
		Map.redraw(plots[index], nil)
	end
end

local function playerName(userId)
	if userId == nil then
		return ""
	end
	local player = Players:GetPlayerByUserId(userId)
	if player ~= nil then
		return player.DisplayName
	end
	return "Taken"
end

local function snapshot(player)
	local profile = profiles[player.UserId]
	local rows = Session.list(server)
	local plotsState = {}
	for _, row in ipairs(rows) do
		table.insert(plotsState, {
			index = row.index,
			open = row.owner == nil,
			yours = row.owner == player.UserId,
			owner = playerName(row.owner),
		})
	end
	local exported = nil
	if profile ~= nil then
		exported = Save.export(profile)
		exported.capacity = Venue.capacity(profile)
		exported.best = Events.best(profile)
	end
	return {
		profile = exported,
		plotIndex = plotIndexOf(player.UserId),
		plots = plotsState,
	}
end

local function push(player, extra)
	local state = snapshot(player)
	if extra ~= nil then
		for key, value in pairs(extra) do
			state[key] = value
		end
	end
	stateRemote:FireClient(player, state)
	return state
end

local function pushPlots()
	for _, player in ipairs(Players:GetPlayers()) do
		push(player)
	end
end

local function requireProfile(player)
	local profile = profiles[player.UserId]
	if profile == nil then
		return nil, "no club"
	end
	return profile
end

local function requirePlot(player)
	local profile, reason = requireProfile(player)
	if profile == nil then
		return nil, reason
	end
	if plotIndexOf(player.UserId) == nil then
		return nil, "claim a plot"
	end
	return profile
end

local function redrawOwned(player)
	local index = plotIndexOf(player.UserId)
	local profile = profiles[player.UserId]
	if index ~= nil then
		Map.redraw(plots[index], profile)
	end
end

local actions = {}

function actions.GetState(player)
	return true, nil
end

function actions.NewClub(player)
	release(player.UserId)
	profiles[player.UserId] = Profile.new()
	return true
end

function actions.ClaimPlot(player, plotIndex)
	if profiles[player.UserId] == nil then
		return false, "no club"
	end
	local index, reason = Session.claim(server, player.UserId, plotIndex)
	if index == nil then
		return false, reason
	end
	Map.teleport(player, plots[index])
	redrawOwned(player)
	return true
end

function actions.PlacePiece(player, x, y, kind, facing)
	local profile, reason = requirePlot(player)
	if profile == nil then
		return false, reason
	end
	local ok, placeReason = Grid.place(profile, x, y, kind, facing)
	if not ok then
		return false, placeReason
	end
	redrawOwned(player)
	return true
end

function actions.RemovePiece(player, x, y)
	local profile, reason = requirePlot(player)
	if profile == nil then
		return false, reason
	end
	local ok, removeReason = Grid.remove(profile, x, y)
	if not ok then
		return false, removeReason
	end
	redrawOwned(player)
	return true
end

function actions.ExpandLand(player)
	local profile, reason = requirePlot(player)
	if profile == nil then
		return false, reason
	end
	local ok, expandReason = Grid.expand(profile)
	if not ok then
		return false, expandReason
	end
	return true
end

function actions.HostMatch(player, competitionId)
	local profile, reason = requirePlot(player)
	if profile == nil then
		return false, reason
	end
	local ok, hostReason = Session.host(profile, competitionId, math.random(1, 1000000))
	if not ok then
		return false, hostReason
	end
	return true
end

function actions.FoundClub(player, name, primary, secondary)
	local profile, reason = requirePlot(player)
	if profile == nil then
		return false, reason
	end
	return Club.found(profile, name, primary, secondary)
end

function actions.CompleteSideTask(player, taskId)
	local profile, reason = requireProfile(player)
	if profile == nil then
		return false, reason
	end
	return SideTasks.complete(profile, taskId)
end

function actions.ClaimObjective(player, objectiveId)
	local profile, reason = requireProfile(player)
	if profile == nil then
		return false, reason
	end
	return Objectives.claim(profile, objectiveId)
end

function actions.BuyJersey(player, kitId)
	local profile, reason = requireProfile(player)
	if profile == nil then
		return false, reason
	end
	return Kits.buy(profile, kitId)
end

actionRemote.OnServerInvoke = function(player, name, a, b, c, d)
	local fn = actions[name]
	if fn == nil then
		return { ok = false, reason = "unknown", state = snapshot(player) }
	end
	local ok, result, detail = pcall(fn, player, a, b, c, d)
	if not ok then
		return { ok = false, reason = "failed", state = snapshot(player) }
	end
	local state = push(player)
	if name == "ClaimPlot" or name == "NewClub" then
		pushPlots()
	end
	return { ok = result == true, reason = detail, state = state }
end

local function sendToPlot(player)
	local index = plotIndexOf(player.UserId)
	if index ~= nil then
		task.defer(function()
			Map.teleport(player, plots[index])
		end)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		sendToPlot(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	release(player.UserId)
	profiles[player.UserId] = nil
	pushPlots()
end)

local elapsed = 0
local shownSecond = {}
RunService.Heartbeat:Connect(function(dt)
	elapsed = elapsed + dt
	if elapsed < 0.25 then
		return
	end
	local step = elapsed
	elapsed = 0
	for _, player in ipairs(Players:GetPlayers()) do
		local profile = profiles[player.UserId]
		if profile ~= nil and profile.activeMatch ~= nil then
			local result = Session.advance(profile, step)
			if result ~= nil then
				shownSecond[player.UserId] = nil
				redrawOwned(player)
				push(player, { lastMatch = result })
			else
				local whole = math.floor(profile.activeMatch.elapsed)
				if shownSecond[player.UserId] ~= whole then
					shownSecond[player.UserId] = whole
					push(player)
				end
			end
		end
	end
end)
