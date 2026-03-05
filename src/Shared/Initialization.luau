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
    @usage Initialize a module.

    @param module any
    @param i number
    @param LoadedModules { any }

    @return void
]]
local function initializeModule(module: any, i: number, LoadedModules: { any })
    Chronovisor(
        function()
            local finishedLoading = false

            task.spawn(
                function()
                    pcall(function() module() end)
                                
                    finishedLoading = true
                end
            )

            task.defer(function()
                if not finishedLoading then print(LoadedModules, `Module {i} yielded when initializing, side: {runningFrom}`) end
            end)
        end
    )
    :onError(function(err: string?)
        print(LoadedModules, `Failed to initialize module, error: {err}, side: {runningFrom}`)

        task.wait(1)

        initializeModule(module, i, LoadedModules)
    end)
end


--[[ @section Constructor ]]
--[[
    @usage Initialize modules.

    @param ModulesToLoad { ModuleScript }

    @return boolean
]]
local function constructorCallback(ModulesToLoad: { ModuleScript }): boolean
    local LoadedModules: { any } = {}

    Chronovisor(
        function()
            for i: number, module: any in ipairs(ModulesToLoad) do
                local RequiredModule = require(module) :: any

                if not RequiredModule then
                    repeat
                        task.wait()
                        RequiredModule = require(module) :: any
                    until RequiredModule
                end

                table.insert(LoadedModules, RequiredModule)
            end
        end
    )
    :onError(function(err: string?) print(ModulesToLoad, `Failed to require module, error: {err}, side: {runningFrom}`) end)

    for i: number, module: any in ipairs(LoadedModules) do initializeModule(module, i, LoadedModules) end

    return true
end

return constructorCallback
--[[ @end_section Constructor ]]