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

local endpoint = SERVER .. "/getcmd/" .. username

print("[CMD LISTENER] Started for:", username)

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
	local placeName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
	local playerCount = #Players:GetPlayers()
	local maxPlayers = Players.MaxPlayers

	local url = string.format(
		"%s/roblox/info?user=%s&map=%s&players=%d&max=%d&token=%s",
		SERVER,
		HttpService:UrlEncode(username),
		HttpService:UrlEncode(placeName),
		playerCount,
		maxPlayers,
		HttpService:UrlEncode(BOT_TOKEN)
	)

	pcall(function()
		HttpService:GetAsync(url)
	end)

	debug("Info sent to server")
end

--==========================
--  SEND PLAYER LIST → SERVER
--==========================
local function sendPlayerList()
	local list = {}
	for _, pl in ipairs(Players:GetPlayers()) do
		table.insert(list, pl.Name)
	end

	local url = string.format(
		"%s/roblox/playerlist?user=%s&list=%s&token=%s",
		SERVER,
		HttpService:UrlEncode(username),
		HttpService:UrlEncode(table.concat(list, ",")),
		HttpService:UrlEncode(BOT_TOKEN)
	)

	pcall(function()
		HttpService:GetAsync(url)
	end)

	debug("Player list sent to server")
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

	local cmd = HttpService:JSONDecode(response)

	if cmd.action == "none" then
		continue
	end

	debug("Command received: " .. cmd.action)

	if cmd.action == "kick" then
		kick(cmd.reason)

	elseif cmd.action == "alert" then
		alert(cmd.message)

	elseif cmd.action == "srvhop" then
		hop()

	elseif cmd.action == "info" then
		sendInfo()

	elseif cmd.action == "playerlist" then
		sendPlayerList()
	end
end
