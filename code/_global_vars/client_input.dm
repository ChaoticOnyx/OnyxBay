GLOBAL_LIST_EMPTY(hotkey_keybinding_list_by_key)
GLOBAL_LIST_INIT(keybindings_by_name, init_kb_by_name())

/proc/init_kb_by_name()
	var/list/keybindings = list()
	for(var/path in subtypesof(/datum/keybinding))
		var/datum/keybinding/keybinding = path
		if(!keybinding::name)
			continue

		var/datum/keybinding/instance = new keybinding()
		keybindings[instance.name] = instance
		if(length(instance.hotkey_keys))
			for(var/bound_key in instance.hotkey_keys)
				GLOB.hotkey_keybinding_list_by_key[bound_key] += list(instance.name)

	return keybindings

// This is a mapping from JS keys to Byond - ref: https://keycode.info/
GLOBAL_LIST_INIT(_kbMap, list(
	"UP"       = "North",
	"RIGHT"    = "East",
	"DOWN"     = "South",
	"LEFT"     = "West",
	"INSERT"   = "Insert",
	"HOME"     = "Northwest",
	"PAGEUP"   = "Northeast",
	"DEL"      = "Delete",
	"END"      = "Southwest",
	"PAGEDOWN" = "Southeast",
	"SPACEBAR" = "Space",
	"ALT"      = "Alt",
	"SHIFT"    = "Shift",
	"CONTROL"  = "Ctrl"
))

// Without alt, shift, ctrl and etc because its not necessary
GLOBAL_LIST_INIT(_kbMap_reverse, list(
	"North" = "Up",
	"East" = "Right",
	"South" = "Down",
	"West" = "Left",
	"Northwest" = "Home",
	"Northeast" = "PageUp",
	"Southwest" = "End",
	"Southeast" = "PageDown",
))
