local _, ns = ...
local SnailNotes = ns.SnailNotes
local shared = ns.NotesShared or {}
ns.NotesShared = shared

-- Window Sizing And Title
local BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil
local WINDOW_TITLE = "Notes"
local WINDOW_TITLE_Y_OFFSET = -2
local WINDOW_DEFAULT_WIDTH = 760
local WINDOW_DEFAULT_HEIGHT = 560
local WINDOW_MIN_WIDTH = 540
local WINDOW_MIN_HEIGHT = 420
local WINDOW_SCREEN_MARGIN = 48

-- Tabs And Note Defaults
local MAX_NOTE_TABS = 3
local TAB_HEIGHT = 24
local TAB_SPACING = -18
local DEFAULT_NOTE_TITLE = "Untitled Note"
local DEFAULT_NOTE_BODY = ""
local NOTE_ID_PREFIX = "note-"
local NOTE_TITLE_MAX_LENGTH = 20
local NOTE_EXPORT_PREFIX = "SSNOTE:1:"
local NOTE_EXPORT_VERSION = 1
local NOTE_AUTOSAVE_DELAY_SECONDS = 5
local BUILTIN_NOTES_GUIDE_ID = ns.NotesGuideData and ns.NotesGuideData.id or "builtin-notes-guide"
local BUILTIN_NOTES_GUIDE_UPDATED_AT = ns.NotesGuideData and ns.NotesGuideData.updatedAt or 1

-- Home Tab Layout
local HOME_HEADER_TOP_INSET = 0
local HOME_HEADER_SIDE_INSET = 8
local HOME_HEADER_COUNT_TOP_OFFSET = 3
local HOME_BUTTON_WIDTH = 84
local HOME_BUTTON_HEIGHT = 22
local HOME_HEADER_BUTTON_SPACING = 4

-- Home List Layout
local HOME_LIST_TOP_INSET = 32
local HOME_LIST_FRAME_INSET = 4
local HOME_LIST_BOTTOM_INSET = 10
local HOME_LIST_BACKDROP_BORDER_MARGIN = 3
local HOME_LIST_INNER_PADDING = 8
local HOME_LIST_SCROLLBAR_WIDTH = 12
local HOME_LIST_SCROLLBAR_RIGHT_PADDING = 9
local HOME_LIST_SCROLLBAR_TOTAL_WIDTH = HOME_LIST_SCROLLBAR_WIDTH + HOME_LIST_SCROLLBAR_RIGHT_PADDING
local HOME_ROW_HEIGHT = 32
local HOME_ROW_SPACING = 2
local HOME_ROW_TEXT_SIDE_INSET = 10
local HOME_ROW_TEXT_VERTICAL_OFFSET = 0
local HOME_ROW_TITLE_VERTICAL_OFFSET = -1
local HOME_ROW_BUILTIN_TITLE_CENTER_OFFSET_X = 0
local HOME_ROW_TIMESTAMP_RIGHT_INSET = 10
local HOME_ROW_TIMESTAMP_WIDTH = 126
local HOME_ROW_TITLE_TO_TIMESTAMP_SPACING = 12
local HOME_ROW_TITLE_FONT_SIZE = 15
local HOME_ROW_TIMESTAMP_FONT_SIZE = 11
local EMPTY_STATE_WIDTH = 320
local EMPTY_STATE_HEIGHT = 84
local EMPTY_STATE_MESSAGE_WIDTH = 260
local ROW_STRIDE = HOME_ROW_HEIGHT + HOME_ROW_SPACING

-- Row Action Menu
local ROW_MENU_WIDTH = 148
local ROW_MENU_BUTTON_HEIGHT = 22
local ROW_MENU_PADDING = 6
local ROW_MENU_SPACING = 2
local ROW_MENU_ANCHOR_X = -6
local ROW_MENU_ANCHOR_Y = -2
local ROW_MENU_BACKGROUND_TEXTURE = "Interface\\Buttons\\WHITE8x8"

-- Note Tab Layout
local NOTE_TAB_SIDE_INSET = 8
local NOTE_TAB_BOTTOM_INSET = 10
local NOTE_TAB_TOP_ROW_TOP_OFFSET = 2
local NOTE_TAB_TOP_ROW_HEIGHT = 28
local NOTE_TAB_TOP_ROW_TO_BODY_GAP = 8
local NOTE_TAB_ACTION_BUTTON_WIDTH = 78
local NOTE_TAB_DELETE_BUTTON_WIDTH = NOTE_TAB_ACTION_BUTTON_WIDTH
local NOTE_TAB_MODE_BUTTON_WIDTH = NOTE_TAB_ACTION_BUTTON_WIDTH
local NOTE_TAB_SAVE_BUTTON_WIDTH = NOTE_TAB_ACTION_BUTTON_WIDTH
local NOTE_TAB_EXPORT_BUTTON_WIDTH = NOTE_TAB_ACTION_BUTTON_WIDTH
local NOTE_TAB_TOP_CLOSE_BUTTON_SIZE = 38
local NOTE_TAB_TOP_CLOSE_BUTTON_SPACING = -2
local NOTE_TAB_TOP_ROW_CLOSE_BUTTON_RIGHT_INSET = -8
local NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_LEFT = 4
local NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_RIGHT = 4
local NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_TOP = 4
local NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_BOTTOM = 4
local NOTE_TAB_TITLE_WIDTH = 160
local NOTE_TAB_TITLE_TO_META_SPACING = 10
local NOTE_TAB_FIELD_INNER_X = 8
local NOTE_TAB_FIELD_INNER_Y = 6

-- Note Body Layout
local NOTE_TAB_BODY_MIN_CONTENT_HEIGHT = 120
local NOTE_TAB_BODY_INITIAL_VISIBLE_WIDTH = 280
local NOTE_TAB_BODY_EDIT_FONT_SIZE = 16
local NOTE_TAB_BODY_DIAGNOSTIC_LEFT_INSET = 8
local NOTE_TAB_BODY_DIAGNOSTIC_TOP_INSET = 8
local NOTE_TAB_BODY_DIAGNOSTIC_RIGHT_INSET = 8
local NOTE_TAB_BODY_DIAGNOSTIC_BOTTOM_INSET = 8

-- Note Body Background
local NOTE_TAB_BODY_BACKGROUND_ATLAS = "auctionhouse-background-buy-noncommodities-market"
local NOTE_TAB_BODY_BACKGROUND_COLOR = { 1.0, 1.0, 1.0, 1.0 }
local NOTE_TAB_BODY_BACKGROUND_FALLBACK_COLOR = { 0.05, 0.05, 0.05, 0.55 }

-- Note Body Scrollbar Layout
local NOTE_TAB_BODY_NATIVE_LEFT_INSET = NOTE_TAB_BODY_DIAGNOSTIC_LEFT_INSET
local NOTE_TAB_BODY_NATIVE_TOP_INSET = NOTE_TAB_BODY_DIAGNOSTIC_TOP_INSET
local NOTE_TAB_BODY_NATIVE_RIGHT_INSET = NOTE_TAB_BODY_DIAGNOSTIC_RIGHT_INSET
local NOTE_TAB_BODY_NATIVE_BOTTOM_INSET = NOTE_TAB_BODY_DIAGNOSTIC_BOTTOM_INSET
local NOTE_TAB_BODY_SCROLLBAR_WIDTH = 26
local NOTE_TAB_BODY_SCROLLBAR_X_OFFSET = 0
local NOTE_TAB_BODY_SCROLLBAR_LEFT_INSET = 0
local NOTE_TAB_BODY_SCROLLBAR_TOP_INSET = 14
local NOTE_TAB_BODY_SCROLLBAR_GAP = 0
local NOTE_TAB_BODY_SCROLLBAR_RIGHT_INSET = 26
local NOTE_TAB_BODY_SCROLLBAR_BOTTOM_INSET = 14
local NOTE_TAB_READ_TITLE_RIGHT_INSET = 12

-- Read View Fonts
local FONT_REGULAR = "Interface\\AddOns\\SnailNotes\\Media\\Fonts\\IBM-Plex-Sans\\IBMPlexSans-Medium.ttf"
local FONT_ITALIC = "Interface\\AddOns\\SnailNotes\\Media\\Fonts\\IBM-Plex-Sans\\IBMPlexSans-MediumItalic.ttf"
local FONT_BOLD = "Interface\\AddOns\\SnailNotes\\Media\\Fonts\\IBM-Plex-Sans\\IBMPlexSans-Bold.ttf"
local FONT_BOLDITALIC = "Interface\\AddOns\\SnailNotes\\Media\\Fonts\\IBM-Plex-Sans\\IBMPlexSans-BoldItalic.ttf"

-- Read View Renderer MD-Lite
local READ_LINE_FONT_SIZE = 16
local READ_HEADER1_FONT_SIZE = 46
local READ_HEADER2_FONT_SIZE = 34
local READ_HEADER3_FONT_SIZE = 24
local READ_BULLET_INDENT = 28
local READ_LINE_VERTICAL_SPACING = -10
local READ_HEADER_VERTICAL_SPACING = 0
local READ_POST_BULLET_BLOCK_SPACING = 4
local READ_BLANK_LINE_HEIGHT = 10
local READ_SEPARATOR_ROW_HEIGHT = 18
local READ_SEPARATOR_SIDE_INSET = 10
local READ_SEPARATOR_THICKNESS = 1
local READ_SEPARATOR_COLOR = { 0.65, 0.62, 0.56, 0.75 }
local READ_CODE_BACKGROUND_COLOR = { 0.02, 0.02, 0.02, 0.42 }
local READ_UNRESOLVED_ITEM_TOKEN_COLOR = { 1.0, 0.25, 0.25 }

-- Visual Colors And Textures
local HOME_LIST_BACKGROUND_HEX = "#181818"
local HOME_LIST_BACKGROUND_ALPHA = 1.0
local HOME_LIST_BORDER_COLOR = { 0.30, 0.30, 0.30, 0.55 }
local HOME_ROW_BACKGROUND_COLOR = { 0.04, 0.04, 0.04, 0.14 }
local HOME_ROW_HOVER_COLOR = { 0.45, 0.68, 1.0, 0.12 }
local HOME_ROW_SELECTED_COLOR = { 0.38, 0.62, 1.0, 0.22 }
local ROW_MENU_BACKGROUND_COLOR = { 0, 0, 0, 0.72 }
local ROW_MENU_BUTTON_HOVER_COLOR = HOME_ROW_HOVER_COLOR

-- Import / Export Dialog
local NOTE_TRANSFER_DIALOG_WIDTH = 560
local NOTE_TRANSFER_DIALOG_HEIGHT = 380
local NOTE_TRANSFER_DIALOG_BUTTON_WIDTH = 84
local NOTE_TRANSFER_DIALOG_BUTTON_HEIGHT = 22
local NOTE_TRANSFER_DIALOG_SIDE_INSET = 14
local NOTE_TRANSFER_DIALOG_TOP_INSET = 14
local NOTE_TRANSFER_DIALOG_BOTTOM_INSET = 14
local NOTE_TRANSFER_DIALOG_INSTRUCTIONS_TOP_GAP = 10
local NOTE_TRANSFER_DIALOG_BODY_TOP_GAP = 12
local NOTE_TRANSFER_DIALOG_STATUS_TOP_GAP = 8
local NOTE_TRANSFER_DIALOG_BUTTON_TOP_GAP = 12
local NOTE_TRANSFER_DIALOG_EDIT_INNER_X = 8
local NOTE_TRANSFER_DIALOG_EDIT_INNER_Y = 8
local NOTE_PREVIEW_LIVE_UPDATE_DELAY_SECONDS = 0.25
local NOTE_TASK_TOGGLE_AUTOSAVE_DELAY_SECONDS = 0.3
local NOTE_PREVIEW_WINDOW_WIDTH = 520
local NOTE_PREVIEW_WINDOW_HEIGHT = 480
local NOTE_PREVIEW_WINDOW_MIN_WIDTH = 360
local NOTE_PREVIEW_WINDOW_MIN_HEIGHT = 280

-- Module State
local module
local AceSerializer
local LibDeflate
local noteBodyScrollFrameSerial = 0

StaticPopupDialogs["SNAILNOTES_CONFIRM_DISCARD"] = {
    text = "You have unsaved changes. Discard them?",
    button1 = YES,
    button2 = NO,
    OnAccept = function(_, data)
        if data and data.onConfirm then
            data.onConfirm()
        end
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3,
}

StaticPopupDialogs["SNAILNOTES_TITLE_REQUIRED"] = {
    text = "Notes need a title.",
    button1 = OKAY,
    OnAccept = function(_, data)
        local tab = data and data.tab or nil
        local view = module and module.GetNoteTabEditView and module:GetNoteTabEditView(tab and tab.panel) or nil
        if view and view.titleInput then
            view.titleInput:SetFocus()
            if view.titleInput.HighlightText then
                view.titleInput:HighlightText()
            end
        end
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3,
}

StaticPopupDialogs["SNAILNOTES_CONFIRM_DELETE"] = {
    text = "Are you sure you want to delete your note?",
    button1 = YES,
    button2 = CANCEL,
    OnAccept = function(_, data)
        if data and data.noteId then
            module:DeleteNote(data.noteId)
        end
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3,
}

local function ClampNoteTitleLength(title)
    title = tostring(title or "")
    if string.len(title) > NOTE_TITLE_MAX_LENGTH then
        return string.sub(title, 1, NOTE_TITLE_MAX_LENGTH)
    end

    return title
end

local function NormalizeNoteTitle(title)
    title = ClampNoteTitleLength(title)
    if title == "" then
        return DEFAULT_NOTE_TITLE
    end

    return title
end

local function TrimNoteTitle(title)
    title = tostring(title or "")
    title = string.gsub(title, "^%s+", "")
    title = string.gsub(title, "%s+$", "")
    return ClampNoteTitleLength(title)
end

local function NormalizeNoteLinkTitle(title)
    title = tostring(title or "")
    title = string.gsub(title, "^%s+", "")
    title = string.gsub(title, "%s+$", "")
    if title == "" then
        return "Note"
    end

    return title
end

local function ClampImportTimestamp(value)
    local number = tonumber(value)
    if not number or number <= 0 then
        return nil
    end

    return math.floor(number)
end

local function GetPrintableErrorMessage(message)
    local text = tostring(message or "Invalid note import string.")
    text = string.gsub(text, "[%c]+", " ")
    text = string.gsub(text, "%s+", " ")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    if text == "" then
        text = "Invalid note import string."
    end

    return text
end

local function ExtractItemIdFromItemLink(itemLink)
    local itemId = itemLink and string.match(itemLink, "item:(%d+)")
    return tonumber(itemId)
end

local function BuildSuffixedNoteTitle(baseTitle, suffixIndex)
    local suffix = string.format(" (%d)", tonumber(suffixIndex) or 1)
    local maxBaseLength = math.max(NOTE_TITLE_MAX_LENGTH - string.len(suffix), 0)
    local trimmedBase = string.sub(tostring(baseTitle or ""), 1, maxBaseLength)
    trimmedBase = string.gsub(trimmedBase, "%s+$", "")
    if trimmedBase == "" then
        trimmedBase = string.sub(DEFAULT_NOTE_TITLE, 1, maxBaseLength)
    end

    return trimmedBase .. suffix
end

local function GetSafeWindowScreenBounds()
    local parentWidth = UIParent and UIParent:GetWidth() or WINDOW_DEFAULT_WIDTH
    local parentHeight = UIParent and UIParent:GetHeight() or WINDOW_DEFAULT_HEIGHT
    local maxWidth = math.max(math.floor(parentWidth - (WINDOW_SCREEN_MARGIN * 2)), WINDOW_MIN_WIDTH)
    local maxHeight = math.max(math.floor(parentHeight - (WINDOW_SCREEN_MARGIN * 2)), WINDOW_MIN_HEIGHT)
    return maxWidth, maxHeight
end

local function ClampWindowSize(width, height)
    width = tonumber(width) or WINDOW_DEFAULT_WIDTH
    height = tonumber(height) or WINDOW_DEFAULT_HEIGHT
    local maxWidth, maxHeight = GetSafeWindowScreenBounds()

    width = math.max(WINDOW_MIN_WIDTH, math.min(math.floor(width + 0.5), maxWidth))
    height = math.max(WINDOW_MIN_HEIGHT, math.min(math.floor(height + 0.5), maxHeight))

    return width, height
end

local function ClampHomeWindowSize(width, height)
    local _, clampedHeight = ClampWindowSize(WINDOW_MIN_WIDTH, height)
    return WINDOW_MIN_WIDTH, clampedHeight
end

local function CompactCheckboxRow(row)
    if not row or not row.check or not row.label then
        return
    end

    row:SetHeight(30)
    if row.description then
        row.description:Hide()
    end

    row.check:ClearAllPoints()
    row.check:SetPoint("LEFT", 0, 0)

    row.label:ClearAllPoints()
    row.label:SetPoint("LEFT", row.check, "RIGHT", 6, 1)
    row.label:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row.label:SetJustifyV("MIDDLE")
end

local function AttachTooltip(frame, title, text)
    if not frame or not title then
        return
    end

    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function(selfFrame)
        GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText(title, 1, 0.82, 0)
        if text and text ~= "" then
            GameTooltip:AddLine(text, 0.92, 0.88, 0.80, true)
        end
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function CreateSolidTexture(parent, layer, color)
    local texture = parent:CreateTexture(nil, layer or "BACKGROUND")
    texture:SetTexture("Interface\\Buttons\\WHITE8x8")
    texture:SetVertexColor(unpack(color))
    return texture
end

local function CreateBackdropFrame(parent, includeBackground)
    local frame = CreateFrame("Frame", nil, parent, BACKDROP_TEMPLATE)
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = includeBackground and "Interface\\Tooltips\\UI-Tooltip-Background" or nil,
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
    end
    return frame
end

local function HexToColorRGB(hex)
    local value = tostring(hex or "")
    value = string.gsub(value, "^#", "")
    if string.len(value) ~= 6 then
        return 1, 1, 1
    end

    local red = tonumber(string.sub(value, 1, 2), 16)
    local green = tonumber(string.sub(value, 3, 4), 16)
    local blue = tonumber(string.sub(value, 5, 6), 16)
    if not red or not green or not blue then
        return 1, 1, 1
    end

    return red / 255, green / 255, blue / 255
end

local function GetDayStartTimestamp(value)
    local dateTable = date("*t", value or time())
    return time({
        year = dateTable.year,
        month = dateTable.month,
        day = dateTable.day,
        hour = 0,
        min = 0,
        sec = 0,
    })
end

local function FormatSmartTimestamp(timestamp, createdTimestamp)
    local safeTimestamp = tonumber(timestamp) or tonumber(createdTimestamp) or time()
    local safeCreated = tonumber(createdTimestamp) or safeTimestamp
    local prefix = safeTimestamp > safeCreated and "Updated" or "Created"

    local now = time()
    local dayStart = GetDayStartTimestamp(now)
    local targetDayStart = GetDayStartTimestamp(safeTimestamp)
    local dayDelta = math.floor((dayStart - targetDayStart) / 86400)

    if dayDelta <= 0 then
        return string.format("%s today %s", prefix, date("%I:%M %p", safeTimestamp))
    end

    if dayDelta == 1 then
        return string.format("%s yesterday %s", prefix, date("%I:%M %p", safeTimestamp))
    end

    if dayDelta < 7 then
        return string.format("%s %s %s", prefix, date("%a", safeTimestamp), date("%I:%M %p", safeTimestamp))
    end

    return string.format("%s %s", prefix, date("%b %d, %Y", safeTimestamp))
end

module = SnailNotes
module.moduleName = "SnailNotes"
module.displayName = "SnailNotes"
module.description = "A standalone notes addon."

ns.SnailNotesDefaults = {
    profile = {
        enabled = true,
        options = {
            autoSave = true,
        },
        window = {
            width = WINDOW_DEFAULT_WIDTH,
            homeWidth = WINDOW_MIN_WIDTH,
            noteWidth = WINDOW_DEFAULT_WIDTH,
            height = WINDOW_DEFAULT_HEIGHT,
            point = "CENTER",
            relativePoint = "CENTER",
            x = 0,
            y = 0,
            preview = {
                width = NOTE_PREVIEW_WINDOW_WIDTH,
                height = NOTE_PREVIEW_WINDOW_HEIGHT,
                point = "CENTER",
                relativePoint = "CENTER",
                x = 300,
                y = 0,
            },
        },
        notes = {
            nextId = 1,
            items = {},
        },
    },
}

function module:GetBuiltinNotes()
    return {
        {
            id = BUILTIN_NOTES_GUIDE_ID,
            title = ns.NotesGuideData and ns.NotesGuideData.title or "Notes Guide",
            body = ns.NotesGuideData and ns.NotesGuideData.body or DEFAULT_NOTE_BODY,
            createdAt = BUILTIN_NOTES_GUIDE_UPDATED_AT,
            updatedAt = BUILTIN_NOTES_GUIDE_UPDATED_AT,
            isBuiltin = true,
        },
    }
end

function module:IsBuiltinNoteId(noteId)
    return noteId == BUILTIN_NOTES_GUIDE_ID
end

function module:GetBuiltinNoteById(noteId)
    if not self:IsBuiltinNoteId(noteId) then
        return nil
    end

    for _, note in ipairs(self:GetBuiltinNotes()) do
        if note.id == noteId then
            return note
        end
    end

    return nil
end

function module:GetSettings()
    if not self.db then
        return nil
    end

    self.db.profile = self.db.profile or {}

    local defaults = ns.SnailNotesDefaults and ns.SnailNotesDefaults.profile or nil
    if defaults then
        if self.db.profile.enabled == nil then
            self.db.profile.enabled = defaults.enabled
        end
        self.db.profile.options = self.db.profile.options or {}
        if self.db.profile.options.autoSave == nil then
            if self.db.profile.autosaveEnabled ~= nil then
                self.db.profile.options.autoSave = self.db.profile.autosaveEnabled ~= false
            else
                self.db.profile.options.autoSave = defaults.options and defaults.options.autoSave ~= false or true
            end
        end
        self.db.profile.window = self.db.profile.window or {}
        self.db.profile.notes = self.db.profile.notes or {}
        self.db.profile.window.preview = self.db.profile.window.preview or {}
        self.db.profile.notes.items = self.db.profile.notes.items or {}
        if self.db.profile.notes.nextId == nil then
            self.db.profile.notes.nextId = defaults.notes and defaults.notes.nextId or 1
        end
    end

    return self.db.profile
end

function module:GetWindowSettings()
    local settings = self:GetSettings()
    settings.window = settings.window or {}
    settings.window.width = tonumber(settings.window.width) or WINDOW_DEFAULT_WIDTH
    settings.window.homeWidth = tonumber(settings.window.homeWidth) or WINDOW_MIN_WIDTH
    settings.window.noteWidth = tonumber(settings.window.noteWidth) or WINDOW_DEFAULT_WIDTH
    return settings.window
end

local function ClampPreviewWindowSize(width, height)
    width = tonumber(width) or NOTE_PREVIEW_WINDOW_WIDTH
    height = tonumber(height) or NOTE_PREVIEW_WINDOW_HEIGHT
    local maxWidth, maxHeight = GetSafeWindowScreenBounds()

    width = math.max(NOTE_PREVIEW_WINDOW_MIN_WIDTH, math.min(math.floor(width + 0.5), maxWidth))
    height = math.max(NOTE_PREVIEW_WINDOW_MIN_HEIGHT, math.min(math.floor(height + 0.5), maxHeight))

    return width, height
end

function module:ClampPreviewWindowSize(width, height)
    return ClampPreviewWindowSize(width, height)
end

function module:GetPreviewWindowSettings()
    local windowSettings = self:GetWindowSettings()
    windowSettings.preview = windowSettings.preview or {}
    local previewSettings = windowSettings.preview
    previewSettings.width = tonumber(previewSettings.width) or NOTE_PREVIEW_WINDOW_WIDTH
    previewSettings.height = tonumber(previewSettings.height) or NOTE_PREVIEW_WINDOW_HEIGHT
    previewSettings.point = previewSettings.point or "CENTER"
    previewSettings.relativePoint = previewSettings.relativePoint or previewSettings.point or "CENTER"
    previewSettings.x = tonumber(previewSettings.x) or 300
    previewSettings.y = tonumber(previewSettings.y) or 0
    return previewSettings
end

function module:GetActiveWindowWidthSettingKey()
    if self:IsHomeTabActive() then
        return "homeWidth"
    end

    return "noteWidth"
end

function module:GetActiveWindowWidth(settings)
    settings = settings or self:GetWindowSettings()
    local widthKey = self:GetActiveWindowWidthSettingKey()
    return tonumber(settings[widthKey]) or tonumber(settings.width) or WINDOW_DEFAULT_WIDTH
end

function module:GetNoteStore()
    local settings = self:GetSettings()
    settings.notes = settings.notes or {}
    settings.notes.nextId = tonumber(settings.notes.nextId) or 1
    settings.notes.items = settings.notes.items or {}
    return settings.notes
end

function module:GetNotesTable()
    return self:GetNoteStore().items
end

function module:GetOrderedNotes()
    local orderedNotes = {}

    for _, note in ipairs(self:GetBuiltinNotes()) do
        orderedNotes[#orderedNotes + 1] = note
    end

    for _, note in pairs(self:GetNotesTable()) do
        orderedNotes[#orderedNotes + 1] = note
    end

    table.sort(orderedNotes, function(left, right)
        if left.isBuiltin ~= right.isBuiltin then
            return left.isBuiltin and true or false
        end

        local leftUpdated = tonumber(left.updatedAt) or tonumber(left.createdAt) or 0
        local rightUpdated = tonumber(right.updatedAt) or tonumber(right.createdAt) or 0
        if leftUpdated ~= rightUpdated then
            return leftUpdated > rightUpdated
        end

        local leftCreated = tonumber(left.createdAt) or 0
        local rightCreated = tonumber(right.createdAt) or 0
        if leftCreated ~= rightCreated then
            return leftCreated > rightCreated
        end

        return tostring(left.id or "") > tostring(right.id or "")
    end)

    return orderedNotes
end

function module:GetNoteById(noteId)
    if not noteId then
        return nil
    end

    local builtinNote = self:GetBuiltinNoteById(noteId)
    if builtinNote then
        return builtinNote
    end

    return self:GetNotesTable()[noteId]
end

function module:BuildNoteLinkString(noteId, titleOverride)
    local note = noteId and self:GetNoteById(noteId) or nil
    if not note then
        return nil
    end

    local noteTitle = titleOverride
    if noteTitle == nil then
        noteTitle = note.title
    end

    return string.format("(%s)[[%s]]", NormalizeNoteLinkTitle(noteTitle), tostring(note.id or noteId))
end

function module:IsGloballyEnabled()
    return self.db and self.db.profile and self.db.profile.enabled ~= false
end

function module:IsOperationalEnabled()
    local settings = self:GetSettings()
    return self:IsEnabled()
        and self:IsGloballyEnabled()
        and settings
        and settings.enabled ~= false
end

function module:IsHomeTabActive()
    return self.runtime and self.runtime.activeTabKey == "home"
end

function module:EnsureRuntime()
    if self.runtime then
        return
    end

    self.runtime = {
        frame = nil,
        activeTabKey = "home",
        tabs = {},
        orderedTabs = {},
        noteSlots = {},
        hoveredNoteId = nil,
        selectedNoteId = nil,
        rowActionMenu = nil,
        isListeningForReadItemInfo = false,
    }
end

function module:SaveWindowGeometry(frame)
    if not frame then
        return
    end

    local settings = self:GetWindowSettings()
    local width, height
    if self:IsHomeTabActive() then
        width, height = ClampHomeWindowSize(frame:GetWidth(), frame:GetHeight())
    else
        width, height = ClampWindowSize(frame:GetWidth(), frame:GetHeight())
    end
    settings[self:GetActiveWindowWidthSettingKey()] = width
    settings.width = width
    settings.height = height

    local point, _, relativePoint, x, y = frame:GetPoint(1)
    settings.point = point or "CENTER"
    settings.relativePoint = relativePoint or settings.point or "CENTER"
    settings.x = x or 0
    settings.y = y or 0
end

function module:UpdateWindowResizeBounds(frame)
    if not frame then
        return
    end

    local maxWidth, maxHeight = GetSafeWindowScreenBounds()
    if self:IsHomeTabActive() then
        maxWidth = math.max(math.min(WINDOW_MIN_WIDTH, maxWidth), WINDOW_MIN_WIDTH)
    end

    if frame.SetResizeBounds then
        frame:SetResizeBounds(WINDOW_MIN_WIDTH, WINDOW_MIN_HEIGHT, maxWidth, maxHeight)
    elseif frame.SetMaxResize then
        frame:SetMaxResize(maxWidth, maxHeight)
    end
end

function module:EnsureWindowGeometryIsReachable(frame)
    if not frame or not frame.GetLeft or not frame.GetRight or not frame.GetBottom or not frame.GetTop then
        return
    end

    local left = frame:GetLeft()
    local right = frame:GetRight()
    local bottom = frame:GetBottom()
    local top = frame:GetTop()
    if not left or not right or not bottom or not top then
        return
    end

    local parentWidth = UIParent and UIParent:GetWidth() or 0
    local parentHeight = UIParent and UIParent:GetHeight() or 0
    local offsetX = 0
    local offsetY = 0

    if left < WINDOW_SCREEN_MARGIN then
        offsetX = WINDOW_SCREEN_MARGIN - left
    elseif right > (parentWidth - WINDOW_SCREEN_MARGIN) then
        offsetX = (parentWidth - WINDOW_SCREEN_MARGIN) - right
    end

    if bottom < WINDOW_SCREEN_MARGIN then
        offsetY = WINDOW_SCREEN_MARGIN - bottom
    elseif top > (parentHeight - WINDOW_SCREEN_MARGIN) then
        offsetY = (parentHeight - WINDOW_SCREEN_MARGIN) - top
    end

    if offsetX == 0 and offsetY == 0 then
        return
    end

    frame:ClearAllPoints()
    frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left + offsetX, bottom + offsetY)
end

function module:ApplyWindowGeometry(frame)
    if not frame then
        return
    end

    local settings = self:GetWindowSettings()
    self:UpdateWindowResizeBounds(frame)
    local width, height
    if self:IsHomeTabActive() then
        width, height = ClampHomeWindowSize(self:GetActiveWindowWidth(settings), settings.height)
    else
        width, height = ClampWindowSize(self:GetActiveWindowWidth(settings), settings.height)
    end
    frame:SetSize(width, height)
    frame:ClearAllPoints()
    frame:SetPoint(settings.point or "CENTER", UIParent, settings.relativePoint or settings.point or "CENTER", settings.x or 0, settings.y or 0)
    self:EnsureWindowGeometryIsReachable(frame)
end

function module:SavePreviewWindowGeometry(frame)
    if not frame then
        return
    end

    local settings = self:GetPreviewWindowSettings()
    local width, height = ClampPreviewWindowSize(frame:GetWidth(), frame:GetHeight())
    settings.width = width
    settings.height = height

    local point, _, relativePoint, x, y = frame:GetPoint(1)
    settings.point = point or "CENTER"
    settings.relativePoint = relativePoint or settings.point or "CENTER"
    settings.x = x or 0
    settings.y = y or 0
end

function module:UpdatePreviewWindowResizeBounds(frame)
    if not frame then
        return
    end

    local maxWidth, maxHeight = GetSafeWindowScreenBounds()
    if frame.SetResizeBounds then
        frame:SetResizeBounds(NOTE_PREVIEW_WINDOW_MIN_WIDTH, NOTE_PREVIEW_WINDOW_MIN_HEIGHT, maxWidth, maxHeight)
    elseif frame.SetMaxResize then
        frame:SetMaxResize(maxWidth, maxHeight)
    end
end

function module:ApplyPreviewWindowGeometry(frame)
    if not frame then
        return
    end

    local settings = self:GetPreviewWindowSettings()
    self:UpdatePreviewWindowResizeBounds(frame)
    local width, height = ClampPreviewWindowSize(settings.width, settings.height)
    frame:SetSize(width, height)
    frame:ClearAllPoints()
    frame:SetPoint(settings.point or "CENTER", UIParent, settings.relativePoint or settings.point or "CENTER", settings.x or 0, settings.y or 0)
    self:EnsureWindowGeometryIsReachable(frame)
end

function module:GetNoteTabView(panel)
    return panel and panel.activeView
end

function module:GetNoteTabEditView(panel)
    return panel and panel.editView or nil
end

function module:GetNoteTabReadView(panel)
    return panel and panel.readView or nil
end

function module:GetNoteTabStoredTitle(tab)
    return NormalizeNoteTitle(tab and tab.noteData and tab.noteData.title or "Note")
end

function module:GetNoteTabWorkingValues(tab)
    local view = self:GetNoteTabEditView(tab and tab.panel)
    if not view then
        return self:GetNoteTabStoredTitle(tab), DEFAULT_NOTE_BODY
    end

    local titleText = view.titleInput and view.titleInput:GetText() or nil
    local bodyText = view.bodyInput and view.bodyInput:GetText() or nil
    return NormalizeNoteTitle(titleText), bodyText or DEFAULT_NOTE_BODY
end

local function SplitNoteBodyTextIntoLines(bodyText)
    local text = tostring(bodyText or "")
    text = string.gsub(text, "\r\n", "\n")
    text = string.gsub(text, "\r", "\n")

    local lines = {}
    if text == "" then
        lines[1] = ""
        return lines
    end

    for line in string.gmatch(text .. "\n", "(.-)\n") do
        lines[#lines + 1] = line
    end

    return lines
end

function module:ToggleTaskLineAtIndex(tab, sourceLineIndex)
    if not tab or not tab.panel or not sourceLineIndex then
        return false
    end

    local _, currentBody = self:GetNoteTabWorkingValues(tab)
    local lines = SplitNoteBodyTextIntoLines(currentBody)
    local targetIndex = tonumber(sourceLineIndex)
    local targetLine = targetIndex and lines[targetIndex] or nil
    if not targetLine then
        return false
    end

    local toggledLine, replacementCount = string.gsub(targetLine, "^(%-%s+)%[%](%s+.*)$", "%1[x]%2", 1)
    if replacementCount == 0 then
        toggledLine, replacementCount = string.gsub(targetLine, "^(%-%s+)%[[xX]%](%s+.*)$", "%1[]%2", 1)
    end
    if replacementCount == 0 or toggledLine == targetLine then
        return false
    end

    lines[targetIndex] = toggledLine
    local updatedBody = table.concat(lines, "\n")
    local panel = tab.panel
    local editView = self:GetNoteTabEditView(panel)

    if editView and editView.bodyInput then
        local previousCursorPosition = editView.bodyInput.GetCursorPosition and editView.bodyInput:GetCursorPosition() or nil
        local previousScrollOffset = editView.bodyScrollFrame and editView.bodyScrollFrame:GetVerticalScroll() or nil
        panel.isLoadingView = true
        editView.bodyInput:SetText(updatedBody)
        if previousCursorPosition and editView.bodyInput.SetCursorPosition then
            editView.bodyInput:SetCursorPosition(math.max(math.min(previousCursorPosition, string.len(updatedBody)), 0))
        end
        if previousScrollOffset and editView.bodyScrollFrame and editView.bodyScrollFrame.GetVerticalScrollRange then
            local maxScroll = math.max(editView.bodyScrollFrame:GetVerticalScrollRange() or 0, 0)
            editView.bodyScrollFrame:SetVerticalScroll(math.max(0, math.min(previousScrollOffset, maxScroll)))
        end
        panel.isLoadingView = false
    end

    tab.noteData = tab.noteData or {}
    tab.noteData.body = updatedBody

    self:HandleNoteTabContentChanged(tab)
    self:RefreshNoteReadView(tab)
    self:ScheduleNoteTaskToggleAutosave(tab)

    local previewOwner = self:GetPreviewOwnerTab()
    if previewOwner == tab then
        self:RefreshNotePreview(tab)
    end

    return true
end

function module:GetNoteTabDisplayTitle(tab)
    local title = self:GetNoteTabStoredTitle(tab)
    if tab and tab.dirty then
        title = self:GetNoteTabWorkingValues(tab)
        return title .. "*"
    end

    return title
end

function module:GetCursorItemId()
    local cursorType, cursorItemId, cursorItemLink = GetCursorInfo()
    if cursorType ~= "item" then
        return nil
    end

    return tonumber(cursorItemId) or ExtractItemIdFromItemLink(cursorItemLink)
end

function module:HandleNoteBodyItemDrop(tab, editBox)
    if not tab then
        return
    end

    local view = self:GetNoteTabEditView(tab.panel)
    editBox = editBox or (view and view.bodyInput or nil)
    if not editBox then
        return
    end

    local itemId = self:GetCursorItemId()
    if not itemId then
        return
    end

    local cursorPosition = editBox.GetCursorPosition and editBox:GetCursorPosition() or nil
    editBox:SetFocus()
    if cursorPosition and editBox.SetCursorPosition then
        editBox:SetCursorPosition(cursorPosition)
    end
    editBox:Insert(string.format("[%d]", itemId))
    self:HandleNoteTabContentChanged(tab)
    ClearCursor()
end

function module:RefreshNoteTabTitle(tab)
    if tab then
        self:SetTabTitle(tab, self:GetNoteTabDisplayTitle(tab))
    end
end

function module:RefreshNoteTabControls(tab)
    local panel = tab and tab.panel
    local editView = self:GetNoteTabEditView(panel)
    local readView = self:GetNoteTabReadView(panel)
    if not editView and not readView then
        return
    end

    local metaText = ""
    local isBuiltinNote = tab and tab.noteData and self:IsBuiltinNoteId(tab.noteData.noteId) or false
    if isBuiltinNote then
        metaText = "Built-in guide"
    elseif tab and tab.noteData and tab.noteData.updatedAt then
        metaText = FormatSmartTimestamp(tab.noteData.updatedAt, tab.noteData.createdAt)
    end

    if editView and editView.metaText then
        editView.metaText:SetText(metaText)
    end

    if readView and readView.metaText then
        readView.metaText:SetText(metaText)
    end

    local hasSavedNote = tab and tab.noteData and tab.noteData.noteId and true or false
    if editView and editView.deleteButton then
        editView.deleteButton:SetEnabled(hasSavedNote and not isBuiltinNote)
    end
    if readView and readView.deleteButton then
        readView.deleteButton:SetEnabled(hasSavedNote and not isBuiltinNote)
    end
    if readView and readView.exportButton then
        readView.exportButton:SetEnabled(hasSavedNote and not isBuiltinNote)
    end
    if readView and readView.linkButton then
        readView.linkButton:SetEnabled(hasSavedNote)
    end

    if editView and editView.modeButton then
        editView.modeButton:SetEnabled(not isBuiltinNote)
    end
    if readView and readView.modeButton then
        readView.modeButton:SetEnabled(not isBuiltinNote)
    end

    if editView and editView.saveButton then
        if tab and tab.dirty and not isBuiltinNote then
            editView.saveButton:Enable()
        else
            editView.saveButton:Disable()
        end
    end

    if editView and editView.previewCheck then
        editView.previewCheck:SetChecked(tab and tab.previewEnabled and true or false)
    end
end

function module:CancelNotePreviewUpdate(tab)
    if not tab then
        return
    end

    tab.previewUpdateToken = (tonumber(tab.previewUpdateToken) or 0) + 1
    if tab.previewUpdateTimer and tab.previewUpdateTimer.Cancel then
        tab.previewUpdateTimer:Cancel()
    end
    tab.previewUpdateTimer = nil
    tab.previewDirty = nil
end

function module:GetPreviewOwnerTab()
    local previewWindow = self.runtime and self.runtime.previewWindow or nil
    return previewWindow and previewWindow.ownerTab or nil
end

function module:CloseNotePreviewWindow(tab)
    local previewWindow = self.runtime and self.runtime.previewWindow or nil
    if not previewWindow then
        return
    end

    if tab and previewWindow.ownerTab ~= tab then
        return
    end

    previewWindow.suppressOwnerReset = true
    previewWindow.ownerTab = nil
    previewWindow:Hide()
    previewWindow.suppressOwnerReset = nil
end

function module:GetActiveNoteTab()
    local runtime = self.runtime
    if not runtime or not runtime.activeTabKey or not runtime.tabs then
        return nil
    end

    local activeTab = runtime.tabs[runtime.activeTabKey]
    if activeTab and activeTab.slotIndex and activeTab.assigned then
        return activeTab
    end

    return nil
end

function module:RefreshNotePreview(tab)
    if not tab or not tab.previewEnabled or not self:IsNoteTabInEditMode(tab) then
        return false
    end

    local activeTab = self:GetActiveNoteTab()
    if activeTab ~= tab then
        return false
    end

    local previewWindow = self:CreateNotePreviewWindow()
    local previewView = previewWindow and previewWindow.readView or nil
    if not previewView then
        return false
    end

    local title, body = self:GetNoteTabWorkingValues(tab)
    previewWindow.ownerTab = tab
    previewWindow:Show()
    previewView.ownerTab = tab
    self:RefreshStandaloneReadView(previewView, title, body)
    tab.previewDirty = nil
    self:UpdateReadItemInfoEventRegistration()
    return true
end

function module:ScheduleNotePreviewUpdate(tab)
    if not tab or not tab.previewEnabled then
        return
    end

    self:CancelNotePreviewUpdate(tab)
    tab.previewDirty = true

    local previewUpdateToken = tab.previewUpdateToken
    if C_Timer and C_Timer.NewTimer then
        tab.previewUpdateTimer = C_Timer.NewTimer(NOTE_PREVIEW_LIVE_UPDATE_DELAY_SECONDS, function()
            if not tab or tab.previewUpdateToken ~= previewUpdateToken or not tab.previewDirty then
                return
            end

            tab.previewUpdateTimer = nil
            module:RefreshNotePreview(tab)
        end)
        return
    end

    self:RefreshNotePreview(tab)
end

function module:DisableNotePreview(tab)
    if not tab then
        return
    end

    tab.previewEnabled = false
    self:CancelNotePreviewUpdate(tab)
    self:CloseNotePreviewWindow(tab)
    self:RefreshNoteTabControls(tab)
    self:UpdateReadItemInfoEventRegistration()
end

function module:SetNotePreviewEnabled(tab, enabled)
    if not tab then
        return
    end

    if enabled then
        local previousOwner = self:GetPreviewOwnerTab()
        if previousOwner and previousOwner ~= tab then
            self:DisableNotePreview(previousOwner)
        end

        tab.previewEnabled = true
        self:RefreshNoteTabControls(tab)
        self:RefreshNotePreview(tab)
        return
    end

    self:DisableNotePreview(tab)
end

function module:RefreshNotePreviewVisibility()
    local previewOwner = self:GetPreviewOwnerTab()
    local activeTab = self:GetActiveNoteTab()
    if not activeTab or not self:IsNoteTabInEditMode(activeTab) then
        if previewOwner then
            self:DisableNotePreview(previewOwner)
        end
        return
    end

    if previewOwner and previewOwner ~= activeTab then
        self:DisableNotePreview(previewOwner)
        previewOwner = nil
    end

    if activeTab.previewEnabled then
        self:RefreshNotePreview(activeTab)
    elseif previewOwner == activeTab then
        self:DisableNotePreview(activeTab)
    end
end

function module:GetNoteTabMode(tab)
    if tab and tab.mode == "read" then
        return "read"
    end

    return "edit"
end

function module:IsNoteTabInEditMode(tab)
    return self:GetNoteTabMode(tab) == "edit"
end

function module:SetNoteTabDirty(tab, isDirty)
    if not tab then
        return
    end

    tab.dirty = isDirty and true or false
    if not tab.dirty then
        self:CancelNoteAutosave(tab)
    end
    self:RefreshNoteTabTitle(tab)
    self:RefreshNoteTabControls(tab)
end

function module:ConfirmDiscardIfDirty(tab, onConfirm)
    if type(onConfirm) ~= "function" then
        return
    end

    if not tab or not tab.dirty then
        onConfirm()
        return
    end

    self:CancelNoteAutosave(tab)
    StaticPopup_Show("SNAILNOTES_CONFIRM_DISCARD", nil, nil, {
        onConfirm = onConfirm,
    })
end

function module:HandleNoteTabContentChanged(tab)
    local panel = tab and tab.panel
    if not panel or panel.isLoadingView then
        return
    end

    self:SetNoteTabDirty(tab, true)
    self:ScheduleNoteAutosave(tab)
    self:ScheduleNotePreviewUpdate(tab)
end

function module:CancelNoteAutosave(tab)
    if not tab then
        return
    end

    tab.autosaveToken = (tonumber(tab.autosaveToken) or 0) + 1
    if tab.autosaveTimer and tab.autosaveTimer.Cancel then
        tab.autosaveTimer:Cancel()
    end
    tab.autosaveTimer = nil
end

function module:CancelNoteTaskToggleAutosave(tab)
    if not tab then
        return
    end

    tab.taskToggleAutosaveToken = (tonumber(tab.taskToggleAutosaveToken) or 0) + 1
    if tab.taskToggleAutosaveTimer and tab.taskToggleAutosaveTimer.Cancel then
        tab.taskToggleAutosaveTimer:Cancel()
    end
    tab.taskToggleAutosaveTimer = nil
end

function module:ScheduleNoteTaskToggleAutosave(tab)
    if not tab then
        return
    end

    self:CancelNoteTaskToggleAutosave(tab)
    if not tab.dirty or not tab.noteData or self:IsBuiltinNoteId(tab.noteData.noteId) then
        return
    end

    local autosaveToken = tab.taskToggleAutosaveToken
    local saveTaskToggleNote = function()
        if not tab or tab.taskToggleAutosaveToken ~= autosaveToken then
            return
        end

        tab.taskToggleAutosaveTimer = nil
        if not tab.panel or not tab.assigned or not tab.dirty or not tab.noteData or self:IsBuiltinNoteId(tab.noteData.noteId) then
            return
        end

        -- Read-view task toggles are treated as committed interactions and
        -- should persist shortly after the click, even when general autosave is off.
        module:SaveNoteTabInternal(tab, {
            allowBlankTitle = true,
            keepEditMode = module:IsNoteTabInEditMode(tab),
        })
    end

    if C_Timer and C_Timer.NewTimer then
        tab.taskToggleAutosaveTimer = C_Timer.NewTimer(NOTE_TASK_TOGGLE_AUTOSAVE_DELAY_SECONDS, saveTaskToggleNote)
        return
    end

    C_Timer.After(NOTE_TASK_TOGGLE_AUTOSAVE_DELAY_SECONDS, saveTaskToggleNote)
end

function module:HasMeaningfulUnsavedNoteContent(tab)
    local view = self:GetNoteTabEditView(tab and tab.panel)
    if not view then
        return false
    end

    local titleText = view.titleInput and view.titleInput:GetText() or ""
    local bodyText = view.bodyInput and view.bodyInput:GetText() or ""
    return string.find(titleText, "%S") ~= nil or string.find(bodyText, "%S") ~= nil
end

function module:CanAutosaveNoteTab(tab)
    if not tab or not tab.panel or not tab.dirty then
        return false
    end

    if not self:IsAutoSaveEnabled() then
        return false
    end

    if not self:IsNoteTabInEditMode(tab) then
        return false
    end

    if not self.runtime or self.runtime.activeTabKey ~= tab.key then
        return false
    end

    if tab.noteData and tab.noteData.noteId then
        return true
    end

    return self:HasMeaningfulUnsavedNoteContent(tab)
end

function module:ScheduleNoteAutosave(tab)
    if not tab then
        return
    end

    self:CancelNoteAutosave(tab)

    if not self:IsAutoSaveEnabled() then
        return
    end

    if not tab.dirty or not self:IsNoteTabInEditMode(tab) then
        return
    end

    local autosaveToken = tab.autosaveToken
    if C_Timer and C_Timer.NewTimer then
        tab.autosaveTimer = C_Timer.NewTimer(NOTE_AUTOSAVE_DELAY_SECONDS, function()
            if not tab or tab.autosaveToken ~= autosaveToken then
                return
            end

            tab.autosaveTimer = nil
            if not module:CanAutosaveNoteTab(tab) then
                return
            end

            module:AutosaveNoteTab(tab)
        end)
        return
    end

    C_Timer.After(NOTE_AUTOSAVE_DELAY_SECONDS, function()
        if not tab or tab.autosaveToken ~= autosaveToken then
            return
        end

        tab.autosaveTimer = nil
        if not module:CanAutosaveNoteTab(tab) then
            return
        end

        module:AutosaveNoteTab(tab)
    end)
end

function module:GetNoteBodyTextHeight(bodyInput)
    if not bodyInput then
        return 0
    end

    local textHeight = bodyInput.GetTextHeight and bodyInput:GetTextHeight() or nil
    if tonumber(textHeight) and textHeight > 0 then
        return textHeight
    end

    local fontString = bodyInput.GetFontString and bodyInput:GetFontString() or nil
    if fontString and fontString.GetStringHeight then
        textHeight = fontString:GetStringHeight()
        if tonumber(textHeight) and textHeight > 0 then
            return textHeight
        end
    end

    return 0
end

function module:GetNoteBodyVisibleWidth(view, includeScrollbar)
    if not view or not view.bodyFrame then
        return NOTE_TAB_BODY_INITIAL_VISIBLE_WIDTH
    end

    local width = view.bodyScrollFrame and view.bodyScrollFrame:GetWidth() or 0
    if width and width > 1 then
        return width
    end

    width = (view.bodyFrame:GetWidth() or 0)
        - NOTE_TAB_BODY_NATIVE_LEFT_INSET
        - NOTE_TAB_BODY_NATIVE_RIGHT_INSET
    if includeScrollbar then
        width = width - NOTE_TAB_BODY_SCROLLBAR_WIDTH - NOTE_TAB_BODY_SCROLLBAR_GAP
    end

    return math.max(width, NOTE_TAB_BODY_INITIAL_VISIBLE_WIDTH)
end

function module:GetNoteBodyVisibleHeight(view)
    if not view or not view.bodyFrame then
        return NOTE_TAB_BODY_MIN_CONTENT_HEIGHT
    end

    local height = view.bodyScrollFrame and view.bodyScrollFrame:GetHeight() or 0
    if height and height > 1 then
        return height
    end

    height = (view.bodyFrame:GetHeight() or 0)
        - NOTE_TAB_BODY_NATIVE_TOP_INSET
        - NOTE_TAB_BODY_NATIVE_BOTTOM_INSET

    return math.max(height, NOTE_TAB_BODY_MIN_CONTENT_HEIGHT)
end

function module:GetNoteBodyContentHeight(view)
    if not view or not view.bodyInput then
        return NOTE_TAB_BODY_MIN_CONTENT_HEIGHT
    end

    local textHeight = self:GetNoteBodyTextHeight(view.bodyInput)
    local visibleHeight = self:GetNoteBodyVisibleHeight(view)
    local contentHeight = math.max(textHeight + (NOTE_TAB_FIELD_INNER_Y * 2), visibleHeight, NOTE_TAB_BODY_MIN_CONTENT_HEIGHT)
    return math.max(contentHeight, 1)
end

function module:GetNoteReadBodyTextHeight(view)
    if not view or not view.bodyLines then
        return 0
    end

    local textHeight = 0
    local previousLineType = nil
    for _, row in ipairs(view.bodyLines) do
        if row:IsShown() then
            textHeight = textHeight + math.max(row:GetHeight() or 0, 0)
            if previousLineType then
                textHeight = textHeight + self:GetReadViewLineSpacing(previousLineType, row.lineType)
            end
            previousLineType = row.lineType
        end
    end

    return math.max(tonumber(textHeight) or 0, 0)
end

function module:GetNoteReadBodyVisibleWidth(view, includeScrollbar)
    if not view or not view.bodyFrame then
        return NOTE_TAB_BODY_INITIAL_VISIBLE_WIDTH
    end

    local width = view.bodyScrollFrame and view.bodyScrollFrame:GetWidth() or 0
    if width and width > 1 then
        return width
    end

    width = (view.bodyFrame:GetWidth() or 0)
        - NOTE_TAB_BODY_NATIVE_LEFT_INSET
        - NOTE_TAB_BODY_NATIVE_RIGHT_INSET
    if includeScrollbar then
        width = width - NOTE_TAB_BODY_SCROLLBAR_WIDTH - NOTE_TAB_BODY_SCROLLBAR_GAP
    end

    return math.max(width, NOTE_TAB_BODY_INITIAL_VISIBLE_WIDTH)
end

function module:GetNoteReadBodyVisibleHeight(view)
    if not view or not view.bodyFrame then
        return NOTE_TAB_BODY_MIN_CONTENT_HEIGHT
    end

    local height = view.bodyScrollFrame and view.bodyScrollFrame:GetHeight() or 0
    if height and height > 1 then
        return height
    end

    height = (view.bodyFrame:GetHeight() or 0)
        - NOTE_TAB_BODY_NATIVE_TOP_INSET
        - NOTE_TAB_BODY_NATIVE_BOTTOM_INSET

    return math.max(height, NOTE_TAB_BODY_MIN_CONTENT_HEIGHT)
end

function module:GetNoteReadBodyContentHeight(view)
    if not view then
        return NOTE_TAB_BODY_MIN_CONTENT_HEIGHT
    end

    local textHeight = self:GetNoteReadBodyTextHeight(view)
    local visibleHeight = self:GetNoteReadBodyVisibleHeight(view)
    local contentHeight = math.max(textHeight, visibleHeight, NOTE_TAB_BODY_MIN_CONTENT_HEIGHT)
    return math.max(contentHeight, 1)
end

function module:ApplyTabMode(tab)
    if not tab or not tab.panel then
        return
    end

    local panel = tab.panel
    local editView = self:GetNoteTabEditView(panel)
    local readView = self:GetNoteTabReadView(panel)
    local isEditMode = self:IsNoteTabInEditMode(tab)

    if editView then
        editView:SetShown(isEditMode)
        if editView.modeButton then
            editView.modeButton:SetText(isEditMode and "Cancel" or "Edit")
        end
        if editView.saveButton then
            editView.saveButton:SetShown(isEditMode)
        end
    end

    if readView then
        readView:SetShown(not isEditMode)
        if readView.modeButton then
            readView.modeButton:SetText(isEditMode and "Cancel" or "Edit")
        end
    end

    panel.activeView = isEditMode and editView or readView

    if isEditMode then
        self:UpdateNoteBodyEditLayout(tab)
    else
        self:RefreshNoteReadView(tab)
    end

    self:RefreshNotePreviewVisibility()
end

function module:SetNoteTabMode(tab, mode)
    if not tab then
        return
    end

    self:CancelNoteAutosave(tab)

    if mode == "read" then
        self:DisableNotePreview(tab)
        tab.mode = "read"
    else
        tab.mode = "edit"
    end

    self:ApplyTabMode(tab)
    self:RefreshNoteTabControls(tab)
    self:UpdateReadItemInfoEventRegistration()
end

function module:RestoreSavedNoteToTab(tab)
    if not tab or not tab.noteData or not tab.noteData.noteId then
        return
    end

    local note = self:GetNoteById(tab.noteData.noteId)
    if note then
        self:LoadNoteIntoTab(tab, note)
    end
end

function module:HandleNoteModeButtonClicked(tab)
    if not tab then
        return
    end

    if tab.noteData and self:IsBuiltinNoteId(tab.noteData.noteId) then
        return
    end

    if self:IsNoteTabInEditMode(tab) then
        if tab.noteData and tab.noteData.noteId then
            self:ConfirmDiscardIfDirty(tab, function()
                module:RestoreSavedNoteToTab(tab)
                module:SetNoteTabMode(tab, "read")
            end)
        else
            self:ConfirmDiscardIfDirty(tab, function()
                module:CloseTab(tab)
            end)
        end
        return
    end

    self:SetNoteTabMode(tab, "edit")
end

function module:LoadNoteIntoTab(tab, note)
    local panel = tab and tab.panel
    local view = self:GetNoteTabEditView(panel)
    if not tab or not panel or not view then
        return
    end

    local title = NormalizeNoteTitle(note and note.title or tab.noteData and tab.noteData.title or "Note")
    local body = note and note.body or tab.noteData and tab.noteData.body or DEFAULT_NOTE_BODY

    tab.noteData = tab.noteData or {}
    tab.noteData.noteId = note and note.id or tab.noteData.noteId
    tab.noteData.title = title
    tab.noteData.body = body
    tab.noteData.createdAt = note and note.createdAt or tab.noteData.createdAt
    tab.noteData.updatedAt = note and note.updatedAt or tab.noteData.updatedAt

    panel.isLoadingView = true
    view.titleInput:SetText(title)
    view.bodyInput:SetText(body)
    view.bodyInput:SetCursorPosition(0)
    panel.isLoadingView = false

    self:UpdateNoteBodyEditLayout(tab)
    self:SetNoteTabDirty(tab, false)
    self:RefreshNoteReadView(tab)
    self:RefreshNotePreviewVisibility()
end

function module:RefreshNotePanel(tab)
    if not tab or not tab.panel then
        return
    end

    local note = tab.noteData and tab.noteData.noteId and self:GetNoteById(tab.noteData.noteId) or nil
    if note then
        self:LoadNoteIntoTab(tab, note)
        self:ApplyTabMode(tab)
        return
    end

    self:RefreshNoteTabTitle(tab)
    self:RefreshNoteTabControls(tab)
    self:RefreshNoteReadView(tab)
    self:ApplyTabMode(tab)
end

function module:RefreshSavedNoteReferences(tab)
    if not tab then
        return
    end

    self:RefreshNoteTabTitle(tab)
    self:RefreshNoteTabControls(tab)
    self:RefreshHomeList()
    self:RefreshRowActionMenu()
end

function module:SaveNoteTabInternal(tab, options)
    if not tab or not tab.noteData then
        return false
    end

    if self:IsBuiltinNoteId(tab.noteData.noteId) then
        return false
    end

    options = options or {}
    local view = self:GetNoteTabEditView(tab.panel)
    local rawTitle = view and view.titleInput and view.titleInput:GetText() or tab.noteData.title or ""
    local trimmedTitle = TrimNoteTitle(rawTitle)
    if trimmedTitle == "" and not options.allowBlankTitle then
        StaticPopup_Show("SNAILNOTES_TITLE_REQUIRED", nil, nil, {
            tab = tab,
        })
        return false
    end

    local title, body = self:GetNoteTabWorkingValues(tab)
    local now = time()
    local note = nil
    local isNewNote = not tab.noteData.noteId

    if tab.noteData.noteId then
        note = self:GetNoteById(tab.noteData.noteId)
        if not note then
            return false
        end
    else
        note = {
            id = self:BuildNextNoteId(),
            createdAt = now,
        }
        self:GetNotesTable()[note.id] = note
        tab.noteData.noteId = note.id
    end

    if isNewNote then
        title = self:GetUniqueNoteTitle(title, note.id)
    end

    note.title = title
    note.body = body
    note.updatedAt = now
    note.createdAt = note.createdAt or now

    tab.noteData.title = title
    tab.noteData.body = body
    tab.noteData.createdAt = note.createdAt
    tab.noteData.updatedAt = now

    if view and view.titleInput:GetText() ~= title then
        tab.panel.isLoadingView = true
        view.titleInput:SetText(title)
        tab.panel.isLoadingView = false
    end

    self:CancelNoteTaskToggleAutosave(tab)
    self:SetSelectedNote(note.id)
    self:SetNoteTabDirty(tab, false)
    self:RefreshNoteReadView(tab)
    if not options.keepEditMode then
        self:SetNoteTabMode(tab, "read")
    else
        self:RefreshNoteTabControls(tab)
        self:UpdateReadItemInfoEventRegistration()
    end
    self:RefreshSavedNoteReferences(tab)
    return true
end

function module:SaveNoteTab(tab)
    return self:SaveNoteTabInternal(tab)
end

function module:AutosaveNoteTab(tab)
    if not self:CanAutosaveNoteTab(tab) then
        return false
    end

    return self:SaveNoteTabInternal(tab, {
        allowBlankTitle = true,
        keepEditMode = true,
    })
end

function module:SaveNoteTabIfDirty(tab)
    if tab and tab.dirty then
        return self:SaveNoteTab(tab)
    end

    return true
end

function module:GetOpenTabForNoteId(noteId)
    if not noteId or not self.runtime or not self.runtime.noteSlots then
        return nil
    end

    for _, tab in ipairs(self.runtime.noteSlots) do
        if tab and tab.assigned and tab.noteData and tab.noteData.noteId == noteId then
            return tab
        end
    end

    return nil
end

function module:GetFirstAvailableNoteTabSlot()
    if not self.runtime or not self.runtime.noteSlots then
        return nil
    end

    for slotIndex = 1, MAX_NOTE_TABS do
        local tab = self.runtime.noteSlots[slotIndex]
        if tab and not tab.assigned then
            return slotIndex
        end
    end

    return nil
end

function module:HasAvailableNoteTabSlot()
    return self:GetFirstAvailableNoteTabSlot() ~= nil
end

function module:GetFallbackReusableTabSlot()
    local runtime = self.runtime
    if not runtime or not runtime.noteSlots then
        return 1
    end

    local activeTab = runtime.tabs and runtime.tabs[runtime.activeTabKey]
    if activeTab and activeTab.slotIndex then
        return activeTab.slotIndex
    end

    return 1
end

function module:EnsureSelectedNoteExists()
    local selectedNoteId = self.runtime and self.runtime.selectedNoteId
    if selectedNoteId and not self:GetNoteById(selectedNoteId) then
        self.runtime.selectedNoteId = nil
    end
end

function module:SetSelectedNote(noteId)
    self:EnsureRuntime()
    self.runtime.selectedNoteId = noteId
    self:RefreshHomeList()
end

function module:BuildNextNoteId()
    local store = self:GetNoteStore()
    local nextId = tonumber(store.nextId) or 1
    store.nextId = nextId + 1
    return NOTE_ID_PREFIX .. tostring(nextId)
end

function module:GetUniqueNoteTitle(baseTitle, ignoreNoteId)
    local normalizedTitle = NormalizeNoteTitle(baseTitle)
    local notes = self:GetNotesTable()

    local function titleExists(candidateTitle)
        for noteId, note in pairs(notes) do
            if noteId ~= ignoreNoteId and note and note.title == candidateTitle then
                return true
            end
        end

        return false
    end

    if not titleExists(normalizedTitle) then
        return normalizedTitle
    end

    local suffixIndex = 1
    local candidateTitle = BuildSuffixedNoteTitle(normalizedTitle, suffixIndex)
    while titleExists(candidateTitle) do
        suffixIndex = suffixIndex + 1
        candidateTitle = BuildSuffixedNoteTitle(normalizedTitle, suffixIndex)
    end

    return candidateTitle
end

function module:DeleteNote(noteId)
    self:EnsureRuntime()

    if not noteId or self:IsBuiltinNoteId(noteId) then
        return
    end

    local notes = self:GetNotesTable()
    if not notes[noteId] then
        return
    end

    notes[noteId] = nil
    self:CloseTabsForNote(noteId)

    if self.runtime and self.runtime.selectedNoteId == noteId then
        self.runtime.selectedNoteId = nil
    end

    self:HideRowActionMenu()
    self:Refresh()
end

function module:ConfirmDeleteNoteFromTab(tab)
    local noteId = tab and tab.noteData and tab.noteData.noteId or nil
    if not noteId or self:IsBuiltinNoteId(noteId) then
        return
    end

    StaticPopup_Show("SNAILNOTES_CONFIRM_DELETE", nil, nil, {
        noteId = noteId,
    })
end

function module:CreateAndOpenNote()
    self:EnsureRuntime()

    local targetSlotIndex = self:GetFirstAvailableNoteTabSlot() or self:GetFallbackReusableTabSlot()
    local tab = self.runtime and self.runtime.noteSlots and self.runtime.noteSlots[targetSlotIndex]
    if not tab then
        return
    end

    local function assignUnsavedNote()
        self:DisableNotePreview(tab)
        tab.assigned = true
        tab.mode = "edit"
        tab.noteData = {
            noteId = nil,
            title = DEFAULT_NOTE_TITLE,
            body = DEFAULT_NOTE_BODY,
            createdAt = nil,
            updatedAt = nil,
        }

        self:SetSelectedNote(nil)
        self:RefreshNotePanel(tab)
        self:SetNoteTabDirty(tab, true)
        self:RefreshTabLayout()
        self:SelectTab(tab.key)

        local view = self:GetNoteTabEditView(tab.panel)
        if view and view.bodyInput then
            view.bodyInput:SetFocus()
            view.bodyInput:SetCursorPosition(0)
        end
    end

    self:ConfirmDiscardIfDirty(tab, assignUnsavedNote)
end

function module:OpenAssignedNoteTab(slotIndex, note, keepCurrentTabActive)
    self:EnsureRuntime()

    local tab = self.runtime.noteSlots and self.runtime.noteSlots[slotIndex]
    if not tab or not note then
        return
    end

    local function assignNote()
        self:DisableNotePreview(tab)
        tab.assigned = true
        tab.mode = "read"
        tab.noteData = {
            noteId = note.id,
            title = NormalizeNoteTitle(note.title),
            body = note.body or DEFAULT_NOTE_BODY,
            createdAt = note.createdAt,
            updatedAt = note.updatedAt,
        }

        self:RefreshNotePanel(tab)
        self:RefreshTabLayout()
        if not keepCurrentTabActive then
            self:SelectTab(tab.key)
        end
    end

    local isReplacingDifferentNote = tab.assigned and tab.noteData and tab.noteData.noteId ~= note.id
    if isReplacingDifferentNote then
        self:ConfirmDiscardIfDirty(tab, assignNote)
        return
    end

    assignNote()
end

function module:CloseAssignedNoteTab(slotIndex)
    self:EnsureRuntime()

    local tab = self.runtime.noteSlots and self.runtime.noteSlots[slotIndex]
    if not tab then
        return
    end

    self:DisableNotePreview(tab)
    self:CancelNoteAutosave(tab)
    self:CancelNoteTaskToggleAutosave(tab)

    local view = self:GetNoteTabEditView(tab.panel)
    local readView = self:GetNoteTabReadView(tab.panel)
    if view then
        tab.panel.isLoadingView = true
        view.titleInput:SetText("")
        view.bodyInput:SetText("")
        tab.panel.isLoadingView = false
        self:UpdateNoteBodyEditLayout(tab)
    end
    if readView then
        readView.titleText:SetText("")
        self:RefreshNoteReadLineRows(readView, "")
        self:UpdateNoteBodyReadLayout(tab)
    end

    tab.assigned = false
    tab.mode = "edit"
    tab.hasPendingReadItemInfo = false
    tab.pendingReadItemIds = nil
    tab.noteData = nil
    self:SetNoteTabDirty(tab, false)
    self:SetTabTitle(tab, "Note")
    self:RefreshNoteTabControls(tab)
    self:UpdateReadItemInfoEventRegistration()

    if self.runtime.activeTabKey == tab.key then
        self.runtime.activeTabKey = "home"
    end

    self:RefreshTabLayout()
    self:SelectTab(self.runtime.activeTabKey or "home")
end

function module:CloseTab(tab)
    if not tab then
        return
    end

    if self:IsOptionsTab(tab) then
        self:CloseOptionsTab(tab)
        return
    end

    if not tab.slotIndex then
        return
    end

    self:CloseAssignedNoteTab(tab.slotIndex)
end

function module:RequestCloseTab(tab)
    if not tab then
        return
    end

    if self:IsOptionsTab(tab) then
        self:RequestCloseOptionsTab(tab)
        return
    end

    self:ConfirmDiscardIfDirty(tab, function()
        module:CloseTab(tab)
    end)
end

function module:CloseTabsForNote(noteId)
    if not noteId or not self.runtime or not self.runtime.noteSlots then
        return
    end

    for slotIndex = 1, MAX_NOTE_TABS do
        local tab = self.runtime.noteSlots[slotIndex]
        if tab and tab.assigned and tab.noteData and tab.noteData.noteId == noteId then
            self:CloseAssignedNoteTab(slotIndex)
        end
    end
end

function module:OpenNote(noteId, openInNewTab, keepCurrentTabActive)
    local note = self:GetNoteById(noteId)
    if not note then
        return false
    end

    self:SetSelectedNote(noteId)

    local existingTab = self:GetOpenTabForNoteId(noteId)
    if existingTab then
        if not keepCurrentTabActive then
            self:SelectTab(existingTab.key)
        end
        return true
    end

    local targetSlotIndex = nil
    if openInNewTab then
        targetSlotIndex = self:GetFirstAvailableNoteTabSlot()
        if not targetSlotIndex then
            self:RefreshRowActionMenu()
            return false
        end
    else
        targetSlotIndex = self:GetFirstAvailableNoteTabSlot() or self:GetFallbackReusableTabSlot()
    end

    self:OpenAssignedNoteTab(targetSlotIndex, note, keepCurrentTabActive)
    return true
end

function module:OpenWindow()
    if not self:IsOperationalEnabled() then
        self:PrintMessage("SnailNotes is disabled.")
        return
    end

    local frame = self:CreateNotesFrame()
    frame:Show()
    if frame.Raise then
        frame:Raise()
    end
end

function module:IsWindowOpen()
    return self.runtime and self.runtime.frame and self.runtime.frame:IsShown() or false
end

function module:CloseWindow()
    local previewOwner = self:GetPreviewOwnerTab()
    if previewOwner then
        self:DisableNotePreview(previewOwner)
    end
    if self.runtime and self.runtime.frame then
        self.runtime.frame:Hide()
    end
end

function module:Refresh()
    self:EnsureRuntime()

    if not self:IsOperationalEnabled() then
        self:CloseWindow()
        return
    end

    if self.runtime.frame and self.runtime.frame:IsShown() then
        self:RefreshHomeView()
        self:RefreshTabLayout()
        self:SelectTab(self.runtime.activeTabKey or "home")
    end

    self:UpdateReadItemInfoEventRegistration()
end

function module:HandleReadItemInfoReceived(itemId, success)
    if not success or not self.runtime then
        return
    end

    local numericItemId = tonumber(itemId)
    if not numericItemId then
        return
    end

    local didRefreshTab = false
    for _, tab in ipairs(self.runtime.noteSlots or {}) do
        if tab and tab.assigned and not self:IsNoteTabInEditMode(tab) and tab.hasPendingReadItemInfo then
            local pendingReadItemIds = tab.pendingReadItemIds
            if pendingReadItemIds and pendingReadItemIds[numericItemId] then
                self:RefreshNoteReadView(tab)
                didRefreshTab = true
            end
        end
    end

    local previewWindow = self.runtime.previewWindow
    local previewView = previewWindow and previewWindow.readView or nil
    local previewOwnerTab = previewWindow and previewWindow.ownerTab or nil
    if previewOwnerTab and previewWindow and previewWindow:IsShown() and previewView and previewView.hasPendingReadItemInfo then
        local pendingReadItemIds = previewView.pendingReadItemIds
        if pendingReadItemIds and pendingReadItemIds[numericItemId] then
            self:RefreshNotePreview(previewOwnerTab)
            didRefreshTab = true
        end
    end

    if not didRefreshTab then
        self:UpdateReadItemInfoEventRegistration()
    end
end

function module:GET_ITEM_INFO_RECEIVED(_, itemId, success)
    self:HandleReadItemInfoReceived(itemId, success)
end

function module:ITEM_DATA_LOAD_RESULT(_, itemId, success)
    self:HandleReadItemInfoReceived(itemId, success)
end

function module:OnInitialize()
    if self.InitializeStandaloneAddon then
        self:InitializeStandaloneAddon()
    end
    AceSerializer = LibStub and LibStub("AceSerializer-3.0", true) or nil
    LibDeflate = LibStub and LibStub("LibDeflate", true) or nil
    self:EnsureRuntime()
    self:GetNoteStore()
end

function module:OnEnable()
    self:EnsureRuntime()
    self:Refresh()
end

function module:OnDisable()
    if self.runtime and self.runtime.isListeningForReadItemInfo then
        self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
        self:UnregisterEvent("ITEM_DATA_LOAD_RESULT")
        self.runtime.isListeningForReadItemInfo = false
    end
    local previewOwner = self:GetPreviewOwnerTab()
    if previewOwner then
        self:DisableNotePreview(previewOwner)
    end
    self:CloseWindow()
end

shared.module = module
shared.constants = {
    WINDOW_TITLE = WINDOW_TITLE,
    WINDOW_TITLE_Y_OFFSET = WINDOW_TITLE_Y_OFFSET,
    WINDOW_DEFAULT_WIDTH = WINDOW_DEFAULT_WIDTH,
    WINDOW_DEFAULT_HEIGHT = WINDOW_DEFAULT_HEIGHT,
    WINDOW_MIN_WIDTH = WINDOW_MIN_WIDTH,
    WINDOW_MIN_HEIGHT = WINDOW_MIN_HEIGHT,
    WINDOW_SCREEN_MARGIN = WINDOW_SCREEN_MARGIN,
    MAX_NOTE_TABS = MAX_NOTE_TABS,
    TAB_HEIGHT = TAB_HEIGHT,
    TAB_SPACING = TAB_SPACING,
    DEFAULT_NOTE_TITLE = DEFAULT_NOTE_TITLE,
    DEFAULT_NOTE_BODY = DEFAULT_NOTE_BODY,
    NOTE_ID_PREFIX = NOTE_ID_PREFIX,
    NOTE_TITLE_MAX_LENGTH = NOTE_TITLE_MAX_LENGTH,
    NOTE_EXPORT_PREFIX = NOTE_EXPORT_PREFIX,
    NOTE_EXPORT_VERSION = NOTE_EXPORT_VERSION,
    BUILTIN_NOTES_GUIDE_ID = BUILTIN_NOTES_GUIDE_ID,
    BUILTIN_NOTES_GUIDE_UPDATED_AT = BUILTIN_NOTES_GUIDE_UPDATED_AT,
    HOME_HEADER_TOP_INSET = HOME_HEADER_TOP_INSET,
    HOME_HEADER_SIDE_INSET = HOME_HEADER_SIDE_INSET,
    HOME_HEADER_COUNT_TOP_OFFSET = HOME_HEADER_COUNT_TOP_OFFSET,
    HOME_BUTTON_WIDTH = HOME_BUTTON_WIDTH,
    HOME_BUTTON_HEIGHT = HOME_BUTTON_HEIGHT,
    HOME_HEADER_BUTTON_SPACING = HOME_HEADER_BUTTON_SPACING,
    HOME_LIST_TOP_INSET = HOME_LIST_TOP_INSET,
    HOME_LIST_FRAME_INSET = HOME_LIST_FRAME_INSET,
    HOME_LIST_BOTTOM_INSET = HOME_LIST_BOTTOM_INSET,
    HOME_LIST_BACKDROP_BORDER_MARGIN = HOME_LIST_BACKDROP_BORDER_MARGIN,
    HOME_LIST_INNER_PADDING = HOME_LIST_INNER_PADDING,
    HOME_LIST_SCROLLBAR_WIDTH = HOME_LIST_SCROLLBAR_WIDTH,
    HOME_LIST_SCROLLBAR_RIGHT_PADDING = HOME_LIST_SCROLLBAR_RIGHT_PADDING,
    HOME_LIST_SCROLLBAR_TOTAL_WIDTH = HOME_LIST_SCROLLBAR_TOTAL_WIDTH,
    HOME_ROW_HEIGHT = HOME_ROW_HEIGHT,
    HOME_ROW_SPACING = HOME_ROW_SPACING,
    HOME_ROW_TEXT_SIDE_INSET = HOME_ROW_TEXT_SIDE_INSET,
    HOME_ROW_TEXT_VERTICAL_OFFSET = HOME_ROW_TEXT_VERTICAL_OFFSET,
    HOME_ROW_TITLE_VERTICAL_OFFSET = HOME_ROW_TITLE_VERTICAL_OFFSET,
    HOME_ROW_BUILTIN_TITLE_CENTER_OFFSET_X = HOME_ROW_BUILTIN_TITLE_CENTER_OFFSET_X,
    HOME_ROW_TIMESTAMP_RIGHT_INSET = HOME_ROW_TIMESTAMP_RIGHT_INSET,
    HOME_ROW_TIMESTAMP_WIDTH = HOME_ROW_TIMESTAMP_WIDTH,
    HOME_ROW_TITLE_TO_TIMESTAMP_SPACING = HOME_ROW_TITLE_TO_TIMESTAMP_SPACING,
    HOME_ROW_TITLE_FONT_SIZE = HOME_ROW_TITLE_FONT_SIZE,
    HOME_ROW_TIMESTAMP_FONT_SIZE = HOME_ROW_TIMESTAMP_FONT_SIZE,
    EMPTY_STATE_WIDTH = EMPTY_STATE_WIDTH,
    EMPTY_STATE_HEIGHT = EMPTY_STATE_HEIGHT,
    EMPTY_STATE_MESSAGE_WIDTH = EMPTY_STATE_MESSAGE_WIDTH,
    ROW_STRIDE = ROW_STRIDE,
    ROW_MENU_WIDTH = ROW_MENU_WIDTH,
    ROW_MENU_BUTTON_HEIGHT = ROW_MENU_BUTTON_HEIGHT,
    ROW_MENU_PADDING = ROW_MENU_PADDING,
    ROW_MENU_SPACING = ROW_MENU_SPACING,
    ROW_MENU_ANCHOR_X = ROW_MENU_ANCHOR_X,
    ROW_MENU_ANCHOR_Y = ROW_MENU_ANCHOR_Y,
    ROW_MENU_BACKGROUND_TEXTURE = ROW_MENU_BACKGROUND_TEXTURE,
    NOTE_TAB_SIDE_INSET = NOTE_TAB_SIDE_INSET,
    NOTE_TAB_BOTTOM_INSET = NOTE_TAB_BOTTOM_INSET,
    NOTE_TAB_TOP_ROW_TOP_OFFSET = NOTE_TAB_TOP_ROW_TOP_OFFSET,
    NOTE_TAB_TOP_ROW_HEIGHT = NOTE_TAB_TOP_ROW_HEIGHT,
    NOTE_TAB_TOP_ROW_TO_BODY_GAP = NOTE_TAB_TOP_ROW_TO_BODY_GAP,
    NOTE_TAB_ACTION_BUTTON_WIDTH = NOTE_TAB_ACTION_BUTTON_WIDTH,
    NOTE_TAB_DELETE_BUTTON_WIDTH = NOTE_TAB_DELETE_BUTTON_WIDTH,
    NOTE_TAB_MODE_BUTTON_WIDTH = NOTE_TAB_MODE_BUTTON_WIDTH,
    NOTE_TAB_SAVE_BUTTON_WIDTH = NOTE_TAB_SAVE_BUTTON_WIDTH,
    NOTE_TAB_EXPORT_BUTTON_WIDTH = NOTE_TAB_EXPORT_BUTTON_WIDTH,
    NOTE_TAB_TOP_CLOSE_BUTTON_SIZE = NOTE_TAB_TOP_CLOSE_BUTTON_SIZE,
    NOTE_TAB_TOP_CLOSE_BUTTON_SPACING = NOTE_TAB_TOP_CLOSE_BUTTON_SPACING,
    NOTE_TAB_TOP_ROW_CLOSE_BUTTON_RIGHT_INSET = NOTE_TAB_TOP_ROW_CLOSE_BUTTON_RIGHT_INSET,
    NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_LEFT = NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_LEFT,
    NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_RIGHT = NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_RIGHT,
    NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_TOP = NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_TOP,
    NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_BOTTOM = NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_BOTTOM,
    NOTE_TAB_TITLE_WIDTH = NOTE_TAB_TITLE_WIDTH,
    NOTE_TAB_TITLE_TO_META_SPACING = NOTE_TAB_TITLE_TO_META_SPACING,
    NOTE_TAB_FIELD_INNER_X = NOTE_TAB_FIELD_INNER_X,
    NOTE_TAB_FIELD_INNER_Y = NOTE_TAB_FIELD_INNER_Y,
    NOTE_TAB_BODY_MIN_CONTENT_HEIGHT = NOTE_TAB_BODY_MIN_CONTENT_HEIGHT,
    NOTE_TAB_BODY_INITIAL_VISIBLE_WIDTH = NOTE_TAB_BODY_INITIAL_VISIBLE_WIDTH,
    NOTE_TAB_BODY_EDIT_FONT_SIZE = NOTE_TAB_BODY_EDIT_FONT_SIZE,
    NOTE_TAB_BODY_DIAGNOSTIC_LEFT_INSET = NOTE_TAB_BODY_DIAGNOSTIC_LEFT_INSET,
    NOTE_TAB_BODY_DIAGNOSTIC_TOP_INSET = NOTE_TAB_BODY_DIAGNOSTIC_TOP_INSET,
    NOTE_TAB_BODY_DIAGNOSTIC_RIGHT_INSET = NOTE_TAB_BODY_DIAGNOSTIC_RIGHT_INSET,
    NOTE_TAB_BODY_DIAGNOSTIC_BOTTOM_INSET = NOTE_TAB_BODY_DIAGNOSTIC_BOTTOM_INSET,
    NOTE_TAB_BODY_BACKGROUND_ATLAS = NOTE_TAB_BODY_BACKGROUND_ATLAS,
    NOTE_TAB_BODY_BACKGROUND_COLOR = NOTE_TAB_BODY_BACKGROUND_COLOR,
    NOTE_TAB_BODY_BACKGROUND_FALLBACK_COLOR = NOTE_TAB_BODY_BACKGROUND_FALLBACK_COLOR,
    NOTE_TAB_BODY_NATIVE_LEFT_INSET = NOTE_TAB_BODY_NATIVE_LEFT_INSET,
    NOTE_TAB_BODY_NATIVE_TOP_INSET = NOTE_TAB_BODY_NATIVE_TOP_INSET,
    NOTE_TAB_BODY_NATIVE_RIGHT_INSET = NOTE_TAB_BODY_NATIVE_RIGHT_INSET,
    NOTE_TAB_BODY_NATIVE_BOTTOM_INSET = NOTE_TAB_BODY_NATIVE_BOTTOM_INSET,
    NOTE_TAB_BODY_SCROLLBAR_WIDTH = NOTE_TAB_BODY_SCROLLBAR_WIDTH,
    NOTE_TAB_BODY_SCROLLBAR_X_OFFSET = NOTE_TAB_BODY_SCROLLBAR_X_OFFSET,
    NOTE_TAB_BODY_SCROLLBAR_LEFT_INSET = NOTE_TAB_BODY_SCROLLBAR_LEFT_INSET,
    NOTE_TAB_BODY_SCROLLBAR_TOP_INSET = NOTE_TAB_BODY_SCROLLBAR_TOP_INSET,
    NOTE_TAB_BODY_SCROLLBAR_GAP = NOTE_TAB_BODY_SCROLLBAR_GAP,
    NOTE_TAB_BODY_SCROLLBAR_RIGHT_INSET = NOTE_TAB_BODY_SCROLLBAR_RIGHT_INSET,
    NOTE_TAB_BODY_SCROLLBAR_BOTTOM_INSET = NOTE_TAB_BODY_SCROLLBAR_BOTTOM_INSET,
    NOTE_TAB_READ_TITLE_RIGHT_INSET = NOTE_TAB_READ_TITLE_RIGHT_INSET,
    FONT_REGULAR = FONT_REGULAR,
    FONT_ITALIC = FONT_ITALIC,
    FONT_BOLD = FONT_BOLD,
    FONT_BOLDITALIC = FONT_BOLDITALIC,
    READ_LINE_FONT_SIZE = READ_LINE_FONT_SIZE,
    READ_HEADER1_FONT_SIZE = READ_HEADER1_FONT_SIZE,
    READ_HEADER2_FONT_SIZE = READ_HEADER2_FONT_SIZE,
    READ_HEADER3_FONT_SIZE = READ_HEADER3_FONT_SIZE,
    READ_BULLET_INDENT = READ_BULLET_INDENT,
    READ_LINE_VERTICAL_SPACING = READ_LINE_VERTICAL_SPACING,
    READ_HEADER_VERTICAL_SPACING = READ_HEADER_VERTICAL_SPACING,
    READ_POST_BULLET_BLOCK_SPACING = READ_POST_BULLET_BLOCK_SPACING,
    READ_BLANK_LINE_HEIGHT = READ_BLANK_LINE_HEIGHT,
    READ_SEPARATOR_ROW_HEIGHT = READ_SEPARATOR_ROW_HEIGHT,
    READ_SEPARATOR_SIDE_INSET = READ_SEPARATOR_SIDE_INSET,
    READ_SEPARATOR_THICKNESS = READ_SEPARATOR_THICKNESS,
    READ_SEPARATOR_COLOR = READ_SEPARATOR_COLOR,
    READ_CODE_BACKGROUND_COLOR = READ_CODE_BACKGROUND_COLOR,
    READ_UNRESOLVED_ITEM_TOKEN_COLOR = READ_UNRESOLVED_ITEM_TOKEN_COLOR,
    HOME_LIST_BACKGROUND_HEX = HOME_LIST_BACKGROUND_HEX,
    HOME_LIST_BACKGROUND_ALPHA = HOME_LIST_BACKGROUND_ALPHA,
    HOME_LIST_BORDER_COLOR = HOME_LIST_BORDER_COLOR,
    HOME_ROW_BACKGROUND_COLOR = HOME_ROW_BACKGROUND_COLOR,
    HOME_ROW_HOVER_COLOR = HOME_ROW_HOVER_COLOR,
    HOME_ROW_SELECTED_COLOR = HOME_ROW_SELECTED_COLOR,
    ROW_MENU_BACKGROUND_COLOR = ROW_MENU_BACKGROUND_COLOR,
    ROW_MENU_BUTTON_HOVER_COLOR = ROW_MENU_BUTTON_HOVER_COLOR,
    NOTE_TRANSFER_DIALOG_WIDTH = NOTE_TRANSFER_DIALOG_WIDTH,
    NOTE_TRANSFER_DIALOG_HEIGHT = NOTE_TRANSFER_DIALOG_HEIGHT,
    NOTE_TRANSFER_DIALOG_BUTTON_WIDTH = NOTE_TRANSFER_DIALOG_BUTTON_WIDTH,
    NOTE_TRANSFER_DIALOG_BUTTON_HEIGHT = NOTE_TRANSFER_DIALOG_BUTTON_HEIGHT,
    NOTE_TRANSFER_DIALOG_SIDE_INSET = NOTE_TRANSFER_DIALOG_SIDE_INSET,
    NOTE_TRANSFER_DIALOG_TOP_INSET = NOTE_TRANSFER_DIALOG_TOP_INSET,
    NOTE_TRANSFER_DIALOG_BOTTOM_INSET = NOTE_TRANSFER_DIALOG_BOTTOM_INSET,
    NOTE_TRANSFER_DIALOG_INSTRUCTIONS_TOP_GAP = NOTE_TRANSFER_DIALOG_INSTRUCTIONS_TOP_GAP,
    NOTE_TRANSFER_DIALOG_BODY_TOP_GAP = NOTE_TRANSFER_DIALOG_BODY_TOP_GAP,
    NOTE_TRANSFER_DIALOG_STATUS_TOP_GAP = NOTE_TRANSFER_DIALOG_STATUS_TOP_GAP,
    NOTE_TRANSFER_DIALOG_BUTTON_TOP_GAP = NOTE_TRANSFER_DIALOG_BUTTON_TOP_GAP,
    NOTE_TRANSFER_DIALOG_EDIT_INNER_X = NOTE_TRANSFER_DIALOG_EDIT_INNER_X,
    NOTE_TRANSFER_DIALOG_EDIT_INNER_Y = NOTE_TRANSFER_DIALOG_EDIT_INNER_Y,
    NOTE_PREVIEW_LIVE_UPDATE_DELAY_SECONDS = NOTE_PREVIEW_LIVE_UPDATE_DELAY_SECONDS,
    NOTE_PREVIEW_WINDOW_WIDTH = NOTE_PREVIEW_WINDOW_WIDTH,
    NOTE_PREVIEW_WINDOW_HEIGHT = NOTE_PREVIEW_WINDOW_HEIGHT,
    NOTE_PREVIEW_WINDOW_MIN_WIDTH = NOTE_PREVIEW_WINDOW_MIN_WIDTH,
    NOTE_PREVIEW_WINDOW_MIN_HEIGHT = NOTE_PREVIEW_WINDOW_MIN_HEIGHT,
}
shared.helpers = {
    ClampNoteTitleLength = ClampNoteTitleLength,
    NormalizeNoteTitle = NormalizeNoteTitle,
    TrimNoteTitle = TrimNoteTitle,
    ClampImportTimestamp = ClampImportTimestamp,
    GetPrintableErrorMessage = GetPrintableErrorMessage,
    ExtractItemIdFromItemLink = ExtractItemIdFromItemLink,
    BuildSuffixedNoteTitle = BuildSuffixedNoteTitle,
    GetSafeWindowScreenBounds = GetSafeWindowScreenBounds,
    ClampWindowSize = ClampWindowSize,
    ClampHomeWindowSize = ClampHomeWindowSize,
    CompactCheckboxRow = CompactCheckboxRow,
    AttachTooltip = AttachTooltip,
    CreateSolidTexture = CreateSolidTexture,
    CreateBackdropFrame = CreateBackdropFrame,
    HexToColorRGB = HexToColorRGB,
    GetDayStartTimestamp = GetDayStartTimestamp,
    FormatSmartTimestamp = FormatSmartTimestamp,
}
shared.NextNoteBodyScrollFrameSerial = function()
    noteBodyScrollFrameSerial = noteBodyScrollFrameSerial + 1
    return noteBodyScrollFrameSerial
end
shared.GetAceSerializer = function()
    return AceSerializer
end
shared.GetLibDeflate = function()
    return LibDeflate
end
