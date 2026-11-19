local Save = {}

local function copy(value)
	if type(value) ~= "table" then
		return value
	end
	local cloned = {}
	for key, child in pairs(value) do
		cloned[key] = copy(child)
	end
	return cloned
end

function Save.export(profile)
	local data = copy(profile)
	data.version = 1
	return data
end

function Save.import(data)
	if type(data) ~= "table" or data.version ~= 1 then
		return nil, "version"
	end
	if type(data.cash) ~= "number" or type(data.width) ~= "number" or type(data.height) ~= "number" then
		return nil, "profile"
	end
	if type(data.cells) ~= "table" or type(data.sponsors) ~= "table" or type(data.objectives) ~= "table" then
		return nil, "profile"
	end
	return copy(data)
end

return Save
