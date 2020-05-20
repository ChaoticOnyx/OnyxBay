/obj/item/device/ai_remote
	name = "AI remote control circuit"
	desc = "This device can be placed into a cyborg instead of its processor, rendering it mindless and non-autonomous, but allowing AI to assume direct control."
	origin_tech = list(TECH_MAGNET = 3, TECH_ENGINEERING = 3, TECH_MATERIAL = 2)
	icon_state = "airemote"

/mob/living/silicon/ai
	var/mob/living/silicon/robot/remotable/controlling_robot

/mob/living/silicon/robot/remotable
	var/mob/living/silicon/ai/controlling_ai

/mob/living/silicon/robot/remotable/attack_ai(mob/living/silicon/ai/user)

	if(!istype(user) || controlling_ai)
		return

	if(client || key) // In case if some admin's put a player into a remotable cyborg. Shame on that person though ~Toby
		to_chat(user, SPAN("warning", "You cannot take control of an autonomous, active cyborg."))
		return

	if(health < -35)
		to_chat(user, SPAN("notice", "<b>WARNING:</b> connection timed out."))
		return

	assume_control(user)

/mob/living/silicon/robot/remotable/proc/assume_control(mob/living/silicon/ai/user)
	user.controlling_robot = src
	controlling_ai = user
	verbs += /mob/living/silicon/robot/remotable/proc/release_ai_control_verb
	local_transmit = FALSE
	languages = controlling_ai.languages.Copy()
	add_language("Robot Talk", 1)

	default_language = all_languages[LANGUAGE_GALCOM]

	stat = CONSCIOUS
	if(user.mind)
		user.mind.transfer_to(src)
	else
		key = user.key
	updatename()
	qdel(silicon_radio)
	silicon_radio = new /obj/item/device/radio/headset/heads/ai_integrated(src)

	to_chat(src, SPAN("notice", "<b>You have shunted your primary control loop into \a [initial(name)].</b> Use the <b>Release Control</b> verb to return to your core."))

/mob/living/silicon/robot/remotable/death(gibbed, ai_release)
	if(controlling_ai)
		release_ai_control("<b>WARNING: remote system failure.</b> Connection timed out.")
	. = ..(gibbed, ai_release)

/mob/living/silicon/ai/death(gibbed)
	if(controlling_robot)
		controlling_robot.release_ai_control("<b>WARNING: Primary control loop failure.</b> Session terminated.")
	. = ..(gibbed)

/mob/living/silicon/ai/Life()
	. = ..()
	if(controlling_robot && stat != CONSCIOUS)
		controlling_robot.release_ai_control("<b>WARNING: Primary control loop failure.</b> Session terminated.")

/mob/living/silicon/robot/remotable/proc/release_ai_control_verb()
	set name = "Release Control"
	set desc = "Release control of a cyborg."
	set category = "Silicon Commands"

	release_ai_control("Remote session terminated.")

/mob/living/silicon/robot/remotable/proc/release_ai_control(message = "Connection terminated.")

	if(controlling_ai)
		if(mind)
			mind.transfer_to(controlling_ai)
		else
			controlling_ai.key = key
		to_chat(controlling_ai, SPAN("notice", message))
		controlling_ai.controlling_robot = null
		controlling_ai = null

	verbs -= /mob/living/silicon/robot/remotable/proc/release_ai_control_verb
	full_law_reset()
	updatename()
	death(FALSE, TRUE)

/mob/living/silicon/robot/remotable/proc/full_law_reset()
	clear_supplied_laws(1)
	clear_inherent_laws(1)
	clear_ion_laws(1)
	QDEL_NULL(laws)
	var/law_type = initial(laws) || GLOB.using_map.default_law_type
	laws = new law_type
