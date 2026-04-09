local ADDON_NAME, ns = ...

local SnailNotes = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
ns.SnailNotes = SnailNotes
_G.SnailNotes = SnailNotes
_G.BINDING_NAME_SNAILNOTES_TOGGLE = "Toggle SnailNotes"

SnailNotes.ADDON_NAME = ADDON_NAME

local function DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, entry in pairs(value) do
        copy[key] = DeepCopy(entry)
    end

    return copy
end

local function MergeDefaults(target, defaults)
    if type(defaults) ~= "table" then
        return target
    end

    target = type(target) == "table" and target or {}
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            target[key] = MergeDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end

    return target
end

function SnailNotes:PrintMessage(message)
    self:Print("|cff7fdc7fSnailNotes|r: " .. (message or ""))
end

function SnailNotes:BuildDefaults()
    return DeepCopy(ns.SnailNotesDefaults or {
        profile = {
            enabled = true,
            options = {
                autoSave = true,
            },
            window = {},
            notes = {
                nextId = 1,
                items = {},
            },
        },
    })
end

function SnailNotes:SetupSlashCommands()
    self:RegisterChatCommand("snailnotes", "HandleNotesSlashCommand")
    self:RegisterChatCommand("snotes", "HandleNotesSlashCommand")
end

function SnailNotes:ToggleNotesWindow()
    if self.IsWindowOpen and self:IsWindowOpen() then
        self:CloseWindow()
        return
    end

    self:OpenWindow()
end

function SnailNotes:HandleNotesSlashCommand()
    self:ToggleNotesWindow()
end

function _G.SnailNotes_ToggleBinding()
    local addon = _G.SnailNotes
    if addon and addon.ToggleNotesWindow then
        addon:ToggleNotesWindow()
    end
end

function SnailNotes:InitializeStandaloneAddon()
    local aceDB = LibStub("AceDB-3.0")
    self.db = aceDB:New("SnailNotesDB", self:BuildDefaults(), true)
    self:SetupSlashCommands()
end
