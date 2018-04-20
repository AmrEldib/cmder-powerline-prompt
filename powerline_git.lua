-- Constants
local branchSymbol = ""
local segmentColors = {
    clean = {
        fill = colorGreen,
        text = colorWhite
    },
    dirty = {
        fill = colorYellow,
        text = colorBlack
    }
}

---
-- Finds out the name of the current branch
-- @return {nil|git branch name}
---
function get_git_branch(git_dir)
    git_dir = git_dir or get_git_dir()

    -- If git directory not found then we're probably outside of repo
    -- or something went wrong. The same is when head_file is nil
    local head_file = git_dir and io.open(git_dir..'/HEAD')
    if not head_file then return end

    local HEAD = head_file:read()
    head_file:close()

    -- if HEAD matches branch expression, then we're on named branch
    -- otherwise it is a detached commit
    local branch_name = HEAD:match('ref: refs/heads/(.+)')

    return branch_name or 'HEAD detached at '..HEAD:sub(1, 7)
end

---
-- Gets the .git directory
-- copied from clink.lua
-- clink.lua is saved under %CMDER_ROOT%\vendor
-- @return {bool} indicating there's a git directory or not
---
function get_git_dir(path)

    -- return parent path for specified entry (either file or directory)
    local function pathname(path)
        local prefix = ""
        local i = path:find("[\\/:][^\\/:]*$")
        if i then
            prefix = path:sub(1, i-1)
        end
        return prefix
    end

    -- Checks if provided directory contains git directory
    local function has_git_dir(dir)
        return clink.is_dir(dir..'/.git') and dir..'/.git'
    end

    local function has_git_file(dir)
        local gitfile = io.open(dir..'/.git')
        if not gitfile then return false end

        local git_dir = gitfile:read():match('gitdir: (.*)')
        gitfile:close()

        return git_dir and dir..'/'..git_dir
    end

    -- Set default path to current directory
    if not path or path == '.' then path = clink.get_cwd() end

    -- Calculate parent path now otherwise we won't be
    -- able to do that inside of logical operator
    local parent_path = pathname(path)

    return has_git_dir(path)
        or has_git_file(path)
        -- Otherwise go up one level and make a recursive call
        or (parent_path ~= path and get_git_dir(parent_path) or nil)
end

---
-- Gets the status of working dir
-- @return {bool} indicating true for clean, false for dirty
---
function get_git_status()
    local file = io.popen("git --no-optional-locks status --porcelain 2>nul")
    for line in file:lines() do
        file:close()
        return false
    end
    file:close()
    return true
end

-- * Segment object with these properties:
---- * isNeeded: sepcifies whether a segment should be added or not. For example: no Git segment is needed in a non-git folder
---- * text
---- * textColor: Use one of the color constants. Ex: colorWhite
---- * fillColor: Use one of the color constants. Ex: colorBlue
local segment = {
    isNeeded = false,
    text = "",
    textColor = 0,
    fillColor = 0
}

---
-- Sets the properties of the Segment object, and prepares for a segment to be added
---
local function init()
    segment.isNeeded = get_git_dir()
    if segment.isNeeded then
        -- if we're inside of git repo then try to detect current branch
        local branch = get_git_branch(git_dir)
        if branch then
            -- Has branch => therefore it is a git folder, now figure out status
            local gitStatus = get_git_status()
            segment.text = " "..branchSymbol.." "..branch.." "
            if gitStatus then
                segment.textColor = segmentColors.clean.text
                segment.fillColor = segmentColors.clean.fill
            else
                segment.textColor = segmentColors.dirty.text
                segment.fillColor = segmentColors.dirty.fill
                segment.text = segment.text.."± "
            end
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