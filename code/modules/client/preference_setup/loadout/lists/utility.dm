// "Useful" items - I'm guessing things that might be used at work?
/datum/gear/utility
	sort_category = "Utility"

/datum/gear/utility/briefcase
	display_name = "briefcase"
	path = /obj/item/weapon/storage/briefcase
	cost = 2

/datum/gear/utility/clipboard
	display_name = "clipboard"
	path = /obj/item/weapon/clipboard

/datum/gear/utility/folder
	display_name = "folders"
	path = /obj/item/weapon/folder

/datum/gear/utility/taperecorder
	display_name = "tape recorder"
	path = /obj/item/device/taperecorder
	cost = 2

/datum/gear/utility/folder/New()
	..()
	var/folders = list()
	folders["blue folder"] = /obj/item/weapon/folder/blue
	folders["grey folder"] = /obj/item/weapon/folder
	folders["red folder"] = /obj/item/weapon/folder/red
	folders["white folder"] = /obj/item/weapon/folder/white
	folders["yellow folder"] = /obj/item/weapon/folder/yellow
	gear_tweaks += new /datum/gear_tweak/path(folders)

/datum/gear/utility/paicard
	display_name = "personal AI device"
	path = /obj/item/device/paicard
	cost = 2

/datum/gear/utility/camera
	display_name = "camera"
	path = /obj/item/device/camera
	cost = 2

/datum/gear/utility/stethoscope
	display_name = "stethoscope (medical)"
	path = /obj/item/clothing/accessory/stethoscope
	cost = 2

/datum/gear/mask/gas
	sort_category = "Utility"
	display_name = "old gas mask"
	path = /obj/item/clothing/mask/gas/old
	cost = 3

/datum/gear/mask/gas/clear
	display_name = "clear gas mask"
	path = /obj/item/clothing/mask/gas/clear
	price = 15

/datum/gear/utility/music_tape_custom
	display_name = "music tape (custom)"
	description = {"
		A dusty tape, which can hold anything. Only what you need is blow the dust away and you will be able to play it again.
		<br><br>
		<b>Be careful!</b> Don't use it to play music/sounds which can be annoying for other players. Admins can erase your music if they consider it unacceptable or even ban you for abusing it.
	"}
	path = /obj/item/music_tape/custom
	patron_tier = PATREON_HOS

/datum/gear/utility/boombox
	display_name = "boombox"
	description = {"
		A musical audio player station, also known as boombox or ghettobox. Very robust.
		<br><br>
		<b>Be careful!</b> Don't use it to play music/sounds which can be annoying for other players. Admins can delete your boombox if they consider your music unacceptable or even ban you for abusing it.
	"}
	path = /obj/item/music_player/boombox
	flags = GEAR_HAS_COLOR_SELECTION
	patron_tier = PATREON_ASSISTANT
	cost = 4

/****************
modular computers
****************/

/datum/gear/utility/cheaptablet
	display_name = "tablet computer, cheap"
	path = /obj/item/modular_computer/tablet/preset/custom_loadout/cheap
	cost = 3

/datum/gear/utility/normaltablet
	display_name = "tablet computer, advanced"
	path = /obj/item/modular_computer/tablet/preset/custom_loadout/advanced
	cost = 4

/datum/gear/utility/customtablet
	display_name = "tablet computer, custom"
	path = /obj/item/modular_computer/tablet
	cost = 4

/datum/gear/utility/customtablet/New()
	..()
	gear_tweaks += new /datum/gear_tweak/tablet()

/datum/gear/utility/cheaplaptop
	display_name = "laptop computer, cheap"
	path = /obj/item/modular_computer/laptop/preset/custom_loadout/cheap
	cost = 5

/datum/gear/utility/normallaptop
	display_name = "laptop computer, advanced"
	path = /obj/item/modular_computer/laptop/preset/custom_loadout/advanced
	cost = 6
