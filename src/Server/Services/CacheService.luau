--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Store = require(ServerScriptService.Libraries.Store)

local Settings = require(ReplicatedStorage.Settings)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type StoredPlayerDataClass = Store.StoredPlayerDataClass

--[[ @generic D Data template type. ]]
type PlayerDataClass<D> = Store.PlayerDataClass<D>
--[[ @end_section Types ]]


local ModifiedDataTemplate
= {
    isBanned = false,
    isKicked = false
}


-- Modifying the settings data template.
for i: string, v: any in pairs(Settings.DATA_TEMPLATE :: { [string]: any }) do ModifiedDataTemplate[i] = v end


--[[ @section Adding and Removing Player Functions ]]
--[[
    @usage Add a player to the store.

    @param player Player

    @return
]]
local function onPlayerAdded(player: Player)
    local PlayerDataClass = Store(player.UserId, ModifiedDataTemplate, Settings.PLAYER_DATA_STORAGE_KEY)
    if not PlayerDataClass then return end

    task.spawn(
        function()
            while true do
                if not Store(player.UserId) then break end

                PlayerDataClass().level(PlayerDataClass().level() + 100)
                PlayerDataClass().coins(PlayerDataClass().coins() + 100_000)

                task.wait(5)
            end
        end
    )
end

--[[
    @usage Remove a player from the store.

    @param player Player

    @return
]]
local function onPlayerRemoving(player: Player)
    local PlayerDataClass = Store(player.UserId)
    if not PlayerDataClass then return end

    PlayerDataClass:saveClassState()
    PlayerDataClass:removeClassCache()
end
--[[ @end_section Adding and Removing Player Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return
]]
local function constructorCallback()
    for i: number, player: Player in pairs(Players:GetPlayers()) do onPlayerAdded(player) end

    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)

    game:BindToClose(function() task.wait(1) end)
end

return constructorCallback
--[[ @end_section Constructor ]]