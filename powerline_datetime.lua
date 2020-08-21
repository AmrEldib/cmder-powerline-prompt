-- Configurations
--- plc_datetime_type is the format for displaying data and time
--- please refer to https://www.lua.org/pil/22.1.html for references
local dateTimeTypeFull = "%Y-%m-%d %H:%M:%S"

 -- default is dateTimeTypeFull
 -- Set default value if no value is already set
if not plc_datetime_type then
    plc_datetime_type = dateTimeTypeFull
end

function time_prompt()
    return os.date(plc_datetime_type)
end

-- * Segment object with these properties:
---- * isNeeded: sepcifies whether a segment should be added or not. For example: no Git segment is needed in a non-git folder
---- * text
---- * textColor: Use one of the color constants. Ex: colorWhite
---- * fillColor: Use one of the color constants. Ex: colorBlue
local segment = {
    isNeeded = true,
    text = "",
    textColor = colorWhite,
    fillColor = colorGreen
}

---
-- Sets the properties of the Segment object, and prepares for a segment to be added
---
local function init()
	segment.text = time_prompt()
end

---
-- Uses the segment properties to add a new segment to the prompt
---
local function addAddonSegment()
    init()
    addSegment(segment.text, segment.textColor, segment.fillColor)
end

-- Register this addon with Clink
clink.prompt.register_filter(addAddonSegment, 54)
