--======================--
--  CONFIG
--======================--

local BOT_TOKEN = "8506651300:AAEuhXSs86i1x_yCznkfefjz8vIz9gGTqmg"
local SERVER = "https://remote-roblox.vercel.app"
local chatId = 7777604508

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

local endpoint = SERVER .. "/getcmd/" .. HttpService:UrlEncode(username)

print("[CMD LISTENER] Started for:", username)

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

--============================================--
--  SEND INFO → DIRECT TELEGRAM API
--============================================--

local function sendInfo()
    local HttpS = game:GetService("HttpService")
    local marketplace = game:GetService("MarketplaceService")
    local info = marketplace:GetProductInfo(game.PlaceId)

    local placeName = info.Name or "Unknown"
    local placeId = game.PlaceId
    local jobId = game.JobId

    local joinLink =
        "https://www.roblox.com/games/"
        .. placeId
        .. "/?privateServerLinkCode="
        .. HttpS:UrlEncode(jobId)

    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    local ping = math.floor(game:GetService("Stats")
        .Network.ServerStatsItem["Data Ping"]:GetValue())

    local exec = (identifyexecutor and identifyexecutor()) or "N/A"

    local message =
        "ℹ️ INFO PLAYER: " .. username .. "\n\n" ..
        "🗺 Map: " .. placeName .. "\n" ..
        "🏷 PlaceId: " .. placeId .. "\n" ..
        "🌀 JobId: " .. jobId .. "\n" ..
        "🔗 Join: " .. joinLink .. "\n\n" ..
        "👥 Players: " .. playerCount .. "/" .. maxPlayers .. "\n" ..
        "📡 Ping: " .. ping .. "ms\n" ..
        "⚙ Executor: " .. exec

    -- BODY TELEGRAM (POST)
    local body = {
        chat_id = tonumber(chatId), -- WAJIB number
        text = message
    }

    local jsonBody = HttpS:JSONEncode(body)

    pcall(function()
        game:HttpPost(
            "https://api.telegram.org/bot" .. BOT_TOKEN .. "/sendMessage",
            jsonBody,
            Enum.HttpContentType.ApplicationJson
        )
    end)

    debug("Info sent via Telegram API (POST)")
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

	elseif action == "info" then
		sendInfo()
	end
end
