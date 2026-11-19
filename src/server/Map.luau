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

return Map
