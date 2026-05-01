--!strict
--!native
--!optimize 2


export type PetSchema
= {
    petName: string,
    petImageId: string,
    
    GameplayStats
    : {
        maxHealth: number,
        attackDamage: number,
        petHealth: number
    },

    PetStats
    : {
        rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "???" | "Secret",
        size: "Default" | "Huge" | "Gigantic",
        color: "Default" | "Rainbow" | "Radioactive" | "Glitched"
    },

    petOwner: Player?
}


local Data
= {
    RARITIES
    = {
        [1] = "Common",
        [2] = "Uncommon",
        [3] = "Rare",
        [4] = "Epic",
        [5] = "Legendary",
        [6] = "???",
        [7] = "Secret"
    },

    PHYSICAL_ATTRIBUTES
    = {
        SIZES
        = {
            [1] = "Default",
            [2] = "Huge",
            [3] = "Gigantic"
        },

        COLORS
        = {
            [1] = "Default",
            [2] = "Rainbow",
            [3] = "Radioactive",
            [4] = "Glitched"
        }
    },

    ATTRIBUTE_CHANCES
    = {
        SIZE
        = {
            [1] = 100 - (1 / 1_000_000 * 100) - (1 / 10_000_000 * 100),
            [2] = 1 / 1_000_000 * 100,
            [3] = 1 / 10_000_000 * 100
        },

        COLOR
        = {
            [1] = 100 - (1 / 25 * 100) - (1 / 75 * 100) - 1,
            [2] = 1 / 25 * 100,
            [3] = 1 / 75 * 100,
            [4] = 1
        }
    }
}


table.freeze(Data)
return Data