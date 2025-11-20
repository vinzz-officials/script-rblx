--======================--
--  CONFIG
--======================--

local BOT_TOKEN = "8506651300:AAEuhXSs86i1x_yCznkfefjz8vIz9gGTqmg"
local SERVER = "https://remote-roblox.vercel.app"

--======================--
--  CUSTOM HTTP WRAPPER
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
--  FLAG ACTIVE SCRIPT
--======================--

local flag = Instance.new("BoolValue")
flag.Name = "ScriptConnected"
flag.Parent = Players.LocalPlayer

--======================--
--  UTILS
--======================--

local function debug(msg)
	print("[CMD DEBUG] " .. msg)
end

local function alert(msg)
	debug("Alert received")
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "System Alert",
		Text = msg,
		Duration = 4
	})
end

local function kick(reason)
	debug("Kick executed: " .. reason)
	Players.LocalPlayer:Kick(reason)
end

local function hop()
	debug("Server Hop executed")
	TeleportService:Teleport(game.PlaceId)
end

--==========================
--  SEND INFO → SERVER
--==========================
local function sendInfo()
	local marketplace = game:GetService("MarketplaceService")
	local info = marketplace:GetProductInfo(game.PlaceId)
	local placeName = info.Name or "Unknown"

	local playerCount = #Players:GetPlayers()
	local maxPlayers = Players.MaxPlayers

	local url =
		SERVER .. "/roblox/info"
		.. "?user=" .. HttpService:UrlEncode(username)
		.. "&map=" .. HttpService:UrlEncode(placeName)
		.. "&players=" .. tostring(playerCount)
		.. "&max=" .. tostring(maxPlayers)
		.. "&token=" .. HttpService:UrlEncode(BOT_TOKEN)

	pcall(function()
		HttpService:GetAsync(url)
	end)

	debug("Info sent to server")
end

--==========================
--  MAIN COMMAND LISTENER
--==========================
while true do
	task.wait(2)

	local success, response = pcall(function()
		return HttpService:GetAsync(endpoint)
	end)

	if not success then
		debug("HTTP ERROR: " .. tostring(response))
		continue
	end

	local cmdData
	local ok, decodeErr = pcall(function()
		cmdData = HttpService:JSONDecode(response)
	end)

	if not ok then
		debug("JSON ERROR: " .. tostring(decodeErr))
		continue
	end

	local action = cmdData.action
	if action == "none" or not action then
		continue
	end

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
