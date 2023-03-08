-- Configurations: Provide default values in case config file is missing
-- Config file is "_powerline_config.lua"
-- Sample config file is "_powerline_config.lua.sample"

------
-- Core file, and addon files
------
-- Prompt consists of multiple segments. Each segment consists of:
-- * Whether a segment should be added or not
-- * Text
-- * Color indicating status

-- There's a core file that contain basic info and functions
-- Then, each type of segment should have its own 'addon' file
-- One file for Git segment, Hg segment, Node.js, Python, etc.

-- Info shared between segments
-- * Current fill color
-- * Current text color
-- * Current prompt value

-- Functions used by all 'addon' code will go into the core file
-- * addSegment(text, forecolor, backcolor)
--      Because core file keeps track of current colors, it can attach segments with the correct colors without addon files needing to manage this on their own

-- In all 'addon' files:
-- * Segment object with these properties:
---- * isNeeded: sepcifies whether a segment should be added or not. For example: no Git segment is needed in a non-git folder
---- * text
---- * textColor: Use one of the color constants. Ex: colorWhite
---- * fillColor: Use one of the color constants. Ex: colorBlue
-- Function in all 'addon' files
---- * init: Sets the properties of the Segment object, and prepares for a segment to be added
---- * addAddonSegment: uses the segment properties to add a new segment to the prompt
-- * Must call clink.prompt.register_filter and pass addAddonSegment

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
ansiFgClrDefault = "39"
-- ANSI Background Colors
ansiBgClrBlack = "40"
ansiBgClrRed = "41"
ansiBgClrGreen = "42"
ansiBgClrYellow = "43"
ansiBgClrBlue = "44"
ansiBgClrMagenta = "45"
ansiBgClrCyan = "46"
ansiBgClrWhite = "47"
ansiBgClrDefault = "49"

-- Colors
colorDefault = {
	foreground = ansiFgClrDefault,
	background = ansiBgClrDefault
}
colorBlack = {
	foreground = ansiFgClrBlack,
	background = ansiBgClrBlack
}
colorRed = {
	foreground = ansiFgClrRed,
	background = ansiBgClrRed
}
colorGreen = {
	foreground = ansiFgClrGreen,
	background = ansiBgClrGreen
}
colorYellow = {
	foreground = ansiFgClrYellow,
	background = ansiBgClrYellow
}
colorBlue = {
	foreground = ansiFgClrBlue,
	background = ansiBgClrBlue
}
colorMagenta = {
	foreground = ansiFgClrMagenta,
	background = ansiBgClrMagenta
}
colorCyan = {
	foreground = ansiFgClrCyan,
	background = ansiBgClrCyan
}
colorWhite = {
	foreground = ansiFgClrWhite,
	background = ansiBgClrWhite
}

-- Variables to maintain prompt state
currentSegments = ""
currentFillColor = colorBlue.background
currentTextColor = colorWhite.foreground

-- Constants
-- Symbols
newLineSymbol = "\n"

-- Default symbols
-- Some symbols are required. If the user fails to provide them in the config file, they're created here
-- Prompt displayed instead of user's home folder e.g. C:\Users\username
if not plc_prompt_homeSymbol then
	plc_prompt_homeSymbol = "~"
end
-- Symbol connecting each segment of the prompt. Be careful before you change this.
if not plc_prompt_arrowSymbol then
	plc_prompt_arrowSymbol = ""
end
-- Symbol displayed in the new line below the prompt.
if not plc_prompt_lambSymbol then
	plc_prompt_lambSymbol = "λ"
end
-- Version control (e.g. Git) branch symbol. Used to indicate the name of a branch.
if not plc_git_branchSymbol then
	plc_git_branchSymbol = ""
end
-- Version control (e.g. Git) conflict symbol. Used to indicate there's a conflict.
if not plc_git_conflictSymbol then
	plc_git_conflictSymbol = "!"
end

---
-- Adds an arrow symbol to the input text with the correct colors
-- text {string} input text to which an arrow symbol will be added
-- oldColor {color} Color of the prompt on the left of the arrow symbol. Use one of the color constants as input.
-- newColor {color} Color of the prompt on the right of the arrow symbol. Use one of the color constants as input.
-- @return {string} text with an arrow symbol added to it
---
function addArrow(text, oldColor, newColor)
	-- Old color is the color of the previous segment
	-- New color is the color of the next segment
	-- An arrow is a character written using the old color on a background of the new color
	text = addTextWithColor(text, plc_prompt_arrowSymbol, oldColor.foreground, newColor.background)
	return text
end

---
-- Adds text to the input text with the correct colors
-- text {string} input text to which more text will be added
-- textToAdd {string} text to be added with the specified colors
-- textColorValue {number} Foreground color of the newly added text. Provide an ANSI color value.
-- fillColorValue {number} Background color of the newly added text. Provide an ANSI color value.
-- @return {string} concatination of the the two input text with the correct color formatting.
---
function addTextWithColor(text, textToAdd, textColorValue, fillColorValue)
	-- let's say the
	-- fillColorValue is 41
	-- textColorValue is 30
	-- textToAdd is "Hello"
	-- This adds to text \x1b[30;40mHello\x1b[0m
	-- which add Hello with red background and black letters
	-- [0m at the end turns off all attributes
	text = text..ansiEscChar.."["..textColorValue..";"..fillColorValue.."m"..textToAdd..ansiEscChar.."[0m"
	return text
end

---
-- Adds a new segment to the prompt with the specified colors.
-- text {string} Text of the new segment to be added to the prompt.
-- textColor {color} Foreground color of the new segment. Use one of the color constants as input.
-- fillColor {color} Background color of the new segment. Use one of the color constants as input.
-- @return {nil} The prompt is reset with the new segments
---
function addSegment(text, textColor, fillColor)
	local newPrompt = ""
	-- If there's an existing segment
	if currentSegments == "" then
		newPrompt = ""
	else
		-- Remove the existing arrow
		-- The last arrow with all its surrounding escape characters and graphics mode settings count as 7 characters
		newPrompt = string.sub(currentSegments, 0, string.len(currentSegments) - 7)
		-- Add arrow with color of new segment
		newPrompt = addArrow(newPrompt, currentFillColor, fillColor)
	end
	-- Write the text with the fill color
	newPrompt = addTextWithColor(newPrompt, text, textColor.foreground, fillColor.background)
	-- Write the closing arrow
	newPrompt = addArrow(newPrompt, fillColor, colorDefault)

	-- Update current values
	currentSegments = newPrompt
	currentFillColor = fillColor
	currentTextColor = textColor

	-- Update clink prompt
	clink.prompt.value = newPrompt
end

---
-- Resets the prompt and all state variables
---
function resetPrompt()
	clink.prompt.value = ""
	currentSegments = ""
	currentFillColor = colorBlue
	currentTextColor = colorWhite
end

---
-- Closes the prompts with a new line and the lamb symbol
---
function closePrompt()
	clink.prompt.value = clink.prompt.value..newLineSymbol..plc_prompt_lambSymbol.." "
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

-- Register filters for resetting the prompt and closing it before and after all addons
clink.prompt.register_filter(resetPrompt, 51)
clink.prompt.register_filter(closePrompt, 99)
