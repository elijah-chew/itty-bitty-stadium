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

local Catalog = load("Catalog")

local Monetisation = {}

function Monetisation.multiplier(profile)
	if profile.doubleMoney then
		return 2
	end
	return 1
end

function Monetisation.setDoubleMoney(profile, owned)
	local before = profile.cash
	profile.doubleMoney = if owned then true else false
	profile.cash = before
end

function Monetisation.setPitchPass(profile, owned)
	local before = profile.cash
	profile.pitchPass = if owned then true else false
	profile.cash = before
end

function Monetisation.grant(profile, productKey, purchaseId)
	local product = Catalog.products[productKey]
	if product == nil or purchaseId == nil or purchaseId == "" then
		return "not_processed", 0
	end
	local receiptId = tostring(purchaseId)
	if profile.receipts[receiptId] then
		return "duplicate", 0
	end
	local amount = product.cash * Monetisation.multiplier(profile)
	profile.receipts[receiptId] = true
	profile.cash = profile.cash + amount
	return "granted", amount
end

return Monetisation
