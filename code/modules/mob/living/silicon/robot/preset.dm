/mob/living/silicon/robot/syndicate
	lawupdate = 0
	scrambledcodes = 1
	icon_state = "securityrobot"
	modtype = "Security"
	lawchannel = "State"
	laws = /datum/ai_laws/syndicate_override
	idcard = /obj/item/weapon/card/id/syndicate
	module = /obj/item/weapon/robot_module/syndicate
	silicon_radio = /obj/item/device/radio/borg/syndicate
	spawn_sound = 'sound/mecha/nominalsyndi.ogg'
	cell = /obj/item/weapon/cell/super
	pitch_toggle = 0

/mob/living/silicon/robot/combat
	lawupdate = 0
	scrambledcodes = 1
	modtype = "Combat"
	module = /obj/item/weapon/robot_module/security/combat
	spawn_sound = 'sound/mecha/nominalsyndi.ogg'
	cell = /obj/item/weapon/cell/super
	pitch_toggle = 0

/mob/living/silicon/robot/combat/nt
	laws = /datum/ai_laws/nanotrasen_aggressive
	idcard = /obj/item/weapon/card/id/centcom/ERT
	silicon_radio = /obj/item/device/radio/borg/ert

/mob/living/silicon/robot/remotable/curio
	icon_state = "curio"
	modtype  = "AI"
	module = /obj/item/weapon/robot_module/curio
	cell = /obj/item/weapon/cell/super
	remotable = 1
	var/icon/hair_style
	var/icon/holo_icon
	var/holooverlay = FALSE

/mob/living/silicon/robot/remotable/curio/New()
	..()
	holo_icon = icon('icons/mob/hologram.dmi',"Default-Slim")
	holo_icon.ChangeOpacity(0.7)//Make it kinda transparent.
	var/icon/alpha_mask = new('icons/effects/effects.dmi', "scanline-[HOLOPAD_SHORT_RANGE]")//Scanline effect.
	holo_icon.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.

/mob/living/silicon/robot/remotable/curio/update_icon()
	..()
	overlays += hair_style
	if(holooverlay && stat == CONSCIOUS)
		overlays += holo_icon

/mob/living/silicon/robot/remotable/curio/verb/toggleholo()
	set name = "Toggle Hologram"
	set desc = "Toggles holographic overlay."
	set category = "Silicon Commands"

	holooverlay = !holooverlay
	to_chat(src, "Holographic overlay [holooverlay ? "activated" : "deactivated"].")
	update_icon()

/*/mob/living/silicon/robot/remotable/curio/verb/changehairverb() // Hopefully, somebody's gonna find out how to make this shit work. I give up ~Toby
	set name = "Change Appearance"
	set desc = "Change your synth-hair shape."
	set category = "Silicon Commands"

	var/new_h_color = input(src, "Choose your character's hair colour:") as color|null
	var/list/valid_hairstyles = all_species[SPECIES_HUMAN].get_hair_styles()
	var/new_h_style = input(src, "Choose your character's hair style:") as null|anything in valid_hairstyles

	if(new_h_color)
		to_chat(src, "New hair color")
	if(new_h_style)
		to_chat(src, "New hair style [new_h_style]")

	if(new_h_color && new_h_style)
		var/datum/sprite_accessory/hair/hair_style = GLOB.hair_styles_list[new_h_style]
		to_chat(src, "Hair_Style initialized")
		var/icon/hair_s = new /icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[new_h_style]_s")
		to_chat(src, "Hair Icon set")
		hair_s.ColorTone(new_h_color, hair_style.blend)
		to_chat(src, "Hair color blend")
		hair_style = hair_s
	update_icon()*/
