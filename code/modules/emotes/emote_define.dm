// Note about emote messages:
// - USER / TARGET will be replaced with the relevant name, in bold.
// - USER_THEM / TARGET_THEM / USER_THEIR / TARGET_THEIR will be replaced with a
//   gender-appropriate version of the same.
// - Impaired messages do not do any substitutions.

/decl/emote

	var/key                            // Command to use emote ie. '*[key]'
	var/emote_message_1p               // First person message ('You do a flip!')
	var/emote_message_3p               // Third person message ('Urist McShitter does a flip!')
	var/emote_message_impaired         // Deaf/blind message ('You hear someone flipping out.', 'You see someone opening and closing their mouth')

	var/emote_message_1p_target        // 'You do a flip at Urist McTarget!'
	var/emote_message_3p_target        // 'Urist McShitter does a flip at Urist McTarget!'

	var/message_type = VISIBLE_MESSAGE // Audible/visual flag
	var/targetted_emote                // Whether or not this emote needs a target.
	var/check_restraints               // Can this emote be used while restrained?
	var/conscious = 1				   // Do we need to be awake to emote this?

/decl/emote/proc/get_emote_message_1p(atom/user, atom/target, extra_params)
	if(target)
		return emote_message_1p_target
	return emote_message_1p

/decl/emote/proc/get_emote_message_3p(atom/user, atom/target, extra_params)
	if(target)
		return emote_message_3p_target
	return emote_message_3p

/decl/emote/proc/play_emote_sound(mob/user, key, datum/gender/user_gender)
	if (user.type != /mob/living/carbon/human)
		return

	if (world.time > user.lastemote + 5 SECONDS)
		user.lastemote = world.time
	else
		return

	var/gender_prefix = ""

	if (istype(user_gender, /datum/gender/male))
		gender_prefix = "male"
	else
		gender_prefix = "female"

	switch (key)
		if ("cough")
			playsound(user, "[gender_prefix]_cough", rand(25, 40), FALSE)
		if ("scream")
			playsound(user, "[gender_prefix]_pain", rand(25, 40), FALSE)
		if ("gasp","choke")
			playsound(user, "[gender_prefix]_breath", rand(25, 40), FALSE)
		if ("sneeze")
			playsound(user, "[gender_prefix]_sneeze", rand(25, 40), FALSE)
		if ("long_scream")
			playsound(user, "[gender_prefix]_long_scream", rand(25, 40), FALSE)

/decl/emote/proc/do_emote(atom/user, extra_params)

	if(ismob(user) && check_restraints)
		var/mob/M = user
		if(M.restrained())
			to_chat(user, "<span class='warning'>You are restrained and cannot do that.</span>")
			return

	var/atom/target
	if(can_target() && extra_params)
		extra_params = lowertext(extra_params)
		for(var/atom/thing in view(user))
			if(extra_params == lowertext(thing.name))
				target = thing
				break

	var/datum/gender/user_gender = gender_datums[user.gender]
	var/datum/gender/target_gender
	if(target)
		target_gender = gender_datums[target.gender]

	var/use_3p
	var/use_1p
	if(emote_message_1p)
		if(target && emote_message_1p_target)
			use_1p = get_emote_message_1p(user, target, extra_params)
			use_1p = replacetext(use_1p, "TARGET_THEM", target_gender.him)
			use_1p = replacetext(use_1p, "TARGET_THEIR", target_gender.his)
			use_1p = replacetext(use_1p, "TARGET", "<b>\the [target]</b>")
		else
			use_1p = get_emote_message_1p(user, null, extra_params)
		use_1p = capitalize(use_1p)

	if(emote_message_3p)
		if(target && emote_message_3p_target)
			use_3p = get_emote_message_3p(user, target, extra_params)
			use_3p = replacetext(use_3p, "TARGET_THEM", target_gender.him)
			use_3p = replacetext(use_3p, "TARGET_THEIR", target_gender.his)
			use_3p = replacetext(use_3p, "TARGET", "<b>\the [target]</b>")
		else
			use_3p = get_emote_message_3p(user, null, extra_params)
		use_3p = replacetext(use_3p, "USER_THEM", user_gender.him)
		use_3p = replacetext(use_3p, "USER_THEIR", user_gender.his)
		use_3p = replacetext(use_3p, "USER", "<b>\the [user]</b>")
		use_3p = capitalize(use_3p)

	if(message_type == AUDIBLE_MESSAGE)
		play_emote_sound(user, key, user_gender)

		user.audible_message(message = use_3p, deaf_message = emote_message_impaired, checkghosts = /datum/client_preference/ghost_sight)
	else
		user.visible_message(message = use_3p, blind_message = emote_message_impaired, checkghosts = /datum/client_preference/ghost_sight)

	do_extra(user, target)

/decl/emote/proc/do_extra(atom/user, atom/target)
	return

/decl/emote/proc/check_user(atom/user)
	return TRUE

/decl/emote/proc/can_target()
	return (emote_message_1p_target || emote_message_3p_target)

/decl/emote/dd_SortValue()
	return key
