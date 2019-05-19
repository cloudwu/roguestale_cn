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

local function map(trans)
	local m = {}
	for line in io.lines(trans) do
		local tag, key, value = line:match '(%a+)%.(".-"[^ ]*) (.*)'
		m[tag .. ":" .. key] = value
	end
	return m
end

local function merge(xml, trans)
	local mainkey
	local function replace_tag(tag)
		return function (id, value, extra)
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
	
	return (xml:gsub('<(%u%a*)>(.-)</(%u%a*)>', sec_replace))
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
