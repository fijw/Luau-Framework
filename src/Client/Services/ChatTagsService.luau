--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local ChatWindowConfiguration = TextChatService.ChatWindowConfiguration

local Settings = require(ReplicatedStorage.Settings)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type RainbowMessageSchema
= {
    MessageProperties: ChatWindowMessageProperties,

    rawPrefixText: string,
    rawTagText: string,
    rawMessageText: string
}

type ChatTagSchema = Settings.ChatTagSchema
--[[ @end_section Types ]]


--[[ @section Variables ]]
local EFFECT_SPEED = 0.25
local COLOR_SPREAD = 0.75 -- 1 = 1 char?, 0.75 = 1.25 chars?, 0.5 = 2 chars?, 0.25 = 4 chars


local USERNAME_COLORS
= {
	Color3.new(253 / 255, 41 / 255, 67 / 255),
	Color3.new(1 / 255, 162 / 255, 255 / 255),
	Color3.new(2 / 255, 184 / 255, 87 / 255),
	
	BrickColor.new("Bright violet").Color,
	BrickColor.new("Bright orange").Color,
	BrickColor.new("Bright yellow").Color,
	BrickColor.new("Light reddish violet").Color,
	BrickColor.new("Brick yellow").Color
}


local RainbowMessages: { RainbowMessageSchema } = {}

local accumulatedTime = 0
--[[ @end_section Variables ]]


--[[ @section Text & Name Functions ]]
--[[
    @usage Returns the name value of a string.

    @param name string
    
    @return number
]]
local function GetNameValue(name: string): number
	local value = 0

	for i = 1, #name do
		local reverseIndex = #name - i + 1
		local cValue = string.byte(string.sub(name, i, i))

		if #name%2 == 1 then reverseIndex -= 1
		elseif reverseIndex%4 >= 2 then cValue = -cValue end

		value += cValue
	end

	return value
end

--[[
    @usage Returns the rainbow text of a string.

    @param baseText string
    @param timeOffset number

    @return string
]]
local function generateRainbowText(baseText: string, timeOffset: number): string
	local result = ""
	local index = 0

	for i: number, codepoint: number in utf8.codes(baseText) do
		index += 1

		local char = utf8.char(codepoint)

		local waveOffset = (timeOffset - index * COLOR_SPREAD * EFFECT_SPEED) % 1
		local color = Color3.fromHSV(waveOffset, 0.65, 1)

		local r, g, b = math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5)

		result ..= `<font color="rgb({r},{g},{b})">{char}</font>`
	end

	return result
end
--[[ @end_section Text & Name Functions ]]


--[[ @section Utility Functions ]]
--[[
    @usage Handles every render step.

    @param deltaTime number

    @return void
]]
local function onRenderStepped(deltaTime: number)
	accumulatedTime += deltaTime
	
	for i: number, Message: RainbowMessageSchema in RainbowMessages do
		if not Message.MessageProperties or not Message.rawPrefixText then return end
		
		local rainbowTag = generateRainbowText(`{Message.rawTagText}`, (accumulatedTime * EFFECT_SPEED) % 1)
		Message.MessageProperties.PrefixText = `{rainbowTag} {Message.rawPrefixText}`
	end
	
	local flickerColor = Color3.new((math.floor(accumulatedTime * 60) % 2 == 0) and 1 or 254/255, 1, 1)
	ChatWindowConfiguration.TextColor3 = flickerColor
end

--[[
    @usage Handles when a message is sent.

    @param message TextChatMessage

    @return ChatWindowMessageProperties?
]]
local function onChatSent(message: TextChatMessage): ChatWindowMessageProperties?
    if not message.TextSource then return nil end

	-- Prevent memory leaking.
	if #RainbowMessages >= 200 then table.remove(RainbowMessages, 1) end

	local textSourcePlayer = Players:GetPlayerByUserId(message.TextSource.UserId)
	if not textSourcePlayer then return nil end

	local textSourcePlayerRank = textSourcePlayer:GetRankInGroupAsync(game.CreatorId)
	
	local IdTagData = Settings.ChatSettings.ChatTagSettings.UserIdsWithChatTags[textSourcePlayer.UserId]
	local RankTagData = Settings.ChatSettings.ChatTagSettings.RanksWithChatTags[textSourcePlayerRank]

	local GamepassTags = {} :: { ChatTagSchema }

	for i: number, TagData: ChatTagSchema in pairs(Settings.ChatSettings.ChatTagSettings.GamepassesWithChatTags) do
		if not MarketplaceService:UserOwnsGamePassAsync(textSourcePlayer.UserId, i) then continue end

		table.insert(GamepassTags, TagData)
	end

	local textSourceTag = ""

	local RainbowTagsPresent = {} :: { string }

	-- Generate the tag text.
	do
		if IdTagData then
			if not IdTagData.isRainbow then
				local tagColor = (IdTagData.tagColor or Color3.fromRGB(255, 0, 0)):ToHex()
				textSourceTag = `<font color="#{tagColor}">[{IdTagData.tagText}]</font>`
			else table.insert(RainbowTagsPresent, IdTagData.tagText) end
		end

		if RankTagData then
			local rankTagText: string

			if not IdTagData then
				rankTagText = `[{RankTagData.tagText}]`
			else
				rankTagText = ` [{RankTagData.tagText}]`
			end

			if not RankTagData.isRainbow then
				local tagColor = (RankTagData.tagColor or Color3.fromRGB(255, 0, 0)):ToHex()
				textSourceTag = `<font color="#{tagColor}">{rankTagText}</font>`
			else table.insert(RainbowTagsPresent, RankTagData.tagText) end
		end

		local gamepassTagCount = 0

		for i: number, TagData: ChatTagSchema in ipairs(GamepassTags) do
			gamepassTagCount += 1

			local gamepassTagText: string

			if IdTagData or RankTagData or gamepassTagCount >= 1 then
				gamepassTagText = ` [{TagData.tagText}]`
			else
				gamepassTagText = `[{TagData.tagText}]`
			end

			if not TagData.isRainbow then
				local tagColor = (TagData.tagColor or Color3.fromRGB(255, 0, 0)):ToHex()
				textSourceTag ..= `<font color="#{tagColor}">{gamepassTagText}</font>`
			else table.insert(RainbowTagsPresent, TagData.tagText :: string) end
		end
	end

	-- Generate the message properties.
	do
		local properties = ChatWindowConfiguration:DeriveNewMessageProperties()
		if not properties then return nil end

		local nameColor = USERNAME_COLORS[(GetNameValue(message.TextSource.Name) % #USERNAME_COLORS) + 1]
		local hexNameColor = nameColor:ToHex()

		if RainbowTagsPresent then
			local combinedTagText = ""

			for i: number, tagText: string in ipairs(RainbowTagsPresent) do
				if i > 1 then combinedTagText ..= ` [{tagText}]` else combinedTagText ..= `[{tagText}]` end
			end

			table.insert(RainbowMessages,
				{
					MessageProperties = properties,

					rawPrefixText = `<font color="#{hexNameColor}">{textSourceTag} {message.PrefixText}</font>`,
					rawTagText = combinedTagText,
					rawMessageText = message.Text
				} :: RainbowMessageSchema
			)
		else properties.PrefixText = `{textSourceTag} <font color="#{hexNameColor}">{message.PrefixText}</font>` end

		return properties
	end
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
--[[
	@usage Initialize the service.

	@return void
]]
local function constructorCallback()
    TextChatService.OnChatWindowAdded = onChatSent
    local _renderSteppedConnection = RunService.RenderStepped:Connect(onRenderStepped)
end

return constructorCallback
--[[ @end_section Constructor ]]