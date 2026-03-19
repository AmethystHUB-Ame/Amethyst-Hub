--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║               AMETHYST HUB LOADER v4.0                      ║
    ║       Dynamic Database Version with Rayfield UI              ║
    ║                                                              ║
    ║  Features:                                                   ║
    ║   • Animated splash screen with Amethyst branding            ║
    ║   • Remote database fetch from GitHub                        ║
    ║   • Main Scripts tab with dynamic buttons                    ║
    ║   • Game Scripts tab with dropdown + execute                 ║
    ║   • Amethyst Purple theme throughout                         ║
    ║   • Mobile-friendly (Delta/Fluxus/Hydrogen compatible)       ║
    ║   • Anti-double-load protection                              ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- ══════════════════════════════════════════════════════════════
-- SECTION 0: ANTI-DOUBLE LOAD GUARD
-- ══════════════════════════════════════════════════════════════

if getgenv().AmethystLoaded then
    warn("[Amethyst Hub] Already loaded this session. Aborting duplicate execution.")
    return
end
getgenv().AmethystLoaded = true

-- ══════════════════════════════════════════════════════════════
-- SECTION 1: SERVICE REFERENCES & CONSTANTS
-- ══════════════════════════════════════════════════════════════

local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui         = game:GetService("CoreGui")

local LocalPlayer     = Players.LocalPlayer
local PlayerName      = LocalPlayer and LocalPlayer.Name or "Player"

-- Amethyst colour palette
local COLORS = {
    Background     = Color3.fromRGB(35, 10, 50),
    Outline        = Color3.fromRGB(180, 100, 255),
    OutlineGlow    = Color3.fromRGB(200, 140, 255),
    BarBackground  = Color3.fromRGB(55, 20, 75),
    BarFill        = Color3.fromRGB(180, 100, 255),
    TextPrimary    = Color3.fromRGB(230, 200, 255),
    TextSecondary  = Color3.fromRGB(150, 120, 180),
    White          = Color3.fromRGB(255, 255, 255),
    Transparent    = Color3.fromRGB(0, 0, 0),
}

-- Database URL (dynamic — always fetches latest)
local DATABASE_URL = "https://raw.githubusercontent.com/AmethystHUB-Ame/Amethyst-Hub/refs/heads/main/Database.lua"

-- ══════════════════════════════════════════════════════════════
-- SECTION 2: UTILITY HELPERS
-- ══════════════════════════════════════════════════════════════

local function tweenPlay(instance, tweenInfo, properties)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function tweenAndWait(instance, tweenInfo, properties)
    local tween = tweenPlay(instance, tweenInfo, properties)
    tween.Completed:Wait()
    return tween
end

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

local function addStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLORS.Outline
    stroke.Thickness = thickness or 2
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function addPadding(parent, top, bottom, left, right)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, top or 0)
    pad.PaddingBottom = UDim.new(0, bottom or 0)
    pad.PaddingLeft   = UDim.new(0, left or 0)
    pad.PaddingRight  = UDim.new(0, right or 0)
    pad.Parent = parent
    return pad
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 3: SPLASH SCREEN
-- ══════════════════════════════════════════════════════════════

local SplashGui = Instance.new("ScreenGui")
SplashGui.Name = "AmethystSplash"
SplashGui.ResetOnSpawn = false
SplashGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SplashGui.IgnoreGuiInset = true
SplashGui.DisplayOrder = 999

local guiParent = (syn and syn.protect_gui and CoreGui)
    or (gethui and gethui())
    or CoreGui

local splashParentOk = pcall(function()
    SplashGui.Parent = guiParent
end)
if not splashParentOk then
    SplashGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Semi-transparent background overlay
local Overlay = Instance.new("Frame")
Overlay.Name = "Overlay"
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(10, 2, 15)
Overlay.BackgroundTransparency = 0.3
Overlay.BorderSizePixel = 0
Overlay.Parent = SplashGui

-- Main splash card
local SplashCard = Instance.new("Frame")
SplashCard.Name = "SplashCard"
SplashCard.AnchorPoint = Vector2.new(0.5, 0.5)
SplashCard.Position = UDim2.new(0.5, 0, 0.5, 0)
SplashCard.Size = UDim2.new(0, 360, 0, 200)
SplashCard.BackgroundColor3 = COLORS.Background
SplashCard.BackgroundTransparency = 1
SplashCard.BorderSizePixel = 0
SplashCard.Parent = SplashGui

addCorner(SplashCard, 16)
local splashStroke = addStroke(SplashCard, COLORS.Outline, 2.5, 1)

-- Logo Text
local LogoText = Instance.new("TextLabel")
LogoText.Name = "LogoText"
LogoText.AnchorPoint = Vector2.new(0.5, 0)
LogoText.Position = UDim2.new(0.5, 0, 0.12, 0)
LogoText.Size = UDim2.new(0.9, 0, 0, 40)
LogoText.BackgroundTransparency = 1
LogoText.Text = "💎 Amethyst Hub"
LogoText.TextColor3 = COLORS.Outline
LogoText.TextTransparency = 1
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 28
LogoText.TextScaled = false
LogoText.Parent = SplashCard

-- Status text
local StatusText = Instance.new("TextLabel")
StatusText.Name = "StatusText"
StatusText.AnchorPoint = Vector2.new(0.5, 0)
StatusText.Position = UDim2.new(0.5, 0, 0.42, 0)
StatusText.Size = UDim2.new(0.85, 0, 0, 22)
StatusText.BackgroundTransparency = 1
StatusText.Text = ""
StatusText.TextColor3 = COLORS.TextSecondary
StatusText.TextTransparency = 1
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 14
StatusText.Parent = SplashCard

-- Loading bar background
local BarBG = Instance.new("Frame")
BarBG.Name = "BarBG"
BarBG.AnchorPoint = Vector2.new(0.5, 0)
BarBG.Position = UDim2.new(0.5, 0, 0.72, 0)
BarBG.Size = UDim2.new(0.75, 0, 0, 8)
BarBG.BackgroundColor3 = COLORS.BarBackground
BarBG.BackgroundTransparency = 1
BarBG.BorderSizePixel = 0
BarBG.Parent = SplashCard
addCorner(BarBG, 4)

-- Loading bar fill
local BarFill = Instance.new("Frame")
BarFill.Name = "BarFill"
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = COLORS.BarFill
BarFill.BackgroundTransparency = 1
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBG
addCorner(BarFill, 4)

-- Version tag
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "Version"
VersionLabel.AnchorPoint = Vector2.new(0.5, 1)
VersionLabel.Position = UDim2.new(0.5, 0, 0.95, 0)
VersionLabel.Size = UDim2.new(0.5, 0, 0, 14)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v4.0"
VersionLabel.TextColor3 = COLORS.TextSecondary
VersionLabel.TextTransparency = 1
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextSize = 11
VersionLabel.Parent = SplashCard

-- Splash Animation
local fastTween  = TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local medTween   = TweenInfo.new(0.6,  Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local barTween   = TweenInfo.new(0.5,  Enum.EasingStyle.Sine,  Enum.EasingDirection.InOut)
local pulseTween = TweenInfo.new(1.2,  Enum.EasingStyle.Sine,  Enum.EasingDirection.InOut, -1, true)

tweenPlay(SplashCard,   medTween, { BackgroundTransparency = 0 })
tweenPlay(splashStroke,  medTween, { Transparency = 0 })
tweenPlay(LogoText,      medTween, { TextTransparency = 0 })
tweenPlay(StatusText,    medTween, { TextTransparency = 0 })
tweenPlay(BarBG,         medTween, { BackgroundTransparency = 0 })
tweenPlay(BarFill,       medTween, { BackgroundTransparency = 0 })
tweenAndWait(VersionLabel, medTween, { TextTransparency = 0.4 })

local glowPulse = tweenPlay(splashStroke, pulseTween, { Color = COLORS.OutlineGlow })
local logoPulse = tweenPlay(LogoText, pulseTween, { TextTransparency = 0.25 })

local statusMessages = {
    { text = "Connecting to GitHub...",                  progress = 0.2  },
    { text = "Fetching Database...",                     progress = 0.5  },
    { text = "Verifying Scripts...",                     progress = 0.8  },
    { text = "Welcome, " .. PlayerName .. "!",           progress = 1.0  },
}

for i, msg in ipairs(statusMessages) do
    StatusText.Text = msg.text
    tweenAndWait(BarFill, barTween, { Size = UDim2.new(msg.progress, 0, 1, 0) })
    if i < #statusMessages then
        task.wait(0.35)
    end
end

task.wait(0.8)
glowPulse:Cancel()
logoPulse:Cancel()

-- ══════════════════════════════════════════════════════════════
-- SECTION 4: FETCH REMOTE DATABASE
-- ══════════════════════════════════════════════════════════════

local Database = nil
local fetchSuccess, fetchError = pcall(function()
    local rawData
    if game and game.HttpGet then
        rawData = game:HttpGet(DATABASE_URL)
    elseif request then
        rawData = request({ Url = DATABASE_URL, Method = "GET" }).Body
    elseif http_request then
        rawData = http_request({ Url = DATABASE_URL, Method = "GET" }).Body
    elseif syn and syn.request then
        rawData = syn.request({ Url = DATABASE_URL, Method = "GET" }).Body
    else
        error("No HTTP method available on this executor.")
    end

    local loader = loadstring(rawData)
    if loader then
        Database = loader()
    else
        error("Failed to parse database source.")
    end
end)

local fetchFailed = not fetchSuccess

if fetchFailed then
    warn("Database failed to load!")
    warn("[Amethyst Hub] Fetch error detail: " .. tostring(fetchError))
else
    print("Database loaded successfully")
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 5: FADE OUT SPLASH SCREEN
-- ══════════════════════════════════════════════════════════════

local fadeOutTween = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

tweenPlay(SplashCard,   fadeOutTween, { BackgroundTransparency = 1 })
tweenPlay(splashStroke,  fadeOutTween, { Transparency = 1 })
tweenPlay(LogoText,      fadeOutTween, { TextTransparency = 1 })
tweenPlay(StatusText,    fadeOutTween, { TextTransparency = 1 })
tweenPlay(BarBG,         fadeOutTween, { BackgroundTransparency = 1 })
tweenPlay(BarFill,       fadeOutTween, { BackgroundTransparency = 1 })
tweenPlay(VersionLabel,  fadeOutTween, { TextTransparency = 1 })
tweenAndWait(Overlay,    fadeOutTween, { BackgroundTransparency = 1 })

SplashGui:Destroy()

-- ══════════════════════════════════════════════════════════════
-- SECTION 6: LOAD RAYFIELD UI LIBRARY
-- ══════════════════════════════════════════════════════════════

local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"
))()

-- ══════════════════════════════════════════════════════════════
-- SECTION 7: CREATE THE MAIN WINDOW
-- ══════════════════════════════════════════════════════════════

local Window = Rayfield:CreateWindow({
    Name            = "💎 Amethyst Hub v4.0",
    Icon            = 0,
    LoadingEnabled  = false,
    ConfigurationSaving = {
        Enabled  = false,
        FileName = "AmethystHub_Config"
    },
    Discord = {
        Enabled  = false,
    },
    KeySystem       = false,
    Theme           = "Amethyst",
})

-- Show error notification if database fetch failed
if fetchFailed then
    Rayfield:Notify({
        Title   = "Connection Error",
        Content = "Error: Could not connect to Amethyst Database. Tabs may be empty.",
        Duration = 6,
        Image   = "alert-triangle",
    })
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 8: TAB 1 — MAIN SCRIPTS
-- Loops through ["AmethystHUB Main"] and creates buttons.
-- ══════════════════════════════════════════════════════════════

local MainTab = Window:CreateTab("Main Scripts", "zap")

if Database and Database["AmethystHUB Main"] and type(Database["AmethystHUB Main"]) == "table" then
    MainTab:CreateLabel("📂 AmethystHUB Main Scripts")

    for _, scriptEntry in ipairs(Database["AmethystHUB Main"]) do
        local sName = scriptEntry.Name or scriptEntry["Name"] or "Unnamed Script"
        local sURL  = scriptEntry.URL  or scriptEntry["URL"]  or ""
        local sDesc = scriptEntry.Description or scriptEntry["Description"] or ""

        MainTab:CreateButton({
            Name = "▶ " .. sName,
            Callback = function()
                -- Show notification with description
                Rayfield:Notify({
                    Title   = "💎 " .. sName,
                    Content = sDesc ~= "" and sDesc or ("Loading " .. sName .. "..."),
                    Duration = 4,
                    Image   = "download",
                })

                -- Execute the remote script safely
                local execOk, execErr = pcall(function()
                    loadstring(game:HttpGet(sURL))()
                end)

                if not execOk then
                    Rayfield:Notify({
                        Title   = "Execution Error",
                        Content = "Failed to load " .. sName .. ":\n" .. tostring(execErr),
                        Duration = 6,
                        Image   = "alert-triangle",
                    })
                    warn("[Amethyst Hub] Script execution error (" .. sName .. "): " .. tostring(execErr))
                else
                    Rayfield:Notify({
                        Title   = "Success",
                        Content = sName .. " loaded successfully!",
                        Duration = 3,
                        Image   = "check-circle",
                    })
                end
            end,
        })

        -- Show description below the button
        if sDesc ~= "" then
            MainTab:CreateParagraph({
                Title   = "",
                Content = sDesc,
            })
        end
    end
else
    MainTab:CreateLabel("⚠️ No main scripts loaded — check your connection.")
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 9: TAB 2 — GAME SCRIPTS
-- ONE dropdown populated from ["AmethystHUB Game"] + Execute btn
-- ══════════════════════════════════════════════════════════════

local GameTab = Window:CreateTab("Game Scripts", "gamepad-2")

local selectedGameName = nil
local selectedGameURL  = nil
local selectedGameDesc = nil

-- Build lookup table and name list from database
local gameNames = {}
local gameLookup = {}

if Database and Database["AmethystHUB Game"] and type(Database["AmethystHUB Game"]) == "table" then
    for _, entry in ipairs(Database["AmethystHUB Game"]) do
        local gName = entry.Name or entry["Name"] or "Unknown Game"
        local gURL  = entry.URL  or entry["URL"]  or ""
        local gDesc = entry.Description or entry["Description"] or ""

        table.insert(gameNames, gName)
        gameLookup[gName] = {
            URL = gURL,
            Description = gDesc,
        }
    end
end

if #gameNames > 0 then
    GameTab:CreateLabel("🎮 AmethystHUB Game Scripts")

    GameTab:CreateDropdown({
        Name = "Select a Game",
        Options = gameNames,
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "AmethystGameDropdown",
        Callback = function(Options)
            local picked = Options[1] or Options
            if type(picked) == "string" and gameLookup[picked] then
                selectedGameName = picked
                selectedGameURL  = gameLookup[picked].URL
                selectedGameDesc = gameLookup[picked].Description

                Rayfield:Notify({
                    Title   = "Selected",
                    Content = "Game: " .. selectedGameName .. "\n" .. (selectedGameDesc or ""),
                    Duration = 3,
                    Image   = "info",
                })
            end
        end,
    })

    GameTab:CreateButton({
        Name = "🚀 Execute",
        Callback = function()
            if not selectedGameName or not selectedGameURL or selectedGameURL == "" then
                Rayfield:Notify({
                    Title   = "No Game Selected",
                    Content = "Please select a game from the dropdown first.",
                    Duration = 3,
                    Image   = "alert-circle",
                })
                return
            end

            Rayfield:Notify({
                Title   = "💎 Executing",
                Content = "Loading " .. selectedGameName .. " script...",
                Duration = 4,
                Image   = "download",
            })

            local execOk, execErr = pcall(function()
                loadstring(game:HttpGet(selectedGameURL))()
            end)

            if not execOk then
                Rayfield:Notify({
                    Title   = "Execution Error",
                    Content = "Failed to load " .. selectedGameName .. ":\n" .. tostring(execErr),
                    Duration = 6,
                    Image   = "alert-triangle",
                })
                warn("[Amethyst Hub] Game script error (" .. selectedGameName .. "): " .. tostring(execErr))
            else
                Rayfield:Notify({
                    Title   = "Success",
                    Content = selectedGameName .. " script loaded successfully!",
                    Duration = 3,
                    Image   = "check-circle",
                })
            end
        end,
    })
else
    GameTab:CreateLabel("⚠️ No game scripts loaded — check your connection.")
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 10: TAB — SETTINGS
-- ══════════════════════════════════════════════════════════════

local SettingsTab = Window:CreateTab("Settings", "settings")

-- Amethyst Watermark
local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "AmethystWatermark"
WatermarkGui.ResetOnSpawn = false
WatermarkGui.IgnoreGuiInset = true
WatermarkGui.DisplayOrder = 998

pcall(function()
    WatermarkGui.Parent = guiParent
end)
if not WatermarkGui.Parent then
    WatermarkGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local WatermarkLabel = Instance.new("TextLabel")
WatermarkLabel.Name = "WatermarkLabel"
WatermarkLabel.AnchorPoint = Vector2.new(1, 1)
WatermarkLabel.Position = UDim2.new(1, -12, 1, -8)
WatermarkLabel.Size = UDim2.new(0, 180, 0, 24)
WatermarkLabel.BackgroundTransparency = 1
WatermarkLabel.Text = "💎 Amethyst Hub v4.0"
WatermarkLabel.TextColor3 = COLORS.Outline
WatermarkLabel.TextTransparency = 0.35
WatermarkLabel.Font = Enum.Font.GothamBold
WatermarkLabel.TextSize = 13
WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Right
WatermarkLabel.Parent = WatermarkGui

WatermarkGui.Enabled = true

SettingsTab:CreateToggle({
    Name          = "Show Amethyst Watermark",
    CurrentValue  = true,
    Flag          = "AmethystWatermarkToggle",
    Callback = function(state)
        WatermarkGui.Enabled = state
    end,
})

SettingsTab:CreateDivider()

SettingsTab:CreateButton({
    Name = "🗑️ Destroy UI",
    Callback = function()
        Rayfield:Notify({
            Title   = "Goodbye!",
            Content = "Amethyst Hub UI destroyed. Re-execute the script to reload.",
            Duration = 3,
            Image   = "log-out",
        })

        task.wait(0.5)

        pcall(function()
            WatermarkGui:Destroy()
        end)

        pcall(function()
            Rayfield:Destroy()
        end)

        getgenv().AmethystLoaded = false
    end,
})

-- ══════════════════════════════════════════════════════════════
-- SECTION 11: FINAL WELCOME NOTIFICATION
-- ══════════════════════════════════════════════════════════════

Rayfield:Notify({
    Title   = "💎 Amethyst Hub",
    Content = "Welcome, " .. PlayerName .. "! Hub loaded successfully.",
    Duration = 4,
    Image   = "gem",
})
