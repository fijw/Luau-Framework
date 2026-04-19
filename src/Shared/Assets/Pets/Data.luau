--!strict
--!native
--!optimize 2


export type PetSchema
= {
    name: string,

    rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "???" | "Secret",
    size: "Default" | "Huge" | "Gigantic",
    color: "Default" | "Rainbow" | "Radioactive" | "Glitched",

    stats
    : {
        health: number,
        attack: number
    }
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
            [1] = 99.99989,
            [2] = 0.0001,
            [3] = 0.00001
        },

        COLOR
        = {
            [1] = 93.95,
            [2] = 4,
            [3] = 1.25,
            [4] = 0.8
        }
    }
}


table.freeze(Data)
return Data