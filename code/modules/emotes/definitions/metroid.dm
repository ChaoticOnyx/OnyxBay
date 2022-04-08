/decl/emote/metroid
	key = "nomood"
	var/mood

/decl/emote/metroid/do_extra(mob/living/carbon/metroid/user)
	user.mood = mood
	user.regenerate_icons()

/decl/emote/metroid/check_user(atom/user)
	return istype(user, /mob/living/carbon/metroid)

/decl/emote/metroid/pout
	key = "pout"
	mood = "pout"

/decl/emote/metroid/sad
	key = "sad"
	mood = "sad"

/decl/emote/metroid/angry
	key = "angry"
	mood = "angry"

/decl/emote/metroid/frown
	key = "frown"
	mood = "mischevous"

/decl/emote/metroid/smile
	key = "smile"
	mood = ":3"
