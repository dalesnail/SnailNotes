local _, ns = ...
local shared = ns.NotesShared
local module = shared and shared.module
if not shared or not module then return end

local constants = shared.constants
local NOTE_TAB_BODY_MIN_CONTENT_HEIGHT = constants.NOTE_TAB_BODY_MIN_CONTENT_HEIGHT
local NOTE_TAB_BODY_NATIVE_LEFT_INSET = constants.NOTE_TAB_BODY_NATIVE_LEFT_INSET
local NOTE_TAB_BODY_NATIVE_TOP_INSET = constants.NOTE_TAB_BODY_NATIVE_TOP_INSET
local NOTE_TAB_BODY_NATIVE_RIGHT_INSET = constants.NOTE_TAB_BODY_NATIVE_RIGHT_INSET
local NOTE_TAB_BODY_NATIVE_BOTTOM_INSET = constants.NOTE_TAB_BODY_NATIVE_BOTTOM_INSET
local NOTE_TAB_FIELD_INNER_X = constants.NOTE_TAB_FIELD_INNER_X
local NOTE_TAB_FIELD_INNER_Y = constants.NOTE_TAB_FIELD_INNER_Y
local FONT_REGULAR = constants.FONT_REGULAR
local FONT_ITALIC = constants.FONT_ITALIC
local FONT_BOLD = constants.FONT_BOLD
local FONT_BOLDITALIC = constants.FONT_BOLDITALIC
local READ_BULLET_INDENT = constants.READ_BULLET_INDENT
local READ_SEPARATOR_COLOR = constants.READ_SEPARATOR_COLOR
local READ_CODE_BACKGROUND_COLOR = constants.READ_CODE_BACKGROUND_COLOR
local READ_UNRESOLVED_ITEM_TOKEN_COLOR = constants.READ_UNRESOLVED_ITEM_TOKEN_COLOR

local FLOAT_BODY_TOP_INSET = 8
local FLOAT_BODY_SIDE_INSET = 8
local FLOAT_BODY_BOTTOM_INSET = 18
local FLOAT_SETTINGS_BUTTON_LEFT = 8
local FLOAT_SETTINGS_BUTTON_BOTTOM = 6
local FLOAT_TEXT_FONT_SIZE = 15
local FLOAT_HEADER1_FONT_SIZE = 24
local FLOAT_HEADER2_FONT_SIZE = 20
local FLOAT_HEADER3_FONT_SIZE = 17
local FLOAT_CODE_FONT_SIZE = 14
local FLOAT_ROW_SIDE_PADDING = 8
local FLOAT_ROW_TOP_PADDING = 2
local FLOAT_ROW_BOTTOM_PADDING = 2
local FLOAT_MARKER_GAP = 6
local FLOAT_LIST_INDENT = math.max(math.floor((READ_BULLET_INDENT * 0.4) + 0.5), 8)
local FLOAT_INLINE_CODE_PADDING_X = 4
local FLOAT_INLINE_CODE_PADDING_Y = 2
local FLOAT_CODE_BLOCK_PADDING_X = 6
local FLOAT_CODE_BLOCK_PADDING_Y = 4
local FLOAT_CODE_LINE_SPACING = 1
local FLOAT_LINE_SPACING = 1
local FLOAT_TASK_SPACING = 6
local FLOAT_HEADER_SPACING = 3
local FLOAT_POST_LIST_SPACING = 2
local FLOAT_SEPARATOR_SPACING = 4
local FLOAT_BLANK_LINE_HEIGHT = 7
local FLOAT_SEPARATOR_HEIGHT = 12
local FLOAT_TEXTURE_MAX_HEIGHT = 180
local FLOAT_LINK_COLOR = { 0.45, 0.82, 1.0 }
local FLOAT_TASK_CHECKED_TEXT_COLOR = { 0.72, 0.72, 0.72 }
local FLOAT_TASK_CHECKED_MARKER_COLOR = { 0.55, 0.92, 0.55 }
local FLOAT_TASK_UNCHECKED_MARKER_COLOR = { 0.93, 0.90, 0.84 }
local FLOAT_INLINE_CODE_TEXT_COLOR = { 0.80, 0.80, 0.80 }
local FLOAT_INLINE_CODE_BACKGROUND_COLOR = { 0.02, 0.02, 0.02, 0.42 }
local FLOAT_CODE_TEXT_COLOR = { 0.80, 0.80, 0.80 }
local FLOAT_SETTINGS_TEXT_COLOR = { 0.88, 0.88, 0.88, 0.92 }
local FLOAT_SETTINGS_TEXT_HOVER = { 1.0, 1.0, 1.0, 1.0 }
local NOTES_SCROLL_MULT = 1.25
local NOTES_MOUSE_WHEEL_SCROLL_STEP = 40

local function NextNoteBodyScrollFrameSerial()
    return shared.NextNoteBodyScrollFrameSerial()
end

local function IsFloatListLineType(lineType)
    return lineType == "bullet" or lineType == "numbered" or lineType == "taskUnchecked" or lineType == "taskChecked"
end

local function IsFloatHeaderLineType(lineType)
    return lineType == "h1" or lineType == "h2" or lineType == "h3"
end

local function GetFloatChunkFontPath(style, lineType)
    if style == "bolditalic" then
        return FONT_BOLDITALIC
    elseif style == "bold" then
        return FONT_BOLD
    elseif style == "italic" then
        if IsFloatHeaderLineType(lineType) then
            return FONT_BOLDITALIC or FONT_BOLD or FONT_ITALIC or FONT_REGULAR
        end
        return FONT_ITALIC
    elseif IsFloatHeaderLineType(lineType) then
        return FONT_BOLD or FONT_REGULAR
    end

    return FONT_REGULAR
end

local function GetFloatLineFontSize(lineType)
    local baseFontSize = FLOAT_TEXT_FONT_SIZE
    if lineType == "h1" then
        baseFontSize = FLOAT_HEADER1_FONT_SIZE
    elseif lineType == "h2" then
        baseFontSize = FLOAT_HEADER2_FONT_SIZE
    elseif lineType == "h3" then
        baseFontSize = FLOAT_HEADER3_FONT_SIZE
    elseif lineType == "code" then
        baseFontSize = FLOAT_CODE_FONT_SIZE
    end

    local scale = module.GetFloatFontScale and module:GetFloatFontScale() or 1
    return math.max(math.floor((baseFontSize * scale) + 0.5), 1)
end

local function GetFloatRowSpacing(previousLineType, currentLineType)
    if not previousLineType then
        return 0
    end

    if previousLineType == "separator" or currentLineType == "separator" then
        return FLOAT_SEPARATOR_SPACING
    end

    if previousLineType == "h1" or previousLineType == "h2" or previousLineType == "h3" then
        return FLOAT_HEADER_SPACING
    end

    if previousLineType == "taskUnchecked" or previousLineType == "taskChecked" then
        return FLOAT_TASK_SPACING
    end

    if IsFloatListLineType(previousLineType) and not IsFloatListLineType(currentLineType) then
        return FLOAT_POST_LIST_SPACING
    end

    return FLOAT_LINE_SPACING
end

local function GetFloatIndentOffset(entry)
    if entry and IsFloatListLineType(entry.lineType) and not entry.isCentered then
        return FLOAT_LIST_INDENT
    end

    return entry and entry.indentOffset or 0
end

local function ResolveFloatTaskTargetTab(noteId)
    if not noteId then
        return nil
    end

    local realTab = module:GetOpenTabForNoteId(noteId)
    local proxyTab = realTab and nil or module:GetFloatWindowProxyTab(noteId)
    local targetTab = realTab or proxyTab
    return targetTab
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

local function SetChunkInteractiveState(chunk, enabled)
    chunk.segmentData = enabled and chunk.segmentData or nil
    chunk:EnableMouse(enabled)
end

local function ConfigureFloatInteractiveChunk(chunk)
    chunk:RegisterForClicks("LeftButtonUp")
    chunk:SetScript("OnEnter", function(selfChunk)
        local segmentData = selfChunk.segmentData
        if not segmentData or not segmentData.isResolved then
            return
        end

        if segmentData.kind == "noteLink" then
            local targetNote = segmentData.targetNote
            GameTooltip:SetOwner(selfChunk, "ANCHOR_RIGHT")
            GameTooltip:SetText(segmentData.linkText or segmentData.displayText or "", unpack(FLOAT_LINK_COLOR))
            if targetNote and targetNote.title and targetNote.title ~= "" then
                GameTooltip:AddLine(targetNote.title, 0.92, 0.88, 0.80, true)
            end
            GameTooltip:AddLine("Open note", 0.92, 0.88, 0.80, true)
            GameTooltip:Show()
            return
        end

        GameTooltip:SetOwner(selfChunk, "ANCHOR_RIGHT")
        if segmentData.kind == "anchorLink" then
            GameTooltip:SetText(segmentData.linkText or segmentData.displayText or "", unpack(FLOAT_LINK_COLOR))
            GameTooltip:AddLine("Jump to section", 0.92, 0.88, 0.80, true)
        elseif segmentData.itemLink then
            GameTooltip:SetHyperlink(segmentData.itemLink)
        end
        GameTooltip:Show()
    end)
    chunk:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    chunk:SetScript("OnClick", function(selfChunk, button)
        local segmentData = selfChunk.segmentData
        if not segmentData or not segmentData.isResolved then
            return
        end

        if segmentData.kind == "anchorLink" then
            if segmentData.readView and segmentData.anchorId then
                module:JumpToReadViewAnchor(segmentData.readView, segmentData.anchorId)
            end
            return
        end

        if segmentData.kind == "noteLink" then
            if segmentData.noteId then
                module:OpenNote(segmentData.noteId, false)
            end
            return
        end

        local itemLink = segmentData.itemLink
        if not itemLink or itemLink == "" then
            return
        end

        if HandleModifiedItemClick and HandleModifiedItemClick(itemLink) then
            return
        end

        if SetItemRef then
            SetItemRef(itemLink, itemLink, button or "LeftButton", selfChunk)
        end
    end)
end

local function GetOrCreateFloatChunk(row, index)
    row.floatChunks = row.floatChunks or {}
    local chunk = row.floatChunks[index]
    if chunk then
        return chunk
    end

    chunk = CreateFrame("Button", nil, row)
    chunk.text = chunk:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    chunk.text:SetPoint("TOPLEFT", 0, 0)
    chunk.background = chunk:CreateTexture(nil, "BACKGROUND")
    chunk.background:SetTexture("Interface\\Buttons\\WHITE8x8")
    chunk.background:Hide()
    ConfigureFloatInteractiveChunk(chunk)
    row.floatChunks[index] = chunk
    return chunk
end

local function HideUnusedFloatChunks(row)
    if not row or not row.floatChunks then
        return
    end

    for _, chunk in ipairs(row.floatChunks) do
        chunk.segmentData = nil
        chunk:EnableMouse(false)
        chunk.background:Hide()
        chunk.text:SetText("")
        chunk:Hide()
    end
end

local function GetOrCreateFloatLineRow(view, index)
    view.bodyLines = view.bodyLines or {}
    local row = view.bodyLines[index]
    if row then
        return row
    end

    row = CreateFrame("Frame", nil, view.bodyRenderRoot)
    row.readView = view
    row:SetHeight(1)

    row.measure = row:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    row.measure:Hide()

    row.markerButton = CreateFrame("Button", nil, row)
    row.markerButton:RegisterForClicks("LeftButtonUp")
    row.markerButton.text = row.markerButton:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    row.markerButton.text:SetPoint("TOPLEFT", 0, 0)
    row.markerButton.text:SetJustifyH("LEFT")
    row.markerButton.text:SetJustifyV("TOP")
    row.markerButton:Hide()
    row.markerButton:SetScript("OnClick", function(buttonFrame)
        local noteId = buttonFrame.noteId
        local sourceLineIndex = buttonFrame.sourceLineIndex
        if not noteId or not sourceLineIndex then
            return
        end

        local targetTab = ResolveFloatTaskTargetTab(noteId)
        if not targetTab then
            return
        end

        module:ToggleTaskLineAtIndex(targetTab, sourceLineIndex)
    end)

    row.separator = row:CreateTexture(nil, "ARTWORK")
    row.separator:SetTexture("Interface\\Buttons\\WHITE8x8")
    row.separator:SetVertexColor(unpack(READ_SEPARATOR_COLOR))
    row.separator:Hide()

    row.codeBackground = row:CreateTexture(nil, "BACKGROUND")
    row.codeBackground:SetTexture("Interface\\Buttons\\WHITE8x8")
    row.codeBackground:SetVertexColor(unpack(READ_CODE_BACKGROUND_COLOR))
    row.codeBackground:Hide()

    row.atlasTexture = row:CreateTexture(nil, "ARTWORK")
    row.atlasTexture:Hide()

    view.bodyLines[index] = row
    return row
end

local function HideFloatLineRow(row)
    if not row then
        return
    end

    row.anchorId = nil
    row.inlineSegments = nil
    row.markerText = nil
    row.lineType = nil
    row.separator:Hide()
    row.codeBackground:Hide()
    row.atlasTexture:Hide()
    row.markerButton.noteId = nil
    row.markerButton.sourceLineIndex = nil
    row.markerButton:Hide()
    HideUnusedFloatChunks(row)
    row:Hide()
end

local function HideUnusedFloatRows(view, fromIndex)
    if not view or not view.bodyLines then
        return
    end

    for index = fromIndex, #view.bodyLines do
        HideFloatLineRow(view.bodyLines[index])
    end
end

local function MeasureFloatText(row, text, fontPath, fontSize)
    module:ApplyReadViewFont(row.measure, fontPath, FONT_REGULAR, fontSize, "")
    row.measure:SetText(text or "")
    return row.measure:GetStringWidth() or 0, row.measure:GetStringHeight() or fontSize
end

local function SplitFloatSegmentIntoUnits(segmentData)
    local units = {}
    local displayText = tostring(segmentData and (segmentData.displayText or segmentData.text) or "")
    if displayText == "" then
        return units
    end

    if segmentData and (segmentData.kind == "itemToken" or segmentData.style == "code") then
        units[1] = {
            text = displayText,
            segmentData = segmentData,
            isSpace = false,
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
                isSpace = true,
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
                isSpace = false,
            }
            cursor = wordEnd + 1
        end
    end

    return units
end

local function GetFloatSegmentTextColor(lineType, segmentData, marker)
    if marker then
        if lineType == "taskChecked" then
            return FLOAT_TASK_CHECKED_MARKER_COLOR
        elseif lineType == "taskUnchecked" then
            return FLOAT_TASK_UNCHECKED_MARKER_COLOR
        end
        return FLOAT_SETTINGS_TEXT_COLOR
    end

    if segmentData.kind == "noteLink" or segmentData.kind == "anchorLink" then
        return segmentData.isResolved and FLOAT_LINK_COLOR or READ_UNRESOLVED_ITEM_TOKEN_COLOR
    end
    if segmentData.kind == "itemToken" then
        return segmentData.isResolved and nil or READ_UNRESOLVED_ITEM_TOKEN_COLOR
    end
    if segmentData.style == "code" then
        return FLOAT_INLINE_CODE_TEXT_COLOR
    end
    if lineType == "taskChecked" then
        return FLOAT_TASK_CHECKED_TEXT_COLOR
    end
    return segmentData.textColor
end

local function RenderFloatInlineRow(view, row, entry, segments)
    local lineType = entry.lineType
    local baseFontSize = GetFloatLineFontSize(lineType)
    local leftInset = FLOAT_ROW_SIDE_PADDING
    local topInset = FLOAT_ROW_TOP_PADDING
    local bottomInset = FLOAT_ROW_BOTTOM_PADDING
    local rightInset = FLOAT_ROW_SIDE_PADDING
    local markerText = nil
    local markerWidth = 0
    local markerHeight = 0
    local isTask = lineType == "taskUnchecked" or lineType == "taskChecked"

    row.markerButton:Hide()
    if IsFloatListLineType(lineType) and not entry.isCentered then
        markerText = module:ResolveReadListMarkerText(nil, lineType, entry.markerText or "•")
        row.markerText = markerText
        module:ApplyReadViewFont(row.markerButton.text, FONT_REGULAR, FONT_REGULAR, GetFloatLineFontSize("plain"), "")
        row.markerButton.text:SetText(markerText or "")
        local markerColor = GetFloatSegmentTextColor(lineType, {}, true)
        if markerColor then
            row.markerButton.text:SetTextColor(unpack(markerColor))
        else
            row.markerButton.text:SetTextColor(1, 1, 1)
        end
        markerWidth, markerHeight = MeasureFloatText(row, markerText or "", FONT_REGULAR, GetFloatLineFontSize("plain"))
        row.markerButton:ClearAllPoints()
        row.markerButton:SetPoint("TOPLEFT", row, "TOPLEFT", leftInset, -topInset)
        row.markerButton:SetSize(math.max(markerWidth, 1), math.max(markerHeight, 1))
        row.markerButton.noteId = isTask and view.noteId or nil
        row.markerButton.sourceLineIndex = isTask and entry.sourceLineIndex or nil
        row.markerButton:EnableMouse(isTask and row.markerButton.noteId ~= nil)
        row.markerButton:Show()
    end

    local indentOffset = GetFloatIndentOffset(entry)
    local availableWidth = math.max(
        (view.floatBaseLayoutWidth or 1) - indentOffset - leftInset - rightInset - (markerWidth > 0 and (markerWidth + FLOAT_MARKER_GAP) or 0),
        1
    )
    local units = {}
    for _, segmentData in ipairs(segments or {}) do
        local segmentUnits = SplitFloatSegmentIntoUnits(segmentData)
        for _, unit in ipairs(segmentUnits) do
            local fontPath = GetFloatChunkFontPath(segmentData.style, lineType)
            local fontSize = segmentData.style == "code" and GetFloatLineFontSize("code") or baseFontSize
            local unitWidth, unitHeight = MeasureFloatText(row, unit.text, fontPath, fontSize)
            if segmentData.style == "code" then
                unitWidth = unitWidth + (FLOAT_INLINE_CODE_PADDING_X * 2)
                unitHeight = unitHeight + (FLOAT_INLINE_CODE_PADDING_Y * 2)
            end
            units[#units + 1] = {
                text = unit.text,
                segmentData = segmentData,
                isSpace = unit.isSpace,
                fontPath = fontPath,
                fontSize = fontSize,
                width = unitWidth,
                height = unitHeight,
            }
        end
    end

    local lines = {}
    local currentLine = { width = 0, height = baseFontSize, units = {} }
    lines[1] = currentLine
    for _, unit in ipairs(units) do
        if unit.isSpace and currentLine.width == 0 then
            -- skip leading spaces
        else
            local wouldWrap = currentLine.width > 0 and not unit.isSpace and (currentLine.width + unit.width) > availableWidth
            if wouldWrap then
                currentLine = { width = 0, height = baseFontSize, units = {} }
                lines[#lines + 1] = currentLine
            end

            currentLine.units[#currentLine.units + 1] = unit
            currentLine.width = currentLine.width + unit.width
            currentLine.height = math.max(currentLine.height, unit.height)
        end
    end

    local chunkIndex = 0
    local markerOffset = markerWidth > 0 and (markerWidth + FLOAT_MARKER_GAP) or 0
    local yOffset = topInset
    for _, lineData in ipairs(lines) do
        local centeredOffset = 0
        if entry.isCentered and availableWidth > lineData.width then
            centeredOffset = math.max(math.floor(((availableWidth - lineData.width) / 2) + 0.5), 0)
        end

        local xOffset = 0
        for _, unit in ipairs(lineData.units) do
            chunkIndex = chunkIndex + 1
            local chunk = GetOrCreateFloatChunk(row, chunkIndex)
            local segmentData = unit.segmentData or {}
            local chunkText = unit.text or ""
            local textColor = GetFloatSegmentTextColor(lineType, segmentData, false)
            chunk.segmentData = (segmentData.kind == "itemToken" or segmentData.kind == "anchorLink" or segmentData.kind == "noteLink")
                and segmentData.isResolved and not unit.isSpace and segmentData or nil
            chunk:ClearAllPoints()
            chunk:SetPoint("TOPLEFT", row, "TOPLEFT", leftInset + markerOffset + centeredOffset + xOffset, -yOffset)
            chunk.text:ClearAllPoints()
            chunk.text:SetPoint("TOPLEFT", 0, 0)
            module:ApplyReadViewFont(chunk.text, unit.fontPath, FONT_REGULAR, unit.fontSize, "")
            chunk.text:SetText(chunkText)
            if textColor then
                chunk.text:SetTextColor(unpack(textColor))
            else
                chunk.text:SetTextColor(1, 1, 1)
            end
            chunk.background:Hide()
            local chunkWidth = unit.width
            local chunkHeight = math.max(lineData.height, unit.height)
            if segmentData.style == "code" then
                chunk.background:SetVertexColor(unpack(FLOAT_INLINE_CODE_BACKGROUND_COLOR))
                chunk.background:ClearAllPoints()
                chunk.background:SetPoint("TOPLEFT", chunk.text, "TOPLEFT", -FLOAT_INLINE_CODE_PADDING_X, FLOAT_INLINE_CODE_PADDING_Y)
                chunk.background:SetPoint("BOTTOMRIGHT", chunk.text, "BOTTOMRIGHT", FLOAT_INLINE_CODE_PADDING_X, -FLOAT_INLINE_CODE_PADDING_Y)
                chunk.background:Show()
            end
            chunk:SetSize(math.max(chunkWidth, 1), math.max(chunkHeight, 1))
            SetChunkInteractiveState(chunk, chunk.segmentData ~= nil)
            chunk:Show()
            xOffset = xOffset + unit.width
        end

        yOffset = yOffset + lineData.height + FLOAT_LINE_SPACING
    end

    if row.floatChunks then
        for index = chunkIndex + 1, #row.floatChunks do
            row.floatChunks[index].segmentData = nil
            row.floatChunks[index]:EnableMouse(false)
            row.floatChunks[index]:Hide()
            row.floatChunks[index].background:Hide()
        end
    end

    row.inlineSegments = segments
    row.contentHeight = math.max(yOffset + bottomInset - FLOAT_LINE_SPACING, markerHeight + topInset + bottomInset, 1)
    row:SetHeight(row.contentHeight)
end

local function RenderFloatCodeRow(view, row, displayText)
    local chunk = GetOrCreateFloatChunk(row, 1)
    HideUnusedFloatChunks(row)
    row.markerButton:Hide()
    row.codeBackground:Show()
    row.codeBackground:ClearAllPoints()
    row.codeBackground:SetPoint("TOPLEFT", row, "TOPLEFT", FLOAT_ROW_SIDE_PADDING, -FLOAT_ROW_TOP_PADDING)
    row.codeBackground:SetPoint("TOPRIGHT", row, "TOPRIGHT", -FLOAT_ROW_SIDE_PADDING, -FLOAT_ROW_TOP_PADDING)
    chunk.segmentData = nil
    chunk:ClearAllPoints()
    chunk:SetPoint("TOPLEFT", row, "TOPLEFT", FLOAT_ROW_SIDE_PADDING + FLOAT_CODE_BLOCK_PADDING_X, -(FLOAT_ROW_TOP_PADDING + FLOAT_CODE_BLOCK_PADDING_Y))
    chunk.text:ClearAllPoints()
    chunk.text:SetPoint("TOPLEFT", 0, 0)
    module:ApplyReadViewFont(chunk.text, FONT_REGULAR, FONT_REGULAR, GetFloatLineFontSize("code"), "")
    chunk.text:SetTextColor(unpack(FLOAT_CODE_TEXT_COLOR))
    if chunk.text.SetSpacing then
        chunk.text:SetSpacing(FLOAT_CODE_LINE_SPACING)
    end
    chunk.text:SetWordWrap(true)
    if chunk.text.SetNonSpaceWrap then
        chunk.text:SetNonSpaceWrap(true)
    end
    chunk.text:SetWidth(math.max((view.floatBaseLayoutWidth or 1) - (FLOAT_ROW_SIDE_PADDING * 2) - (FLOAT_CODE_BLOCK_PADDING_X * 2), 1))
    chunk.text:SetText(tostring(displayText or ""))
    chunk.background:Hide()
    chunk:EnableMouse(false)
    chunk:Show()
    local textHeight = chunk.text:GetStringHeight() or GetFloatLineFontSize("code")
    row.contentHeight = textHeight + (FLOAT_ROW_TOP_PADDING * 2) + (FLOAT_CODE_BLOCK_PADDING_Y * 2)
    row:SetHeight(math.max(row.contentHeight, 1))
    row.codeBackground:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -FLOAT_ROW_SIDE_PADDING, FLOAT_ROW_BOTTOM_PADDING)
end

local function RenderFloatSeparatorRow(view, row)
    HideUnusedFloatChunks(row)
    row.markerButton:Hide()
    row.separator:ClearAllPoints()
    row.separator:SetPoint("LEFT", row, "LEFT", FLOAT_ROW_SIDE_PADDING + 6, 0)
    row.separator:SetPoint("RIGHT", row, "RIGHT", -(FLOAT_ROW_SIDE_PADDING + 6), 0)
    row.separator:SetHeight(1)
    row.separator:Show()
    row:SetHeight(FLOAT_SEPARATOR_HEIGHT)
end

local function RenderFloatBlankRow(row)
    HideUnusedFloatChunks(row)
    row.markerButton:Hide()
    row:SetHeight(FLOAT_BLANK_LINE_HEIGHT)
end

local function RenderFloatAtlasRow(view, row, atlasData)
    HideUnusedFloatChunks(row)
    row.markerButton:Hide()
    row.atlasTexture:ClearAllPoints()
    local applied = row.atlasTexture:SetAtlas(atlasData.atlasName, true)
    if not applied then
        row.atlasTexture:Hide()
        row:SetHeight(1)
        return
    end

    local textureWidth = atlasData.width or row.atlasTexture:GetWidth() or 32
    local textureHeight = atlasData.height or row.atlasTexture:GetHeight() or textureWidth
    local maxWidth = math.max((view.floatBaseLayoutWidth or 1) - (FLOAT_ROW_SIDE_PADDING * 2), 1)
    local scale = math.min(1, maxWidth / math.max(textureWidth, 1), FLOAT_TEXTURE_MAX_HEIGHT / math.max(textureHeight, 1))
    textureWidth = math.max(math.floor((textureWidth * scale) + 0.5), 1)
    textureHeight = math.max(math.floor((textureHeight * scale) + 0.5), 1)
    row.atlasTexture:SetSize(textureWidth, textureHeight)
    row.atlasTexture:SetPoint("TOPLEFT", row, "TOPLEFT", FLOAT_ROW_SIDE_PADDING, -FLOAT_ROW_TOP_PADDING)
    row.atlasTexture:Show()
    row:SetHeight(textureHeight + FLOAT_ROW_TOP_PADDING + FLOAT_ROW_BOTTOM_PADDING)
end

function module:UpdateFloatRenderSettings(view)
    if not view then
        return
    end

    if view.settingsButton and view.settingsButton.text then
        view.settingsButton.text:SetText("Edit Note")
    end
end

function module:UpdateFloatReadViewLayout(view)
    if not view or not view.bodyFrame or not view.bodyScrollFrame or not view.bodyContent or not view.bodyRenderRoot then
        return
    end

    local scrollBar = view.bodyScrollBar
    local rightInset = NOTE_TAB_BODY_NATIVE_RIGHT_INSET

    view.bodyScrollFrame:ClearAllPoints()
    view.bodyScrollFrame:SetPoint("TOPLEFT", view.bodyFrame, "TOPLEFT", NOTE_TAB_BODY_NATIVE_LEFT_INSET, -NOTE_TAB_BODY_NATIVE_TOP_INSET)
    view.bodyScrollFrame:SetPoint("BOTTOMRIGHT", view.bodyFrame, "BOTTOMRIGHT", -rightInset, NOTE_TAB_BODY_NATIVE_BOTTOM_INSET)

    if scrollBar then
        scrollBar:Hide()
    end

    view.bodyContent:ClearAllPoints()
    view.bodyContent:SetPoint("TOPLEFT", view.bodyScrollFrame, "TOPLEFT", 0, 0)

    local visibleWidth = math.max(view.bodyScrollFrame:GetWidth() or 0, 1)
    local visibleHeight = math.max(view.bodyScrollFrame:GetHeight() or 0, 1)
    local logicalContentHeight = math.max(view.floatContentHeight or 0, NOTE_TAB_BODY_MIN_CONTENT_HEIGHT)
    local layoutWidth = math.max(tonumber(view.floatBaseLayoutWidth) or visibleWidth, 1)

    view.bodyRenderRoot:ClearAllPoints()
    view.bodyRenderRoot:SetPoint("TOPLEFT", view.bodyContent, "TOPLEFT", 0, 0)
    view.bodyRenderRoot:SetSize(layoutWidth, logicalContentHeight)
    view.bodyContent:SetSize(
        math.max(layoutWidth, visibleWidth),
        math.max(logicalContentHeight, visibleHeight)
    )
    self:ApplyPendingFloatReadViewScrollRestore(view)
end

function module:ApplyPendingFloatReadViewScrollRestore(view)
    if not view or not view.bodyScrollFrame or view.pendingScrollRestoreOffset == nil then
        return false
    end

    if view.bodyScrollFrame.UpdateScrollChildRect then
        view.bodyScrollFrame:UpdateScrollChildRect()
    end

    local requestedScrollOffset = tonumber(view.pendingScrollRestoreOffset) or 0
    local clampedScrollOffset, maxScroll = self:ClampReadViewScrollOffset(view, requestedScrollOffset)
    local visibleHeight = math.max(view.bodyScrollFrame:GetHeight() or 0, 0)
    local contentHeight = math.max((view.bodyContent and view.bodyContent:GetHeight()) or 0, 0)
    if maxScroll <= 0 and requestedScrollOffset > 0 and contentHeight > (visibleHeight + 0.5) then
        return false
    end

    if view.bodyScrollBar and view.bodyScrollBar.SetMinMaxValues then
        view.bodyScrollBar:SetMinMaxValues(0, maxScroll)
    end
    self:ApplyReadViewVerticalScroll(view, clampedScrollOffset, maxScroll)
    if view.bodyScrollBar and view.bodyScrollBar.SetValue then
        view.bodyScrollBar:SetValue(clampedScrollOffset)
    end
    view.pendingScrollRestoreOffset = nil
    return true
end

function module:RefreshFloatReadView(view, bodyText, preserveScroll)
    if not view then
        return false
    end

    local previousScrollOffset = nil
    if preserveScroll and view.bodyScrollFrame and view.bodyScrollFrame.GetVerticalScroll then
        previousScrollOffset = view.bodyScrollFrame:GetVerticalScroll() or 0
    end
    self:UpdateFloatRenderSettings(view)
    view.currentBodyText = bodyText or ""
    view.floatBaseLayoutWidth = math.max(
        (view.contentViewport and view.contentViewport:GetWidth() or 0) - NOTE_TAB_BODY_NATIVE_LEFT_INSET - NOTE_TAB_BODY_NATIVE_RIGHT_INSET,
        1
    )

    local entries, anchorIds = self:BuildReadViewRenderPlan(view.currentBodyText)
    local pendingItemIds = {}
    local hasPendingReadItemInfo = false
    local renderedLineCount = 0
    local previousRow = nil
    local previousLineType = nil
    local showTextures = self:IsFloatTexturesEnabled()
    local contentHeight = 0

    for _, entry in ipairs(entries or {}) do
        if entry.lineType ~= "atlas" or showTextures then
            renderedLineCount = renderedLineCount + 1
            local row = GetOrCreateFloatLineRow(view, renderedLineCount)
            row:ClearAllPoints()
            row.anchorId = entry.anchorId
            row.sourceLineIndex = entry.sourceLineIndex
            row.isCentered = entry.isCentered and true or false
            row.lineType = entry.lineType
            row.separator:Hide()
            row.codeBackground:Hide()
            row.atlasTexture:Hide()

            if entry.lineType == "blank" then
                RenderFloatBlankRow(row)
                row.inlineSegments = nil
            elseif entry.lineType == "separator" then
                RenderFloatSeparatorRow(view, row)
                row.inlineSegments = nil
            elseif entry.lineType == "atlas" then
                RenderFloatAtlasRow(view, row, entry.displayText or {})
                row.inlineSegments = nil
            elseif entry.lineType == "code" then
                RenderFloatCodeRow(view, row, entry.displayText or "")
                row.inlineSegments = nil
            else
                local isCenteredList = IsFloatListLineType(entry.lineType) and entry.isCentered or false
                local resolvedSegments, _, rowHasPending = self:BuildResolvedReadViewSegments(
                    entry.displayText or "",
                    entry.lineType,
                    view,
                    pendingItemIds,
                    anchorIds,
                    entry.markerText,
                    isCenteredList
                )
                RenderFloatInlineRow(view, row, entry, resolvedSegments)
                hasPendingReadItemInfo = hasPendingReadItemInfo or rowHasPending
            end

            local indentOffset = GetFloatIndentOffset(entry)
            row:SetPoint("LEFT", view.bodyRenderRoot, "LEFT", indentOffset, 0)
            row:SetPoint("RIGHT", view.bodyRenderRoot, "RIGHT", 0, 0)
            if previousRow then
                row:SetPoint("TOPLEFT", previousRow, "BOTTOMLEFT", indentOffset - (previousRow.indentOffset or 0), -GetFloatRowSpacing(previousLineType, row.lineType))
            else
                row:SetPoint("TOPLEFT", view.bodyRenderRoot, "TOPLEFT", indentOffset, 0)
            end
            row.indentOffset = indentOffset
            row:Show()
            contentHeight = contentHeight + (previousRow and GetFloatRowSpacing(previousLineType, row.lineType) or 0) + (row:GetHeight() or 0)
            previousRow = row
            previousLineType = row.lineType
        end
    end

    HideUnusedFloatRows(view, renderedLineCount + 1)
    self:RefreshReadAnchorTargets(view)
    view.floatContentHeight = math.max(contentHeight, NOTE_TAB_BODY_MIN_CONTENT_HEIGHT)
    view.pendingReadItemIds = pendingItemIds
    view.hasPendingReadItemInfo = hasPendingReadItemInfo
    view.renderedNoteId = view.noteId or view.renderedNoteId
    self:QueueReadViewScrollRestore(view, previousScrollOffset)
    self:UpdateFloatReadViewLayout(view)
    return hasPendingReadItemInfo
end

function module:CreateFloatRenderContentView(parent)
    local view = CreateFrame("Frame", nil, parent)
    view:SetAllPoints()
    view.isFloatView = true
    view.floatBaseLayoutWidth = 1

    view.contentViewport = CreateFrame("Frame", nil, view)
    view.contentViewport:SetPoint("TOPLEFT", FLOAT_BODY_SIDE_INSET, -FLOAT_BODY_TOP_INSET)
    view.contentViewport:SetPoint("TOPRIGHT", -FLOAT_BODY_SIDE_INSET, -FLOAT_BODY_TOP_INSET)
    view.contentViewport:SetPoint("BOTTOMLEFT", FLOAT_BODY_SIDE_INSET, FLOAT_BODY_BOTTOM_INSET)
    view.contentViewport:SetPoint("BOTTOMRIGHT", -FLOAT_BODY_SIDE_INSET, FLOAT_BODY_BOTTOM_INSET)
    if view.contentViewport.SetClipsChildren then
        view.contentViewport:SetClipsChildren(true)
    end

    view.bodyFrame = CreateFrame("Frame", nil, view.contentViewport)
    view.bodyFrame:SetAllPoints()

    local scrollFrameSerial = NextNoteBodyScrollFrameSerial()
    view.bodyScrollFrameName = "SnailNotesFloatScrollFrame" .. tostring(scrollFrameSerial)
    view.bodyScrollFrame = CreateFrame("ScrollFrame", view.bodyScrollFrameName, view.bodyFrame, "UIPanelScrollFrameTemplate")
    view.bodyScrollBar = _G[view.bodyScrollFrameName .. "ScrollBar"]
    ClearScrollFrameTemplateRegions(view.bodyScrollFrame)
    if view.bodyScrollBar then
        view.bodyScrollBar:Hide()
        view.bodyScrollBar:EnableMouse(false)
        view.bodyScrollBar:SetAlpha(0)
    end

    view.bodyContent = CreateFrame("Frame", nil, view.bodyScrollFrame)
    view.bodyContent:SetPoint("TOPLEFT", view.bodyScrollFrame, "TOPLEFT", 0, 0)
    if view.bodyContent.SetClipsChildren then
        view.bodyContent:SetClipsChildren(true)
    end

    view.contentScaleRoot = CreateFrame("Frame", nil, view.bodyContent)
    view.contentScaleRoot:SetPoint("TOPLEFT", view.bodyContent, "TOPLEFT", 0, 0)
    view.bodyRenderRoot = view.contentScaleRoot
    view.bodyLines = {}

    view.bodyScrollFrame:SetScrollChild(view.bodyContent)
    view.bodyScrollFrame:EnableMouse(true)
    if view.bodyScrollFrame.EnableMouseWheel then
        view.bodyScrollFrame:EnableMouseWheel(true)
    end
    view.bodyScrollFrame:SetScript("OnMouseWheel", function(selfFrame, delta)
        ApplyNotesMouseWheelScroll(selfFrame, delta)
    end)
    view.bodyScrollFrame:SetScript("OnScrollRangeChanged", function()
        if module.ApplyPendingFloatReadViewScrollRestore then
            module:ApplyPendingFloatReadViewScrollRestore(view)
        end
    end)

    view.settingsButton = CreateFrame("Button", nil, view)
    view.settingsButton:SetPoint("BOTTOMLEFT", view, "BOTTOMLEFT", FLOAT_SETTINGS_BUTTON_LEFT, FLOAT_SETTINGS_BUTTON_BOTTOM)
    view.settingsButton:SetSize(100, 14)
    view.settingsButton.text = view.settingsButton:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    view.settingsButton.text:SetAllPoints()
    view.settingsButton.text:SetJustifyH("LEFT")
    view.settingsButton.text:SetTextColor(unpack(FLOAT_SETTINGS_TEXT_COLOR))
    view.settingsButton:SetScript("OnEnter", function(selfButton)
        selfButton.text:SetTextColor(unpack(FLOAT_SETTINGS_TEXT_HOVER))
    end)
    view.settingsButton:SetScript("OnLeave", function(selfButton)
        selfButton.text:SetTextColor(unpack(FLOAT_SETTINGS_TEXT_COLOR))
    end)
    view.settingsButton:SetScript("OnClick", function()
        if view.noteId then
            module:OpenNoteInEditMode(view.noteId)
        end
    end)

    view.contentViewport:SetScript("OnSizeChanged", function()
        if view.currentBodyText ~= nil then
            module:RefreshFloatReadView(view, view.currentBodyText, true)
        else
            module:UpdateFloatReadViewLayout(view)
        end
    end)

    module:UpdateFloatRenderSettings(view)
    return view
end
