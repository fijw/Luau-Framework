--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Data = require(ReplicatedStorage.DataAssets.Pets.Data)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


local ENUM_LIST
= {
    Enum.NormalId.Top,
    Enum.NormalId.Bottom,
    Enum.NormalId.Left,
    Enum.NormalId.Right,
    Enum.NormalId.Front,
    Enum.NormalId.Back
}


--[[
    @usage Interpolate between colors.

    @param t number

    @return Color3
]]
local function glitchedColor(t: number): Color3
	if t < 0.5 then
		return Color3.new(0, 0, 0):Lerp(Color3.fromRGB(170, 0, 255), t / 0.5)
	else
		return Color3.fromRGB(170, 0, 255):Lerp(Color3.new(0, 0, 0), (t - 0.5) / 0.5)
	end
end


--[[ @section Constructor Function ]]
--[[
    @usage Add pet to the game world.
    
    @param CachedFieldPets { [string]: { petModel: Model, field: BasePart } }
    @param EquippedPetsCache { [string]: Model }
    @param GamePetsFolder Folder
    @param AssetsPetsFolder Folder
    @param EquippingData { PetData: PetSchema, petId: string }
    @param spawnPoint BasePart
    @param field BasePart?

    @return void
]]
local function addPetToWorkspace
(
    CachedFieldPets: { [string]: { petModel: Model, field: BasePart } },
    EquippedPetsCache: { [string]: Model },
    GamePetsFolder: Folder,
    AssetsPetsFolder: Folder,
    EquippingData: { PetData: PetSchema, petId: string },
    spawnPoint: BasePart,
    field: BasePart?
)
    if field then if CachedFieldPets[EquippingData.petId] then return end
    else if EquippedPetsCache[EquippingData.petId] then return end end

    local petModel = AssetsPetsFolder:WaitForChild(EquippingData.PetData.petName) :: Model
    if not petModel.PrimaryPart then repeat task.wait() until petModel.PrimaryPart end
    
    local clonedPetModel = petModel:Clone()
    clonedPetModel.Name = EquippingData.petId
    clonedPetModel.Parent = GamePetsFolder

    if field then CachedFieldPets[EquippingData.petId] = { petModel = clonedPetModel, field = field }
    else EquippedPetsCache[EquippingData.petId] = clonedPetModel end
    
    local petRootPart = clonedPetModel.PrimaryPart :: MeshPart
    petRootPart.CanCollide = false
    petRootPart.Anchored = true
    petRootPart.CastShadow = false

    if EquippingData.PetData.PetStats.size == "Worldbreaker" then
        clonedPetModel:ScaleTo(16)
    elseif EquippingData.PetData.PetStats.size == "Gigantic" then
        clonedPetModel:ScaleTo(8)
    elseif EquippingData.PetData.PetStats.size == "Huge" then
        clonedPetModel:ScaleTo(4)
    end

    if EquippingData.PetData.PetStats.color == "Diamond" then
        local petHighlight = Instance.new("Highlight")
        petHighlight.Parent = petRootPart
        petHighlight.OutlineTransparency = 1
        petHighlight.FillTransparency = 0.4
        petHighlight.FillColor = Color3.fromRGB(0, 225, 255)
        petHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
    elseif EquippingData.PetData.PetStats.color == "Gold" then
        local petHighlight = Instance.new("Highlight")
        petHighlight.Parent = petRootPart
        petHighlight.OutlineTransparency = 1
        petHighlight.FillTransparency = 0.4
        petHighlight.FillColor = Color3.fromRGB(255, 208, 0)
        petHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
    end

    -- Handle ra/gl textures and the rb/gl/ra colors.
    do
        local Textures: { Texture } = {}
        local petHighlight: Highlight?

        if EquippingData.PetData.PetStats.color == "Glitched" or EquippingData.PetData.PetStats.color == "Rainbow" then
            petHighlight = Instance.new("Highlight")
            petHighlight.Parent = petRootPart
            petHighlight.OutlineTransparency = 1
            petHighlight.FillTransparency = 0.4
            petHighlight.DepthMode = Enum.HighlightDepthMode.Occluded

            for i = 1, 6 do
                local newTexture = Instance.new("Texture")
                newTexture.Texture = "rbxasset://textures/water/normal_21.dds"
                newTexture.Color3 = Color3.fromRGB(0, 0, 0)
                newTexture.Parent = petRootPart
                newTexture.Face = ENUM_LIST[i]

                if EquippingData.PetData.PetStats.size == "Worldbreaker" then
                    newTexture.StudsPerTileU *= 16; newTexture.StudsPerTileV *= 16
                elseif EquippingData.PetData.PetStats.size == "Gigantic" then
                    newTexture.StudsPerTileU *= 8; newTexture.StudsPerTileV *= 8
                elseif EquippingData.PetData.PetStats.size == "Huge" then
                    newTexture.StudsPerTileU *= 4; newTexture.StudsPerTileV *= 4
                end

                table.insert(Textures, newTexture)
            end
        end

        if EquippingData.PetData.PetStats.color == "Glitched" or EquippingData.PetData.PetStats.color == "Rainbow" then
            local textureOffset = 0
            local colorOffset = 0

            local whileEquippedConnection: RBXScriptConnection

            whileEquippedConnection = RunService.Heartbeat:Connect(
                function(deltaTime: number)
                    if not EquippedPetsCache[EquippingData.petId] then whileEquippedConnection:Disconnect(); return end

                    if EquippingData.PetData.PetStats.size == "Worldbreaker" then textureOffset += deltaTime * 16
                    elseif EquippingData.PetData.PetStats.size == "Gigantic" then textureOffset += deltaTime * 8
                    elseif EquippingData.PetData.PetStats.size == "Huge" then textureOffset += deltaTime * 4
                    else textureOffset += deltaTime end
                    
                    colorOffset += deltaTime * 0.15; colorOffset %= 1

                    if EquippingData.PetData.PetStats.size == "Worldbreaker" then textureOffset %= 2 * 16
                    elseif EquippingData.PetData.PetStats.size == "Gigantic" then textureOffset %= 2 * 8
                    elseif EquippingData.PetData.PetStats.size == "Huge" then textureOffset %= 2 * 4
                    else textureOffset %= 2 end

                    if EquippingData.PetData.PetStats.color == "Glitched" then
                        for i: number, texture: Texture in pairs(Textures) do texture.OffsetStudsU = textureOffset; texture.OffsetStudsV = textureOffset end
                        if petHighlight then petHighlight.FillColor = glitchedColor(colorOffset) end
                    elseif EquippingData.PetData.PetStats.color == "Rainbow" then
                        for i: number, texture: Texture in pairs(Textures) do texture.OffsetStudsU = textureOffset; texture.OffsetStudsV = textureOffset end
                        if petHighlight then petHighlight.FillColor = Color3.fromHSV(colorOffset, 0.75, 1) end
                    end
                end
            )
        end
    end

    petRootPart.Position = spawnPoint.Position
end

return addPetToWorkspace
--[[ @end_section Constructor Function ]]