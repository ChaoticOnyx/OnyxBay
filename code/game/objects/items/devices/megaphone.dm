#define MEGAPHONE_COOLDOWN 2 SECONDS

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

	/// Amount of insults left before megaphone will return to normal.
	var/insults_left = 0
	/// List of possible insults.
	var/static/list/insults = list("FUCK EVERYONE!", "I'M A TATER!", "ALL SECURITY TO SHOOT ME ON SIGHT!", "I HAVE A BOMB!", "CAPTAIN IS A COMDOM!", "FOR THE SYNDICATE!")


/obj/item/device/megaphone/on_update_icon()
	icon_state = "megaphone[active ? "_on" : ""]"


/obj/item/device/megaphone/Initialize()
	GLOB.listening_objects |= src
	return ..()


/obj/item/device/megaphone/Destroy()
	GLOB.listening_objects -= src
	return ..()


/obj/item/device/megaphone/attack_self(mob/living/user)
	show_splash_text(user, "toggled [active ? "off" : "on"]")
	active = !active
	update_icon()


/obj/item/device/megaphone/hear_talk(mob/M, text, verb, datum/language/speaking)
	if(!active)
		return

	if(M != loc)
		return

	if(world.time <= last_use + MEGAPHONE_COOLDOWN)
		show_splash_text(loc, "needs to recharge!")
		return

	_speak(M, capitalize(text), speaking, !!length(insults_left))


/obj/item/device/megaphone/proc/_speak(mob/living/talker, message, datum/language/speaking, emagged = FALSE)
	var/msg = emagged ? pick(insults) : message
	if(insults_left)
		insults_left--

	for(var/mob/O in viewers(talker))
		O.hear_say(FONT_GIANT(msg), "broadcasts", speaking, speaker = talker, speech_sound = 'sound/items/megaphone.ogg', sound_vol = 20)

	for(var/obj/item/device/radio/intercom/I in view(3, talker))
		I.talk_into(talker, msg, verb = "shout", speaking = speaking)

	last_use = world.time


/obj/item/device/megaphone/emag_act(remaining_charges, mob/user)
	if(emagged)
		return

	show_splash_text(user, "overload voice synthesizer!")
	emagged = TRUE
	insults_left = rand(1, 3)

#undef MEGAPHONE_COOLDOWN
