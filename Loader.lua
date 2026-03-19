--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║               AMETHYST HUB LOADER v4.0 (FIXED)               ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- 1. ANTI-DOUBLE LOAD
if getgenv().AmethystLoaded then
    warn("[Amethyst Hub] Already loaded!")
    return
end
getgenv().AmethystLoaded = true

-- 2. CONFIGURATION (GANTI LINK DI BAWAH INI)
local DATABASE_URL = "https://raw.githubusercontent.com/AmethystHUB-Ame/Amethyst-Hub/main/Database.lua"

-- 3. SERVICES
local HttpService = game:GetService("HttpService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 4. FETCH DATABASE
print("Amethyst: Fetching Database...")
local success, result = pcall(function()
    return loadstring(game:HttpGet(DATABASE_URL))()
end)

if not success or type(result) ~= "table" then
    getgenv().AmethystLoaded = false
    warn("Amethyst Fatal Error: Gagal ambil Database! Link Raw mungkin salah.")
    return
end

-- 5. CREATE WINDOW
local Window = Rayfield:CreateWindow({
    Name = "Amethyst Hub | v4.0",
    LoadingTitle = "💎 AMETHYST HUB",
    LoadingSubtitle = "by Amethyst Team",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- 6. TAB: MAIN SCRIPTS
local MainTab = Window:CreateTab("Main Scripts", "home")
MainTab:CreateSection("AmethystHUB Main")

if result["AmethystHUB Main"] then
    for _, scriptData in pairs(result["AmethystHUB Main"]) do
        MainTab:CreateButton({
            Name = scriptData.Name,
            Callback = function()
                Rayfield:Notify({
                    Title = "Executing: " .. scriptData.Name,
                    Content = scriptData.Description,
                    Duration = 3,
                    Image = "play"
                })
                loadstring(game:HttpGet(scriptData.URL))()
            end,
        })
    end
end

-- 7. TAB: GAME SCRIPTS (DROPDOWN)
local GameTab = Window:CreateTab("Game Scripts", "gamepad-2")
GameTab:CreateSection("AmethystHUB Game")

local gameList = {}
local gameMap = {}

if result["AmethystHUB Game"] then
    for _, scriptData in pairs(result["AmethystHUB Game"]) do
        table.insert(gameList, scriptData.Name)
        gameMap[scriptData.Name] = scriptData
    end
end

local selectedGame = nil

local Dropdown = GameTab:CreateDropdown({
    Name = "Select a Game",
    Options = gameList,
    CurrentOption = {"None"},
    MultipleOptions = false,
    Flag = "GameDropdown",
    Callback = function(Option)
        selectedGame = Option[1]
    end,
})

GameTab:CreateButton({
    Name = "🚀 Execute Selected Game",
    Callback = function()
        if selectedGame and gameMap[selectedGame] then
            local data = gameMap[selectedGame]
            Rayfield:Notify({
                Title = "Loading " .. data.Name,
                Content = data.Description,
                Duration = 3,
                Image = "download"
            })
            loadstring(game:HttpGet(data.URL))()
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Sila pilih game dari dropdown dulu!",
                Duration = 3,
                Image = "alert-circle"
            })
        end
    end,
})

Rayfield:Notify({
    Title = "Amethyst Loaded!",
    Content = "Database Berjaya Diambil.",
    Duration = 5,
    Image = "check-circle",
})
