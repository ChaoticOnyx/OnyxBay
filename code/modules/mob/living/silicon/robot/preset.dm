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

/mob/living/silicon/robot/remotable
	remotable = 1

/mob/living/silicon/robot/remotable/curio
	icon_state = "curio"
	modtype  = "AI"
	module = /obj/item/weapon/robot_module/curio
	cell = /obj/item/weapon/cell/super
	remotable = 1
	var/holooverlay = FALSE
	var/icon/holo_icon

/mob/living/silicon/robot/remotable/curio/New()
	..()
	holo_icon = icon('icons/mob/hologram.dmi',"Default-Slim")
	holo_icon.ChangeOpacity(0.7)//Make it kinda transparent.
	var/icon/alpha_mask = new('icons/effects/effects.dmi', "scanline-[HOLOPAD_SHORT_RANGE]")//Scanline effect.
	holo_icon.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.
	death(0,1)

/mob/living/silicon/robot/remotable/curio/update_icon()
	..()
	if(holooverlay && stat == CONSCIOUS)
		overlays += holo_icon

/mob/living/silicon/robot/remotable/curio/verb/toggleholo()
	set name = "Toggle Hologram"
	set desc = "Toggles holographic overlay."
	set category = "Silicon Commands"

	holooverlay = !holooverlay
	to_chat(src, "Holographic overlay [holooverlay ? "activated" : "deactivated"].")
	update_icon()
