local _, ns = ...
local shared = ns.NotesShared
local module = shared and shared.module
if not shared or not module then return end

local constants = shared.constants
local helpers = shared.helpers
local CreateBackdropFrame = helpers.CreateBackdropFrame
local HexToColorRGB = helpers.HexToColorRGB
local AttachTooltip = helpers.AttachTooltip

local HOME_BUTTON_WIDTH = constants.HOME_BUTTON_WIDTH
local HOME_BUTTON_HEIGHT = constants.HOME_BUTTON_HEIGHT
local HOME_HEADER_BUTTON_SPACING = constants.HOME_HEADER_BUTTON_SPACING
local HOME_LIST_BACKGROUND_HEX = constants.HOME_LIST_BACKGROUND_HEX
local HOME_LIST_BACKGROUND_ALPHA = constants.HOME_LIST_BACKGROUND_ALPHA
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
local HOME_LIST_INNER_SHADOW_ATLAS = "insetshadow"
local HOME_LIST_INNER_SHADOW_ALPHA = 0.85
local HOME_LIST_INNER_SHADOW_INSET = 1
local NOTE_BODY_BORDER_COLOR = { 0.36, 0.36, 0.36, 0.82 }
local NOTE_BODY_BORDER_EDGE_SIZE = 14
local NOTE_BODY_BORDER_INSETS = { left = 4, right = 4, top = 4, bottom = 4 }
local NOTE_BODY_BORDER_OUTSET = 2
local NOTE_BODY_SHADOW_ATLAS = HOME_LIST_INNER_SHADOW_ATLAS
local NOTE_OPTIONS_BODY_SHADOW_ALPHA = HOME_LIST_INNER_SHADOW_ALPHA
local NOTE_OPTIONS_BODY_SHADOW_INSET = HOME_LIST_INNER_SHADOW_INSET
local OPTIONS_SECTION_BUTTON_WIDTH = 96
local OPTIONS_SECTION_BUTTON_HEIGHT = 24
local OPTIONS_SECTION_BUTTON_SPACING = 8
local OPTIONS_SECTION_GENERAL = "general"
local OPTIONS_SECTION_FLOAT = "float"
local OPTIONS_SECTION_REMINDER = "reminder"
local FLOAT_FONT_SCALE_MIN = 70
local FLOAT_FONT_SCALE_MAX = 200
local FLOAT_FONT_SCALE_STEP = 5
local FLOAT_BACKGROUND_ALPHA_MIN = 0
local FLOAT_BACKGROUND_ALPHA_MAX = 100
local FLOAT_BACKGROUND_ALPHA_STEP = 5

local function NormalizeOptionsSectionKey(sectionKey)
    if sectionKey == OPTIONS_SECTION_REMINDER then
        return OPTIONS_SECTION_REMINDER
    end

    if sectionKey == OPTIONS_SECTION_FLOAT then
        return OPTIONS_SECTION_FLOAT
    end

    return OPTIONS_SECTION_GENERAL
end

local function ApplyTooltipBorderToRegion(parent, targetFrame)
    local borderFrame = CreateBackdropFrame(parent, false)
    borderFrame:SetPoint("TOPLEFT", targetFrame, "TOPLEFT", -NOTE_BODY_BORDER_OUTSET, NOTE_BODY_BORDER_OUTSET)
    borderFrame:SetPoint("BOTTOMRIGHT", targetFrame, "BOTTOMRIGHT", NOTE_BODY_BORDER_OUTSET, -NOTE_BODY_BORDER_OUTSET)
    borderFrame:EnableMouse(false)
    if borderFrame.SetBackdrop then
        borderFrame:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = NOTE_BODY_BORDER_EDGE_SIZE,
            insets = NOTE_BODY_BORDER_INSETS,
        })
    end
    if borderFrame.SetBackdropBorderColor then
        borderFrame:SetBackdropBorderColor(unpack(NOTE_BODY_BORDER_COLOR))
    end
    if borderFrame.SetBackdropColor then
        borderFrame:SetBackdropColor(0, 0, 0, 0)
    end
    borderFrame:SetFrameLevel((targetFrame:GetFrameLevel() or 1) + 2)
    return borderFrame
end

local function ApplyInsetShadowToRegion(parent, targetFrame, atlasName, alpha, inset)
    local shadowBounds = CreateFrame("Frame", nil, parent)
    shadowBounds:SetPoint("TOPLEFT", targetFrame, "TOPLEFT", inset, -inset)
    shadowBounds:SetPoint("BOTTOMRIGHT", targetFrame, "BOTTOMRIGHT", -inset, inset)
    shadowBounds:SetFrameLevel((targetFrame:GetFrameLevel() or 1) + 1)
    shadowBounds:EnableMouse(false)

    local shadowTexture = shadowBounds:CreateTexture(nil, "ARTWORK")
    shadowTexture:SetAllPoints()
    shadowTexture:SetAtlas(atlasName, true)
    shadowTexture:SetVertexColor(1, 1, 1, alpha)

    return shadowBounds, shadowTexture
end

local function HideSliderHelperText(slider)
    if not slider or not slider.GetRegions then
        return
    end

    local regions = { slider:GetRegions() }
    for _, region in ipairs(regions) do
        if region and region.GetObjectType and region:GetObjectType() == "FontString" then
            region:SetText("")
            region:Hide()
        end
    end
end

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

function module:GetActiveOptionsSectionKey()
    return NormalizeOptionsSectionKey(self.runtime and self.runtime.optionsSectionKey or nil)
end

function module:SetActiveOptionsSectionKey(sectionKey)
    self:EnsureRuntime()
    local previousSectionKey = NormalizeOptionsSectionKey(self.runtime.optionsSectionKey)
    local nextSectionKey = NormalizeOptionsSectionKey(sectionKey)
    if previousSectionKey == OPTIONS_SECTION_REMINDER and nextSectionKey ~= OPTIONS_SECTION_REMINDER and self.HideReminderEditWindow then
        self:HideReminderEditWindow()
    end
    self.runtime.optionsSectionKey = nextSectionKey
end

function module:OpenOptionsTab(sectionKey)
    self:EnsureRuntime()
    self:SetActiveOptionsSectionKey(sectionKey)

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

    if self.HideReminderEditWindow then
        self:HideReminderEditWindow()
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

local function RefreshFloatFontScaleValueText(panel, scale)
    if panel and panel.floatFontScaleValue then
        panel.floatFontScaleValue:SetText(string.format("%d%%", math.floor(((tonumber(scale) or 1) * 100) + 0.5)))
    end
end

local function RefreshFloatBackgroundAlphaValueText(panel, alphaPercent)
    if panel and panel.floatBackgroundAlphaValue then
        panel.floatBackgroundAlphaValue:SetText(string.format("%d%%", math.floor((tonumber(alphaPercent) or 0) + 0.5)))
    end
end

local function RefreshReminderFontScaleValueText(panel, scale)
    if panel and panel.reminderFontScaleValue then
        panel.reminderFontScaleValue:SetText(string.format("%d%%", math.floor(((tonumber(scale) or 1) * 100) + 0.5)))
    end
end

local function RefreshReminderBackgroundAlphaValueText(panel, alphaPercent)
    if panel and panel.reminderBackgroundAlphaValue then
        panel.reminderBackgroundAlphaValue:SetText(string.format("%d%%", math.floor((tonumber(alphaPercent) or 0) + 0.5)))
    end
end

local function ApplyFloatTexturesValue(panel, enabled)
    if not panel then
        return
    end

    local normalizedEnabled = enabled == true
    panel.floatTexturesCheck:SetChecked(normalizedEnabled)
    module:SetFloatTexturesEnabled(normalizedEnabled)
end

local function ApplyFloatBorderValue(panel, enabled)
    if not panel then
        return
    end

    local normalizedEnabled = enabled == true
    panel.floatBorderCheck:SetChecked(normalizedEnabled)
    module:SetFloatBorderEnabled(normalizedEnabled)
end

local function ApplyFloatFontScaleValue(panel, scale)
    if not panel or not panel.floatFontScaleSlider then
        return
    end

    local normalizedPercent = math.floor(math.max(FLOAT_FONT_SCALE_MIN, math.min(FLOAT_FONT_SCALE_MAX, tonumber(scale) or 100)) + 0.5)
    panel.updatingFloatFontScale = true
    panel.floatFontScaleSlider:SetValue(normalizedPercent)
    panel.updatingFloatFontScale = nil
    RefreshFloatFontScaleValueText(panel, normalizedPercent / 100)
    module:SetFloatFontScale(normalizedPercent / 100)
end

local function ApplyFloatBackgroundAlphaValue(panel, alphaPercent)
    if not panel or not panel.floatBackgroundAlphaSlider then
        return
    end

    local normalizedPercent = math.floor(math.max(FLOAT_BACKGROUND_ALPHA_MIN, math.min(FLOAT_BACKGROUND_ALPHA_MAX, tonumber(alphaPercent) or 0)) + 0.5)
    panel.updatingFloatBackgroundAlpha = true
    panel.floatBackgroundAlphaSlider:SetValue(normalizedPercent)
    panel.updatingFloatBackgroundAlpha = nil
    RefreshFloatBackgroundAlphaValueText(panel, normalizedPercent)
    module:SetFloatBackgroundAlpha(normalizedPercent / 100)
end

local function ApplyReminderTexturesValue(panel, enabled)
    if not panel then
        return
    end

    local normalizedEnabled = enabled == true
    panel.reminderTexturesCheck:SetChecked(normalizedEnabled)
    module:SetReminderTexturesEnabled(normalizedEnabled)
end

local function ApplyReminderBorderValue(panel, enabled)
    if not panel then
        return
    end

    local normalizedEnabled = enabled == true
    panel.reminderBorderCheck:SetChecked(normalizedEnabled)
    module:SetReminderBorderEnabled(normalizedEnabled)
end

local function ApplyReminderFontScaleValue(panel, scale)
    if not panel or not panel.reminderFontScaleSlider then
        return
    end

    local normalizedPercent = math.floor(math.max(FLOAT_FONT_SCALE_MIN, math.min(FLOAT_FONT_SCALE_MAX, tonumber(scale) or 100)) + 0.5)
    panel.updatingReminderFontScale = true
    panel.reminderFontScaleSlider:SetValue(normalizedPercent)
    panel.updatingReminderFontScale = nil
    RefreshReminderFontScaleValueText(panel, normalizedPercent / 100)
    module:SetReminderFontScale(normalizedPercent / 100)
end

local function ApplyReminderBackgroundAlphaValue(panel, alphaPercent)
    if not panel or not panel.reminderBackgroundAlphaSlider then
        return
    end

    local normalizedPercent = math.floor(math.max(FLOAT_BACKGROUND_ALPHA_MIN, math.min(FLOAT_BACKGROUND_ALPHA_MAX, tonumber(alphaPercent) or 0)) + 0.5)
    panel.updatingReminderBackgroundAlpha = true
    panel.reminderBackgroundAlphaSlider:SetValue(normalizedPercent)
    panel.updatingReminderBackgroundAlpha = nil
    RefreshReminderBackgroundAlphaValueText(panel, normalizedPercent)
    module:SetReminderBackgroundAlpha(normalizedPercent / 100)
end

local function RefreshOptionsSectionVisibility(panel)
    if not panel then
        return
    end

    local activeSectionKey = module:GetActiveOptionsSectionKey()
    if panel.generalSection then
        panel.generalSection:SetShown(activeSectionKey == OPTIONS_SECTION_GENERAL)
    end
    if panel.floatSection then
        panel.floatSection:SetShown(activeSectionKey == OPTIONS_SECTION_FLOAT)
    end
    if panel.reminderSection then
        panel.reminderSection:SetShown(activeSectionKey == OPTIONS_SECTION_REMINDER)
    end
    if panel.generalSectionButton then
        panel.generalSectionButton:SetEnabled(activeSectionKey ~= OPTIONS_SECTION_GENERAL)
    end
    if panel.floatSectionButton then
        panel.floatSectionButton:SetEnabled(activeSectionKey ~= OPTIONS_SECTION_FLOAT)
    end
    if panel.reminderSectionButton then
        panel.reminderSectionButton:SetEnabled(activeSectionKey ~= OPTIONS_SECTION_REMINDER)
    end
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
    do
        local red, green, blue = HexToColorRGB(HOME_LIST_BACKGROUND_HEX)
        panel.bodyBackground:SetColorTexture(red, green, blue, HOME_LIST_BACKGROUND_ALPHA)
    end

    panel.bodyBorderFrame = ApplyTooltipBorderToRegion(panel, panel.bodyFrame)
    panel.bodyShadowBounds, panel.bodyShadowTexture = ApplyInsetShadowToRegion(
        panel.bodyFrame,
        panel.bodyFrame,
        NOTE_BODY_SHADOW_ATLAS,
        NOTE_OPTIONS_BODY_SHADOW_ALPHA,
        NOTE_OPTIONS_BODY_SHADOW_INSET
    )

    panel.contentInset = CreateFrame("Frame", nil, panel.bodyFrame)
    panel.contentInset:SetPoint("TOPLEFT", panel.bodyFrame, "TOPLEFT", NOTE_TAB_FIELD_INNER_X, -NOTE_TAB_FIELD_INNER_Y)
    panel.contentInset:SetPoint("BOTTOMRIGHT", panel.bodyFrame, "BOTTOMRIGHT", -NOTE_TAB_FIELD_INNER_X, NOTE_TAB_FIELD_INNER_Y)
    panel.contentInset:SetFrameLevel((panel.bodyShadowBounds:GetFrameLevel() or 1) + 1)

    panel.sectionBar = CreateFrame("Frame", nil, panel.contentInset)
    panel.sectionBar:SetPoint("TOPLEFT", 12, -12)
    panel.sectionBar:SetPoint("TOPRIGHT", -12, -12)
    panel.sectionBar:SetHeight(OPTIONS_SECTION_BUTTON_HEIGHT)

    panel.generalSectionButton = CreateFrame("Button", nil, panel.sectionBar, "UIPanelButtonTemplate")
    panel.generalSectionButton:SetSize(OPTIONS_SECTION_BUTTON_WIDTH, OPTIONS_SECTION_BUTTON_HEIGHT)
    panel.generalSectionButton:SetPoint("TOPLEFT", 0, 0)
    panel.generalSectionButton:SetText("General")
    panel.generalSectionButton:SetScript("OnClick", function()
        module:SetActiveOptionsSectionKey(OPTIONS_SECTION_GENERAL)
        module:RefreshOptionsPanel(module:GetOptionsTab())
    end)

    panel.floatSectionButton = CreateFrame("Button", nil, panel.sectionBar, "UIPanelButtonTemplate")
    panel.floatSectionButton:SetSize(OPTIONS_SECTION_BUTTON_WIDTH, OPTIONS_SECTION_BUTTON_HEIGHT)
    panel.floatSectionButton:SetPoint("LEFT", panel.generalSectionButton, "RIGHT", OPTIONS_SECTION_BUTTON_SPACING, 0)
    panel.floatSectionButton:SetText("Float")
    panel.floatSectionButton:SetScript("OnClick", function()
        module:SetActiveOptionsSectionKey(OPTIONS_SECTION_FLOAT)
        module:RefreshOptionsPanel(module:GetOptionsTab())
    end)

    panel.reminderSectionButton = CreateFrame("Button", nil, panel.sectionBar, "UIPanelButtonTemplate")
    panel.reminderSectionButton:SetSize(OPTIONS_SECTION_BUTTON_WIDTH, OPTIONS_SECTION_BUTTON_HEIGHT)
    panel.reminderSectionButton:SetPoint("LEFT", panel.floatSectionButton, "RIGHT", OPTIONS_SECTION_BUTTON_SPACING, 0)
    panel.reminderSectionButton:SetText("Reminder")
    panel.reminderSectionButton:SetScript("OnClick", function()
        module:SetActiveOptionsSectionKey(OPTIONS_SECTION_REMINDER)
        module:RefreshOptionsPanel(module:GetOptionsTab())
    end)

    panel.sectionContent = CreateFrame("Frame", nil, panel.contentInset)
    panel.sectionContent:SetPoint("TOPLEFT", panel.sectionBar, "BOTTOMLEFT", 0, -12)
    panel.sectionContent:SetPoint("TOPRIGHT", panel.sectionBar, "BOTTOMRIGHT", 0, -12)
    panel.sectionContent:SetPoint("BOTTOMLEFT", panel.contentInset, "BOTTOMLEFT", 0, 0)
    panel.sectionContent:SetPoint("BOTTOMRIGHT", panel.contentInset, "BOTTOMRIGHT", 0, 0)

    panel.generalSection = CreateFrame("Frame", nil, panel.sectionContent)
    panel.generalSection:SetAllPoints()

    panel.floatSection = CreateFrame("Frame", nil, panel.sectionContent)
    panel.floatSection:SetAllPoints()

    panel.reminderSection = CreateFrame("Frame", nil, panel.sectionContent)
    panel.reminderSection:SetAllPoints()

    panel.autoSaveCheck = CreateFrame("CheckButton", nil, panel.generalSection, "UICheckButtonTemplate")
    panel.autoSaveCheck:SetPoint("TOPLEFT", 16, -8)

    panel.autoSaveLabelButton = CreateFrame("Button", nil, panel.generalSection)
    panel.autoSaveLabelButton:SetPoint("LEFT", panel.autoSaveCheck, "RIGHT", 4, 0)
    panel.autoSaveLabelButton:SetPoint("RIGHT", panel.generalSection, "RIGHT", -16, 0)
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

    panel.floatTexturesCheck = CreateFrame("CheckButton", nil, panel.floatSection, "UICheckButtonTemplate")
    panel.floatTexturesCheck:SetPoint("TOPLEFT", 16, -12)

    panel.floatTexturesLabelButton = CreateFrame("Button", nil, panel.floatSection)
    panel.floatTexturesLabelButton:SetPoint("LEFT", panel.floatTexturesCheck, "RIGHT", 4, 0)
    panel.floatTexturesLabelButton:SetPoint("RIGHT", panel.floatSection, "RIGHT", -16, 0)
    panel.floatTexturesLabelButton:SetHeight(24)

    panel.floatTexturesLabel = panel.floatTexturesLabelButton:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    panel.floatTexturesLabel:SetAllPoints()
    panel.floatTexturesLabel:SetJustifyH("LEFT")
    panel.floatTexturesLabel:SetJustifyV("MIDDLE")
    panel.floatTexturesLabel:SetText("Show textures in Float window")

    panel.floatTexturesCheck:SetScript("OnClick", function(check)
        ApplyFloatTexturesValue(panel, check:GetChecked())
    end)
    panel.floatTexturesLabelButton:SetScript("OnClick", function()
        ApplyFloatTexturesValue(panel, not panel.floatTexturesCheck:GetChecked())
    end)

    panel.floatBorderCheck = CreateFrame("CheckButton", nil, panel.floatSection, "UICheckButtonTemplate")
    panel.floatBorderCheck:SetPoint("TOPLEFT", panel.floatTexturesCheck, "BOTTOMLEFT", 0, -8)

    panel.floatBorderLabelButton = CreateFrame("Button", nil, panel.floatSection)
    panel.floatBorderLabelButton:SetPoint("LEFT", panel.floatBorderCheck, "RIGHT", 4, 0)
    panel.floatBorderLabelButton:SetPoint("RIGHT", panel.floatSection, "RIGHT", -16, 0)
    panel.floatBorderLabelButton:SetHeight(24)

    panel.floatBorderLabel = panel.floatBorderLabelButton:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    panel.floatBorderLabel:SetAllPoints()
    panel.floatBorderLabel:SetJustifyH("LEFT")
    panel.floatBorderLabel:SetJustifyV("MIDDLE")
    panel.floatBorderLabel:SetText("Show border")

    panel.floatBorderCheck:SetScript("OnClick", function(check)
        ApplyFloatBorderValue(panel, check:GetChecked())
    end)
    panel.floatBorderLabelButton:SetScript("OnClick", function()
        ApplyFloatBorderValue(panel, not panel.floatBorderCheck:GetChecked())
    end)

    panel.floatFontScaleLabel = panel.floatSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    panel.floatFontScaleLabel:SetPoint("TOPLEFT", panel.floatBorderCheck, "BOTTOMLEFT", 4, -20)
    panel.floatFontScaleLabel:SetText("Font size")

    panel.floatFontScaleValue = panel.floatSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    panel.floatFontScaleValue:SetPoint("LEFT", panel.floatFontScaleLabel, "RIGHT", 12, 0)
    panel.floatFontScaleValue:SetText("100%")

    panel.floatFontScaleSlider = CreateFrame("Slider", nil, panel.floatSection, "OptionsSliderTemplate")
    panel.floatFontScaleSlider:SetPoint("TOPLEFT", panel.floatFontScaleLabel, "BOTTOMLEFT", -2, -12)
    panel.floatFontScaleSlider:SetWidth(220)
    panel.floatFontScaleSlider:SetMinMaxValues(FLOAT_FONT_SCALE_MIN, FLOAT_FONT_SCALE_MAX)
    panel.floatFontScaleSlider:SetValueStep(FLOAT_FONT_SCALE_STEP)
    if panel.floatFontScaleSlider.SetObeyStepOnDrag then
        panel.floatFontScaleSlider:SetObeyStepOnDrag(true)
    end
    panel.floatFontScaleSliderBar = CreateFrame("Frame", nil, panel.floatSection, BackdropTemplateMixin and "BackdropTemplate")
    panel.floatFontScaleSliderBar:SetFrameLevel(panel.floatFontScaleSlider:GetFrameLevel())
    panel.floatFontScaleSliderBar:SetPoint("BOTTOMLEFT", panel.floatFontScaleSlider, "BOTTOMLEFT", 0, 0)
    panel.floatFontScaleSliderBar:SetPoint("BOTTOMRIGHT", panel.floatFontScaleSlider, "BOTTOMRIGHT", 0, 0)
    panel.floatFontScaleSliderBar:SetHeight(17)
    if panel.floatFontScaleSliderBar.SetBackdrop then
        panel.floatFontScaleSliderBar:SetBackdrop({
            bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
            edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
            tile = true,
            tileSize = 8,
            edgeSize = 8,
            insets = { left = 3, right = 3, top = 6, bottom = 6 },
        })
    end
    panel.floatFontScaleSlider:SetFrameLevel(panel.floatFontScaleSliderBar:GetFrameLevel() + 1)
    panel.floatFontScaleSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    local floatFontScaleThumb = panel.floatFontScaleSlider:GetThumbTexture()
    if floatFontScaleThumb then
        floatFontScaleThumb:SetSize(32, 32)
        floatFontScaleThumb:SetDrawLayer("OVERLAY", 7)
        floatFontScaleThumb:SetTexCoord(0, 1, 0, 1)
    end
    HideSliderHelperText(panel.floatFontScaleSlider)
    panel.floatFontScaleSlider:SetScript("OnValueChanged", function(slider, value)
        if panel.updatingFloatFontScale then
            return
        end

        local snappedValue = math.floor((value / FLOAT_FONT_SCALE_STEP) + 0.5) * FLOAT_FONT_SCALE_STEP
        if math.abs((value or 0) - snappedValue) > 0.01 then
            panel.updatingFloatFontScale = true
            slider:SetValue(snappedValue)
            panel.updatingFloatFontScale = nil
            return
        end

        ApplyFloatFontScaleValue(panel, snappedValue)
    end)

    panel.floatBackgroundAlphaLabel = panel.floatSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    panel.floatBackgroundAlphaLabel:SetPoint("TOPLEFT", panel.floatFontScaleSlider, "BOTTOMLEFT", 2, -34)
    panel.floatBackgroundAlphaLabel:SetText("Background alpha")

    panel.floatBackgroundAlphaValue = panel.floatSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    panel.floatBackgroundAlphaValue:SetPoint("LEFT", panel.floatBackgroundAlphaLabel, "RIGHT", 12, 0)
    panel.floatBackgroundAlphaValue:SetText("18%")

    panel.floatBackgroundAlphaSlider = CreateFrame("Slider", nil, panel.floatSection, "OptionsSliderTemplate")
    panel.floatBackgroundAlphaSlider:SetPoint("TOPLEFT", panel.floatBackgroundAlphaLabel, "BOTTOMLEFT", -2, -12)
    panel.floatBackgroundAlphaSlider:SetWidth(220)
    panel.floatBackgroundAlphaSlider:SetMinMaxValues(FLOAT_BACKGROUND_ALPHA_MIN, FLOAT_BACKGROUND_ALPHA_MAX)
    panel.floatBackgroundAlphaSlider:SetValueStep(FLOAT_BACKGROUND_ALPHA_STEP)
    if panel.floatBackgroundAlphaSlider.SetObeyStepOnDrag then
        panel.floatBackgroundAlphaSlider:SetObeyStepOnDrag(true)
    end
    panel.floatBackgroundAlphaSliderBar = CreateFrame("Frame", nil, panel.floatSection, BackdropTemplateMixin and "BackdropTemplate")
    panel.floatBackgroundAlphaSliderBar:SetFrameLevel(panel.floatBackgroundAlphaSlider:GetFrameLevel())
    panel.floatBackgroundAlphaSliderBar:SetPoint("BOTTOMLEFT", panel.floatBackgroundAlphaSlider, "BOTTOMLEFT", 0, 0)
    panel.floatBackgroundAlphaSliderBar:SetPoint("BOTTOMRIGHT", panel.floatBackgroundAlphaSlider, "BOTTOMRIGHT", 0, 0)
    panel.floatBackgroundAlphaSliderBar:SetHeight(17)
    if panel.floatBackgroundAlphaSliderBar.SetBackdrop then
        panel.floatBackgroundAlphaSliderBar:SetBackdrop({
            bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
            edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
            tile = true,
            tileSize = 8,
            edgeSize = 8,
            insets = { left = 3, right = 3, top = 6, bottom = 6 },
        })
    end
    panel.floatBackgroundAlphaSlider:SetFrameLevel(panel.floatBackgroundAlphaSliderBar:GetFrameLevel() + 1)
    panel.floatBackgroundAlphaSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    local floatBackgroundAlphaThumb = panel.floatBackgroundAlphaSlider:GetThumbTexture()
    if floatBackgroundAlphaThumb then
        floatBackgroundAlphaThumb:SetSize(32, 32)
        floatBackgroundAlphaThumb:SetDrawLayer("OVERLAY", 7)
        floatBackgroundAlphaThumb:SetTexCoord(0, 1, 0, 1)
    end
    HideSliderHelperText(panel.floatBackgroundAlphaSlider)
    panel.floatBackgroundAlphaSlider:SetScript("OnValueChanged", function(slider, value)
        if panel.updatingFloatBackgroundAlpha then
            return
        end

        local snappedValue = math.floor((value / FLOAT_BACKGROUND_ALPHA_STEP) + 0.5) * FLOAT_BACKGROUND_ALPHA_STEP
        if math.abs((value or 0) - snappedValue) > 0.01 then
            panel.updatingFloatBackgroundAlpha = true
            slider:SetValue(snappedValue)
            panel.updatingFloatBackgroundAlpha = nil
            return
        end

        ApplyFloatBackgroundAlphaValue(panel, snappedValue)
    end)

    panel.reminderTestButton = CreateFrame("Button", nil, panel.reminderSection, "UIPanelButtonTemplate")
    panel.reminderTestButton:SetSize(120, OPTIONS_SECTION_BUTTON_HEIGHT)
    panel.reminderTestButton:SetPoint("TOPLEFT", 16, -12)
    panel.reminderTestButton:SetText("Edit")
    if AttachTooltip then
        AttachTooltip(panel.reminderTestButton, "Edit", "Preview and position reminder popups.")
    end
    panel.reminderTestButton:SetScript("OnClick", function()
        if module.ToggleReminderTestWindow then
            module:ToggleReminderTestWindow()
        end
    end)

    panel.reminderTexturesCheck = CreateFrame("CheckButton", nil, panel.reminderSection, "UICheckButtonTemplate")
    panel.reminderTexturesCheck:SetPoint("TOPLEFT", panel.reminderTestButton, "BOTTOMLEFT", 0, -12)

    panel.reminderTexturesLabelButton = CreateFrame("Button", nil, panel.reminderSection)
    panel.reminderTexturesLabelButton:SetPoint("LEFT", panel.reminderTexturesCheck, "RIGHT", 4, 0)
    panel.reminderTexturesLabelButton:SetPoint("RIGHT", panel.reminderSection, "RIGHT", -16, 0)
    panel.reminderTexturesLabelButton:SetHeight(24)

    panel.reminderTexturesLabel = panel.reminderTexturesLabelButton:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    panel.reminderTexturesLabel:SetAllPoints()
    panel.reminderTexturesLabel:SetJustifyH("LEFT")
    panel.reminderTexturesLabel:SetJustifyV("MIDDLE")
    panel.reminderTexturesLabel:SetText("Show textures in Reminder window")

    panel.reminderTexturesCheck:SetScript("OnClick", function(check)
        ApplyReminderTexturesValue(panel, check:GetChecked())
    end)
    panel.reminderTexturesLabelButton:SetScript("OnClick", function()
        ApplyReminderTexturesValue(panel, not panel.reminderTexturesCheck:GetChecked())
    end)

    panel.reminderBorderCheck = CreateFrame("CheckButton", nil, panel.reminderSection, "UICheckButtonTemplate")
    panel.reminderBorderCheck:SetPoint("TOPLEFT", panel.reminderTexturesCheck, "BOTTOMLEFT", 0, -8)

    panel.reminderBorderLabelButton = CreateFrame("Button", nil, panel.reminderSection)
    panel.reminderBorderLabelButton:SetPoint("LEFT", panel.reminderBorderCheck, "RIGHT", 4, 0)
    panel.reminderBorderLabelButton:SetPoint("RIGHT", panel.reminderSection, "RIGHT", -16, 0)
    panel.reminderBorderLabelButton:SetHeight(24)

    panel.reminderBorderLabel = panel.reminderBorderLabelButton:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    panel.reminderBorderLabel:SetAllPoints()
    panel.reminderBorderLabel:SetJustifyH("LEFT")
    panel.reminderBorderLabel:SetJustifyV("MIDDLE")
    panel.reminderBorderLabel:SetText("Show border")

    panel.reminderBorderCheck:SetScript("OnClick", function(check)
        ApplyReminderBorderValue(panel, check:GetChecked())
    end)
    panel.reminderBorderLabelButton:SetScript("OnClick", function()
        ApplyReminderBorderValue(panel, not panel.reminderBorderCheck:GetChecked())
    end)

    panel.reminderFontScaleLabel = panel.reminderSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    panel.reminderFontScaleLabel:SetPoint("TOPLEFT", panel.reminderBorderCheck, "BOTTOMLEFT", 4, -20)
    panel.reminderFontScaleLabel:SetText("Font size")

    panel.reminderFontScaleValue = panel.reminderSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    panel.reminderFontScaleValue:SetPoint("LEFT", panel.reminderFontScaleLabel, "RIGHT", 12, 0)
    panel.reminderFontScaleValue:SetText("85%")

    panel.reminderFontScaleSlider = CreateFrame("Slider", nil, panel.reminderSection, "OptionsSliderTemplate")
    panel.reminderFontScaleSlider:SetPoint("TOPLEFT", panel.reminderFontScaleLabel, "BOTTOMLEFT", -2, -12)
    panel.reminderFontScaleSlider:SetWidth(220)
    panel.reminderFontScaleSlider:SetMinMaxValues(FLOAT_FONT_SCALE_MIN, FLOAT_FONT_SCALE_MAX)
    panel.reminderFontScaleSlider:SetValueStep(FLOAT_FONT_SCALE_STEP)
    if panel.reminderFontScaleSlider.SetObeyStepOnDrag then
        panel.reminderFontScaleSlider:SetObeyStepOnDrag(true)
    end
    panel.reminderFontScaleSliderBar = CreateFrame("Frame", nil, panel.reminderSection, BackdropTemplateMixin and "BackdropTemplate")
    panel.reminderFontScaleSliderBar:SetFrameLevel(panel.reminderFontScaleSlider:GetFrameLevel())
    panel.reminderFontScaleSliderBar:SetPoint("BOTTOMLEFT", panel.reminderFontScaleSlider, "BOTTOMLEFT", 0, 0)
    panel.reminderFontScaleSliderBar:SetPoint("BOTTOMRIGHT", panel.reminderFontScaleSlider, "BOTTOMRIGHT", 0, 0)
    panel.reminderFontScaleSliderBar:SetHeight(17)
    if panel.reminderFontScaleSliderBar.SetBackdrop then
        panel.reminderFontScaleSliderBar:SetBackdrop({
            bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
            edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
            tile = true,
            tileSize = 8,
            edgeSize = 8,
            insets = { left = 3, right = 3, top = 6, bottom = 6 },
        })
    end
    panel.reminderFontScaleSlider:SetFrameLevel(panel.reminderFontScaleSliderBar:GetFrameLevel() + 1)
    panel.reminderFontScaleSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    local reminderFontScaleThumb = panel.reminderFontScaleSlider:GetThumbTexture()
    if reminderFontScaleThumb then
        reminderFontScaleThumb:SetSize(32, 32)
        reminderFontScaleThumb:SetDrawLayer("OVERLAY", 7)
        reminderFontScaleThumb:SetTexCoord(0, 1, 0, 1)
    end
    HideSliderHelperText(panel.reminderFontScaleSlider)
    panel.reminderFontScaleSlider:SetScript("OnValueChanged", function(slider, value)
        if panel.updatingReminderFontScale then
            return
        end

        local snappedValue = math.floor((value / FLOAT_FONT_SCALE_STEP) + 0.5) * FLOAT_FONT_SCALE_STEP
        if math.abs((value or 0) - snappedValue) > 0.01 then
            panel.updatingReminderFontScale = true
            slider:SetValue(snappedValue)
            panel.updatingReminderFontScale = nil
            return
        end

        ApplyReminderFontScaleValue(panel, snappedValue)
    end)

    panel.reminderBackgroundAlphaLabel = panel.reminderSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    panel.reminderBackgroundAlphaLabel:SetPoint("TOPLEFT", panel.reminderFontScaleSlider, "BOTTOMLEFT", 2, -34)
    panel.reminderBackgroundAlphaLabel:SetText("Background alpha")

    panel.reminderBackgroundAlphaValue = panel.reminderSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    panel.reminderBackgroundAlphaValue:SetPoint("LEFT", panel.reminderBackgroundAlphaLabel, "RIGHT", 12, 0)
    panel.reminderBackgroundAlphaValue:SetText("65%")

    panel.reminderBackgroundAlphaSlider = CreateFrame("Slider", nil, panel.reminderSection, "OptionsSliderTemplate")
    panel.reminderBackgroundAlphaSlider:SetPoint("TOPLEFT", panel.reminderBackgroundAlphaLabel, "BOTTOMLEFT", -2, -12)
    panel.reminderBackgroundAlphaSlider:SetWidth(220)
    panel.reminderBackgroundAlphaSlider:SetMinMaxValues(FLOAT_BACKGROUND_ALPHA_MIN, FLOAT_BACKGROUND_ALPHA_MAX)
    panel.reminderBackgroundAlphaSlider:SetValueStep(FLOAT_BACKGROUND_ALPHA_STEP)
    if panel.reminderBackgroundAlphaSlider.SetObeyStepOnDrag then
        panel.reminderBackgroundAlphaSlider:SetObeyStepOnDrag(true)
    end
    panel.reminderBackgroundAlphaSliderBar = CreateFrame("Frame", nil, panel.reminderSection, BackdropTemplateMixin and "BackdropTemplate")
    panel.reminderBackgroundAlphaSliderBar:SetFrameLevel(panel.reminderBackgroundAlphaSlider:GetFrameLevel())
    panel.reminderBackgroundAlphaSliderBar:SetPoint("BOTTOMLEFT", panel.reminderBackgroundAlphaSlider, "BOTTOMLEFT", 0, 0)
    panel.reminderBackgroundAlphaSliderBar:SetPoint("BOTTOMRIGHT", panel.reminderBackgroundAlphaSlider, "BOTTOMRIGHT", 0, 0)
    panel.reminderBackgroundAlphaSliderBar:SetHeight(17)
    if panel.reminderBackgroundAlphaSliderBar.SetBackdrop then
        panel.reminderBackgroundAlphaSliderBar:SetBackdrop({
            bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
            edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
            tile = true,
            tileSize = 8,
            edgeSize = 8,
            insets = { left = 3, right = 3, top = 6, bottom = 6 },
        })
    end
    panel.reminderBackgroundAlphaSlider:SetFrameLevel(panel.reminderBackgroundAlphaSliderBar:GetFrameLevel() + 1)
    panel.reminderBackgroundAlphaSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    local reminderBackgroundAlphaThumb = panel.reminderBackgroundAlphaSlider:GetThumbTexture()
    if reminderBackgroundAlphaThumb then
        reminderBackgroundAlphaThumb:SetSize(32, 32)
        reminderBackgroundAlphaThumb:SetDrawLayer("OVERLAY", 7)
        reminderBackgroundAlphaThumb:SetTexCoord(0, 1, 0, 1)
    end
    HideSliderHelperText(panel.reminderBackgroundAlphaSlider)
    panel.reminderBackgroundAlphaSlider:SetScript("OnValueChanged", function(slider, value)
        if panel.updatingReminderBackgroundAlpha then
            return
        end

        local snappedValue = math.floor((value / FLOAT_BACKGROUND_ALPHA_STEP) + 0.5) * FLOAT_BACKGROUND_ALPHA_STEP
        if math.abs((value or 0) - snappedValue) > 0.01 then
            panel.updatingReminderBackgroundAlpha = true
            slider:SetValue(snappedValue)
            panel.updatingReminderBackgroundAlpha = nil
            return
        end

        ApplyReminderBackgroundAlphaValue(panel, snappedValue)
    end)

    panel.closeButton:SetScript("OnClick", function()
        module:RequestCloseOptionsTab(module:GetOptionsTab())
    end)
    panel:SetScript("OnHide", function()
        if module.HideReminderEditWindow then
            module:HideReminderEditWindow()
        end
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
    panel.floatTexturesCheck:SetChecked(module:IsFloatTexturesEnabled())
    panel.floatBorderCheck:SetChecked(module:IsFloatBorderEnabled())
    panel.updatingFloatFontScale = true
    panel.floatFontScaleSlider:SetValue(math.floor((module:GetFloatFontScale() * 100) + 0.5))
    panel.updatingFloatFontScale = nil
    RefreshFloatFontScaleValueText(panel, module:GetFloatFontScale())
    panel.updatingFloatBackgroundAlpha = true
    panel.floatBackgroundAlphaSlider:SetValue(math.floor((module:GetFloatBackgroundAlpha() * 100) + 0.5))
    panel.updatingFloatBackgroundAlpha = nil
    RefreshFloatBackgroundAlphaValueText(panel, module:GetFloatBackgroundAlpha() * 100)
    panel.reminderTexturesCheck:SetChecked(module:IsReminderTexturesEnabled())
    panel.reminderBorderCheck:SetChecked(module:IsReminderBorderEnabled())
    panel.updatingReminderFontScale = true
    panel.reminderFontScaleSlider:SetValue(math.floor((module:GetReminderFontScale() * 100) + 0.5))
    panel.updatingReminderFontScale = nil
    RefreshReminderFontScaleValueText(panel, module:GetReminderFontScale())
    panel.updatingReminderBackgroundAlpha = true
    panel.reminderBackgroundAlphaSlider:SetValue(math.floor((module:GetReminderBackgroundAlpha() * 100) + 0.5))
    panel.updatingReminderBackgroundAlpha = nil
    RefreshReminderBackgroundAlphaValueText(panel, module:GetReminderBackgroundAlpha() * 100)
    RefreshOptionsSectionVisibility(panel)
end
