--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)

local CmdsSettings = require(ReplicatedStorage.Settings.CmdsSettings)
--[[ @end_section Imports ]]


type SavingInventoryClassSchema = Stackentory.SavingInventoryClassSchema


local LoggedJoinedPlrs: { Player } = {}


--[[ @section Constructor ]]
--[[
    @usage Handles player cache upon joining and leaving.
    
    @return void
]]
local function constructorCallback()
    local function onPlayerAdded(player: Player)
        table.insert(LoggedJoinedPlrs, player)

        local PlrDataClass = Registry(player, true)
        if not PlrDataClass then return end

        -- Initialize the player's inventory.
        PlrDataClass()().Inventory = Stackentory(if PlrDataClass()().Inventory then PlrDataClass()().Inventory() else nil)

        print(PlrDataClass()(), `{player.UserId}'s data.`)

        -- Make the coins divisible using a custom callback.
        do
            PlrDataClass()().coins:addOperator(
                "__div",
                
                function(self, data)
                    print(data, "__div callback")
                    return self
                end
            )

            PlrDataClass()().coins /= 5
        end

        task.spawn(
            function()
                while true do
                    if not Players:GetPlayerByUserId(player.UserId) then break end

                    local oldCoins = PlrDataClass()().coins()
                    PlrDataClass()().coins(oldCoins + 100_000)

                    task.wait(5)
                end
            end
        )

        if #LoggedJoinedPlrs > 1 and #LoggedJoinedPlrs < 3 or #LoggedJoinedPlrs == 2 then
            local txPlr1, txPlr2 = LoggedJoinedPlrs[1], LoggedJoinedPlrs[2]
            if not txPlr1 or not txPlr2 then return end

            Registry.atomicTransaction(LoggedJoinedPlrs,
                function(PlayerStates)
                    local oldPlr1Coins = PlayerStates[txPlr1].coins()
                    local oldPlr2Coins = PlayerStates[txPlr2].coins()
                    if oldPlr1Coins < 100_000 then print("not enough coins from plr1"); return false end

                    PlayerStates[txPlr1].coins(oldPlr1Coins - 100_000)
                    PlayerStates[txPlr2].coins(oldPlr2Coins + 100_000)

                    local changedPlr1Coins = PlayerStates[txPlr1].coins()
                    local changedPlr2Coins = PlayerStates[txPlr2].coins()

                    if changedPlr1Coins ~= oldPlr1Coins - 100_000 or changedPlr2Coins ~= oldPlr2Coins + 100_000 then
                        print("transfer didn't work correctly, data doesn't match expected values")
                        return false
                    end

                    print(`Gave {txPlr2.UserId} 100_000 coins from {txPlr1.UserId}.`)

                    return true
                end
            )
        end
    end

    local function onPlayerRemoving(player: Player)
        local IndexedJoinedPlr = table.find(LoggedJoinedPlrs, player)
        if IndexedJoinedPlr then table.remove(LoggedJoinedPlrs, IndexedJoinedPlr) end

        local PlrDataClass = Registry(player)
        if not PlrDataClass then return end

        PlrDataClass:saveClass()
        PlrDataClass:deleteClass()

        if not CmdsSettings.ServerUsersGivenFunCommands[player.UserId] then return end
        CmdsSettings.ServerUsersGivenFunCommands[player.UserId] = nil
    end

    -- Handle player joining and leaving connections.
    do
        for i: number, player: Player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end

        Players.PlayerAdded:Connect(onPlayerAdded)
        Players.PlayerRemoving:Connect(onPlayerRemoving)
    end
end

return constructorCallback
--[[ @end_section Constructor ]]