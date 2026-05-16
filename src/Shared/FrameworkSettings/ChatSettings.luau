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
            tagText = "🔒 Holder",
            isRainbow = true
        },

        [254]
        = {
            tagText = "👑 Owner",
            isRainbow = true
        },

        [253]
        = {
            tagText = "🔨 Developer",
            isRainbow = true
        },

        [252]
        = {
            tagText = "👀 Manager",
            tagColor = Color3.fromRGB(119, 0, 255)
        },

        [251]
        = {
            tagText = "⚖ Moderator",
            tagColor = Color3.fromRGB(0, 132, 255)
        },

        [250]
        = {
            tagText = "🕵️‍♂️ Tester",
            tagColor = Color3.fromRGB(255, 0, 0)
        },

        [249]
        = {
            tagText = "✅ Verified",
            tagColor = Color3.fromRGB(0, 255, 0)
        }
    },

    UserIdsWithChatTags
    = {
        [5618502527]
        = {
            tagText = "🤫 Lewis",
            tagColor = Color3.fromRGB(255, 255, 0)
        },

        [5575325013]
        = {
            tagText = "🤔 Alice",
            tagColor = Color3.fromRGB(0, 255, 0)
        }
    },

    GamepassesWithChatTags
    = {
        [1784888719]
        = {
            tagText = "🌹 Paid1",
            tagColor = Color3.fromRGB(255, 0, 255)
        },

        [1783948225]
        = {
            tagText = "🌷 Paid2",
            isRainbow = true
        }
    }
} :: { [string]: { [number]: ChatTagSchema } }


table.freeze(ChatSettings)
return ChatSettings