local _, ns = ...
local shared = ns.NotesShared
local module = shared and shared.module
if not shared or not module then return end
local constants = shared.constants
local helpers = shared.helpers
local CreateSolidTexture = helpers.CreateSolidTexture
local CreateBackdropFrame = helpers.CreateBackdropFrame
local HexToColorRGB = helpers.HexToColorRGB
local ClampWindowSize = helpers.ClampWindowSize
local ClampHomeWindowSize = helpers.ClampHomeWindowSize
local NormalizeNoteTitle = helpers.NormalizeNoteTitle
local HOME_ROW_HEIGHT = constants.HOME_ROW_HEIGHT
local HOME_ROW_BACKGROUND_COLOR = constants.HOME_ROW_BACKGROUND_COLOR
local HOME_ROW_HOVER_COLOR = constants.HOME_ROW_HOVER_COLOR
local HOME_ROW_SELECTED_COLOR = constants.HOME_ROW_SELECTED_COLOR
local HOME_ROW_TEXT_SIDE_INSET = constants.HOME_ROW_TEXT_SIDE_INSET
local HOME_ROW_TEXT_VERTICAL_OFFSET = constants.HOME_ROW_TEXT_VERTICAL_OFFSET
local HOME_ROW_TITLE_VERTICAL_OFFSET = constants.HOME_ROW_TITLE_VERTICAL_OFFSET
local HOME_ROW_BUILTIN_TITLE_CENTER_OFFSET_X = constants.HOME_ROW_BUILTIN_TITLE_CENTER_OFFSET_X
local HOME_ROW_TIMESTAMP_RIGHT_INSET = constants.HOME_ROW_TIMESTAMP_RIGHT_INSET
local HOME_ROW_TITLE_TO_TIMESTAMP_SPACING = constants.HOME_ROW_TITLE_TO_TIMESTAMP_SPACING
local HOME_ROW_TITLE_FONT_SIZE = constants.HOME_ROW_TITLE_FONT_SIZE
local HOME_ROW_TIMESTAMP_FONT_SIZE = constants.HOME_ROW_TIMESTAMP_FONT_SIZE
local HOME_ROW_SPACING = constants.HOME_ROW_SPACING
local ROW_STRIDE = constants.ROW_STRIDE
local HOME_HEADER_SIDE_INSET = constants.HOME_HEADER_SIDE_INSET
local HOME_HEADER_TOP_INSET = constants.HOME_HEADER_TOP_INSET
local HOME_HEADER_COUNT_TOP_OFFSET = constants.HOME_HEADER_COUNT_TOP_OFFSET
local HOME_BUTTON_WIDTH = constants.HOME_BUTTON_WIDTH
local HOME_BUTTON_HEIGHT = constants.HOME_BUTTON_HEIGHT
local HOME_HEADER_BUTTON_SPACING = constants.HOME_HEADER_BUTTON_SPACING
local HOME_LIST_TOP_INSET = constants.HOME_LIST_TOP_INSET
local HOME_LIST_FRAME_INSET = constants.HOME_LIST_FRAME_INSET
local HOME_LIST_BOTTOM_INSET = constants.HOME_LIST_BOTTOM_INSET
local HOME_LIST_BACKDROP_BORDER_MARGIN = constants.HOME_LIST_BACKDROP_BORDER_MARGIN
local HOME_LIST_INNER_PADDING = constants.HOME_LIST_INNER_PADDING
local HOME_LIST_SCROLLBAR_TOTAL_WIDTH = constants.HOME_LIST_SCROLLBAR_TOTAL_WIDTH
local EMPTY_STATE_WIDTH = constants.EMPTY_STATE_WIDTH
local EMPTY_STATE_HEIGHT = constants.EMPTY_STATE_HEIGHT
local EMPTY_STATE_MESSAGE_WIDTH = constants.EMPTY_STATE_MESSAGE_WIDTH
local HOME_LIST_BORDER_COLOR = constants.HOME_LIST_BORDER_COLOR
local HOME_LIST_BACKGROUND_HEX = constants.HOME_LIST_BACKGROUND_HEX
local HOME_LIST_BACKGROUND_ALPHA = constants.HOME_LIST_BACKGROUND_ALPHA
local ROW_MENU_WIDTH = constants.ROW_MENU_WIDTH
local ROW_MENU_BUTTON_HEIGHT = constants.ROW_MENU_BUTTON_HEIGHT
local ROW_MENU_PADDING = constants.ROW_MENU_PADDING
local ROW_MENU_SPACING = constants.ROW_MENU_SPACING
local ROW_MENU_ANCHOR_X = constants.ROW_MENU_ANCHOR_X
local ROW_MENU_ANCHOR_Y = constants.ROW_MENU_ANCHOR_Y
local ROW_MENU_BACKGROUND_TEXTURE = constants.ROW_MENU_BACKGROUND_TEXTURE
local ROW_MENU_BACKGROUND_COLOR = constants.ROW_MENU_BACKGROUND_COLOR
local ROW_MENU_BUTTON_HOVER_COLOR = constants.ROW_MENU_BUTTON_HOVER_COLOR
local NOTE_TAB_SIDE_INSET = constants.NOTE_TAB_SIDE_INSET
local NOTE_TAB_BOTTOM_INSET = constants.NOTE_TAB_BOTTOM_INSET
local NOTE_TAB_TOP_ROW_TOP_OFFSET = constants.NOTE_TAB_TOP_ROW_TOP_OFFSET
local NOTE_TAB_TOP_ROW_HEIGHT = constants.NOTE_TAB_TOP_ROW_HEIGHT
local NOTE_TAB_TOP_ROW_TO_BODY_GAP = constants.NOTE_TAB_TOP_ROW_TO_BODY_GAP
local NOTE_TAB_DELETE_BUTTON_WIDTH = constants.NOTE_TAB_DELETE_BUTTON_WIDTH
local NOTE_TAB_MODE_BUTTON_WIDTH = constants.NOTE_TAB_MODE_BUTTON_WIDTH
local NOTE_TAB_SAVE_BUTTON_WIDTH = constants.NOTE_TAB_SAVE_BUTTON_WIDTH
local NOTE_TAB_EXPORT_BUTTON_WIDTH = constants.NOTE_TAB_EXPORT_BUTTON_WIDTH
local NOTE_TAB_TOP_CLOSE_BUTTON_SIZE = constants.NOTE_TAB_TOP_CLOSE_BUTTON_SIZE
local NOTE_TAB_TOP_CLOSE_BUTTON_SPACING = constants.NOTE_TAB_TOP_CLOSE_BUTTON_SPACING
local NOTE_TAB_TOP_ROW_CLOSE_BUTTON_RIGHT_INSET = constants.NOTE_TAB_TOP_ROW_CLOSE_BUTTON_RIGHT_INSET
local NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_LEFT = constants.NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_LEFT
local NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_RIGHT = constants.NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_RIGHT
local NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_TOP = constants.NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_TOP
local NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_BOTTOM = constants.NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_BOTTOM
local NOTE_TAB_TITLE_WIDTH = constants.NOTE_TAB_TITLE_WIDTH
local NOTE_TITLE_MAX_LENGTH = constants.NOTE_TITLE_MAX_LENGTH
local NOTE_TAB_TITLE_TO_META_SPACING = constants.NOTE_TAB_TITLE_TO_META_SPACING
local NOTE_TAB_FIELD_INNER_X = constants.NOTE_TAB_FIELD_INNER_X
local NOTE_TAB_FIELD_INNER_Y = constants.NOTE_TAB_FIELD_INNER_Y
local NOTE_TAB_BODY_MIN_CONTENT_HEIGHT = constants.NOTE_TAB_BODY_MIN_CONTENT_HEIGHT
local NOTE_TAB_BODY_SCROLLBAR_WIDTH = constants.NOTE_TAB_BODY_SCROLLBAR_WIDTH
local NOTE_TAB_BODY_SCROLLBAR_GAP = constants.NOTE_TAB_BODY_SCROLLBAR_GAP
local NOTE_TAB_BODY_EDIT_FONT_SIZE = constants.NOTE_TAB_BODY_EDIT_FONT_SIZE
local NOTE_TAB_BODY_BACKGROUND_ATLAS = constants.NOTE_TAB_BODY_BACKGROUND_ATLAS
local NOTE_TAB_BODY_BACKGROUND_COLOR = constants.NOTE_TAB_BODY_BACKGROUND_COLOR
local NOTE_TAB_BODY_BACKGROUND_FALLBACK_COLOR = constants.NOTE_TAB_BODY_BACKGROUND_FALLBACK_COLOR
local NOTE_TAB_READ_TITLE_RIGHT_INSET = constants.NOTE_TAB_READ_TITLE_RIGHT_INSET
local DEFAULT_NOTE_TITLE = constants.DEFAULT_NOTE_TITLE
local DEFAULT_NOTE_BODY = constants.DEFAULT_NOTE_BODY
local MAX_NOTE_TABS = constants.MAX_NOTE_TABS
local TAB_HEIGHT = constants.TAB_HEIGHT
local TAB_SPACING = constants.TAB_SPACING
local WINDOW_TITLE = constants.WINDOW_TITLE
local WINDOW_TITLE_Y_OFFSET = constants.WINDOW_TITLE_Y_OFFSET
local WINDOW_MIN_WIDTH = constants.WINDOW_MIN_WIDTH
local WINDOW_MIN_HEIGHT = constants.WINDOW_MIN_HEIGHT
local NOTE_PREVIEW_WINDOW_WIDTH = constants.NOTE_PREVIEW_WINDOW_WIDTH
local NOTE_PREVIEW_WINDOW_HEIGHT = constants.NOTE_PREVIEW_WINDOW_HEIGHT
local NOTE_PREVIEW_WINDOW_MIN_WIDTH = constants.NOTE_PREVIEW_WINDOW_MIN_WIDTH
local NOTE_PREVIEW_WINDOW_MIN_HEIGHT = constants.NOTE_PREVIEW_WINDOW_MIN_HEIGHT
local HOME_ROW_TITLE_FONT = "Interface\\AddOns\\SnailNotes\\Media\\Fonts\\IBM-Plex-Sans\\IBMPlexSans-Bold.ttf"
local HOME_ROW_TIMESTAMP_FONT = "Interface\\AddOns\\SnailNotes\\Media\\Fonts\\IBM-Plex-Sans\\IBMPlexSans-Medium.ttf"
local HOME_ROW_BUILTIN_TITLE_FONT_SIZE = HOME_ROW_TITLE_FONT_SIZE + 4
-- Home list text color tuning
local HOME_ROW_UNSELECTED_TITLE_BRIGHTNESS = 0.52
local HOME_ROW_UNSELECTED_TIMESTAMP_BRIGHTNESS = 0.38
local HOME_ROW_BUILTIN_TITLE_COLOR = { 1.0, 1.0, 1.0 }
local HOME_ROW_TITLE_SELECTED_COLOR = { 1.0, 1.0, 1.0 }
local HOME_ROW_TITLE_HOVER_COLOR = { 0.82, 0.82, 0.82 }
local HOME_ROW_TITLE_UNSELECTED_COLOR = {
    HOME_ROW_UNSELECTED_TITLE_BRIGHTNESS,
    HOME_ROW_UNSELECTED_TITLE_BRIGHTNESS,
    HOME_ROW_UNSELECTED_TITLE_BRIGHTNESS,
}
local HOME_ROW_TIMESTAMP_SELECTED_COLOR = { 0.64, 0.64, 0.64 }
local HOME_ROW_TIMESTAMP_UNSELECTED_COLOR = {
    HOME_ROW_UNSELECTED_TIMESTAMP_BRIGHTNESS,
    HOME_ROW_UNSELECTED_TIMESTAMP_BRIGHTNESS,
    HOME_ROW_UNSELECTED_TIMESTAMP_BRIGHTNESS,
}
local HOME_ROW_TIMESTAMP_DISPLAY_WIDTH = 138
local HOME_LIST_INNER_SHADOW_ATLAS = "insetshadow"
local HOME_LIST_INNER_SHADOW_ALPHA = 0.85
local HOME_LIST_INNER_SHADOW_INSET = 1
local NOTE_BODY_BORDER_COLOR = { 0.36, 0.36, 0.36, 0.82 }
local NOTE_BODY_BORDER_EDGE_SIZE = 14
local NOTE_BODY_BORDER_INSETS = { left = 4, right = 4, top = 4, bottom = 4 }
local NOTE_BODY_BORDER_OUTSET = 2
local NOTE_BODY_SHADOW_ATLAS = HOME_LIST_INNER_SHADOW_ATLAS
local NOTE_EDIT_BODY_SHADOW_ALPHA = HOME_LIST_INNER_SHADOW_ALPHA
local NOTE_EDIT_BODY_SHADOW_INSET = HOME_LIST_INNER_SHADOW_INSET
local NOTE_READ_BODY_SHADOW_ALPHA = HOME_LIST_INNER_SHADOW_ALPHA
local NOTE_READ_BODY_SHADOW_INSET = HOME_LIST_INNER_SHADOW_INSET
local NOTE_PREVIEW_BODY_SHADOW_ALPHA = HOME_LIST_INNER_SHADOW_ALPHA
local NOTE_PREVIEW_BODY_SHADOW_INSET = HOME_LIST_INNER_SHADOW_INSET

local function FormatHomeListTimestamp(timestamp, createdTimestamp)
    local safeTimestamp = tonumber(timestamp) or tonumber(createdTimestamp) or time()
    local safeCreated = tonumber(createdTimestamp) or safeTimestamp
    local prefix = safeTimestamp > safeCreated and "Updated" or "Created"

    local now = time()
    local nowDate = date("*t", now)
    local targetDate = date("*t", safeTimestamp)
    local dayStart = time({
        year = nowDate.year,
        month = nowDate.month,
        day = nowDate.day,
        hour = 0,
        min = 0,
        sec = 0,
    })
    local targetDayStart = time({
        year = targetDate.year,
        month = targetDate.month,
        day = targetDate.day,
        hour = 0,
        min = 0,
        sec = 0,
    })
    local dayDelta = math.floor((dayStart - targetDayStart) / 86400)

    if dayDelta <= 0 then
        return string.format("%s today · %s", prefix, date("%I:%M %p", safeTimestamp):gsub("^0", ""))
    end

    if dayDelta == 1 then
        return string.format("%s yday · %s", prefix, date("%I:%M %p", safeTimestamp):gsub("^0", ""))
    end

    if dayDelta < 7 then
        return string.format("%s %s · %s", prefix, date("%a", safeTimestamp), date("%I:%M %p", safeTimestamp):gsub("^0", ""))
    end

    return string.format("%s %s", prefix, date("%b %d", safeTimestamp))
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

local function ClearScrollFrameTemplateRegions(scrollFrame)
    if not scrollFrame or not scrollFrame.GetRegions then
        return
    end

    local regions = { scrollFrame:GetRegions() }
    for _, region in ipairs(regions) do
        if region and region.GetObjectType and region:GetObjectType() == "Texture" then
            region:SetTexture(nil)
            region:Hide()
        end
    end
end

-- Edit Gutter
local NOTE_EDIT_GUTTER_WIDTH = 18
local NOTE_EDIT_GUTTER_MAX_WIDTH = 144
local NOTE_EDIT_GUTTER_GAP = 6
local NOTE_EDIT_GUTTER_FONT = "Interface\\AddOns\\SnailNotes\\Media\\Fonts\\IBM-Plex-Mono\\IBMPlexMono-Medium.ttf"
local NOTE_EDIT_GUTTER_FONT_SIZE = 14
local NOTE_EDIT_GUTTER_TEXT_Y_OFFSET = 0
local NOTE_EDIT_GUTTER_RIGHT_PADDING = 6
local NOTE_EDIT_GUTTER_LEFT_PADDING = 4
local NOTE_EDIT_GUTTER_TEXT_COLOR = { 0.42, 0.42, 0.42, 0.95 }
local NOTE_EDIT_GUTTER_ACTIVE_TEXT_COLOR = { 1.00, 0.90, 0.20, 1.00 }
local NOTE_EDIT_GUTTER_BACKGROUND_COLOR = { 0, 0, 0, 0.36 }

-- Edit Font
local NOTE_EDIT_EDITOR_FONT = "Interface\\AddOns\\SnailNotes\\Media\\Fonts\\IBM-Plex-Mono\\IBMPlexMono-Medium.ttf"
local NOTE_EDIT_EDITOR_FONT_SIZE = 14
local NOTE_EDIT_EDITOR_VERTICAL_INSET = NOTE_TAB_FIELD_INNER_Y
local NOTE_EDIT_PREVIEW_CHECKBOX_X_OFFSET = -2
local NOTE_EDIT_PREVIEW_CHECKBOX_Y_OFFSET = -1
local NOTES_SCROLL_MULT = 1.25
local NOTES_MOUSE_WHEEL_SCROLL_STEP = 40
local RESIZE_START_JITTER_THRESHOLD = 2
local PREVIEW_WINDOW_SNAP_HORIZONTAL_THRESHOLD = 20
local PREVIEW_WINDOW_SNAP_MIN_VERTICAL_OVERLAP = 64

local function NextNoteBodyScrollFrameSerial()
    return shared.NextNoteBodyScrollFrameSerial()
end

local function GetCursorBaselinePosition()
    if not GetCursorPosition then
        return nil, nil
    end

    local cursorX, cursorY = GetCursorPosition()
    return tonumber(cursorX), tonumber(cursorY)
end

local function BeginResizeFromGrip(frame)
    if not frame then
        return
    end

    local cursorX, cursorY = GetCursorBaselinePosition()
    frame.resizeStartState = {
        width = frame:GetWidth(),
        height = frame:GetHeight(),
        cursorX = cursorX,
        cursorY = cursorY,
        hasMoved = false,
    }
end

local function HasResizeCursorMoved(frame)
    local resizeStartState = frame and frame.resizeStartState or nil
    if not resizeStartState then
        return true
    end
    if resizeStartState.hasMoved then
        return true
    end

    local cursorX, cursorY = GetCursorBaselinePosition()
    if not cursorX or not cursorY or not resizeStartState.cursorX or not resizeStartState.cursorY then
        resizeStartState.hasMoved = true
        return true
    end

    local deltaX = math.abs(cursorX - resizeStartState.cursorX)
    local deltaY = math.abs(cursorY - resizeStartState.cursorY)
    if deltaX > RESIZE_START_JITTER_THRESHOLD or deltaY > RESIZE_START_JITTER_THRESHOLD then
        resizeStartState.hasMoved = true
        return true
    end

    return false
end

local function EndResizeFromGrip(frame)
    if frame then
        frame.resizeStartState = nil
        frame.isSizingByGrip = nil
    end
end

local function ApplyNotesMouseWheelScroll(scrollFrame, delta)
    if not scrollFrame or not delta then
        return
    end

    local currentScroll = scrollFrame:GetVerticalScroll() or 0
    local maxScroll = math.max(scrollFrame.GetVerticalScrollRange and (scrollFrame:GetVerticalScrollRange() or 0) or 0, 0)
    if maxScroll <= 0 then
        scrollFrame:SetVerticalScroll(0)
        return
    end

    local newScroll = currentScroll - (delta * NOTES_MOUSE_WHEEL_SCROLL_STEP * NOTES_SCROLL_MULT)
    if newScroll < 0 then
        newScroll = 0
    elseif newScroll > maxScroll then
        newScroll = maxScroll
    end

    scrollFrame:SetVerticalScroll(newScroll)
end

local function ClearPreviewWindowSnapState(frame)
    if frame then
        frame.snappedToNotesRight = nil
    end
end

local function UpdateSnappedPreviewWindowPosition(frame, shouldSaveGeometry)
    if not frame or not frame:IsShown() or not frame.snappedToNotesRight then
        return false
    end

    local runtime = module and module.runtime or nil
    local notesFrame = runtime and runtime.frame or nil
    if not notesFrame or not notesFrame:IsShown() then
        return false
    end

    local notesRight = notesFrame:GetRight()
    local notesTop = notesFrame:GetTop()
    local notesBottom = notesFrame:GetBottom()
    if not notesRight or not notesTop or not notesBottom then
        return false
    end

    local snappedWidth = frame:GetWidth()
    local snappedHeight = notesTop - notesBottom
    if module and module.ClampPreviewWindowSize then
        snappedWidth, snappedHeight = module:ClampPreviewWindowSize(snappedWidth, snappedHeight)
    end

    frame:SetSize(snappedWidth, snappedHeight)

    local targetLeft = notesRight
    local targetBottom = notesTop - snappedHeight
    frame:ClearAllPoints()
    frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", targetLeft, targetBottom)
    if module and module.EnsureWindowGeometryIsReachable then
        module:EnsureWindowGeometryIsReachable(frame)
    end
    if shouldSaveGeometry and module and module.SavePreviewWindowGeometry then
        module:SavePreviewWindowGeometry(frame)
    end

    return true
end

local function TrySnapPreviewWindowToNotesWindow(frame)
    if not frame or not frame:IsShown() then
        return false
    end

    local runtime = module and module.runtime or nil
    local notesFrame = runtime and runtime.frame or nil
    if not notesFrame or not notesFrame:IsShown() then
        return false
    end

    local notesRight = notesFrame:GetRight()
    local notesTop = notesFrame:GetTop()
    local notesBottom = notesFrame:GetBottom()
    local previewLeft = frame:GetLeft()
    local previewTop = frame:GetTop()
    local previewBottom = frame:GetBottom()
    if not notesRight or not notesTop or not notesBottom or not previewLeft or not previewTop or not previewBottom then
        return false
    end

    local horizontalDistance = math.abs(previewLeft - notesRight)
    local verticalOverlap = math.min(previewTop, notesTop) - math.max(previewBottom, notesBottom)
    if horizontalDistance > PREVIEW_WINDOW_SNAP_HORIZONTAL_THRESHOLD or verticalOverlap < PREVIEW_WINDOW_SNAP_MIN_VERTICAL_OVERLAP then
        ClearPreviewWindowSnapState(frame)
        return false
    end

    frame.snappedToNotesRight = true
    if not UpdateSnappedPreviewWindowPosition(frame, false) then
        ClearPreviewWindowSnapState(frame)
        return false
    end

    return true
end

local function GetNoteEditLineCount(text)
    local normalized = tostring(text or "")
    normalized = string.gsub(normalized, "\r\n", "\n")
    normalized = string.gsub(normalized, "\r", "\n")
    local _, lineCount = string.gsub(normalized, "\n", "")
    return math.max(1, (tonumber(lineCount) or 0) + 1)
end

local function BuildNoteEditLineNumberText(lineCount)
    local lines = {}
    for index = 1, math.max(tonumber(lineCount) or 1, 1) do
        lines[index] = tostring(index)
    end
    return table.concat(lines, "\n")
end

local function GetNoteEditViewportWidth(view)
    if not view or not view.bodyScrollFrame then
        return 1
    end

    return math.max(view.bodyScrollFrame:GetWidth() or 0, 1)
end

local function GetOrCreateNoteEditWrapMeasure(view)
    if not view or not view.bodyFrame then
        return nil
    end

    if view.lineWrapMeasure then
        return view.lineWrapMeasure
    end

    local measure = view.bodyFrame:CreateFontString(nil, "ARTWORK")
    measure:Hide()
    measure:SetFont(NOTE_EDIT_EDITOR_FONT, NOTE_EDIT_EDITOR_FONT_SIZE, "")
    measure:SetJustifyH("LEFT")
    measure:SetJustifyV("TOP")
    measure:SetWordWrap(false)
    if measure.SetNonSpaceWrap then
        measure:SetNonSpaceWrap(false)
    end
    measure:SetShadowOffset(0, 0)
    measure:SetShadowColor(0, 0, 0, 0)
    view.lineWrapMeasure = measure
    return measure
end

local function GetOrCreateNoteEditGutterMeasure(view)
    if not view or not view.bodyFrame then
        return nil
    end

    if view.lineNumberMeasure then
        return view.lineNumberMeasure
    end

    local measure = view.bodyFrame:CreateFontString(nil, "ARTWORK")
    measure:Hide()
    measure:SetFont(NOTE_EDIT_GUTTER_FONT, NOTE_EDIT_GUTTER_FONT_SIZE, "")
    measure:SetJustifyH("LEFT")
    measure:SetJustifyV("TOP")
    measure:SetWordWrap(false)
    if measure.SetNonSpaceWrap then
        measure:SetNonSpaceWrap(false)
    end
    measure:SetShadowOffset(0, 0)
    measure:SetShadowColor(0, 0, 0, 0)
    view.lineNumberMeasure = measure
    return measure
end

local function GetNoteEditAvailableTextWidth(view)
    local viewportWidth = GetNoteEditViewportWidth(view)
    return math.max(viewportWidth - (NOTE_TAB_FIELD_INNER_X * 2), 1)
end

local function GetNoteEditActiveLineNumber(view)
    if not view or not view.bodyInput then
        return 1
    end

    local text = tostring(view.bodyInput:GetText() or "")
    local cursorPosition = math.max(tonumber(view.bodyInput:GetCursorPosition()) or 0, 0)
    local cursorText = string.sub(text, 1, cursorPosition)
    local _, newlineCount = string.gsub(cursorText, "\n", "")
    return math.max((tonumber(newlineCount) or 0) + 1, 1)
end

local function GetNoteEditGutterColorCode(color)
    local r = math.floor(math.max(math.min((color and color[1]) or 1, 1), 0) * 255)
    local g = math.floor(math.max(math.min((color and color[2]) or 1, 1), 0) * 255)
    local b = math.floor(math.max(math.min((color and color[3]) or 1, 1), 0) * 255)
    return string.format("|cff%02x%02x%02x", r, g, b)
end

local function GetNoteEditDesiredGutterWidth(view)
    if not view or not view.bodyInput then
        return NOTE_EDIT_GUTTER_WIDTH
    end

    local lineCount = GetNoteEditLineCount(view.bodyInput:GetText())
    local digitCount = string.len(tostring(math.max(lineCount, 1)))
    local measure = GetOrCreateNoteEditGutterMeasure(view)
    local desiredWidth = NOTE_EDIT_GUTTER_WIDTH

    if measure then
        measure:SetText(string.rep("8", digitCount))
        desiredWidth = math.ceil((measure:GetStringWidth() or 0) + NOTE_EDIT_GUTTER_LEFT_PADDING + NOTE_EDIT_GUTTER_RIGHT_PADDING + 2)
    end

    desiredWidth = math.max(desiredWidth, NOTE_EDIT_GUTTER_WIDTH)
    desiredWidth = math.min(desiredWidth, NOTE_EDIT_GUTTER_MAX_WIDTH)
    return desiredWidth
end

local function BuildNoteEditWrappedLineNumberText(view)
    local text = view and view.bodyInput and tostring(view.bodyInput:GetText() or "") or ""
    local activeLine = GetNoteEditActiveLineNumber(view)
    local availableWidth = GetNoteEditAvailableTextWidth(view)
    local measure = GetOrCreateNoteEditWrapMeasure(view)
    local normalColor = GetNoteEditGutterColorCode(NOTE_EDIT_GUTTER_TEXT_COLOR)
    local activeColor = GetNoteEditGutterColorCode(NOTE_EDIT_GUTTER_ACTIVE_TEXT_COLOR)
    local gutterLines = {}
    local logicalLine = 0

    for line in string.gmatch(text .. "\n", "([^\n]*\n?)") do
        if #line > 0 then
            logicalLine = logicalLine + 1

            local colorCode = logicalLine == activeLine and activeColor or normalColor
            gutterLines[#gutterLines + 1] = string.format("%s%d|r", colorCode, logicalLine)

            local strippedLine = string.gsub(line, "\n$", "", 1)
            local extraWrapLines = 0
            if measure and strippedLine ~= "" then
                measure:SetText(strippedLine:gsub("|", "||"))
                local stringWidth = measure:GetStringWidth() or 0
                if stringWidth >= availableWidth then
                    extraWrapLines = math.floor(stringWidth / availableWidth)
                end
            end

            for _ = 1, extraWrapLines do
                gutterLines[#gutterLines + 1] = ""
            end
        end
    end

    if logicalLine == 0 then
        gutterLines[1] = string.format("%s1|r", activeColor)
    end

    return table.concat(gutterLines, "\n"), #gutterLines
end

local function UpdateNoteEditScrollBar(view)
    if not view or not view.bodyScrollFrame or not view.bodyScrollBar then
        return
    end

    local scrollBar = view.bodyScrollBar
    local scrollOffset = view.bodyScrollFrame:GetVerticalScroll() or 0
    local scrollRange = view.bodyScrollFrame.GetVerticalScrollRange and (view.bodyScrollFrame:GetVerticalScrollRange() or 0) or 0
    local maxScroll = math.max(scrollRange, 0)
    local hasScrollableRange = maxScroll > 0.5

    scrollBar:SetMinMaxValues(0, maxScroll)
    scrollBar:SetValue(math.max(0, math.min(scrollOffset, maxScroll)))
    scrollBar:SetShown(hasScrollableRange)

    local upButton = _G[scrollBar:GetName() .. "ScrollUpButton"]
    local downButton = _G[scrollBar:GetName() .. "ScrollDownButton"]
    if upButton then
        if scrollOffset <= 0 then
            upButton:Disable()
        else
            upButton:Enable()
        end
    end
    if downButton then
        if scrollOffset >= maxScroll then
            downButton:Disable()
        else
            downButton:Enable()
        end
    end
end

local function SyncNoteEditGutterScroll(view)
    if not view or not view.lineNumberScrollFrame or not view.bodyScrollFrame then
        return
    end

    local scrollOffset = view.bodyScrollFrame:GetVerticalScroll() or 0
    view.lineNumberScrollFrame:SetVerticalScroll(scrollOffset)
end

local function GetOrCreateNoteEditLineNumberWidget(view)
    if not view or not view.lineNumberScrollFrame then
        return nil
    end

    if view.lineNumberText then
        return view.lineNumberText
    end

    local text = CreateFrame("EditBox", nil, view.lineNumberScrollFrame)
    text:SetAutoFocus(false)
    text:SetMultiLine(true)
    text:SetMaxLetters(0)
    text:ClearAllPoints()
    text:SetPoint("TOPLEFT", view.lineNumberScrollFrame, "TOPLEFT", 0, 0)
    text:SetFont(NOTE_EDIT_GUTTER_FONT, NOTE_EDIT_GUTTER_FONT_SIZE, "")
    text:SetShadowOffset(0, 0)
    text:SetShadowColor(0, 0, 0, 0)
    text:SetTextColor(unpack(NOTE_EDIT_GUTTER_TEXT_COLOR))
    text:SetTextInsets(NOTE_EDIT_GUTTER_LEFT_PADDING, NOTE_EDIT_GUTTER_RIGHT_PADDING, NOTE_EDIT_EDITOR_VERTICAL_INSET + NOTE_EDIT_GUTTER_TEXT_Y_OFFSET, NOTE_EDIT_EDITOR_VERTICAL_INSET)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    if text.SetWordWrap then
        text:SetWordWrap(false)
    end
    if text.SetNonSpaceWrap then
        text:SetNonSpaceWrap(false)
    end
    text:EnableMouse(false)
    if text.EnableKeyboard then
        text:EnableKeyboard(false)
    end
    text:SetScript("OnEditFocusGained", function(self)
        self:ClearFocus()
    end)
    view.lineNumberText = text
    view.lineNumberScrollFrame:SetScrollChild(text)
    return text
end

local function UpdateNoteEditLineNumbers(tab, view)
    if not view or not view.bodyInput or not view.lineNumberScrollFrame then
        return
    end

    local desiredGutterWidth = GetNoteEditDesiredGutterWidth(view)
    if view.lineNumberGutter and math.abs((view.lineNumberGutter:GetWidth() or 0) - desiredGutterWidth) > 0.5 then
        view.lineNumberGutter:SetWidth(desiredGutterWidth)
        if tab then
            module:UpdateNoteBodyEditLayout(tab)
        end
    end

    local text = GetOrCreateNoteEditLineNumberWidget(view)
    if not text then
        return
    end

    local lineText, renderedLineCount = BuildNoteEditWrappedLineNumberText(view)

    text:SetFont(NOTE_EDIT_GUTTER_FONT, NOTE_EDIT_GUTTER_FONT_SIZE, "")
    text:SetShadowOffset(0, 0)
    text:SetShadowColor(0, 0, 0, 0)
    text:SetTextColor(unpack(NOTE_EDIT_GUTTER_TEXT_COLOR))
    text:SetTextInsets(NOTE_EDIT_GUTTER_LEFT_PADDING, NOTE_EDIT_GUTTER_RIGHT_PADDING, NOTE_EDIT_EDITOR_VERTICAL_INSET + NOTE_EDIT_GUTTER_TEXT_Y_OFFSET, NOTE_EDIT_EDITOR_VERTICAL_INSET)
    text:SetJustifyH("LEFT")
    if text.SetWordWrap then
        text:SetWordWrap(false)
    end
    if text.SetNonSpaceWrap then
        text:SetNonSpaceWrap(false)
    end
    text:SetWidth(math.max(view.lineNumberScrollFrame:GetWidth() or (view.lineNumberGutter and view.lineNumberGutter:GetWidth() or NOTE_EDIT_GUTTER_WIDTH), 1))
    text:SetText(lineText)
    text:SetHeight(math.max(view.bodyInput:GetHeight() or 0, view.lineNumberScrollFrame:GetHeight() or 0, NOTE_TAB_BODY_MIN_CONTENT_HEIGHT, renderedLineCount * NOTE_EDIT_EDITOR_FONT_SIZE))
    text:SetCursorPosition(0)
    SyncNoteEditGutterScroll(view)
end

local function RefreshNoteEditBody(tab, options)
    local view = module and module.GetNoteTabEditView and module:GetNoteTabEditView(tab and tab.panel) or nil
    if not tab or not view or not view.bodyInput or not view.bodyScrollFrame then
        return
    end

    if not view:IsShown() then
        return
    end

    options = options or {}

    local previousCursor = view.bodyInput:GetCursorPosition() or 0
    local previousScroll = view.bodyScrollFrame:GetVerticalScroll() or 0

    module:UpdateNoteBodyEditLayout(tab)
    view.bodyInput:SetWidth(math.max(GetNoteEditViewportWidth(view), 1))

    if options.resetScroll then
        view.bodyScrollFrame:SetVerticalScroll(0)
    else
        local maxScroll = math.max(view.bodyScrollFrame.GetVerticalScrollRange and (view.bodyScrollFrame:GetVerticalScrollRange() or 0) or 0, 0)
        view.bodyScrollFrame:SetVerticalScroll(math.max(0, math.min(previousScroll, maxScroll)))
    end

    if options.focusEditor then
        view.bodyInput:SetFocus()
        view.bodyInput:SetCursorPosition(math.max(tonumber(options.cursorPosition) or 0, 0))
        if ScrollingEdit_OnCursorChanged then
            ScrollingEdit_OnCursorChanged(view.bodyInput, 0, 0, view.bodyInput:GetWidth() or 0, view.bodyInput:GetHeight() or 0)
        end
        if view.bodyInput.HighlightText then
            view.bodyInput:HighlightText(0, 0)
        end
    else
        view.bodyInput:SetCursorPosition(previousCursor or 0)
    end

    UpdateNoteEditLineNumbers(tab, view)
    UpdateNoteEditScrollBar(view)
    SyncNoteEditGutterScroll(view)
end

local function FocusNoteEditBodyToEnd(view)
    if not view or not view.bodyInput then
        return
    end

    local editBox = view.bodyInput
    local text = tostring(editBox:GetText() or "")
    local cursorPosition = string.len(text)

    editBox:SetFocus()
    if editBox.HighlightText then
        editBox:HighlightText(0, 0)
    end
    if editBox.SetCursorPosition then
        editBox:SetCursorPosition(cursorPosition)
    end
    if ScrollingEdit_OnCursorChanged then
        ScrollingEdit_OnCursorChanged(editBox, 0, 0, editBox:GetWidth() or 0, editBox:GetHeight() or 0)
    end
end

function module:CreateNoteEditView(parent)
    local view = CreateFrame("Frame", nil, parent)
    view:SetAllPoints()

    view.topRow = CreateFrame("Frame", nil, view)
    view.topRow:SetHeight(NOTE_TAB_TOP_ROW_HEIGHT)
    view.topRow:SetPoint("TOPLEFT", NOTE_TAB_SIDE_INSET, -NOTE_TAB_TOP_ROW_TOP_OFFSET)
    view.topRow:SetPoint("TOPRIGHT", -NOTE_TAB_SIDE_INSET, -NOTE_TAB_TOP_ROW_TOP_OFFSET)

    view.saveButton = CreateFrame("Button", nil, view.topRow, "UIPanelButtonTemplate")
    view.saveButton:SetSize(NOTE_TAB_SAVE_BUTTON_WIDTH, NOTE_TAB_TOP_ROW_HEIGHT)
    view.saveButton:SetText("Save")

    view.modeButton = CreateFrame("Button", nil, view.topRow, "UIPanelButtonTemplate")
    view.modeButton:SetSize(NOTE_TAB_MODE_BUTTON_WIDTH, NOTE_TAB_TOP_ROW_HEIGHT)
    view.modeButton:SetText("Cancel")

    view.deleteButton = CreateFrame("Button", nil, view.topRow, "UIPanelButtonTemplate")
    view.deleteButton:SetSize(NOTE_TAB_DELETE_BUTTON_WIDTH, NOTE_TAB_TOP_ROW_HEIGHT)
    view.deleteButton:SetText("Delete")

    view.closeButton = CreateFrame("Button", nil, view.topRow, "UIPanelCloseButton")
    view.closeButton:SetSize(NOTE_TAB_TOP_CLOSE_BUTTON_SIZE, NOTE_TAB_TOP_CLOSE_BUTTON_SIZE)
    view.closeButton:ClearAllPoints()
    view.closeButton:SetPoint("RIGHT", view.topRow, "RIGHT", -NOTE_TAB_TOP_ROW_CLOSE_BUTTON_RIGHT_INSET, 0)
    view.closeButton:SetHitRectInsets(
        NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_LEFT,
        NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_RIGHT,
        NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_TOP,
        NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_BOTTOM
    )

    view.saveButton:ClearAllPoints()
    view.saveButton:SetPoint("RIGHT", view.closeButton, "LEFT", -NOTE_TAB_TOP_CLOSE_BUTTON_SPACING, 0)

    view.modeButton:ClearAllPoints()
    view.modeButton:SetPoint("RIGHT", view.saveButton, "LEFT", -4, 0)

    view.deleteButton:ClearAllPoints()
    view.deleteButton:SetPoint("RIGHT", view.modeButton, "LEFT", -4, 0)

    view.previewToggle = CreateFrame("Frame", nil, view.topRow)
    view.previewToggle:SetHeight(NOTE_TAB_TOP_ROW_HEIGHT)
    view.previewToggle:SetPoint("RIGHT", view.deleteButton, "LEFT", -6, 0)
    view.previewToggle:SetWidth(78)

    view.previewLabelButton = CreateFrame("Button", nil, view.previewToggle)
    view.previewLabelButton:SetHeight(NOTE_TAB_TOP_ROW_HEIGHT)
    view.previewLabelButton:SetPoint("LEFT", view.previewToggle, "LEFT", 0, 0)
    view.previewLabelButton:SetWidth(48)

    view.previewLabelText = view.previewLabelButton:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    view.previewLabelText:SetAllPoints()
    view.previewLabelText:SetJustifyH("LEFT")
    view.previewLabelText:SetJustifyV("MIDDLE")
    view.previewLabelText:SetText("Preview")

    view.previewCheck = CreateFrame("CheckButton", nil, view.previewToggle, "UICheckButtonTemplate")
    view.previewCheck:ClearAllPoints()
    view.previewCheck:SetPoint("LEFT", view.previewLabelButton, "RIGHT", NOTE_EDIT_PREVIEW_CHECKBOX_X_OFFSET, NOTE_EDIT_PREVIEW_CHECKBOX_Y_OFFSET)

    view.titleInput = CreateFrame("EditBox", nil, view.topRow, "InputBoxTemplate")
    view.titleInput:SetAutoFocus(false)
    view.titleInput:SetMaxLetters(NOTE_TITLE_MAX_LENGTH)
    view.titleInput:SetFontObject(GameFontHighlightLarge)
    view.titleInput:SetSize(NOTE_TAB_TITLE_WIDTH, NOTE_TAB_TOP_ROW_HEIGHT)
    view.titleInput:SetPoint("LEFT", 0, 0)
    view.titleInput:SetJustifyH("LEFT")
    view.titleInput:SetTextInsets(0, 0, 0, 0)

    view.metaText = view.topRow:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    view.metaText:SetPoint("LEFT", view.titleInput, "RIGHT", NOTE_TAB_TITLE_TO_META_SPACING, 0)
    view.metaText:SetPoint("RIGHT", view.previewToggle, "LEFT", -12, 0)
    view.metaText:SetJustifyH("LEFT")
    view.metaText:SetJustifyV("MIDDLE")

    view.bodyFrame = CreateFrame("Frame", nil, view)
    view.bodyFrame:SetPoint("TOPLEFT", NOTE_TAB_SIDE_INSET, -(NOTE_TAB_TOP_ROW_TOP_OFFSET + NOTE_TAB_TOP_ROW_HEIGHT + NOTE_TAB_TOP_ROW_TO_BODY_GAP))
    view.bodyFrame:SetPoint("TOPRIGHT", -NOTE_TAB_SIDE_INSET, -(NOTE_TAB_TOP_ROW_TOP_OFFSET + NOTE_TAB_TOP_ROW_HEIGHT + NOTE_TAB_TOP_ROW_TO_BODY_GAP))
    view.bodyFrame:SetPoint("BOTTOMLEFT", NOTE_TAB_SIDE_INSET, NOTE_TAB_BOTTOM_INSET)
    view.bodyFrame:SetPoint("BOTTOMRIGHT", -NOTE_TAB_SIDE_INSET, NOTE_TAB_BOTTOM_INSET)

    view.bodyBackground = view.bodyFrame:CreateTexture(nil, "BACKGROUND")
    view.bodyBackground:SetAllPoints()
    do
        local red, green, blue = HexToColorRGB(HOME_LIST_BACKGROUND_HEX)
        view.bodyBackground:SetColorTexture(red, green, blue, HOME_LIST_BACKGROUND_ALPHA)
    end

    view.bodyFallbackFill = view.bodyFrame:CreateTexture(nil, "BACKGROUND", nil, -1)
    view.bodyFallbackFill:SetAllPoints()
    view.bodyFallbackFill:SetTexture("Interface\\Buttons\\WHITE8x8")
    view.bodyFallbackFill:SetVertexColor(unpack(NOTE_TAB_BODY_BACKGROUND_FALLBACK_COLOR))
    view.bodyFallbackFill:Hide()
    view.bodyFrame:EnableMouse(true)

    view.bodyBorderFrame = ApplyTooltipBorderToRegion(view, view.bodyFrame)
    view.bodyShadowBounds, view.bodyShadowTexture = ApplyInsetShadowToRegion(
        view.bodyFrame,
        view.bodyFrame,
        NOTE_BODY_SHADOW_ATLAS,
        NOTE_EDIT_BODY_SHADOW_ALPHA,
        NOTE_EDIT_BODY_SHADOW_INSET
    )

    view.lineNumberGutter = CreateFrame("Frame", nil, view.bodyFrame)
    view.lineNumberGutter:SetPoint("TOPLEFT", view.bodyFrame, "TOPLEFT", NOTE_TAB_FIELD_INNER_X, -NOTE_TAB_FIELD_INNER_Y)
    view.lineNumberGutter:SetPoint("BOTTOMLEFT", view.bodyFrame, "BOTTOMLEFT", NOTE_TAB_FIELD_INNER_X, NOTE_TAB_FIELD_INNER_Y)
    view.lineNumberGutter:SetWidth(NOTE_EDIT_GUTTER_WIDTH)
    view.lineNumberGutter:EnableMouse(false)
    view.lineNumberGutter:SetFrameLevel((view.bodyShadowBounds:GetFrameLevel() or 1) + 1)
    view.lineNumberGap = NOTE_EDIT_GUTTER_GAP

    view.lineNumberBackground = view.lineNumberGutter:CreateTexture(nil, "ARTWORK")
    view.lineNumberBackground:SetAllPoints()
    view.lineNumberBackground:SetTexture("Interface\\Buttons\\WHITE8x8")
    view.lineNumberBackground:SetVertexColor(unpack(NOTE_EDIT_GUTTER_BACKGROUND_COLOR))

    view.lineNumberScrollFrame = CreateFrame("ScrollFrame", nil, view.lineNumberGutter)
    view.lineNumberScrollFrame:SetAllPoints()
    view.lineNumberScrollFrame:EnableMouse(false)

    local scrollFrameSerial = NextNoteBodyScrollFrameSerial()
    view.bodyScrollFrameName = "SnailNotesBodyScrollFrame" .. tostring(scrollFrameSerial)
    view.bodyScrollFrame = CreateFrame("ScrollFrame", view.bodyScrollFrameName, view.bodyFrame, "UIPanelScrollFrameTemplate")
    view.bodyScrollBar = _G[view.bodyScrollFrameName .. "ScrollBar"]
    ClearScrollFrameTemplateRegions(view.bodyScrollFrame)
    view.bodyScrollFrame:SetFrameLevel((view.bodyShadowBounds:GetFrameLevel() or 1) + 1)
    view.bodyScrollFrame.scrollBarHideable = 1
    view.bodyScrollFrame:SetScript("OnVerticalScroll", function()
        SyncNoteEditGutterScroll(view)
        UpdateNoteEditScrollBar(view)
    end)
    view.bodyScrollFrame:SetScript("OnShow", function()
        SyncNoteEditGutterScroll(view)
        UpdateNoteEditScrollBar(view)
    end)
    if view.bodyScrollFrame.EnableMouseWheel then
        view.bodyScrollFrame:EnableMouseWheel(true)
    end
    view.bodyScrollFrame:SetScript("OnMouseWheel", function(selfFrame, delta)
        ApplyNotesMouseWheelScroll(selfFrame, delta)
    end)
    if view.bodyScrollBar then
        view.bodyScrollBar:Hide()
    end

    view.bodyInput = CreateFrame("EditBox", nil, view.bodyScrollFrame)
    view.bodyInput:SetAutoFocus(false)
    view.bodyInput:SetMultiLine(true)
    view.bodyInput:SetMaxLetters(0)
    view.bodyInput:SetFont(NOTE_EDIT_EDITOR_FONT, NOTE_EDIT_EDITOR_FONT_SIZE, "")
    view.bodyInput:SetShadowOffset(0, 0)
    view.bodyInput:SetShadowColor(0, 0, 0, 0)
    view.bodyInput:SetTextInsets(NOTE_TAB_FIELD_INNER_X, NOTE_TAB_FIELD_INNER_X, NOTE_EDIT_EDITOR_VERTICAL_INSET, NOTE_EDIT_EDITOR_VERTICAL_INSET)
    view.bodyInput:SetJustifyH("LEFT")
    view.bodyInput:SetJustifyV("TOP")
    view.bodyInput:EnableMouse(true)
    view.bodyInput:SetBlinkSpeed(0.5)
    view.bodyInput:ClearAllPoints()
    view.bodyInput:SetPoint("TOPLEFT", view.bodyScrollFrame, "TOPLEFT", 0, 0)
    view.bodyInput:SetPoint("BOTTOMRIGHT", view.bodyScrollFrame, "BOTTOMRIGHT", 0, 0)
    if view.bodyInput.SetCountInvisibleLetters then
        view.bodyInput:SetCountInvisibleLetters(false)
    end

    view.bodyScrollFrame:SetScrollChild(view.bodyInput)
    view.bodyScrollFrame:EnableMouse(true)

    return view
end

function module:CreateNotePreviewContentView(parent)
    local view = CreateFrame("Frame", nil, parent)
    view:SetAllPoints()

    view.titleText = view:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    view.titleText:SetPoint("TOPLEFT", NOTE_TAB_SIDE_INSET, -(NOTE_TAB_TOP_ROW_TOP_OFFSET + 2))
    view.titleText:SetPoint("TOPRIGHT", -NOTE_TAB_SIDE_INSET, -(NOTE_TAB_TOP_ROW_TOP_OFFSET + 2))
    view.titleText:SetJustifyH("LEFT")
    view.titleText:SetJustifyV("TOP")

    view.bodyFrame = CreateFrame("Frame", nil, view)
    view.bodyFrame:SetPoint("TOPLEFT", NOTE_TAB_SIDE_INSET, -(NOTE_TAB_TOP_ROW_TOP_OFFSET + NOTE_TAB_TOP_ROW_HEIGHT + NOTE_TAB_TOP_ROW_TO_BODY_GAP))
    view.bodyFrame:SetPoint("TOPRIGHT", -NOTE_TAB_SIDE_INSET, -(NOTE_TAB_TOP_ROW_TOP_OFFSET + NOTE_TAB_TOP_ROW_HEIGHT + NOTE_TAB_TOP_ROW_TO_BODY_GAP))
    view.bodyFrame:SetPoint("BOTTOMLEFT", NOTE_TAB_SIDE_INSET, NOTE_TAB_BOTTOM_INSET)
    view.bodyFrame:SetPoint("BOTTOMRIGHT", -NOTE_TAB_SIDE_INSET, NOTE_TAB_BOTTOM_INSET)

    view.bodyBackground = view.bodyFrame:CreateTexture(nil, "BACKGROUND")
    view.bodyBackground:SetAllPoints()
    if NOTE_TAB_BODY_BACKGROUND_ATLAS and NOTE_TAB_BODY_BACKGROUND_ATLAS ~= "" then
        view.bodyBackground:SetAtlas(NOTE_TAB_BODY_BACKGROUND_ATLAS, true)
        view.bodyBackground:SetVertexColor(unpack(NOTE_TAB_BODY_BACKGROUND_COLOR))
    else
        view.bodyBackground:SetTexture("Interface\\Buttons\\WHITE8x8")
        view.bodyBackground:SetVertexColor(unpack(NOTE_TAB_BODY_BACKGROUND_FALLBACK_COLOR))
    end

    view.bodyFallbackFill = view.bodyFrame:CreateTexture(nil, "BACKGROUND", nil, -1)
    view.bodyFallbackFill:SetAllPoints()
    view.bodyFallbackFill:SetTexture("Interface\\Buttons\\WHITE8x8")
    view.bodyFallbackFill:SetVertexColor(unpack(NOTE_TAB_BODY_BACKGROUND_FALLBACK_COLOR))
    view.bodyFallbackFill:SetShown(not (NOTE_TAB_BODY_BACKGROUND_ATLAS and NOTE_TAB_BODY_BACKGROUND_ATLAS ~= ""))

    view.bodyBorderFrame = ApplyTooltipBorderToRegion(view, view.bodyFrame)
    view.bodyShadowBounds, view.bodyShadowTexture = ApplyInsetShadowToRegion(
        view.bodyFrame,
        view.bodyFrame,
        NOTE_BODY_SHADOW_ATLAS,
        NOTE_PREVIEW_BODY_SHADOW_ALPHA,
        NOTE_PREVIEW_BODY_SHADOW_INSET
    )

    local scrollFrameSerial = NextNoteBodyScrollFrameSerial()
    view.bodyScrollFrameName = "SnailNotesPreviewScrollFrame" .. tostring(scrollFrameSerial)
    view.bodyScrollFrame = CreateFrame("ScrollFrame", view.bodyScrollFrameName, view.bodyFrame, "UIPanelScrollFrameTemplate")
    view.bodyScrollBar = _G[view.bodyScrollFrameName .. "ScrollBar"]
    ClearScrollFrameTemplateRegions(view.bodyScrollFrame)
    view.bodyScrollFrame:SetFrameLevel((view.bodyShadowBounds:GetFrameLevel() or 1) + 1)

    view.bodyContent = CreateFrame("Frame", nil, view.bodyScrollFrame)
    view.bodyContent:SetPoint("TOPLEFT", view.bodyScrollFrame, "TOPLEFT", 0, 0)
    view.bodyContent:SetPoint("TOPRIGHT", view.bodyScrollFrame, "TOPRIGHT", 0, 0)
    view.bodyContent:SetHeight(NOTE_TAB_BODY_MIN_CONTENT_HEIGHT)
    view.bodyContent:SetFrameLevel((view.bodyShadowBounds:GetFrameLevel() or 1) + 1)
    view.bodyScrollFrame:SetScrollChild(view.bodyContent)
    if view.bodyScrollFrame.EnableMouseWheel then
        view.bodyScrollFrame:EnableMouseWheel(true)
    end
    view.bodyScrollFrame:SetScript("OnMouseWheel", function(selfFrame, delta)
        ApplyNotesMouseWheelScroll(selfFrame, delta)
    end)

    view.bodyFrame:SetScript("OnSizeChanged", function()
        module:UpdateStandaloneReadViewLayout(view)
    end)

    return view
end

function module:CreateNoteReadView(parent)
    local view = CreateFrame("Frame", nil, parent)
    view:SetAllPoints()

    view.topRow = CreateFrame("Frame", nil, view)
    view.topRow:SetHeight(NOTE_TAB_TOP_ROW_HEIGHT)
    view.topRow:SetPoint("TOPLEFT", NOTE_TAB_SIDE_INSET, -NOTE_TAB_TOP_ROW_TOP_OFFSET)
    view.topRow:SetPoint("TOPRIGHT", -NOTE_TAB_SIDE_INSET, -NOTE_TAB_TOP_ROW_TOP_OFFSET)

    view.closeButton = CreateFrame("Button", nil, view.topRow, "UIPanelCloseButton")
    view.closeButton:SetSize(NOTE_TAB_TOP_CLOSE_BUTTON_SIZE, NOTE_TAB_TOP_CLOSE_BUTTON_SIZE)
    view.closeButton:ClearAllPoints()
    view.closeButton:SetPoint("RIGHT", view.topRow, "RIGHT", -NOTE_TAB_TOP_ROW_CLOSE_BUTTON_RIGHT_INSET, 0)
    view.closeButton:SetHitRectInsets(
        NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_LEFT,
        NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_RIGHT,
        NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_TOP,
        NOTE_TAB_TOP_CLOSE_BUTTON_HIT_RECT_BOTTOM
    )

    view.modeButton = CreateFrame("Button", nil, view.topRow, "UIPanelButtonTemplate")
    view.modeButton:SetSize(NOTE_TAB_MODE_BUTTON_WIDTH, NOTE_TAB_TOP_ROW_HEIGHT)
    view.modeButton:SetText("Edit")
    view.modeButton:SetPoint("RIGHT", view.closeButton, "LEFT", -NOTE_TAB_TOP_CLOSE_BUTTON_SPACING, 0)

    view.deleteButton = CreateFrame("Button", nil, view.topRow, "UIPanelButtonTemplate")
    view.deleteButton:SetSize(NOTE_TAB_DELETE_BUTTON_WIDTH, NOTE_TAB_TOP_ROW_HEIGHT)
    view.deleteButton:SetText("Delete")
    view.deleteButton:SetPoint("RIGHT", view.modeButton, "LEFT", -4, 0)

    view.exportButton = CreateFrame("Button", nil, view.topRow, "UIPanelButtonTemplate")
    view.exportButton:SetSize(NOTE_TAB_EXPORT_BUTTON_WIDTH, NOTE_TAB_TOP_ROW_HEIGHT)
    view.exportButton:SetText("Export")
    view.exportButton:SetPoint("RIGHT", view.deleteButton, "LEFT", -4, 0)

    view.linkButton = CreateFrame("Button", nil, view.topRow, "UIPanelButtonTemplate")
    view.linkButton:SetSize(NOTE_TAB_EXPORT_BUTTON_WIDTH, NOTE_TAB_TOP_ROW_HEIGHT)
    view.linkButton:SetText("Link")
    view.linkButton:SetPoint("RIGHT", view.exportButton, "LEFT", -4, 0)

    view.titleText = view.topRow:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    view.titleText:SetWidth(NOTE_TAB_TITLE_WIDTH)
    view.titleText:SetPoint("LEFT", 0, 0)
    view.titleText:SetJustifyH("LEFT")
    view.titleText:SetJustifyV("MIDDLE")

    view.metaText = view.topRow:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    view.metaText:SetPoint("LEFT", view.titleText, "RIGHT", NOTE_TAB_TITLE_TO_META_SPACING, 0)
    view.metaText:SetPoint("RIGHT", view.linkButton, "LEFT", -NOTE_TAB_READ_TITLE_RIGHT_INSET, 0)
    view.metaText:SetJustifyH("LEFT")
    view.metaText:SetJustifyV("MIDDLE")

    view.bodyFrame = CreateFrame("Frame", nil, view)
    view.bodyFrame:SetPoint("TOPLEFT", NOTE_TAB_SIDE_INSET, -(NOTE_TAB_TOP_ROW_TOP_OFFSET + NOTE_TAB_TOP_ROW_HEIGHT + NOTE_TAB_TOP_ROW_TO_BODY_GAP))
    view.bodyFrame:SetPoint("TOPRIGHT", -NOTE_TAB_SIDE_INSET, -(NOTE_TAB_TOP_ROW_TOP_OFFSET + NOTE_TAB_TOP_ROW_HEIGHT + NOTE_TAB_TOP_ROW_TO_BODY_GAP))
    view.bodyFrame:SetPoint("BOTTOMLEFT", NOTE_TAB_SIDE_INSET, NOTE_TAB_BOTTOM_INSET)
    view.bodyFrame:SetPoint("BOTTOMRIGHT", -NOTE_TAB_SIDE_INSET, NOTE_TAB_BOTTOM_INSET)

    view.bodyBackground = view.bodyFrame:CreateTexture(nil, "BACKGROUND")
    view.bodyBackground:SetAllPoints()
    if NOTE_TAB_BODY_BACKGROUND_ATLAS and NOTE_TAB_BODY_BACKGROUND_ATLAS ~= "" then
        view.bodyBackground:SetAtlas(NOTE_TAB_BODY_BACKGROUND_ATLAS, true)
        view.bodyBackground:SetVertexColor(unpack(NOTE_TAB_BODY_BACKGROUND_COLOR))
    else
        view.bodyBackground:SetTexture("Interface\\Buttons\\WHITE8x8")
        view.bodyBackground:SetVertexColor(unpack(NOTE_TAB_BODY_BACKGROUND_FALLBACK_COLOR))
    end

    view.bodyFallbackFill = view.bodyFrame:CreateTexture(nil, "BACKGROUND", nil, -1)
    view.bodyFallbackFill:SetAllPoints()
    view.bodyFallbackFill:SetTexture("Interface\\Buttons\\WHITE8x8")
    view.bodyFallbackFill:SetVertexColor(unpack(NOTE_TAB_BODY_BACKGROUND_FALLBACK_COLOR))
    view.bodyFallbackFill:SetShown(not (NOTE_TAB_BODY_BACKGROUND_ATLAS and NOTE_TAB_BODY_BACKGROUND_ATLAS ~= ""))

    view.bodyBorderFrame = ApplyTooltipBorderToRegion(view, view.bodyFrame)
    view.bodyShadowBounds, view.bodyShadowTexture = ApplyInsetShadowToRegion(
        view.bodyFrame,
        view.bodyFrame,
        NOTE_BODY_SHADOW_ATLAS,
        NOTE_READ_BODY_SHADOW_ALPHA,
        NOTE_READ_BODY_SHADOW_INSET
    )

    local scrollFrameSerial = NextNoteBodyScrollFrameSerial()
    view.bodyScrollFrameName = "SnailNotesReadScrollFrame" .. tostring(scrollFrameSerial)
    view.bodyScrollFrame = CreateFrame("ScrollFrame", view.bodyScrollFrameName, view.bodyFrame, "UIPanelScrollFrameTemplate")
    view.bodyScrollBar = _G[view.bodyScrollFrameName .. "ScrollBar"]
    ClearScrollFrameTemplateRegions(view.bodyScrollFrame)
    view.bodyScrollFrame:SetFrameLevel((view.bodyShadowBounds:GetFrameLevel() or 1) + 1)

    view.bodyContent = CreateFrame("Frame", nil, view.bodyScrollFrame)
    view.bodyContent:SetPoint("TOPLEFT", view.bodyScrollFrame, "TOPLEFT", 0, 0)
    view.bodyLines = {}

    view.bodyScrollFrame:SetScrollChild(view.bodyContent)
    view.bodyScrollFrame:EnableMouse(true)
    if view.bodyScrollFrame.EnableMouseWheel then
        view.bodyScrollFrame:EnableMouseWheel(true)
    end
    view.bodyScrollFrame:SetScript("OnMouseWheel", function(selfFrame, delta)
        ApplyNotesMouseWheelScroll(selfFrame, delta)
    end)

    return view
end

function module:CreateHomeListRow(parent, index)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(HOME_ROW_HEIGHT)
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
    row:SetHighlightTexture("Interface\\Buttons\\WHITE8x8")
    row:GetHighlightTexture():SetVertexColor(1, 1, 1, 0)

    row.background = CreateSolidTexture(row, "BACKGROUND", HOME_ROW_BACKGROUND_COLOR)
    row.background:SetAllPoints()

    row.hoverTexture = CreateSolidTexture(row, "ARTWORK", HOME_ROW_HOVER_COLOR)
    row.hoverTexture:SetAllPoints()
    row.hoverTexture:Hide()

    row.selectedTexture = CreateSolidTexture(row, "ARTWORK", HOME_ROW_SELECTED_COLOR)
    row.selectedTexture:SetAllPoints()
    row.selectedTexture:Hide()

    row.title = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    row.title:SetPoint("LEFT", HOME_ROW_TEXT_SIDE_INSET, HOME_ROW_TITLE_VERTICAL_OFFSET)
    row.title:SetPoint("RIGHT", row, "RIGHT", -(HOME_ROW_TIMESTAMP_RIGHT_INSET + HOME_ROW_TIMESTAMP_DISPLAY_WIDTH + HOME_ROW_TITLE_TO_TIMESTAMP_SPACING), HOME_ROW_TITLE_VERTICAL_OFFSET)
    row.title:SetJustifyH("LEFT")
    row.title:SetJustifyV("MIDDLE")
    row.title:SetWordWrap(false)
    row.title:SetFont(HOME_ROW_TITLE_FONT, HOME_ROW_TITLE_FONT_SIZE, "")

    row.timestamp = row:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    row.timestamp:SetWidth(HOME_ROW_TIMESTAMP_DISPLAY_WIDTH)
    row.timestamp:SetPoint("RIGHT", -HOME_ROW_TIMESTAMP_RIGHT_INSET, HOME_ROW_TEXT_VERTICAL_OFFSET)
    row.timestamp:SetJustifyH("RIGHT")
    row.timestamp:SetJustifyV("MIDDLE")
    row.timestamp:SetWordWrap(false)
    row.timestamp:SetFont(HOME_ROW_TIMESTAMP_FONT, HOME_ROW_TIMESTAMP_FONT_SIZE, "")

    row:SetScript("OnEnter", function(selfRow)
        module.runtime.hoveredNoteId = selfRow.noteId
        module:RefreshHomeRowVisuals(selfRow)
    end)
    row:SetScript("OnLeave", function(selfRow)
        if module.runtime.hoveredNoteId == selfRow.noteId then
            module.runtime.hoveredNoteId = nil
        end
        module:RefreshHomeRowVisuals(selfRow)
    end)
    row:SetScript("OnClick", function(selfRow, button)
        if not selfRow.noteId then
            return
        end

        if button == "RightButton" then
            module:SetSelectedNote(selfRow.noteId)
            module:ShowRowActionMenu(selfRow, selfRow.noteId)
            return
        end

        if button == "MiddleButton" then
            module:HideRowActionMenu()
            module:OpenNote(selfRow.noteId, true, true)
            return
        end

        module:HideRowActionMenu()
        module:OpenNote(selfRow.noteId, false)
    end)

    return row
end

function module:GetVisibleHomeRowCount(panel)
    if not panel or not panel.listBody then
        return 0
    end

    local availableHeight = math.max(panel.listBody:GetHeight(), HOME_ROW_HEIGHT)
    return math.max(1, math.floor((availableHeight + HOME_ROW_SPACING) / ROW_STRIDE))
end

function module:NeedsHomeScrollbar(panel, noteCount)
    if not panel then
        return false
    end

    return (tonumber(noteCount) or 0) > self:GetVisibleHomeRowCount(panel)
end

function module:ApplyHomeListWidth(panel, hasScrollbar)
    if not panel then
        return
    end

    local rightInset = hasScrollbar and HOME_LIST_SCROLLBAR_TOTAL_WIDTH or 0

    if panel.scrollFrame then
        panel.scrollFrame:ClearAllPoints()
        panel.scrollFrame:SetPoint("TOPLEFT", panel.listBody, "TOPLEFT", 0, 0)
        panel.scrollFrame:SetPoint("BOTTOMRIGHT", panel.listBody, "BOTTOMRIGHT", -rightInset, 0)
        panel.scrollFrame:SetShown(hasScrollbar)
    end

    if not panel.rows then
        return
    end

    for _, row in ipairs(panel.rows) do
        row:ClearAllPoints()
        row:SetPoint("LEFT", 0, 0)
        row:SetPoint("RIGHT", -rightInset, 0)
    end

    for index, row in ipairs(panel.rows) do
        if index == 1 then
            row:SetPoint("TOPLEFT", panel.rowContainer, "TOPLEFT", 0, 0)
        else
            row:SetPoint("TOPLEFT", panel.rows[index - 1], "BOTTOMLEFT", 0, -HOME_ROW_SPACING)
        end
    end
end

function module:UpdateHomeRowPool(panel, visibleRowCount)
    if not panel or not panel.rows then
        return
    end

    for index, row in ipairs(panel.rows) do
        if index <= visibleRowCount then
            row:Show()
        else
            row.noteId = nil
            row:Hide()
        end
    end
end

function module:EnsureHomeRows(panel)
    panel.rows = panel.rows or {}

    local desiredRowCount = self:GetVisibleHomeRowCount(panel)
    for index = #panel.rows + 1, desiredRowCount do
        local row = self:CreateHomeListRow(panel.rowContainer, index)
        if index == 1 then
            row:SetPoint("TOPLEFT", panel.rowContainer, "TOPLEFT", 0, 0)
        else
            row:SetPoint("TOPLEFT", panel.rows[index - 1], "BOTTOMLEFT", 0, -HOME_ROW_SPACING)
        end
        panel.rows[index] = row
    end
end

function module:RefreshHomeRowVisuals(row)
    if not row or not row.noteId then
        return
    end

    local isSelected = self.runtime and self.runtime.selectedNoteId == row.noteId
    local isHovered = self.runtime and self.runtime.hoveredNoteId == row.noteId
    local isBuiltin = row.timestamp and (row.timestamp:GetText() or "") == ""

    row.selectedTexture:SetShown(isSelected)
    row.hoverTexture:SetShown(isHovered and not isSelected)

    if isBuiltin then
        row.title:SetTextColor(unpack(HOME_ROW_BUILTIN_TITLE_COLOR))
        row.timestamp:SetTextColor(unpack(HOME_ROW_TIMESTAMP_UNSELECTED_COLOR))
    elseif isSelected then
        row.title:SetTextColor(unpack(HOME_ROW_TITLE_SELECTED_COLOR))
        row.timestamp:SetTextColor(unpack(HOME_ROW_TIMESTAMP_SELECTED_COLOR))
    elseif isHovered then
        row.title:SetTextColor(unpack(HOME_ROW_TITLE_HOVER_COLOR))
        row.timestamp:SetTextColor(unpack(HOME_ROW_TIMESTAMP_UNSELECTED_COLOR))
    else
        row.title:SetTextColor(unpack(HOME_ROW_TITLE_UNSELECTED_COLOR))
        row.timestamp:SetTextColor(unpack(HOME_ROW_TIMESTAMP_UNSELECTED_COLOR))
    end
end

function module:RefreshHomeHeader(panel, noteCount)
    if not panel or not panel.countText then
        return
    end

    if noteCount == 1 then
        panel.countText:SetText("1 note")
    else
        panel.countText:SetText(string.format("%d notes", noteCount))
    end
end

function module:RefreshHomeList()
    local runtime = self.runtime
    local homeTab = runtime and runtime.tabs and runtime.tabs.home
    local panel = homeTab and homeTab.panel
    if not panel or not panel.scrollFrame then
        return
    end

    self:EnsureSelectedNoteExists()
    self:EnsureHomeRows(panel)

    local notes = self:GetOrderedNotes()
    local noteCount = #notes
    local visibleRowCount = math.max(1, self:GetVisibleHomeRowCount(panel))
    local hasScrollbar = self:NeedsHomeScrollbar(panel, noteCount)
    local scrollOffset = FauxScrollFrame_GetOffset(panel.scrollFrame) or 0

    FauxScrollFrame_Update(panel.scrollFrame, noteCount, visibleRowCount, ROW_STRIDE)
    self:ApplyHomeListWidth(panel, hasScrollbar)
    self:UpdateHomeRowPool(panel, visibleRowCount)
    scrollOffset = math.min(scrollOffset, math.max(0, noteCount - visibleRowCount))

    self:RefreshHomeHeader(panel, noteCount)

    panel.emptyState:SetShown(noteCount == 0)

    if noteCount == 0 then
        self:HideRowActionMenu()
    end

    local actionMenuNoteVisible = false

    for rowIndex, row in ipairs(panel.rows) do
        local noteIndex = scrollOffset + rowIndex
        local note = notes[noteIndex]

        if note then
            row.noteId = note.id
            row.title:SetText(note.title or DEFAULT_NOTE_TITLE)
            if note.isBuiltin then
                row.title:SetFont(HOME_ROW_TITLE_FONT, HOME_ROW_BUILTIN_TITLE_FONT_SIZE, "")
                row.title:SetJustifyH("CENTER")
                row.title:ClearAllPoints()
                row.title:SetPoint("LEFT", row, "LEFT", HOME_ROW_TEXT_SIDE_INSET + HOME_ROW_BUILTIN_TITLE_CENTER_OFFSET_X, HOME_ROW_TITLE_VERTICAL_OFFSET)
                row.title:SetPoint("RIGHT", row, "RIGHT", -(HOME_ROW_TEXT_SIDE_INSET - HOME_ROW_BUILTIN_TITLE_CENTER_OFFSET_X), HOME_ROW_TITLE_VERTICAL_OFFSET)
            else
                row.title:SetFont(HOME_ROW_TITLE_FONT, HOME_ROW_TITLE_FONT_SIZE, "")
                row.title:SetJustifyH("LEFT")
                row.title:ClearAllPoints()
                row.title:SetPoint("LEFT", HOME_ROW_TEXT_SIDE_INSET, HOME_ROW_TITLE_VERTICAL_OFFSET)
                row.title:SetPoint("RIGHT", row, "RIGHT", -(HOME_ROW_TIMESTAMP_RIGHT_INSET + HOME_ROW_TIMESTAMP_DISPLAY_WIDTH + HOME_ROW_TITLE_TO_TIMESTAMP_SPACING), HOME_ROW_TITLE_VERTICAL_OFFSET)
            end
            if note.isBuiltin then
                row.timestamp:SetText("")
            else
                row.timestamp:SetText(FormatHomeListTimestamp(note.updatedAt, note.createdAt))
            end
            row:Show()
            self:RefreshHomeRowVisuals(row)

            if runtime.rowActionMenu and runtime.rowActionMenu:IsShown() and runtime.rowActionMenu.noteId == note.id then
                actionMenuNoteVisible = true
                runtime.rowActionMenu.currentRow = row
                self:RefreshRowActionMenu()
            end
        else
            row.noteId = nil
            row.title:SetFont(HOME_ROW_TITLE_FONT, HOME_ROW_TITLE_FONT_SIZE, "")
            row.title:SetJustifyH("LEFT")
            row.title:ClearAllPoints()
            row.title:SetPoint("LEFT", HOME_ROW_TEXT_SIDE_INSET, HOME_ROW_TITLE_VERTICAL_OFFSET)
                row.title:SetPoint("RIGHT", row, "RIGHT", -(HOME_ROW_TIMESTAMP_RIGHT_INSET + HOME_ROW_TIMESTAMP_DISPLAY_WIDTH + HOME_ROW_TITLE_TO_TIMESTAMP_SPACING), HOME_ROW_TITLE_VERTICAL_OFFSET)
            row:Hide()
        end
    end

    if runtime.rowActionMenu and runtime.rowActionMenu:IsShown() and not actionMenuNoteVisible then
        self:HideRowActionMenu()
    end
end

function module:RefreshHomeView()
    self:RefreshHomeList()
end

function module:CreateHomePanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()

    panel.countText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    panel.countText:SetPoint("TOPLEFT", HOME_HEADER_SIDE_INSET, -HOME_HEADER_TOP_INSET - HOME_HEADER_COUNT_TOP_OFFSET)
    panel.countText:SetJustifyH("LEFT")
    panel.countText:SetJustifyV("MIDDLE")

    panel.newButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    panel.newButton:SetSize(HOME_BUTTON_WIDTH, HOME_BUTTON_HEIGHT)
    panel.newButton:SetPoint("TOPRIGHT", -HOME_HEADER_SIDE_INSET, -HOME_HEADER_TOP_INSET)
    panel.newButton:SetText("New")
    panel.newButton:SetScript("OnClick", function()
        module:HideRowActionMenu()
        module:CreateAndOpenNote()
    end)

    panel.importButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    panel.importButton:SetSize(HOME_BUTTON_WIDTH, HOME_BUTTON_HEIGHT)
    panel.importButton:SetPoint("RIGHT", panel.newButton, "LEFT", -HOME_HEADER_BUTTON_SPACING, 0)
    panel.importButton:SetPoint("TOP", panel.newButton, "TOP", 0, 0)
    panel.importButton:SetText("Import")
    panel.importButton:SetScript("OnClick", function()
        module:ShowNoteImportDialog()
    end)
    self:CreateHomeOptionsButton(panel)

    panel.listFrame = CreateBackdropFrame(panel, false)
    panel.listFrame:SetPoint("TOPLEFT", HOME_LIST_FRAME_INSET, -HOME_LIST_TOP_INSET)
    panel.listFrame:SetPoint("BOTTOMRIGHT", -HOME_LIST_FRAME_INSET, HOME_LIST_BOTTOM_INSET)
    if panel.listFrame.SetBackdrop then
        panel.listFrame:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 14,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
    end
    if panel.listFrame.SetBackdropBorderColor then
        panel.listFrame:SetBackdropBorderColor(0.36, 0.36, 0.36, 0.82)
    end
    if panel.listFrame.SetBackdropColor then
        panel.listFrame:SetBackdropColor(0, 0, 0, 0)
    end

    panel.listBackground = panel.listFrame:CreateTexture(nil, "BACKGROUND")
    panel.listBackground:SetPoint("TOPLEFT", HOME_LIST_BACKDROP_BORDER_MARGIN, -HOME_LIST_BACKDROP_BORDER_MARGIN)
    panel.listBackground:SetPoint("BOTTOMRIGHT", -HOME_LIST_BACKDROP_BORDER_MARGIN, HOME_LIST_BACKDROP_BORDER_MARGIN)
    do
        local red, green, blue = HexToColorRGB(HOME_LIST_BACKGROUND_HEX)
        panel.listBackground:SetColorTexture(red, green, blue, HOME_LIST_BACKGROUND_ALPHA)
    end

    panel.listClip = CreateFrame("Frame", nil, panel.listFrame)
    panel.listClip:SetPoint("TOPLEFT", HOME_LIST_BACKDROP_BORDER_MARGIN, -HOME_LIST_BACKDROP_BORDER_MARGIN)
    panel.listClip:SetPoint("BOTTOMRIGHT", -HOME_LIST_BACKDROP_BORDER_MARGIN, HOME_LIST_BACKDROP_BORDER_MARGIN + 8)
    if panel.listClip.SetClipsChildren then
        panel.listClip:SetClipsChildren(true)
    end

    panel.listShadowBounds = CreateFrame("Frame", nil, panel.listFrame)
    panel.listShadowBounds:SetPoint("TOPLEFT", panel.listBackground, "TOPLEFT", HOME_LIST_INNER_SHADOW_INSET, -HOME_LIST_INNER_SHADOW_INSET)
    panel.listShadowBounds:SetPoint("BOTTOMRIGHT", panel.listBackground, "BOTTOMRIGHT", -HOME_LIST_INNER_SHADOW_INSET, HOME_LIST_INNER_SHADOW_INSET)
    panel.listShadowBounds:SetFrameLevel((panel.listClip:GetFrameLevel() or 1) + 1)
    panel.listShadowBounds:EnableMouse(false)

    panel.listInnerShadowTexture = panel.listShadowBounds:CreateTexture(nil, "ARTWORK")
    panel.listInnerShadowTexture:SetAllPoints()
    panel.listInnerShadowTexture:SetAtlas(HOME_LIST_INNER_SHADOW_ATLAS, true)
    panel.listInnerShadowTexture:SetVertexColor(1, 1, 1, HOME_LIST_INNER_SHADOW_ALPHA)

    panel.listBody = CreateFrame("Frame", nil, panel.listClip)
    panel.listBody:SetPoint("TOPLEFT", HOME_LIST_INNER_PADDING, -HOME_LIST_INNER_PADDING)
    panel.listBody:SetPoint("BOTTOMRIGHT", -HOME_LIST_INNER_PADDING, HOME_LIST_INNER_PADDING)
    panel.listBody:SetFrameLevel((panel.listShadowBounds:GetFrameLevel() or 1) + 1)
    panel.listBody:SetScript("OnSizeChanged", function()
        module:RefreshHomeList()
    end)

    panel.rowContainer = CreateFrame("Frame", nil, panel.listBody)
    panel.rowContainer:SetPoint("TOPLEFT", 0, 0)
    panel.rowContainer:SetPoint("TOPRIGHT", 0, 0)
    panel.rowContainer:SetPoint("BOTTOMLEFT", 0, 0)
    panel.rowContainer:SetPoint("BOTTOMRIGHT", 0, 0)

    panel.scrollFrame = CreateFrame("ScrollFrame", nil, panel.listClip, "FauxScrollFrameTemplate")
    panel.scrollFrame:SetPoint("TOPLEFT", panel.listBody, "TOPLEFT", 0, 0)
    panel.scrollFrame:SetPoint("BOTTOMRIGHT", panel.listBody, "BOTTOMRIGHT", -HOME_LIST_SCROLLBAR_TOTAL_WIDTH, 0)
    panel.scrollFrame:SetScript("OnVerticalScroll", function(selfFrame, offset)
        FauxScrollFrame_OnVerticalScroll(selfFrame, offset, ROW_STRIDE, function()
            module:RefreshHomeList()
        end)
    end)

    panel.emptyState = CreateFrame("Button", nil, panel.listBody)
    panel.emptyState:SetSize(EMPTY_STATE_WIDTH, EMPTY_STATE_HEIGHT)
    panel.emptyState:SetPoint("CENTER", 0, 0)
    panel.emptyState:RegisterForClicks("LeftButtonUp")
    panel.emptyState:SetScript("OnClick", function(_, button)
        if button == "LeftButton" then
            module:CreateAndOpenNote()
        end
    end)

    panel.emptyStateBackdrop = CreateBackdropFrame(panel.emptyState)
    panel.emptyStateBackdrop:SetAllPoints()
    if panel.emptyStateBackdrop.SetBackdropColor then
        panel.emptyStateBackdrop:SetBackdropColor(0.08, 0.08, 0.08, 0.35)
    end
    if panel.emptyStateBackdrop.SetBackdropBorderColor then
        panel.emptyStateBackdrop:SetBackdropBorderColor(0.28, 0.28, 0.28, 0.55)
    end

    panel.emptyStateText = panel.emptyState:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    panel.emptyStateText:SetWidth(EMPTY_STATE_MESSAGE_WIDTH)
    panel.emptyStateText:SetPoint("CENTER", 0, 0)
    panel.emptyStateText:SetJustifyH("CENTER")
    panel.emptyStateText:SetJustifyV("MIDDLE")
    panel.emptyStateText:SetSpacing(4)
    panel.emptyStateText:SetText("No notes yet.\nClick here to create your first note!")

    panel.emptyState:SetScript("OnEnter", function()
        panel.emptyStateText:SetTextColor(1, 0.93, 0.65)
    end)
    panel.emptyState:SetScript("OnLeave", function()
        panel.emptyStateText:SetTextColor(0.93, 0.90, 0.84)
    end)

    panel.rows = {}

    return panel
end

function module:CreateNotePanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()

    panel.viewHost = CreateFrame("Frame", nil, panel)
    panel.viewHost:SetAllPoints()

    panel.readView = self:CreateNoteReadView(panel.viewHost)
    panel.editView = self:CreateNoteEditView(panel.viewHost)
    panel.activeView = panel.editView
    panel.readView:Hide()

    return panel
end

function module:SetTabTitle(tab, title)
    if not tab or not tab.button then
        return
    end

    tab.title = title or "Note"
    tab.button:SetText(tab.title)
    if PanelTemplates_TabResize then
        PanelTemplates_TabResize(tab.button, 0)
    end
end

function module:SetTabSelected(tab, selected)
    if not tab or not tab.button then
        return
    end

    tab.selected = selected and true or false

    if tab.selected then
        if PanelTemplates_SelectTab then
            PanelTemplates_SelectTab(tab.button)
        end
    else
        if PanelTemplates_DeselectTab then
            PanelTemplates_DeselectTab(tab.button)
        end
    end
end

function module:IsTabVisible(tab)
    return tab and (tab.key == "home" or tab.assigned) or false
end

function module:RefreshTabLayout()
    local runtime = self.runtime
    if not runtime or not runtime.frame then
        return
    end

    local previousButton
    for _, tab in ipairs(runtime.orderedTabs) do
        local visible = self:IsTabVisible(tab)
        tab.button:ClearAllPoints()
        tab.button:SetShown(visible)
        tab.content:SetShown(visible and runtime.activeTabKey == tab.key)

        if visible then
            if previousButton then
                tab.button:SetPoint("LEFT", previousButton, "RIGHT", TAB_SPACING, 0)
            else
                tab.button:SetPoint("BOTTOMLEFT", runtime.frame.tabBar, "BOTTOMLEFT", 0, 0)
            end
            previousButton = tab.button
        end
    end
end

function module:SelectTab(tabKey)
    local runtime = self.runtime
    local tab = runtime and runtime.tabs and runtime.tabs[tabKey]
    if not runtime or not tab or not self:IsTabVisible(tab) then
        return
    end

    runtime.activeTabKey = tabKey
    self:HideRowActionMenu()
    self:HideTabContextMenu()

    for _, entry in ipairs(runtime.orderedTabs) do
        local visible = self:IsTabVisible(entry)
        entry.content:SetShown(visible and entry.key == tabKey)
        self:SetTabSelected(entry, entry.key == tabKey)
    end

    if runtime.frame then
        self:ApplyWindowGeometry(runtime.frame)
    end

    if tabKey == "home" then
        self:RefreshHomeView()
    elseif tabKey == "options" then
        self:RefreshOptionsPanel(tab)
    elseif tab.slotIndex then
        self:RefreshNoteTabControls(tab)
        self:ApplyTabMode(tab)
    end

    self:RefreshNotePreviewVisibility()
end

function module:CreateTab(frame, definition, index)
    local buttonName = (frame:GetName() or "SnailNotesFrame") .. "Tab" .. index
    local button = CreateFrame("Button", buttonName, frame, "CharacterFrameTabButtonTemplate")
    button:SetParent(frame.tabBar)
    button:SetID(index)
    button:SetFrameStrata(frame:GetFrameStrata())
    button:SetFrameLevel((frame:GetFrameLevel() or 1) + 8)
    button:SetHeight(TAB_HEIGHT)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button.text = button.GetFontString and button:GetFontString() or button.Text

    local content = CreateFrame("Frame", nil, frame.contentHost)
    content:SetAllPoints()
    content:Hide()

    local tab = {
        key = definition.key,
        title = definition.title,
        button = button,
        content = content,
        slotIndex = definition.slotIndex,
        specialType = definition.specialType,
        assigned = definition.key == "home",
        selected = false,
        noteData = nil,
        panel = nil,
    }

    if definition.key == "home" then
        tab.panel = self:CreateHomePanel(content)
    elseif definition.key == "options" then
        tab.panel = self:CreateOptionsPanel(content)
    else
        tab.panel = self:CreateNotePanel(content)
        local view = self:GetNoteTabEditView(tab.panel)
        local readView = self:GetNoteTabReadView(tab.panel)
        if view then
            view.saveButton:SetScript("OnClick", function()
                module:SaveNoteTab(tab)
            end)
            view.previewCheck:SetScript("OnClick", function(check)
                module:SetNotePreviewEnabled(tab, check:GetChecked() and true or false)
            end)
            view.previewLabelButton:SetScript("OnClick", function()
                local nextValue = not view.previewCheck:GetChecked()
                view.previewCheck:SetChecked(nextValue)
                module:SetNotePreviewEnabled(tab, nextValue)
            end)
            view.deleteButton:SetScript("OnClick", function()
                module:ConfirmDeleteNoteFromTab(tab)
            end)
            view.modeButton:SetScript("OnClick", function()
                module:HandleNoteModeButtonClicked(tab)
            end)
            view.closeButton:SetScript("OnClick", function()
                module:RequestCloseTab(tab)
            end)
            view.titleInput:SetScript("OnEscapePressed", function(editBox)
                editBox:ClearFocus()
            end)
            view.titleInput:SetScript("OnEnterPressed", function(editBox)
                editBox:ClearFocus()
                module:SaveNoteTab(tab)
            end)
            view.titleInput:SetScript("OnTextChanged", function(_, userInput)
                if userInput then
                    module:HandleNoteTabContentChanged(tab)
                end
            end)

            view.bodyInput:SetScript("OnEscapePressed", function(editBox)
                editBox:ClearFocus()
            end)
            view.bodyInput:SetScript("OnCursorChanged", function(editBox, x, y, width, height)
                ScrollingEdit_OnCursorChanged(editBox, x, y, width, height)
                UpdateNoteEditLineNumbers(tab, view)
                SyncNoteEditGutterScroll(view)
                UpdateNoteEditScrollBar(view)
            end)
            view.bodyInput:SetScript("OnUpdate", function(editBox, elapsed)
                if ScrollingEdit_OnUpdate then
                    ScrollingEdit_OnUpdate(editBox, elapsed, view.bodyScrollFrame)
                end
            end)
            view.bodyInput:SetScript("OnTextChanged", function(editBox, userInput)
                if ScrollingEdit_OnTextChanged then
                    ScrollingEdit_OnTextChanged(editBox, view.bodyScrollFrame)
                end
                if userInput then
                    module:HandleNoteTabContentChanged(tab)
                end
                UpdateNoteEditLineNumbers(tab, view)
                UpdateNoteEditScrollBar(view)
                SyncNoteEditGutterScroll(view)
            end)
            view.bodyInput:SetScript("OnEditFocusLost", function(editBox)
                editBox:HighlightText(0, 0)
            end)
            view.bodyInput:SetScript("OnReceiveDrag", function(editBox)
                module:HandleNoteBodyItemDrop(tab, editBox)
            end)
            view.bodyScrollFrame:HookScript("OnMouseDown", function(_, button)
                if button == "LeftButton" then
                    FocusNoteEditBodyToEnd(view)
                end
            end)
            view.bodyFrame:HookScript("OnMouseDown", function(_, button)
                if button == "LeftButton" then
                    FocusNoteEditBodyToEnd(view)
                end
            end)
            view.bodyScrollFrame:SetScript("OnReceiveDrag", function()
                module:HandleNoteBodyItemDrop(tab, view.bodyInput)
            end)
            view.bodyFrame:SetScript("OnReceiveDrag", function()
                module:HandleNoteBodyItemDrop(tab, view.bodyInput)
            end)
            view.bodyFrame:SetScript("OnSizeChanged", function()
                RefreshNoteEditBody(tab, {
                    resetScroll = false,
                    focusEditor = false,
                })
            end)
            view:SetScript("OnShow", function()
                if C_Timer and C_Timer.After then
                    C_Timer.After(0, function()
                        RefreshNoteEditBody(tab, {
                            resetScroll = true,
                            focusEditor = true,
                            cursorPosition = 0,
                        })
                    end)
                else
                    RefreshNoteEditBody(tab, {
                        resetScroll = true,
                        focusEditor = true,
                        cursorPosition = 0,
                    })
                end
            end)
        end
        if readView then
            readView.linkButton:SetScript("OnClick", function()
                local noteId = tab and tab.noteData and tab.noteData.noteId or nil
                if noteId then
                    module:ShowNoteLinkDialog(noteId, module:GetNoteTabStoredTitle(tab))
                end
            end)
            readView.exportButton:SetScript("OnClick", function()
                local noteId = tab and tab.noteData and tab.noteData.noteId or nil
                if noteId then
                    module:ShowNoteExportDialog(noteId)
                end
            end)
            readView.deleteButton:SetScript("OnClick", function()
                module:ConfirmDeleteNoteFromTab(tab)
            end)
            readView.modeButton:SetScript("OnClick", function()
                module:HandleNoteModeButtonClicked(tab)
            end)
            readView.closeButton:SetScript("OnClick", function()
                module:RequestCloseTab(tab)
            end)
            readView.bodyFrame:SetScript("OnSizeChanged", function()
                module:UpdateNoteBodyReadLayout(tab)
            end)
            readView:SetScript("OnShow", function()
                module:RefreshNoteReadView(tab)
                module:QueueDeferredNoteReadViewRefresh(tab)
            end)
        end
    end

    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            if tab.key ~= "home" then
                module:ShowTabContextMenu(tab)
            end
            return
        end

        module:SelectTab(tab.key)
    end)

    self:SetTabTitle(tab, definition.title)
    self:SetTabSelected(tab, false)

    return tab
end

function module:CreateRowActionMenuButton(parent, label, orderIndex, callback)
    local button = CreateFrame("Button", nil, parent)
    button:SetHeight(ROW_MENU_BUTTON_HEIGHT)
    button:SetPoint("LEFT", ROW_MENU_PADDING, 0)
    button:SetPoint("RIGHT", -ROW_MENU_PADDING, 0)
    if orderIndex == 1 then
        button:SetPoint("TOP", 0, -ROW_MENU_PADDING)
    else
        button:SetPoint("TOP", parent.buttons[orderIndex - 1], "BOTTOM", 0, -ROW_MENU_SPACING)
    end

    button.background = CreateSolidTexture(button, "BACKGROUND", { 0, 0, 0, 0 })
    button.background:SetAllPoints()

    button.highlight = CreateSolidTexture(button, "ARTWORK", ROW_MENU_BUTTON_HOVER_COLOR)
    button.highlight:SetAllPoints()
    button.highlight:Hide()

    button.text = button:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    button.text:SetPoint("LEFT", 8, 0)
    button.text:SetPoint("RIGHT", -8, 0)
    button.text:SetJustifyH("LEFT")
    button.text:SetText(label)

    button:SetScript("OnEnter", function(selfButton)
        if not selfButton.disabled then
            selfButton.highlight:Show()
        end
    end)
    button:SetScript("OnLeave", function(selfButton)
        selfButton.highlight:Hide()
    end)
    button:SetScript("OnClick", function(selfButton)
        if selfButton.disabled then
            return
        end

        callback()
    end)

    return button
end

function module:CreateRowActionMenu(parent)
    local menu = CreateFrame("Frame", nil, parent)
    menu:SetFrameStrata("DIALOG")
    menu:SetFrameLevel((parent:GetFrameLevel() or 1) + 40)
    menu:SetWidth(ROW_MENU_WIDTH)

    menu.background = menu:CreateTexture(nil, "BACKGROUND")
    menu.background:SetAllPoints()
    menu.background:SetTexture(ROW_MENU_BACKGROUND_TEXTURE)
    menu.background:SetVertexColor(unpack(ROW_MENU_BACKGROUND_COLOR))

    menu:Hide()

    menu.buttons = {}

    menu.buttons[1] = self:CreateRowActionMenuButton(menu, "Open in new tab", 1, function()
        local noteId = menu.noteId
        menu:Hide()
        module:OpenNote(noteId, true, true)
    end)

    menu.buttons[2] = self:CreateRowActionMenuButton(menu, "Copy Note Link", 2, function()
        local noteId = menu.noteId
        menu:Hide()
        module:ShowNoteLinkDialog(noteId)
    end)

    menu.buttons[3] = self:CreateRowActionMenuButton(menu, "Export", 3, function()
        local noteId = menu.noteId
        menu:Hide()
        module:ShowNoteExportDialog(noteId)
    end)

    menu.buttons[4] = self:CreateRowActionMenuButton(menu, "Duplicate", 4, function()
        local noteId = menu.noteId
        menu:Hide()
        module:DuplicateNote(noteId)
    end)

    menu.buttons[5] = self:CreateRowActionMenuButton(menu, "Delete", 5, function()
        local noteId = menu.noteId
        menu:Hide()
        module:DeleteNote(noteId)
    end)

    menu:SetHeight((ROW_MENU_PADDING * 2) + (ROW_MENU_BUTTON_HEIGHT * #menu.buttons) + (ROW_MENU_SPACING * (#menu.buttons - 1)))
    menu:SetScript("OnHide", function()
        menu.noteId = nil
        menu.currentRow = nil
    end)

    return menu
end

function module:RefreshRowActionMenu()
    local menu = self.runtime and self.runtime.rowActionMenu
    if not menu or not menu:IsShown() then
        return
    end

    local disableNewTab = not self:HasAvailableNoteTabSlot()
    local newTabButton = menu.buttons and menu.buttons[1]
    if newTabButton then
        newTabButton.disabled = disableNewTab
        newTabButton:EnableMouse(not disableNewTab)
        newTabButton.highlight:Hide()
        if disableNewTab then
            newTabButton.text:SetTextColor(0.50, 0.50, 0.50)
        else
            newTabButton.text:SetTextColor(0.93, 0.90, 0.84)
        end
    end
end

function module:ShowRowActionMenu(row, noteId)
    if not row or not noteId or self:IsBuiltinNoteId(noteId) or not self.runtime or not self.runtime.rowActionMenu then
        return
    end

    self:HideTabContextMenu()

    local menu = self.runtime.rowActionMenu
    menu.noteId = noteId
    menu.currentRow = row
    menu:ClearAllPoints()
    menu:SetPoint("TOPRIGHT", row, "TOPRIGHT", ROW_MENU_ANCHOR_X, ROW_MENU_ANCHOR_Y)
    menu:Show()
    self:RefreshRowActionMenu()
end

function module:HideRowActionMenu()
    local menu = self.runtime and self.runtime.rowActionMenu
    if menu and menu:IsShown() then
        menu:Hide()
    end
end

function module:CreateTabContextMenu(parent)
    local menu = CreateFrame("Frame", nil, parent)
    menu:SetFrameStrata("DIALOG")
    menu:SetFrameLevel((parent:GetFrameLevel() or 1) + 40)
    menu:SetWidth(ROW_MENU_WIDTH)

    menu.background = menu:CreateTexture(nil, "BACKGROUND")
    menu.background:SetAllPoints()
    menu.background:SetTexture(ROW_MENU_BACKGROUND_TEXTURE)
    menu.background:SetVertexColor(unpack(ROW_MENU_BACKGROUND_COLOR))

    menu:Hide()
    menu.buttons = {}

    menu.buttons[1] = self:CreateRowActionMenuButton(menu, "Close Tab", 1, function()
        local targetTab = menu.targetTab
        menu:Hide()
        if targetTab then
            module:RequestCloseTab(targetTab)
        end
    end)

    menu:SetHeight((ROW_MENU_PADDING * 2) + ROW_MENU_BUTTON_HEIGHT)
    menu:SetScript("OnHide", function()
        menu.targetTab = nil
        menu.targetButton = nil
    end)

    return menu
end

function module:ShowTabContextMenu(tab)
    if not tab or tab.key == "home" or not tab.button or not self.runtime or not self.runtime.tabContextMenu then
        return
    end

    self:HideRowActionMenu()

    local menu = self.runtime.tabContextMenu
    menu.targetTab = tab
    menu.targetButton = tab.button
    menu:ClearAllPoints()
    menu:SetPoint("TOPRIGHT", tab.button, "BOTTOMRIGHT", 0, -2)
    menu:Show()
end

function module:HideTabContextMenu()
    local menu = self.runtime and self.runtime.tabContextMenu
    if menu and menu:IsShown() then
        menu:Hide()
    end
end

function module:CreateNotesFrame()
    self:EnsureRuntime()
    if self.runtime.frame then
        return self.runtime.frame
    end

    local frame = CreateFrame("Frame", "SnailNotesFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:Hide()

    if frame.SetMinResize then
        frame:SetMinResize(WINDOW_MIN_WIDTH, WINDOW_MIN_HEIGHT)
    end
    self:UpdateWindowResizeBounds(frame)

    self:ApplyWindowGeometry(frame)

    if frame.TitleText then
        frame.TitleText:SetText(WINDOW_TITLE)
        frame.TitleText:ClearAllPoints()
        frame.TitleText:SetPoint("TOP", frame, "TOP", 0, -4 + WINDOW_TITLE_Y_OFFSET)
    end

    frame:SetScript("OnDragStart", function(selfFrame)
        selfFrame:StartMoving()
        selfFrame.isMovingByDrag = true
    end)
    frame:SetScript("OnDragStop", function(selfFrame)
        selfFrame:StopMovingOrSizing()
        selfFrame.isMovingByDrag = nil
        UpdateSnappedPreviewWindowPosition(module and module.runtime and module.runtime.previewWindow or nil, false)
        if module and module.runtime and module.runtime.previewWindow and module.runtime.previewWindow.snappedToNotesRight then
            module:SavePreviewWindowGeometry(module.runtime.previewWindow)
        end
        module:SaveWindowGeometry(selfFrame)
    end)
    frame:SetScript("OnHide", function(selfFrame)
        EndResizeFromGrip(selfFrame)
        module:SaveWindowGeometry(selfFrame)
        module:HideRowActionMenu()
        module:HideTabContextMenu()
    end)
    frame:SetScript("OnMouseDown", function()
        module:HideRowActionMenu()
        module:HideTabContextMenu()
    end)
    frame:SetScript("OnSizeChanged", function(selfFrame, width, height)
        if selfFrame.isSizingByGrip and not HasResizeCursorMoved(selfFrame) then
            local resizeStartState = selfFrame.resizeStartState
            if resizeStartState and not selfFrame.enforcingSize then
                local baselineWidth = tonumber(resizeStartState.width) or width
                local baselineHeight = tonumber(resizeStartState.height) or height
                if math.abs(width - baselineWidth) > 0.5 or math.abs(height - baselineHeight) > 0.5 then
                    selfFrame.enforcingSize = true
                    selfFrame:SetSize(baselineWidth, baselineHeight)
                    selfFrame.enforcingSize = false
                end
            end
            return
        end

        local clampedWidth, clampedHeight
        if module:IsHomeTabActive() then
            clampedWidth, clampedHeight = ClampHomeWindowSize(width, height)
        else
            clampedWidth, clampedHeight = ClampWindowSize(width, height)
        end
        if not selfFrame.enforcingSize and (math.abs(width - clampedWidth) > 0.5 or math.abs(height - clampedHeight) > 0.5) then
            selfFrame.enforcingSize = true
            selfFrame:SetSize(clampedWidth, clampedHeight)
            selfFrame.enforcingSize = false
            return
        end

        module:SaveWindowGeometry(selfFrame)
        module:RefreshHomeList()
        UpdateSnappedPreviewWindowPosition(module and module.runtime and module.runtime.previewWindow or nil, true)
    end)
    frame:SetScript("OnUpdate", function(selfFrame)
        if selfFrame.isMovingByDrag then
            UpdateSnappedPreviewWindowPosition(module and module.runtime and module.runtime.previewWindow or nil, false)
        end
    end)
    frame:SetScript("OnShow", function()
        module:RefreshTabLayout()
        module:SelectTab(module.runtime.activeTabKey or "home")
    end)

    frame.inner = CreateFrame("Frame", nil, frame)
    frame.inner:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -30)
    frame.inner:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 14)

    frame.innerBackground = frame.inner:CreateTexture(nil, "BACKGROUND")
    frame.innerBackground:SetAllPoints()
    frame.innerBackground:SetTexture("Interface\\Buttons\\WHITE8x8")
    frame.innerBackground:SetVertexColor(0, 0, 0, 0.18)

    frame.contentHost = CreateFrame("Frame", nil, frame.inner)
    frame.contentHost:SetPoint("TOPLEFT", frame.inner, "TOPLEFT", 8, -8)
    frame.contentHost:SetPoint("BOTTOMRIGHT", frame.inner, "BOTTOMRIGHT", -8, 0)

    frame.tabBar = CreateFrame("Frame", nil, frame)
    frame.tabBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 14, -22)
    frame.tabBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -38, -22)
    frame.tabBar:SetHeight(TAB_HEIGHT)
    frame.tabBar:SetFrameStrata(frame:GetFrameStrata())
    frame.tabBar:SetFrameLevel((frame:GetFrameLevel() or 1) + 6)

    frame.resizeGrip = CreateFrame("Button", nil, frame)
    frame.resizeGrip:SetSize(16, 16)
    frame.resizeGrip:SetPoint("BOTTOMRIGHT", -6, 6)
    frame.resizeGrip:RegisterForDrag("LeftButton")
    frame.resizeGrip.texture = frame.resizeGrip:CreateTexture(nil, "ARTWORK")
    frame.resizeGrip.texture:SetAllPoints()
    frame.resizeGrip.texture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    frame.resizeGrip:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            BeginResizeFromGrip(frame)
        end
    end)
    frame.resizeGrip:SetScript("OnDragStart", function()
        BeginResizeFromGrip(frame)
        frame.isSizingByGrip = true
        frame:StartSizing("BOTTOMRIGHT")
    end)
    frame.resizeGrip:SetScript("OnDragStop", function()
        if frame.isSizingByGrip then
            frame:StopMovingOrSizing()
        end
        EndResizeFromGrip(frame)
        module:SaveWindowGeometry(frame)
    end)
    frame.resizeGrip:SetScript("OnMouseUp", function(_, button)
        if button ~= "LeftButton" or not frame.isSizingByGrip then
            return
        end

        frame:StopMovingOrSizing()
        EndResizeFromGrip(frame)
        module:SaveWindowGeometry(frame)
    end)

    self.runtime.frame = frame
    self.runtime.tabs = {}
    self.runtime.orderedTabs = {}
    self.runtime.noteSlots = {}
    self.runtime.rowActionMenu = self:CreateRowActionMenu(frame.contentHost)
    self.runtime.tabContextMenu = self:CreateTabContextMenu(frame.contentHost)

    local definitions = {
        { key = "home", title = "Home" },
        { key = "options", title = "Options", specialType = "options" },
        { key = "noteSlot1", title = "Note", slotIndex = 1 },
        { key = "noteSlot2", title = "Note", slotIndex = 2 },
        { key = "noteSlot3", title = "Note", slotIndex = 3 },
    }

    for index, definition in ipairs(definitions) do
        local tab = self:CreateTab(frame, definition, index)
        self.runtime.tabs[definition.key] = tab
        self.runtime.orderedTabs[#self.runtime.orderedTabs + 1] = tab

        if definition.slotIndex then
            self.runtime.noteSlots[definition.slotIndex] = tab
        end
    end

    self:RefreshTabLayout()
    self:SelectTab("home")

    return frame
end

function module:CreateNotePreviewWindow()
    self:EnsureRuntime()
    if self.runtime.previewWindow then
        return self.runtime.previewWindow
    end

    local frame = CreateFrame("Frame", "SnailNotesPreviewFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:Hide()

    if frame.SetMinResize then
        frame:SetMinResize(NOTE_PREVIEW_WINDOW_MIN_WIDTH, NOTE_PREVIEW_WINDOW_MIN_HEIGHT)
    end
    self:ApplyPreviewWindowGeometry(frame)

    if frame.TitleText then
        frame.TitleText:SetText("Preview")
    end

    frame:SetScript("OnDragStart", function(selfFrame)
        selfFrame:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(selfFrame)
        selfFrame:StopMovingOrSizing()
        if not TrySnapPreviewWindowToNotesWindow(selfFrame) then
            ClearPreviewWindowSnapState(selfFrame)
        end
        module:SavePreviewWindowGeometry(selfFrame)
    end)
    frame:SetScript("OnHide", function(selfFrame)
        EndResizeFromGrip(selfFrame)
        module:SavePreviewWindowGeometry(selfFrame)
        if selfFrame.suppressOwnerReset then
            return
        end

        local ownerTab = selfFrame.ownerTab
        selfFrame.ownerTab = nil
        if ownerTab then
            module:SetNotePreviewEnabled(ownerTab, false)
        end
    end)
    frame:SetScript("OnSizeChanged", function(selfFrame, width, height)
        if selfFrame.isSizingByGrip and not HasResizeCursorMoved(selfFrame) then
            local resizeStartState = selfFrame.resizeStartState
            if resizeStartState and not selfFrame.enforcingSize then
                local baselineWidth = tonumber(resizeStartState.width) or width
                local baselineHeight = tonumber(resizeStartState.height) or height
                if math.abs(width - baselineWidth) > 0.5 or math.abs(height - baselineHeight) > 0.5 then
                    selfFrame.enforcingSize = true
                    selfFrame:SetSize(baselineWidth, baselineHeight)
                    selfFrame.enforcingSize = false
                end
            end
            return
        end

        local clampedWidth, clampedHeight = width, height
        if module.ClampPreviewWindowSize then
            clampedWidth, clampedHeight = module:ClampPreviewWindowSize(width, height)
        end
        if not selfFrame.enforcingSize and (math.abs(width - clampedWidth) > 0.5 or math.abs(height - clampedHeight) > 0.5) then
            selfFrame.enforcingSize = true
            selfFrame:SetSize(clampedWidth, clampedHeight)
            selfFrame.enforcingSize = false
            return
        end

        module:SavePreviewWindowGeometry(selfFrame)
        module:UpdateStandaloneReadViewLayout(selfFrame.readView)
    end)

    frame.contentHost = CreateFrame("Frame", nil, frame)
    frame.contentHost:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)
    frame.contentHost:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)

    frame.readView = self:CreateNotePreviewContentView(frame.contentHost)

    frame.resizeGrip = CreateFrame("Button", nil, frame)
    frame.resizeGrip:SetSize(16, 16)
    frame.resizeGrip:SetPoint("BOTTOMRIGHT", -6, 6)
    frame.resizeGrip:RegisterForDrag("LeftButton")
    frame.resizeGrip.texture = frame.resizeGrip:CreateTexture(nil, "ARTWORK")
    frame.resizeGrip.texture:SetAllPoints()
    frame.resizeGrip.texture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    frame.resizeGrip:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            BeginResizeFromGrip(frame)
        end
    end)
    frame.resizeGrip:SetScript("OnDragStart", function()
        BeginResizeFromGrip(frame)
        frame.isSizingByGrip = true
        frame:StartSizing("BOTTOMRIGHT")
    end)
    frame.resizeGrip:SetScript("OnDragStop", function()
        if frame.isSizingByGrip then
            frame:StopMovingOrSizing()
        end
        EndResizeFromGrip(frame)
        module:SavePreviewWindowGeometry(frame)
    end)
    frame.resizeGrip:SetScript("OnMouseUp", function(_, button)
        if button ~= "LeftButton" or not frame.isSizingByGrip then
            return
        end

        frame:StopMovingOrSizing()
        EndResizeFromGrip(frame)
        module:SavePreviewWindowGeometry(frame)
    end)

    self.runtime.previewWindow = frame
    return frame
end

