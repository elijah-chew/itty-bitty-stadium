local function load(name)
	local ok, current = pcall(function()
		return script
	end)
	if ok and current ~= nil and current.Parent ~= nil then
		local child = current.Parent:FindFirstChild(name)
		if child ~= nil then
			return require(child)
		end
	end
	return require("./" .. name)
end

return load
