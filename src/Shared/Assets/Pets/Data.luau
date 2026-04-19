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

    STAT_CHANCES
    = {
        SIZES
        = {
            Default = 99.99989,
            Huge = 0.0001,
            Gigantic = 0.00001
        },

        COLORS
        = {
            Default = 93,
            Rainbow = 4,
            Radioactive = 2,
            Glitched = 1
        }
    }
}


table.freeze(Data)
return Data