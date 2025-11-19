--// VINZZ ADMIN PANEL (LEGAL EDITION)
--// Buat game pribadi / latihan scripting

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

--// FUNCTION: DRAGGING UI
local function MakeDraggable(topbar, frame)
    local dragging = false
    local dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

--// MAIN SCREEN GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

--// TOGGLE BUTTON
local toggleBtn = Instance.new("ImageButton", gui)
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 15, 0.5, -20)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Image = "rbxassetid://17273376262" -- NEXT.JS LOGO

--// MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 520, 0, 330)
main.Position = UDim2.new(0.5, -260, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(25, 30, 70)
main.Visible = false

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 10)

--// TOPBAR FOR DRAGGING
local topbar = Instance.new("Frame", main)
topbar.Size = UDim2.new(1, 0, 0, 32)
topbar.BackgroundColor3 = Color3.fromRGB(20, 25, 60)
Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 8)

MakeDraggable(topbar, main)

--// SIDEBAR
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 120, 1, -32)
sidebar.Position = UDim2.new(0, 0, 0, 32)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 20, 50)
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

--// MAIN PANEL
local panel = Instance.new("ScrollingFrame", main)
panel.Size = UDim2.new(1, -130, 1, -40)
panel.Position = UDim2.new(0, 130, 0, 38)
panel.BackgroundColor3 = Color3.fromRGB(30, 40, 90)
panel.CanvasSize = UDim2.new(0, 0, 2, 0)
panel.ScrollBarThickness = 6
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local layout = Instance.new("UIListLayout", panel)
layout.Padding = UDim.new(0, 5)

--// BUTTON MAKER
local function CreateBtn(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(50, 80, 170)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Text = text
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

--// TABS
local tabs = {
    Home = Instance.new("TextButton"),
    Movement = Instance.new("TextButton"),
}

local function StyleTab(btn, name)
    btn.Parent = sidebar
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 80, 180)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Text = name
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
end

StyleTab(tabs.Home, "Home")
StyleTab(tabs.Movement, "Movement")

--// TAB SWITCHER
local function OpenTab(name)
    for _, c in pairs(panel:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
    Instance.new("UIListLayout", panel).Padding = UDim.new(0, 5)

    if name == "Home" then
        -- SELF KICK
        local b1 = CreateBtn("Kick Self")
        b1.Parent = panel
        b1.MouseButton1Click:Connect(function()
            player:Kick("You have been kicked by Admin (Vinzz Test Kick)")
        end)

        -- SERVER HOP
        local b2 = CreateBtn("Server Hop")
        b2.Parent = panel
        b2.MouseButton1Click:Connect(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)

    elseif name == "Movement" then
        -- FLY TOGGLE
        local flying = false
        local speed = 50

        local flyBtn = CreateBtn("Toggle Fly")
        flyBtn.Parent = panel

        flyBtn.MouseButton1Click:Connect(function()
            flying = not flying
            if flying then
                local body = Instance.new("BodyVelocity", player.Character:WaitForChild("HumanoidRootPart"))
                body.Velocity = Vector3.new(0, 0, 0)
                body.MaxForce = Vector3.new(99999, 99999, 99999)
                body.Name = "VinzzFly"

                while flying do
                    task.wait()
                    local move = Vector3.zero
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then move = move + player.Character.HumanoidRootPart.CFrame.LookVector end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then move = move - player.Character.HumanoidRootPart.CFrame.LookVector end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then move = move - player.Character.HumanoidRootPart.CFrame.RightVector end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then move = move + player.Character.HumanoidRootPart.CFrame.RightVector end

                    body.Velocity = move * speed
                end

                body:Destroy()
            end
        end)

        -- SLIDER SPEED (simple)
        local slider = Instance.new("TextButton", panel)
        slider.Size = UDim2.new(1, -20, 0, 40)
        slider.BackgroundColor3 = Color3.fromRGB(70, 100, 200)
        slider.Text = "Fly Speed: "..speed
        slider.Font = Enum.Font.GothamBold
        slider.TextColor3 = Color3.white
        slider.TextSize = 16
        Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 8)

        slider.MouseButton1Click:Connect(function()
            speed = speed + 10
            if speed > 200 then speed = 10 end
            slider.Text = "Fly Speed: "..speed
        end)
    end
end

-- Default tab
OpenTab("Home")

tabs.Home.MouseButton1Click:Connect(function() OpenTab("Home") end)
tabs.Movement.MouseButton1Click:Connect(function() OpenTab("Movement") end)

-- TOGGLE GUI
toggleBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)
