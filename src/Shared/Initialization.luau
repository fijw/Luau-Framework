--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
--[[ @end_section Imports ]]


local isServer = RunService:IsServer()
local runningFrom = if isServer then "Server" else "Client"


--[[
    @usage Attempt to initialize a module until it succeeds.

    @param module any
    @param i string
    @param LoadedModules { [string]: any }

    @return void
]]
local function initializeModule(module: any, i: string, LoadedModules: { [string]: any })
    Chronovisor(
        function()
            local finishedLoading = false

            task.spawn(
                function()
                    pcall(function() module() end)
                                
                    finishedLoading = true
                end
            )

            task.defer(
                function()
                    if not finishedLoading then print(LoadedModules, `Module {i} yielded when initializing, side: {runningFrom}`) end
                end
            )
        end
    )
    :onError(
        function(err: string?)
            print(LoadedModules, `Failed to initialize module, error: {err}, side: {runningFrom}`)

            task.wait(1)

            initializeModule(module, i, LoadedModules)
        end
    )
end


--[[ @section Constructor ]]
--[[
    @usage Initialize modules.

    @param ModulesToLoad { [string]: ModuleScript }

    @return void
]]
local function constructorCallback(ModulesToLoad: { [string]: ModuleScript })
    local LoadedModules: { [string]: any } = {}

    -- Attempt to require all modules and store them in a table.
    Chronovisor(
        function()
            for i: string, module: any in pairs(ModulesToLoad) do
                local RequiredModule = require(module) :: any

                if not RequiredModule then
                    repeat
                        task.wait()
                        RequiredModule = require(module) :: any
                    until RequiredModule
                end

                LoadedModules[i] = RequiredModule
            end
        end
    )
    :onError(function(err: string?) print(ModulesToLoad, `Failed to require module, error: {err}, side: {runningFrom}`) end)

    for i: string, module: any in pairs(LoadedModules) do initializeModule(module, i, LoadedModules) end
end

return constructorCallback
--[[ @end_section Constructor ]]