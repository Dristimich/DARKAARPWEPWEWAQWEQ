getgenv().AutoFarm = getgenv().AutoFarm or {}
getgenv().AutoFarm.Enabled = false
getgenv().AutoFarm.Theme = getgenv().AutoFarm.Theme or "Dark"

-- Базовые координаты
getgenv().AutoFarm.Coords = getgenv().AutoFarm.Coords or {
    Start = nil, Skip = nil,
    Unit1 = nil, Unit2 = nil, Unit3 = nil, -- Ученый, Мех, Титан
    Upgrade = nil, Sell = nil
}

-- Массивы точек установки на карте
getgenv().AutoFarm.Spots = getgenv().AutoFarm.Spots or {
    Sci = {}, Mech = {}, Titan = {}
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local fileName = "NightmareMacro_Config.txt"

-- ==================== СИСТЕМА СОХРАНЕНИЯ ====================
local function loadPositions()
    if isfile and readfile and isfile(fileName) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(fileName)) end)
        if success and data then
            getgenv().AutoFarm.Coords = data.Coords or getgenv().AutoFarm.Coords
            getgenv().AutoFarm.Spots = data.Spots or getgenv().AutoFarm.Spots
            getgenv().AutoFarm.Theme = data.Theme or "Dark"
        end
    end
end

local function savePositions()
    local data = {
        Coords = getgenv().AutoFarm.Coords,
        Spots = getgenv().AutoFarm.Spots,
        Theme = getgenv().AutoFarm.Theme
    }
    if writefile then writefile(fileName, HttpService:JSONEncode(data)) end
end

loadPositions()

-- ==================== THEMES ====================
local Themes = {
    Dark = {Main = Color3.fromRGB(30,30,30), Top = Color3.fromRGB(20,20,20), Button = Color3.fromRGB(60,60,60)},
    Blood = {Main = Color3.fromRGB(35,10,10), Top = Color3.fromRGB(25,5,5), Button = Color3.fromRGB(70,20,20)},
    Ocean = {Main = Color3.fromRGB(10,25,40), Top = Color3.fromRGB(5,20,35), Button = Color3.fromRGB(20,60,90)}
}

-- ==================== GUI ====================
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 350)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Themes.Dark.Main
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 28)
titleBar.BackgroundColor3 = Themes.Dark.Top
titleBar.Text = "Macro Farm | Nightmare"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.TextSize = 15
titleBar.Font = Enum.Font.SourceSansBold
titleBar.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 22)
statusLabel.Position = UDim2.new(0, 10, 0, 30)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ожидание..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 24)
toggle.Position = UDim2.new(0, 10, 0, 55)
toggle.BackgroundColor3 = getgenv().AutoFarm.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
toggle.Text = getgenv().AutoFarm.Enabled and "МАКРОС ВКЛЮЧЕН" or "МАКРОС ВЫКЛЮЧЕН"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.TextSize = 14
toggle.Font = Enum.Font.SourceSansBold
toggle.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -90)
scroll.Position = UDim2.new(0, 5, 0, 85)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 380)
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local function createBtn(text, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 24)
    btn.BackgroundColor3 = Themes.Dark.Button
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = parent
    return btn
end

local function updateStatus(text)
    statusLabel.Text = text
end

local function calibrateCoord(name, key)
    updateStatus("Кликни на экран для: " .. name)
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            getgenv().AutoFarm.Coords[key] = {X = input.Position.X, Y = input.Position.Y}
            savePositions()
            updateStatus(name .. " сохранено!")
            connection:Disconnect()
        end
    end)
end

local function calibrateSpot(name, listKey)
    updateStatus("Кликни на карту для установки: " .. name)
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            table.insert(getgenv().AutoFarm.Spots[listKey], {X = input.Position.X, Y = input.Position.Y})
            savePositions()
            updateStatus(name .. " добавлена! (Всего: " .. #getgenv().AutoFarm.Spots[listKey] .. ")")
            connection:Disconnect()
        end
    end)
end

createBtn("Задать [Start]", scroll).MouseButton1Click:Connect(function() calibrateCoord("Start", "Start") end)
createBtn("Задать [Skip]", scroll).MouseButton1Click:Connect(function() calibrateCoord("Skip", "Skip") end)
createBtn("Слот 1 [Ученый]", scroll).MouseButton1Click:Connect(function() calibrateCoord("Слот Ученого", "Unit1") end)
createBtn("Слот 2 [Мех]", scroll).MouseButton1Click:Connect(function() calibrateCoord("Слот Меха", "Unit2") end)
createBtn("Слот 3 [Титан TV]", scroll).MouseButton1Click:Connect(function() calibrateCoord("Слот Титана", "Unit3") end)
createBtn("Кнопка [Upgrade]", scroll).MouseButton1Click:Connect(function() calibrateCoord("Upgrade", "Upgrade") end)
createBtn("Кнопка [Sell]", scroll).MouseButton1Click:Connect(function() calibrateCoord("Sell", "Sell") end)
createBtn("+ Точка для Ученого на карте", scroll).MouseButton1Click:Connect(function() calibrateSpot("Ученый", "Sci") end)
createBtn("+ Точка для Меха на карте", scroll).MouseButton1Click:Connect(function() calibrateSpot("Мех", "Mech") end)
createBtn("+ Точка для Титана на карте", scroll).MouseButton1Click:Connect(function() calibrateSpot("Титан", "Titan") end)

createBtn("Очистить все точки карты", scroll).MouseButton1Click:Connect(function()
    getgenv().AutoFarm.Spots = {Sci = {}, Mech = {}, Titan = {}}
    savePositions()
    updateStatus("Точки карты очищены!")
end)

toggle.MouseButton1Click:Connect(function()
    getgenv().AutoFarm.Enabled = not getgenv().AutoFarm.Enabled
    toggle.Text = getgenv().AutoFarm.Enabled and "МАКРОС ВКЛЮЧЕН" or "МАКРОС ВЫКЛЮЧЕН"
    toggle.BackgroundColor3 = getgenv().AutoFarm.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

-- ==================== МАКРОС ИГРЫ ====================
local function click(pos)
    if pos then
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
        task.wait(0.2)
    end
end

local function placeUnit(slotCoord, spotCoord)
    click(slotCoord) -- Выбираем юнита
    task.wait(0.2)
    click(spotCoord) -- Кликаем на карту
    task.wait(0.5)
end

local function upgradeUnit(spotCoord)
    click(spotCoord) -- Выделяем юнита
    task.wait(0.2)
    click(getgenv().AutoFarm.Coords.Upgrade) -- Жмем апгрейд
    task.wait(0.2)
    -- Кликаем куда-то в пустоту, чтобы снять выделение (можно использовать координату Start или просто в угол)
    click({X = 10, Y = 10}) 
end

local function sellUnit(spotCoord)
    click(spotCoord)
    task.wait(0.2)
    click(getgenv().AutoFarm.Coords.Sell)
    task.wait(0.2)
    click({X = 10, Y = 10})
end

local function getWaveNumber()
    local topFrame = player.PlayerGui:FindFirstChild("Match") and player.PlayerGui.Match:FindFirstChild("TopFrame")
    if topFrame and topFrame:FindFirstChild("WaveNumber") then
        local text = topFrame.WaveNumber.Text
        local num = string.match(text, "%d+")
        if num then return tonumber(num) end
    end
    return 0
end

local function isInLobby()
    local lifts = Workspace:FindFirstChild("Lifts")
    return lifts and lifts:FindFirstChild("ToiletHQ") ~= nil
end

-- ==================== ГЛАВНЫЙ ЦИКЛ ====================
task.spawn(function()
    local lastWave = 0
    local sciIndex = 1
    local mechIndex = 1
    local titanIndex = 1
    local waveActionDone = false

    while true do
        task.wait(1)
        if not getgenv().AutoFarm.Enabled then continue end

        if isInLobby() then
            updateStatus("Лобби: Заход в ToiletHQ...")
            lastWave = 0
            sciIndex = 1
            mechIndex = 1
            titanIndex = 1
            
            local lifts = Workspace:FindFirstChild("Lifts")
            if lifts and lifts:FindFirstChild("ToiletHQ") then
                player.Character.HumanoidRootPart.CFrame = lifts.ToiletHQ:GetPivot() + Vector3.new(0, 9, 0)
                task.wait(3)
                click(getgenv().AutoFarm.Coords.Start)
                task.wait(10) -- Ждем загрузки матча
            end
        else
            -- В ИГРЕ
            local currentWave = getWaveNumber()
            updateStatus("В катке. Текущая волна: " .. tostring(currentWave))
            
            if currentWave >= 50 then
                updateStatus("ПОБЕДА! ДОШЛИ ДО 50 ВОЛНЫ")
                print("====================================")
                print("[MACRO LOG] ДОСТИГНУТА ВОЛНА 50!")
                print("Скрипт успешно отработал всю логику.")
                print("====================================")
                task.wait(10)
                continue
            end

            -- Срабатывает 1 раз при смене волны
            if currentWave ~= lastWave and currentWave > 0 then
                lastWave = currentWave
                waveActionDone = false
                updateStatus("Выполняю логику волны: " .. tostring(currentWave))
            end

            -- ЛОГИКА ВОЛН
            if currentWave > 0 and not waveActionDone then
                local spots = getgenv().AutoFarm.Spots
                local coords = getgenv().AutoFarm.Coords

                if currentWave == 1 then
                    click(coords.Skip) -- Нажимаем скип 1 раз
                    if spots.Sci[1] then placeUnit(coords.Unit1, spots.Sci[1]) end
                    if spots.Sci[2] then placeUnit(coords.Unit1, spots.Sci[2]) end
                    sciIndex = 3
                    waveActionDone = true

                elseif currentWave == 2 then
                    if spots.Sci[sciIndex] then placeUnit(coords.Unit1, spots.Sci[sciIndex]); sciIndex = sciIndex + 1 end
                    if spots.Sci[sciIndex] then placeUnit(coords.Unit1, spots.Sci[sciIndex]); sciIndex = sciIndex + 1 end
                    waveActionDone = true

                elseif currentWave == 3 or currentWave == 7 or currentWave == 8 or currentWave == 23 then
                    -- Ничего не делаем, копим
                    waveActionDone = true

                elseif currentWave == 4 then
                    if spots.Mech[mechIndex] then placeUnit(coords.Unit2, spots.Mech[mechIndex]); mechIndex = mechIndex + 1 end
                    waveActionDone = true

                elseif currentWave == 5 or currentWave == 9 or currentWave == 11 then
                    -- 1 раз качаем Меха (первого)
                    if spots.Mech[1] then upgradeUnit(spots.Mech[1]) end
                    waveActionDone = true

                elseif currentWave == 6 then
                    if spots.Mech[1] then upgradeUnit(spots.Mech[1]) end
                    if spots.Sci[1] then upgradeUnit(spots.Sci[1]) end
                    waveActionDone = true

                elseif currentWave == 15 or currentWave == 17 or currentWave == 19 then
                    if spots.Mech[mechIndex] then placeUnit(coords.Unit2, spots.Mech[mechIndex]); mechIndex = mechIndex + 1 end
                    -- Качаем как можем: оставляем waveActionDone = false, чтобы в else блоке ниже шел спам апгрейда
                    waveActionDone = true 

                elseif currentWave == 22 then
                    if spots.Titan[titanIndex] then placeUnit(coords.Unit3, spots.Titan[titanIndex]); titanIndex = titanIndex + 1 end
                    waveActionDone = true

                elseif currentWave == 25 then
                    if spots.Mech[mechIndex] then placeUnit(coords.Unit2, spots.Mech[mechIndex]); mechIndex = mechIndex + 1 end
                    if spots.Mech[mechIndex] then placeUnit(coords.Unit2, spots.Mech[mechIndex]); mechIndex = mechIndex + 1 end
                    waveActionDone = true

                elseif currentWave == 28 then
                    -- Ставим много Мехов
                    for i = 1, 4 do
                        if spots.Mech[mechIndex] then 
                            placeUnit(coords.Unit2, spots.Mech[mechIndex])
                            mechIndex = mechIndex + 1 
                        end
                    end
                    waveActionDone = true

                elseif currentWave == 34 then
                    -- Волна 33 закончилась, начало 34 (продаем фермы)
                    for _, sciSpot in ipairs(spots.Sci) do
                        sellUnit(sciSpot)
                        task.wait(0.5)
                    end
                    if spots.Titan[titanIndex] then placeUnit(coords.Unit3, spots.Titan[titanIndex]); titanIndex = titanIndex + 1 end
                    waveActionDone = true

                elseif currentWave == 38 or currentWave == 39 then
                    if spots.Titan[titanIndex] then placeUnit(coords.Unit3, spots.Titan[titanIndex]); titanIndex = titanIndex + 1 end
                    waveActionDone = true

                else
                    waveActionDone = true
                end
            end

            -- ПОСТОЯННЫЕ ДЕЙСТВИЯ (СПАМ АПГРЕЙДОВ В ТЕЧЕНИЕ ВОЛНЫ)
            if waveActionDone then
                local spots = getgenv().AutoFarm.Spots
                -- Если волна подразумевает постоянную прокачку (качаем как можем по кд)
                if currentWave == 10 or currentWave == 12 or currentWave == 13 or currentWave == 14 or currentWave == 21 then
                    -- Качаем ученых
                    for i = 1, sciIndex - 1 do
                        if spots.Sci[i] then upgradeUnit(spots.Sci[i]) end
                    end
                elseif currentWave == 15 or currentWave == 16 or currentWave == 17 or currentWave == 18 or currentWave == 19 or currentWave == 20 or currentWave == 25 or (currentWave >= 29 and currentWave <= 33) then
                    -- Качаем Мехов
                    for i = 1, mechIndex - 1 do
                        if spots.Mech[i] then upgradeUnit(spots.Mech[i]) end
                    end
                    -- В 18 волне 1 раз качаем ученых (сделаем это костылем в начале спама)
                    if currentWave == 18 and not _G.Wave18SciDone then
                        if spots.Sci[1] then upgradeUnit(spots.Sci[1]) end
                        _G.Wave18SciDone = true
                    end
                elseif currentWave == 24 or currentWave == 26 or currentWave == 27 or (currentWave >= 34 and currentWave <= 50) then
                    -- Качаем Титанов
                    for i = 1, titanIndex - 1 do
                        if spots.Titan[i] then upgradeUnit(spots.Titan[i]) end
                    end
                end
            end

            task.wait(1)
        end
    end
end)
