local _, ns = ...
local shared = ns.NotesShared
local module = shared and shared.module
if not shared or not module then return end

local constants = shared.constants
local helpers = shared.helpers
local CreateSolidTexture = helpers.CreateSolidTexture
local CreateBackdropFrame = helpers.CreateBackdropFrame

local HOME_BUTTON_WIDTH = constants.HOME_BUTTON_WIDTH
local HOME_BUTTON_HEIGHT = constants.HOME_BUTTON_HEIGHT
local HOME_HEADER_BUTTON_SPACING = constants.HOME_HEADER_BUTTON_SPACING
local HOME_LIST_BORDER_COLOR = constants.HOME_LIST_BORDER_COLOR
local NOTE_TAB_SIDE_INSET = constants.NOTE_TAB_SIDE_INSET
local NOTE_TAB_BOTTOM_INSET = constants.NOTE_TAB_BOTTOM_INSET
local NOTE_TAB_TOP_ROW_TOP_OFFSET = constants.NOTE_TAB_TOP_ROW_TOP_OFFSET
local NOTE_TAB_TOP_ROW_HEIGHT = constants.NOTE_TAB_TOP_ROW_HEIGHT
local NOTE_TAB_TOP_ROW_TO_BODY_GAP = constants.NOTE_TAB_TOP_ROW_TO_BODY_GAP
local NOTE_TAB_TOP_CLOSE_BUTTON_SIZE = constants.NOTE_TAB_TOP_CLOSE_BUTTON_SIZE
local NOTE_TAB_TOP_CLOSE_BUTTON_RIGHT_INSET = constants.NOTE_TAB_TOP_ROW_CLOSE_BUTTON_RIGHT_INSET
local NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_LEFT = constants.NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_LEFT
local NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_RIGHT = constants.NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_RIGHT
local NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_TOP = constants.NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_TOP
local NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_BOTTOM = constants.NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_BOTTOM
local NOTE_TAB_FIELD_INNER_X = constants.NOTE_TAB_FIELD_INNER_X
local NOTE_TAB_FIELD_INNER_Y = constants.NOTE_TAB_FIELD_INNER_Y
local NOTE_TAB_BODY_BACKGROUND_ATLAS = constants.NOTE_TAB_BODY_BACKGROUND_ATLAS
local NOTE_TAB_BODY_BACKGROUND_COLOR = constants.NOTE_TAB_BODY_BACKGROUND_COLOR
local NOTE_TAB_BODY_BACKGROUND_FALLBACK_COLOR = constants.NOTE_TAB_BODY_BACKGROUND_FALLBACK_COLOR

function module:IsOptionsTabActive()
    return self.runtime and self.runtime.activeTabKey == "options"
end

function module:IsOptionsTab(tab)
    return tab and tab.key == "options" or false
end

function module:IsAutoSaveEnabled()
    local settings = self:GetSettings()
    local options = settings and settings.options or nil
    return not not (options == nil or options.autoSave ~= false)
end

function module:SetAutoSaveEnabled(enabled)
    local settings = self:GetSettings()
    if not settings then
        return
    end

    settings.options = settings.options or {}
    settings.options.autoSave = enabled and true or false

    if not settings.options.autoSave then
        for _, tab in ipairs(self.runtime and self.runtime.noteSlots or {}) do
            if tab then
                self:CancelNoteAutosave(tab)
                self:CancelNoteTaskToggleAutosave(tab)
            end
        end
    end
end

function module:GetOptionsTab()
    return self.runtime and self.runtime.tabs and self.runtime.tabs.options or nil
end

function module:OpenOptionsTab()
    self:EnsureRuntime()

    local tab = self:GetOptionsTab()
    if not tab then
        return
    end

    tab.assigned = true
    self:RefreshTabLayout()
    self:SelectTab(tab.key)
end

function module:CloseOptionsTab(tab)
    tab = tab or self:GetOptionsTab()
    if not tab then
        return
    end

    tab.assigned = false
    if self.runtime and self.runtime.activeTabKey == tab.key then
        self.runtime.activeTabKey = "home"
    end

    self:RefreshTabLayout()
    self:SelectTab(self.runtime and (self.runtime.activeTabKey or "home") or "home")
end

function module:RequestCloseOptionsTab(tab)
    self:CloseOptionsTab(tab)
end

function module:CreateHomeOptionsButton(panel)
    if not panel or panel.optionsButton then
        return panel and panel.optionsButton or nil
    end

    panel.optionsButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    panel.optionsButton:SetSize(HOME_BUTTON_WIDTH, HOME_BUTTON_HEIGHT)
    panel.optionsButton:SetPoint("RIGHT", panel.importButton, "LEFT", -HOME_HEADER_BUTTON_SPACING, 0)
    panel.optionsButton:SetPoint("TOP", panel.newButton, "TOP", 0, 0)
    panel.optionsButton:SetText("Options")
    panel.optionsButton:SetScript("OnClick", function()
        module:OpenOptionsTab()
    end)

    return panel.optionsButton
end

local function ApplyAutoSaveValue(panel, enabled)
    if not panel then
        return
    end

    panel.autoSaveCheck:SetChecked(enabled and true or false)
    module:SetAutoSaveEnabled(enabled and true or false)
end

function module:CreateOptionsPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()

    panel.topRow = CreateFrame("Frame", nil, panel)
    panel.topRow:SetHeight(NOTE_TAB_TOP_ROW_HEIGHT)
    panel.topRow:SetPoint("TOPLEFT", NOTE_TAB_SIDE_INSET, -NOTE_TAB_TOP_ROW_TOP_OFFSET)
    panel.topRow:SetPoint("TOPRIGHT", -NOTE_TAB_SIDE_INSET, -NOTE_TAB_TOP_ROW_TOP_OFFSET)

    panel.closeButton = CreateFrame("Button", nil, panel.topRow, "UIPanelCloseButton")
    panel.closeButton:SetSize(NOTE_TAB_TOP_CLOSE_BUTTON_SIZE, NOTE_TAB_TOP_CLOSE_BUTTON_SIZE)
    panel.closeButton:ClearAllPoints()
    panel.closeButton:SetPoint("RIGHT", panel.topRow, "RIGHT", -NOTE_TAB_TOP_CLOSE_BUTTON_RIGHT_INSET, 0)
    panel.closeButton:SetHitRectInsets(
        NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_LEFT,
        NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_RIGHT,
        NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_TOP,
        NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_BOTTOM
    )

    panel.titleText = panel.topRow:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    panel.titleText:SetPoint("LEFT", 0, 0)
    panel.titleText:SetPoint("RIGHT", panel.closeButton, "LEFT", -16, 0)
    panel.titleText:SetJustifyH("LEFT")
    panel.titleText:SetJustifyV("MIDDLE")
    panel.titleText:SetText("Options")

    panel.bodyFrame = CreateFrame("Frame", nil, panel)
    panel.bodyFrame:SetPoint("TOPLEFT", NOTE_TAB_SIDE_INSET, -(NOTE_TAB_TOP_ROW_TOP_OFFSET + NOTE_TAB_TOP_ROW_HEIGHT + NOTE_TAB_TOP_ROW_TO_BODY_GAP))
    panel.bodyFrame:SetPoint("TOPRIGHT", -NOTE_TAB_SIDE_INSET, -(NOTE_TAB_TOP_ROW_TOP_OFFSET + NOTE_TAB_TOP_ROW_HEIGHT + NOTE_TAB_TOP_ROW_TO_BODY_GAP))
    panel.bodyFrame:SetPoint("BOTTOMLEFT", NOTE_TAB_SIDE_INSET, NOTE_TAB_BOTTOM_INSET)
    panel.bodyFrame:SetPoint("BOTTOMRIGHT", -NOTE_TAB_SIDE_INSET, NOTE_TAB_BOTTOM_INSET)

    panel.bodyBackground = panel.bodyFrame:CreateTexture(nil, "BACKGROUND")
    panel.bodyBackground:SetAllPoints()
    if NOTE_TAB_BODY_BACKGROUND_ATLAS and NOTE_TAB_BODY_BACKGROUND_ATLAS ~= "" then
        panel.bodyBackground:SetAtlas(NOTE_TAB_BODY_BACKGROUND_ATLAS, true)
        panel.bodyBackground:SetVertexColor(unpack(NOTE_TAB_BODY_BACKGROUND_COLOR))
    else
        panel.bodyBackground:SetTexture("Interface\\Buttons\\WHITE8x8")
        panel.bodyBackground:SetVertexColor(unpack(NOTE_TAB_BODY_BACKGROUND_FALLBACK_COLOR))
    end

    panel.bodyFallbackFill = panel.bodyFrame:CreateTexture(nil, "BACKGROUND", nil, -1)
    panel.bodyFallbackFill:SetAllPoints()
    panel.bodyFallbackFill:SetTexture("Interface\\Buttons\\WHITE8x8")
    panel.bodyFallbackFill:SetVertexColor(unpack(NOTE_TAB_BODY_BACKGROUND_FALLBACK_COLOR))
    panel.bodyFallbackFill:SetShown(not (NOTE_TAB_BODY_BACKGROUND_ATLAS and NOTE_TAB_BODY_BACKGROUND_ATLAS ~= ""))

    panel.contentInset = CreateBackdropFrame(panel.bodyFrame, false)
    panel.contentInset:SetPoint("TOPLEFT", panel.bodyFrame, "TOPLEFT", NOTE_TAB_FIELD_INNER_X, -NOTE_TAB_FIELD_INNER_Y)
    panel.contentInset:SetPoint("BOTTOMRIGHT", panel.bodyFrame, "BOTTOMRIGHT", -NOTE_TAB_FIELD_INNER_X, NOTE_TAB_FIELD_INNER_Y)

    panel.contentFill = CreateSolidTexture(panel.contentInset, "BACKGROUND", { 0, 0, 0, 0.14 })
    panel.contentFill:SetAllPoints()

    if panel.contentInset.SetBackdropColor then
        panel.contentInset:SetBackdropColor(0.04, 0.04, 0.04, 0.16)
    end
    if panel.contentInset.SetBackdropBorderColor then
        panel.contentInset:SetBackdropBorderColor(unpack(HOME_LIST_BORDER_COLOR))
    end

    panel.autoSaveCheck = CreateFrame("CheckButton", nil, panel.contentInset, "UICheckButtonTemplate")
    panel.autoSaveCheck:SetPoint("TOPLEFT", 16, -16)

    panel.autoSaveLabelButton = CreateFrame("Button", nil, panel.contentInset)
    panel.autoSaveLabelButton:SetPoint("LEFT", panel.autoSaveCheck, "RIGHT", 4, 0)
    panel.autoSaveLabelButton:SetPoint("RIGHT", panel.contentInset, "RIGHT", -16, 0)
    panel.autoSaveLabelButton:SetHeight(24)

    panel.autoSaveLabel = panel.autoSaveLabelButton:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    panel.autoSaveLabel:SetAllPoints()
    panel.autoSaveLabel:SetJustifyH("LEFT")
    panel.autoSaveLabel:SetJustifyV("MIDDLE")
    panel.autoSaveLabel:SetText("Enable Autosave")

    panel.autoSaveCheck:SetScript("OnClick", function(check)
        ApplyAutoSaveValue(panel, check:GetChecked())
    end)
    panel.autoSaveLabelButton:SetScript("OnClick", function()
        ApplyAutoSaveValue(panel, not panel.autoSaveCheck:GetChecked())
    end)

    panel.closeButton:SetScript("OnClick", function()
        module:RequestCloseOptionsTab(module:GetOptionsTab())
    end)

    return panel
end

function module:RefreshOptionsPanel(tab)
    local panel = tab and tab.panel
    if not panel or not panel.autoSaveCheck then
        return
    end

    panel.titleText:SetText("Options")
    panel.autoSaveCheck:SetChecked(module:IsAutoSaveEnabled())
end
