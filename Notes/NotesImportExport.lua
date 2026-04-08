local _, ns = ...
local shared = ns.NotesShared
local module = shared and shared.module
if not shared or not module then return end
local constants = shared.constants
local helpers = shared.helpers
local NormalizeNoteTitle = helpers.NormalizeNoteTitle
local ClampImportTimestamp = helpers.ClampImportTimestamp
local GetPrintableErrorMessage = helpers.GetPrintableErrorMessage
local CreateBackdropFrame = helpers.CreateBackdropFrame
local DEFAULT_NOTE_TITLE = constants.DEFAULT_NOTE_TITLE
local DEFAULT_NOTE_BODY = constants.DEFAULT_NOTE_BODY
local NOTE_EXPORT_PREFIX = constants.NOTE_EXPORT_PREFIX
local NOTE_EXPORT_VERSION = constants.NOTE_EXPORT_VERSION
local NOTE_TRANSFER_DIALOG_WIDTH = constants.NOTE_TRANSFER_DIALOG_WIDTH
local NOTE_TRANSFER_DIALOG_HEIGHT = constants.NOTE_TRANSFER_DIALOG_HEIGHT
local NOTE_TRANSFER_DIALOG_BUTTON_WIDTH = constants.NOTE_TRANSFER_DIALOG_BUTTON_WIDTH
local NOTE_TRANSFER_DIALOG_BUTTON_HEIGHT = constants.NOTE_TRANSFER_DIALOG_BUTTON_HEIGHT
local NOTE_TRANSFER_DIALOG_SIDE_INSET = constants.NOTE_TRANSFER_DIALOG_SIDE_INSET
local NOTE_TRANSFER_DIALOG_TOP_INSET = constants.NOTE_TRANSFER_DIALOG_TOP_INSET
local NOTE_TRANSFER_DIALOG_BOTTOM_INSET = constants.NOTE_TRANSFER_DIALOG_BOTTOM_INSET
local NOTE_TRANSFER_DIALOG_INSTRUCTIONS_TOP_GAP = constants.NOTE_TRANSFER_DIALOG_INSTRUCTIONS_TOP_GAP
local NOTE_TRANSFER_DIALOG_BODY_TOP_GAP = constants.NOTE_TRANSFER_DIALOG_BODY_TOP_GAP
local NOTE_TRANSFER_DIALOG_STATUS_TOP_GAP = constants.NOTE_TRANSFER_DIALOG_STATUS_TOP_GAP
local NOTE_TRANSFER_DIALOG_BUTTON_TOP_GAP = constants.NOTE_TRANSFER_DIALOG_BUTTON_TOP_GAP
local NOTE_TRANSFER_DIALOG_EDIT_INNER_X = constants.NOTE_TRANSFER_DIALOG_EDIT_INNER_X
local NOTE_TRANSFER_DIALOG_EDIT_INNER_Y = constants.NOTE_TRANSFER_DIALOG_EDIT_INNER_Y
local HOME_LIST_BORDER_COLOR = constants.HOME_LIST_BORDER_COLOR
local HOME_LIST_BACKDROP_BORDER_MARGIN = constants.HOME_LIST_BACKDROP_BORDER_MARGIN
local NOTE_TAB_BODY_EDIT_FONT_SIZE = constants.NOTE_TAB_BODY_EDIT_FONT_SIZE
local function NextNoteBodyScrollFrameSerial()
    return shared.NextNoteBodyScrollFrameSerial()
end
local function GetAceSerializer()
    return shared.GetAceSerializer()
end
local function GetLibDeflate()
    return shared.GetLibDeflate()
end

function module:BuildNoteExportString(noteId)
    local note = noteId and self:GetNoteById(noteId) or nil
    if not note or note.isBuiltin then
        return nil, "Only saved notes can be exported."
    end

    if not GetAceSerializer() or not GetLibDeflate() then
        return nil, "Note export is unavailable."
    end

    local payload = {
        v = NOTE_EXPORT_VERSION,
        t = tostring(note.title or DEFAULT_NOTE_TITLE),
        b = tostring(note.body or DEFAULT_NOTE_BODY),
        c = tonumber(note.createdAt) or time(),
        u = tonumber(note.updatedAt) or tonumber(note.createdAt) or time(),
    }

    local serialized = GetAceSerializer():Serialize(payload)
    local compressed = GetLibDeflate():CompressDeflate(serialized)
    if not compressed then
        return nil, "Note export failed."
    end

    local encoded = GetLibDeflate():EncodeForPrint(compressed)
    if not encoded or encoded == "" then
        return nil, "Note export failed."
    end

    return NOTE_EXPORT_PREFIX .. encoded
end

function module:ParseSerializedImportedNotePayload(serialized)
    if not GetAceSerializer() then
        return nil, "Note import is unavailable."
    end

    if serialized == "" then
        return nil, "The import string is empty."
    end

    local ok, payload = GetAceSerializer():Deserialize(serialized)
    if not ok then
        return nil, GetPrintableErrorMessage(payload)
    end

    if type(payload) ~= "table" then
        return nil, "The import payload is malformed."
    end

    local version = tonumber(payload.v)
    if version == nil and (payload.t ~= nil or payload.b ~= nil or payload.c ~= nil or payload.u ~= nil) then
        version = NOTE_EXPORT_VERSION
    end
    if version == nil and (payload.title ~= nil or payload.body ~= nil or payload.createdAt ~= nil or payload.updatedAt ~= nil) then
        version = tonumber(payload.version) or NOTE_EXPORT_VERSION
    end
    if version ~= NOTE_EXPORT_VERSION then
        return nil, "This note export version is not supported."
    end

    local title = payload.t
    if title == nil then
        title = payload.title
    end
    if title ~= nil and type(title) ~= "string" then
        return nil, "Imported note title is invalid."
    end

    local body = payload.b
    if body == nil then
        body = payload.body
    end
    if body ~= nil and type(body) ~= "string" then
        return nil, "Imported note body is invalid."
    end

    local createdAt = ClampImportTimestamp(payload.c)
    if createdAt == nil then
        createdAt = ClampImportTimestamp(payload.createdAt)
    end

    local updatedAt = ClampImportTimestamp(payload.u)
    if updatedAt == nil then
        updatedAt = ClampImportTimestamp(payload.updatedAt)
    end

    if createdAt and updatedAt and updatedAt < createdAt then
        updatedAt = createdAt
    end

    return {
        title = NormalizeNoteTitle(title),
        body = body or DEFAULT_NOTE_BODY,
        createdAt = createdAt,
        updatedAt = updatedAt,
    }
end

function module:ParseImportedNoteString(rawText)
    if not GetAceSerializer() then
        return nil, "Note import is unavailable."
    end

    local text = tostring(rawText or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    if text == "" then
        return nil, "Paste a note import string first."
    end

    if string.sub(text, 1, string.len(NOTE_EXPORT_PREFIX)) ~= NOTE_EXPORT_PREFIX then
        return nil, "This string is not a SnailNotes note export."
    end

    local payloadText = string.sub(text, string.len(NOTE_EXPORT_PREFIX) + 1)
    if payloadText == "" then
        return nil, "The import string is empty."
    end

    if GetLibDeflate() then
        local decoded = GetLibDeflate():DecodeForPrint(payloadText)
        if decoded then
            local decompressed = GetLibDeflate():DecompressDeflate(decoded)
            if not decompressed then
                return nil, "The import payload could not be decompressed."
            end

            return self:ParseSerializedImportedNotePayload(decompressed)
        end
    end

    return self:ParseSerializedImportedNotePayload(payloadText)
end

function module:CreateImportedNote(importedNote)
    self:EnsureRuntime()

    local now = time()
    local createdAt = importedNote and importedNote.createdAt or now
    local updatedAt = importedNote and importedNote.updatedAt or createdAt
    if updatedAt < createdAt then
        updatedAt = createdAt
    end

    local note = {
        id = self:BuildNextNoteId(),
        title = NormalizeNoteTitle(importedNote and importedNote.title),
        body = tostring(importedNote and importedNote.body or DEFAULT_NOTE_BODY),
        createdAt = createdAt,
        updatedAt = updatedAt,
    }

    self:GetNotesTable()[note.id] = note
    self.runtime.selectedNoteId = note.id
    self:Refresh()
    return note
end

function module:CreateNote(title, body)
    self:EnsureRuntime()

    local noteTitle = self:GetUniqueNoteTitle(title)

    local now = time()
    local note = {
        id = self:BuildNextNoteId(),
        title = noteTitle,
        body = body or DEFAULT_NOTE_BODY,
        createdAt = now,
        updatedAt = now,
    }

    self:GetNotesTable()[note.id] = note
    self.runtime.selectedNoteId = note.id
    self:Refresh()
    return note
end

function module:DuplicateNote(noteId)
    if self:IsBuiltinNoteId(noteId) then
        return nil
    end

    local note = self:GetNoteById(noteId)
    if not note then
        return nil
    end

    return self:CreateNote(note.title, note.body)
end

function module:SetNoteTransferDialogStatus(dialog, text, isError)
    if not dialog or not dialog.statusText then
        return
    end

    dialog.statusText:SetText(text or "")
    if isError then
        dialog.statusText:SetTextColor(1.0, 0.25, 0.25)
    else
        dialog.statusText:SetTextColor(0.80, 0.88, 0.98)
    end
end

function module:CreateNoteTransferDialog(parent)
    local dialog = CreateFrame("Frame", nil, parent, "BasicFrameTemplateWithInset")
    dialog:SetFrameStrata("DIALOG")
    dialog:SetFrameLevel((parent:GetFrameLevel() or 1) + 60)
    dialog:SetSize(NOTE_TRANSFER_DIALOG_WIDTH, NOTE_TRANSFER_DIALOG_HEIGHT)
    dialog:SetPoint("CENTER", parent, "CENTER", 0, 0)
    dialog:Hide()

    if dialog.TitleText then
        dialog.TitleText:SetText("Note Transfer")
    end

    dialog.instructions = dialog:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    dialog.instructions:SetPoint("TOPLEFT", NOTE_TRANSFER_DIALOG_SIDE_INSET, -NOTE_TRANSFER_DIALOG_TOP_INSET - NOTE_TRANSFER_DIALOG_INSTRUCTIONS_TOP_GAP)
    dialog.instructions:SetPoint("TOPRIGHT", -NOTE_TRANSFER_DIALOG_SIDE_INSET, -NOTE_TRANSFER_DIALOG_TOP_INSET - NOTE_TRANSFER_DIALOG_INSTRUCTIONS_TOP_GAP)
    dialog.instructions:SetJustifyH("LEFT")
    dialog.instructions:SetJustifyV("TOP")

    dialog.bodyFrame = CreateBackdropFrame(dialog, false)
    dialog.bodyFrame:SetPoint("TOPLEFT", dialog.instructions, "BOTTOMLEFT", 0, -NOTE_TRANSFER_DIALOG_BODY_TOP_GAP)
    dialog.bodyFrame:SetPoint("TOPRIGHT", dialog.instructions, "BOTTOMRIGHT", 0, -NOTE_TRANSFER_DIALOG_BODY_TOP_GAP)
    dialog.bodyFrame:SetPoint("BOTTOMRIGHT", -NOTE_TRANSFER_DIALOG_SIDE_INSET, NOTE_TRANSFER_DIALOG_BOTTOM_INSET + NOTE_TRANSFER_DIALOG_BUTTON_HEIGHT + NOTE_TRANSFER_DIALOG_BUTTON_TOP_GAP + 24)
    if dialog.bodyFrame.SetBackdropBorderColor then
        dialog.bodyFrame:SetBackdropBorderColor(unpack(HOME_LIST_BORDER_COLOR))
    end

    dialog.bodyBackground = dialog.bodyFrame:CreateTexture(nil, "BACKGROUND")
    dialog.bodyBackground:SetPoint("TOPLEFT", HOME_LIST_BACKDROP_BORDER_MARGIN, -HOME_LIST_BACKDROP_BORDER_MARGIN)
    dialog.bodyBackground:SetPoint("BOTTOMRIGHT", -HOME_LIST_BACKDROP_BORDER_MARGIN, HOME_LIST_BACKDROP_BORDER_MARGIN)
    dialog.bodyBackground:SetTexture("Interface\\Buttons\\WHITE8x8")
    dialog.bodyBackground:SetVertexColor(0.02, 0.02, 0.02, 0.82)

    local scrollFrameSerial = NextNoteBodyScrollFrameSerial()
    dialog.scrollFrameName = "SnailNotesTransferScrollFrame" .. tostring(scrollFrameSerial)
    dialog.scrollFrame = CreateFrame("ScrollFrame", dialog.scrollFrameName, dialog.bodyFrame, "UIPanelScrollFrameTemplate")
    dialog.scrollFrame:SetPoint("TOPLEFT", 6, -6)
    dialog.scrollFrame:SetPoint("BOTTOMRIGHT", -28, 6)

    dialog.editBox = CreateFrame("EditBox", nil, dialog.scrollFrame)
    dialog.editBox:SetAutoFocus(false)
    dialog.editBox:SetMultiLine(true)
    dialog.editBox:SetMaxLetters(0)
    do
        local fontPath, _, fontFlags = ChatFontNormal:GetFont()
        dialog.editBox:SetFont(fontPath or STANDARD_TEXT_FONT, NOTE_TAB_BODY_EDIT_FONT_SIZE, fontFlags)
    end
    dialog.editBox:SetTextInsets(NOTE_TRANSFER_DIALOG_EDIT_INNER_X, NOTE_TRANSFER_DIALOG_EDIT_INNER_X, NOTE_TRANSFER_DIALOG_EDIT_INNER_Y, NOTE_TRANSFER_DIALOG_EDIT_INNER_Y)
    dialog.editBox:SetJustifyH("LEFT")
    dialog.editBox:SetJustifyV("TOP")
    dialog.editBox:EnableMouse(true)
    dialog.editBox:SetBlinkSpeed(0.5)
    dialog.editBox:SetWidth(NOTE_TRANSFER_DIALOG_WIDTH - 72)
    dialog.editBox:SetPoint("TOPLEFT", dialog.scrollFrame, "TOPLEFT", 0, 0)
    if dialog.editBox.SetCountInvisibleLetters then
        dialog.editBox:SetCountInvisibleLetters(false)
    end

    dialog.scrollFrame:SetScrollChild(dialog.editBox)
    dialog.scrollFrame:EnableMouse(true)

    dialog.statusText = dialog:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    dialog.statusText:SetPoint("TOPLEFT", dialog.bodyFrame, "BOTTOMLEFT", 2, -NOTE_TRANSFER_DIALOG_STATUS_TOP_GAP)
    dialog.statusText:SetPoint("TOPRIGHT", dialog.bodyFrame, "BOTTOMRIGHT", -2, -NOTE_TRANSFER_DIALOG_STATUS_TOP_GAP)
    dialog.statusText:SetJustifyH("LEFT")
    dialog.statusText:SetJustifyV("TOP")

    dialog.secondaryButton = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    dialog.secondaryButton:SetSize(NOTE_TRANSFER_DIALOG_BUTTON_WIDTH, NOTE_TRANSFER_DIALOG_BUTTON_HEIGHT)
    dialog.secondaryButton:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -(NOTE_TRANSFER_DIALOG_SIDE_INSET + NOTE_TRANSFER_DIALOG_BUTTON_WIDTH + 4), NOTE_TRANSFER_DIALOG_BOTTOM_INSET)
    dialog.secondaryButton:SetText(CANCEL)
    dialog.secondaryButton:SetScript("OnClick", function()
        dialog:Hide()
    end)

    dialog.primaryButton = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    dialog.primaryButton:SetSize(NOTE_TRANSFER_DIALOG_BUTTON_WIDTH, NOTE_TRANSFER_DIALOG_BUTTON_HEIGHT)
    dialog.primaryButton:SetPoint("RIGHT", dialog.secondaryButton, "LEFT", -4, 0)

    if dialog.CloseButton then
        dialog.CloseButton:SetScript("OnClick", function()
            dialog:Hide()
        end)
    end

    dialog.editBox:SetScript("OnEscapePressed", function()
        dialog:Hide()
    end)
    dialog.editBox:SetScript("OnCursorChanged", ScrollingEdit_OnCursorChanged)
    dialog.editBox:SetScript("OnUpdate", function(editBox, elapsed)
        if ScrollingEdit_OnUpdate then
            ScrollingEdit_OnUpdate(editBox, elapsed, dialog.scrollFrame)
        end
    end)
    dialog.editBox:SetScript("OnTextChanged", function(editBox)
        if ScrollingEdit_OnTextChanged then
            ScrollingEdit_OnTextChanged(editBox, dialog.scrollFrame)
        end
        if dialog.mode == "import" and dialog.statusText and dialog.statusText:GetText() ~= "" then
            module:SetNoteTransferDialogStatus(dialog, "")
        end
    end)
    dialog:SetScript("OnHide", function()
        dialog.mode = nil
        dialog.noteId = nil
        module:SetNoteTransferDialogStatus(dialog, "")
    end)

    return dialog
end

function module:GetNoteTransferDialog()
    if not self.runtime or not self.runtime.frame then
        return nil
    end

    if not self.runtime.noteTransferDialog then
        self.runtime.noteTransferDialog = self:CreateNoteTransferDialog(self.runtime.frame)
    end

    return self.runtime.noteTransferDialog
end

function module:ShowNoteExportDialog(noteId)
    local exportString, err = self:BuildNoteExportString(noteId)
    if not exportString then
        return false, err
    end

    local dialog = self:GetNoteTransferDialog()
    if not dialog then
        return false, "Unable to open export dialog."
    end

    self:HideRowActionMenu()
    self:HideTabContextMenu()

    dialog.mode = "export"
    dialog.noteId = noteId
    dialog:SetFrameLevel((self.runtime.frame:GetFrameLevel() or 1) + 60)
    if dialog.TitleText then
        dialog.TitleText:SetText("Export Note")
    end
    dialog.instructions:SetText("Copy this note export string. It contains the saved title, body, and timestamps for this note.")
    dialog.primaryButton:SetText(CLOSE)
    dialog.primaryButton:ClearAllPoints()
    dialog.primaryButton:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -NOTE_TRANSFER_DIALOG_SIDE_INSET, NOTE_TRANSFER_DIALOG_BOTTOM_INSET)
    dialog.primaryButton:SetScript("OnClick", function()
        dialog:Hide()
    end)
    dialog.secondaryButton:Hide()
    self:SetNoteTransferDialogStatus(dialog, "")
    dialog:Show()
    dialog.editBox:SetText(exportString)
    dialog.editBox:SetFocus()
    if dialog.editBox.HighlightText then
        dialog.editBox:HighlightText()
    else
        dialog.editBox:SetCursorPosition(0)
    end

    return true
end

function module:ShowNoteLinkDialog(noteId, titleOverride)
    local noteLink = self:BuildNoteLinkString(noteId, titleOverride)
    if not noteLink then
        return false, "Unable to build note link."
    end

    local dialog = self:GetNoteTransferDialog()
    if not dialog then
        return false, "Unable to open note link dialog."
    end

    self:HideRowActionMenu()
    self:HideTabContextMenu()

    dialog.mode = "noteLink"
    dialog.noteId = noteId
    dialog:SetFrameLevel((self.runtime.frame:GetFrameLevel() or 1) + 60)
    if dialog.TitleText then
        dialog.TitleText:SetText("Copy Note Link")
    end
    dialog.instructions:SetText("Copy this note link. It is ready to paste directly into another note.")
    dialog.primaryButton:SetText(CLOSE)
    dialog.primaryButton:ClearAllPoints()
    dialog.primaryButton:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -NOTE_TRANSFER_DIALOG_SIDE_INSET, NOTE_TRANSFER_DIALOG_BOTTOM_INSET)
    dialog.primaryButton:SetScript("OnClick", function()
        dialog:Hide()
    end)
    dialog.secondaryButton:Hide()
    self:SetNoteTransferDialogStatus(dialog, "")
    dialog:Show()
    dialog.editBox:SetText(noteLink)
    dialog.editBox:SetFocus()
    if dialog.editBox.HighlightText then
        dialog.editBox:HighlightText()
    else
        dialog.editBox:SetCursorPosition(0)
    end

    return true
end

function module:ShowNoteImportDialog()
    local dialog = self:GetNoteTransferDialog()
    if not dialog then
        return false
    end

    self:HideRowActionMenu()
    self:HideTabContextMenu()

    dialog.mode = "import"
    dialog.noteId = nil
    dialog:SetFrameLevel((self.runtime.frame:GetFrameLevel() or 1) + 60)
    if dialog.TitleText then
        dialog.TitleText:SetText("Import Note")
    end
    dialog.instructions:SetText("Paste a SnailNotes note export string to create a new local note.")
    dialog.primaryButton:SetText("Import")
    dialog.primaryButton:ClearAllPoints()
    dialog.primaryButton:SetPoint("RIGHT", dialog.secondaryButton, "LEFT", -4, 0)
    dialog.primaryButton:SetScript("OnClick", function()
        local importedNote, err = module:ParseImportedNoteString(dialog.editBox:GetText())
        if not importedNote then
            module:SetNoteTransferDialogStatus(dialog, err, true)
            return
        end

        dialog:Hide()

        local note = module:CreateImportedNote(importedNote)
        if module:HasAvailableNoteTabSlot() then
            module:OpenNote(note.id, false)
        else
            module:SetSelectedNote(note.id)
            module:RefreshHomeList()
        end
    end)
    dialog.secondaryButton:Show()
    dialog.secondaryButton:SetText(CANCEL)
    self:SetNoteTransferDialogStatus(dialog, "")
    dialog:Show()
    dialog.editBox:SetText("")
    dialog.editBox:SetFocus()
    dialog.editBox:SetCursorPosition(0)

    return true
end

