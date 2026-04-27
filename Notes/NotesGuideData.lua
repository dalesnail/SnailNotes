local addonName, ns = ...

ns.NotesGuideData = {
id = "builtin-notes-guide",
title = "Notes Guide",
body = [=[


[c]
# Notes Guide [top]
[@atlas GarrMission_ListGlow-Select 800x30]
[/c]
## Index [index]
(Basic Text)[basic-text]
(Headers)[headers]
(Bullet Lists)[bullet-lists]
(Numbered Lists)[numbered-lists]
(Task Lists)[task-lists]
(Item Links)[item-links]
(Inline Formatting)[inline-formatting]
(Separator)[separator]
(Centered Blocks)[centered-blocks]
(Atlas Rows)[atlas-rows]
(Code Blocks)[code-blocks]
(Inline Code)[inline-code]
(Read vs Edit)[read-vs-edit]
(Header Anchors And Jump Links)[header-anchors-and-jump-links]
(External Note Links)[external-note-links]
(Reminders)[reminders]

---

## Basic Text [basic-text]

Normal lines render as normal text.

Blank lines are preserved.

```
Normal text line

Another normal text line after a blank line
```

(Back to Top)[top]
---

## Headers [headers]

# Header 1

## Header 2

### Header 3

```
# Header 1

## Header 2

### Header 3
```

(Back to Top)[top]
---

## Bullet Lists [bullet-lists]

- First bullet
- Second bullet
- Third bullet

```
- First bullet
- Second bullet
- Third bullet
```

(Back to Top)[top]
---

## Numbered Lists [numbered-lists]

1. First
2. Second
3. Third

```
1. First
2. Second
3. Third
```

(Back to Top)[top]
---

## Task Lists [task-lists]

- [] Task
- [] Task 2
- [x] Task 3

Task lists can be toggled directly in Read View by clicking the checkbox.

```
- [] Task
- [] Task 2
- [x] Task 3
```

(Back to Top)[top]
---

## Item Links [item-links]

Type item IDs in brackets:

[6948]
[2589]
[17182]

If the item is known or becomes cached, Read View will render it as an item link.

You can also drag an item into the editor to insert its [itemID] automatically.

```
[6948]
[2589]
[17182]
```

(Back to Top)[top]
---

## Inline Formatting [inline-formatting]

This is **BOLD text**

This is __italic text__

This is **__BOLD italic__**

This is also __**BOLD italic**__

Formatting can be used inside normal lines.

```
**BOLD text**

__italic text__

**__BOLD italic__**

__**Also BOLD italic**__
```

(Back to Top)[top]
---

## Separator [separator]

Type exactly:

```
---
```

(Back to Top)[top]
---

[c]
## Centered Blocks [centered-blocks]

This text is centered
So is this line
And this one too
[/c]

Use:

```
[c]
Your centered lines here
[/c]
```

Centered blocks can also contain headers and atlas rows.

(Back to Top)[top]
---

## Atlas Rows [atlas-rows]

[@atlas GarrMission_CurrentEncounter-Glow]
[@atlas GarrMission_CurrentEncounter-Glow 54x54]
[@atlas GarrMission_CurrentEncounter-Glow 32x32]

Use:

```
[@atlas GarrMission_CurrentEncounter-Glow]
[@atlas GarrMission_CurrentEncounter-Glow 54x54]
[@atlas GarrMission_CurrentEncounter-Glow 32x32]
```

If no size is provided, the atlas uses its native size.
If a size is provided, it uses that size.
Large atlases can clamp to the note width to avoid overflow.

Atlas tokens must be on their own line.

(Back to Top)[top]
---

## Code Blocks [code-blocks]

```
# This stays literal

- This stays literal

[12345]

[@atlas GarrMission_CurrentEncounter-Glow]

**This also stays literal**
```

Code blocks render their contents literally and suppress all Notes formatting rules inside the block.

To show code block syntax inside a note add this above and below the intended contents:

```
 ```
```

(Back to Top)[top]
---

## Inline Code [inline-code]

`Code Line`

```
 `Inline Code`
```

Inline code renders as a small contained block and does not apply any other formatting inside it.

(Back to Top)[top]
---

## Notes About Read vs Edit [read-vs-edit]

Edit View always stores plain raw text only.

Read View is where formatting, links, and atlas rendering happen.

Your saved note text is never converted into formatted rich text.

(Back to Top)[top]
---

## Header Anchors And Jump Links [header-anchors-and-jump-links]

# Gear Setup [gear]

## Boss One [boss-1]

### Phase Two [phase-2]

(Jump to gear)[gear]
(Jump to boss one)[boss-1]
(Broken link example)[missing-anchor]

Anchor tokens only work on header lines and must be at the end of the line.

Valid anchor IDs use lowercase letters, numbers, and hyphens only.

Read View hides the anchor token from the displayed header text.

Jump links only resolve inside the current note.

If a jump target is missing, the full link stays visible in red and does nothing.

Use:

```
# Gear Setup [gear]
## Boss One [boss-1]
### Phase Two [phase-2]

(Jump to gear)[gear]
(Jump to boss one)[boss-1]
(Broken link example)[missing-anchor]
```
(Back to Top)[top]
---

## External Note Links [external-note-links]

(Raid Prep)[[AJH23S]]
(Missing Note)[[INVALID]]

External note links open another saved note using its internal note ID.

If the note exists, the link is clickable in Read View.

If the note does not exist, the full token stays visible in red and does nothing.

Use:

```
(Raid Prep)[[AJH23S]]
(Missing Note)[[INVALID]]
```

You can generate a ready-to-paste note link from:

* the Home tab right-click row menu using  `Copy Note Link`
* the Read View  `Link` button under options

Both produce:

```
(Note Title)[[AJH23S]]
```
(Back to Top)[top]
---

# Reminder System [reminders]

SnailNotes supports context-based reminders that appear automatically when certain conditions are met.

## Basic Syntax

Reminder blocks use the following format:

```
[! trigger]
Reminder text
[!]
```

## Supported Triggers

`[! mail]`
  
When opening a mailbox

`[! bank]`  

When opening the bank

`[! auction]`  

When opening the auction house

`[! login]`  

When logging in

`[! zone:<zone-name>]`  

When entering a zone or area (use this for specific instances and open world areas)

`[! dungeon]`  

When entering any 5-man dungeon

`[! raid]`

When entering any raid


## Examples
```
[! zone:stormwind-city]
Buy reagents
[!]

---

[! dungeon]
You can have
Multiple Lines
in a reminder block

- [] As well as
- [] Checklist items

Or almost any other formatting, Including textures
[!]
```


## Character-Specific Reminders

You can limit reminders to a specific character:

**Example:**
```
[! mail:dalesnail]
Check alt mail
[!]

[! zone:stormwind:dalesnail]
Do Stormwind stuff
[!]
```


## Done Flag

You can mark reminders as complete like this:
```
[! mail done]
```
Or you can toggle them as done in the reminder window

**Done reminders:**
- Do not trigger
- Still exist in the note
- Can be toggled in the reminder window

## In-Game Reminder Window

When triggered, reminders appear in a popup window.

**Features:**
- Checklist items can be toggled
- "Done" / "Undo" marks a reminder complete
- "Open Note" jumps to the source note
- Manual close (X) temporarily dismisses reminders for the current context

## Zone Behavior

**Zone reminders:**
- Trigger when entering a matching zone
- Support flexible matching (e.g. "stormwind" matches "Stormwind City")
- Stay dismissed if closed manually until leaving the zone and re-entering

## Notes Behavior

- Reminder blocks are hidden in normal rendering (tags are not shown)
- Multiple reminders from one note are grouped together
- Reminders update automatically based on game events

---

(Back to Top)[top]

]=],
updatedAt = 6,
}
