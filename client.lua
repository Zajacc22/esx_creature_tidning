local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  }
  
ESX                           = nil

local Fishing = false

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData() == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

local Locations = {        --Jag ska byta coords innan release

    ["Blips"] = {

        ["SellTidning"] = {
            ["title"] = "Sälj Tidningar",
            ["sprite"] = 356,
            ["x"] =  -1845.41, ["y"] = -1196.15, ["z"] = 12.17
        }

    },

    ["Markers"] = {
        ["SellTidning"] = { ["x"] = -1845.28, ["y"] = -1195.79, ["z"] = 18.33, ["Info"] = "[E] ~g~Sälj Tidningar" }
    }
}                            --Jag ska byta coords innan release

Citizen.CreateThread(function()

    local Blips = Locations["Blips"]

    for spot, val in pairs(Blips) do
        local BlipInformation = val
        
        local Blip = AddBlipForCoord(BlipInformation["x"], BlipInformation["y"], BlipInformation["z"])
        SetBlipSprite(Blip, BlipInformation["sprite"])
        SetBlipDisplay(Blip, 4)
        SetBlipScale(Blip, 0.8)
        SetBlipColour(Blip, 0)
        SetBlipAsShortRange(Blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(BlipInformation["title"])
        EndTextCommandSetBlipName(Blip)
    end

    Citizen.Wait(0)

    while true do
      
        local sleep = 500
        
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if not Fishing then

            for place, v in pairs(Locations["Markers"]) do

                local dstCheck = GetDistanceBetweenCoords(coords, v["x"], v["y"], v["z"], true)

                if dstCheck <= 5.0 then
                    sleep = 5
                    DrawM(v["Info"], 27, v["x"], v["y"], v["z"])
                    if dstCheck <= 1.5 then
                        if IsControlJustPressed(0, Keys["E"]) then
                            print(place)
                            StartAction(place)
                        end
                    end
                end
            end

        end

        Citizen.Wait(sleep)


    end
end) 
  
function StartAction(currentAction)
    if string.len(currentAction) >= 15 then
        StartFishing()
    elseif currentAction == "SellTidning" then
        TriggerServerEvent("esx_creature_tidning:sellTidning")
    end
end 

function Draw3DText(x, y, z, text)
      local onScreen, _x, _y = World3dToScreen2d(x, y, z)
      local p = GetGameplayCamCoords()
      local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
      local scale = (1 / distance) * 2
      local fov = (1 / GetGameplayCamFov()) * 100
      local scale = scale * fov
      if onScreen then
          SetTextScale(0.0*scale, 0.35*scale)
          SetTextFont(0)
          SetTextProportional(1)
          SetTextColour(255, 255, 255, 255)
          SetTextDropshadow(0, 0, 0, 0, 255)
          SetTextEdge(2, 0, 0, 0, 150) 
          SetTextDropShadow()
          SetTextOutline()
          SetTextEntry("STRING")
          SetTextCentre(1)
          AddTextComponentString(text)
          DrawText(_x,_y)
      end
end

function DrawM(hint, type, x, y, z)
	ESX.Game.Utils.DrawText3D({x = x, y = y, z = z + 1.0}, hint, 0.4)
	DrawMarker(type, x, y, z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 2.0, 2.0, 255, 255, 255, 100, false, true, 2, false, false, false, false)
end
