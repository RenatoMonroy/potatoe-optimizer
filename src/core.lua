-- PotatoeOptimizer v1.0
-- Aplica la configuración de bajo consumo al iniciar sesión y en cada /reload.
-- Comando manual: /potato

local PREFIX = "|cff00ff00[PotatoeOptimizer]|r "

-- Lista ordenada de {cvar, valor}
local SETTINGS = {
    { "graphicsQuality",       "1" },
    { "RenderScale",           "0.75" },
    { "volumeFog",             "0" },
    { "maxLightDist",          "0" },
    { "weatherDensity",        "0" },
    { "shadowMode",            "0" },
}

local SetCVarSafe = (C_CVar and C_CVar.SetCVar) or SetCVar
local GetCVarSafe = (C_CVar and C_CVar.GetCVar) or GetCVar

local function Print(msg)
    print(PREFIX .. msg)
end

-- Aplica todos los CVars. Cada uno va protegido: si uno falla, los demás siguen.
local function ApplySettings()
    local applied, failed = 0, {}

    for _, entry in ipairs(SETTINGS) do
        local name, value = entry[1], entry[2]
        local ok, err = pcall(function()
            if GetCVarSafe(name) == nil then
                error("CVar no disponible en este cliente", 0)
            end
            SetCVarSafe(name, value)
        end)

        if ok then
            applied = applied + 1
        else
            failed[#failed + 1] = name .. " (" .. tostring(err) .. ")"
        end
    end

    return applied, failed
end

local function Run()
    local ok, applied, failed = pcall(ApplySettings)
    if not ok then
        Print("|cffff0000Error inesperado:|r " .. tostring(applied))
        return
    end

    if #failed == 0 then
        Print("Configuración optimizada aplicada (" .. applied .. "/" .. #SETTINGS .. ").")
    else
        Print("Aplicada parcialmente (" .. applied .. "/" .. #SETTINGS .. "). No se pudo:")
        for _, line in ipairs(failed) do
            Print("  - " .. line)
        end
    end
end

-- PLAYER_LOGIN se dispara al entrar al juego y también después de cada /reload.
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    Run()
    self:UnregisterEvent(event)
end)

SLASH_POTATOEOPTIMIZER1 = "/potato"
SlashCmdList["POTATOEOPTIMIZER"] = Run