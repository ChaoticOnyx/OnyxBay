/decl/emote/human
	key = "vomit"

/decl/emote/human/check_user(mob/living/carbon/human/user)
	return (istype(user) && user.check_has_mouth() && !user.isSynthetic())

/decl/emote/human/do_emote(mob/living/carbon/human/user)
	user.vomit()

/decl/emote/human/deathgasp
	key = "deathgasp"

/decl/emote/human/deathgasp/get_emote_message_3p(mob/living/carbon/human/user)
	return "USER [user.species.get_death_message()]"

/decl/emote/human/dance
	key = "dance"
	var/list/mob/living/carbon/human/dancing = list()

/decl/emote/human/dance/do_emote(mob/living/carbon/human/user)
	if(weakref(user) in dancing)
		dancing.Remove(weakref(user))
		return

	dancing.Add(weakref(user))
	user.pixel_y = initial(user.pixel_y)
	var/oldpixely = user.pixel_y
	while(weakref(user) in dancing)
		var/pixely = rand(5, 6)
		animate(user, pixel_y = pixely, time = 0.5)
		sleep(1)
		animate(user, pixel_y = oldpixely, time = 0.7)
		sleep(2)
		animate(user, pixel_y = 2, time = 0.2)
		sleep(1)
		animate(user, pixel_y = oldpixely, time = 0.2)
		if(user.resting || user.buckled || user.stat)
			dancing.Remove(weakref(user))
			break

/decl/emote/human/swish
	key = "swish"

/decl/emote/human/swish/do_emote(mob/living/carbon/human/user)
	user.animate_tail_once()

/decl/emote/human/wag
	key = "wag"

/decl/emote/human/wag/do_emote(mob/living/carbon/human/user)
	user.animate_tail_start()

/decl/emote/human/sway
	key = "sway"

/decl/emote/human/sway/do_emote(mob/living/carbon/human/user)
	user.animate_tail_start()

/decl/emote/human/qwag
	key = "qwag"

/decl/emote/human/qwag/do_emote(mob/living/carbon/human/user)
	user.animate_tail_fast()

/decl/emote/human/fastsway
	key = "fastsway"

/decl/emote/human/fastsway/do_emote(mob/living/carbon/human/user)
	user.animate_tail_fast()

/decl/emote/human/swag
	key = "swag"

/decl/emote/human/swag/do_emote(mob/living/carbon/human/user)
	user.animate_tail_stop()

/decl/emote/human/stopsway
	key = "stopsway"

/decl/emote/human/stopsway/do_emote(mob/living/carbon/human/user)
	user.animate_tail_stop()
