--!strict
--!native
--!optimize 2


-- "fun_perms" is not able to be assigned to a user or rank.
export type PermissionTypes = "moderator" | "developer" | "fun_perms"


local CmdsSettings
= {
    RanksWithCommandPermissions
    = {
        [255] = "developer",
        [254] = "developer",
        [253] = "developer",

        [252] = "moderator",
        [251] = "moderator"
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
} :: {
    RanksWithCommandPermissions: { [number]: PermissionTypes },
    UserIdsWithCommandPermissions: { [number]: PermissionTypes },
    loggingDiscordWebhookUrl: string
}


table.freeze(CmdsSettings)
return CmdsSettings