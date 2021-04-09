local ESX = nil
local IsChoosing = true
local cam
local cam2


-- Global to local micro-optimizations
-- Assigning a global to a local will yield 30% performance gains,
-- versus traversing _G

local NetworkIsSessionStarted = NetworkIsSessionStarted
local ShutdownLoadingScreen = ShutdownLoadingScreen
local DisplayHud = DisplayHud
local DisplayRadar = DisplayRadar
local Wait = Wait
local DoScreenFadeOut = DoScreenFadeOut
local DoScreenFadeIn = DoScreenFadeIn
local IsScreenFadedOut = IsScreenFadedOut
local SetTimecycleModifier = SetTimecycleModifier
local FreezeEntityPosition = FreezeEntityPosition
local CreateCamWithParams = CreateCamWithParams
local SetCamActive = SetCamActive
local RenderScriptCams = RenderScriptCams
local SetNuiFocus = SetNuiFocus
local SendNUIMessage = SendNUIMessage
local SetEntityCoords = SetEntityCoords
local PointCamAtCoord = PointCamAtCoord
local SetCamActiveWithInterp = SetCamActiveWithInterp
local PlaySoundFrontend = PlaySoundFrontend
local DestroyCam = DestroyCam
local TriggerEvent = TriggerEvent
local TriggerServerEvent = TriggerServerEvent

CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Wait(0)
    end
end)

-- This Code Was changed to fix error With player spawner as default --
-- Link to the post with the error fix --
-- https://forum.fivem.net/t/release-esx-kashacters-multi-character/251613/316?u=xxfri3ndlyxx --
CreateThread(function()
    while true do
        Wait(200)
        if ESX ~= nil then
            if NetworkIsSessionStarted() and not ESX.IsPlayerLoaded() then
                TriggerServerEvent("kashactersS:SetupCharacters")
                TriggerEvent("kashactersC:SetupCharacters")
                return -- break the loop
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if IsChoosing then
            DisplayHud(false)
            DisplayRadar(false)
        end
    end
end)

RegisterNetEvent('kashactersC:SetupCharacters')
AddEventHandler('kashactersC:SetupCharacters', function()
    ShutdownLoadingScreen()
    Wait(100)
    DoScreenFadeOut(10)
    while not IsScreenFadedOut() do
        Wait(10)
    end
    SetTimecycleModifier('hud_def_blur')
    FreezeEntityPosition(PlayerPedId(), true)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", -1355.93, -1487.78, 520.75, 300.00, 0.00, 0.00, 100.00, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1, true, true)
end)

RegisterNetEvent('kashactersC:SetupUI')
AddEventHandler('kashactersC:SetupUI', function(Characters)
    DoScreenFadeIn(500)
    Wait(500)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openui",
        characters = Characters,
    })
end)

RegisterNetEvent('kashactersC:SpawnCharacter')
AddEventHandler('kashactersC:SpawnCharacter', function(spawn, isnew)
    local pos = spawn
    local playerPed = PlayerPedId()

    SetTimecycleModifier('default')
    SetEntityCoords(playerPed, pos.x, pos.y, pos.z)
    DoScreenFadeIn(500)

    Wait(500)

    cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", -1355.93,-1487.78,520.75, 300.00,0.00,0.00, 100.00, false, 0)
    PointCamAtCoord(cam2, pos.x,pos.y,pos.z+200)
    SetCamActiveWithInterp(cam2, cam, 900, true, true)

    Wait(900)

    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z + 200, 300.00, 0.00, 0.00, 100.00, false, 0)
    PointCamAtCoord(cam, pos.x, pos.y, pos.z + 2)
    SetCamActiveWithInterp(cam, cam2, 3700, true, true)

    Wait(3700)

    PlaySoundFrontend(-1, "Zoom_Out", "DLC_HEIST_PLANNING_BOARD_SOUNDS", 1)
    RenderScriptCams(false, true, 500, true, true)
    PlaySoundFrontend(-1, "CAR_BIKE_WHOOSH", "MP_LOBBY_SOUNDS", 1)
    FreezeEntityPosition(playerPed, false)

    Wait(500)

    SetCamActive(cam, false)
    DestroyCam(cam, true)
    IsChoosing = false
    DisplayHud(true)
    DisplayRadar(true)

    TriggerEvent('esx:kashloaded')
    TriggerEvent('esx_ambulancejob:multicharacter', source)
    if isnew == true then
        TriggerEvent('esx_identity:showRegisterIdentity')
    end
end)

RegisterNetEvent('kashactersC:ReloadCharacters')
AddEventHandler('kashactersC:ReloadCharacters', function()
    TriggerServerEvent("kashactersS:SetupCharacters")
    TriggerEvent("kashactersC:SetupCharacters")
end)

RegisterNUICallback("CharacterChosen", function(data, cb)
    SetNuiFocus(false, false)
    DoScreenFadeOut(500)
    TriggerServerEvent('kashactersS:CharacterChosen', data.charid, data.ischar)
    while not IsScreenFadedOut() do
        Wait(10)
    end
    cb({})
end)

RegisterNUICallback("DeleteCharacter", function(data, cb)
    SetNuiFocus(false, false)
    DoScreenFadeOut(500)
    TriggerServerEvent('kashactersS:DeleteCharacter', data.charid)
    while not IsScreenFadedOut() do
        Wait(10)
    end
    cb({})
end)
