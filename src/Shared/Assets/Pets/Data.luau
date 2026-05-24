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
        rarity: "Common" | "Rare" | "Legendary" | "Secret" | "Unobtainable",
        size: "Default" | "Huge" | "Gigantic" | "Worldbreaker",
        color: "Default" | "Rainbow" | "Radioactive" | "Glitched" | "broken_mix"
    },
    
    Locked: { string }?,
    Equipped: { string }?
}


local Data
= {
    PHYSICAL_ATTRIBUTES
    = {
        SIZES
        = {
            [1] = "Default",
            [2] = "Huge",
            [3] = "Gigantic",
            [4] = "Worldbreaker"
        },

        COLORS
        = {
            [1] = "Default",
            [2] = "Rainbow",
            [3] = "Radioactive",
            [4] = "Glitched",
            [5] = "broken_mix"
        }
    },

    ATTRIBUTE_CHANCES
    = {
        SIZE
        = {
            [1] = 100 - (1 / 50_000_000 * 100) - (1 / 250_000_000 * 100) - (1 / 1_000_000_000_000_000 * 100),
            [2] = 1 / 50_000_000 * 100,
            [3] = 1 / 250_000_000 * 100,
            [4] = 1 / 1_000_000_000_000_000 * 100
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