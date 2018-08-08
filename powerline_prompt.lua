-- Configurations
--- plc_prompt_type is whether the displayed prompt is the full path or only the folder name
 -- Use:
 -- "full" for full path like C:\Windows\System32
local promptTypeFull = "full"
 -- "folder" for folder name only like System32
local promptTypeFolder = "folder"
 -- "smart" to switch in git repo to folder name instead of full path
local promptTypeSmart = "smart"

 -- default is promptTypeFull
 -- Set default value if no value is already set
if not plc_prompt_type then
    plc_prompt_type = promptTypeFull
end
if not plc_prompt_useHomeSymbol then
	plc_prompt_useHomeSymbol = true
end
if not plc_prompt_homeSymbolEnvironment then
    plc_prompt_homeSymbolEnvironment = "HOME"
end

-- Extracts only the folder name from the input Path
-- Ex: Input C:\Windows\System32 returns System32
---
local function get_folder_name(path)
	local reversePath = string.reverse(path)
	local slashIndex = string.find(reversePath, "\\")
	return string.sub(path, string.len(path) - slashIndex + 2)
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
    fillColor = colorBlue
}

---
-- Sets the properties of the Segment object, and prepares for a segment to be added
---
local git_root_dir = nil
local function init()
    -- fullpath
    cwd = clink.get_cwd()

    -- show just current folder
    if plc_prompt_type == promptTypeFolder then
		cwd =  get_folder_name(cwd)
    else
    -- show 'smart' folder name
    -- This will show the full folder path unless a Git repo is active in the folder
    -- If a Git repo is active, it will only show the folder name
    -- This helps users avoid having a super long prompt
        local git_dir = get_git_dir()
        if git_dir and git_root_dir == nil then
            -- get the root of the git directory and save it
            git_root_dir = git_dir:gsub("/.git", "")
        end
        if plc_prompt_useHomeSymbol and string.find(cwd, clink.get_env(plc_prompt_homeSymbolEnvironment)) and git_dir ==nil then
            -- in both smart and full if we are in home, behave like a proper command line
            git_root_dir = nil
            cwd = string.gsub(cwd, clink.get_env(plc_prompt_homeSymbolEnvironment), plc_prompt_homeSymbol)
        else
            -- either not in home or home not supported then check the smart path
            if plc_prompt_type == promptTypeSmart then
                if git_dir then
                    -- get the root git folder name and reappend any part of the directory that comes after
                    -- replaces all special characters in cwd with "" and then replaces the cwd up to git_root_dir with ""
                    -- Ex: C:\Users\username\cmder-powerline-prompt\innerdir -> cmder-powerline-prompt\innerdir
                    local appended_dir = cwd:gsub("[%(%)%.%%%+%-%*%?%[%^%&]",""):gsub("(.*)("..git_root_dir..")", "")
                    cwd = get_folder_name(git_root_dir)..appended_dir
                    if plc_prompt_gitSymbol then
                        cwd = plc_prompt_gitSymbol.." "..cwd
                    end
                end
                -- if not git dir leave the full path
            end
        end
    end

	segment.text = " "..cwd.." "
end

---
-- Uses the segment properties to add a new segment to the prompt
---
local function addAddonSegment()
    init()
    addSegment(segment.text, segment.textColor, segment.fillColor)
end

-- Register this addon with Clink
clink.prompt.register_filter(addAddonSegment, 55)
