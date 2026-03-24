--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Store = require(ServerScriptService.Libraries.Store)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)

local Types = require(script.Parent.Parent.Types)
--[[ @end_section Imports ]]


--[[ @section Types ]]
--[[ @generic D Data template type. ]]
type PlayerDataClass<D> = Store.PlayerDataClass<D>

--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.AbstractedStateEngine<T>

type DecompressedDataSchema = Types.DecompressedDataSchema
--[[ @end_section Types ]]


--[[ @section Constructor ]]
local function constructorCallback(DecompressedData: DecompressedDataSchema)
    local reason, targetId = DecompressedData.reason, DecompressedData.targetId
    if not reason or not targetId then return end

    local FoundPlayer = Players:GetPlayerByUserId(targetId)
    if not FoundPlayer then return end

    local PlayerDataClass = Store(targetId)
    if not PlayerDataClass then return end

    (PlayerDataClass() :: { [string]: StateEngine<any> }).banReason = Reactor(reason);
    (PlayerDataClass() :: { [string]: StateEngine<any> }).isBanned(true)
end

return constructorCallback
--[[ @end_section Constructor ]]