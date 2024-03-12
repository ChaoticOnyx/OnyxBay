#define MEGAPHONE_COOLDOWN 2 SECONDS

GLOBAL_LIST_INIT(megaphone_insults, world.file2list("config/translation/megaphone_insults.txt"))

/obj/item/device/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."

	icon_state = "megaphone"
	item_state = "radio"

	w_class = ITEM_SIZE_SMALL
	obj_flags = OBJ_FLAG_CONDUCTIBLE

	var/active = FALSE
	var/emagged = FALSE

	/// Last `world.time` device was successfully used.
	var/last_use = 0


/obj/item/device/megaphone/on_update_icon()
	icon_state = "megaphone[active ? "_on" : ""]"

/obj/item/device/megaphone/attack_self(mob/living/user)
	show_splash_text(user, "toggled [active ? "off" : "on"]")
	active = !active
	update_icon()

/obj/item/device/megaphone/hear_say(message, verb, datum/language/language, alt_name, italics, mob/speaker, sound/speech_sound, sound_vol)
	if(!active)
		return

	if(speaker != loc)
		return

	if(world.time <= last_use + MEGAPHONE_COOLDOWN)
		show_splash_text(loc, "needs to recharge!")
		return

	_speak(speaker, capitalize(message), language)

/obj/item/device/megaphone/proc/_speak(mob/living/talker, message, datum/language/speaking)
	var/msg = emagged && prob(50) ? pick(GLOB.megaphone_insults) : message

	var/list/hearing = get_hearers_in_view(world.view, talker)

	for(var/mob/O in hearing)
		O.hear_say(FONT_GIANT(SPAN_BOLD(msg)), "broadcasts", speaking, speaker = talker, speech_sound = 'sound/items/megaphone.ogg', sound_vol = 20)

	for(var/obj/item/device/radio/intercom/I in hearing)
		I.talk_into(talker, msg, verb = "broadcasts", speaking = speaking)

	last_use = world.time

/obj/item/device/megaphone/emag_act(remaining_charges, mob/user)
	if(emagged)
		return FALSE

	show_splash_text(user, "overload voice synthesizer!")
	emagged = TRUE
	return TRUE

#undef MEGAPHONE_COOLDOWN
