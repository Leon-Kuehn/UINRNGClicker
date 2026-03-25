-- FormatUtils.lua
-- Shared number and text formatting helpers.
-- Safe to require on both client and server.

local FormatUtils = {}

-- Compact large numbers: 1500 → "1.50K", 2 000 000 → "2.00M", etc.
function FormatUtils.CompactNumber(value: number): string
	local abs = math.abs(value)
	if abs >= 1e12 then
		return string.format("%.2fT", value / 1e12)
	elseif abs >= 1e9 then
		return string.format("%.2fB", value / 1e9)
	elseif abs >= 1e6 then
		return string.format("%.2fM", value / 1e6)
	elseif abs >= 1e3 then
		return string.format("%.2fK", value / 1e3)
	end
	return string.format("%d", math.floor(value))
end

-- Format a weapon multiplier for display: 1.5 → "x1.5",  12 → "x12.0"
function FormatUtils.FormatMultiplier(mult: number): string
	return string.format("x%.1f", mult)
end

return FormatUtils
