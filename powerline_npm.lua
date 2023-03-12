local function get_package_json_dir(path)

  -- return parent path for specified entry (either file or directory)
  local function pathname(path)
          local prefix = ""
          local postfix = ""
          local i = path:find("[\\/:][^\\/:]*$")
          if i then
                  prefix = path:sub(1, i-1)

          end
          return prefix
  end

  if not path or path == '.' then path = clink.get_cwd() end

  local parent_path = pathname(path)
  return io.open(path..'\\package.json') or (parent_path ~= path and get_package_json_dir(parent_path) or nil)
end

-- * Segment object with these properties:
---- * isNeeded: sepcifies whether a segment should be added or not. For example: no Git segment is needed in a non-git folder
---- * text
---- * textColor: Use one of the color constants. Ex: colorWhite
---- * fillColor: Use one of the color constants. Ex: colorBlue
local segment = {
  isNeeded = false,
  text = "",
  textColor = colorWhite,
  fillColor = colorCyan
}

---
-- Sets the properties of the Segment object, and prepares for a segment to be added
---
local function init()
  segment.isNeeded = get_package_json_dir()
  if segment.isNeeded then
    local package_info = segment.isNeeded:read('*a')
    segment.isNeeded:close()

    local package_name = string.match(package_info, '"name"%s*:%s*"(%g-)"')
    if package_name == nil then
            package_name = ''
    end

    local package_version = string.match(package_info, '"version"%s*:%s*"(.-)"')
    if package_version == nil then
            package_version = ''
    end

    if plc_npm_npmSymbol then
      segment.text = " "..plc_npm_npmSymbol.." "..package_name.."@"..package_version.." "
    else
      segment.text = " "..package_name.."@"..package_version.." "
    end 
  end
end 

---
-- Uses the segment properties to add a new segment to the prompt
---
local function addAddonSegment()
  init()
  if segment.isNeeded then 
      addSegment(segment.text, segment.textColor, segment.fillColor)
  end 
end 

-- Register this addon with Clink
clink.prompt.register_filter(addAddonSegment, 60)
