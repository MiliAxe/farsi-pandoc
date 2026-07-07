local variables = {}
function RawBlock(raw)
	if raw.format ~= "org" then
		return nil
	end
	local name, value = raw.text:match("#%+(%w+):%s*(.+)$")
	if name and value then
		variables[string.lower(name)] = value
	end
end

function Meta(meta)
	for name, value in pairs(variables) do
		meta[name] = value
	end
	return meta
end
