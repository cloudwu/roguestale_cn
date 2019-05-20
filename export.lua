local function readfile(filename)
	local f = assert(io.open(filename))
	local t = f:read "a"
	f:close()
	return t
end

local function export(text)
	local list = {}
	local n = 0
	for tag, content, endtag in text:gmatch '<(%u%a*)>(.-)</(%u%a*)>' do
		assert(tag == endtag)
		for id, value in content:gmatch '<str id="([^"]+)" value="([^"]+)".->' do
			n = n + 1
			list[n] = { tag, id, value }
		end
	end
	return list
end

local function main(filename)
	local t = readfile(filename)
	local list = export(t)
	local e = {}
	local mainkey
	local n = 0
	for _, item in ipairs(list) do
		local tag, id, value = item[1], item[2], item[3]
		local paragraph = id:match "^paragraph (%d+)"
		if paragraph then
			id = mainkey .. "." .. paragraph
		else
			id = '"' .. id .. '"'
			mainkey = id
		end
		n = n + 1
		value = value:gsub("\n", "&#10;")
		e[n] = string.format("%s.%s %s", tag, id, value)
	end
	local f = io.open(filename .. ".txt", "wb")
	f:write((table.concat(e, "\n")))
	f:close()
end

main "English.xml"
