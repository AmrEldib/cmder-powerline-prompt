This page is kept in case the [original page](http://ascii-table.com/ansi-escape-sequences.php) disappears.

# ANSI Escape sequences
## (ANSI Escape codes)

These sequences define functions that change display graphics, control cursor movement, and reassign keys.

ANSI escape sequence is a sequence of ASCII characters, the first two of which are the ASCII "Escape" character 27 (1Bh) and the left-bracket character " [ " (5Bh). The character or characters following the escape and left-bracket characters specify an alphanumeric code that controls a keyboard or display function.

ANSI escape sequences distinguish between uppercase and lowercase letters.

Information is also available on VT100 / VT52 ANSI escape sequences. 

Symbol | Description 
------ | -----------
Esc<b>[</b>Line;Column<b>H</b><br/>Esc<b>[</b>Line;Column<b>f</b> | Cursor Position:<br/> Moves the cursor to the specified position (coordinates).<br/> If you do not specify a position, the cursor moves to the home position at the upper-left corner of the screen (line 0, column 0). This escape sequence works the same way as the following Cursor Position escape sequence.
Esc<b>[</b>Value<b>A</b> |	Cursor Up: <br/>Moves the cursor up by the specified number of lines without changing columns. If the cursor is already on the top line, ANSI.SYS ignores this sequence.
Esc<b>[</b>Value<b>B</b> |	Cursor Down: <br/>Moves the cursor down by the specified number of lines without changing columns. If the cursor is already on the bottom line, ANSI.SYS ignores this sequence.
Esc<b>[</b>Value<b>C</b> |	Cursor Forward:<br/>Moves the cursor forward by the specified number of columns without changing lines. If the cursor is already in the rightmost column, ANSI.SYS ignores this sequence.
Esc<b>[</b>Value<b>D</b> |	Cursor Backward:<br/>Moves the cursor back by the specified number of columns without changing lines. If the cursor is already in the leftmost column, ANSI.SYS ignores this sequence.
Esc<b>[s</b> |	Save Cursor Position:<br/>Saves the current cursor position. You can move the cursor to the saved cursor position by using the Restore Cursor Position sequence.
Esc<b>[u</b> |	Restore Cursor Position:<br/>Returns the cursor to the position stored by the Save Cursor Position sequence.
Esc<b>[2J</b> |	Erase Display:<br/>Clears the screen and moves the cursor to the home position (line 0, column 0).
Esc<b>[K</b> |	Erase Line:<br/>Clears all characters from the cursor position to the end of the line (including the character at the cursor position). 