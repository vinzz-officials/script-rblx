local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local BASE = "https://YOUR-VERCEL-APP/api"
local TOKEN = "TOKEN-BOT-TELEGRAM"

local ActivePlayers = {} -- player yg aktif GETCMD

-- register player aktif setiap GETCMD
local function markActive(name)
	if not ActivePlayers[name] then
		ActivePlayers[name] = true
	end
end

-- kirim info detail
local function sendInfo(player)
	local payload = {
		user = player.Name,
		map = game.PlaceId,
		mapId = game.PlaceId,
		jobId = game.JobId,
		link = "https://www.roblox.com/games/"..game.PlaceId.."/?privateServerLinkCode="..game.JobId,
		players = #Players:GetPlayers(),
		max = Players.MaxPlayers,
		token = TOKEN
	}

	local qs = "?"
	for k,v in pairs(payload) do
		qs = qs .. k .. "=" .. HttpService:UrlEncode(tostring(v)) .. "&"
	end

	HttpService:GetAsync(BASE.."/roblox/info"..qs)
end

-- kirim playerlist (hanya yg aktif GETCMD)
local function sendPlayerList(player)
	local list = ""

	for name,_ in pairs(ActivePlayers) do
		list = list .. name .. "\n"
	end

	local qs = "?user="..player.Name.."&list="..HttpService:UrlEncode(list).."&token="..TOKEN

	HttpService:GetAsync(BASE.."/roblox/playerlist"..qs)
end

-------------------------------------------
-- LOOP GETCMD
-------------------------------------------

task.spawn(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			local url = BASE.."/getcmd/"..player.Name
			local result

			pcall(function()
				result = HttpService:GetAsync(url)
			end)

			if result then
				local data = HttpService:JSONDecode(result)

				if data.action ~= "none" then
					
					-- tandai player aktif
					markActive(player.Name)

					if data.action == "info" then
						sendInfo(player)

					elseif data.action == "playerlist" then
						sendPlayerList(player)

					elseif data.action == "kick" then
						player:Kick(data.reason or "Kicked")

					elseif data.action == "alert" then
						game.StarterGui:SetCore("SendNotification", {
							Title = "Alert",
							Text = data.message or ""
						})

					elseif data.action == "srvhop" then
						local TeleportService = game:GetService("TeleportService")
						pcall(function()
							TeleportService:Teleport(game.PlaceId, player)
						end)
					end
				end
			end
		end

		task.wait(1)
	end
end)
