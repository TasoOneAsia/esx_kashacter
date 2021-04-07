---------------------------------------------------------------------------------------
-- Edit this table to all the database tables and columns
-- where identifiers are used (such as users, owned_vehicles, owned_properties etc.)
---------------------------------------------------------------------------------------

local IdentifierTables = KashServerCfg.IdentifierTables

--- Initial boostrap event triggered by client
--- time to set some stuff up for them
RegisterServerEvent("kashactersS:SetupCharacters")
AddEventHandler('kashactersS:SetupCharacters', function()
    local src = source
    local LastCharId = GetLastCharacter(src)

    SetIdentifierToChar(GetGameLicense(src), LastCharId)
    local Characters = GetPlayerCharacters(src)
    TriggerClientEvent('kashactersC:SetupUI', src, Characters)
end)

--- Char Chosen handler, emitted when a client chooses
--- to confirm loading a selected character
RegisterServerEvent("kashactersS:CharacterChosen")
AddEventHandler('kashactersS:CharacterChosen', function(charid, ischar)
    local src = source
    local new = true
    -- Sus type check again.
    if type(charid) == "number" and charid:len() == 1 and type(ischar) == "boolean" then
        SetLastCharacter(src, tonumber(charid))
        SetCharToIdentifier(GetGameLicense(src), tonumber(charid))

        local spawn
        if ischar == true then
            new = false
            spawn = GetSpawnPos(src)
        else
            TriggerClientEvent('skinchanger:loadDefaultModel', src, true, cb)
            spawn = KashServerCfg.DefaultSpawnLocation -- DEFAULT SPAWN POSITION
        end

        TriggerClientEvent("kashactersC:SpawnCharacter", src, spawn, new)
    else
        rint(('[^1esx_kashacters^0] %s. CharID: %s, Source: %s'):format('Type checked failed for char chosen event', charid, src))
    end
end)

--- Ensure that this event has apt security behind it, as it
--- targeted often.
RegisterServerEvent("kashactersS:DeleteCharacter")
AddEventHandler('kashactersS:DeleteCharacter', function(charid)
    local src = source

    -- Do type checks here lol, apparently guy before thought
    -- to do this rather than using prepared statements instead of
    -- directly concatenating into the query string

    if type(charid) == "number" and string.len(charid) == 1 then
        DeleteCharacter(GetGameLicense(src), charid)
        -- We trigger a refresh after killing it
        TriggerClientEvent("kashactersC:ReloadCharacters", src)
    else
        print(('[^1esx_kashacters^0] %s. CharID: %s, Source: %s'):format('Type checked failed for delete char event', charid, src))
    end
end)

--- Get a nested table of Characters and CharacterData
---@param src number playerId
---@return table
function GetPlayerCharacters(src)
    local Chars = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier LIKE @identifier", {
        identifier = GetIdentifierWithoutLicense(GetGameLicense(src))
    })

    -- We now iterate and mutate each char depending
    -- on queries. Mutable boys > immutable boys
    for _, char in ipairs(Chars) do
        -- This is stored as a string
        -- at this time in exec
        local accounts = json.decode(char.accounts)

        local charJob = MySQL.Sync.fetchAll("SELECT * FROM jobs WHERE name = @name", {
            name = char.job
        })
        -- Select the job grades previous char
        local charJobgrade = MySQL.Sync.fetchAll("SELECT * FROM job_grades WHERE grade = @grade AND job_name = @jobname", {
            grade = char.job_grade,
            jobname = char.jobname
        })

        char.bank = accounts.bank
        char.money = accounts.money

        char.job = charJob[1].label

        -- Welface check
        if charJob[1].label == "Unemployed" then
            char.job_grade = ""
        else
            charJob.job_grade = charJobgrade[1].label
        end


        if char.sex == "m" then
            char.sex = "Male"
        else
            char.sex = "Female"
        end

    end

    return Chars
end

--- Get the last character
--- @param src number PlayerID ie 'source'
--- @return number
function GetLastCharacter(src)
    local LastChar = MySQL.Sync.fetchAll([[
        SELECT charid
        FROM user_lastcharacter
        WHERE license = @license
    ]], {
        license = GetGameLicense(src)
    })
    -- If we actually get a LastChar back from query
    if LastChar[1] ~= nil and LastChar[1].charid ~= nil then
        return tonumber(LastChar[1].charid)
    -- Just create a new row for user_lastcharacter then
    else
        MySql.Async.fetchAll("INSERT INTO user_lastcharacter (license, charid) VALUES (@license, 1)", {
            license = GetGameLicense(src)
        })
        return 1
    end
end
--- Update database with last used character for a license
---@param src number playerId
---@param charid number Set the last character ID for a player
---@return void
function SetLastCharacter(src, charid)
    MySql.Async.execute([[
        UPDATE `user_lastcharacter`
        SET `charid` = @charid
        WHERE `license` = @license
    ]], {
        charid = charid,
        license = GetGameLicense(src)
    })
end
--- Set a specific player row in database to a char
--- using identifier
--- @param identifier string The identifier to resolve
--- @param charid number The character ID to set for the player
---
function SetIdentifierToChar(identifier, charid)
    local formatCharId = ('Char%s%s'):format(charid, GetIdentifierWithoutLicense(identifier))
    for i = 1, #IdentifierTables, 1 do
        local identifierObj = IdentifierTables[i]
        MySQL.Async.execute([[
            UPDATE `@identiferTable`
            SET `@tableColumn = @charId
            WHERE   @identifierTable = @identifier
        ]], {
            charid = formatCharId,
            identifierTable = identifierObj.table,
            dentifierTable = identifierObj.column,
            identifier = identifier
        })
    end
end

--- Set a specific player row in database to a identifer
--- using a charid
--- @param identifier string The identifier to resolve
--- @param charid number The character ID to set for the player
---
function SetCharToIdentifier(identifier, charid)
    local formatCharId = ('Char%s%s'):format(charid, GetIdentifierWithoutLicense(identifier))
    for i = 1, #IdentifierTables, 1 do
        local identifierObj = IdentifierTables[i]
        MySQL.Async.execute([[
            UPDATE @identTable
            SET @tableColumn = @identifier
            WHERE @tableColumn = @charID
        ]], {
            identTable = identifierObj.table,
            tableColumn = identifierObj.column,
            charID = formatCharId,
            identifier = identifier
        })
    end
end

--- Deletes character for a specific user using a charid
--- @param identifier string The identifier to resolve
--- @param charid number The character ID to set for the player
---
function DeleteCharacter(identifier, charid)
    local formatCharId = ('Char%s%s'):format(charid, GetIdentifierWithoutLicense(identifier))
    for i = 1, #IdentifierTables, 1 do
        local identifierObj = IdentifierTables[i]
        MySQL.Async.execute([[
            DELETE FROM @identTable
            WHERE @identColumn = @charID'
        ]], {
            charID = formatCharId,
            identTable = identifierObj.table,
            identColumn = identifierObj.column
        })
    end
end

--- Get the last known position for player
--- I feel very eh about this existing
---@param src number PlayerID
---@return table Table with values x, y ,z
function GetSpawnPos(src)
    local spawn = MySQL.Sync.fetchScalar("SELECT `position` FROM `users` WHERE `identifier` = @identifier", {
        identifier = GetGameLicense(src)
    })
    return json.decode(spawn.position)
end

--- Kinda useless NGL, substr function
--- that returns the identifier without the license
--- prefix.
---@param ident string The license
---@return string
function GetIdentifierWithoutLicense(ident)
    return ident:gsub("license", "")
end

--- Quick util to get the identifier `license:` from a
--- player (always license 1, never license2:)
---@param playerId number PlayerID
---@return string The game license
function GetGameLicense(playerId)
    local identifier
    local gameIdentifiers = GetPlayerIdentifiers(playerId)

    for i=1, #gameIdentifiers, 1 do
        local ident = gameIdentifiers[i]
        -- We are parsing specifically for license1 not license2 if available
        if ident:match('license:') then
            identifier = v
            break
        end
    end

    return identifier
end
