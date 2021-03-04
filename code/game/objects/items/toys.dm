/* Toys!
 * Contains:
 *		Balloons
 *		Fake telebeacon
 *		Fake singularity
 *		Toy gun
 *		Toy crossbow
 *		Toy swords
 *		Toy bosun's whistle
 *      Toy mechs
 *		Snap pops
 *		Water flower
 *      Therapy dolls
 *      Inflatable duck
 *		Action figures
 *		Plushies
 *		Toy cult sword
 *		Marshalling wand
 *		Ring bell
 *		BANana
 *		Rubber pigs
 */


/obj/item/toy
	icon = 'icons/obj/toy.dmi'
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	force = 0
	mod_weight = 0.25
	mod_reach = 0.25
	mod_handy = 0.25

/obj/item/toy/proc/speak(message)
	if (!message)
		return

	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='game say'><span class='name'>\The [src]</span> says, \"[message]\"</span>",2)
	return

/*
 * Balloons
 */
/obj/item/toy/water_balloon
	name = "water balloon"
	desc = "A translucent balloon. There's nothing in it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "waterballoon-e"
	item_state = "balloon-empty"

/obj/item/toy/water_balloon/New()
	create_reagents(10)
	..()

/obj/item/toy/water_balloon/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/toy/water_balloon/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return
	if (istype(A, /obj/structure/reagent_dispensers/watertank) && get_dist(src,A) <= 1)
		A.reagents.trans_to_obj(src, 10)
		to_chat(user, "<span class='notice'>You fill the balloon with the contents of [A].</span>")
		src.desc = "A translucent balloon with some form of liquid sloshing around in it."
		src.update_icon()
	return

/obj/item/toy/water_balloon/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/glass))
		if(O.reagents)
			if(O.reagents.total_volume < 1)
				to_chat(user, "The [O] is empty.")
			else if(O.reagents.total_volume >= 1)
				if(O.reagents.has_reagent(/datum/reagent/acid/polyacid, 1))
					to_chat(user, "The acid chews through the balloon!")
					O.reagents.splash(user, reagents.total_volume)
					qdel(src)
				else
					src.desc = "A translucent balloon with some form of liquid sloshing around in it."
					to_chat(user, "<span class='notice'>You fill the balloon with the contents of [O].</span>")
					O.reagents.trans_to_obj(src, 10)
	src.update_icon()
	return

/obj/item/toy/water_balloon/throw_impact(atom/hit_atom)
	if(src.reagents.total_volume >= 1)
		src.visible_message("<span class='warning'>\The [src] bursts!</span>","You hear a pop and a splash.")
		src.reagents.touch_turf(get_turf(hit_atom))
		for(var/atom/A in get_turf(hit_atom))
			src.reagents.touch(A)
		src.icon_state = "burst"
		spawn(5)
			if(src)
				qdel(src)
	return

/obj/item/toy/water_balloon/update_icon()
	if(src.reagents.total_volume >= 1)
		icon_state = "waterballoon"
		item_state = "balloon"
	else
		icon_state = "waterballoon-e"
		item_state = "balloon-empty"

/obj/item/toy/balloon
	name = "\improper 'criminal' balloon"
	desc = "FUK NT!11!"
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	force = 0
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	item_state = "syndballoon"
	w_class = ITEM_SIZE_HUGE

/obj/item/toy/balloon/New()
	..()
	desc = "Across the balloon is printed: \"[desc]\""

/obj/item/toy/balloon/nanotrasen
	name = "\improper 'motivational' balloon"
	desc = "Man, I love NanoTrasen soooo much. I use only NT products. You have NO idea."
	icon_state = "ntballoon"
	item_state = "ntballoon"

/*
 * Fake telebeacon
 */
/obj/item/toy/blink
	name = "electronic blink toy game"
	desc = "Blink.  Blink.  Blink. Ages 8 and up."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "gravitational singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"

/*
 * Toy crossbow
 */

/obj/item/toy/crossbow
	name = "foam dart crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon = 'icons/obj/gun.dmi'
	icon_state = "crossbow"
	item_state = "crossbow"
	item_icons = list(
		slot_l_hand_str  = 'icons/mob/onmob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_guns.dmi'
		)
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("attacked", "struck", "hit")
	var/bullets = 5

	examine(mob/user)
		if(..(user, 2) && bullets)
			to_chat(user, "<span class='notice'>It is loaded with [bullets] foam darts!</span>")

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/toy/ammo/crossbow))
			if(bullets <= 4)
				user.drop_item()
				qdel(I)
				bullets++
				to_chat(user, "<span class='notice'>You load the foam dart into the crossbow.</span>")
			else
				to_chat(usr, "<span class='warning'>It's already fully loaded.</span>")


	afterattack(atom/target, mob/user, flag)
		if(!isturf(target.loc) || target == user) return
		if(flag) return

		if (locate (/obj/structure/table, src.loc))
			return
		else if (bullets)
			var/turf/trg = get_turf(target)
			var/obj/effect/foam_dart_dummy/D = new /obj/effect/foam_dart_dummy(get_turf(src))
			bullets--
			D.icon_state = "foamdart"
			D.SetName("foam dart")
			playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

			for(var/i=0, i<6, i++)
				if (D)
					if(D.loc == trg) break
					step_towards(D,trg)

					for(var/mob/living/M in D.loc)
						if(!istype(M,/mob/living)) continue
						if(M == user) continue
						for(var/mob/O in viewers(world.view, D))
							O.show_message(text("<span class='warning'>\The [] was hit by the foam dart!</span>", M), 1)
						new /obj/item/toy/ammo/crossbow(M.loc)
						qdel(D)
						return

					for(var/atom/A in D.loc)
						if(A == user) continue
						if(A.density)
							new /obj/item/toy/ammo/crossbow(A.loc)
							qdel(D)

				sleep(1)

			spawn(10)
				if(D)
					new /obj/item/toy/ammo/crossbow(D.loc)
					qdel(D)

			return
		else if (bullets == 0)
			user.Weaken(5)
			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("<span class='warning'>\The [] realized they were out of ammo and starting scrounging for some!</span>", user), 1)


	attack(mob/M, mob/user)
		src.add_fingerprint(user)

// ******* Check

		if (src.bullets > 0 && M.lying)

			for(var/mob/O in viewers(M, null))
				if(O.client)
					O.show_message(text("<span class='danger'>\The [] casually lines up a shot with []'s head and pulls the trigger!</span>", user, M), 1, "<span class='warning'>You hear the sound of foam against skull</span>", 2)
					O.show_message(text("<span class='warning'>\The [] was hit in the head by the foam dart!</span>", M), 1)

			playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)
			new /obj/item/toy/ammo/crossbow(M.loc)
			src.bullets--
		else if (M.lying && src.bullets == 0)
			for(var/mob/O in viewers(M, null))
				if (O.client)	O.show_message(text("<span class='danger'>\The [] casually lines up a shot with []'s head, pulls the trigger, then realizes they are out of ammo and drops to the floor in search of some!</span>", user, M), 1, "<span class='warning'>You hear someone fall</span>", 2)
			user.Weaken(5)
		return

/obj/item/toy/ammo/crossbow
	name = "foam dart"
	desc = "It's nerf or nothing! Ages 8 and up."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamdart"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS

/obj/effect/foam_dart_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/toy.dmi'
	icon_state = "null"
	anchored = 1
	density = 0


/*
 * Toy swords
 */
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "sword0"
	item_state = "sword0"
	var/active = 0.0
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("attacked", "struck", "hit")

	attack_self(mob/user)
		src.active = !( src.active )
		if (src.active)
			to_chat(user, "<span class='notice'>You extend the plastic blade with a quick flick of your wrist.</span>")
			playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
			src.icon_state = "swordblue"
			src.item_state = "swordblue"
			src.w_class = ITEM_SIZE_HUGE
		else
			to_chat(user, "<span class='notice'>You push the plastic blade back down into the handle.</span>")
			playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
			src.icon_state = "sword0"
			src.item_state = "sword0"
			src.w_class = initial(w_class)

		update_held_icon()

		src.add_fingerprint(user)
		return

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 5
	throwforce = 5
	w_class = ITEM_SIZE_LARGE
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")

/*
 * Snap pops
 */
/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = ITEM_SIZE_TINY

	throw_impact(atom/hit_atom)
		..()
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		new /obj/effect/decal/cleanable/ash(src.loc)
		src.visible_message("<span class='warning'>The [src.name] explodes!</span>","<span class='warning'>You hear a snap!</span>")
		playsound(src, 'sound/effects/snap.ogg', 50, 1)
		qdel(src)

/obj/item/toy/snappop/Crossed(H as mob|obj)
	if((ishuman(H))) //i guess carp and shit shouldn't set them off
		var/mob/living/carbon/M = H
		if(M.m_intent == M_RUN)
			to_chat(M, "<span class='warning'>You step on the snap pop!</span>")

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 0, src)
			s.start()
			new /obj/effect/decal/cleanable/ash(src.loc)
			src.visible_message("<span class='warning'>The [src.name] explodes!</span>","<span class='warning'>You hear a snap!</span>")
			playsound(src, 'sound/effects/snap.ogg', 50, 1)
			qdel(src)

/*
 * Bosun's whistle
 */

/obj/item/toy/bosunwhistle
	name = "bosun's whistle"
	desc = "A genuine Admiral Krush Bosun's Whistle, for the aspiring ship's captain! Suitable for ages 8 and up, do not swallow."
	icon = 'icons/obj/toy.dmi'
	icon_state = "bosunwhistle"
	var/cooldown = 0
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS

/obj/item/toy/bosunwhistle/attack_self(mob/user)
	if(cooldown < world.time - 35)
		to_chat(user, "<span class='notice'>You blow on [src], creating an ear-splitting noise!</span>")
		playsound(user, 'sound/misc/boatswain.ogg', 20, 1)
		cooldown = world.time

/*
 * Mech prizes
 */
/obj/item/toy/prize
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"
	var/cooldown = 0

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user)
	if(cooldown < world.time - 8)
		to_chat(user, "<span class='notice'>You play with [src].</span>")
		playsound(user, 'sound/mecha/mechstep.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/prize/attack_hand(mob/user)
	if(loc == user)
		if(cooldown < world.time - 8)
			to_chat(user, "<span class='notice'>You play with [src].</span>")
			playsound(user, 'sound/mecha/mechturn.ogg', 20, 1)
			cooldown = world.time
			return
	..()

/obj/item/toy/prize/ripley
	name = "toy ripley"
	desc = "Mini-Mecha action figure! Collect them all! 1/11."

/obj/item/toy/prize/fireripley
	name = "toy firefighting ripley"
	desc = "Mini-Mecha action figure! Collect them all! 2/11."
	icon_state = "fireripleytoy"

/obj/item/toy/prize/deathripley
	name = "toy deathsquad ripley"
	desc = "Mini-Mecha action figure! Collect them all! 3/11."
	icon_state = "deathripleytoy"

/obj/item/toy/prize/gygax
	name = "toy gygax"
	desc = "Mini-Mecha action figure! Collect them all! 4/11."
	icon_state = "gygaxtoy"

/obj/item/toy/prize/durand
	name = "toy durand"
	desc = "Mini-Mecha action figure! Collect them all! 5/11."
	icon_state = "durandprize"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mecha action figure! Collect them all! 6/11."
	icon_state = "honkprize"

/obj/item/toy/prize/marauder
	name = "toy marauder"
	desc = "Mini-Mecha action figure! Collect them all! 7/11."
	icon_state = "marauderprize"

/obj/item/toy/prize/seraph
	name = "toy seraph"
	desc = "Mini-Mecha action figure! Collect them all! 8/11."
	icon_state = "seraphprize"

/obj/item/toy/prize/mauler
	name = "toy mauler"
	desc = "Mini-Mecha action figure! Collect them all! 9/11."
	icon_state = "maulerprize"

/obj/item/toy/prize/odysseus
	name = "toy odysseus"
	desc = "Mini-Mecha action figure! Collect them all! 10/11."
	icon_state = "odysseusprize"

/obj/item/toy/prize/phazon
	name = "toy phazon"
	desc = "Mini-Mecha action figure! Collect them all! 11/11."
	icon_state = "phazonprize"

/*
 * Action figures
 */

/obj/item/toy/figure
	name = "Completely Glitched action figure"
	desc = "A \"Space Life\" brand... wait, what the hell is this thing? It seems to be requesting the sweet release of death."
	icon_state = "assistant"
	icon = 'icons/obj/toy.dmi'

/obj/item/toy/figure/cmo
	name = "Chief Medical Officer action figure"
	desc = "A \"Space Life\" brand Chief Medical Officer action figure."
	icon_state = "cmo"

/obj/item/toy/figure/assistant
	name = "Assistant action figure"
	desc = "A \"Space Life\" brand Assistant action figure."
	icon_state = "assistant"

/obj/item/toy/figure/atmos
	name = "Atmospheric Technician action figure"
	desc = "A \"Space Life\" brand Atmospheric Technician action figure."
	icon_state = "atmos"

/obj/item/toy/figure/bartender
	name = "Bartender action figure"
	desc = "A \"Space Life\" brand Bartender action figure."
	icon_state = "bartender"

/obj/item/toy/figure/moose
	name = "Moose action figure"
	desc = "A \"Space Life\" brand Moose action figure."
	icon_state = "moose"

/obj/item/toy/figure/borg
	name = "Cyborg action figure"
	desc = "A \"Space Life\" brand Cyborg action figure."
	icon_state = "borg"

/obj/item/toy/figure/gardener
	name = "Gardener action figure"
	desc = "A \"Space Life\" brand Gardener action figure."
	icon_state = "botanist"

/obj/item/toy/figure/captain
	name = "Captain action figure"
	desc = "A \"Space Life\" brand Captain action figure."
	icon_state = "captain"

/obj/item/toy/figure/cargotech
	name = "Cargo Technician action figure"
	desc = "A \"Space Life\" brand Cargo Technician action figure."
	icon_state = "cargotech"

/obj/item/toy/figure/ce
	name = "Chief Engineer action figure"
	desc = "A \"Space Life\" brand Chief Engineer action figure."
	icon_state = "ce"

/obj/item/toy/figure/chaplain
	name = "Chaplain action figure"
	desc = "A \"Space Life\" brand Chaplain action figure."
	icon_state = "chaplain"

/obj/item/toy/figure/chef
	name = "Chef action figure"
	desc = "A \"Space Life\" brand Chef action figure."
	icon_state = "chef"

/obj/item/toy/figure/chemist
	name = "Chemist action figure"
	desc = "A \"Space Life\" brand Chemist action figure."
	icon_state = "chemist"

/obj/item/toy/figure/clown
	name = "Clown action figure"
	desc = "A \"Space Life\" brand Clown action figure."
	icon_state = "clown"

/obj/item/toy/figure/corgi
	name = "Corgi action figure"
	desc = "A \"Space Life\" brand Corgi action figure."
	icon_state = "ian"

/obj/item/toy/figure/detective
	name = "Detective action figure"
	desc = "A \"Space Life\" brand Detective action figure."
	icon_state = "detective"

/obj/item/toy/figure/dsquad
	name = "Space Commando action figure"
	desc = "A \"Space Life\" brand Space Commando action figure."
	icon_state = "dsquad"

/obj/item/toy/figure/engineer
	name = "Engineer action figure"
	desc = "A \"Space Life\" brand Engineer action figure."
	icon_state = "engineer"

/obj/item/toy/figure/geneticist
	name = "Geneticist action figure"
	desc = "A \"Space Life\" brand Geneticist action figure, which was recently dicontinued."
	icon_state = "geneticist"

/obj/item/toy/figure/hop
	name = "Head of Personel action figure"
	desc = "A \"Space Life\" brand Head of Personel action figure."
	icon_state = "hop"

/obj/item/toy/figure/hos
	name = "Head of Security action figure"
	desc = "A \"Space Life\" brand Head of Security action figure."
	icon_state = "hos"

/obj/item/toy/figure/qm
	name = "Quartermaster action figure"
	desc = "A \"Space Life\" brand Quartermaster action figure."
	icon_state = "qm"

/obj/item/toy/figure/janitor
	name = "Janitor action figure"
	desc = "A \"Space Life\" brand Janitor action figure."
	icon_state = "janitor"

/obj/item/toy/figure/agent
	name = "Internal Affairs Agent action figure"
	desc = "A \"Space Life\" brand Internal Affairs Agent action figure."
	icon_state = "agent"

/obj/item/toy/figure/librarian
	name = "Librarian action figure"
	desc = "A \"Space Life\" brand Librarian action figure."
	icon_state = "librarian"

/obj/item/toy/figure/md
	name = "Medical Doctor action figure"
	desc = "A \"Space Life\" brand Medical Doctor action figure."
	icon_state = "md"

/obj/item/toy/figure/mime
	name = "Mime action figure"
	desc = "A \"Space Life\" brand Mime action figure."
	icon_state = "mime"

/obj/item/toy/figure/miner
	name = "Shaft Miner action figure"
	desc = "A \"Space Life\" brand Shaft Miner action figure."
	icon_state = "miner"

/obj/item/toy/figure/ninja
	name = "Space Ninja action figure"
	desc = "A \"Space Life\" brand Space Ninja action figure."
	icon_state = "ninja"

/obj/item/toy/figure/wizard
	name = "Wizard action figure"
	desc = "A \"Space Life\" brand Wizard action figure."
	icon_state = "wizard"

/obj/item/toy/figure/rd
	name = "Research Director action figure"
	desc = "A \"Space Life\" brand Research Director action figure."
	icon_state = "rd"

/obj/item/toy/figure/roboticist
	name = "Roboticist action figure"
	desc = "A \"Space Life\" brand Roboticist action figure."
	icon_state = "roboticist"

/obj/item/toy/figure/scientist
	name = "Scientist action figure"
	desc = "A \"Space Life\" brand Scientist action figure."
	icon_state = "scientist"

/obj/item/toy/figure/syndie
	name = "Doom Operative action figure"
	desc = "A \"Space Life\" brand Doom Operative action figure."
	icon_state = "syndie"

/obj/item/toy/figure/secofficer
	name = "Security Officer action figure"
	desc = "A \"Space Life\" brand Security Officer action figure."
	icon_state = "secofficer"

/obj/item/toy/figure/warden
	name = "Warden action figure"
	desc = "A \"Space Life\" brand Warden action figure."
	icon_state = "warden"

/obj/item/toy/figure/psychologist
	name = "Psychologist action figure"
	desc = "A \"Space Life\" brand Psychologist action figure."
	icon_state = "psychologist"

/obj/item/toy/figure/paramedic
	name = "Paramedic action figure"
	desc = "A \"Space Life\" brand Paramedic action figure."
	icon_state = "paramedic"

/obj/item/toy/figure/ert
	name = "Emergency Response Team Commander action figure"
	desc = "A \"Space Life\" brand Emergency Response Team Commander action figure."
	icon_state = "ert"

/obj/item/toy/therapy_red
	name = "red therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is red."
	icon_state = "therapyred"
	item_state = "egg4" // It's the red egg in items_left/righthand
	w_class = ITEM_SIZE_TINY

/obj/item/toy/therapy_purple
	name = "purple therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is purple."
	icon_state = "therapypurple"
	item_state = "egg1" // It's the magenta egg in items_left/righthand
	w_class = ITEM_SIZE_TINY

/obj/item/toy/therapy_blue
	name = "blue therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is blue."
	icon_state = "therapyblue"
	item_state = "egg2" // It's the blue egg in items_left/righthand
	w_class = ITEM_SIZE_TINY

/obj/item/toy/therapy_yellow
	name = "yellow therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is yellow."
	icon_state = "therapyyellow"
	item_state = "egg5" // It's the yellow egg in items_left/righthand
	w_class = ITEM_SIZE_TINY

/obj/item/toy/therapy_orange
	name = "orange therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is orange."
	icon_state = "therapyorange"
	item_state = "egg4" // It's the red one again, lacking an orange item_state and making a new one is pointless
	w_class = ITEM_SIZE_TINY

/obj/item/toy/therapy_green
	name = "green therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is green."
	icon_state = "therapygreen"
	item_state = "egg3" // It's the green egg in items_left/righthand
	w_class = ITEM_SIZE_TINY

/*
 * Plushies
 */

//Large plushies.
/obj/structure/plushie
	name = "generic plush"
	desc = "A very generic plushie. It seems to not want to exist."
	icon = 'icons/obj/toy.dmi'
	icon_state = "ianplushie"
	anchored = 0
	density = 1
	var/phrase = "I don't want to exist anymore!"

/obj/structure/plushie/attack_hand(mob/user)
	if(user.a_intent == I_HELP)
		user.visible_message("<span class='notice'><b>\The [user]</b> hugs [src]!</span>","<span class='notice'>You hug [src]!</span>")
	else if (user.a_intent == I_HURT)
		user.visible_message("<span class='warning'><b>\The [user]</b> punches [src]!</span>","<span class='warning'>You punch [src]!</span>")
	else if (user.a_intent == I_GRAB)
		user.visible_message("<span class='warning'><b>\The [user]</b> attempts to strangle [src]!</span>","<span class='warning'>You attempt to strangle [src]!</span>")
	else
		user.visible_message("<span class='notice'><b>\The [user]</b> pokes the [src].</span>","<span class='notice'>You poke the [src].</span>")
		visible_message("[src] says, \"[phrase]\"")

/obj/structure/plushie/ian
	name = "plush corgi"
	desc = "A plushie of an adorable corgi! Don't you just want to hug it and squeeze it and call it \"Ian\"?"
	icon_state = "ianplushie"
	phrase = "Arf!"

/obj/structure/plushie/drone
	name = "plush drone"
	desc = "A plushie of a happy drone! It appears to be smiling, and has a small tag which reads \"N.D.V. Icarus Gift Shop\"."
	icon_state = "droneplushie"
	phrase = "Beep boop!"

/obj/structure/plushie/carp
	name = "plush carp"
	desc = "A plushie of an elated carp! Straight from the wilds of the Nyx frontier, now right here in your hands."
	icon_state = "carpplushie"
	phrase = "Glorf!"

/obj/structure/plushie/beepsky
	name = "plush Officer Sweepsky"
	desc = "A plushie of a popular industrious cleaning robot! If it could feel emotions, it would love you."
	icon_state = "beepskyplushie"
	phrase = "Ping!"

//Small plushies.
/obj/item/toy/plushie
	name = "generic small plush"
	desc = "A very generic small plushie. It seems to not want to exist."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nymphplushie"

/obj/item/toy/plushie/attack_self(mob/user)
	if(user.a_intent == I_HELP)
		user.visible_message("<span class='notice'><b>\The [user]</b> hugs [src]!</span>","<span class='notice'>You hug [src]!</span>")
	else if (user.a_intent == I_HURT)
		user.visible_message("<span class='warning'><b>\The [user]</b> punches [src]!</span>","<span class='warning'>You punch [src]!</span>")
	else if (user.a_intent == I_GRAB)
		user.visible_message("<span class='warning'><b>\The [user]</b> attempts to strangle [src]!</span>","<span class='warning'>You attempt to strangle [src]!</span>")
	else
		user.visible_message("<span class='notice'><b>\The [user]</b> pokes the [src].</span>","<span class='notice'>You poke the [src].</span>")

/obj/item/toy/plushie/nymph
	name = "diona nymph plush"
	desc = "A plushie of an adorable diona nymph! While its level of self-awareness is still being debated, its level of cuteness is not."
	icon_state = "nymphplushie"

/obj/item/toy/plushie/mouse
	name = "mouse plush"
	desc = "A plushie of a delightful mouse! What was once considered a vile rodent is now your very best friend."
	icon_state = "mouseplushie"

/obj/item/toy/plushie/kitten
	name = "kitten plush"
	desc = "A plushie of a cute kitten! Watch as it purrs it's way right into your heart."
	icon_state = "kittenplushie"

/obj/item/toy/plushie/lizard
	name = "lizard plush"
	desc = "A plushie of a scaly lizard! Very controversial, after being accused as \"racist\" by some Unathi."
	icon_state = "lizardplushie"

/obj/item/toy/plushie/spider
	name = "spider plush"
	desc = "A plushie of a fuzzy spider! It has eight legs - all the better to hug you with."
	icon_state = "spiderplushie"

/obj/item/toy/plushie/farwa
	name = "farwa plush"
	desc = "A farwa plush doll. It's soft and comforting!"
	icon_state = "farwaplushie"

//Toy cult sword
/obj/item/toy/cultsword
	name = "foam sword"
	desc = "An arcane weapon (made of foam) wielded by the followers of the hit Saturday morning cartoon \"King Nursee and the Acolytes of Heroism\"."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "cultblade"
	item_state = "cultblade"
	w_class = ITEM_SIZE_HUGE
	attack_verb = list("attacked", "slashed", "stabbed", "poked")

/obj/item/weapon/inflatable_duck
	name = "inflatable duck"
	desc = "No bother to sink or swim when you can just float!"
	icon_state = "inflatable"
	item_state = "inflatable"
	icon = 'icons/obj/clothing/belts.dmi'
	slot_flags = SLOT_BELT

/obj/item/weapon/marshalling_wand
	name = "marshalling wand"
	desc = "An illuminated, hand-held baton used by hangar personnel to visually signal shuttle pilots. The signal changes depending on your intent."
	icon_state = "marshallingwand"
	item_state = "marshallingwand"
	icon = 'icons/obj/toy.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand.dmi'
		)
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	force = 1
	attack_verb = list("attacked", "whacked", "jabbed", "poked", "marshalled")

/obj/item/weapon/marshalling_wand/Initialize()
	set_light(1.5, 1.5, "#ff0000")
	return ..()

/obj/item/weapon/marshalling_wand/attack_self(mob/living/user)
	if (user.a_intent == I_HELP)
		user.visible_message("<span class='notice'>[user] beckons with \the [src], signalling forward motion.</span>",
							"<span class='notice'>You beckon with \the [src], signalling forward motion.</span>")
	else if (user.a_intent == I_DISARM)
		user.visible_message("<span class='notice'>[user] holds \the [src] above their head, signalling a stop.</span>",
							"<span class='notice'>You hold \the [src] above your head, signalling a stop.</span>")
	else if (user.a_intent == I_GRAB)
		var/WAND_TURN_DIRECTION
		if (user.l_hand == src) WAND_TURN_DIRECTION = "left"
		else if (user.r_hand == src) WAND_TURN_DIRECTION = "right"
		else return //how can you not be holding it in either hand?? black magic
		user.visible_message("<span class='notice'>[user] waves \the [src] to the [WAND_TURN_DIRECTION], signalling a turn.</span>",
							"<span class='notice'>You wave \the [src] to the [WAND_TURN_DIRECTION], signalling a turn.</span>")
	else if (user.a_intent == I_HURT)
		user.visible_message("<span class='warning'>[user] frantically waves \the [src] above their head!</span>",
							"<span class='warning'>You frantically wave \the [src] above your head!</span>")

/obj/item/toy/torchmodel
	name = "table-top SEV Torch model"
	desc = "This is a replica of the SEV Torch, in 1:250th scale, on a handsome wooden stand. Small lights blink on the hull and at the engine exhaust."
	icon = 'icons/obj/toy.dmi'
	icon_state = "torch_model_figure"

/obj/item/toy/ringbell
	name = "ringside bell"
	desc = "A bell used to signal the beginning and end of various ring sports."
	icon = 'icons/obj/toy.dmi'
	icon_state= "ringbell"
	anchored = 1

/obj/item/toy/ringbell/attack_hand(mob/user)
	if (user.a_intent == I_HELP)
		user.visible_message("<span class='notice'>[user] rings \the [src], signalling the beginning of the contest.</span>")
		playsound(user.loc, 'sound/items/oneding.ogg', 60)
	else if (user.a_intent == I_DISARM)
		user.visible_message("<span class='notice'>[user] rings \the [src] three times, signalling the end of the contest!</span>")
		playsound(user.loc, 'sound/items/threedings.ogg', 60)
	else if (user.a_intent == I_HURT)
		user.visible_message("<span class='warning'>[user] rings \the [src] repeatedly, signalling a disqualification!</span>")
		playsound(user.loc, 'sound/items/manydings.ogg', 60)

/obj/item/toy/chubbyskeleton
	name = "Sans"
	icon = 'icons/obj/toy.dmi'
	icon_state = "heya"
	anchored = 1
	density = 1
	var/dodgecount = 0
	var/spam_flag = 0

/obj/item/toy/chubbyskeleton/New()
	..()
	pixel_x = 0
	pixel_y = 0

/obj/item/toy/chubbyskeleton/examine(mob/user)
	return "<span class='notice'>*---------*<BR>This is [src], a Skeleton!<BR>He is wearing some black shorts.<BR>He is wearing a blue hoodie.<BR>He is wearing some slippers on his feet.<BR>*---------*</span>"

/obj/item/toy/chubbyskeleton/attack_hand(mob/user)
	if(spam_flag == 0)
		spam_flag = 1
		if(user.a_intent == I_HELP)
			speak(pick( "why are skeletons so calm? because nothing gets under their skin!",
						"why can't skeletons play church music? because they have no organs!",
						"what does a skeleton order at a restaurant? SPARERIBS",
						"my favorite instrument? the tromBONE, of course.",
						"what do skeletons hate the most about wind? nothing, it goes right through them.",
						"why don't skeletons fight each other? they don't have the guts!",
						"why are graveyards so noisy? because of all the COFFIN!",
						"i'm not fat. i'm just big boned!",
						"what do skeletons say before they begin dining? bone-appetit!",
						"what do you call a skeleton snake? a rattler!",
						"what did the skeleton say while riding his Harley Davidson motorcycle? im bone to be wild!",
						"my brother always works himself down to the bone!",
						"why did the skeleton want a friend? because she was feeling BONELY",
						"what do you do if you see a skeleton running across a road? jump out of your skin and join him!",
						"everytime I hear a skeleton joke I feel it in my bones",
						"skulls are always single because they have NO BODY",
						"these jokes are very bare bones",
						"why do skeletons makes bad miners? because they only go 6 FOOT UNDER GROUND",
						"you wanna know why skeletons are terrible liars? everyone can see right through them!",
						"why does skeletons never go to swimming pools? because they hate being SOAKED TO THE BONE",
						"a dog stole a skeleton's left leg and left arm the other day. but it's cool he's ALL RIGHT now!", //lmfao this one cracked me up ~Toby
						"what d'ye call a monkey with no skin? a babBONE!",
						"what band do skeletons like listening to? Boney M!",
						"what is a skeleton's favorite music band? BONE JOVI!",
						"what do you call a skeleton who presses the door bell? a dead ringer!",
						"why did the ghost took the elevator? to lift his SPIRIT up"))
			playsound(user.loc, pick('sound/effects/bonebreak1.ogg','sound/effects/bonebreak2.ogg','sound/effects/bonebreak3.ogg','sound/effects/bonebreak4.ogg','sound/effects/bonerattle.ogg'), 60)
		else
			badtime(user)
		spawn(10)
			spam_flag = 0
	return

/obj/item/toy/chubbyskeleton/attackby(obj/item/I, mob/user)
	if(spam_flag == 0)
		spam_flag = 1
		badtime(user)
		spawn(5)
			spam_flag = 0
	return

/obj/item/toy/chubbyskeleton/proc/badtime(mob/user)
	dodgecount++
	if(dodgecount < 4)
		user.visible_message("<span class='warning'>[src] dodges [user]'s attack!</span>")
		speak(pick("welp.","what? you think i'm just gonna stand there and take it? ","all right.","our reports showed a massive bluespace anomaly.","that sent chills down my SPINE."))
	else if(dodgecount == 4)
		icon_state = "badtime"
		user.visible_message("<span class='warning'>[src] dodges [user]'s attack!</span>")
		speak(pick("do you wanna have a bad time?","you are REALLY not going to like what happens next."))
	else
		icon_state = "heya"
		dodgecount = 0
		speak(pick("geeettttttt dunked on!!!","told ya."))
		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			H.ChangeToSkeleton()
			for(var/obj/item/W in H)
				H.drop_from_inventory(W)
		playsound(user.loc, pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg'), 60)

/obj/item/toy/banbanana
	name = "BANana"
	desc = "What happens if I peel it?"
	icon = 'icons/obj/toy.dmi'
	icon_state = "banana"

/obj/item/toy/banbanana/attack_self(mob/user)
	for(var/mob/M in viewers(user, null))
		if(M.client)
			M.show_message("<span class='danger'>You have been banned by HO$T.\nReason: Honk.</span>")
			M.show_message("<span class='warning'>This is a PERMENANT ban.</span>")
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.eye_blind += 1
	playsound(user.loc, 'sound/effects/adminhelp.ogg', 100)
	user.drop_from_inventory(src)
	qdel(src)

/obj/item/toy/pig
	name = "rubber piggy"
	desc = "The people demand pigs!"
	icon_state = "pig1"
	var/spam_flag = 0
	var/message_spam_flag = 0

/obj/item/toy/pig/proc/oink(mob/user, msg)
	if(spam_flag == 0)
		spam_flag = 1
		playsound(loc, pick('sound/effects/pig1.ogg','sound/effects/pig2.ogg','sound/effects/pig3.ogg'), 100, 1)
		add_fingerprint(user)
		if(message_spam_flag == 0)
			message_spam_flag = 1
			user.visible_message(SPAN("notice", "[user] [msg] \the [src] in hand!"))
			spawn(30)
				message_spam_flag = 0
		spawn(3)
			spam_flag = 0
	return

/obj/item/toy/pig/Initialize()
	. = ..()
	switch(rand(1, 100))
		if(1 to 33)
			icon_state = "pig1"
		if(34 to 66)
			icon_state = "pig2"
		if(67 to 99)
			icon_state = "pig3"
		if(100)
			icon_state = "pig4"
			name = "green rubber piggy"
			desc = "Watch out for angry voxes!"

/obj/item/toy/pig/attack_self(mob/user)
	oink(user, "squeezes")

/obj/item/toy/pig/attack_hand(mob/user)
	oink(user, pick("presses", "squeezes", "squashes", "champs", "pinches"))

/obj/item/toy/pig/MouseDrop(mob/user)
	if(!CanMouseDrop(src, usr))
		return
	if(user == usr && (user.contents.Find(src) || in_range(src, user)))
		if(ishuman(user) && !user.get_active_hand())
			var/mob/living/carbon/human/H = user
			var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]
			if(H.hand)
				temp = H.organs_by_name[BP_L_HAND]
			if(temp && !temp.is_usable())
				to_chat(user, SPAN("warning", "You try to pick up \the [src] with your [temp.name], but cannot!"))
				return
			to_chat(user, SPAN("notice", "You pick up \the [src]."))
			user.put_in_hands(src)
	return
