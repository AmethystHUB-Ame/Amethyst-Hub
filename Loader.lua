--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║               AMETHYST HUB LOADER v3.0                      ║
    ║          Professional Dynamic Hub with Rayfield UI           ║
    ║                                                              ║
    ║  Features:                                                   ║
    ║   • Animated splash screen with Amethyst branding            ║
    ║   • Remote database fetch from GitHub                        ║
    ║   • Dynamic script gallery built from database categories    ║
    ║   • Custom URL executor                                      ║
    ║   • Mobile-friendly (Delta/Fluxus compatible)                ║
    ║   • Anti-double-load protection                              ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- ══════════════════════════════════════════════════════════════
-- SECTION 0: ANTI-DOUBLE LOAD GUARD
-- Prevents the hub from initializing more than once per session.
-- ══════════════════════════════════════════════════════════════

if getgenv().AmethystLoaded then
    warn("[Amethyst Hub] Already loaded this session. Aborting duplicate execution.")
    return
end
getgenv().AmethystLoaded = true

-- ══════════════════════════════════════════════════════════════
-- SECTION 1: SERVICE REFERENCES & CONSTANTS
-- ══════════════════════════════════════════════════════════════

local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui        = game:GetService("CoreGui")

local LocalPlayer    = Players.LocalPlayer
local PlayerName     = LocalPlayer and LocalPlayer.Name or "Player"

-- Amethyst colour palette
local COLORS = {
    Background     = Color3.fromRGB(35, 10, 50),       -- Deep Amethyst
    Outline        = Color3.fromRGB(180, 100, 255),     -- Lavender glow
    OutlineGlow    = Color3.fromRGB(200, 140, 255),     -- Brighter lavender pulse
    BarBackground  = Color3.fromRGB(55, 20, 75),        -- Muted purple
    BarFill        = Color3.fromRGB(180, 100, 255),     -- Lavender
    TextPrimary    = Color3.fromRGB(230, 200, 255),     -- Light lavender text
    TextSecondary  = Color3.fromRGB(150, 120, 180),     -- Dimmer text
    White          = Color3.fromRGB(255, 255, 255),
    Transparent    = Color3.fromRGB(0, 0, 0),
}

-- Database URL
local DATABASE_URL = "https://raw.githubusercontent.com/AmethystHUB-Ame/Amethyst-Hub/1df06addbd9f8906c80707c4e8476e4aa914988b/Database.lua"

-- ══════════════════════════════════════════════════════════════
-- SECTION 2: UTILITY HELPERS
-- ══════════════════════════════════════════════════════════════

--- Safely creates a tween and plays it, returning the Tween object.
local function tweenPlay(instance, tweenInfo, properties)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

--- Waits for a tween to complete.
local function tweenAndWait(instance, tweenInfo, properties)
    local tween = tweenPlay(instance, tweenInfo, properties)
    tween.Completed:Wait()
    return tween
end

--- Creates a rounded UICorner parented to the given instance.
local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

--- Creates a UIStroke for glowing outlines.
local function addStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLORS.Outline
    stroke.Thickness = thickness or 2
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

--- Creates a UIPadding helper.
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
-- The "Amethyst Signature" animated loading screen.
-- ══════════════════════════════════════════════════════════════

local SplashGui = Instance.new("ScreenGui")
SplashGui.Name = "AmethystSplash"
SplashGui.ResetOnSpawn = false
SplashGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SplashGui.IgnoreGuiInset = true
SplashGui.DisplayOrder = 999

-- Try CoreGui first (works on most executors), fall back to PlayerGui
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

-- Main splash card (centered, rounded, initially invisible)
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

-- Logo / Title Text
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

-- Status text (below logo)
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

-- Version tag at the bottom of the card
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "Version"
VersionLabel.AnchorPoint = Vector2.new(0.5, 1)
VersionLabel.Position = UDim2.new(0.5, 0, 0.95, 0)
VersionLabel.Size = UDim2.new(0.5, 0, 0, 14)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v3.0"
VersionLabel.TextColor3 = COLORS.TextSecondary
VersionLabel.TextTransparency = 1
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextSize = 11
VersionLabel.Parent = SplashCard

-- ── Splash Animation Sequence ──

local fastTween  = TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local medTween   = TweenInfo.new(0.6,  Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local barTween   = TweenInfo.new(0.5,  Enum.EasingStyle.Sine,  Enum.EasingDirection.InOut)
local pulseTween = TweenInfo.new(1.2,  Enum.EasingStyle.Sine,  Enum.EasingDirection.InOut, -1, true)

-- Fade in the card
tweenPlay(SplashCard,  medTween, { BackgroundTransparency = 0 })
tweenPlay(splashStroke, medTween, { Transparency = 0 })
tweenPlay(LogoText,     medTween, { TextTransparency = 0 })
tweenPlay(StatusText,   medTween, { TextTransparency = 0 })
tweenPlay(BarBG,        medTween, { BackgroundTransparency = 0 })
tweenPlay(BarFill,      medTween, { BackgroundTransparency = 0 })
tweenAndWait(VersionLabel, medTween, { TextTransparency = 0.4 })

-- Start a pulsing glow on the outline
local glowPulse = tweenPlay(splashStroke, pulseTween, { Color = COLORS.OutlineGlow })

-- Start a gentle pulse on the logo text
local logoPulse = tweenPlay(LogoText, pulseTween, { TextTransparency = 0.25 })

-- Status message cycling with loading bar progression
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

-- Brief hold on the "Welcome" message
task.wait(0.8)

-- Stop the pulse tweens
glowPulse:Cancel()
logoPulse:Cancel()

-- ══════════════════════════════════════════════════════════════
-- SECTION 4: FETCH REMOTE DATABASE
-- ══════════════════════════════════════════════════════════════

local Database = nil
local fetchSuccess, fetchError = pcall(function()
    -- game:HttpGet works on most executors; fall back to request-based methods
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

    -- The database file returns a Lua table via 'return { ... }'
    local loader = loadstring(rawData)
    if loader then
        Database = loader()
    else
        error("Failed to parse database source.")
    end
end)

-- If fetch fails we will still open the UI but show an error notification later
local fetchFailed = not fetchSuccess

if fetchFailed then
    warn("[Amethyst Hub] Database fetch error: " .. tostring(fetchError))
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
-- Amethyst-themed Rayfield window.
-- ══════════════════════════════════════════════════════════════

local Window = Rayfield:CreateWindow({
    Name            = "💎 Amethyst Hub v3.0",
    Icon            = 0,                        -- No icon (text logo is sufficient)
    LoadingEnabled  = false,                     -- We already have our own splash
    ConfigurationSaving = {
        Enabled  = false,
        FileName = "AmethystHub_Config"
    },
    Discord = {
        Enabled  = false,
    },
    KeySystem       = false,
    Theme           = "Amethyst",               -- Rayfield's built-in Amethyst theme
})

-- Show error notification if database fetch failed
if fetchFailed then
    Rayfield:Notify({
        Title   = "Connection Error",
        Content = "Error: Could not connect to Amethyst Database. The Script Gallery will be empty.",
        Duration = 6,
        Image   = "alert-triangle",
    })
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 8: TAB — HOME
-- Version info, welcome message, and Discord link.
-- ══════════════════════════════════════════════════════════════

local HomeTab = Window:CreateTab("Home", "home")

HomeTab:CreateLabel("💎 Amethyst Hub — v3.0")

HomeTab:CreateParagraph({
    Title   = "Welcome, " .. PlayerName .. "!",
    Content = "Amethyst Hub is your all-in-one script loader.\n\n"
            .. "• Browse the Script Gallery to run curated scripts.\n"
            .. "• Use the Executor tab to run scripts from any URL.\n"
            .. "• Customize your experience in Settings.\n\n"
            .. "Stay updated by joining our Discord community!"
})

HomeTab:CreateButton({
    Name = "🔗 Join Discord",
    Callback = function()
        -- Attempt to open the Discord invite link
        -- Replace with your actual invite code
        local discordURL = "https://discord.gg/YourInviteCodeHere"

        Rayfield:Notify({
            Title   = "Discord",
            Content = "Opening Discord invite... If it didn't open, visit:\n" .. discordURL,
            Duration = 5,
            Image   = "message-circle",
        })

        -- Try multiple methods to open the URL (executor compatibility)
        pcall(function()
            if setclipboard then
                setclipboard(discordURL)
            end
        end)

        pcall(function()
            if (syn and syn.request) then
                syn.request({
                    Url    = "http://127.0.0.1:6463/rpc?v=1",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        Origin = "https://discord.com"
                    },
                    Body = game:GetService("HttpService"):JSONEncode({
                        cmd  = "INVITE_BROWSER",
                        nonce = game:GetService("HttpService"):GenerateGUID(false),
                        args = { code = "YourInviteCodeHere" }
                    })
                })
            end
        end)
    end,
})

-- ══════════════════════════════════════════════════════════════
-- SECTION 9: TAB — SCRIPT GALLERY (DYNAMIC)
-- Loops through every category and script in the Database,
-- creating Rayfield sections and buttons automatically.
-- ══════════════════════════════════════════════════════════════

local GalleryTab = Window:CreateTab("Script Gallery", "scroll-text")

if Database and type(Database) == "table" then
    -- Sort category names for consistent ordering
    local categoryNames = {}
    for categoryName, _ in pairs(Database) do
        table.insert(categoryNames, categoryName)
    end
    table.sort(categoryNames)

    for _, categoryName in ipairs(categoryNames) do
        local scripts = Database[categoryName]

        -- Create a section divider / label for each category
        GalleryTab:CreateLabel("📂 " .. categoryName)

        if type(scripts) == "table" then
            for _, scriptEntry in ipairs(scripts) do
                local sName = scriptEntry.Name or scriptEntry["Name"] or "Unnamed Script"
                local sURL  = scriptEntry.URL  or scriptEntry["URL"]  or ""
                local sDesc = scriptEntry.Description or scriptEntry["Description"] or ""

                GalleryTab:CreateButton({
                    Name = "▶ " .. sName,
                    Callback = function()
                        -- Show loading notification
                        Rayfield:Notify({
                            Title   = "Amethyst",
                            Content = "Loading " .. sName .. "...",
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

                -- Show description as a paragraph if available
                if sDesc ~= "" then
                    GalleryTab:CreateParagraph({
                        Title   = "",
                        Content = sDesc,
                    })
                end
            end
        end
    end
else
    GalleryTab:CreateLabel("⚠️ No database loaded — check your connection.")
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 10: TAB — EXECUTOR
-- Text input for a custom script URL and an Execute button.
-- ══════════════════════════════════════════════════════════════

local ExecutorTab = Window:CreateTab("Executor", "terminal")

local customURL = ""

ExecutorTab:CreateParagraph({
    Title   = "Custom Script Executor",
    Content = "Paste a raw script URL below and press Execute to run it."
})

ExecutorTab:CreateInput({
    Name            = "Custom URL",
    CurrentValue    = "",
    PlaceholderText = "https://raw.githubusercontent.com/...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        customURL = text
    end,
})

ExecutorTab:CreateButton({
    Name = "🚀 Execute",
    Callback = function()
        if customURL == nil or customURL == "" then
            Rayfield:Notify({
                Title   = "Executor",
                Content = "Please enter a URL first.",
                Duration = 3,
                Image   = "alert-circle",
            })
            return
        end

        Rayfield:Notify({
            Title   = "Executor",
            Content = "Executing script from URL...",
            Duration = 3,
            Image   = "loader",
        })

        local ok, err = pcall(function()
            loadstring(game:HttpGet(customURL))()
        end)

        if not ok then
            Rayfield:Notify({
                Title   = "Execution Error",
                Content = "Failed:\n" .. tostring(err),
                Duration = 6,
                Image   = "alert-triangle",
            })
        else
            Rayfield:Notify({
                Title   = "Success",
                Content = "Custom script executed successfully!",
                Duration = 3,
                Image   = "check-circle",
            })
        end
    end,
})

-- ══════════════════════════════════════════════════════════════
-- SECTION 11: TAB — SETTINGS
-- Destroy UI button and Amethyst Watermark toggle.
-- ══════════════════════════════════════════════════════════════

local SettingsTab = Window:CreateTab("Settings", "settings")

-- ── Amethyst Watermark ──
-- A subtle "Amethyst Hub v3.0" label anchored at the bottom-right.

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
WatermarkLabel.Text = "💎 Amethyst Hub v3.0"
WatermarkLabel.TextColor3 = COLORS.Outline
WatermarkLabel.TextTransparency = 0.35
WatermarkLabel.Font = Enum.Font.GothamBold
WatermarkLabel.TextSize = 13
WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Right
WatermarkLabel.Parent = WatermarkGui

-- Watermark starts visible (enabled by default)
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

        -- Clean up watermark
        pcall(function()
            WatermarkGui:Destroy()
        end)

        -- Destroy Rayfield window
        pcall(function()
            Rayfield:Destroy()
        end)

        -- Allow re-loading after destroy
        getgenv().AmethystLoaded = false
    end,
})

-- ══════════════════════════════════════════════════════════════
-- SECTION 12: FINAL WELCOME NOTIFICATION
-- ══════════════════════════════════════════════════════════════

Rayfield:Notify({
    Title   = "💎 Amethyst Hub",
    Content = "Welcome, " .. PlayerName .. "! Hub loaded successfully.",
    Duration = 4,
    Image   = "gem",
})

-- ══════════════════════════════════════════════════════════════
-- END OF AMETHYST HUB LOADER
-- ══════════════════════════════════════════════════════════════
