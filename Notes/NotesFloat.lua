local _, ns = ...
local shared = ns.NotesShared
local module = shared and shared.module
if not shared or not module then return end

local constants = shared.constants
local helpers = shared.helpers
local CreateBackdropFrame = helpers.CreateBackdropFrame
local NormalizeNoteTitle = helpers.NormalizeNoteTitle
local GetSafeWindowScreenBounds = helpers.GetSafeWindowScreenBounds
local DEFAULT_NOTE_BODY = constants.DEFAULT_NOTE_BODY
local NOTE_FLOAT_WINDOW_WIDTH = 560
local NOTE_FLOAT_WINDOW_HEIGHT = 560
local NOTE_FLOAT_WINDOW_MIN_WIDTH = 240
local NOTE_FLOAT_WINDOW_MIN_HEIGHT = 180
local NOTE_FLOAT_BACKGROUND_COLOR = { 0, 0, 0, 0.18 }
local NOTE_FLOAT_CLOSE_BUTTON_SIZE = 16
local NOTE_FLOAT_CLOSE_BUTTON_RIGHT_INSET = 6
local NOTE_FLOAT_CLOSE_BUTTON_TOP_INSET = 4
local NOTE_FLOAT_LOCK_TEXT_RIGHT_INSET = 18
local NOTE_FLOAT_LOCK_TEXT_BOTTOM_INSET = 6
local NOTE_FLOAT_RESIZE_GRIP_SIZE = 14
local NOTE_FLOAT_RESIZE_GRIP_RIGHT_INSET = 4
local NOTE_FLOAT_RESIZE_GRIP_BOTTOM_INSET = 4
local NOTE_FLOAT_CONTROL_TEXT_COLOR = { 0.90, 0.90, 0.90, 0.90 }
local NOTE_FLOAT_CONTROL_TEXT_HOVER_COLOR = { 1.0, 1.0, 1.0, 1.0 }
local NOTE_FLOAT_LOCK_BUTTON_VISIBLE_ALPHA = 1.0
local NOTE_FLOAT_LOCK_BUTTON_IDLE_ALPHA = 0.92
local NOTE_FLOAT_LOCK_BUTTON_HIDDEN_ALPHA = 0.03
local RESIZE_START_JITTER_THRESHOLD = 2
local NOTE_FLOAT_BORDER_OUTSET = 2
local NOTE_FLOAT_BORDER_COLOR = { 1, 1, 1, 1 }

local function ApplyFloatWindowBackgroundAlpha(frame)
    if not frame or not frame.background then
        return
    end

    local alpha = module:GetFloatBackgroundAlpha()
    frame.background:SetVertexColor(
        NOTE_FLOAT_BACKGROUND_COLOR[1] or 0,
        NOTE_FLOAT_BACKGROUND_COLOR[2] or 0,
        NOTE_FLOAT_BACKGROUND_COLOR[3] or 0,
        alpha
    )
end

local function ApplyFloatWindowBorderVisibility(frame)
    if not frame or not frame.borderFrame then
        return
    end

    frame.borderFrame:SetShown(module:IsFloatBorderEnabled())
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

local function ClampFloatWindowSize(width, height)
    width = tonumber(width) or NOTE_FLOAT_WINDOW_WIDTH
    height = tonumber(height) or NOTE_FLOAT_WINDOW_HEIGHT
    local maxWidth, maxHeight = GetSafeWindowScreenBounds()

    width = math.max(NOTE_FLOAT_WINDOW_MIN_WIDTH, math.min(math.floor(width + 0.5), maxWidth))
    height = math.max(NOTE_FLOAT_WINDOW_MIN_HEIGHT, math.min(math.floor(height + 0.5), maxHeight))

    return width, height
end

local function UpdateFloatWindowInteractionState(frame)
    if not frame then
        return
    end

    local isLocked = frame.isLocked == true
    frame:SetMovable(not isLocked)
    frame:SetResizable(not isLocked)
    if frame.resizeGrip then
        frame.resizeGrip:SetShown(not isLocked)
        frame.resizeGrip:EnableMouse(not isLocked)
    end
    if frame.lockButton and frame.lockButton.text then
        frame.lockButton.text:SetText(isLocked and "unlock" or "lock")
    end
end

local function RefreshFloatWindowLockButtonVisibility(frame)
    if not frame or not frame.lockButton then
        return
    end

    local isHovered = frame.isMouseOver == true or frame.isLockButtonHovered == true
    if frame.isLocked then
        frame.lockButton:SetAlpha(isHovered and NOTE_FLOAT_LOCK_BUTTON_VISIBLE_ALPHA or NOTE_FLOAT_LOCK_BUTTON_HIDDEN_ALPHA)
    else
        frame.lockButton:SetAlpha(isHovered and NOTE_FLOAT_LOCK_BUTTON_VISIBLE_ALPHA or NOTE_FLOAT_LOCK_BUTTON_IDLE_ALPHA)
    end
end

function module:ClampFloatWindowSize(width, height)
    return ClampFloatWindowSize(width, height)
end

function module:GetFloatWindowSettings()
    local windowSettings = self:GetWindowSettings()
    windowSettings.float = windowSettings.float or {}
    local floatSettings = windowSettings.float
    floatSettings.noteId = floatSettings.noteId or nil
    floatSettings.width = tonumber(floatSettings.width) or NOTE_FLOAT_WINDOW_WIDTH
    floatSettings.height = tonumber(floatSettings.height) or NOTE_FLOAT_WINDOW_HEIGHT
    floatSettings.point = floatSettings.point or "CENTER"
    floatSettings.relativePoint = floatSettings.relativePoint or floatSettings.point or "CENTER"
    floatSettings.x = tonumber(floatSettings.x) or -300
    floatSettings.y = tonumber(floatSettings.y) or 0
    floatSettings.locked = floatSettings.locked == true
    if floatSettings.showTextures == nil then
        floatSettings.showTextures = true
    else
        floatSettings.showTextures = floatSettings.showTextures == true
    end
    floatSettings.showBorder = floatSettings.showBorder == true
    local fontScale = tonumber(floatSettings.fontScale)
    if not fontScale then
        fontScale = 1
    end
    floatSettings.fontScale = math.max(0.7, math.min(fontScale, 2.0))
    local backgroundAlpha = tonumber(floatSettings.backgroundAlpha)
    if not backgroundAlpha then
        backgroundAlpha = NOTE_FLOAT_BACKGROUND_COLOR[4] or 0.18
    end
    floatSettings.backgroundAlpha = math.max(0, math.min(backgroundAlpha, 1))
    return floatSettings
end

function module:IsFloatTexturesEnabled()
    return self:GetFloatWindowSettings().showTextures ~= false
end

function module:SetFloatTexturesEnabled(enabled)
    local settings = self:GetFloatWindowSettings()
    local normalizedEnabled = enabled == true
    if settings.showTextures == normalizedEnabled then
        return
    end

    settings.showTextures = normalizedEnabled
    self:RefreshFloatWindow()
end

function module:IsFloatBorderEnabled()
    return self:GetFloatWindowSettings().showBorder == true
end

function module:SetFloatBorderEnabled(enabled)
    local settings = self:GetFloatWindowSettings()
    local normalizedEnabled = enabled == true
    if settings.showBorder == normalizedEnabled then
        return
    end

    settings.showBorder = normalizedEnabled
    local floatWindow = self.runtime and self.runtime.floatWindow or nil
    if floatWindow then
        ApplyFloatWindowBorderVisibility(floatWindow)
    end
end

function module:GetFloatFontScale()
    return self:GetFloatWindowSettings().fontScale or 1
end

function module:SetFloatFontScale(scale)
    local settings = self:GetFloatWindowSettings()
    local normalizedScale = tonumber(scale) or 1
    normalizedScale = math.max(0.7, math.min(normalizedScale, 2.0))
    if math.abs((settings.fontScale or 1) - normalizedScale) < 0.001 then
        return
    end

    settings.fontScale = normalizedScale
    self:RefreshFloatWindow()
end

function module:GetFloatBackgroundAlpha()
    return self:GetFloatWindowSettings().backgroundAlpha or NOTE_FLOAT_BACKGROUND_COLOR[4] or 0.18
end

function module:SetFloatBackgroundAlpha(alpha)
    local settings = self:GetFloatWindowSettings()
    local normalizedAlpha = tonumber(alpha) or NOTE_FLOAT_BACKGROUND_COLOR[4] or 0.18
    normalizedAlpha = math.max(0, math.min(normalizedAlpha, 1))
    if math.abs((settings.backgroundAlpha or 0) - normalizedAlpha) < 0.001 then
        return
    end

    settings.backgroundAlpha = normalizedAlpha
    local floatWindow = self.runtime and self.runtime.floatWindow or nil
    if floatWindow then
        ApplyFloatWindowBackgroundAlpha(floatWindow)
    end
end

function module:SaveFloatWindowGeometry(frame)
    if not frame then
        return
    end

    local settings = self:GetFloatWindowSettings()
    local width, height = ClampFloatWindowSize(frame:GetWidth(), frame:GetHeight())
    settings.width = width
    settings.height = height

    local point, _, relativePoint, x, y = frame:GetPoint(1)
    settings.point = point or "CENTER"
    settings.relativePoint = relativePoint or settings.point or "CENTER"
    settings.x = x or 0
    settings.y = y or 0
    settings.locked = frame.isLocked == true
end

function module:UpdateFloatWindowResizeBounds(frame)
    if not frame then
        return
    end

    local maxWidth, maxHeight = GetSafeWindowScreenBounds()
    if frame.SetResizeBounds then
        frame:SetResizeBounds(NOTE_FLOAT_WINDOW_MIN_WIDTH, NOTE_FLOAT_WINDOW_MIN_HEIGHT, maxWidth, maxHeight)
    elseif frame.SetMaxResize then
        frame:SetMaxResize(maxWidth, maxHeight)
    end
end

function module:ApplyFloatWindowGeometry(frame)
    if not frame then
        return
    end

    local settings = self:GetFloatWindowSettings()
    self:UpdateFloatWindowResizeBounds(frame)
    local width, height = ClampFloatWindowSize(settings.width, settings.height)
    frame:SetSize(width, height)
    frame:ClearAllPoints()
    frame:SetPoint(settings.point or "CENTER", UIParent, settings.relativePoint or settings.point or "CENTER", settings.x or 0, settings.y or 0)
    self:EnsureWindowGeometryIsReachable(frame)
end

function module:GetFloatWindowProxyTab(noteId)
    if not noteId then
        return nil
    end

    self:EnsureRuntime()
    local runtime = self.runtime
    runtime.floatProxyTab = runtime.floatProxyTab or {
        assigned = true,
        isFloatProxy = true,
        key = "float",
        mode = "read",
        noteData = {},
    }

    local proxyTab = runtime.floatProxyTab
    local note = self:GetNoteById(noteId)
    if not note then
        return nil
    end

    local shouldPreserveDirtyState = proxyTab.dirty
        and proxyTab.noteData
        and proxyTab.noteData.noteId == note.id

    proxyTab.assigned = true
    proxyTab.mode = "read"
    proxyTab.noteData = proxyTab.noteData or {}
    proxyTab.noteData.noteId = note.id
    if not shouldPreserveDirtyState then
        proxyTab.noteData.title = NormalizeNoteTitle(note.title)
        proxyTab.noteData.body = note.body or DEFAULT_NOTE_BODY
    end
    proxyTab.noteData.createdAt = note.createdAt
    proxyTab.noteData.updatedAt = note.updatedAt
    return proxyTab
end

function module:GetFloatWindowOwnerTab(noteId)
    if not noteId then
        return nil
    end

    return self:GetOpenTabForNoteId(noteId) or self:GetFloatWindowProxyTab(noteId)
end

function module:IsFloatWindowShowingNote(noteId)
    local floatWindow = self.runtime and self.runtime.floatWindow or nil
    return floatWindow and floatWindow:IsShown() and floatWindow.noteId == noteId or false
end

function module:HideFloatWindow()
    local floatWindow = self.runtime and self.runtime.floatWindow or nil
    if floatWindow and floatWindow:IsShown() then
        floatWindow:Hide()
    end
end

function module:RefreshFloatWindow()
    local floatWindow = self.runtime and self.runtime.floatWindow or nil
    if not floatWindow or not floatWindow.noteId then
        return false
    end

    local note = self:GetNoteById(floatWindow.noteId)
    if not note then
        self:HideFloatWindow()
        return false
    end

    local readView = floatWindow.readView
    if not readView then
        return false
    end

    local preserveScroll = readView.renderedNoteId == note.id
    readView.noteId = note.id
    readView.ownerTab = self:GetFloatWindowOwnerTab(note.id)
    local renderedBody = note.body or DEFAULT_NOTE_BODY
    if readView.ownerTab
        and readView.ownerTab.isFloatProxy
        and readView.ownerTab.dirty
        and readView.ownerTab.noteData
        and readView.ownerTab.noteData.noteId == note.id
    then
        renderedBody = readView.ownerTab.noteData.body or renderedBody
    end

    self:RefreshFloatReadView(readView, renderedBody, preserveScroll)
    floatWindow.noteId = note.id
    self:UpdateReadItemInfoEventRegistration()
    return true
end

function module:ShowFloatWindow(noteId)
    local note = noteId and self:GetNoteById(noteId) or nil
    if not note then
        return false
    end

    local floatWindow = self:CreateFloatWindow()
    if not floatWindow then
        return false
    end

    local settings = self:GetFloatWindowSettings()
    settings.noteId = note.id
    floatWindow.noteId = note.id
    floatWindow:Show()
    self:RefreshFloatWindow()
    return true
end

function module:CreateFloatWindow()
    self:EnsureRuntime()
    if self.runtime.floatWindow then
        return self.runtime.floatWindow
    end

    local frame = CreateFrame("Frame", "SnailNotesFloatFrame", UIParent)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:RegisterForDrag("LeftButton")
    frame:Hide()

    self:ApplyFloatWindowGeometry(frame)
    local floatSettings = self:GetFloatWindowSettings()
    frame.isLocked = floatSettings.locked == true

    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetAllPoints()
    frame.background:SetTexture("Interface\\Buttons\\WHITE8x8")
    ApplyFloatWindowBackgroundAlpha(frame)

    frame.borderFrame = CreateBackdropFrame(frame, false)
    frame.borderFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", -NOTE_FLOAT_BORDER_OUTSET, NOTE_FLOAT_BORDER_OUTSET)
    frame.borderFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", NOTE_FLOAT_BORDER_OUTSET, -NOTE_FLOAT_BORDER_OUTSET)
    frame.borderFrame:EnableMouse(false)
    if frame.borderFrame.SetBackdropBorderColor then
        frame.borderFrame:SetBackdropBorderColor(unpack(NOTE_FLOAT_BORDER_COLOR))
    end
    if frame.borderFrame.SetBackdropColor then
        frame.borderFrame:SetBackdropColor(0, 0, 0, 0)
    end
    frame.borderFrame:SetFrameLevel((frame:GetFrameLevel() or 1) + 2)

    frame.contentHost = CreateFrame("Frame", nil, frame)
    frame.contentHost:SetAllPoints()

    frame.readView = self:CreateFloatRenderContentView(frame.contentHost)

    frame.closeButton = CreateFrame("Button", nil, frame)
    frame.closeButton:SetSize(NOTE_FLOAT_CLOSE_BUTTON_SIZE, NOTE_FLOAT_CLOSE_BUTTON_SIZE)
    frame.closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -NOTE_FLOAT_CLOSE_BUTTON_RIGHT_INSET, -NOTE_FLOAT_CLOSE_BUTTON_TOP_INSET)
    frame.closeButton.text = frame.closeButton:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    frame.closeButton.text:SetAllPoints()
    frame.closeButton.text:SetText("x")
    frame.closeButton:SetScript("OnEnter", function(selfButton)
        selfButton.text:SetTextColor(unpack(NOTE_FLOAT_CONTROL_TEXT_HOVER_COLOR))
    end)
    frame.closeButton:SetScript("OnLeave", function(selfButton)
        selfButton.text:SetTextColor(unpack(NOTE_FLOAT_CONTROL_TEXT_COLOR))
    end)
    frame.closeButton:SetScript("OnClick", function()
        local settings = module:GetFloatWindowSettings()
        settings.noteId = nil
        module:HideFloatWindow()
    end)
    frame.closeButton.text:SetTextColor(unpack(NOTE_FLOAT_CONTROL_TEXT_COLOR))

    frame.lockButton = CreateFrame("Button", nil, frame)
    frame.lockButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -NOTE_FLOAT_LOCK_TEXT_RIGHT_INSET, NOTE_FLOAT_LOCK_TEXT_BOTTOM_INSET)
    frame.lockButton:SetSize(40, 14)
    frame.lockButton.text = frame.lockButton:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    frame.lockButton.text:SetAllPoints()
    frame.lockButton.text:SetJustifyH("RIGHT")
    frame.lockButton.text:SetTextColor(unpack(NOTE_FLOAT_CONTROL_TEXT_COLOR))
    frame.lockButton:SetScript("OnEnter", function(selfButton)
        frame.isLockButtonHovered = true
        selfButton.text:SetTextColor(unpack(NOTE_FLOAT_CONTROL_TEXT_HOVER_COLOR))
        RefreshFloatWindowLockButtonVisibility(frame)
    end)
    frame.lockButton:SetScript("OnLeave", function(selfButton)
        frame.isLockButtonHovered = nil
        selfButton.text:SetTextColor(unpack(NOTE_FLOAT_CONTROL_TEXT_COLOR))
        RefreshFloatWindowLockButtonVisibility(frame)
    end)
    frame.lockButton:SetScript("OnClick", function()
        frame.isLocked = not frame.isLocked
        local settings = module:GetFloatWindowSettings()
        settings.locked = frame.isLocked == true
        UpdateFloatWindowInteractionState(frame)
        RefreshFloatWindowLockButtonVisibility(frame)
    end)

    frame.resizeGrip = CreateFrame("Button", nil, frame)
    frame.resizeGrip:SetSize(NOTE_FLOAT_RESIZE_GRIP_SIZE, NOTE_FLOAT_RESIZE_GRIP_SIZE)
    frame.resizeGrip:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -NOTE_FLOAT_RESIZE_GRIP_RIGHT_INSET, NOTE_FLOAT_RESIZE_GRIP_BOTTOM_INSET)
    frame.resizeGrip.text = frame.resizeGrip:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    frame.resizeGrip.text:SetAllPoints()
    frame.resizeGrip.text:SetText("+")
    frame.resizeGrip.text:SetTextColor(unpack(NOTE_FLOAT_CONTROL_TEXT_COLOR))
    frame.resizeGrip:RegisterForDrag("LeftButton")
    frame.resizeGrip:SetScript("OnEnter", function(selfButton)
        selfButton.text:SetTextColor(unpack(NOTE_FLOAT_CONTROL_TEXT_HOVER_COLOR))
    end)
    frame.resizeGrip:SetScript("OnLeave", function(selfButton)
        selfButton.text:SetTextColor(unpack(NOTE_FLOAT_CONTROL_TEXT_COLOR))
    end)
    frame.resizeGrip:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" and not frame.isLocked then
            BeginResizeFromGrip(frame)
        end
    end)
    frame.resizeGrip:SetScript("OnDragStart", function()
        if frame.isLocked then
            return
        end
        BeginResizeFromGrip(frame)
        frame.isSizingByGrip = true
        frame:StartSizing("BOTTOMRIGHT")
    end)
    frame.resizeGrip:SetScript("OnDragStop", function()
        if frame.isSizingByGrip then
            frame:StopMovingOrSizing()
        end
        EndResizeFromGrip(frame)
        module:SaveFloatWindowGeometry(frame)
    end)
    frame.resizeGrip:SetScript("OnMouseUp", function(_, button)
        if button ~= "LeftButton" or not frame.isSizingByGrip then
            return
        end

        frame:StopMovingOrSizing()
        EndResizeFromGrip(frame)
        module:SaveFloatWindowGeometry(frame)
    end)

    frame:SetScript("OnDragStart", function(selfFrame)
        if selfFrame.isLocked then
            return
        end
        selfFrame:StartMoving()
        selfFrame.isMovingByDrag = true
    end)
    frame:SetScript("OnDragStop", function(selfFrame)
        if selfFrame.isMovingByDrag then
            selfFrame:StopMovingOrSizing()
        end
        selfFrame.isMovingByDrag = nil
        module:SaveFloatWindowGeometry(selfFrame)
    end)
    frame:SetScript("OnMouseDown", function()
        module:HideRowActionMenu()
        module:HideTabContextMenu()
    end)
    frame:SetScript("OnEnter", function(selfFrame)
        selfFrame.isMouseOver = true
        RefreshFloatWindowLockButtonVisibility(selfFrame)
    end)
    frame:SetScript("OnLeave", function(selfFrame)
        selfFrame.isMouseOver = nil
        RefreshFloatWindowLockButtonVisibility(selfFrame)
    end)
    frame:SetScript("OnHide", function(selfFrame)
        EndResizeFromGrip(selfFrame)
        module:SaveFloatWindowGeometry(selfFrame)
        selfFrame.noteId = nil
        selfFrame.isMouseOver = nil
        selfFrame.isLockButtonHovered = nil
        if selfFrame.readView then
            selfFrame.readView.noteId = nil
            selfFrame.readView.ownerTab = nil
        end
        module:UpdateReadItemInfoEventRegistration()
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

        local clampedWidth, clampedHeight = module:ClampFloatWindowSize(width, height)
        if not selfFrame.enforcingSize and (math.abs(width - clampedWidth) > 0.5 or math.abs(height - clampedHeight) > 0.5) then
            selfFrame.enforcingSize = true
            selfFrame:SetSize(clampedWidth, clampedHeight)
            selfFrame.enforcingSize = false
            return
        end

        module:SaveFloatWindowGeometry(selfFrame)
        module:UpdateFloatReadViewLayout(selfFrame.readView)
    end)
    frame:SetScript("OnShow", function(selfFrame)
        module:ApplyFloatWindowGeometry(selfFrame)
        ApplyFloatWindowBackgroundAlpha(selfFrame)
        ApplyFloatWindowBorderVisibility(selfFrame)
        UpdateFloatWindowInteractionState(selfFrame)
        RefreshFloatWindowLockButtonVisibility(selfFrame)
        module:UpdateFloatRenderSettings(selfFrame.readView)
    end)

    UpdateFloatWindowInteractionState(frame)
    RefreshFloatWindowLockButtonVisibility(frame)
    ApplyFloatWindowBorderVisibility(frame)

    self.runtime.floatWindow = frame
    return frame
end
