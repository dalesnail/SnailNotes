local _, ns = ...
local shared = ns.NotesShared
local module = shared and shared.module
if not shared or not module then return end

local helpers = shared.helpers or {}
local CreateBackdropFrame = helpers.CreateBackdropFrame
local GetSafeWindowScreenBounds = helpers.GetSafeWindowScreenBounds

local REMINDER_TRIGGERS = {
    mail = true,
    auction = true,
    bank = true,
    login = true,
    zone = true,
    dungeon = true,
    raid = true,
}
local REMINDER_EVENT_TRIGGERS = {
    MAIL_SHOW = { trigger = "mail", action = "open" },
    BANKFRAME_OPENED = { trigger = "bank", action = "open" },
    AUCTION_HOUSE_SHOW = { trigger = "auction", action = "open" },
    AUCTION_HOUSE_CLOSED = { trigger = "auction", action = "close" },
}
local REMINDER_INTERACTION_HIDE_TRIGGERS = {
    [17] = "mail",
    [8] = "bank",
    [21] = "auction",
}
local REMINDER_EVENTS = {
    "MAIL_SHOW",
    "PLAYER_INTERACTION_MANAGER_FRAME_HIDE",
    "BANKFRAME_OPENED",
    "AUCTION_HOUSE_SHOW",
    "AUCTION_HOUSE_CLOSED",
    "PLAYER_ENTERING_WORLD",
    "ZONE_CHANGED",
    "ZONE_CHANGED_NEW_AREA",
    "ZONE_CHANGED_INDOORS",
}

local activeReminderBlocksByTrigger = {
    mail = {},
    auction = {},
    bank = {},
    login = {},
    zone = {},
    dungeon = {},
    raid = {},
}
local dismissedReminderLocationContexts = {
    zone = {},
    dungeon = {},
    raid = {},
}
local lastReminderPayload = nil
local reminderEventsRegistered = false
local loginReminderTriggered = false
local reminderOpenTokens = {
    mail = 0,
    auction = 0,
    bank = 0,
    login = 0,
    zone = 0,
    dungeon = 0,
    raid = 0,
}
local REMINDER_CLOSE_DEBOUNCE = 0.08
local REMINDER_FLOAT_DEFAULT_WIDTH = 420
local REMINDER_FLOAT_DEFAULT_HEIGHT = 300
local REMINDER_FLOAT_MIN_WIDTH = 260
local REMINDER_FLOAT_MIN_HEIGHT = 180
local REMINDER_FLOAT_BORDER_OUTSET = 2
local REMINDER_FLOAT_BORDER_COLOR = { 1, 1, 1, 1 }
local REMINDER_FLOAT_RESIZE_GRIP_SIZE = 14
local REMINDER_FLOAT_RESIZE_GRIP_ALPHA = 0.78
local REMINDER_FLOAT_RESIZE_GRIP_HOVER_ALPHA = 1.0
local REMINDER_DONE_FLAG = "done"
local REMINDER_TEST_BLOCKS = {
    {
        trigger = "mail",
        noteTitle = "Example Note Title",
        contentLines = {
            { text = "Mail Reminder" },
            { text = "- [] Test task" },
            { text = "- [] Another task" },
        },
    },
    {
        trigger = "bank",
        noteTitle = "Another Note",
        contentLines = {
            { text = "Bank Reminder" },
            { text = "- [] Deposit cloth" },
        },
    },
}

local function NormalizeLineEndings(text)
    local normalizedText = tostring(text or "")
    normalizedText = string.gsub(normalizedText, "\r\n", "\n")
    normalizedText = string.gsub(normalizedText, "\r", "\n")
    return normalizedText
end

local function IsReminderTrigger(trigger)
    return REMINDER_TRIGGERS[tostring(trigger or ""):lower()] == true
end

local function NormalizeReminderTrigger(trigger)
    local normalizedTrigger = tostring(trigger or ""):lower()
    if IsReminderTrigger(normalizedTrigger) then
        return normalizedTrigger
    end

    return nil
end

local function NormalizeReminderCharacterName(characterName)
    local normalizedCharacterName = tostring(characterName or ""):lower()
    if normalizedCharacterName == "" then
        return nil
    end

    return normalizedCharacterName
end

local function NormalizeReminderZoneName(zoneName)
    local normalizedZoneName = tostring(zoneName or ""):lower()
    normalizedZoneName = string.gsub(normalizedZoneName, "^%s+", "")
    normalizedZoneName = string.gsub(normalizedZoneName, "%s+$", "")
    normalizedZoneName = string.gsub(normalizedZoneName, "[%s%-]+", "-")
    normalizedZoneName = string.gsub(normalizedZoneName, "^%-+", "")
    normalizedZoneName = string.gsub(normalizedZoneName, "%-+$", "")
    if normalizedZoneName == "" then
        return nil
    end

    return normalizedZoneName
end

local function ParseReminderTokenTarget(token)
    local tokenText = tostring(token or "")
    local parts = {}
    for part in string.gmatch(tokenText, "([^:]+)") do
        parts[#parts + 1] = part
    end

    local trigger = tostring(parts[1] or tokenText):lower()
    if trigger == "zone" then
        return trigger, NormalizeReminderZoneName(parts[2]), NormalizeReminderCharacterName(parts[3])
    end

    return trigger, nil, NormalizeReminderCharacterName(parts[2])
end

local function GetCurrentReminderCharacterName()
    if UnitName then
        return NormalizeReminderCharacterName(UnitName("player"))
    end

    return nil
end

local function ReminderMatchesCurrentCharacter(reminderBlock)
    local targetCharacter = NormalizeReminderCharacterName(reminderBlock and reminderBlock.character or nil)
    if not targetCharacter then
        return true
    end

    return targetCharacter == GetCurrentReminderCharacterName()
end

local function GetCurrentReminderZoneNames()
    local zoneNames = {}
    if GetZoneText then
        zoneNames[#zoneNames + 1] = NormalizeReminderZoneName(GetZoneText())
    end
    if GetRealZoneText then
        zoneNames[#zoneNames + 1] = NormalizeReminderZoneName(GetRealZoneText())
    end
    if GetSubZoneText then
        zoneNames[#zoneNames + 1] = NormalizeReminderZoneName(GetSubZoneText())
    end
    return zoneNames
end

local function GetCurrentReminderZoneContextKey()
    local realZone = GetRealZoneText and NormalizeReminderZoneName(GetRealZoneText()) or nil
    if realZone then
        return realZone
    end

    local zone = GetZoneText and NormalizeReminderZoneName(GetZoneText()) or nil
    if zone then
        return zone
    end

    return GetSubZoneText and NormalizeReminderZoneName(GetSubZoneText()) or nil
end

local function DoesReminderZoneNameMatch(targetZone, currentZone)
    if not targetZone or not currentZone then
        return false
    end

    if targetZone == currentZone then
        return true
    end

    if string.sub(currentZone, 1, string.len(targetZone) + 1) == targetZone .. "-" then
        return true
    end

    if string.sub(currentZone, -(string.len(targetZone) + 1)) == "-" .. targetZone then
        return true
    end

    return string.find(currentZone, "-" .. targetZone .. "-", 1, true) ~= nil
end

local function ReminderMatchesCurrentZone(reminderBlock)
    local targetZone = NormalizeReminderZoneName(reminderBlock and reminderBlock.zone or nil)
    if not targetZone then
        return tostring(reminderBlock and reminderBlock.trigger or ""):lower() ~= "zone"
    end

    for _, currentZone in ipairs(GetCurrentReminderZoneNames()) do
        if DoesReminderZoneNameMatch(targetZone, currentZone) then
            return true
        end
    end

    return false
end

local function ClearStaleDismissedZoneContexts()
    local dismissedZoneContexts = dismissedReminderLocationContexts.zone
    if not dismissedZoneContexts then
        return
    end

    local currentZoneNames = GetCurrentReminderZoneNames()
    for dismissedContextKey in pairs(dismissedZoneContexts) do
        local stillInDismissedContext = false
        for _, currentZone in ipairs(currentZoneNames) do
            if DoesReminderZoneNameMatch(dismissedContextKey, currentZone) or DoesReminderZoneNameMatch(currentZone, dismissedContextKey) then
                stillInDismissedContext = true
                break
            end
        end

        if not stillInDismissedContext then
            dismissedZoneContexts[dismissedContextKey] = nil
        end
    end
end

local function GetCurrentReminderInstanceContext()
    if not IsInInstance then
        return nil, nil
    end

    local inInstance, instanceType = IsInInstance()
    if not inInstance then
        return nil, nil
    end

    local instanceName = nil
    if GetInstanceInfo then
        local infoInstanceName, infoInstanceType = GetInstanceInfo()
        instanceName = infoInstanceName
        instanceType = infoInstanceType or instanceType
    end

    local trigger = nil
    if instanceType == "party" then
        trigger = "dungeon"
    elseif instanceType == "raid" then
        trigger = "raid"
    else
        return nil, nil
    end

    local normalizedInstanceName = NormalizeReminderZoneName(instanceName)
    return trigger, trigger .. ":" .. (normalizedInstanceName or "instance")
end

local function ClearStaleDismissedInstanceContexts(activeTrigger, activeContextKey)
    for trigger, dismissedContexts in pairs(dismissedReminderLocationContexts) do
        if trigger == "dungeon" or trigger == "raid" then
            for contextKey in pairs(dismissedContexts or {}) do
                if trigger ~= activeTrigger or contextKey ~= activeContextKey then
                    dismissedContexts[contextKey] = nil
                end
            end
        end
    end
end

local function ParseReminderOpeningTagText(tagText)
    local innerText = string.match(tostring(tagText or ""), "^[ \t]*%[!%s+(.+)%][ \t]*$")
    if not innerText then
        return nil
    end

    local tokens = {}
    for token in string.gmatch(innerText, "%S+") do
        tokens[#tokens + 1] = tostring(token):lower()
    end

    local triggerToken, zone, character = ParseReminderTokenTarget(tokens[1])
    local trigger = NormalizeReminderTrigger(triggerToken)
    if not trigger then
        return nil
    end

    local flags = {}
    for index = 2, #tokens do
        flags[tokens[index]] = true
    end

    return trigger, flags, character, zone
end

local function ParseReminderOpeningTagTokens(lineText)
    local innerText = string.match(tostring(lineText or ""), "^[ \t]*%[!%s+(.+)%][ \t]*$")
    if not innerText then
        return nil
    end

    local tokens = {}
    for token in string.gmatch(innerText, "%S+") do
        tokens[#tokens + 1] = token
    end

    local triggerToken, zone, character = ParseReminderTokenTarget(tokens[1])
    local trigger = NormalizeReminderTrigger(triggerToken)
    if not trigger then
        return nil
    end

    local flags = {}
    local flagTokens = {}
    for index = 2, #tokens do
        local flagToken = tostring(tokens[index] or "")
        local normalizedFlag = string.lower(flagToken)
        if normalizedFlag ~= "" then
            flags[normalizedFlag] = true
            flagTokens[#flagTokens + 1] = normalizedFlag
        end
    end

    return trigger, flags, flagTokens, character, zone
end

local function BuildReminderBlockKey(noteId, startLineIndex)
    return tostring(noteId or "") .. ":" .. tostring(startLineIndex or "")
end

local function SplitReminderSourceLines(bodyText)
    local text = NormalizeLineEndings(bodyText)
    local lines = {}
    local textEndsWithNewline = string.sub(text, -1) == "\n"
    local _, newlineCount = string.gsub(text, "\n", "")

    if text == "" then
        return { "" }, false
    end

    for line in string.gmatch(text .. "\n", "(.-)\n") do
        local isArtificialTrailingLine = textEndsWithNewline and #lines == newlineCount
        if not isArtificialTrailingLine then
            lines[#lines + 1] = line
        end
    end

    return lines, textEndsWithNewline
end

local function JoinReminderSourceLines(lines, textEndsWithNewline)
    local bodyText = table.concat(lines or {}, "\n")
    if textEndsWithNewline then
        bodyText = bodyText .. "\n"
    end
    return bodyText
end

local function BuildReminderOpeningTagLine(trigger, flagTokens, shouldBeDone, character, zone)
    local outputTokens = {}
    local normalizedTrigger = NormalizeReminderTrigger(trigger)
    if not normalizedTrigger then
        return nil
    end
    if normalizedTrigger == "zone" then
        local normalizedZone = NormalizeReminderZoneName(zone)
        if not normalizedZone then
            return nil
        end
        outputTokens[1] = normalizedTrigger .. ":" .. normalizedZone .. (NormalizeReminderCharacterName(character) and (":" .. NormalizeReminderCharacterName(character)) or "")
    else
        outputTokens[1] = normalizedTrigger .. (NormalizeReminderCharacterName(character) and (":" .. NormalizeReminderCharacterName(character)) or "")
    end

    local hasDoneFlag = false
    for _, flagToken in ipairs(flagTokens or {}) do
        local normalizedFlag = string.lower(tostring(flagToken or ""))
        if normalizedFlag == REMINDER_DONE_FLAG then
            hasDoneFlag = true
            if shouldBeDone then
                outputTokens[#outputTokens + 1] = REMINDER_DONE_FLAG
            end
        elseif normalizedFlag ~= "" then
            outputTokens[#outputTokens + 1] = flagToken
        end
    end

    if shouldBeDone and not hasDoneFlag then
        outputTokens[#outputTokens + 1] = REMINDER_DONE_FLAG
    end

    return "[! " .. table.concat(outputTokens, " ") .. "]"
end

local function GetReminderOpeningLineTrigger(lineText)
    return ParseReminderOpeningTagText(lineText)
end

local function IsReminderClosingLine(lineText)
    return string.match(tostring(lineText or ""), "^[ \t]*%[!%][ \t]*$") ~= nil
end

local function IsReminderCodeFence(lineText)
    return tostring(lineText or "") == "```"
end

local function FindReminderBlockClose(text, startIndex)
    local closeStart, closeEnd = string.find(text, "%[!%]", startIndex)
    return closeStart, closeEnd
end

local function FindReminderBlockOpen(text, startIndex)
    local openStart, openEnd, tagText = string.find(text, "(%[!%s+[^%]]+%])", startIndex)
    if not openStart then
        return nil
    end

    local trigger, flags, character, zone = ParseReminderOpeningTagText(tagText)
    return openStart, openEnd, trigger, flags, character, zone
end

local function FindSupportedReminderBlockOpen(text, startIndex)
    local searchStart = startIndex
    while searchStart <= string.len(text) do
        local openStart, openEnd, trigger = FindReminderBlockOpen(text, searchStart)
        if not openStart then
            return nil
        end

        if trigger then
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
    local text = NormalizeLineEndings(bodyText)
    local reminders = {}
    local lines = {}
    local sourceLineIndex = 0
    local textEndsWithNewline = string.sub(text, -1) == "\n"
    local _, newlineCount = string.gsub(text, "\n", "")
    local inCodeBlock = false
    local openBlock = nil

    for line in string.gmatch(text .. "\n", "(.-)\n") do
        sourceLineIndex = sourceLineIndex + 1
        local isArtificialTrailingLine = textEndsWithNewline and sourceLineIndex == newlineCount + 1
        if not isArtificialTrailingLine then
            lines[sourceLineIndex] = line

            if IsReminderCodeFence(line) then
                inCodeBlock = not inCodeBlock
            elseif not inCodeBlock then
                if openBlock then
                    if IsReminderClosingLine(line) then
                        local contentLines = BuildSourceLineRecordsForRange(text, openBlock.startLineIndex + 1, sourceLineIndex - 1, noteId)
                        local contentText = {}
                        for _, lineData in ipairs(contentLines) do
                            contentText[#contentText + 1] = lineData.text or ""
                        end
                        reminders[#reminders + 1] = {
                            trigger = openBlock.trigger,
                            content = table.concat(contentText, "\n"),
                            noteTitle = noteTitle,
                            noteId = noteId,
                            startLineIndex = openBlock.startLineIndex,
                            openingTagLine = openBlock.openingTagLine,
                            flags = openBlock.flags or {},
                            character = openBlock.character,
                            zone = openBlock.zone,
                            done = openBlock.flags and openBlock.flags[REMINDER_DONE_FLAG] == true or false,
                            blockKey = BuildReminderBlockKey(noteId, openBlock.startLineIndex),
                            contentLines = contentLines,
                        }
                        openBlock = nil
                    end
                else
                    local trigger, flags, character, zone = ParseReminderOpeningTagText(line)
                    local normalizedTrigger = NormalizeReminderTrigger(trigger)
                    if normalizedTrigger then
                        openBlock = {
                            trigger = normalizedTrigger,
                            flags = flags or {},
                            character = character,
                            zone = zone,
                            startLineIndex = sourceLineIndex,
                            openingTagLine = line,
                        }
                    end
                end
            end
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
            reminderBlockKey = reminderBlock.blockKey,
            reminderDone = reminderBlock.done == true,
        }
    end
end

local function BuildReminderDisplayLines(reminderBlocks)
    local displayLines = {}
    local activeGroupKey = nil
    local blockCount = #(reminderBlocks or {})

    for blockIndex, reminderBlock in ipairs(reminderBlocks or {}) do
        local groupKey = GetReminderNoteGroupKey(reminderBlock)
        local nextReminderBlock = reminderBlocks[blockIndex + 1]
        local nextGroupKey = nextReminderBlock and GetReminderNoteGroupKey(nextReminderBlock) or nil
        if groupKey ~= activeGroupKey then
            displayLines[#displayLines + 1] = {
                text = reminderBlock.noteTitle or "Note",
                sourceLineIndex = nil,
                noteId = reminderBlock.noteId,
                lineType = "reminderNoteTitle",
            }
            activeGroupKey = groupKey
        end

        AppendReminderBlockLines(displayLines, reminderBlock)
        displayLines[#displayLines + 1] = {
            text = reminderBlock.done and "Undo" or "Done",
            sourceLineIndex = nil,
            noteId = reminderBlock.noteId,
            reminderBlockKey = reminderBlock.blockKey,
            reminderDone = reminderBlock.done == true,
            lineType = "reminderDoneAction",
        }
        if blockIndex < blockCount then
            if nextGroupKey and nextGroupKey ~= groupKey then
                displayLines[#displayLines + 1] = {
                    text = "",
                    sourceLineIndex = nil,
                    noteId = nil,
                    lineType = "separator",
                }
            else
                displayLines[#displayLines + 1] = {
                    text = "",
                    sourceLineIndex = nil,
                    noteId = reminderBlock.noteId,
                }
            end
        end
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
        if tostring(reminderBlock and reminderBlock.trigger or ""):lower() == normalizedTrigger
            and ReminderMatchesCurrentCharacter(reminderBlock)
            and ReminderMatchesCurrentZone(reminderBlock)
        then
            matchingBlocks[#matchingBlocks + 1] = reminderBlock
        end
    end

    return matchingBlocks
end

local function CollectAllReminderBlocks(includeDone)
    local reminders = {}

    for _, note in ipairs(module:GetOrderedNotes()) do
        local noteReminders = ParseReminderBlocks(note and note.body or "", note and note.title or nil, note and note.id or nil)
        for _, reminder in ipairs(noteReminders) do
            if (includeDone or not reminder.done)
                and ReminderMatchesCurrentCharacter(reminder)
                and ReminderMatchesCurrentZone(reminder)
            then
                reminders[#reminders + 1] = reminder
            end
        end
    end

    return reminders
end

local function CollectReminderBlocksForTriggerIncludingSessionDone(trigger)
    local normalizedTrigger = tostring(trigger or ""):lower()
    local matchingBlocks = {}
    local activeDoneBlockKeys = {}

    for _, reminderBlock in ipairs(activeReminderBlocksByTrigger[normalizedTrigger] or {}) do
        if reminderBlock and reminderBlock.done and reminderBlock.blockKey then
            activeDoneBlockKeys[reminderBlock.blockKey] = true
        end
    end

    for _, reminderBlock in ipairs(CollectAllReminderBlocks(true)) do
        if tostring(reminderBlock and reminderBlock.trigger or ""):lower() == normalizedTrigger
            and (not reminderBlock.done or activeDoneBlockKeys[reminderBlock.blockKey])
        then
            matchingBlocks[#matchingBlocks + 1] = reminderBlock
        end
    end

    return matchingBlocks
end

local function ApplyStableReminderBlockOrder(trigger, reminderBlocks)
    local normalizedTrigger = tostring(trigger or ""):lower()
    local activeBlocks = activeReminderBlocksByTrigger[normalizedTrigger] or {}
    if #activeBlocks == 0 or not reminderBlocks or #reminderBlocks <= 1 then
        return reminderBlocks
    end

    local refreshedByKey = {}
    for _, reminderBlock in ipairs(reminderBlocks) do
        if reminderBlock and reminderBlock.blockKey then
            refreshedByKey[reminderBlock.blockKey] = reminderBlock
        end
    end

    local orderedBlocks = {}
    local usedBlockKeys = {}
    for _, activeBlock in ipairs(activeBlocks) do
        local blockKey = activeBlock and activeBlock.blockKey or nil
        local refreshedBlock = blockKey and refreshedByKey[blockKey] or nil
        if refreshedBlock then
            orderedBlocks[#orderedBlocks + 1] = refreshedBlock
            usedBlockKeys[blockKey] = true
        end
    end

    for _, reminderBlock in ipairs(reminderBlocks) do
        local blockKey = reminderBlock and reminderBlock.blockKey or nil
        if not blockKey or not usedBlockKeys[blockKey] then
            orderedBlocks[#orderedBlocks + 1] = reminderBlock
        end
    end

    return orderedBlocks
end

local function BuildReminderPayloadSignature(reminderBlocks)
    local signatureParts = {}
    for _, reminderBlock in ipairs(reminderBlocks or {}) do
        signatureParts[#signatureParts + 1] = table.concat({
            tostring(reminderBlock and reminderBlock.blockKey or ""),
            reminderBlock and reminderBlock.done and "done" or "active",
        }, ":")
    end
    return table.concat(signatureParts, "|")
end

local function IsReminderFloatShowingTrigger(trigger)
    local frame = module.runtime and module.runtime.reminderFloatWindow or nil
    return frame and frame:IsShown() and frame.reminderTrigger == tostring(trigger or ""):lower()
end

local function SetActiveReminderBlockDoneState(blockKey, isDone)
    if not blockKey then
        return
    end

    for _, reminderBlocks in pairs(activeReminderBlocksByTrigger) do
        for _, reminderBlock in ipairs(reminderBlocks or {}) do
            if reminderBlock and reminderBlock.blockKey == blockKey then
                reminderBlock.done = isDone == true
                reminderBlock.flags = reminderBlock.flags or {}
                reminderBlock.flags[REMINDER_DONE_FLAG] = reminderBlock.done or nil
            end
        end
    end
end

local function SyncUpdatedReminderNote(note)
    if not note then
        return
    end

    local tab = module.GetOpenTabForNoteId and module:GetOpenTabForNoteId(note.id) or nil
    if tab then
        tab.noteData = tab.noteData or {}
        tab.noteData.body = note.body
        tab.noteData.updatedAt = note.updatedAt
        tab.noteData.title = note.title
        tab.noteData.createdAt = note.createdAt

        local editView = module.GetNoteTabEditView and module:GetNoteTabEditView(tab.panel) or nil
        if editView and editView.bodyInput then
            local previousCursorPosition = editView.bodyInput.GetCursorPosition and editView.bodyInput:GetCursorPosition() or nil
            local previousScrollOffset = editView.bodyScrollFrame and editView.bodyScrollFrame:GetVerticalScroll() or nil
            if tab.panel then
                tab.panel.isLoadingView = true
            end
            editView.bodyInput:SetText(note.body or "")
            if previousCursorPosition and editView.bodyInput.SetCursorPosition then
                editView.bodyInput:SetCursorPosition(math.max(math.min(previousCursorPosition, string.len(note.body or "")), 0))
            end
            if previousScrollOffset ~= nil and editView.bodyScrollFrame and editView.bodyScrollFrame.GetVerticalScrollRange then
                local maxScroll = math.max(editView.bodyScrollFrame:GetVerticalScrollRange() or 0, 0)
                editView.bodyScrollFrame:SetVerticalScroll(math.max(0, math.min(previousScrollOffset, maxScroll)))
            end
            if tab.panel then
                tab.panel.isLoadingView = false
            end
            if module.UpdateNoteBodyEditLayout then
                module:UpdateNoteBodyEditLayout(tab)
            end
        end

        if module.SetNoteTabDirty then
            module:SetNoteTabDirty(tab, false)
        end
        if module.RefreshNoteReadView then
            module:RefreshNoteReadView(tab, true)
        end
        if module.RefreshSavedNoteReferences then
            module:RefreshSavedNoteReferences(tab)
        end
    else
        if module.RefreshHomeList then
            module:RefreshHomeList()
        end
        if module.RefreshRowActionMenu then
            module:RefreshRowActionMenu()
        end
        if module.RefreshFloatWindow then
            module:RefreshFloatWindow()
        end
    end
end

local function SetReminderBlockDoneInSource(noteId, startLineIndex, isDone)
    if not noteId or not startLineIndex or not module.GetNoteById then
        return false
    end

    if module.IsBuiltinNoteId and module:IsBuiltinNoteId(noteId) then
        return false
    end

    local note = module:GetNoteById(noteId)
    if not note then
        return false
    end

    local tab = module.GetOpenTabForNoteId and module:GetOpenTabForNoteId(noteId) or nil
    local workingBody = nil
    if tab and module.GetNoteTabWorkingValues then
        local _, tabBody = module:GetNoteTabWorkingValues(tab)
        workingBody = tabBody
    end
    local sourceBody = workingBody or note.body or ""
    local lines, textEndsWithNewline = SplitReminderSourceLines(sourceBody)
    local lineIndex = tonumber(startLineIndex)
    local openingLine = lineIndex and lines[lineIndex] or nil
    if not openingLine then
        return false
    end

    local trigger, _, flagTokens, character, zone = ParseReminderOpeningTagTokens(openingLine)
    if not trigger then
        return false
    end

    local updatedOpeningLine = BuildReminderOpeningTagLine(trigger, flagTokens, isDone == true, character, zone)
    if not updatedOpeningLine or updatedOpeningLine == openingLine then
        return false
    end

    lines[lineIndex] = updatedOpeningLine
    local updatedBody = JoinReminderSourceLines(lines, textEndsWithNewline)

    if tab then
        tab.noteData = tab.noteData or {}
        tab.noteData.body = updatedBody
        local editView = module.GetNoteTabEditView and module:GetNoteTabEditView(tab.panel) or nil
        if editView and editView.bodyInput then
            local previousCursorPosition = editView.bodyInput.GetCursorPosition and editView.bodyInput:GetCursorPosition() or nil
            local previousScrollOffset = editView.bodyScrollFrame and editView.bodyScrollFrame:GetVerticalScroll() or nil
            if tab.panel then
                tab.panel.isLoadingView = true
            end
            editView.bodyInput:SetText(updatedBody)
            if previousCursorPosition and editView.bodyInput.SetCursorPosition then
                editView.bodyInput:SetCursorPosition(math.max(math.min(previousCursorPosition, string.len(updatedBody)), 0))
            end
            if previousScrollOffset ~= nil and editView.bodyScrollFrame and editView.bodyScrollFrame.GetVerticalScrollRange then
                local maxScroll = math.max(editView.bodyScrollFrame:GetVerticalScrollRange() or 0, 0)
                editView.bodyScrollFrame:SetVerticalScroll(math.max(0, math.min(previousScrollOffset, maxScroll)))
            end
            if tab.panel then
                tab.panel.isLoadingView = false
            end
            if module.UpdateNoteBodyEditLayout then
                module:UpdateNoteBodyEditLayout(tab)
            end
        end

        if module.SaveNoteTabInternal then
            return module:SaveNoteTabInternal(tab, {
                allowBlankTitle = true,
                keepEditMode = module.IsNoteTabInEditMode and module:IsNoteTabInEditMode(tab) or false,
                preserveReadScroll = true,
            })
        end
    end

    note.body = updatedBody
    note.updatedAt = time()
    note.createdAt = note.createdAt or note.updatedAt
    SyncUpdatedReminderNote(note)
    return true
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

local ApplyReminderFloatBackground

local function ClampReminderFloatSize(width, height)
    width = tonumber(width) or REMINDER_FLOAT_DEFAULT_WIDTH
    height = tonumber(height) or REMINDER_FLOAT_DEFAULT_HEIGHT
    local maxWidth, maxHeight = REMINDER_FLOAT_DEFAULT_WIDTH, REMINDER_FLOAT_DEFAULT_HEIGHT
    if GetSafeWindowScreenBounds then
        maxWidth, maxHeight = GetSafeWindowScreenBounds()
    elseif UIParent then
        maxWidth, maxHeight = UIParent:GetWidth(), UIParent:GetHeight()
    end

    width = math.max(REMINDER_FLOAT_MIN_WIDTH, math.min(math.floor(width + 0.5), maxWidth or REMINDER_FLOAT_DEFAULT_WIDTH))
    height = math.max(REMINDER_FLOAT_MIN_HEIGHT, math.min(math.floor(height + 0.5), maxHeight or REMINDER_FLOAT_DEFAULT_HEIGHT))
    return width, height
end

function module:GetReminderWindowSettings()
    local windowSettings = self:GetWindowSettings()
    windowSettings.reminder = windowSettings.reminder or {}
    local reminderSettings = windowSettings.reminder
    reminderSettings.width = tonumber(reminderSettings.width) or REMINDER_FLOAT_DEFAULT_WIDTH
    reminderSettings.height = tonumber(reminderSettings.height) or REMINDER_FLOAT_DEFAULT_HEIGHT
    reminderSettings.point = reminderSettings.point or "CENTER"
    reminderSettings.relativePoint = reminderSettings.relativePoint or reminderSettings.point or "CENTER"
    reminderSettings.x = tonumber(reminderSettings.x) or 260
    reminderSettings.y = tonumber(reminderSettings.y) or 120
    if reminderSettings.showTextures == nil then
        reminderSettings.showTextures = true
    else
        reminderSettings.showTextures = reminderSettings.showTextures == true
    end
    if reminderSettings.showBorder == nil then
        reminderSettings.showBorder = true
    else
        reminderSettings.showBorder = reminderSettings.showBorder == true
    end
    reminderSettings.fontScale = math.max(0.7, math.min(tonumber(reminderSettings.fontScale) or 0.85, 2.0))
    reminderSettings.backgroundAlpha = math.max(0, math.min(tonumber(reminderSettings.backgroundAlpha) or 0.65, 1))
    return reminderSettings
end

function module:IsReminderTexturesEnabled()
    return self:GetReminderWindowSettings().showTextures ~= false
end

function module:SetReminderTexturesEnabled(enabled)
    local settings = self:GetReminderWindowSettings()
    local normalizedEnabled = enabled == true
    if settings.showTextures == normalizedEnabled then
        return
    end

    settings.showTextures = normalizedEnabled
    self:RefreshReminderFloatWindow(true)
end

function module:IsReminderBorderEnabled()
    return self:GetReminderWindowSettings().showBorder == true
end

function module:SetReminderBorderEnabled(enabled)
    local settings = self:GetReminderWindowSettings()
    local normalizedEnabled = enabled == true
    if settings.showBorder == normalizedEnabled then
        return
    end

    settings.showBorder = normalizedEnabled
    local frame = self.runtime and self.runtime.reminderFloatWindow or nil
    if frame and frame.borderFrame then
        frame.borderFrame:SetShown(normalizedEnabled)
    end
end

function module:GetReminderFontScale()
    return self:GetReminderWindowSettings().fontScale or 0.85
end

function module:SetReminderFontScale(scale)
    local settings = self:GetReminderWindowSettings()
    local normalizedScale = math.max(0.7, math.min(tonumber(scale) or 0.85, 2.0))
    if math.abs((settings.fontScale or 0.85) - normalizedScale) < 0.001 then
        return
    end

    settings.fontScale = normalizedScale
    self:RefreshReminderFloatWindow()
end

function module:GetReminderBackgroundAlpha()
    return self:GetReminderWindowSettings().backgroundAlpha or 0.65
end

function module:SetReminderBackgroundAlpha(alpha)
    local settings = self:GetReminderWindowSettings()
    local normalizedAlpha = math.max(0, math.min(tonumber(alpha) or 0.65, 1))
    if math.abs((settings.backgroundAlpha or 0.65) - normalizedAlpha) < 0.001 then
        return
    end

    settings.backgroundAlpha = normalizedAlpha
    local frame = self.runtime and self.runtime.reminderFloatWindow or nil
    if frame then
        ApplyReminderFloatBackground(frame)
    end
end

function module:SaveReminderWindowGeometry(frame)
    if not frame then
        return
    end

    local settings = self:GetReminderWindowSettings()
    settings.width, settings.height = ClampReminderFloatSize(frame:GetWidth(), frame:GetHeight())
    local point, _, relativePoint, x, y = frame:GetPoint(1)
    settings.point = point or "CENTER"
    settings.relativePoint = relativePoint or settings.point or "CENTER"
    settings.x = x or 0
    settings.y = y or 0
end

function module:ApplyReminderWindowGeometry(frame)
    if not frame then
        return
    end

    local settings = self:GetReminderWindowSettings()
    local width, height = ClampReminderFloatSize(settings.width, settings.height)
    if frame.SetResizeBounds then
        local maxWidth, maxHeight = width, height
        if GetSafeWindowScreenBounds then
            maxWidth, maxHeight = GetSafeWindowScreenBounds()
        elseif UIParent then
            maxWidth, maxHeight = UIParent:GetWidth(), UIParent:GetHeight()
        end
        frame:SetResizeBounds(REMINDER_FLOAT_MIN_WIDTH, REMINDER_FLOAT_MIN_HEIGHT, maxWidth, maxHeight)
    elseif frame.SetMinResize then
        frame:SetMinResize(REMINDER_FLOAT_MIN_WIDTH, REMINDER_FLOAT_MIN_HEIGHT)
    end
    frame:SetSize(width, height)
    frame:ClearAllPoints()
    frame:SetPoint(settings.point or "CENTER", UIParent, settings.relativePoint or settings.point or "CENTER", settings.x or 0, settings.y or 0)
end

local function ApplyReminderFloatGeometry(frame)
    if not frame then
        return
    end

    module:ApplyReminderWindowGeometry(frame)
end

local function SetReminderWindowEditorMode(frame, isEditorPreview)
    if not frame then
        return
    end

    frame.isEditorPreview = isEditorPreview == true
    if frame.SetMovable then
        frame:SetMovable(frame.isEditorPreview)
    end
    if frame.SetResizable then
        frame:SetResizable(frame.isEditorPreview)
    end
    if frame.resizeGrip then
        frame.resizeGrip:SetShown(frame.isEditorPreview)
        frame.resizeGrip:EnableMouse(frame.isEditorPreview)
    end
end

ApplyReminderFloatBackground = function(frame)
    if not frame or not frame.background then
        return
    end

    local alpha = module.GetReminderBackgroundAlpha and module:GetReminderBackgroundAlpha() or 0.65
    frame.background:SetVertexColor(0, 0, 0, alpha)
end

local function ScheduleReminderTimer(delaySeconds, callback)
    if C_Timer and C_Timer.After then
        C_Timer.After(delaySeconds, callback)
    elseif module.ScheduleTimer then
        module:ScheduleTimer(callback, delaySeconds)
    else
        callback()
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
    local inCodeBlock = false

    for line in string.gmatch(text .. "\n", "(.-)\n") do
        sourceLineIndex = sourceLineIndex + 1
        local isArtificialTrailingLine = textEndsWithNewline and sourceLineIndex == newlineCount + 1
        local isMarkerLine = not inCodeBlock and (GetReminderOpeningLineTrigger(line) or IsReminderClosingLine(line))

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

        if not isArtificialTrailingLine and IsReminderCodeFence(line) then
            inCodeBlock = not inCodeBlock
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
            if not reminder.done
                and ReminderMatchesCurrentCharacter(reminder)
                and ReminderMatchesCurrentZone(reminder)
            then
                reminders[#reminders + 1] = reminder
            end
        end
    end

    return reminders
end

function module:BuildReminderDisplayLines(reminderBlocks)
    return BuildReminderDisplayLines(reminderBlocks)
end

function module:SetReminderBlockDone(blockKey, isDone)
    if not blockKey then
        return false
    end

    local targetBlock = nil
    for _, reminderBlocks in pairs(activeReminderBlocksByTrigger) do
        for _, reminderBlock in ipairs(reminderBlocks or {}) do
            if reminderBlock and reminderBlock.blockKey == blockKey then
                targetBlock = reminderBlock
                break
            end
        end
        if targetBlock then
            break
        end
    end

    if not targetBlock then
        return false
    end

    local updated = SetReminderBlockDoneInSource(targetBlock.noteId, targetBlock.startLineIndex, isDone == true)
    if not updated then
        return false
    end

    SetActiveReminderBlockDoneState(blockKey, isDone == true)
    self:RefreshReminderFloatWindow(true)
    return true
end

function module:CreateReminderFloatWindow()
    self:EnsureRuntime()
    if self.runtime.reminderFloatWindow then
        return self.runtime.reminderFloatWindow
    end

    local frame = CreateFrame("Frame", "SnailNotesReminderFloatFrame", UIParent)
    frame:SetFrameStrata("DIALOG")
    if frame.SetClampedToScreen then
        frame:SetClampedToScreen(true)
    end
    frame:EnableMouse(true)
    if frame.SetMovable then
        frame:SetMovable(true)
    end
    if frame.SetResizable then
        frame:SetResizable(true)
    end
    if frame.RegisterForDrag then
        frame:RegisterForDrag("LeftButton")
    end
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

    if CreateBackdropFrame then
        frame.borderFrame = CreateBackdropFrame(frame, false)
        frame.borderFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", -REMINDER_FLOAT_BORDER_OUTSET, REMINDER_FLOAT_BORDER_OUTSET)
        frame.borderFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", REMINDER_FLOAT_BORDER_OUTSET, -REMINDER_FLOAT_BORDER_OUTSET)
        frame.borderFrame:EnableMouse(false)
        if frame.borderFrame.SetBackdropBorderColor then
            frame.borderFrame:SetBackdropBorderColor(unpack(REMINDER_FLOAT_BORDER_COLOR))
        end
        if frame.borderFrame.SetBackdropColor then
            frame.borderFrame:SetBackdropColor(0, 0, 0, 0)
        end
        frame.borderFrame:SetShown(self:IsReminderBorderEnabled())
    end

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
        if module.HandleReminderFloatManualClose then
            module:HandleReminderFloatManualClose(frame)
        end
        frame:Hide()
    end)

    frame.contentHost = CreateFrame("Frame", nil, frame)
    frame.contentHost:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -24)
    frame.contentHost:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
    frame.readView = self:CreateFloatRenderContentView(frame.contentHost)
    frame.readView.isReminderView = true

    frame.resizeGrip = CreateFrame("Button", nil, frame)
    frame.resizeGrip:SetSize(REMINDER_FLOAT_RESIZE_GRIP_SIZE, REMINDER_FLOAT_RESIZE_GRIP_SIZE)
    frame.resizeGrip:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
    frame.resizeGrip.texture = frame.resizeGrip:CreateTexture(nil, "ARTWORK")
    frame.resizeGrip.texture:SetAllPoints()
    frame.resizeGrip.texture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    frame.resizeGrip.texture:SetAlpha(REMINDER_FLOAT_RESIZE_GRIP_ALPHA)
    frame.resizeGrip:RegisterForDrag("LeftButton")
    frame.resizeGrip:SetScript("OnEnter", function(selfButton)
        if selfButton.texture then
            selfButton.texture:SetAlpha(REMINDER_FLOAT_RESIZE_GRIP_HOVER_ALPHA)
        end
    end)
    frame.resizeGrip:SetScript("OnLeave", function(selfButton)
        if selfButton.texture then
            selfButton.texture:SetAlpha(REMINDER_FLOAT_RESIZE_GRIP_ALPHA)
        end
    end)
    frame.resizeGrip:SetScript("OnDragStart", function()
        if not frame.isEditorPreview then
            return
        end
        frame.isSizingByGrip = true
        if frame.StartSizing then
            frame:StartSizing("BOTTOMRIGHT")
        end
    end)
    frame.resizeGrip:SetScript("OnDragStop", function()
        if frame.isSizingByGrip and frame.StopMovingOrSizing then
            frame:StopMovingOrSizing()
        end
        frame.isSizingByGrip = nil
        module:SaveReminderWindowGeometry(frame)
    end)
    frame.resizeGrip:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" and frame.isEditorPreview and frame.isSizingByGrip and frame.StopMovingOrSizing then
            frame:StopMovingOrSizing()
            frame.isSizingByGrip = nil
            module:SaveReminderWindowGeometry(frame)
        end
    end)

    frame:SetScript("OnDragStart", function(selfFrame)
        if not selfFrame.isEditorPreview then
            return
        end
        if selfFrame.StartMoving then
            selfFrame:StartMoving()
            selfFrame.isMovingByDrag = true
        end
    end)
    frame:SetScript("OnDragStop", function(selfFrame)
        if selfFrame.isMovingByDrag and selfFrame.StopMovingOrSizing then
            selfFrame:StopMovingOrSizing()
        end
        selfFrame.isMovingByDrag = nil
        if selfFrame.isEditorPreview then
            module:SaveReminderWindowGeometry(selfFrame)
        end
    end)
    frame:SetScript("OnHide", function(selfFrame)
        if selfFrame.isEditorPreview then
            module:SaveReminderWindowGeometry(selfFrame)
        end
        selfFrame.reminderTrigger = nil
        selfFrame.reminderContextKey = nil
        selfFrame.isReminderTest = nil
        selfFrame.isEditorPreview = nil
        selfFrame.isSizingByGrip = nil
        selfFrame.isMovingByDrag = nil
        if selfFrame.readView then
            selfFrame.readView.currentBodyText = nil
            selfFrame.readView.noteId = nil
            selfFrame.readView.ownerTab = nil
        end
    end)
    frame:SetScript("OnSizeChanged", function(selfFrame)
        if selfFrame.enforcingReminderSize then
            return
        end
        local width, height = ClampReminderFloatSize(selfFrame:GetWidth(), selfFrame:GetHeight())
        if math.abs((selfFrame:GetWidth() or width) - width) > 0.5 or math.abs((selfFrame:GetHeight() or height) - height) > 0.5 then
            selfFrame.enforcingReminderSize = true
            selfFrame:SetSize(width, height)
            selfFrame.enforcingReminderSize = nil
            return
        end
        if selfFrame.isEditorPreview then
            module:SaveReminderWindowGeometry(selfFrame)
        end
        if selfFrame.readView and selfFrame.readView.currentBodyText ~= nil then
            module:RefreshFloatReadView(selfFrame.readView, selfFrame.readView.currentBodyText, true)
        end
    end)
    frame:SetScript("OnShow", function(selfFrame)
        module:ApplyReminderWindowGeometry(selfFrame)
        SetReminderWindowEditorMode(selfFrame, selfFrame.isEditorPreview)
        ApplyReminderFloatBackground(selfFrame)
        if selfFrame.borderFrame then
            selfFrame.borderFrame:SetShown(module:IsReminderBorderEnabled())
        end
        if selfFrame.readView then
            module:UpdateFloatRenderSettings(selfFrame.readView)
        end
    end)

    SetReminderWindowEditorMode(frame, false)

    self.runtime.reminderFloatWindow = frame
    return frame
end

function module:ShowReminderFloat(trigger, reminderBlocks, preserveScroll, contextKey)
    if not reminderBlocks or #reminderBlocks == 0 then
        return false
    end

    local frame = self:CreateReminderFloatWindow()
    if not frame or not frame.readView then
        return false
    end

    local displayLines = BuildReminderDisplayLines(reminderBlocks)
    frame.reminderTrigger = tostring(trigger or ""):lower()
    frame.reminderContextKey = contextKey
    frame.isReminderTest = nil
    frame.isEditorPreview = nil
    SetReminderWindowEditorMode(frame, false)
    if frame.titleText then
        frame.titleText:SetText(string.format("%s reminders", frame.reminderTrigger))
    end
    ApplyReminderFloatBackground(frame)
    frame:Show()
    frame.readView.noteId = nil
    frame.readView.ownerTab = nil
    self:RefreshFloatReadView(frame.readView, displayLines, preserveScroll == true)
    return true
end

function module:ShowReminderTestWindow()
    local frame = self:CreateReminderFloatWindow()
    if not frame or not frame.readView then
        return false
    end

    frame.reminderTrigger = "test"
    frame.isReminderTest = true
    frame.isEditorPreview = true
    SetReminderWindowEditorMode(frame, true)
    if frame.titleText then
        frame.titleText:SetText("Reminder Test")
    end
    ApplyReminderFloatBackground(frame)
    if frame.borderFrame then
        frame.borderFrame:SetShown(self:IsReminderBorderEnabled())
    end
    frame:Show()
    frame.readView.noteId = nil
    frame.readView.ownerTab = nil
    self:RefreshFloatReadView(frame.readView, BuildReminderDisplayLines(REMINDER_TEST_BLOCKS), false)
    return true
end

function module:ToggleReminderTestWindow()
    local frame = self.runtime and self.runtime.reminderFloatWindow or nil
    if frame and frame:IsShown() and frame.isReminderTest then
        frame:Hide()
        return false
    end

    return self:ShowReminderTestWindow()
end

function module:HideReminderEditWindow()
    local frame = self.runtime and self.runtime.reminderFloatWindow or nil
    if frame and frame:IsShown() and frame.isEditorPreview then
        frame:Hide()
    end
end

function module:HandleReminderFloatManualClose(frame)
    if not frame or frame.isEditorPreview or frame.isReminderTest then
        return
    end

    if (frame.reminderTrigger == "zone" or frame.reminderTrigger == "dungeon" or frame.reminderTrigger == "raid") and frame.reminderContextKey then
        dismissedReminderLocationContexts[frame.reminderTrigger] = dismissedReminderLocationContexts[frame.reminderTrigger] or {}
        dismissedReminderLocationContexts[frame.reminderTrigger][frame.reminderContextKey] = true
        ClearActiveReminderBlocks(frame.reminderTrigger)
    end
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

function module:ScheduleReminderClose(trigger, source)
    local normalizedTrigger = NormalizeReminderTrigger(trigger)
    if not normalizedTrigger or normalizedTrigger == "login" then
        return
    end

    local closeToken = reminderOpenTokens[normalizedTrigger] or 0
    local function runCloseCheck()
        local runToken = reminderOpenTokens[normalizedTrigger] or 0
        if runToken ~= closeToken then
            return
        end

        ClearActiveReminderBlocks(normalizedTrigger)
        module:HideReminderFloat(normalizedTrigger)
    end

    ScheduleReminderTimer(REMINDER_CLOSE_DEBOUNCE, runCloseCheck)
end

function module:RefreshReminderFloatWindow(preserveScroll)
    local frame = self.runtime and self.runtime.reminderFloatWindow or nil
    if not frame or not frame:IsShown() or not frame.reminderTrigger then
        return
    end

    if frame.isReminderTest then
        self:ShowReminderTestWindow()
        return
    end

    local matchingBlocks = ApplyStableReminderBlockOrder(
        frame.reminderTrigger,
        CollectReminderBlocksForTriggerIncludingSessionDone(frame.reminderTrigger)
    )
    SetActiveReminderBlocks(frame.reminderTrigger, matchingBlocks)
    if #matchingBlocks == 0 then
        frame:Hide()
        return
    end

    self:ShowReminderFloat(frame.reminderTrigger, matchingBlocks, preserveScroll == true, frame.reminderContextKey)
end

function module:HandleReminderTriggerOpen(trigger)
    local normalizedTrigger = NormalizeReminderTrigger(trigger)
    if not normalizedTrigger then
        return {}
    end

    reminderOpenTokens[normalizedTrigger] = (reminderOpenTokens[normalizedTrigger] or 0) + 1

    local matchingBlocks = CollectReminderBlocksForTrigger(normalizedTrigger)
    SetActiveReminderBlocks(normalizedTrigger, matchingBlocks)
    if #matchingBlocks > 0 then
        self:ShowReminderFloat(normalizedTrigger, matchingBlocks)
    else
        self:HideReminderFloat(normalizedTrigger)
    end

    return matchingBlocks
end

function module:HandleReminderTriggerClose(trigger)
    local normalizedTrigger = NormalizeReminderTrigger(trigger)
    if not normalizedTrigger then
        return
    end

    self:ScheduleReminderClose(normalizedTrigger, "event")
end

function module:HandleZoneReminderLocationChanged()
    ClearStaleDismissedZoneContexts()
    local zoneContextKey = GetCurrentReminderZoneContextKey()
    local matchingBlocks = ApplyStableReminderBlockOrder("zone", CollectReminderBlocksForTriggerIncludingSessionDone("zone"))
    if #matchingBlocks == 0 then
        ClearActiveReminderBlocks("zone")
        self:HideReminderFloat("zone")
        return {}
    end

    if zoneContextKey and dismissedReminderLocationContexts.zone[zoneContextKey] then
        ClearActiveReminderBlocks("zone")
        self:HideReminderFloat("zone")
        return matchingBlocks
    end

    local currentSignature = BuildReminderPayloadSignature(activeReminderBlocksByTrigger.zone)
    local nextSignature = BuildReminderPayloadSignature(matchingBlocks)
    if currentSignature == nextSignature and IsReminderFloatShowingTrigger("zone") then
        return matchingBlocks
    end

    reminderOpenTokens.zone = (reminderOpenTokens.zone or 0) + 1
    SetActiveReminderBlocks("zone", matchingBlocks)
    self:ShowReminderFloat("zone", matchingBlocks, false, zoneContextKey)
    return matchingBlocks
end

function module:HandleInstanceReminderLocationChanged()
    local activeTrigger, contextKey = GetCurrentReminderInstanceContext()
    ClearStaleDismissedInstanceContexts(activeTrigger, contextKey)

    for _, trigger in ipairs({ "dungeon", "raid" }) do
        if trigger ~= activeTrigger then
            ClearActiveReminderBlocks(trigger)
            self:HideReminderFloat(trigger)
        end
    end

    if not activeTrigger then
        return {}
    end

    local matchingBlocks = ApplyStableReminderBlockOrder(activeTrigger, CollectReminderBlocksForTriggerIncludingSessionDone(activeTrigger))
    if #matchingBlocks == 0 then
        ClearActiveReminderBlocks(activeTrigger)
        self:HideReminderFloat(activeTrigger)
        return {}
    end

    if contextKey and dismissedReminderLocationContexts[activeTrigger] and dismissedReminderLocationContexts[activeTrigger][contextKey] then
        ClearActiveReminderBlocks(activeTrigger)
        self:HideReminderFloat(activeTrigger)
        return matchingBlocks
    end

    local currentSignature = BuildReminderPayloadSignature(activeReminderBlocksByTrigger[activeTrigger])
    local nextSignature = BuildReminderPayloadSignature(matchingBlocks)
    if currentSignature == nextSignature and IsReminderFloatShowingTrigger(activeTrigger) then
        return matchingBlocks
    end

    reminderOpenTokens[activeTrigger] = (reminderOpenTokens[activeTrigger] or 0) + 1
    SetActiveReminderBlocks(activeTrigger, matchingBlocks)
    self:ShowReminderFloat(activeTrigger, matchingBlocks, false, contextKey)
    return matchingBlocks
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

function module:HandleReminderEvent(eventName, ...)
    if eventName == "PLAYER_ENTERING_WORLD"
        or eventName == "ZONE_CHANGED"
        or eventName == "ZONE_CHANGED_NEW_AREA"
        or eventName == "ZONE_CHANGED_INDOORS"
    then
        self:HandleZoneReminderLocationChanged()
        self:HandleInstanceReminderLocationChanged()
        if eventName == "PLAYER_ENTERING_WORLD" then
            return
        end
    end

    if eventName == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" then
        local interactionType = tonumber(select(1, ...))
        local trigger = REMINDER_INTERACTION_HIDE_TRIGGERS[interactionType]
        if trigger then
            self:ScheduleReminderClose(trigger, "interaction:" .. tostring(interactionType))
            return
        end
    end

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

    local registeredEvents = {}
    for _, eventName in ipairs(REMINDER_EVENTS) do
        if self.RegisterEvent and not registeredEvents[eventName] then
            local ok = pcall(function()
                self:RegisterEvent(eventName, "HandleReminderEvent")
            end)
            if ok then
                reminderEventsRegistered = true
                registeredEvents[eventName] = true
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
