local list = {
"mainQuestPhase1.xml",
"mainQuestPhase2.xml",
"mainQuestPhase3.xml",
"mainQuestVerdict.xml",
"sideQuestArtificer.xml",
"sideQuestDreadLord.xml",
"sideQuestEvilGenie.xml",
"sideQuestExitPrompt.xml",
}

local function convert(name)
	local fn = "dialogues/Chinese/" .. name
	local f = assert(io.open(fn, "rb"))
	local text = f:read "a"
	f:close()
	text = text:gsub("&#(%d%d%d%d%d?);", function (code)
		code = tonumber(code)
		return utf8.char(code)
	end)
	f = assert(io.open(fn, "wb"))
	f:write(text)
	f:close()
end

for _, name in ipairs(list) do
	print(name)
	convert(name)
end
