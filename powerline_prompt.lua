-- Source: https://github.com/AmrEldib/cmder-powerline-prompt 

-- Configurations: Provide default values in case config file is missing
-- Config file is "_powerline_config.lua"
-- Sample config file is "_powerline_config.lua.sample"
--- promptValue is whether the displayed prompt is the full path or only the folder name
 -- Use:
 -- "full" for full path like C:\Windows\System32
local promptValueFull = "full"
 -- "folder" for folder name only like System32
local promptValueFolder = "folder"
 -- default is promptValueFull
if not promptValue then
    promptValue = promptValueFull
end 

-- Constants
-- Symbols
arrowSymbol = ""
-- ANSI Escape Character
ansiEscChar = "\x1b"
-- ANSI Foreground Colors
ansiFgClrBlack = "30"
ansiFgClrRed = "31"
ansiFgClrGreen = "32"
ansiFgClrYellow = "33"
ansiFgClrBlue = "34"
ansiFgClrMagenta = "35"
ansiFgClrCyan = "36"
ansiFgClrWhite = "37"
-- ANSI Background Colors
ansiBgClrBlack = "40"
ansiBgClrRed = "41"
ansiBgClrGreen = "42"
ansiBgClrYellow = "43"
ansiBgClrBlue = "44"
ansiBgClrMagenta = "45"
ansiBgClrCyan = "46"
ansiBgClrWhite = "47"
-- Common Colorful Arrows
arrowBlueToGreen = ansiEscChar.."["..ansiFgClrBlue..";"..ansiBgClrGreen.."m"..arrowSymbol..ansiEscChar.."["..ansiFgClrWhite..";"..ansiBgClrGreen.."m "
arrowBlueToYellow = ansiEscChar.."["..ansiFgClrBlue..";"..ansiBgClrYellow.."m"..arrowSymbol..ansiEscChar.."["..ansiFgClrBlack..";"..ansiBgClrYellow.."m "
arrowGreenToBlack = ansiEscChar.."["..ansiFgClrGreen..";"..ansiBgClrBlack.."m"..arrowSymbol
arrowYellowToBlack = ansiEscChar.."["..ansiFgClrYellow..";"..ansiBgClrBlack.."m"..arrowSymbol


local function get_folder_name(path)
	local reversePath = string.reverse(path)
	local slashIndex = string.find(reversePath, "\\")
	return string.sub(path, string.len(path) - slashIndex + 2)
end

-- Resets the prompt 
function lambda_prompt_filter()
    cwd = clink.get_cwd()
	if promptValue == promptValueFolder then
		cwd =  get_folder_name(cwd)
	end
    prompt = "\x1b[37;44m{cwd} {git}{hg}\n\x1b[1;30;40m{lamb} \x1b[0m"
    new_value = string.gsub(prompt, "{cwd}", cwd)
    clink.prompt.value = string.gsub(new_value, "{lamb}", "λ")
end

-- override the built-in filters
clink.prompt.register_filter(lambda_prompt_filter, 55)



-- Prompt consists of multiple segments. Each segment consists of:
-- * Whether a segment should be added or not: isSegmentNeeded
-- * Text: getSegmentText
-- * Color indicating status: getSegmentColor

-- There's a core file that contain basic info and functions
-- Then, each type of segment should have its own 'addon' file
-- One file for Git segment, Hg segment, Node.js, Python, etc.

-- Info shared between segments
-- * Current folder
-- * Current background color
-- * Current foreground color

-- Functions used by all 'addon' code will go into the core file
-- * addSegment(text, color)