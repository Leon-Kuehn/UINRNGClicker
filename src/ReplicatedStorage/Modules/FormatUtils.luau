--!strict
-- Number and string formatting utilities shared between server and client.

local FormatUtils = {}

-- Format a large integer with K / M / B / T suffixes (e.g. 1500 → "1.5K").
function FormatUtils.formatNumber(n: number): string
	n = math.floor(n)
	if n >= 1e12 then
		return string.format("%.2fT", n / 1e12)
	elseif n >= 1e9 then
		return string.format("%.2fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("%.2fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("%.1fK", n / 1e3)
	end
	return tostring(n)
end

-- Format a percentage with enough precision to show even tiny chances.
-- e.g. 0.0555...% → "0.0556%"
function FormatUtils.formatPercent(n: number): string
	if n < 0.01 then
		return string.format("%.4f%%", n)
	end
	return string.format("%.2f%%", n)
end

return FormatUtils
