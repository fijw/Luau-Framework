--!strict
--!native
--!optimize 2


export type ChatTagSchema
= {
    tagText: string,
    isRainbow: true?,
    tagColor: Color3?
}


local ChatSettings
= {
    RanksWithChatTags
    = {
        [255]
        = {
            tagText = "Holder",
            isRainbow = true
        },

        [254]
        = {
            tagText = "Owner",
            isRainbow = true
        },

        [253]
        = {
            tagText = "Developer",
            tagColor = Color3.fromRGB(0, 255, 0)
        },

        [252]
        = {
            tagText = "Moderator",
            tagColor = Color3.fromRGB(255, 0, 0)
        }
    },

    UserIdsWithChatTags
    = {
        [1]
        = {
            tagText = "Roblox",
            tagColor = Color3.fromRGB(255, 0, 0)
        },

        [2]
        = {
            tagText = "John Doe",
            tagColor = Color3.fromRGB(255, 0, 0)
        },

        [3]
        = {
            tagText = "Jane Doe",
            tagColor = Color3.fromRGB(255, 0, 0)
        },

        [5618502527]
        = {
            tagText = "Lewis",
            tagColor = Color3.fromRGB(255, 255, 0)
        }
    },

    GamepassesWithChatTags
    = {
        [123456789]
        = {
            tagText = "VIP",
            tagColor = Color3.fromRGB(255, 255, 0)
        },

        [987654321]
        = {
            tagText = "MVP",
            tagColor = Color3.fromRGB(255, 0, 0)
        },

        [1764385010]
        = {
            tagText = "Test Tag",
            isRainbow = true
        }
    }
} :: { [string]: { [number]: ChatTagSchema } }


table.freeze(ChatSettings)
return ChatSettings