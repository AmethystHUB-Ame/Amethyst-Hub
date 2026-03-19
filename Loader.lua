-- [[ AMETHYST HUB - STABLE LOADER ]] --

-- 1. Reset Guard
getgenv().AmethystLoaded = false

-- 2. Configuration
local DATABASE_URL = "https://raw.githubusercontent.com/AmethystHUB-Ame/Amethyst-Hub/main/Database.lua"

-- 3. Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 4. Fetch Database
local success, result = pcall(function()
    return loadstring(game:HttpGet(DATABASE_URL))()
end)

if not success or type(result) ~= "table" then
    warn("AMETHYST: Gagal load Database! Check link GitHub kau.")
    return
end

-- 5. Create Window
local Window = Rayfield:CreateWindow({
    Name = "Amethyst Hub | v4.0",
    LoadingTitle = "Amethyst Hub Loading...",
    LoadingSubtitle = "Please wait",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- 6. Tab: Main Scripts
local MainTab = Window:CreateTab("Main Scripts", "home")

if result["AmethystHUB Main"] then
    for _, data in pairs(result["AmethystHUB Main"]) do
        MainTab:CreateButton({
            Name = data.Name,
            Callback = function()
                Rayfield:Notify({
                    Title = "Executing...",
                    Content = data.Description,
                    Duration = 3,
                    Image = "play"
                })
                loadstring(game:HttpGet(data.URL))()
            end,
        })
    end
end

-- 7. Tab: Game Scripts
local GameTab = Window:CreateTab("Game Scripts", "gamepad-2")
local gameList = {}
local gameMap = {}

if result["AmethystHUB Game"] then
    for _, data in pairs(result["AmethystHUB Game"]) do
        table.insert(gameList, data.Name)
        gameMap[data.Name] = data
    end
end

local selectedGame = nil
GameTab:CreateDropdown({
    Name = "Select Game",
    Options = gameList,
    CurrentOption = {"None"},
    MultipleOptions = false,
    Callback = function(Option)
        selectedGame = Option[1]
    end,
})

GameTab:CreateButton({
    Name = "Execute Selected",
    Callback = function()
        if selectedGame and gameMap[selectedGame] then
            loadstring(game:HttpGet(gameMap[selectedGame].URL))()
        else
            Rayfield:Notify({Title = "Error", Content = "Pilih game dulu!", Duration = 2})
        end
    end,
})

print("Amethyst Hub: Successfully Loaded!")
