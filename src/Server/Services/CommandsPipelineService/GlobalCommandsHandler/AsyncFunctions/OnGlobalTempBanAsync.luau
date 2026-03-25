--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local DataLib = require(ServerScriptService.Libraries.DataLib)

local Types = require(script.Parent.Parent.Types)
--[[ @end_section Imports ]]


type DataClass = DataLib.DataClass
type DecompressedDataSchema = Types.DecompressedDataSchema


--[[ @section Constructor ]]
local function constructorCallback(DecompressedData: DecompressedDataSchema)
    local reason, targetId, duration = DecompressedData.reason, DecompressedData.targetId, DecompressedData.duration
    if not reason or not targetId or not duration then return end

    local FoundPlayer = Players:GetPlayerByUserId(targetId)
    if not FoundPlayer then return end

    local PlayerDataClass = DataLib(FoundPlayer)
    if not PlayerDataClass then return end

    PlayerDataClass().ModerationData(false, "permanent", "BanData")
    PlayerDataClass().ModerationData(reason, "banReason", "BanData")
    PlayerDataClass().ModerationData(true, "isBanned", "BanData")
    PlayerDataClass().ModerationData(duration, "banDuration", "BanData")
end

return constructorCallback
--[[ @end_section Constructor ]]