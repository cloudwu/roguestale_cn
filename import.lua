local sha1b = require "sha1"

local function sha1(text)
	return(sha1b(text):gsub(".", function(c) return string.format("%02x", c:byte()) end))
end

local function readfile(filename)
	local f = assert(io.open(filename))
	local t = f:read "a"
	f:close()
	return t
end

local function composing(line)
	local width, content = line:match '^@%((%d+)%)(.*)'
	if not width then
		return line
	end
	width = tonumber(width)
	content = content:gsub('&#10;', '\n')
	local encode = {}
	local n = 0
	for p, c in utf8.codes(content) do
		if n >= width then
			table.insert(encode, 10)
			n = 0
		end
		if c < 0x3000 then
			if c == 10 then
				n = 0
			else
				n = n + 1
			end
		else
			n = n + 2
		end
		table.insert(encode, c)
	end
	local str = utf8.char(table.unpack(encode))
	return str:gsub('\n', '&#10;')
end

local function map(trans)
	local m = {}
	for line in io.lines(trans) do
		-- ignore comments
		if not line:match '^%s*#' then
			local tag, key, value = line:match '(%a+)%.(".-"[^ ]*) (.*)'
			value = composing(value)
			m[tag .. ":" .. key] = value
		end
	end
	return m
end

local function merge(xml, trans)
	local mainkey
	local t = 0
	local s = 0
	local function replace_tag(tag)
		return function (id, value, extra)
			t = t + 1
			local paragraph = id:match "^paragraph (%d+)"
			local key
			if paragraph then
				key = mainkey .. "." .. paragraph
			else
				key = tag .. ':"' .. id .. '"'
				mainkey = key
			end
			local chinese = trans[key]
			if chinese == nil then
				print("Missing:", key)
				chinese = ""
			else
				local escape = value:gsub("\n", "&#10;")
				if chinese == escape then
					chinese = "" .. extra
				else
					s = s + 1
					chinese = string.format(' local="%s"%s', chinese, extra)
				end
				return string.format('<str id="%s" value="%s"%s>', id, value, chinese)
			end
		end
	end

	local function sec_replace(tag, content, endtag)
		assert(tag == endtag)
		local r = content:gsub('<str id="([^"]+)" value="([^"]+)"(.-)>', replace_tag(tag))
		return string.format('<%s>%s</%s>', tag, r, endtag)
	end

	local m = xml:gsub('<(%u%a*)>(.-)</(%u%a*)>', sec_replace)
	print(string.format("Finish %d/%d", s,t))
	return m
end

local function checksum(xml)
	local remove_checksum = xml:gsub("^(.-) checksum=.-(>.*)", "%1%2")
	local escape = remove_checksum:gsub("&#10;","\n")
	local encode = {}
	for p, c in utf8.codes(escape) do
		if c < 127 then
			table.insert(encode, string.char(c))
		else
			table.insert(encode, string.format("&#%d;", c))
		end
	end
	local hash = sha1(table.concat(encode))
	local sign_checksum = xml:gsub('^(.- checksum=")([%da-f]+)', "%1" .. hash)
	return sign_checksum
end

local function main(filename)
	local xml = readfile(filename)
	local trans = map(filename .. ".txt")
	local merged = merge(xml, trans)
	xml = checksum(merged)
	local f = assert(io.open("Chinese.xml", "wb"))
	f:write(xml)
	f:close()
end

main "English.xml"
