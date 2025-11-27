--[[
    @Framework
    ```
         ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ 
        |___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|
                                                                                                    
                                                                                                    
         _                                                                                       _   
        | |                     _____                   _   _                                   | |  
        | |                    |  _  |___ ___ _____ ___| |_| |_ ___ _ _ ___                     | |  
        | |                    |   __|  _| . |     | -_|  _|   | -_| | |_ -|                    | |  
        | |                    |__|  |_| |___|_|_|_|___|_| |_|_|___|___|___|                    | |  
        |_|                                                                                     |_|  
         _                                                                                       _   
        | |            _____     _   _            _____                                 _       | |  
        | |     ___   | __  |___| |_| |___ _ _   |   __|___ ___ _____ ___ _ _ _ ___ ___| |_     | |  
        | |    | .'|  |    -| . | . | | . |_'_|  |   __|  _| .'|     | -_| | | | . |  _| '_|    | |  
        | |    |__,|  |__|__|___|___|_|___|_,_|  |__|  |_| |__,|_|_|_|___|_____|___|_| |_,_|    | |  
        |_|                                                                                     |_|  
         _                                                                                       _   
        | |                           _        _          _____     _                           | |  
        | |               _____ ___ _| |___   | |_ _ _   |  |  |___|_|___ ___ ___               | |  
        | |              |     | .'| . | -_|  | . | | |  |    -| .'| |  _| . |_ -|              | |  
        | |              |_|_|_|__,|___|___|  |___|_  |  |__|__|__,|_|_| |___|___|              | |  
        |_|                                       |___|                                         |_|  
                                                                                                    
                                                                                                    
         ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ 
        |___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|
    ```

    @Description This is where you can input your experience & community dependent settings.
    @Description Such as selecting whichs ranks in the experience's community are allowed to use chat commands,
    @Description and which ranks have which chat tags (you can select the tags each rank receives).
]]
--!strict
--!optimize 2


local FrameworkSettings
= {
    Permissions
    = {
        AllowedForChatCommands
        = {
            Ranks = { 255, 254, 253, 252, 251 },
            UserIds = { 1, 2, 3, 8446684428 }
        },

        AllowedForChatTags
        = {
            Ranks
            = {
                [255] = "🔒 holder",
                [254] = "👑 kairos",
                [253] = "⚡ lead dev",
                [252] = "🔨 dev",
                [251] = "💼 manager"
            },

            UserIds
            = {
                [1] = "🤖 roblox",
                [2] = "❓ john doe",
                [3] = "❔ jane doe",
                [8446684428] = "🌟 special user"
            }
        }
    },

    Commands
    = {
        ChatCommandPrefixes = { "$", "/", ":" },

        moderationActionLoggingWebhookExtension = "1429616026982547456/an3RQ9joHLKfIUjeuStx6YyIF-w100-ERDxqu3hsb9ISzGyW1Ojmb-gePt2_FylfVbPB"
    },

    registryProfileStorageTag = "hermmm 3"
}


table.freeze(FrameworkSettings)
return FrameworkSettings