-- Этот код создаст синее уведомление в правом нижнем углу экрана игры Roblox
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "GitHub Успех!",
    Text = "Ваш скрипт успешно загрузился и работает!",
    Duration = 10,
    Button1 = "Отлично"
})

-- Дополнительно сделаем персонажа супер-быстрым
local p = game.Players.LocalPlayer
if p and p.Character and p.Character:FindFirstChild("Humanoid") then
    p.Character.Humanoid.WalkSpeed = 60
end

