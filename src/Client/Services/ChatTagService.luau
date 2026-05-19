--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

local ChatSettings = require(ReplicatedStorage.FrameworkSettings.ChatSettings)
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


local HandledChatsArray: { HandledChatSchema } = {}


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
    @usage Returns the purple and blue wave text of a string.

    @param baseText string
    @param timeOffset number

    @return string
]]
local function returnPurpleAndBlueWaveText(text: string, textColorOffset: number): string
    local result = ""
    local charIndex = 0
    local color1 = Color3.fromRGB(170, 0, 255)
    local color2 = Color3.fromRGB(0, 110, 255)

    for first: number, last: number in utf8.graphemes(text) do
        charIndex += 1

        local wave = math.sin(textColorOffset * (#text + 1) + (charIndex * 1))
        local t = (wave + 1) / 2

        result ..= `<font color="#{color1:Lerp(color2, t):ToHex()}">{text:sub(first, last)}</font>`
    end

    return result
end

--[[
    @usage Returns the gold and pink wave text of a string.

    @param baseText string
    @param timeOffset number

    @return string
]]
local function returnGoldAndPinkWaveText(text: string, textColorOffset: number): string
    local result = ""
    local charIndex = 0
    local color1 = Color3.fromRGB(255, 255, 0)
    local color2 = Color3.fromRGB(255, 0, 255)

    for first: number, last: number in utf8.graphemes(text) do
        charIndex += 1

        local wave = math.sin(textColorOffset * (#text + 1) + (charIndex * 1))
        local t = (wave + 1) / 2

        result ..= `<font color="#{color1:Lerp(color2, t):ToHex()}">{text:sub(first, last)}</font>`
    end

    return result
end


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return void
]]
local function constructorCallback()
    local chatColorOffset = 255
    local dualColorTextColorOffset = 0
    local singleWaveTextColorOffset = 0

    RunService.Heartbeat:Connect(
        function(dt: number)
            dualColorTextColorOffset += dt / 2.5; dualColorTextColorOffset %= 1
            singleWaveTextColorOffset += dt / 2; singleWaveTextColorOffset %= 1

            for i: number, ChatData: HandledChatSchema in ipairs(HandledChatsArray) do
                local prefixText = ""

                for i: number, TagData: ChatTagSchema in ipairs(ChatData.TagsArray) do
                    if TagData.tagColor ~= "rainbow" and TagData.tagColor ~= "gold_and_pink" and TagData.tagColor ~= "purple_and_blue" then
                        if typeof(TagData.tagColor) ~= "Color3" then continue end
                        prefixText ..= `<font color="#{TagData.tagColor:ToHex()}">[{TagData.tagText}]</font> `; continue
                    end
                    
                    if TagData.tagColor == "rainbow" then
                        prefixText ..= `{returnRainbowText(`[{TagData.tagText}]`, singleWaveTextColorOffset)} `
                    elseif TagData.tagColor == "purple_and_blue" then
                        prefixText ..= `{returnPurpleAndBlueWaveText(`[{TagData.tagText}]`, dualColorTextColorOffset)} `
                    elseif TagData.tagColor == "gold_and_pink" then
                        prefixText ..= `{returnGoldAndPinkWaveText(`[{TagData.tagText}]`, dualColorTextColorOffset)} `
                    end
                end

                ChatData.Props.PrefixText = `{prefixText}{ChatData.storedPrefixText}`
            end

            TextChatService.ChatWindowConfiguration.TextColor3 = Color3.fromRGB(chatColorOffset, chatColorOffset, chatColorOffset)
            if chatColorOffset == 255 then chatColorOffset = 254 else chatColorOffset = 255 end
        end
    )
    
    TextChatService.OnChatWindowAdded
    = function(message: TextChatMessage): ChatWindowMessageProperties?
        if not message.TextSource then return nil end

        local textSourcePlayer = Players:GetPlayerByUserId(message.TextSource.UserId)
        if not textSourcePlayer then return nil end

        local GamepassTags = {} :: { ChatTagSchema }

        for i: number, TagData: ChatTagSchema in pairs(ChatSettings.GamepassesWithChatTags) do
            if not MarketplaceService:UserOwnsGamePassAsync(textSourcePlayer.UserId, i) then continue end
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

        -- If the message has no rainbow tags don't add it to the handled chats array.
        do
            local hasWavingTags = false

            for i: number, TagData: ChatTagSchema in ipairs(TagsArray) do
                if TagData.tagColor == "rainbow" or TagData.tagColor == "gold_and_pink" or TagData.tagColor == "purple_and_blue" then
                    hasWavingTags = true; break
                end
            end

            if not hasWavingTags then
                local prefixText = ""

                for i: number, TagData: ChatTagSchema in ipairs(TagsArray) do
                    if not TagData.tagColor or typeof(TagData.tagColor) ~= "Color3" then continue end
                    prefixText ..= `<font color="#{TagData.tagColor:ToHex()}">[{TagData.tagText}]</font> `
                end

                newProperties.PrefixText = `{prefixText}{message.PrefixText}`
                return newProperties
            end
        end

        table.insert(HandledChatsArray,
            {
                Props = newProperties,
                TagsArray = TagsArray,
                storedPrefixText = message.PrefixText
            }
        )

        return newProperties
    end
end

return constructorCallback
--[[ @end_section Constructor ]]