--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

local ChatSettings = require(ReplicatedStorage.FrameworkSettings.ChatSettings)

local ChatTagsGroup = require(ReplicatedStorage.Networking.PacketGroups.Services.ChatTags)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type ChatTagSchema = ChatSettings.ChatTagSchema

type HandledChatSchema
= {
    Props: ChatWindowMessageProperties,
    TagsArray: { ChatTagSchema },
    storedPrefixText: string
}
--[[ @end_section Types ]]


--[[ @section Variables ]]
local HandledChatsArray: { HandledChatSchema } = {}

local NAME_COLORS
= {
    Color3.new(253/255, 41/255, 67/255), -- BrickColor.new("Bright red").Color,
    Color3.new(1/255, 162/255, 255/255), -- BrickColor.new("Bright blue").Color,
    Color3.new(2/255, 184/255, 87/255), -- BrickColor.new("Earth green").Color,
    BrickColor.new("Alder").Color,
    BrickColor.new("Bright orange").Color,
    BrickColor.new("Bright yellow").Color,
    BrickColor.new("Light reddish violet").Color,
    BrickColor.new("Brick yellow").Color,
}
--[[ @end_section Variables ]]


--[[ @section Utility Functions ]]
--[[
    @usage Returns the rainbow text of a string.

    @param baseText string
    @param timeOffset number

    @return string
]]
local function returnRainbowText(text: string, textColorOffset: number): string
    local rbText = ""
    local charIndex = 0

    for first: number, last: number in utf8.graphemes(text) do
        charIndex += 1

        local hue = (textColorOffset + (charIndex * 0.15)) % 1
        rbText ..= `<font color="#{Color3.fromHSV(hue, 0.75, 1):ToHex()}">{text:sub(first, last)}</font>`
    end

    return rbText
end

--[[
    @usage Returns the name value of a string.

    @param pName string

    @return number
]]
local function getNameValue(plrName: string): number
	local value = 0

	for index = 1, #plrName do
		local cValue, reverseIndex = string.byte(string.sub(plrName, index, index)), #plrName - index + 1

		if #plrName % 2 == 1 then reverseIndex = reverseIndex - 1 end
		if reverseIndex%4 >= 2 then cValue = -cValue end

		value += cValue
	end

	return value
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return void
]]
local function constructorCallback(): ()
    local chatColorOffset = 255
    local waveTextColorOffset = 0

    RunService.Heartbeat:Connect(
        function(dt: number): ()
            waveTextColorOffset += dt / 2; waveTextColorOffset %= 1

            for i: number, ChatData: HandledChatSchema in ipairs(HandledChatsArray) do
                local prefixText = ""

                for i: number, TagData: ChatTagSchema in ipairs(ChatData.TagsArray) do
                    if TagData.tagColor ~= "rainbow" then
                        if typeof(TagData.tagColor) ~= "Color3" then continue end
                        prefixText ..= `<font color="#{TagData.tagColor:ToHex()}">[{TagData.tagText}]</font> `; continue
                    end
                    
                    if TagData.tagColor == "rainbow" then prefixText ..= `{returnRainbowText(`[{TagData.tagText}]`, waveTextColorOffset)} ` end
                end

                ChatData.Props.PrefixText = `{prefixText}{ChatData.storedPrefixText}`
            end

            TextChatService.ChatWindowConfiguration.TextColor3 = Color3.fromRGB(chatColorOffset, chatColorOffset, chatColorOffset)
            if chatColorOffset == 255 then chatColorOffset = 254 else chatColorOffset = 255 end
        end
    )

    local function onChatMsgAdded(message: TextChatMessage): ChatWindowMessageProperties?
        if not message.TextSource or message.Text == "" then return nil end

        local textSourcePlayer = Players:GetPlayerByUserId(message.TextSource.UserId)
        if not textSourcePlayer then return nil end

        local GamepassTags = {} :: { ChatTagSchema }

        for i: number, TagData: ChatTagSchema in pairs(ChatSettings.GamepassesWithChatTags) do
            if not ChatTagsGroup.CheckIfUserOwnsGamepass:invokeServer(i) then continue end
            table.insert(GamepassTags, TagData)
        end

        local RankTagData = ChatSettings.RanksWithChatTags[textSourcePlayer:GetRankInGroupAsync(game.CreatorId)]
        local IdTagData = ChatSettings.UserIdsWithChatTags[textSourcePlayer.UserId]
        if not RankTagData and not IdTagData and #GamepassTags < 1 then return nil end

        local TagsArray: { ChatTagSchema } = {}

        if RankTagData then table.insert(TagsArray, { tagText = RankTagData.tagText, tagColor = RankTagData.tagColor }) end
        if IdTagData then table.insert(TagsArray, { tagText = IdTagData.tagText, tagColor = IdTagData.tagColor }) end
        if #GamepassTags > 0 then for i: number, TagData: ChatTagSchema in ipairs(GamepassTags) do table.insert(TagsArray, TagData) end end
        
        local newProperties = TextChatService.ChatWindowConfiguration:DeriveNewMessageProperties()
        local msgPrefixText = `<font color="#{NAME_COLORS[(getNameValue(textSourcePlayer.Name) % #NAME_COLORS) + 1]:ToHex()}">{message.PrefixText}</font>`

        -- If the message has no rainbow tags don't add it to the handled chats array.
        do
            local hasWavingTags = false

            for i: number, TagData: ChatTagSchema in ipairs(TagsArray) do
                if TagData.tagColor == "rainbow" then hasWavingTags = true; break end
            end

            if not hasWavingTags then
                local combinedTagTexts = ""

                for i: number, TagData: ChatTagSchema in ipairs(TagsArray) do
                    if not TagData.tagColor or typeof(TagData.tagColor) ~= "Color3" then continue end
                    combinedTagTexts ..= `<font color="#{TagData.tagColor:ToHex()}">[{TagData.tagText}]</font> `
                end

                newProperties.PrefixText = `{combinedTagTexts}{msgPrefixText}`
                return newProperties
            end
        end

        if #HandledChatsArray >= 100 then table.remove(HandledChatsArray, 1) end

        local AddingData: HandledChatSchema
        = {
            Props = newProperties,
            TagsArray = TagsArray,
            storedPrefixText = msgPrefixText
        }

        if table.find(HandledChatsArray, AddingData) then return nil end; table.insert(HandledChatsArray, AddingData)
        return newProperties
    end
    
    TextChatService.OnChatWindowAdded = onChatMsgAdded
end

return constructorCallback
--[[ @end_section Constructor ]]