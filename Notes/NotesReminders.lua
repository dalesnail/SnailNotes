local _, ns = ...
local shared = ns.NotesShared
local module = shared and shared.module
if not shared or not module then return end

local REMINDER_TRIGGERS = {
    mail = true,
    auction = true,
    bank = true,
    login = true,
}
local REMINDER_EVENT_TRIGGERS = {
    MAIL_SHOW = { trigger = "mail", action = "open" },
    MAIL_CLOSED = { trigger = "mail", action = "close" },
    BANKFRAME_OPENED = { trigger = "bank", action = "open" },
    BANKFRAME_CLOSED = { trigger = "bank", action = "close" },
    AUCTION_HOUSE_SHOW = { trigger = "auction", action = "open" },
    AUCTION_HOUSE_CLOSED = { trigger = "auction", action = "close" },
}
local REMINDER_EVENTS = {
    "MAIL_SHOW",
    "MAIL_CLOSED",
    "BANKFRAME_OPENED",
    "BANKFRAME_CLOSED",
    "AUCTION_HOUSE_SHOW",
    "AUCTION_HOUSE_CLOSED",
}

local activeReminderBlocksByTrigger = {
    mail = {},
    auction = {},
    bank = {},
    login = {},
}
local lastReminderPayload = nil
local reminderEventsRegistered = false
local loginReminderTriggered = false
local reminderCloseFallbacks = {}
local REMINDER_FLOAT_DEFAULT_WIDTH = 420
local REMINDER_FLOAT_DEFAULT_HEIGHT = 300
local REMINDER_FLOAT_MIN_WIDTH = 260
local REMINDER_FLOAT_MIN_HEIGHT = 180

local function NormalizeLineEndings(text)
    local normalizedText = tostring(text or "")
    normalizedText = string.gsub(normalizedText, "\r\n", "\n")
    normalizedText = string.gsub(normalizedText, "\r", "\n")
    return normalizedText
end

local function IsReminderTrigger(trigger)
    return REMINDER_TRIGGERS[tostring(trigger or ""):lower()] == true
end

local function GetReminderOpeningLineTrigger(lineText)
    local trigger = string.match(tostring(lineText or ""), "^[ \t]*%[!%s+([%a]+)%][ \t]*$")
    if IsReminderTrigger(trigger) then
        return tostring(trigger):lower()
    end

    return nil
end

local function IsReminderClosingLine(lineText)
    return string.match(tostring(lineText or ""), "^[ \t]*%[!%][ \t]*$") ~= nil
end

local function FindReminderBlockClose(text, startIndex)
    local closeStart, closeEnd = string.find(text, "%[!%]", startIndex)
    return closeStart, closeEnd
end

local function FindReminderBlockOpen(text, startIndex)
    local openStart, openEnd, trigger = string.find(text, "%[!%s+([%a]+)%]", startIndex)
    return openStart, openEnd, trigger
end

local function FindSupportedReminderBlockOpen(text, startIndex)
    local searchStart = startIndex
    while searchStart <= string.len(text) do
        local openStart, openEnd, trigger = FindReminderBlockOpen(text, searchStart)
        if not openStart then
            return nil
        end

        if IsReminderTrigger(trigger) then
            return openStart, openEnd, trigger
        end

        searchStart = openEnd + 1
    end

    return nil
end

local function GetSourceLineIndexAtPosition(text, position)
    local safePosition = math.max(tonumber(position) or 1, 1)
    local prefix = string.sub(tostring(text or ""), 1, safePosition - 1)
    local _, newlineCount = string.gsub(prefix, "\n", "")
    return newlineCount + 1
end

local function BuildSourceLineRecordsForRange(bodyText, firstLineIndex, lastLineIndex, noteId)
    local text = NormalizeLineEndings(bodyText)
    local lines = {}
    local sourceLineIndex = 0
    local textEndsWithNewline = string.sub(text, -1) == "\n"
    local _, newlineCount = string.gsub(text, "\n", "")

    if not firstLineIndex or not lastLineIndex or firstLineIndex > lastLineIndex then
        return lines
    end

    for line in string.gmatch(text .. "\n", "(.-)\n") do
        sourceLineIndex = sourceLineIndex + 1
        local isArtificialTrailingLine = textEndsWithNewline and sourceLineIndex == newlineCount + 1
        if not isArtificialTrailingLine and sourceLineIndex >= firstLineIndex and sourceLineIndex <= lastLineIndex then
            lines[#lines + 1] = {
                text = line,
                sourceLineIndex = sourceLineIndex,
                noteId = noteId,
            }
        end
    end

    return lines
end

local function ParseReminderBlocks(bodyText, noteTitle, noteId)
    local text = tostring(bodyText or "")
    local reminders = {}
    local searchStart = 1

    while searchStart <= string.len(text) do
        local openStart, openEnd, trigger = FindReminderBlockOpen(text, searchStart)
        if not openStart then
            break
        end

        local normalizedTrigger = tostring(trigger or ""):lower()
        if IsReminderTrigger(normalizedTrigger) then
            local closeStart, closeEnd = FindReminderBlockClose(text, openEnd + 1)
            local nextOpenStart = FindSupportedReminderBlockOpen(text, openEnd + 1)
            if closeStart and (not nextOpenStart or closeStart < nextOpenStart) then
                local openLineIndex = GetSourceLineIndexAtPosition(text, openStart)
                local closeLineIndex = GetSourceLineIndexAtPosition(text, closeStart)
                reminders[#reminders + 1] = {
                    trigger = normalizedTrigger,
                    content = string.sub(text, openEnd + 1, closeStart - 1),
                    noteTitle = noteTitle,
                    noteId = noteId,
                    contentLines = BuildSourceLineRecordsForRange(text, openLineIndex + 1, closeLineIndex - 1, noteId),
                }
                searchStart = closeEnd + 1
            else
                searchStart = openEnd + 1
            end
        else
            searchStart = openEnd + 1
        end
    end

    return reminders
end

local function GetReminderNoteGroupKey(reminderBlock)
    return tostring(reminderBlock and reminderBlock.noteId or reminderBlock and reminderBlock.noteTitle or "")
end

local function AppendReminderBlockLines(displayLines, reminderBlock)
    for _, lineData in ipairs(reminderBlock and reminderBlock.contentLines or {}) do
        displayLines[#displayLines + 1] = {
            text = lineData.text or "",
            sourceLineIndex = lineData.sourceLineIndex,
            noteId = lineData.noteId or reminderBlock.noteId,
        }
    end
end

local function BuildReminderDisplayLines(reminderBlocks)
    local displayLines = {}
    local activeGroupKey = nil
    local hasAnyContent = false

    for _, reminderBlock in ipairs(reminderBlocks or {}) do
        local groupKey = GetReminderNoteGroupKey(reminderBlock)
        if groupKey ~= activeGroupKey then
            if #displayLines > 0 then
                displayLines[#displayLines + 1] = {
                    text = "",
                    sourceLineIndex = nil,
                    noteId = nil,
                }
            end
            displayLines[#displayLines + 1] = {
                text = reminderBlock.noteTitle or "Note",
                sourceLineIndex = nil,
                noteId = reminderBlock.noteId,
                lineType = "reminderNoteTitle",
            }
            activeGroupKey = groupKey
        elseif hasAnyContent then
            displayLines[#displayLines + 1] = {
                text = "",
                sourceLineIndex = nil,
                noteId = reminderBlock.noteId,
            }
        end

        AppendReminderBlockLines(displayLines, reminderBlock)
        hasAnyContent = true
    end

    return displayLines
end

local function CopyReminderBlocks(reminderBlocks)
    local copy = {}
    for index, reminderBlock in ipairs(reminderBlocks or {}) do
        copy[index] = reminderBlock
    end
    return copy
end

local function CollectReminderBlocksForTrigger(trigger)
    local normalizedTrigger = tostring(trigger or ""):lower()
    local matchingBlocks = {}

    if not IsReminderTrigger(normalizedTrigger) or not module.GetAllReminderBlocks then
        return matchingBlocks
    end

    for _, reminderBlock in ipairs(module:GetAllReminderBlocks() or {}) do
        if tostring(reminderBlock and reminderBlock.trigger or ""):lower() == normalizedTrigger then
            matchingBlocks[#matchingBlocks + 1] = reminderBlock
        end
    end

    return matchingBlocks
end

local function SetActiveReminderBlocks(trigger, reminderBlocks)
    local normalizedTrigger = tostring(trigger or ""):lower()
    if not IsReminderTrigger(normalizedTrigger) then
        return
    end

    activeReminderBlocksByTrigger[normalizedTrigger] = CopyReminderBlocks(reminderBlocks)
    lastReminderPayload = {
        trigger = normalizedTrigger,
        blocks = CopyReminderBlocks(reminderBlocks),
    }
end

local function ClearActiveReminderBlocks(trigger)
    local normalizedTrigger = tostring(trigger or ""):lower()
    if not IsReminderTrigger(normalizedTrigger) then
        return
    end

    activeReminderBlocksByTrigger[normalizedTrigger] = {}
    lastReminderPayload = {
        trigger = normalizedTrigger,
        blocks = {},
    }
end

local function ApplyReminderFloatGeometry(frame)
    if not frame then
        return
    end

    local maxWidth, maxHeight = UIParent and UIParent:GetWidth() or REMINDER_FLOAT_DEFAULT_WIDTH, UIParent and UIParent:GetHeight() or REMINDER_FLOAT_DEFAULT_HEIGHT
    local width = math.max(REMINDER_FLOAT_MIN_WIDTH, math.min(REMINDER_FLOAT_DEFAULT_WIDTH, math.floor((maxWidth or REMINDER_FLOAT_DEFAULT_WIDTH) - 48)))
    local height = math.max(REMINDER_FLOAT_MIN_HEIGHT, math.min(REMINDER_FLOAT_DEFAULT_HEIGHT, math.floor((maxHeight or REMINDER_FLOAT_DEFAULT_HEIGHT) - 48)))
    frame:SetSize(width, height)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", 260, 120)
end

local function ApplyReminderFloatBackground(frame)
    if not frame or not frame.background then
        return
    end

    local alpha = module.GetFloatBackgroundAlpha and module:GetFloatBackgroundAlpha() or 0.18
    frame.background:SetVertexColor(0, 0, 0, alpha)
end

local function HookReminderCloseFallbackFrame(trigger, frameName)
    if reminderCloseFallbacks[frameName] then
        return true
    end

    local frame = _G and _G[frameName] or nil
    if not frame or not frame.HookScript then
        return false
    end

    frame:HookScript("OnHide", function()
        module:HandleReminderTriggerClose(trigger)
    end)
    reminderCloseFallbacks[frameName] = true
    return true
end

local function EnsureReminderCloseFallback(trigger)
    local normalizedTrigger = tostring(trigger or ""):lower()
    if normalizedTrigger == "mail" then
        HookReminderCloseFallbackFrame("mail", "MailFrame")
    elseif normalizedTrigger == "bank" then
        HookReminderCloseFallbackFrame("bank", "BankFrame")
    elseif normalizedTrigger == "auction" then
        HookReminderCloseFallbackFrame("auction", "AuctionHouseFrame")
        HookReminderCloseFallbackFrame("auction", "AuctionFrame")
    end
end

local function BuildDisplayLinesWithSourceIndexes(bodyText)
    local text = NormalizeLineEndings(bodyText)
    local lines = {}
    local removedMarkerLine = false
    local previousSourceLineWasMarker = false
    local sourceLineIndex = 0
    local textEndsWithNewline = string.sub(text, -1) == "\n"
    local _, newlineCount = string.gsub(text, "\n", "")

    for line in string.gmatch(text .. "\n", "(.-)\n") do
        sourceLineIndex = sourceLineIndex + 1
        local isArtificialTrailingLine = textEndsWithNewline and sourceLineIndex == newlineCount + 1
        local isMarkerLine = GetReminderOpeningLineTrigger(line) or IsReminderClosingLine(line)

        if isMarkerLine then
            removedMarkerLine = true
            previousSourceLineWasMarker = true
        elseif not (isArtificialTrailingLine and previousSourceLineWasMarker) then
            lines[#lines + 1] = {
                text = line,
                sourceLineIndex = sourceLineIndex,
            }
            previousSourceLineWasMarker = false
        end
    end

    if #lines == 0 then
        lines[1] = {
            text = "",
            sourceLineIndex = 1,
        }
    end

    return lines, removedMarkerLine
end

local function StripReminderBlocksForRender(bodyText)
    local lines, removedMarkerLine = BuildDisplayLinesWithSourceIndexes(bodyText)
    if not removedMarkerLine then
        return NormalizeLineEndings(bodyText)
    end

    local displayLines = {}
    for index, lineData in ipairs(lines) do
        displayLines[index] = lineData.text or ""
    end
    return table.concat(displayLines, "\n")
end

function module:ParseReminderBlocks(bodyText, noteTitle, noteId)
    return ParseReminderBlocks(bodyText, noteTitle, noteId)
end

function module:StripReminderBlocksForRender(bodyText)
    return StripReminderBlocksForRender(bodyText)
end

function module:BuildDisplayLinesWithSourceIndexes(bodyText)
    return BuildDisplayLinesWithSourceIndexes(bodyText)
end

function module:StripReminderTags(bodyText)
    return StripReminderBlocksForRender(bodyText)
end

function module:PrepareTextForDisplay(bodyText)
    return StripReminderBlocksForRender(bodyText)
end

function module:GetAllReminderBlocks()
    local reminders = {}

    for _, note in ipairs(self:GetOrderedNotes()) do
        local noteReminders = ParseReminderBlocks(note and note.body or "", note and note.title or nil, note and note.id or nil)
        for _, reminder in ipairs(noteReminders) do
            reminders[#reminders + 1] = reminder
        end
    end

    return reminders
end

function module:BuildReminderDisplayLines(reminderBlocks)
    return BuildReminderDisplayLines(reminderBlocks)
end

function module:CreateReminderFloatWindow()
    self:EnsureRuntime()
    if self.runtime.reminderFloatWindow then
        return self.runtime.reminderFloatWindow
    end

    local frame = CreateFrame("Frame", "SnailNotesReminderFloatFrame", UIParent)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:RegisterForDrag("LeftButton")
    frame:Hide()

    if frame.SetResizeBounds then
        frame:SetResizeBounds(REMINDER_FLOAT_MIN_WIDTH, REMINDER_FLOAT_MIN_HEIGHT, UIParent:GetWidth(), UIParent:GetHeight())
    elseif frame.SetMinResize then
        frame:SetMinResize(REMINDER_FLOAT_MIN_WIDTH, REMINDER_FLOAT_MIN_HEIGHT)
    end

    ApplyReminderFloatGeometry(frame)

    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetAllPoints()
    frame.background:SetTexture("Interface\\Buttons\\WHITE8x8")
    ApplyReminderFloatBackground(frame)

    frame.titleText = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    frame.titleText:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -6)
    frame.titleText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -30, -6)
    frame.titleText:SetJustifyH("LEFT")
    frame.titleText:SetTextColor(0.72, 0.72, 0.72, 0.95)
    frame.titleText:SetText("Reminders")

    frame.closeButton = CreateFrame("Button", nil, frame)
    frame.closeButton:SetSize(18, 18)
    frame.closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -4)
    frame.closeButton.text = frame.closeButton:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    frame.closeButton.text:SetAllPoints()
    frame.closeButton.text:SetText("x")
    frame.closeButton.text:SetTextColor(0.90, 0.90, 0.90, 0.90)
    frame.closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    frame.contentHost = CreateFrame("Frame", nil, frame)
    frame.contentHost:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -24)
    frame.contentHost:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
    frame.readView = self:CreateFloatRenderContentView(frame.contentHost)
    frame.readView.isReminderView = true

    frame:SetScript("OnDragStart", function(selfFrame)
        selfFrame:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(selfFrame)
        selfFrame:StopMovingOrSizing()
    end)
    frame:SetScript("OnHide", function(selfFrame)
        selfFrame.reminderTrigger = nil
        if selfFrame.readView then
            selfFrame.readView.currentBodyText = nil
            selfFrame.readView.noteId = nil
            selfFrame.readView.ownerTab = nil
        end
    end)
    frame:SetScript("OnSizeChanged", function(selfFrame)
        if selfFrame.readView and selfFrame.readView.currentBodyText ~= nil then
            module:RefreshFloatReadView(selfFrame.readView, selfFrame.readView.currentBodyText, true)
        end
    end)

    self.runtime.reminderFloatWindow = frame
    return frame
end

function module:ShowReminderFloat(trigger, reminderBlocks)
    if not reminderBlocks or #reminderBlocks == 0 then
        return false
    end

    local frame = self:CreateReminderFloatWindow()
    if not frame or not frame.readView then
        return false
    end

    local displayLines = BuildReminderDisplayLines(reminderBlocks)
    frame.reminderTrigger = tostring(trigger or ""):lower()
    if frame.titleText then
        frame.titleText:SetText(string.format("%s reminders", frame.reminderTrigger))
    end
    ApplyReminderFloatBackground(frame)
    frame:Show()
    frame.readView.noteId = nil
    frame.readView.ownerTab = nil
    self:RefreshFloatReadView(frame.readView, displayLines, false)
    return true
end

function module:HideReminderFloat(trigger)
    local frame = self.runtime and self.runtime.reminderFloatWindow or nil
    if not frame or not frame:IsShown() then
        return
    end

    local normalizedTrigger = tostring(trigger or ""):lower()
    if normalizedTrigger ~= "" and frame.reminderTrigger ~= normalizedTrigger then
        return
    end

    frame:Hide()
end

function module:RefreshReminderFloatWindow()
    local frame = self.runtime and self.runtime.reminderFloatWindow or nil
    if not frame or not frame:IsShown() or not frame.reminderTrigger then
        return
    end

    local matchingBlocks = CollectReminderBlocksForTrigger(frame.reminderTrigger)
    SetActiveReminderBlocks(frame.reminderTrigger, matchingBlocks)
    if #matchingBlocks == 0 then
        frame:Hide()
        return
    end

    self:ShowReminderFloat(frame.reminderTrigger, matchingBlocks)
end

function module:HandleReminderTriggerOpen(trigger)
    local matchingBlocks = CollectReminderBlocksForTrigger(trigger)
    SetActiveReminderBlocks(trigger, matchingBlocks)
    EnsureReminderCloseFallback(trigger)
    if #matchingBlocks > 0 then
        self:ShowReminderFloat(trigger, matchingBlocks)
    else
        self:HideReminderFloat(trigger)
    end

    return matchingBlocks
end

function module:HandleReminderTriggerClose(trigger)
    ClearActiveReminderBlocks(trigger)
    if tostring(trigger or ""):lower() ~= "login" then
        self:HideReminderFloat(trigger)
    end
end

function module:GetActiveReminderBlocks(trigger)
    local normalizedTrigger = tostring(trigger or ""):lower()
    if not IsReminderTrigger(normalizedTrigger) then
        return {}
    end

    return CopyReminderBlocks(activeReminderBlocksByTrigger[normalizedTrigger])
end

function module:GetLastReminderPayload()
    if not lastReminderPayload then
        return nil
    end

    return {
        trigger = lastReminderPayload.trigger,
        blocks = CopyReminderBlocks(lastReminderPayload.blocks),
    }
end

function module:HandleReminderEvent(eventName)
    local eventData = REMINDER_EVENT_TRIGGERS[eventName]
    if not eventData then
        return
    end

    if eventData.action == "open" then
        self:HandleReminderTriggerOpen(eventData.trigger)
    else
        self:HandleReminderTriggerClose(eventData.trigger)
    end
end

function module:InitializeReminderEvents()
    if reminderEventsRegistered then
        return
    end

    for _, eventName in ipairs(REMINDER_EVENTS) do
        if self.RegisterEvent then
            local ok = pcall(function()
                self:RegisterEvent(eventName, "HandleReminderEvent")
            end)
            if ok then
                reminderEventsRegistered = true
            end
        end
    end
end

function module:TriggerLoginRemindersOnce()
    if loginReminderTriggered then
        return
    end

    loginReminderTriggered = true
    self:HandleReminderTriggerOpen("login")
end

shared.reminders = {
    ParseReminderBlocks = ParseReminderBlocks,
    BuildDisplayLinesWithSourceIndexes = BuildDisplayLinesWithSourceIndexes,
    BuildReminderDisplayLines = BuildReminderDisplayLines,
    StripReminderBlocksForRender = StripReminderBlocksForRender,
    StripReminderTags = StripReminderBlocksForRender,
    PrepareTextForDisplay = StripReminderBlocksForRender,
}
