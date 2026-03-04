--!strict
--!native
--!optimize 2


local Settings
= {
    DATA_TEMPLATE
    = {
        Inventory
        = {
            Pets
            = {
                Cat = 25,
                Dog = 3,
                Rabbit = 1
            },

            Items
            = {
                Sword = 1,
                Shield = 1,
                Bow = 1
            }
        },

        coins = 12_000,
        level = 15,
    },

    PLAYER_DATA_STORAGE_KEY = "hahaa11a11"
}


table.freeze(Settings)
return Settings