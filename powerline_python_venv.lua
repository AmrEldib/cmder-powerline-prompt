---
 -- get the virtual env variable
---
local function get_virtual_env(env_var)

    local venv_path = false
    -- return the folder name of the current virtual env, or false
    local function get_virtual_env_var(var)
        env_path = clink.get_env(var)
        if env_path then
            return string.match(env_path, "[^\\/:]+$")
        else
            return false
        end
    end

    local venv = get_virtual_env_var(env_var) or get_virtual_env_var('VIRTUAL_ENV') or get_virtual_env_var('CONDA_DEFAULT_ENV') or false
    return venv
end

---
 -- check for python files in current directory
---
local function get_py_files(path)
    local function pathname(path)
        local prefix = ""
        local i = path:find("[\\/:][^\\/:]*$")
        if i then
                prefix = path:sub(1, i-1)
        end
        return prefix
    end

    local function has_py_files(dir)
        local pyfile = clink.match_files("*.py", dir)
        return pyfile
    end

    if not path or path == '.' then path = clink.get_cwd() end

    dir = pathname(path)

    files = has_py_files(dir) > 0
    return files
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
    if plc_python_virtualEnvVariable then
        segment.isNeeded = get_virtual_env(plc_python_virtualEnvVariable)
    else
        segment.isNeeded = get_virtual_env()
    end

    if not plc_python_alwaysShow and not get_py_files() then segment.isNeeded = false end

    if segment.isNeeded then
        if plc_python_pythonSymbol then
            segment.text = " "..plc_python_pythonSymbol.." ["..segment.isNeeded.."] "
        else
            segment.text = " ["..segment.isNeeded.."] "
        end
    end
end

local function addAddonSegment()
    init()
    if segment.isNeeded then
        addSegment(segment.text, segment.textColor, segment.fillColor)
    end
end

-- register the filters
clink.prompt.register_filter(addAddonSegment, 59)