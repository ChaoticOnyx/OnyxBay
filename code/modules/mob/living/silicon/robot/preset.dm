/mob/living/silicon/robot/syndicate
	lawupdate = 0
	scrambledcodes = 1
	icon_state = "securityrobot"
	bubble_icon = "syndibot"
	modtype = "Security"
	lawchannel = "State"
	laws = /datum/ai_laws/syndicate_override
	idcard = /obj/item/card/id/syndicate
	module = /obj/item/robot_module/syndicate
	silicon_radio = /obj/item/device/radio/borg/syndicate
	spawn_sound = 'sound/mecha/nominalsyndi.ogg'
	cell = /obj/item/cell/super
	pitch_toggle = 0
	custom_sprite = FALSE // presets robots must not have custom sprites.

/mob/living/silicon/robot/qualified_doctor
	lawupdate = 0
	scrambledcodes = 1
	icon_state = "qualified_doctor"
	bubble_icon = "syndibot"
	modtype = "Medical"
	lawchannel = "State"
	laws = /datum/ai_laws/qualified_doctor
	module = /obj/item/robot_module/medical/qualified_doctor
	spawn_sound = 'sound/mecha/nominalnano.ogg'
	cell = /obj/item/cell/super
	pitch_toggle = 0
	custom_sprite = FALSE // presets robots must not have custom sprites.

	var/list/wizardy_spells = list(/datum/spell/targeted/say/standart_medbot, /datum/spell/targeted/say/target_medbot, /datum/spell/targeted/say/after_heal_medbot, /datum/spell/targeted/say/dead_pacient_medbot)


/mob/living/silicon/robot/qualified_doctor/Initialize(mapload, ...)
	. = ..()
	for(var/spell in wizardy_spells)
		src.add_spell(new spell, "const_spell_ready")

/mob/living/silicon/robot/combat
	lawupdate = 0
	scrambledcodes = 1
	modtype = "Combat"
	module = /obj/item/robot_module/security/combat
	spawn_sound = 'sound/mecha/nominalsyndi.ogg'
	cell = /obj/item/cell/super
	pitch_toggle = 0
	custom_sprite = FALSE // presets robots must not have custom sprites.

/mob/living/silicon/robot/combat/nt
	laws = /datum/ai_laws/nanotrasen_aggressive
	idcard = /obj/item/card/id/centcom/ERT
	silicon_radio = /obj/item/device/radio/borg/ert
	custom_sprite = FALSE // presets robots must not have custom sprites.
