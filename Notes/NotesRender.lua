local _, ns = ...
local shared = ns.NotesShared
local module = shared and shared.module
if not shared or not module then return end
local constants = shared.constants
local NOTE_TAB_FIELD_INNER_X = constants.NOTE_TAB_FIELD_INNER_X
local NOTE_TAB_FIELD_INNER_Y = constants.NOTE_TAB_FIELD_INNER_Y
local NOTE_TAB_BODY_MIN_CONTENT_HEIGHT = constants.NOTE_TAB_BODY_MIN_CONTENT_HEIGHT
local NOTE_TAB_BODY_NATIVE_LEFT_INSET = constants.NOTE_TAB_BODY_NATIVE_LEFT_INSET
local NOTE_TAB_BODY_NATIVE_TOP_INSET = constants.NOTE_TAB_BODY_NATIVE_TOP_INSET
local NOTE_TAB_BODY_NATIVE_RIGHT_INSET = constants.NOTE_TAB_BODY_NATIVE_RIGHT_INSET
local NOTE_TAB_BODY_NATIVE_BOTTOM_INSET = constants.NOTE_TAB_BODY_NATIVE_BOTTOM_INSET
local NOTE_TAB_BODY_SCROLLBAR_WIDTH = constants.NOTE_TAB_BODY_SCROLLBAR_WIDTH
local NOTE_TAB_BODY_SCROLLBAR_X_OFFSET = constants.NOTE_TAB_BODY_SCROLLBAR_X_OFFSET
local NOTE_TAB_BODY_SCROLLBAR_LEFT_INSET = constants.NOTE_TAB_BODY_SCROLLBAR_LEFT_INSET
local NOTE_TAB_BODY_SCROLLBAR_TOP_INSET = constants.NOTE_TAB_BODY_SCROLLBAR_TOP_INSET
local NOTE_TAB_BODY_SCROLLBAR_GAP = constants.NOTE_TAB_BODY_SCROLLBAR_GAP
local NOTE_TAB_BODY_SCROLLBAR_RIGHT_INSET = constants.NOTE_TAB_BODY_SCROLLBAR_RIGHT_INSET
local NOTE_TAB_BODY_SCROLLBAR_BOTTOM_INSET = constants.NOTE_TAB_BODY_SCROLLBAR_BOTTOM_INSET
local READ_SEPARATOR_COLOR = constants.READ_SEPARATOR_COLOR
local READ_CODE_BACKGROUND_COLOR = constants.READ_CODE_BACKGROUND_COLOR
local READ_LINE_VERTICAL_SPACING = constants.READ_LINE_VERTICAL_SPACING
local READ_HEADER_VERTICAL_SPACING = constants.READ_HEADER_VERTICAL_SPACING
local READ_POST_BULLET_BLOCK_SPACING = constants.READ_POST_BULLET_BLOCK_SPACING
local READ_LINE_FONT_SIZE = constants.READ_LINE_FONT_SIZE
local READ_HEADER1_FONT_SIZE = constants.READ_HEADER1_FONT_SIZE
local READ_HEADER2_FONT_SIZE = constants.READ_HEADER2_FONT_SIZE
local READ_HEADER3_FONT_SIZE = constants.READ_HEADER3_FONT_SIZE
local READ_BULLET_INDENT = constants.READ_BULLET_INDENT
local READ_BLANK_LINE_HEIGHT = constants.READ_BLANK_LINE_HEIGHT
local READ_SEPARATOR_ROW_HEIGHT = constants.READ_SEPARATOR_ROW_HEIGHT
local READ_SEPARATOR_SIDE_INSET = constants.READ_SEPARATOR_SIDE_INSET
local READ_SEPARATOR_THICKNESS = constants.READ_SEPARATOR_THICKNESS
local READ_UNRESOLVED_ITEM_TOKEN_COLOR = constants.READ_UNRESOLVED_ITEM_TOKEN_COLOR
local FONT_REGULAR = constants.FONT_REGULAR
local FONT_ITALIC = constants.FONT_ITALIC
local FONT_BOLD = constants.FONT_BOLD
local FONT_BOLDITALIC = constants.FONT_BOLDITALIC
local DEFAULT_NOTE_BODY = constants.DEFAULT_NOTE_BODY
local READ_SAME_NOTE_LINK_COLOR = { 0.45, 0.82, 1.0 }
local READ_TASK_CHECKED_TEXT_COLOR = { 0.72, 0.72, 0.72 }
local READ_TASK_CHECKED_MARKER_COLOR = { 0.55, 0.92, 0.55 }
local READ_TASK_UNCHECKED_MARKER_COLOR = { 0.93, 0.90, 0.84 }
local READ_TASK_UNCHECKED_GLYPH = "[  ]"
local READ_TASK_CHECKED_GLYPH = "[✓]"
local READ_INLINE_CODE_TEXT_COLOR = { 0.80, 0.80, 0.80 }
local READ_INLINE_CODE_BACKGROUND_COLOR = { 0.02, 0.02, 0.02, 0.34 }
local READ_CODE_TEXT_COLOR = { 0.80, 0.80, 0.80 }
local READ_INLINE_CODE_PADDING_X = 5
local READ_INLINE_CODE_PADDING_Y = 2
local READ_CODE_LINE_SPACING = 2
local READ_CODE_BLOCK_PADDING_X = 8
local READ_CODE_BLOCK_PADDING_Y = 6

local function IsReadListLineType(lineType)
    return lineType == "bullet" or lineType == "numbered" or lineType == "taskUnchecked" or lineType == "taskChecked"
end

local function GetReadTaskMarkerGlyph(lineType)
    if lineType == "taskChecked" then
        return READ_TASK_CHECKED_GLYPH
    end

    if lineType == "taskUnchecked" then
        return READ_TASK_UNCHECKED_GLYPH
    end

    return nil
end

local function GetColorCode(color)
    local r = math.floor(math.max(math.min((color and color[1]) or 1, 1), 0) * 255)
    local g = math.floor(math.max(math.min((color and color[2]) or 1, 1), 0) * 255)
    local b = math.floor(math.max(math.min((color and color[3]) or 1, 1), 0) * 255)
    return string.format("|cff%02x%02x%02x", r, g, b)
end

local function ParseReadViewAtlasLine(rawLine)
    local lineText = tostring(rawLine or "")
    local atlasName, width, height = string.match(lineText, "^%[@atlas%s+([^%s%]]+)%s+(%d+)x(%d+)%s*%]$")
    if atlasName then
        return {
            rawText = lineText,
            atlasName = atlasName,
            width = tonumber(width),
            height = tonumber(height),
        }
    end

    atlasName = string.match(lineText, "^%[@atlas%s+([^%s%]]+)%s*%]$")
    if atlasName then
        return {
            rawText = lineText,
            atlasName = atlasName,
        }
    end

    return nil
end

local function IsReadViewCenteredBlockStart(rawLine)
    return tostring(rawLine or "") == "[c]"
end

local function IsReadViewCenteredBlockEnd(rawLine)
    return tostring(rawLine or "") == "[/c]"
end

local function IsReadViewCodeFence(rawLine)
    return tostring(rawLine or "") == "```"
end

local function SplitNoteBodyIntoLines(bodyText)
    local text = tostring(bodyText or "")
    local normalizedText = string.gsub(text, "\r\n", "\n")
    normalizedText = string.gsub(normalizedText, "\r", "\n")

    local lines = {}
    if normalizedText == "" then
        lines[1] = ""
        return lines
    end

    for line in string.gmatch(normalizedText .. "\n", "(.-)\n") do
        lines[#lines + 1] = line
    end

    return lines
end

local function ClassifyReadViewLine(rawLine)
    local lineText = tostring(rawLine or "")

    if lineText == "" then
        return "blank", ""
    end

    if string.match(lineText, "^###%s+") then
        return "h3", string.gsub(lineText, "^###%s+", "", 1)
    end

    if string.match(lineText, "^##%s+") then
        return "h2", string.gsub(lineText, "^##%s+", "", 1)
    end

    if string.match(lineText, "^#%s+") then
        return "h1", string.gsub(lineText, "^#%s+", "", 1)
    end

    local taskUncheckedText = string.match(lineText, "^%-%s+%[%]%s+(.+)$")
    if taskUncheckedText then
        return "taskUnchecked", taskUncheckedText, GetReadTaskMarkerGlyph("taskUnchecked")
    end

    local taskCheckedText = string.match(lineText, "^%-%s+%[[xX]%]%s+(.+)$")
    if taskCheckedText then
        return "taskChecked", taskCheckedText, GetReadTaskMarkerGlyph("taskChecked")
    end

    local listNumber, numberedText = string.match(lineText, "^(%d+)%.%s+(.+)$")
    if listNumber and numberedText then
        return "numbered", numberedText, tostring(listNumber) .. "."
    end

    if string.match(lineText, "^%-%s+") then
        return "bullet", string.gsub(lineText, "^%-%s+", "", 1), "•"
    end

    if lineText == "---" then
        return "separator", ""
    end

    local atlasData = ParseReadViewAtlasLine(lineText)
    if atlasData then
        return "atlas", atlasData
    end

    return "plain", lineText
end

local function ParseReadViewHeaderAnchorSuffix(headerText)
    local text = tostring(headerText or "")
    local trimmedText, anchorId = string.match(text, "^(.-)%s+%[([a-z0-9-]+)%]$")
    if not trimmedText or not anchorId then
        return text, nil
    end

    return trimmedText, anchorId
end

local function ParseReadViewInlineSegments(lineText)
    local text = tostring(lineText or "")
    local segments = {}
    local searchStart = 1

    local function AppendPlainTextSegments(plainText)
        local sourceText = tostring(plainText or "")
        if sourceText == "" then
            return
        end

        if string.find(sourceText, "`", 1, true) then
            segments[#segments + 1] = {
                kind = "text",
                style = "plain",
                text = sourceText,
            }
            return
        end

        local plainSearchStart = 1
        local textLength = string.len(sourceText)

        local function IsPlainFormattingInnerTextValid(innerText)
            local candidate = tostring(innerText or "")
            if candidate == "" then
                return false
            end

            return not string.find(candidate, "%*%*", 1, true) and not string.find(candidate, "__", 1, true)
        end

        local function FindNextFormattingToken(startIndex)
            local candidates = {}

            local boldItalicStart, boldItalicEnd, boldItalicText = string.find(sourceText, "%*%*__([^%c]-)__%*%*", startIndex)
            if boldItalicStart and IsPlainFormattingInnerTextValid(boldItalicText) then
                candidates[#candidates + 1] = {
                    tokenStart = boldItalicStart,
                    tokenEnd = boldItalicEnd,
                    style = "bolditalic",
                    innerText = boldItalicText,
                    priority = 1,
                }
            end

            local reverseBoldItalicStart, reverseBoldItalicEnd, reverseBoldItalicText = string.find(sourceText, "__%*%*([^%c]-)%*%*__", startIndex)
            if reverseBoldItalicStart and IsPlainFormattingInnerTextValid(reverseBoldItalicText) then
                candidates[#candidates + 1] = {
                    tokenStart = reverseBoldItalicStart,
                    tokenEnd = reverseBoldItalicEnd,
                    style = "bolditalic",
                    innerText = reverseBoldItalicText,
                    priority = 1,
                }
            end

            local boldStart, boldEnd, boldText = string.find(sourceText, "%*%*([^%c]-)%*%*", startIndex)
            if boldStart and IsPlainFormattingInnerTextValid(boldText) then
                candidates[#candidates + 1] = {
                    tokenStart = boldStart,
                    tokenEnd = boldEnd,
                    style = "bold",
                    innerText = boldText,
                    priority = 2,
                }
            end

            local italicStart, italicEnd, italicText = string.find(sourceText, "__([^%c]-)__", startIndex)
            if italicStart and IsPlainFormattingInnerTextValid(italicText) then
                candidates[#candidates + 1] = {
                    tokenStart = italicStart,
                    tokenEnd = italicEnd,
                    style = "italic",
                    innerText = italicText,
                    priority = 3,
                }
            end

            table.sort(candidates, function(left, right)
                if left.tokenStart == right.tokenStart then
                    return left.priority < right.priority
                end
                return left.tokenStart < right.tokenStart
            end)

            return candidates[1]
        end

        while plainSearchStart <= textLength do
            local formattingToken = FindNextFormattingToken(plainSearchStart)
            if not formattingToken then
                break
            end

            if formattingToken.tokenStart > plainSearchStart then
                segments[#segments + 1] = {
                    kind = "text",
                    style = "plain",
                    text = string.sub(sourceText, plainSearchStart, formattingToken.tokenStart - 1),
                }
            end

            segments[#segments + 1] = {
                kind = "text",
                style = formattingToken.style,
                text = formattingToken.innerText,
            }

            plainSearchStart = formattingToken.tokenEnd + 1
        end

        if plainSearchStart <= textLength then
            segments[#segments + 1] = {
                kind = "text",
                style = "plain",
                text = string.sub(sourceText, plainSearchStart),
            }
        end
    end

    while searchStart <= string.len(text) do
        local unmatchedBacktickStart = string.find(text, "`", searchStart, true)
        local inlineCodeTokenStart, inlineCodeTokenEnd, inlineCodeText = string.find(text, "`([^`\n]-)`", searchStart)
        local noteLinkTokenStart, noteLinkTokenEnd, noteLinkText, noteId = string.find(text, "%((.-)%)%[%[([^%[%]]+)%]%]", searchStart)
        local itemTokenStart, itemTokenEnd, itemId = string.find(text, "%[(%d+)%]", searchStart)
        local anchorTokenStart, anchorTokenEnd, linkText, anchorId = string.find(text, "%((.-)%)%[([a-z0-9-]+)%]", searchStart)

        local tokenStart = nil
        local tokenEnd = nil
        local tokenKind = nil
        if inlineCodeTokenStart and (not noteLinkTokenStart or inlineCodeTokenStart <= noteLinkTokenStart)
            and (not anchorTokenStart or inlineCodeTokenStart <= anchorTokenStart)
            and (not itemTokenStart or inlineCodeTokenStart <= itemTokenStart)
        then
            tokenStart = inlineCodeTokenStart
            tokenEnd = inlineCodeTokenEnd
            tokenKind = "inlineCode"
        elseif noteLinkTokenStart and (not anchorTokenStart or noteLinkTokenStart <= anchorTokenStart)
            and (not itemTokenStart or noteLinkTokenStart <= itemTokenStart)
        then
            tokenStart = noteLinkTokenStart
            tokenEnd = noteLinkTokenEnd
            tokenKind = "noteLink"
        elseif anchorTokenStart and (not itemTokenStart or anchorTokenStart <= itemTokenStart) then
            tokenStart = anchorTokenStart
            tokenEnd = anchorTokenEnd
            tokenKind = "anchorLink"
        elseif itemTokenStart then
            tokenStart = itemTokenStart
            tokenEnd = itemTokenEnd
            tokenKind = "itemToken"
        end

        if unmatchedBacktickStart and (not inlineCodeTokenStart or unmatchedBacktickStart < inlineCodeTokenStart)
            and (not tokenStart or unmatchedBacktickStart < tokenStart)
        then
            break
        end

        if not tokenStart then
            break
        end

        if tokenStart > searchStart then
            AppendPlainTextSegments(string.sub(text, searchStart, tokenStart - 1))
        end

        if tokenKind == "noteLink" then
            segments[#segments + 1] = {
                kind = "noteLink",
                style = "plain",
                text = string.sub(text, tokenStart, tokenEnd),
                linkText = noteLinkText,
                noteId = noteId,
            }
        elseif tokenKind == "inlineCode" then
            segments[#segments + 1] = {
                kind = "text",
                style = "code",
                text = inlineCodeText,
            }
        elseif tokenKind == "itemToken" then
            segments[#segments + 1] = {
                kind = "itemToken",
                style = "plain",
                text = string.sub(text, tokenStart, tokenEnd),
                itemId = itemId,
            }
        else
            segments[#segments + 1] = {
                kind = "anchorLink",
                style = "plain",
                text = string.sub(text, tokenStart, tokenEnd),
                linkText = linkText,
                anchorId = anchorId,
            }
        end

        searchStart = tokenEnd + 1
    end

    if searchStart <= string.len(text) then
        AppendPlainTextSegments(string.sub(text, searchStart))
    end

    if #segments == 0 then
        segments[1] = {
            kind = "text",
            style = "plain",
            text = text,
        }
    end

    return segments
end

local function BuildReadViewRenderPlan(bodyText)
    local lines = SplitNoteBodyIntoLines(bodyText)
    local entries = {}
    local anchorIds = {}
    local isCenteredBlock = false
    local isCodeBlock = false
    local codeBlockLines = {}

    local function FlushCodeBlock()
        if not isCodeBlock then
            return
        end

        if #codeBlockLines > 0 then
            entries[#entries + 1] = {
                lineType = "code",
                displayText = table.concat(codeBlockLines, "\n"),
                indentOffset = 0,
                isCentered = false,
            }
        end

        wipe(codeBlockLines)
        isCodeBlock = false
    end

    local function FlushMalformedCodeBlock()
        if not isCodeBlock then
            return
        end

        entries[#entries + 1] = {
            lineType = "plain",
            displayText = "```",
            indentOffset = 0,
            isCentered = false,
        }

        for _, codeLine in ipairs(codeBlockLines) do
            entries[#entries + 1] = {
                lineType = "plain",
                displayText = codeLine,
                indentOffset = 0,
                isCentered = false,
            }
        end

        wipe(codeBlockLines)
        isCodeBlock = false
    end

    for lineIndex, lineText in ipairs(lines) do
        if isCodeBlock then
            if IsReadViewCodeFence(lineText) then
                FlushCodeBlock()
            else
                codeBlockLines[#codeBlockLines + 1] = lineText
            end
        elseif IsReadViewCodeFence(lineText) then
            isCodeBlock = true
            wipe(codeBlockLines)
        elseif IsReadViewCenteredBlockStart(lineText) then
            isCenteredBlock = true
        elseif IsReadViewCenteredBlockEnd(lineText) then
            isCenteredBlock = false
        else
            local lineType, displayText, markerText = ClassifyReadViewLine(lineText)
            local anchorId = nil
            if lineType == "h1" or lineType == "h2" or lineType == "h3" then
                displayText, anchorId = ParseReadViewHeaderAnchorSuffix(displayText)
            end

            local isCentered = isCenteredBlock
            entries[#entries + 1] = {
                lineType = lineType,
                displayText = displayText,
                markerText = markerText,
                sourceLineIndex = lineIndex,
                indentOffset = (IsReadListLineType(lineType) and not isCentered) and READ_BULLET_INDENT or 0,
                isCentered = isCentered,
                anchorId = anchorId,
            }

            if anchorId and not anchorIds[anchorId] then
                anchorIds[anchorId] = true
            end
        end
    end

    if isCodeBlock then
        FlushMalformedCodeBlock()
    end

    return entries, anchorIds
end

function module:GetOrCreateNoteReadLineRow(view, index)
    view.bodyLines = view.bodyLines or {}
    local row = view.bodyLines[index]
    if row then
        return row
    end

    row = CreateFrame("Frame", nil, view.bodyContent)
    row:SetHeight(1)

    row.bullet = row:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    row.bullet:SetPoint("TOPLEFT", NOTE_TAB_FIELD_INNER_X, -NOTE_TAB_FIELD_INNER_Y)
    row.bullet:SetJustifyH("LEFT")
    row.bullet:SetJustifyV("TOP")
    row.bullet:SetText("")
    row.bullet:Hide()

    row.text = row:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    row.text:SetPoint("TOPLEFT", NOTE_TAB_FIELD_INNER_X, -NOTE_TAB_FIELD_INNER_Y)
    row.text:SetPoint("TOPRIGHT", -NOTE_TAB_FIELD_INNER_X, -NOTE_TAB_FIELD_INNER_Y)
    row.text:SetJustifyH("LEFT")
    row.text:SetJustifyV("TOP")
    row.text:SetWordWrap(true)
    if row.text.SetNonSpaceWrap then
        row.text:SetNonSpaceWrap(true)
    end
    row.text:SetText("")

    row.separator = row:CreateTexture(nil, "ARTWORK")
    row.separator:SetTexture("Interface\\Buttons\\WHITE8x8")
    row.separator:SetVertexColor(unpack(READ_SEPARATOR_COLOR))
    row.separator:Hide()

    row.codeBackground = row:CreateTexture(nil, "BACKGROUND")
    row.codeBackground:SetAllPoints()
    row.codeBackground:SetTexture("Interface\\Buttons\\WHITE8x8")
    row.codeBackground:SetVertexColor(unpack(READ_CODE_BACKGROUND_COLOR))
    row.codeBackground:Hide()

    row.atlasTexture = row:CreateTexture(nil, "ARTWORK")
    row.atlasTexture:Hide()

    row.measure = row:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    row.measure:Hide()

    row.taskToggleButton = CreateFrame("Button", nil, row)
    row.taskToggleButton:SetFrameStrata(row:GetFrameStrata())
    row.taskToggleButton:SetFrameLevel((row:GetFrameLevel() or 1) + 12)
    row.taskToggleButton:RegisterForClicks("LeftButtonUp")
    row.taskToggleButton:Hide()
    row.taskToggleButton:SetScript("OnClick", function(buttonFrame)
        local targetTab = buttonFrame.targetTab
        local sourceLineIndex = buttonFrame.sourceLineIndex
        if not targetTab or not sourceLineIndex then
            return
        end

        module:ToggleTaskLineAtIndex(targetTab, sourceLineIndex)
    end)

    row.segmentBackgrounds = {}
    row.segmentTexts = {}
    row.hoverRegions = {}

    view.bodyLines[index] = row
    return row
end

function module:GetOrCreateReadSegmentBackground(row, index)
    row.segmentBackgrounds = row.segmentBackgrounds or {}
    local background = row.segmentBackgrounds[index]
    if background then
        return background
    end

    background = row:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Buttons\\WHITE8x8")
    background:SetVertexColor(unpack(READ_INLINE_CODE_BACKGROUND_COLOR))
    background:Hide()

    row.segmentBackgrounds[index] = background
    return background
end

function module:HideReadSegmentBackgrounds(row)
    if not row or not row.segmentBackgrounds then
        return
    end

    for _, background in ipairs(row.segmentBackgrounds) do
        background:Hide()
    end
end

function module:GetOrCreateReadSegmentText(row, index)
    row.segmentTexts = row.segmentTexts or {}
    local segmentText = row.segmentTexts[index]
    if segmentText then
        return segmentText
    end

    segmentText = row:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    segmentText:SetJustifyH("LEFT")
    segmentText:SetJustifyV("TOP")
    segmentText:SetWordWrap(false)
    if segmentText.SetNonSpaceWrap then
        segmentText:SetNonSpaceWrap(false)
    end
    segmentText:Hide()

    row.segmentTexts[index] = segmentText
    return segmentText
end

function module:HideReadSegmentTexts(row)
    if not row or not row.segmentTexts then
        return
    end

    for _, segmentText in ipairs(row.segmentTexts) do
        segmentText:SetText("")
        segmentText:Hide()
    end
end

function module:HideReadTaskToggleButton(row)
    if not row or not row.taskToggleButton then
        return
    end

    row.taskToggleButton.targetTab = nil
    row.taskToggleButton.sourceLineIndex = nil
    row.taskToggleButton:Hide()
end

function module:RefreshReadTaskToggleButton(row)
    if not row or not row.taskToggleButton then
        return
    end

    self:HideReadTaskToggleButton(row)

    if row.lineType ~= "taskUnchecked" and row.lineType ~= "taskChecked" then
        return
    end

    local readView = row.readView
    local targetTab = readView and readView.ownerTab or nil
    local sourceLineIndex = row.sourceLineIndex
    if not targetTab or not sourceLineIndex then
        return
    end

    local toggleButton = row.taskToggleButton
    toggleButton.targetTab = targetTab
    toggleButton.sourceLineIndex = sourceLineIndex
    toggleButton:ClearAllPoints()

    if row.bullet and row.bullet:IsShown() then
        toggleButton:SetPoint("TOPLEFT", row.bullet, "TOPLEFT", 0, 0)
        toggleButton:SetSize(
            math.max(row.bullet:GetStringWidth() or 0, 1),
            math.max(row.bullet:GetStringHeight() or 0, READ_LINE_FONT_SIZE)
        )
        toggleButton:Show()
        return
    end

    local markerWidget = row.segmentTexts and row.segmentTexts[1] or nil
    if markerWidget and markerWidget:IsShown() then
        toggleButton:SetPoint("TOPLEFT", markerWidget, "TOPLEFT", 0, 0)
        toggleButton:SetSize(
            math.max(markerWidget:GetStringWidth() or 0, 1),
            math.max(markerWidget:GetStringHeight() or 0, READ_LINE_FONT_SIZE)
        )
        toggleButton:Show()
    end
end

function module:GetReadViewLineSpacing(previousLineType, currentLineType)
    if previousLineType == "h1" or previousLineType == "h2" or previousLineType == "h3" then
        return READ_HEADER_VERTICAL_SPACING
    end

    if previousLineType == "separator" or currentLineType == "separator" then
        return 6
    end

    if IsReadListLineType(previousLineType) and not IsReadListLineType(currentLineType) then
        return READ_POST_BULLET_BLOCK_SPACING
    end

    if (previousLineType == "plain" or previousLineType == "bold" or previousLineType == "italic")
        and (currentLineType == "plain" or currentLineType == "bold" or currentLineType == "italic")
    then
        return READ_LINE_VERTICAL_SPACING
    end

    return 0
end

function module:ResolveReadViewItemTokenText(itemId, fallbackText)
    local numericItemId = tonumber(itemId)
    local fallback = tostring(fallbackText or "")
    if not numericItemId then
        return fallback, false, nil
    end

    local itemName, itemLink = GetItemInfo(numericItemId)
    if itemName and itemLink and itemLink ~= "" then
        return itemLink, true, itemLink
    end

    if C_Item and C_Item.RequestLoadItemDataByID then
        C_Item.RequestLoadItemDataByID(numericItemId)
    end

    return fallback, false, nil
end

function module:ShouldListenForReadItemInfoUpdates()
    if not self.runtime then
        return false
    end

    if self.runtime.noteSlots then
        for _, tab in ipairs(self.runtime.noteSlots) do
            if tab and tab.assigned and not self:IsNoteTabInEditMode(tab) and tab.hasPendingReadItemInfo then
                return true
            end
        end
    end

    local previewWindow = self.runtime.previewWindow
    local previewView = previewWindow and previewWindow.readView or nil
    if previewWindow and previewWindow:IsShown() and previewView and previewView.hasPendingReadItemInfo then
        return true
    end

    return false
end

function module:UpdateReadItemInfoEventRegistration()
    local shouldListen = self:ShouldListenForReadItemInfoUpdates()
    if shouldListen then
        if not self.runtime.isListeningForReadItemInfo then
            self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
            self:RegisterEvent("ITEM_DATA_LOAD_RESULT")
            self.runtime.isListeningForReadItemInfo = true
        end
    elseif self.runtime and self.runtime.isListeningForReadItemInfo then
        self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
        self:UnregisterEvent("ITEM_DATA_LOAD_RESULT")
        self.runtime.isListeningForReadItemInfo = false
    end
end

function module:TrackPendingReadItemId(pendingItemIds, itemId)
    local numericItemId = tonumber(itemId)
    if not pendingItemIds or not numericItemId then
        return
    end

    pendingItemIds[numericItemId] = true
end

function module:GetReadViewDefaultFont()
    local _, _, fontFlags = ChatFontNormal:GetFont()
    return FONT_REGULAR or STANDARD_TEXT_FONT, fontFlags or ""
end

function module:GetReadViewFontPath(lineType, fallbackFontPath)
    if lineType == "h1italic" or lineType == "h2italic" or lineType == "h3italic" then
        return FONT_BOLDITALIC or FONT_BOLD or FONT_REGULAR or fallbackFontPath
    end

    if lineType == "h1" or lineType == "h2" or lineType == "h3" then
        return FONT_BOLD or FONT_REGULAR or fallbackFontPath
    end

    if lineType == "bold" then
        return FONT_BOLD or FONT_REGULAR or fallbackFontPath
    end

    if lineType == "bolditalic" then
        return FONT_BOLDITALIC or FONT_BOLD or FONT_REGULAR or fallbackFontPath
    end

    if lineType == "italic" then
        return FONT_ITALIC or FONT_REGULAR or fallbackFontPath
    end

    return FONT_REGULAR or fallbackFontPath
end

function module:GetReadViewInlineSegmentFontPath(lineType, segmentStyle, fallbackFontPath)
    if lineType == "h1" or lineType == "h2" or lineType == "h3" then
        if segmentStyle == "italic" or segmentStyle == "bolditalic" then
            return FONT_BOLDITALIC or FONT_BOLD or FONT_REGULAR or fallbackFontPath
        end

        return FONT_BOLD or FONT_REGULAR or fallbackFontPath
    end

    if segmentStyle == "bolditalic" then
        return FONT_BOLDITALIC or FONT_BOLD or FONT_REGULAR or fallbackFontPath
    end

    if segmentStyle == "bold" then
        return FONT_BOLD or FONT_REGULAR or fallbackFontPath
    end

    if segmentStyle == "italic" then
        return FONT_ITALIC or FONT_REGULAR or fallbackFontPath
    end

    if segmentStyle == "code" then
        return FONT_REGULAR or fallbackFontPath
    end

    return FONT_REGULAR or fallbackFontPath
end

function module:ApplyReadViewFont(target, preferredFontPath, fallbackFontPath, fontSize, fontFlags)
    if not target or not target.SetFont then
        return
    end

    local didApplyPreferred = preferredFontPath and target:SetFont(preferredFontPath, fontSize, fontFlags)
    if didApplyPreferred then
        return
    end

    target:SetFont(fallbackFontPath or STANDARD_TEXT_FONT, fontSize, fontFlags)
end

function module:GetReadViewRowAvailableWidth(row)
    if not row then
        return 1
    end

    local width = row:GetWidth() or 0
    if width <= 1 and row.GetParent then
        local parent = row:GetParent()
        width = parent and parent:GetWidth() or 0
    end

    return math.max(width - (NOTE_TAB_FIELD_INNER_X * 2), 1)
end

function module:TryApplyReadViewAtlas(row, atlasData)
    if not row or not row.atlasTexture or not atlasData or not atlasData.atlasName or atlasData.atlasName == "" then
        return false
    end

    if C_Texture and C_Texture.GetAtlasElementID and not C_Texture.GetAtlasElementID(atlasData.atlasName) then
        return false
    end

    row.atlasTexture:ClearAllPoints()

    local didSetAtlas
    local intendedWidth
    local intendedHeight
    if atlasData.width and atlasData.height then
        didSetAtlas = pcall(row.atlasTexture.SetAtlas, row.atlasTexture, atlasData.atlasName)
        if not didSetAtlas then
            row.atlasTexture:SetTexture(nil)
            row.atlasTexture:Hide()
            return false
        end
        intendedWidth = atlasData.width
        intendedHeight = atlasData.height
    else
        didSetAtlas = pcall(row.atlasTexture.SetAtlas, row.atlasTexture, atlasData.atlasName, true)
        if not didSetAtlas then
            row.atlasTexture:SetTexture(nil)
            row.atlasTexture:Hide()
            return false
        end

        intendedWidth, intendedHeight = row.atlasTexture:GetSize()
    end

    if not intendedWidth or intendedWidth <= 0 or not intendedHeight or intendedHeight <= 0 then
        row.atlasTexture:SetTexture(nil)
        row.atlasTexture:Hide()
        return false
    end

    local maxWidth = self:GetReadViewRowAvailableWidth(row)
    local scale = 1
    if intendedWidth > maxWidth then
        scale = maxWidth / intendedWidth
    end

    local atlasWidth = math.max(math.floor((intendedWidth * scale) + 0.5), 1)
    local atlasHeight = math.max(math.floor((intendedHeight * scale) + 0.5), 1)
    row.atlasTexture:SetSize(atlasWidth, atlasHeight)

    if row.isCentered then
        row.atlasTexture:SetPoint("TOP", row, "TOP", 0, -NOTE_TAB_FIELD_INNER_Y)
    else
        row.atlasTexture:SetPoint("TOPLEFT", row, "TOPLEFT", NOTE_TAB_FIELD_INNER_X, -NOTE_TAB_FIELD_INNER_Y)
    end

    row.atlasWidth = atlasWidth
    row.atlasHeight = atlasHeight
    row.atlasData = atlasData
    row.atlasTexture:Show()
    return true
end

function module:GetOrCreateReadInteractiveRegion(row, index)
    row.hoverRegions = row.hoverRegions or {}
    local region = row.hoverRegions[index]
    if region then
        return region
    end

    region = CreateFrame("Button", nil, row)
    region:SetFrameStrata(row:GetFrameStrata())
    region:SetFrameLevel((row:GetFrameLevel() or 1) + 10)
    region:RegisterForClicks("AnyUp")
    region:EnableMouse(true)
    region:Hide()
    region:SetScript("OnEnter", function(selfRegion)
        local segmentData = selfRegion.segmentData
        if not segmentData then
            return
        end

        if segmentData.kind == "anchorLink" then
            if not segmentData.isResolved then
                return
            end

            GameTooltip:SetOwner(selfRegion, "ANCHOR_RIGHT")
            GameTooltip:SetText(segmentData.linkText or segmentData.text or "", 0.45, 0.82, 1.0)
            GameTooltip:AddLine("Jump to section", 0.92, 0.88, 0.80, true)
            GameTooltip:Show()
            return
        end

        if segmentData.kind == "noteLink" then
            if not segmentData.isResolved then
                return
            end

            local targetNote = segmentData.targetNote
            GameTooltip:SetOwner(selfRegion, "ANCHOR_RIGHT")
            GameTooltip:SetText(segmentData.linkText or segmentData.text or "", 0.45, 0.82, 1.0)
            if targetNote and targetNote.title and targetNote.title ~= "" then
                GameTooltip:AddLine(targetNote.title, 0.92, 0.88, 0.80, true)
            end
            GameTooltip:AddLine("Open note", 0.92, 0.88, 0.80, true)
            GameTooltip:Show()
            return
        end

        GameTooltip:SetOwner(selfRegion, "ANCHOR_RIGHT")
        if segmentData.isResolved and segmentData.itemLink then
            GameTooltip:SetHyperlink(segmentData.itemLink)
        else
            GameTooltip:SetText(segmentData.text or "", 1, 0.82, 0)
            GameTooltip:AddLine("Item invalid or not cached", 0.92, 0.88, 0.80, true)
        end
        GameTooltip:Show()
    end)
    region:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    region:SetScript("OnClick", function(selfRegion, button)
        local segmentData = selfRegion.segmentData
        if not segmentData or not segmentData.isResolved then
            return
        end

        if segmentData.kind == "anchorLink" then
            local readView = segmentData.readView
            local anchorId = segmentData.anchorId
            if readView and anchorId then
                module:JumpToReadViewAnchor(readView, anchorId)
            end
            return
        end

        if segmentData.kind == "noteLink" then
            local noteId = segmentData.noteId
            if noteId then
                module:OpenNote(noteId, false)
            end
            return
        end

        local itemLink = segmentData.itemLink or nil
        if not itemLink or itemLink == "" then
            return
        end

        if HandleModifiedItemClick and HandleModifiedItemClick(itemLink) then
            return
        end

        if SetItemRef then
            SetItemRef(itemLink, itemLink, button or "LeftButton", selfRegion)
        end
    end)

    row.hoverRegions[index] = region
    return region
end

function module:HideReadInteractiveRegions(row)
    if not row or not row.hoverRegions then
        return
    end

    for _, region in ipairs(row.hoverRegions) do
        region.segmentData = nil
        region:Hide()
    end
end

function module:RefreshReadInteractiveRegions(row, resolvedFontPath, fallbackFontPath, fontSize, fontFlags)
    if not row or not row.text or not row.measure then
        return
    end

    self:HideReadInteractiveRegions(row)

    local segments = row.inlineSegments
    if not segments or #segments == 0 then
        return
    end

    self:ApplyReadViewFont(row.measure, resolvedFontPath, fallbackFontPath, fontSize, fontFlags)
    row.measure:SetSpacing(row.text.GetSpacing and row.text:GetSpacing() or 0)

    local lineHeight = select(2, row.measure:GetFont())
    local textHeight = row.text:GetStringHeight() or 0
    if not lineHeight or lineHeight <= 0 or textHeight > (lineHeight * 1.5) then
        return
    end

    local fullDisplayText = ""
    for _, segmentData in ipairs(segments) do
        fullDisplayText = fullDisplayText .. (segmentData.displayText or segmentData.text or "")
    end

    local centeredOffset = 0
    if row.isCentered and fullDisplayText ~= "" then
        row.measure:SetText(fullDisplayText)
        local centeredTextWidth = row.measure:GetStringWidth() or 0
        local textRegionWidth = row.text:GetWidth() or 0
        if centeredTextWidth > 0 and textRegionWidth > centeredTextWidth then
            centeredOffset = math.max(math.floor(((textRegionWidth - centeredTextWidth) / 2) + 0.5), 0)
        end
    end

    local prefixText = ""
    local hoverIndex = 0
    for _, segmentData in ipairs(segments) do
        local displayText = segmentData.displayText or segmentData.text or ""
        if (segmentData.kind == "itemToken" or segmentData.kind == "anchorLink" or segmentData.kind == "noteLink")
            and segmentData.isResolved
            and displayText ~= ""
        then
            row.measure:SetText(prefixText)
            local prefixWidth = row.measure:GetStringWidth() or 0

            row.measure:SetText(displayText)
            local segmentWidth = row.measure:GetStringWidth() or 0

            if segmentWidth > 0 then
                hoverIndex = hoverIndex + 1
                local region = self:GetOrCreateReadInteractiveRegion(row, hoverIndex)
                region.segmentData = segmentData
                region:ClearAllPoints()
                region:SetPoint("TOPLEFT", row.text, "TOPLEFT", centeredOffset + prefixWidth, 0)
                region:SetSize(segmentWidth, math.max(textHeight, lineHeight))
                region:Show()
            end
        end

        prefixText = prefixText .. displayText
    end
end

local function HasStyledReadSegments(segments)
    for _, segmentData in ipairs(segments or {}) do
        if segmentData.kind == "text" and segmentData.style and segmentData.style ~= "plain" then
            return true
        end
    end

    return false
end

local function SplitReadSegmentIntoUnits(segmentData)
    local units = {}
    local displayText = tostring(segmentData and (segmentData.displayText or segmentData.text) or "")
    if displayText == "" then
        return units
    end

    if segmentData and segmentData.kind == "itemToken" then
        units[1] = {
            text = displayText,
            segmentData = segmentData,
        }
        return units
    end

    if segmentData and segmentData.style == "code" then
        units[1] = {
            text = displayText,
            segmentData = segmentData,
        }
        return units
    end

    local cursor = 1
    local textLength = string.len(displayText)
    while cursor <= textLength do
        local spaceStart, spaceEnd = string.find(displayText, "^%s+", cursor)
        if spaceStart then
            units[#units + 1] = {
                text = string.sub(displayText, spaceStart, spaceEnd),
                segmentData = segmentData,
            }
            cursor = spaceEnd + 1
        else
            local wordStart, wordEnd = string.find(displayText, "^[^%s]+", cursor)
            if not wordStart then
                break
            end

            units[#units + 1] = {
                text = string.sub(displayText, wordStart, wordEnd),
                segmentData = segmentData,
            }
            cursor = wordEnd + 1
        end
    end

    return units
end

function module:MeasureReadLayoutUnit(row, unitText, fontPath, fallbackFontPath, fontSize, fontFlags)
    self:ApplyReadViewFont(row.measure, fontPath, fallbackFontPath, fontSize, fontFlags)
    row.measure:SetText(unitText or "")
    local unitWidth = row.measure:GetStringWidth() or 0
    local unitHeight = row.measure:GetStringHeight() or fontSize or READ_LINE_FONT_SIZE
    return unitWidth, unitHeight
end

function module:ResolveReadListMarkerText(markerWidget, lineType, markerText)
    if lineType ~= "taskUnchecked" and lineType ~= "taskChecked" then
        return markerText
    end

    return markerText or GetReadTaskMarkerGlyph(lineType)
end

function module:RenderStyledReadSegments(row, lineType, segments, markerText, fallbackFontPath, fontSize, fontFlags)
    self:HideReadInteractiveRegions(row)
    self:HideReadSegmentBackgrounds(row)
    self:HideReadSegmentTexts(row)
    self:HideReadTaskToggleButton(row)

    row.text:SetText("")
    row.text:Hide()

    local markerGap = 6
    local hasLeadingMarker = IsReadListLineType(lineType) and row.bullet and row.bullet:IsShown() and not row.isCentered
    local contentLeft = NOTE_TAB_FIELD_INNER_X
    if hasLeadingMarker then
        contentLeft = contentLeft + (row.bullet:GetStringWidth() or 0) + markerGap
    end

    local availableWidth = math.max((row:GetWidth() or 0) - contentLeft - NOTE_TAB_FIELD_INNER_X, 1)
    local layoutUnits = {}

    for _, segmentData in ipairs(segments or {}) do
        local segmentUnits = SplitReadSegmentIntoUnits(segmentData)
        for _, unitData in ipairs(segmentUnits) do
            layoutUnits[#layoutUnits + 1] = unitData
        end
    end

    local lines = {}
    local currentLine = {
        width = 0,
        height = 0,
        chunks = {},
    }
    lines[1] = currentLine

    local function StartNewLine()
        currentLine = {
            width = 0,
            height = 0,
            chunks = {},
        }
        lines[#lines + 1] = currentLine
    end

    for _, unitData in ipairs(layoutUnits) do
        local segmentData = unitData.segmentData or {}
        local unitText = unitData.text or ""
        local unitIsWhitespace = string.match(unitText, "^%s+$") ~= nil
        local unitFontPath = self:GetReadViewInlineSegmentFontPath(lineType, segmentData.style or "plain", fallbackFontPath)
        local unitWidth, unitHeight = self:MeasureReadLayoutUnit(row, unitText, unitFontPath, fallbackFontPath, fontSize, fontFlags)

        if not unitIsWhitespace and #currentLine.chunks > 0 and (currentLine.width + unitWidth) > availableWidth then
            StartNewLine()
        end

        if unitIsWhitespace and #currentLine.chunks == 0 then
            unitWidth = 0
        end

        currentLine.chunks[#currentLine.chunks + 1] = {
            text = unitText,
            width = unitWidth,
            height = unitHeight,
            fontPath = unitFontPath,
            segmentData = segmentData,
            x = currentLine.width,
        }
        currentLine.width = currentLine.width + unitWidth
        currentLine.height = math.max(currentLine.height, unitHeight)
    end

    local textIndex = 0
    local hoverIndex = 0
    local yOffset = NOTE_TAB_FIELD_INNER_Y

    for _, lineData in ipairs(lines) do
        local centeredOffset = 0
        if row.isCentered and lineData.width < availableWidth then
            centeredOffset = math.max(math.floor(((availableWidth - lineData.width) / 2) + 0.5), 0)
        end

        local previousAnchorRegion = nil
        for _, chunkData in ipairs(lineData.chunks) do
            if chunkData.text ~= "" and chunkData.width > 0 then
                textIndex = textIndex + 1
                local textWidget = self:GetOrCreateReadSegmentText(row, textIndex)
                textWidget:ClearAllPoints()
                self:ApplyReadViewFont(textWidget, chunkData.fontPath, fallbackFontPath, fontSize, fontFlags)
                textWidget:SetTextColor(unpack(chunkData.segmentData.textColor or { 1, 1, 1 }))
                textWidget:SetShadowOffset(0, 0)
                textWidget:SetShadowColor(0, 0, 0, 0)
                if lineType == "h1" or lineType == "h2" then
                    textWidget:SetShadowOffset(3, -3)
                    textWidget:SetShadowColor(0, 0, 0, 0.60)
                end
                textWidget:SetText(chunkData.text)

                if previousAnchorRegion then
                    textWidget:SetPoint("TOPLEFT", previousAnchorRegion, "TOPRIGHT", 0, 0)
                else
                    textWidget:SetPoint("TOPLEFT", row, "TOPLEFT", contentLeft + centeredOffset, -yOffset)
                end

                textWidget:Show()

                local actualChunkWidth = textWidget:GetStringWidth() or chunkData.width
                local actualChunkHeight = textWidget:GetStringHeight() or chunkData.height
                local hoverAnchorRegion = textWidget

                if chunkData.segmentData.style == "code" then
                    local background = self:GetOrCreateReadSegmentBackground(row, textIndex)
                    background:ClearAllPoints()
                    background:SetPoint("TOPLEFT", textWidget, "TOPLEFT", -READ_INLINE_CODE_PADDING_X, READ_INLINE_CODE_PADDING_Y)
                    background:SetPoint("BOTTOMRIGHT", textWidget, "BOTTOMRIGHT", READ_INLINE_CODE_PADDING_X, -READ_INLINE_CODE_PADDING_Y)
                    background:Show()
                    hoverAnchorRegion = background
                    actualChunkWidth = actualChunkWidth + (READ_INLINE_CODE_PADDING_X * 2)
                    actualChunkHeight = math.max(actualChunkHeight + (READ_INLINE_CODE_PADDING_Y * 2), actualChunkHeight)
                end

                if (chunkData.segmentData.kind == "itemToken" or chunkData.segmentData.kind == "anchorLink" or chunkData.segmentData.kind == "noteLink")
                    and chunkData.segmentData.isResolved
                then
                    hoverIndex = hoverIndex + 1
                    local region = self:GetOrCreateReadInteractiveRegion(row, hoverIndex)
                    region.segmentData = chunkData.segmentData
                    region:ClearAllPoints()
                    region:SetPoint("TOPLEFT", hoverAnchorRegion, "TOPLEFT", 0, 0)
                    region:SetSize(actualChunkWidth, math.max(lineData.height, actualChunkHeight))
                    region:Show()
                end

                previousAnchorRegion = hoverAnchorRegion
            end
        end

        yOffset = yOffset + math.max(lineData.height, fontSize)
    end

    row.contentHeight = math.max(yOffset + NOTE_TAB_FIELD_INNER_Y, fontSize + (NOTE_TAB_FIELD_INNER_Y * 2), 1)
    self:RefreshReadTaskToggleButton(row)
end

function module:ApplyReadViewLineStyle(row, lineType, displayText, pendingItemIds, anchorIds, readView, markerText)
    if not row or not row.text or not row.bullet then
        return false
    end

    local fallbackFontPath, fontFlags = self:GetReadViewDefaultFont()
    local resolvedFontPath = self:GetReadViewFontPath(lineType, fallbackFontPath)
    local fontSize = READ_LINE_FONT_SIZE
    local isCenteredList = IsReadListLineType(lineType) and row.isCentered

    row.bullet:Hide()
    row.bullet:SetText("")
    row.bullet:SetTextColor(1, 1, 1)
    if row.separator then
        row.separator:Hide()
    end
    if row.codeBackground then
        row.codeBackground:Hide()
    end
    if row.atlasTexture then
        row.atlasTexture:Hide()
    end
    row.renderedLineType = nil
    row.atlasWidth = nil
    row.atlasHeight = nil
    row.atlasData = nil
    row.contentHeight = nil
    row.usesStyledSegments = nil
    row.markerText = markerText
    row.readView = readView
    row.text:Show()
    row.text:SetSpacing(0)
    self:HideReadSegmentBackgrounds(row)
    self:HideReadSegmentTexts(row)
    self:HideReadTaskToggleButton(row)

    if lineType == "h1" then
        fontSize = READ_HEADER1_FONT_SIZE
    elseif lineType == "h2" then
        fontSize = READ_HEADER2_FONT_SIZE
    elseif lineType == "h3" then
        fontSize = READ_HEADER3_FONT_SIZE
    elseif lineType == "bold" then
        fontSize = READ_LINE_FONT_SIZE
    elseif lineType == "bolditalic" then
        fontSize = READ_LINE_FONT_SIZE
    elseif lineType == "italic" then
        fontSize = READ_LINE_FONT_SIZE
    elseif IsReadListLineType(lineType) then
        if not isCenteredList then
            self:ApplyReadViewFont(row.bullet, fallbackFontPath, fallbackFontPath, READ_LINE_FONT_SIZE, fontFlags)
            markerText = self:ResolveReadListMarkerText(row.bullet, lineType, markerText or "•")
            row.markerText = markerText
            row.bullet:SetText(markerText or "•")
            if lineType == "taskChecked" then
                row.bullet:SetTextColor(unpack(READ_TASK_CHECKED_MARKER_COLOR))
            elseif lineType == "taskUnchecked" then
                row.bullet:SetTextColor(unpack(READ_TASK_UNCHECKED_MARKER_COLOR))
            end
            row.bullet:Show()
        end
    elseif lineType == "separator" then
        fontSize = READ_LINE_FONT_SIZE
    elseif lineType == "blank" then
        fontSize = READ_LINE_FONT_SIZE
    end

    row.text:ClearAllPoints()
    if IsReadListLineType(lineType) and not isCenteredList then
        row.text:SetPoint("TOPLEFT", row.bullet, "TOPRIGHT", 6, 0)
        row.text:SetPoint("TOPRIGHT", row, "TOPRIGHT", -NOTE_TAB_FIELD_INNER_X, -NOTE_TAB_FIELD_INNER_Y)
        row.text:SetJustifyH("LEFT")
    else
        row.text:SetPoint("TOPLEFT", row, "TOPLEFT", NOTE_TAB_FIELD_INNER_X, -NOTE_TAB_FIELD_INNER_Y)
        row.text:SetPoint("TOPRIGHT", row, "TOPRIGHT", -NOTE_TAB_FIELD_INNER_X, -NOTE_TAB_FIELD_INNER_Y)
        row.text:SetJustifyH(row.isCentered and "CENTER" or "LEFT")
    end
    self:ApplyReadViewFont(row.text, resolvedFontPath, fallbackFontPath, fontSize, fontFlags)
    if lineType == "taskChecked" then
        row.text:SetTextColor(unpack(READ_TASK_CHECKED_TEXT_COLOR))
    else
        row.text:SetTextColor(1, 1, 1)
    end
    row.text:SetShadowOffset(0, 0)
    row.text:SetShadowColor(0, 0, 0, 0)

    if lineType == "h1" or lineType == "h2" then
        row.text:SetShadowOffset(3, -3)
        row.text:SetShadowColor(0, 0, 0, 0.60)
    end

    if lineType == "separator" then
        row.renderedLineType = "separator"
        row.text:SetText("")
        row.inlineSegments = nil
        self:HideReadSegmentTexts(row)
        self:HideReadInteractiveRegions(row)
        self:HideReadTaskToggleButton(row)
        if row.separator then
            row.separator:ClearAllPoints()
            row.separator:SetPoint("LEFT", row, "LEFT", NOTE_TAB_FIELD_INNER_X + READ_SEPARATOR_SIDE_INSET, 0)
            row.separator:SetPoint("RIGHT", row, "RIGHT", -(NOTE_TAB_FIELD_INNER_X + READ_SEPARATOR_SIDE_INSET), 0)
            row.separator:SetHeight(READ_SEPARATOR_THICKNESS)
            row.separator:Show()
        end
        return false
    end

    if lineType == "code" then
        row.renderedLineType = "code"
        row.inlineSegments = nil
        row.text:SetSpacing(READ_CODE_LINE_SPACING)
        self:HideReadSegmentTexts(row)
        self:HideReadInteractiveRegions(row)
        self:HideReadTaskToggleButton(row)
        if row.codeBackground then
            row.codeBackground:Show()
        end
        row.text:ClearAllPoints()
        row.text:SetPoint("TOPLEFT", row, "TOPLEFT", NOTE_TAB_FIELD_INNER_X + READ_CODE_BLOCK_PADDING_X, -(NOTE_TAB_FIELD_INNER_Y + READ_CODE_BLOCK_PADDING_Y))
        row.text:SetPoint("TOPRIGHT", row, "TOPRIGHT", -(NOTE_TAB_FIELD_INNER_X + READ_CODE_BLOCK_PADDING_X), -(NOTE_TAB_FIELD_INNER_Y + READ_CODE_BLOCK_PADDING_Y))
        row.text:SetJustifyH("LEFT")
        row.text:SetTextColor(unpack(READ_CODE_TEXT_COLOR))
        row.text:SetText(tostring(displayText or ""))
        return false
    end

    if lineType == "atlas" then
        row.text:SetText("")
        row.inlineSegments = nil
        self:HideReadSegmentTexts(row)
        self:HideReadInteractiveRegions(row)
        self:HideReadTaskToggleButton(row)
        if self:TryApplyReadViewAtlas(row, displayText) then
            row.renderedLineType = "atlas"
            return false
        end

        lineType = "plain"
        displayText = displayText and displayText.rawText or ""
    end

    local segments = ParseReadViewInlineSegments(displayText or "")
    if isCenteredList and markerText and markerText ~= "" then
        markerText = self:ResolveReadListMarkerText(nil, lineType, markerText)
        row.markerText = markerText
        table.insert(segments, 1, {
            kind = "text",
            style = "plain",
            text = markerText .. " ",
            displayText = markerText .. " ",
            textColor = lineType == "taskChecked" and READ_TASK_CHECKED_MARKER_COLOR
                or (lineType == "taskUnchecked" and READ_TASK_UNCHECKED_MARKER_COLOR or nil),
        })
    end
    local formattedSegments = {}
    local hasUnresolvedItemTokens = false

    for _, segmentData in ipairs(segments) do
        if segmentData.kind == "noteLink" then
            local targetNote = segmentData.noteId and self:GetNoteById(segmentData.noteId) or nil
            local isResolved = targetNote ~= nil
            segmentData.isResolved = isResolved
            segmentData.targetNote = targetNote
            if isResolved then
                segmentData.displayText = segmentData.linkText or ""
                segmentData.textColor = READ_SAME_NOTE_LINK_COLOR
                formattedSegments[#formattedSegments + 1] = string.format(
                    "%s%s|r",
                    GetColorCode(READ_SAME_NOTE_LINK_COLOR),
                    segmentData.displayText or ""
                )
            else
                segmentData.displayText = segmentData.text or ""
                segmentData.textColor = READ_UNRESOLVED_ITEM_TOKEN_COLOR
                formattedSegments[#formattedSegments + 1] = string.format(
                    "%s%s|r",
                    GetColorCode(READ_UNRESOLVED_ITEM_TOKEN_COLOR),
                    segmentData.displayText or ""
                )
            end
        elseif segmentData.kind == "itemToken" then
            local resolvedText, isResolved, itemLink = self:ResolveReadViewItemTokenText(segmentData.itemId, segmentData.text)
            segmentData.displayText = resolvedText
            segmentData.isResolved = isResolved
            segmentData.itemLink = itemLink
             segmentData.textColor = isResolved and nil or READ_UNRESOLVED_ITEM_TOKEN_COLOR
            if isResolved then
                formattedSegments[#formattedSegments + 1] = resolvedText
            else
                hasUnresolvedItemTokens = true
                self:TrackPendingReadItemId(pendingItemIds, segmentData.itemId)
                formattedSegments[#formattedSegments + 1] = string.format(
                    "|cff%02x%02x%02x%s|r",
                    math.floor((READ_UNRESOLVED_ITEM_TOKEN_COLOR[1] or 1) * 255),
                    math.floor((READ_UNRESOLVED_ITEM_TOKEN_COLOR[2] or 1) * 255),
                    math.floor((READ_UNRESOLVED_ITEM_TOKEN_COLOR[3] or 1) * 255),
                    resolvedText or ""
                )
            end
        elseif segmentData.kind == "anchorLink" then
            local isResolved = anchorIds and anchorIds[segmentData.anchorId] and true or false
            segmentData.isResolved = isResolved
            segmentData.readView = readView
            if isResolved then
                segmentData.displayText = segmentData.linkText or ""
                segmentData.textColor = READ_SAME_NOTE_LINK_COLOR
                formattedSegments[#formattedSegments + 1] = string.format(
                    "%s%s|r",
                    GetColorCode(READ_SAME_NOTE_LINK_COLOR),
                    segmentData.displayText or ""
                )
            else
                segmentData.displayText = segmentData.text or ""
                segmentData.textColor = READ_UNRESOLVED_ITEM_TOKEN_COLOR
                formattedSegments[#formattedSegments + 1] = string.format(
                    "%s%s|r",
                    GetColorCode(READ_UNRESOLVED_ITEM_TOKEN_COLOR),
                    segmentData.displayText or ""
                )
            end
        else
            segmentData.displayText = segmentData.text or ""
            if segmentData.style == "code" then
                segmentData.textColor = READ_INLINE_CODE_TEXT_COLOR
            elseif lineType == "taskChecked" then
                segmentData.textColor = READ_TASK_CHECKED_TEXT_COLOR
            else
                segmentData.textColor = nil
            end
            formattedSegments[#formattedSegments + 1] = segmentData.text or ""
        end
    end

    row.inlineSegments = segments
    row.renderedLineType = lineType
    if HasStyledReadSegments(segments) or (isCenteredList and (lineType == "taskUnchecked" or lineType == "taskChecked")) then
        row.usesStyledSegments = true
        self:RenderStyledReadSegments(row, lineType, segments, markerText, fallbackFontPath, fontSize, fontFlags)
    else
        row.usesStyledSegments = false
        row.text:SetText(table.concat(formattedSegments))
        self:RefreshReadInteractiveRegions(row, resolvedFontPath, fallbackFontPath, fontSize, fontFlags)
        self:RefreshReadTaskToggleButton(row)
    end
    return hasUnresolvedItemTokens
end

function module:RefreshReadAnchorTargets(view)
    if not view or not view.bodyLines then
        return
    end

    view.anchorTargets = view.anchorTargets or {}
    wipe(view.anchorTargets)

    for _, row in ipairs(view.bodyLines) do
        if row:IsShown() and row.anchorId and not view.anchorTargets[row.anchorId] then
            view.anchorTargets[row.anchorId] = row
        end

        if row.inlineSegments then
            for _, segmentData in ipairs(row.inlineSegments) do
                if segmentData.kind == "anchorLink" then
                    segmentData.readView = view
                    segmentData.anchorTarget = view.anchorTargets[segmentData.anchorId]
                end
            end
        end
    end
end

function module:JumpToReadViewAnchor(view, anchorId)
    if not view or not view.bodyScrollFrame or not view.anchorTargets or not anchorId then
        return false
    end

    local targetRow = view.anchorTargets[anchorId]
    if not targetRow or not targetRow:IsShown() then
        return false
    end

    local contentTop = view.bodyContent and view.bodyContent:GetTop() or nil
    local rowTop = targetRow:GetTop()
    if not contentTop or not rowTop then
        return false
    end

    local targetScroll = math.max(contentTop - rowTop, 0)
    local maxScroll = math.max(view.bodyScrollFrame.GetVerticalScrollRange and (view.bodyScrollFrame:GetVerticalScrollRange() or 0) or 0, 0)
    view.bodyScrollFrame:SetVerticalScroll(math.max(0, math.min(targetScroll, maxScroll)))
    return true
end

function module:GetReadViewLineRowHeight(row)
    if not row then
        return 1
    end

    if row.contentHeight and row.contentHeight > 0 then
        return math.max(row.contentHeight, 1)
    end

    if row.lineType == "blank" then
        return math.max(READ_BLANK_LINE_HEIGHT, 1)
    end

    if row.lineType == "separator" then
        return math.max(READ_SEPARATOR_ROW_HEIGHT, 1)
    end

    if row.lineType == "code" then
        return math.max(
            (row.text and row.text:GetStringHeight() or 0) + (NOTE_TAB_FIELD_INNER_Y * 2) + (READ_CODE_BLOCK_PADDING_Y * 2),
            READ_LINE_FONT_SIZE + (NOTE_TAB_FIELD_INNER_Y * 2) + (READ_CODE_BLOCK_PADDING_Y * 2),
            1
        )
    end

    if row.lineType == "atlas" and row.atlasHeight then
        return math.max(row.atlasHeight + (NOTE_TAB_FIELD_INNER_Y * 2), 1)
    end

    return math.max((row.text and row.text:GetStringHeight() or 0) + (NOTE_TAB_FIELD_INNER_Y * 2), 1)
end

function module:RefreshNoteReadLineRows(view, bodyText)
    if not view or not view.bodyContent then
        return false
    end

    local entries, anchorIds = BuildReadViewRenderPlan(bodyText)
    local renderedLineCount = 0
    local previousRow = nil
    local previousLineType = nil
    local previousIndentOffset = 0
    local hasUnresolvedItemTokens = false
    local pendingItemIds = {}
    for _, entry in ipairs(entries) do
        renderedLineCount = renderedLineCount + 1
        local row = self:GetOrCreateNoteReadLineRow(view, renderedLineCount)
        local lineType = entry.lineType
        local displayText = entry.displayText
        local markerText = entry.markerText
        local indentOffset = entry.indentOffset or 0
        row.isCentered = entry.isCentered and true or false
        row.anchorId = entry.anchorId
        row.sourceLineIndex = entry.sourceLineIndex
        row:ClearAllPoints()
        row:SetPoint("LEFT", view.bodyContent, "LEFT", indentOffset, 0)
        row:SetPoint("RIGHT", view.bodyContent, "RIGHT", 0, 0)

        local rowHasUnresolvedItemTokens = self:ApplyReadViewLineStyle(row, lineType, displayText, pendingItemIds, anchorIds, view, markerText)
        row.lineType = row.renderedLineType or lineType
        if previousRow then
            row:SetPoint("TOPLEFT", previousRow, "BOTTOMLEFT", indentOffset - previousIndentOffset, -self:GetReadViewLineSpacing(previousLineType, row.lineType))
        else
            row:SetPoint("TOPLEFT", view.bodyContent, "TOPLEFT", indentOffset, 0)
        end
        row:SetHeight(self:GetReadViewLineRowHeight(row))
        row:Show()
        previousRow = row
        previousLineType = row.lineType
        previousIndentOffset = indentOffset
        hasUnresolvedItemTokens = hasUnresolvedItemTokens or rowHasUnresolvedItemTokens
    end

    for index = renderedLineCount + 1, #(view.bodyLines or {}) do
        local row = view.bodyLines[index]
        if row then
            self:HideReadInteractiveRegions(row)
            self:HideReadSegmentBackgrounds(row)
            self:HideReadSegmentTexts(row)
            self:HideReadTaskToggleButton(row)
            row:Hide()
            row.lineType = nil
            row.renderedLineType = nil
            row.inlineSegments = nil
            row.atlasData = nil
            row.anchorId = nil
            row.sourceLineIndex = nil
            row.contentHeight = nil
            row.usesStyledSegments = nil
            row.markerText = nil
            row.readView = nil
        end
    end

    self:RefreshReadAnchorTargets(view)
    for index = 1, renderedLineCount do
        local row = view.bodyLines[index]
        if row and row:IsShown() and row.inlineSegments and not row.usesStyledSegments then
            local fallbackFontPath, fontFlags = self:GetReadViewDefaultFont()
            local resolvedFontPath = self:GetReadViewFontPath(row.renderedLineType or row.lineType, fallbackFontPath)
            local fontSize = READ_LINE_FONT_SIZE
            if row.lineType == "h1" then
                fontSize = READ_HEADER1_FONT_SIZE
            elseif row.lineType == "h2" then
                fontSize = READ_HEADER2_FONT_SIZE
            elseif row.lineType == "h3" then
                fontSize = READ_HEADER3_FONT_SIZE
            end
            self:RefreshReadInteractiveRegions(row, resolvedFontPath, fallbackFontPath, fontSize, fontFlags)
        end
        if row and row:IsShown() then
            self:RefreshReadTaskToggleButton(row)
        end
    end

    view.hasPendingReadItemInfo = hasUnresolvedItemTokens
    view.pendingReadItemIds = pendingItemIds
    return hasUnresolvedItemTokens
end

function module:RefreshNoteReadLineRowHeights(view)
    if not view or not view.bodyLines then
        return
    end

    for _, row in ipairs(view.bodyLines) do
        if row:IsShown() and row.text then
            if row.usesStyledSegments and row.inlineSegments then
                local fallbackFontPath, fontFlags = self:GetReadViewDefaultFont()
                local fontSize = READ_LINE_FONT_SIZE
                if row.lineType == "h1" then
                    fontSize = READ_HEADER1_FONT_SIZE
                elseif row.lineType == "h2" then
                    fontSize = READ_HEADER2_FONT_SIZE
                elseif row.lineType == "h3" then
                    fontSize = READ_HEADER3_FONT_SIZE
                end

                self:RenderStyledReadSegments(row, row.renderedLineType or row.lineType, row.inlineSegments, row.markerText, fallbackFontPath, fontSize, fontFlags)
            end
            if row.lineType == "atlas" and row.atlasData then
                self:TryApplyReadViewAtlas(row, row.atlasData)
            end
            row:SetHeight(self:GetReadViewLineRowHeight(row))
            self:RefreshReadTaskToggleButton(row)
        end
    end
end

function module:UpdateNoteBodyEditLayout(tab)
    local view = self:GetNoteTabEditView(tab and tab.panel)
    if not view or not view.bodyFrame or not view.bodyInput or not view.bodyScrollFrame then
        return
    end

    local scrollBar = view.bodyScrollBar

    if view.lineNumberGutter then
        view.lineNumberGutter:ClearAllPoints()
        view.lineNumberGutter:SetPoint("TOPLEFT", view.bodyFrame, "TOPLEFT", NOTE_TAB_BODY_NATIVE_LEFT_INSET, -NOTE_TAB_BODY_NATIVE_TOP_INSET)
        view.lineNumberGutter:SetPoint("BOTTOMLEFT", view.bodyFrame, "BOTTOMLEFT", NOTE_TAB_BODY_NATIVE_LEFT_INSET, NOTE_TAB_BODY_NATIVE_BOTTOM_INSET)
        view.lineNumberGutter:SetWidth(view.lineNumberGutter:GetWidth() or 0)
    end

    view.bodyScrollFrame:ClearAllPoints()
    if view.lineNumberGutter then
        view.bodyScrollFrame:SetPoint("TOPLEFT", view.lineNumberGutter, "TOPRIGHT", view.lineNumberGap or 0, 0)
        view.bodyScrollFrame:SetPoint("BOTTOMLEFT", view.lineNumberGutter, "BOTTOMRIGHT", view.lineNumberGap or 0, 0)
    else
        view.bodyScrollFrame:SetPoint("TOPLEFT", view.bodyFrame, "TOPLEFT", NOTE_TAB_BODY_NATIVE_LEFT_INSET, -NOTE_TAB_BODY_NATIVE_TOP_INSET)
        view.bodyScrollFrame:SetPoint("BOTTOMLEFT", view.bodyFrame, "BOTTOMLEFT", NOTE_TAB_BODY_NATIVE_LEFT_INSET, NOTE_TAB_BODY_NATIVE_BOTTOM_INSET)
    end
    view.bodyScrollFrame:SetPoint("TOPRIGHT", view.bodyFrame, "TOPRIGHT", -NOTE_TAB_BODY_NATIVE_RIGHT_INSET, -NOTE_TAB_BODY_NATIVE_TOP_INSET)
    view.bodyScrollFrame:SetPoint("BOTTOMRIGHT", view.bodyFrame, "BOTTOMRIGHT", -NOTE_TAB_BODY_NATIVE_RIGHT_INSET, NOTE_TAB_BODY_NATIVE_BOTTOM_INSET)

    if scrollBar then
        scrollBar:ClearAllPoints()
        scrollBar:SetWidth(NOTE_TAB_BODY_SCROLLBAR_WIDTH)
        scrollBar:SetPoint("TOPLEFT", view.bodyScrollFrame, "TOPRIGHT", NOTE_TAB_BODY_SCROLLBAR_GAP + NOTE_TAB_BODY_SCROLLBAR_X_OFFSET, -NOTE_TAB_BODY_SCROLLBAR_TOP_INSET)
        scrollBar:SetPoint("BOTTOMRIGHT", view.bodyFrame, "BOTTOMRIGHT", -(NOTE_TAB_BODY_SCROLLBAR_RIGHT_INSET - NOTE_TAB_BODY_SCROLLBAR_X_OFFSET), NOTE_TAB_BODY_NATIVE_BOTTOM_INSET + NOTE_TAB_BODY_SCROLLBAR_BOTTOM_INSET)
    end
end

function module:UpdateNoteBodyReadLayout(tab)
    local view = self:GetNoteTabReadView(tab and tab.panel)
    self:UpdateStandaloneReadViewLayout(view)
end

function module:UpdateStandaloneReadViewLayout(view)
    if not view or not view.bodyFrame or not view.bodyScrollFrame or not view.bodyContent then
        return
    end

    local scrollBar = view.bodyScrollBar
    local reserveScrollbar = scrollBar and scrollBar:IsShown() or false
    local rightInset = NOTE_TAB_BODY_NATIVE_RIGHT_INSET + (reserveScrollbar and (NOTE_TAB_BODY_SCROLLBAR_WIDTH + NOTE_TAB_BODY_SCROLLBAR_GAP) or 0)

    view.bodyScrollFrame:ClearAllPoints()
    view.bodyScrollFrame:SetPoint("TOPLEFT", view.bodyFrame, "TOPLEFT", NOTE_TAB_BODY_NATIVE_LEFT_INSET, -NOTE_TAB_BODY_NATIVE_TOP_INSET)
    view.bodyScrollFrame:SetPoint("BOTTOMRIGHT", view.bodyFrame, "BOTTOMRIGHT", -rightInset, NOTE_TAB_BODY_NATIVE_BOTTOM_INSET)

    if scrollBar then
        scrollBar:ClearAllPoints()
        scrollBar:SetWidth(NOTE_TAB_BODY_SCROLLBAR_WIDTH)
        scrollBar:SetPoint("TOPLEFT", view.bodyFrame, "TOPRIGHT", NOTE_TAB_BODY_SCROLLBAR_LEFT_INSET + NOTE_TAB_BODY_SCROLLBAR_X_OFFSET, -(NOTE_TAB_BODY_NATIVE_TOP_INSET + NOTE_TAB_BODY_SCROLLBAR_TOP_INSET))
        scrollBar:SetPoint("BOTTOMRIGHT", view.bodyFrame, "BOTTOMRIGHT", -(NOTE_TAB_BODY_SCROLLBAR_RIGHT_INSET - NOTE_TAB_BODY_SCROLLBAR_X_OFFSET), NOTE_TAB_BODY_NATIVE_BOTTOM_INSET + NOTE_TAB_BODY_SCROLLBAR_BOTTOM_INSET)
    end

    view.bodyContent:SetWidth(self:GetNoteReadBodyVisibleWidth(view, reserveScrollbar))
    self:RefreshNoteReadLineRowHeights(view)
    view.bodyContent:SetHeight(self:GetNoteReadBodyContentHeight(view))
end

function module:RefreshNoteReadView(tab)
    local readView = self:GetNoteTabReadView(tab and tab.panel)
    if not readView then
        return
    end

    readView.ownerTab = tab
    local title = self:GetNoteTabStoredTitle(tab)
    local body = tab and tab.noteData and tab.noteData.body or DEFAULT_NOTE_BODY
    self:RefreshStandaloneReadView(readView, title, body or DEFAULT_NOTE_BODY)
    tab.hasPendingReadItemInfo = readView.hasPendingReadItemInfo
    tab.pendingReadItemIds = readView.pendingReadItemIds
    self:UpdateReadItemInfoEventRegistration()
end

function module:RefreshStandaloneReadView(view, title, bodyText)
    if not view then
        return false
    end

    if view.titleText then
        view.titleText:SetText(title)
    end
    view.hasPendingReadItemInfo = self:RefreshNoteReadLineRows(view, bodyText or DEFAULT_NOTE_BODY)
    view.pendingReadItemIds = view.pendingReadItemIds or {}
    self:UpdateStandaloneReadViewLayout(view)
    return view.hasPendingReadItemInfo
end

function module:QueueDeferredNoteReadViewRefresh(tab)
    if not tab or tab.pendingDeferredReadRefresh then
        return
    end

    tab.pendingDeferredReadRefresh = true
    C_Timer.After(0, function()
        tab.pendingDeferredReadRefresh = nil

        if not tab.panel or module:IsNoteTabInEditMode(tab) then
            return
        end

        local readView = module:GetNoteTabReadView(tab.panel)
        if not readView or not readView:IsShown() then
            return
        end

        module:RefreshNoteReadView(tab)
    end)
end

