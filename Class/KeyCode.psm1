$script:AdbKeyCodes = @(
    "UNKNOWN", "MENU", "SOFT_RIGHT", "HOME",
    "BACK", "CALL", "ENDCALL",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "STAR", "POUND",
    "DPAD_UP", "DPAD_DOWN", "DPAD_LEFT", "DPAD_RIGHT", "DPAD_CENTER",
    "VOLUME_UP", "VOLUME_DOWN",
    "POWER", "CAMERA", "CLEAR",
    "A", "B", "C", "D",
    "E", "F", "G", "H",
    "I", "J", "K", "L",
    "M", "N", "O", "P",
    "Q", "R", "S", "T",
    "U", "V", "W", "X", "Y", "Z",
    "COMMA", "PERIOD",
    "ALT_LEFT", "ALT_RIGHT",
    "CTRL_LEFT", "CTRL_RIGHT",
    "SHIFT_LEFT", "SHIFT_RIGHT",
    "TAB", "SPACE", "SYM", "EXPLORER",
    "ENVELOPE", "ENTER", "DEL", "GRAVE",
    "MINUS", "EQUALS",
    "LEFT_BRACKET", "RIGHT_BRACKET",
    "BACKSLASH", "SEMICOLON", "APOSTROPHE", "SLASH", "AT", "NUM",
    "HEADSETHOOK", "FOCUS", "PLUS",
    "MENU", "NOTIFICATION", "SEARCH",
    "ESCAPE", "BUTTON_START",
    "TAG_LAST_KEYCODE",
    "PAGE_UP", "PAGE_DOWN",
    "PASTE"
)

class KeyCode : System.Management.Automation.IValidateSetValuesGenerator {

    [string[]] GetValidValues() {
        return $script:AdbKeyCodes
    }
}
