-- Source: https://github.com/AmrEldib/cmder-powerline-prompt 

--- promptValue is whether the displayed prompt is the full path or only the folder name
 -- Use:
 -- "full" for full path like C:\Windows\System32
local promptValueFull = "full"
 -- "folder" for folder name only like System32
local promptValueFolder = "folder"

local promptValueNone = "none"

 -- default is promptValueFull
local promptValue = promptValueFull


local function get_folder_name(path)
	local reversePath = string.reverse(path)
	local slashIndex = string.find(reversePath, "\\")
	return string.sub(path, string.len(path) - slashIndex + 2)
end

local npmIcon = ""
local nodeIcon = ""
local featureIcon = ""
local projectIcon = ""



-- copied from clink.lua
-- clink.lua is saved under %CMDER_ROOT%\vendor
local function get_git_dir(path)   

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
-- Find out current branch
-- @return {nil|git branch name}
---
local function get_git_branch(git_dir)
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

-- Resets the prompt 
function lambda_prompt_filter()
	local git_dir = get_git_dir()
	
    if git_dir then
		promptValue=promptValueNone
	else
		promptValue=promptValueFull
	end
	
    cwd = clink.get_cwd()
	if promptValue == promptValueFolder then
		cwd =  get_folder_name(cwd)
	end
	
	if promptValue == promptValueNone then
		cwd = " "..projectIcon
	end
    prompt = "\x1b[37;44m{cwd} {npm}{git}{hg}\n\x1b[1;30;40m{lamb} \x1b[0m"
    new_value = string.gsub(prompt, "{cwd}", cwd)
    clink.prompt.value = string.gsub(new_value, "{lamb}", "λ")
end

local arrowSymbol = ""
local branchSymbol = ""

--- copied from clink.lua
 -- Resolves closest directory location for specified directory.
 -- Navigates subsequently up one level and tries to find specified directory
 -- @param  {string} path    Path to directory will be checked. If not provided
 --                          current directory will be used
 -- @param  {string} dirname Directory name to search for
 -- @return {string} Path to specified directory or nil if such dir not found
local function get_dir_contains(path, dirname)

    -- return parent path for specified entry (either file or directory)
    local function pathname(path)
        local prefix = ""
        local i = path:find("[\\/:][^\\/:]*$")
        if i then
            prefix = path:sub(1, i-1)
        end
        return prefix
    end

    -- Navigates up one level
    local function up_one_level(path)
        if path == nil then path = '.' end
        if path == '.' then path = clink.get_cwd() end
        return pathname(path)
    end

    -- Checks if provided directory contains git directory
    local function has_specified_dir(path, specified_dir)
        if path == nil then path = '.' end
        local found_dirs = clink.find_dirs(path..'/'..specified_dir)
        if #found_dirs > 0 then return true end
        return false
    end

    -- Set default path to current directory
    if path == nil then path = '.' end

    -- If we're already have .git directory here, then return current path
    if has_specified_dir(path, dirname) then
        return path..'/'..dirname
    else
        -- Otherwise go up one level and make a recursive call
        local parent_path = up_one_level(path)
        if parent_path == path then
            return nil
        else
            return get_dir_contains(parent_path, dirname)
        end
    end
end

-- copied from clink.lua
-- clink.lua is saved under %CMDER_ROOT%\vendor
local function get_hg_dir(path)
    return get_dir_contains(path, '.hg')
end

-- adopted from clink.lua
-- clink.lua is saved under %CMDER_ROOT%\vendor
function colorful_hg_prompt_filter()

    -- Colors for mercurial status
    local colors = {
        clean = "\x1b[1;37;40m",
        dirty = "\x1b[31;1m",
    }

    if get_hg_dir() then
        -- if we're inside of mercurial repo then try to detect current branch
        local branch = get_hg_branch()
        if branch then
            -- Has branch => therefore it is a mercurial folder, now figure out status
            if get_hg_status() then
                color = colors.clean
            else
                color = colors.dirty
            end

            clink.prompt.value = string.gsub(clink.prompt.value, "{hg}", color.."("..branch..")")
            return false
        end
    end

    -- No mercurial present or not in mercurial file
    clink.prompt.value = string.gsub(clink.prompt.value, "{hg}", "")
    return false
end

---
 -- Get the status of working dir
 -- @return {bool}
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

-- adopted from clink.lua
-- Modified to add colors and arrow symbols
function colorful_git_prompt_filter()
    -- Colors for git status
    local colors = {
        clean = "\x1b[34;42m"..arrowSymbol.."\x1b[37;42m ",
        dirty = "\x1b[34;43m"..arrowSymbol.."\x1b[30;43m ",
    }

    local closingcolors = {
        clean = " \x1b[32;40m"..arrowSymbol,
        dirty = "± \x1b[33;40m"..arrowSymbol,
    }

    local git_dir = get_git_dir()
    if git_dir then
        -- if we're inside of git repo then try to detect current branch
        local branch = get_git_branch(git_dir)
		
        if branch then
            -- Has branch => therefore it is a git folder, now figure out status
            if get_git_status() then
                color = colors.clean
                closingcolor = closingcolors.clean
            else
                color = colors.dirty
                closingcolor = closingcolors.dirty
            end

            --clink.prompt.value = string.gsub(clink.prompt.value, "{git}", color.."  "..branch..closingcolor)
            clink.prompt.value = string.gsub(clink.prompt.value, "{git}", color..""..featureIcon.." "..branch..closingcolor)
            return false
        end
    end

    -- No git present or not in git file
    clink.prompt.value = string.gsub(clink.prompt.value, "{git}", "\x1b[34;40m"..arrowSymbol)
    return false
end

local pathToProject = nil

local function find_json(path)
	
	-- return parent path for specified entry (either file or directory)
	local function pathname(path)
		local prefix = ""
		local postfix = ""
		local i = path:find("[\\/:][^\\/:]*$")
		if i then
			prefix = path:sub(1, i-1)
			postfix = path:sub(i)
			if pathToProject == nil then
				pathToProject = postfix
			else
				pathToProject = postfix..''..pathToProject
			end
			
		end
		return prefix
	end
	
	if not path or path == '.' then path = clink.get_cwd() end
	
	local parent_path = pathname(path)	
	return io.open(path..'\\package.json') or (parent_path ~= path and find_json(parent_path) or nil)
end

-- adopted from clink.lua
-- Modified to add colors and arrow symbols
function colorful_npm_prompt_filter()
	-- local package = io.open('package.json')
	pathToProject = nil
	local package = find_json(nil, test)
	
	if pathToProject then
		local j = pathToProject:find("\\",2)
		if j then
			pathToProject = pathToProject:sub(j+1);
			pathToProject = "./"..string.gsub(pathToProject, "\\", "/")
		else
			pathToProject = "."
		end
		pathToProject = pathToProject.." "
	end
	
    -- Colors for npm status
    local colors = {
        clean = "\x1b[34;42m"..arrowSymbol.."\x1b[37;42m "
    }

    local closingcolors = {
        clean = "\x1b[34;40m"..arrowSymbol.."  ",
    }
	
	color = colors.clean
	closingcolor = closingcolors.clean

 
    if package ~= nil then
		local package_info = package:read('*a')
		package:close()
		
		local package_name = string.match(package_info, '"name"%s*:%s*"(%g-)"')
		if package_name == nil then
			package_version = ''
		end     
		
		local package_version = string.match(package_info, '"version"%s*:%s*"(.-)"')
		if package_version == nil then
			package_version = ''
		end  
		
		-- if package_name == '' then
		-- 	clink.prompt.value = string.gsub(clink.prompt.value, "{npm}", "\x1b[34;40m"..arrowSymbol)
		-- 	return false
		-- end
		
		-- if package_version == '' then 
		-- 	clink.prompt.value = string.gsub(clink.prompt.value, "{npm}", color.." "..package_name.." "..closingcolor)
		--     return false
		-- end
		
		clink.prompt.value = string.gsub(clink.prompt.value, "{npm}", pathToProject.."\x1b[34;46m"..arrowSymbol.."\x1b[39;46m "..npmIcon.." 
"..package_name.."@"..package_version.." \x1b[36;44m"..arrowSymbol)
		return false
		
    end
	
	clink.prompt.value = string.gsub(clink.prompt.value, "{npm}", "")
    return false
end


-- override the built-in filters
clink.prompt.register_filter(lambda_prompt_filter, 55)
clink.prompt.register_filter(colorful_hg_prompt_filter, 60)
clink.prompt.register_filter(colorful_git_prompt_filter, 65)
clink.prompt.register_filter(colorful_npm_prompt_filter, 60)
