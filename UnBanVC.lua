-- Universal executor compatibility check
local isExecutor = (syn or protectgui or getgenv or getexecutorname)
if not isExecutor then
    warn("This script requires an executor environment")
    return
end

-- Store script references for complete cleanup
local scriptReferences = {
    screenGui = Instance.new("ScreenGui"),
    connections = {}
}

-- Create protected GUI
if syn then
    syn.protect_gui(scriptReferences.screenGui)
elseif protectgui then
    protectgui(scriptReferences.screenGui)
end
scriptReferences.screenGui.Name = "UnbannerVC_GUI"
scriptReferences.screenGui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0.5, -100, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
frame.BackgroundTransparency = 0.15
frame.Active = true
frame.Draggable = true
frame.Parent = scriptReferences.screenGui

-- UI Styling
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 35))
})
gradient.Rotation = 90
gradient.Parent = frame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame

-- Title Text "Unbanner VC"
local titleText = Instance.new("TextLabel")
titleText.Text = "Unbanner VC"
titleText.Size = UDim2.new(0, 120, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamBold
titleText.BackgroundTransparency = 1
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Create Unban VC Button
local unbanButton = Instance.new("TextButton")
unbanButton.Text = "Unban VC"
unbanButton.Size = UDim2.new(0.8, 0, 0, 40)
unbanButton.Position = UDim2.new(0.1, 0, 0.5, -20)
unbanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
unbanButton.TextSize = 16
unbanButton.Font = Enum.Font.GothamSemibold
unbanButton.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
unbanButton.BackgroundTransparency = 0.25
unbanButton.Parent = frame
unbanButton.UICorner = corner:Clone()

-- Voice Chat Unban Functionality
scriptReferences.connections.unbanClick = unbanButton.MouseButton1Click:Connect(function()
    local vcService = game:GetService("VoiceChatService")
    
    -- First try the JoinVoice method
    local success, result = pcall(function()
        return vcService:JoinVoice()
    end)
    
    -- If that fails, try the newer method
    if not success then
        success, result = pcall(function()
            return vcService:RequestJoinForVoiceChatService()
        end)
    end
    
    -- Update button text based on result
    if success then
        unbanButton.Text = "Success!"
        task.wait(2)
        unbanButton.Text = "Unban VC"
    else
        warn("Voice chat join failed:", result)
        unbanButton.Text = "Failed - Try Again"
        task.wait(2)
        unbanButton.Text = "Unban VC"
    end
end)

-- Close Button with full script unload
local closeButton = Instance.new("TextButton")
closeButton.Text = "X"
closeButton.Size = UDim2.new(0, 30, 1, 0)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BackgroundTransparency = 0.3
closeButton.UICorner = corner:Clone()
closeButton.Parent = titleBar

scriptReferences.connections.closeClick = closeButton.MouseButton1Click:Connect(function()
    -- Disconnect all connections
    for _, connection in pairs(scriptReferences.connections) do
        connection:Disconnect()
    end
    
    -- Destroy all GUI elements
    scriptReferences.screenGui:Destroy()
    
    -- Clear references
    for k in pairs(scriptReferences) do
        scriptReferences[k] = nil
    end
    
    -- Additional cleanup if needed
    if _G.UnbannerVC then
        _G.UnbannerVC = nil
    end
end)

warn("Unbanner VC GUI loaded successfully!")
