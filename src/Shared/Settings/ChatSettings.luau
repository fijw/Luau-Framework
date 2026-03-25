--!strict
--!native
--!optimize 2


--[[ @section Types ]]
export type ChatTagSchema
= {
    tagText: string,
    isRainbow: true?,
    tagColor: Color3?
}

export type PermissionTypes = "moderator" | "developer" | "fun_perms"
--[[ @end_section Types ]]


local ChatSettings
= {
    ChatTagSettings
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
    } :: { [string]: { [number]: ChatTagSchema } },

    ChatCommandSettings
    = {
        RanksWithCommandPermissions
        = {
            [255] = "developer" ,
            [254] = "developer",
            [253] = "moderator"
        },

        UserIdsWithCommandPermissions
        = {
            [1] = "developer",
            [2] = "developer",
            [3] = "developer",
            [5618502527] = "moderator"
        },

        loggingDiscordWebhookUrl
        = "https://webhook.lewisakura.moe/api/webhooks/1485411995787202752/"
        .. "7laGnAIijqNmmSbiBEQl3h0PzaqrASaliE9r9p1W8h_uBkWvmTDSPlqecRiwt0uYsNke"
    }
    :: {
        RanksWithCommandPermissions: { [number]: PermissionTypes },
        UserIdsWithCommandPermissions: { [number]: PermissionTypes },
        loggingDiscordWebhookUrl: string
    }
}


table.freeze(ChatSettings)
return ChatSettings