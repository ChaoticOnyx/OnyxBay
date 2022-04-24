/obj/structure/bed/chair/snowbike
	name = "Snowbike"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "snowbike_1"
	base_icon = "snowbike_1"
	anchored = 0
	density = 1
	foldable = FALSE
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/callme = "pimpin' ride"

/obj/structure/bed/chair/snowbike/New()
	icon_state = "snowbike_[rand(1,3)]"

/obj/structure/bed/chair/snowbike/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/key/snowbike))
		user << "Hold [W] in one of your hands while you drive this [callme]."


/obj/structure/bed/chair/snowbike/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis)
		unbuckle_mob()
	if(istype(user.l_hand, /obj/item/key) || istype(user.r_hand, /obj/item/key))
		step(src, direction)
		update_mob()
	else
		to_chat(user, "<span class='notice'>You'll need the keys in one of your hands to drive this [callme].</span>")

/obj/structure/bed/chair/snowbike/Move()
	..()
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			buckled_mob.loc = loc

/obj/structure/bed/chair/snowbike/Move()
	..()
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			buckled_mob.loc = loc


/obj/structure/bed/chair/snowbike/post_buckle_mob(mob/living/M)
	update_mob()
	return ..()


/obj/structure/bed/chair/snowbike/unbuckle_mob()
	var/mob/living/M = ..()
	if(M)
		M.pixel_x = 0
		M.pixel_y = 0
	return M


/obj/structure/bed/chair/snowbike/set_dir()
	..()
	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null //Temporary, so Move() succeeds.
			buckled_mob.buckled = src //Restoring

	update_mob()

/obj/structure/bed/chair/snowbike/proc/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir
		switch(dir)
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 6
			if(WEST)
				buckled_mob.pixel_x = 2
				buckled_mob.pixel_y = 6
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 6
			if(EAST)
				buckled_mob.pixel_x = -2
				buckled_mob.pixel_y = 6

/obj/structure/bed/chair/snowbike/bullet_act(obj/item/projectile/Proj)
	if(buckled_mob)
		if(prob(65))
			return buckled_mob.bullet_act(Proj)
	visible_message("<span class='warning'>[Proj] ricochets off the [callme]!</span>")

/obj/item/key/snowbike
	name = "key"
	desc = "A keyring with a small steel key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "seckeys"
	w_class = 1
