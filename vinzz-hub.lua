local Http = game:GetService("HttpService")
local Players = game:GetService("Players")

local BASE = "https://remote-roblox.vercel.app"
local TOKEN = "8506651300:AAEuhXSs86i1x_yCznkfefjz8vIz9gGTqmg"

local function sendInfo(player)
	local data = {
		user = player.Name,
		map = game.Name,
		placeId = game.PlaceId,
		jobId = game.JobId,
		link = "https://www.roblox.com/games/"..game.PlaceId.."/?privateServerLinkCode="..game.JobId,
		players = #Players:GetPlayers(),
		max = Players.MaxPlayers,
		ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()),
		fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait()),
		exec = identifyexecutor and identifyexecutor() or "N/A",
		token = TOKEN
	}

	local qs = "?"
	for k, v in pairs(data) do
		qs = qs .. k .. "=" .. Http:UrlEncode(tostring(v)) .. "&"
	end

	Http:GetAsync(BASE.."/roblox/info"..qs)
end

task.spawn(function()
	while true do
		for _, plr in ipairs(Players:GetPlayers()) do
			local raw
			pcall(function()
				raw = Http:GetAsync(BASE.."/getcmd/" .. plr.Name)
			end)

			if raw then
				local cmd = Http:JSONDecode(raw)

				if cmd.action == "info" then
					sendInfo(plr)

				elseif cmd.action == "kick" then
					plr:Kick(cmd.reason or "Kicked")

				elseif cmd.action == "alert" then
					game.StarterGui:SetCore("SendNotification", {
						Title = "Alert",
						Text = cmd.message or ""
					})

				elseif cmd.action == "srvhop" then
					local TS = game:GetService("TeleportService")
					pcall(function()
						TS:Teleport(game.PlaceId, plr)
					end)
				end
			end
		end

		task.wait(1)
	end
end)
