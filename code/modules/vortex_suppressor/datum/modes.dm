/datum/suppressor_mode
	var/mode_name			// User-friendly name of this mode.
	var/mode_desc			// A short description of what the mode does.
	var/mode_flag			// Mode bitflag. See defines file.
	var/multiplier			// Energy usage multiplier. Each enabled mode multiplies upkeep power usage by this number. Values between 1-2 are good balance-wise. Hacked modes can go up to 3-4

/datum/suppressor_mode/incoming
	mode_name = "Incoming"
	mode_desc = "This mode blocks incoming vortex flow."
	mode_flag = MODEFLAG_VORTEX_SUPPRESSOR_INCOMING
	multiplier = 0.5

/datum/suppressor_mode/outgoing
	mode_name = "Outgoing"
	mode_desc = "This mode blocks outgoing vortex flow."
	mode_flag = MODEFLAG_VORTEX_SUPPRESSOR_OUTGOING
	multiplier = 0.5