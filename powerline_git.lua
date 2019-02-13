-- Constants
local segmentColors = {
    clean = {
        fill = colorGreen,
        text = colorWhite
    },
    dirty = {
        fill = colorYellow,
        text = colorBlack
    },
    statusSegment={
        fill = colorMagenta,
        text = colorWhite
    },
    conflict = {
        fill = colorRed,
        text = colorWhite
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
-- function get_git_dir(path)
-- MOVED INTO CORE

---
-- Gets the status of working dir
-- @return {bool} indicating true for clean, false for dirty
---
function get_git_status()
    local file = io.popen("git -c core.quotepath=false -c color.status=false status --short --branch 2>nul")
    local counter=0
    local status={
        behind = 0,
        ahead = 0,
        files = 0
    }
    for line in file:lines() do
        if counter==0 then
            status.behind=tonumber(string.match(line,"%[behind (%d*)%]"))
            if not status.behind then
                status.behind=0
            end
            status.ahead= tonumber(string.match(line,"%[ahead (%d*)%]"))
            if not status.ahead then
                status.ahead=0
            end
        end
        counter=counter+1
    end
    
    status.files=counter-1


    file:close()
    return status
end

---
-- Gets the conflict status
-- @return {bool} indicating true for conflict, false for no conflicts
---
function get_git_conflict()
    local file = io.popen("git diff --name-only --diff-filter=U 2>nul")
    for line in file:lines() do
        file:close()
        return true;
    end
    file:close()
    return false
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

local statusSegment={
    isNeeded = false,
    text = "",
    textColor = segmentColors.statusSegment.text,
    fillColor =segmentColors.statusSegment.fill
}

local function updateStatusSegment(gitStatus)
   statusSegment.isNeeded= gitStatus.ahead>0 or gitStatus.behind>0
    if not statusSegment.isNeeded then
        return
    end

    local statusText=""
   
    if plc_git_aheadSymbol and gitStatus.ahead then
        statusText=" "..plc_git_aheadSymbol..gitStatus.ahead
    end

    if plc_git_behindSymbol and gitStatus.behind then
        statusText=statusText.." "..plc_git_behindSymbol..gitStatus.behind
    end
   
    statusSegment.text = statusText
end
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
            local gitConflict = get_git_conflict()
            segment.text = " "..plc_git_branchSymbol.." "..branch.." "


            if gitConflict then
                segment.textColor = segmentColors.conflict.text
                segment.fillColor = segmentColors.conflict.fill
                if plc_git_conflictSymbol then
                    segment.text = segment.text..plc_git_conflictSymbol
                end 
                return
            end             

            if gitStatus.files>0 then
                segment.textColor = segmentColors.dirty.text
                segment.fillColor = segmentColors.dirty.fill
                if plc_git_fileCountSymbol then 
                    segment.text=segment.text..plc_git_fileCountSymbol..gitStatus.files
                end
            else
                segment.textColor = segmentColors.clean.text
                segment.fillColor = segmentColors.clean.fill
            end
            

            updateStatusSegment(gitStatus)
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
    if statusSegment.isNeeded then 
        addSegment(statusSegment.text, statusSegment.textColor, statusSegment.fillColor)
    end 
end 

-- Register this addon with Clink
clink.prompt.register_filter(addAddonSegment, 61)