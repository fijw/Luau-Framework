--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
--[[ @end_section Imports ]]


local runningFrom = if RunService:IsServer() then "Server" else "Client"
local maxRetryAttempts = 5


--[[
    @usage Attempt to initialize a module until it succeeds.

    @param module any
    @param i string
    @param LoadedModules { [string]: any }

    @return void
]]
local function initializeModule(module: any, i: string, LoadedModules: { [string]: any }): "success" | "failure"
    local returningStatus = "success"
    local attempts = 0

    -- Attempt to initialize the module inputted until it succeeds or exceeds the maximum amount of attempts.
    Chronovisor(
        function(): ()
            local finishedLoading = false

            task.spawn(
                function(): ()
                    pcall(function(): () module() end)
                    finishedLoading = true
                end
            )

            task.defer(
                function(): ()
                    if not finishedLoading then print(`[-] [Framework] Module {i} yielded when initializing, side: {runningFrom}`) end
                end
            )
        end
    )
    :onError(
        function(err: string?): ()
            if attempts > maxRetryAttempts then returningStatus = "failure"; return else attempts += 1; task.wait(1) end

            print(`[!] [Framework] Failed to initialize module {i}, attempt {attempts} out of {maxRetryAttempts}, error: {err}, side: {runningFrom}`)
            initializeModule(module, i, LoadedModules)
        end
    )

    return returningStatus
end


--[[ @section Constructor ]]
--[[
    @usage Initialize modules.

    @param ModulesToLoad { [string]: ModuleScript }

    @return void
]]
local function constructorCallback(ModulesToLoad: { [string]: ModuleScript }): "success" | "failure"
    local RequiredModules: { [string]: any } = {}
    local LoadedModules: { [string]: any } = {}

    local lastRequiredModuleIndex: any

    -- Attempt to require all modules and store them in a table.
    Chronovisor(
        function(): ()
            for i: string, module: any in pairs(ModulesToLoad) do
                local RequiredModule = require(module) :: any; lastRequiredModuleIndex = i

                if not RequiredModule then
                    local attempts = 0

                    repeat
                        attempts += 1
                        RequiredModule = require(module) :: any

                        task.wait()
                    until RequiredModule or attempts > maxRetryAttempts
                end

                RequiredModules[i] = RequiredModule
            end
        end
    )
    :onError(function(err: string?): () print(`[!] [Framework] Failed to require module {lastRequiredModuleIndex}, error: {err}, side: {runningFrom}`) end)

    local requiredCount = 0
    local loadedCount = 0

    -- Attempt to initialize all modules.
    for i: string, module: any in pairs(RequiredModules) do
        if initializeModule(module, i, RequiredModules) == "success" then LoadedModules[i] = module; loadedCount += 1 end
        requiredCount += 1
    end

    if loadedCount >= requiredCount then
        print(`[*] [Framework] Successfully initialized all {loadedCount} modules, side: {runningFrom}`)
        return "success"
    else
        print(`[!] [Framework] Failed to initialize all modules, only initialized {loadedCount} out of {requiredCount}, side: {runningFrom}`)
        return "failure"
    end
end

return constructorCallback
--[[ @end_section Constructor ]]