/obj/item/device/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone"
	item_state = "radio"
	w_class = ITEM_SIZE_SMALL
	obj_flags = OBJ_FLAG_CONDUCTIBLE

	var/spamcheck = 0
	var/emagged = FALSE
	var/insults = 0
	var/list/insultmsg = list("FUCK EVERYONE!", "I'M A TATER!", "ALL SECURITY TO SHOOT ME ON SIGHT!", "I HAVE A BOMB!", "CAPTAIN IS A COMDOM!", "FOR THE SYNDICATE!")

/obj/item/device/megaphone/attack_self(mob/living/user)
	if (user.client)
		if(user.client.prefs.muted & MUTE_IC)
			to_chat(src, SPAN_WARNING("You cannot speak in IC (muted)."))
			return
	if(user.silent)
		return
	if(spamcheck)
		to_chat(user, SPAN_WARNING("\The [src] needs to recharge!"))
		return

	var/message = sanitize(input(user, "Shout a message?", "Megaphone", null)  as text)
	if(!message)
		return
	message = capitalize(message)
	if ((src.loc == user && user.stat == 0))
		if(emagged)
			if(insults)
				speak(user, message, TRUE)
				insults--
			else
				to_chat(user, SPAN_WARNING("*BZZZZzzzzzt*"))
		else
			speak(user, message)

		spamcheck = 1
		spawn(20)
			spamcheck = 0
		return

/obj/item/device/megaphone/proc/speak(mob/living/user, message, emagged = FALSE)
	for(var/mob/O in (viewers(user)))
		O.show_message("<B>[user]</B> broadcasts, [FONT_GIANT("\"[emagged ? pick(insultmsg) : message]\"")]", AUDIBLE_MESSAGE)
		if(O.get_preference_value(/datum/client_preference/runechat) == GLOB.PREF_YES && !O.is_deaf())
			O.create_chat_message(O, message, FALSE, "big")
	for(var/obj/item/device/radio/intercom/I in view(3, user))
		if(I.broadcasting)
			I.talk_into(user, message, verb = "shout")

/obj/item/device/megaphone/emag_act(remaining_charges, mob/user)
	if(!emagged)
		to_chat(user, SPAN_WARNING("You overload \the [src]'s voice synthesizer."))
		emagged = TRUE
		insults = rand(1, 3)//to prevent dickflooding
		return 1
