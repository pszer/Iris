--[[ keybinds are stored here
--   its the keybindings file :)))))
--]]
--

VALID_SCANCODES = {
"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
"1","2","3","4","5","6","7","8","9","0",
"return","escape","backspace","tab","space","-","=","[","]","\\","#","*","@","?",";","'","`",",",".","/",
"capslock","f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15","f16","f17","f18","f19","f20","f21","f22","f23","f24",
"lctrl","lshift","lalt","lgui","rctrl","rshift","ralt","rgui","printscreen","scrolllock","pause","insert","home",
"numlock","pageup","delete","end","pagedown","right","left","down","up","nonusbackslash","application","execute",
"help","menu","select","stop","again","undo","cut","copy","paste","find","kp/","kp*","kp-","kp+","kp=","kpenter",
"kp1","kp2","kp3","kp4","kp5","kp6","kp7","kp8","kp9","kp0","kp.",
"international1","international2","international3","international4","international5","international6","international7","international8","international9","lang1","lang2","lang3","lang4","lang5",
"mute","volumeup","volumedown","audionext","audioprev","audiostop","audioplay","audiomute","mediaselect",
"www","mail","calculator","computer","acsearch","achome","acback","acforward","acstop","acrefresh","acbookmarks",
"power","brightnessdown","brightnessup","displayswitch","kbdillumtoggle","kbdillumdown","kbdillumup","eject",
"sleep","alterase","sysreq","cancel","clear","prior","return2","separator","out","oper","clearagain","crsel",
"exsel","kp00","kp000","thsousandsseparator","decimalseparator","currencyunit","currencysubunit","app1","app2","unknown",
-- i wish mouse buttons were treated like keyboard buttons :(
"mouse1","mouse2","mouse3","mouse4","mouse5"
}

function IS_VALID_SCANCODE(sc)
	for _,v in pairs(VALID_SCANCODES) do
		if v == sc then return true end
	end
	return false
end

KEYBINDS = {
	MV_LEFT  = "left",
	MV_RIGHT = "right",
	MV_DOWN  = "down",
	MV_UP    = "up",
	MV_JUMP  = "z"
}

function SET_KEYBIND(bind, scancode)
	if not IS_VALID_SCANCODE(scancode) then
		print(scancode, "is not a valid scancode")
	else
		KEYBINDS[bind] = scancode
	end
end
