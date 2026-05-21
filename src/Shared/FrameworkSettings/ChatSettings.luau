--!strict
--!native
--!optimize 2


export type ChatTagSchema
= {
    tagText: string,
    tagColor: Color3 | "rainbow"
}


local ChatSettings
= {
    RanksWithChatTags
    = {
        [255]
        = {
            tagText = "Owner",
            tagColor = "rainbow"
        } :: ChatTagSchema,

        [254]
        = {
            tagText = "Developer",
            tagColor = "rainbow"
        } :: ChatTagSchema,

        [253]
        = {
            tagText = "Contributor",
            tagColor = Color3.fromRGB(255, 145, 0)
        } :: ChatTagSchema,

        [252]
        = {
            tagText = "Manager",
            tagColor = Color3.fromRGB(119, 0, 255)
        } :: ChatTagSchema,

        [251]
        = {
            tagText = "Moderator",
            tagColor = Color3.fromRGB(0, 132, 255)
        } :: ChatTagSchema,

        [250]
        = {
            tagText = "Tester",
            tagColor = Color3.fromRGB(255, 0, 0)
        } :: ChatTagSchema,

        [249]
        = {
            tagText = "Verified",
            tagColor = Color3.fromRGB(0, 255, 0)
        } :: ChatTagSchema
    },

    UserIdsWithChatTags
    = {
        [5618502527]
        = {
            tagText = "Lewis",
            tagColor = Color3.fromRGB(255, 255, 0)
        } :: ChatTagSchema,

        [5575325013]
        = {
            tagText = "Alice",
            tagColor = Color3.fromRGB(0, 255, 0)
        } :: ChatTagSchema
    },

    GamepassesWithChatTags
    = {
        [1784888719]
        = {
            tagText = "Paid1",
            tagColor = Color3.fromRGB(255, 0, 255)
        } :: ChatTagSchema,

        [1783948225]
        = {
            tagText = "Paid2",
            tagColor = "rainbow"
        } :: ChatTagSchema
    }
}


table.freeze(ChatSettings)
return ChatSettings