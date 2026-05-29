--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.DataAssets.Pets.Data)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


local UtilsComponent
= {
    COLOR_RARITY_MAP
    = {
        Common = Color3.fromRGB(134, 134, 134),
        Rare = Color3.fromRGB(0, 175, 0),
        Legendary = Color3.fromRGB(154, 0, 201),
        Secret = Color3.fromRGB(0, 81, 173),
        Unobtainable = Color3.fromRGB(172, 0, 0)
    } :: { [string]: Color3 }
}


--[[ @section Color Functions ]]
--[[
    @usage Get radioactive color.

    @param x number

    @return Color3
]]
function UtilsComponent.radioactiveColor(x: number): Color3
    x = x % 1

    if x < 0.25 then
        return Color3.fromRGB(0, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), x / 0.25)
    elseif x < 0.5 then
        return Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(0, 0, 0), (x - 0.25) / 0.25)
    elseif x < 0.75 then
        return Color3.fromRGB(0, 0, 0):Lerp(Color3.fromRGB(255, 255, 0), (x - 0.5) / 0.25)
    else
        return Color3.fromRGB(255, 255, 0):Lerp(Color3.fromRGB(0, 0, 0), (x - 0.75) / 0.25)
    end
end

--[[
    @usage Get glitched color.

    @param x number

    @return Color3
]]
function UtilsComponent.glitchedColor(x: number): Color3
    return Color3.fromRGB(0, 0, 0):Lerp(Color3.fromRGB(128, 0, 255), math.sin(x * math.pi * 2) * 0.5 + 0.5)
end
--[[ @end_section Color Functions ]]


--[[ @section Utility Functions ]]
--[[
    @usage Creates a tick for a pet.

    @param petLabel ImageLabel
    @param type "lock" | "delete" | "selected"

    @return void
]]
function UtilsComponent.createTick(petLabel: ImageLabel, type: "lock" | "delete" | "selected"): ()
    local newTick = Instance.new("ImageLabel")
    newTick.Image = if type == "lock" then "rbxassetid://138368172974659" elseif type == "selected" then "rbxassetid://120401071933338" else "rbxassetid://138335893507994"
    newTick.BackgroundTransparency = 1
    newTick.BorderSizePixel = 0
    newTick.Position = if type == "lock" or type == "delete" then UDim2.new(0, 0, 0, 0) else UDim2.new(0.65, 0, 0, 0)
    newTick.Size = UDim2.new(0.35, 0, 0.35, 0)
    newTick.Name = if type == "lock" then "LockTick" elseif type == "selected" then "SelectTick" else "DeleteTick"
    newTick.ZIndex = 3
    newTick.Parent = petLabel
end

--[[
    @usage Expand items.

    @param inst ImageLabel
    @param ExpandingNums { [string]: number }
    @param expanding boolean
    @param PetCache { [string]: PetSchema }

    @return void
]]
function UtilsComponent.expandItems(inst: ImageLabel, ExpandingNums: { [string]: number }, expanding: boolean, PetCache: { [string]: PetSchema }): ()
    if inst.Name == "Gigantic" then
        if not expanding then
            inst.Size = UDim2.fromScale(inst.Size.X.Scale * ExpandingNums.gigantic, inst.Size.Y.Scale * ExpandingNums.gigantic)
            return
        end

        inst.Size = UDim2.fromScale(inst.Size.X.Scale / ExpandingNums.gigantic, inst.Size.Y.Scale / ExpandingNums.gigantic)
        return
    elseif inst.Name == "Huge" then
        if not expanding then
            inst.Size = UDim2.fromScale(inst.Size.X.Scale * ExpandingNums.huge, inst.Size.Y.Scale * ExpandingNums.huge)
            return
        end

        inst.Size = UDim2.fromScale(inst.Size.X.Scale / ExpandingNums.huge, inst.Size.Y.Scale / ExpandingNums.huge)
        return
    elseif inst.Name == "Default" then
        if not expanding then
            inst.Size = UDim2.fromScale(inst.Size.X.Scale * ExpandingNums.default, inst.Size.Y.Scale * ExpandingNums.default)
            return
        end

        inst.Size = UDim2.fromScale(inst.Size.X.Scale / ExpandingNums.default, inst.Size.Y.Scale / ExpandingNums.default)
        return
    end

    local InstPetData = PetCache[inst.Name]
    if not InstPetData then return end

    if InstPetData.PetStats.size == "Gigantic" then
        if not expanding then
            inst.Size = UDim2.fromScale(inst.Size.X.Scale * ExpandingNums.gigantic, inst.Size.Y.Scale * ExpandingNums.gigantic)
            return
        end

        inst.Size = UDim2.fromScale(inst.Size.X.Scale / ExpandingNums.gigantic, inst.Size.Y.Scale / ExpandingNums.gigantic)
    elseif InstPetData.PetStats.size == "Huge" then
        if not expanding then
            inst.Size = UDim2.fromScale(inst.Size.X.Scale * ExpandingNums.huge, inst.Size.Y.Scale * ExpandingNums.huge)
            return
        end

        inst.Size = UDim2.fromScale(inst.Size.X.Scale / ExpandingNums.huge, inst.Size.Y.Scale / ExpandingNums.huge)
    else
        if not expanding then
            inst.Size = UDim2.fromScale(inst.Size.X.Scale * ExpandingNums.default, inst.Size.Y.Scale * ExpandingNums.default)
            return
        end

        inst.Size = UDim2.fromScale(inst.Size.X.Scale / ExpandingNums.default, inst.Size.Y.Scale / ExpandingNums.default)
    end
end
--[[ @end_section Utility Functions ]]


table.freeze(UtilsComponent)
return UtilsComponent