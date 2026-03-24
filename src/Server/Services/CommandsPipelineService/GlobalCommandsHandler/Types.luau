--!strict
--!native
--!optimize 2


export type DecompressedDataSchema
= {
    targetId: number?,
    commandType: "ban" | "kick" | "bring_player_to_server",
    reason: string?,
    senderId: number?
}


return nil