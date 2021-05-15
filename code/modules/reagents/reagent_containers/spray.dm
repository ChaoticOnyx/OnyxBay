/obj/item/weapon/reagent_containers/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	item_flags = ITEM_FLAG_NO_BLUDGEON
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 2
	throw_range = 10
	amount_per_transfer_from_this = 10
	unacidable = 1 //plastic
	possible_transfer_amounts = "5;10" //Set to null instead of list, if there is only one.
	var/spray_size = 3
	var/list/spray_sizes = list(1,3)
	var/step_delay = 10 // lower is faster
	var/widespray = FALSE
	volume = 250
	var/obj/item/weapon/reagent_containers/external_container = null // Using an external reagent container (i.e. backwear spray)

/obj/item/weapon/reagent_containers/spray/Initialize()
	. = ..()
	src.verbs -= /obj/item/weapon/reagent_containers/verb/set_APTFT

/obj/item/weapon/reagent_containers/spray/afterattack(atom/A as mob|obj, mob/user, proximity)
	if(istype(A, /obj/item/weapon/storage) || istype(A, /obj/structure/table) || istype(A, /obj/structure/closet) || istype(A, /obj/item/weapon/reagent_containers) || istype(A, /obj/structure/sink) || istype(A, /obj/structure/janitorialcart) || istype(A, /obj/item/weapon/backwear/reagent))
		return

	if(istype(A, /spell))
		return

	var/obj/item/weapon/reagent_containers/actual_container = external_container ? external_container : src

	if(proximity)
		if(actual_container.standard_dispenser_refill(user, A))
			return

	if(actual_container.reagents.total_volume < amount_per_transfer_from_this)
		to_chat(user, SPAN("notice", "\The [actual_container] is empty!"))
		return

	if(!user.canClick()) // yeah there we go year 2019...
		return

	if(widespray)
		Spray_at_wide(A, user)
	else
		Spray_at(A, user, proximity)

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	if(actual_container.reagents.has_reagent(/datum/reagent/acid))
		message_admins("[key_name_admin(user)] fired sulphuric acid from \a [src].")
		log_game("[key_name(user)] fired sulphuric acid from \a [src].")
	if(actual_container.reagents.has_reagent(/datum/reagent/acid/polyacid))
		message_admins("[key_name_admin(user)] fired Polyacid from \a [src].")
		log_game("[key_name(user)] fired Polyacid from \a [src].")
	if(actual_container.reagents.has_reagent(/datum/reagent/lube))
		message_admins("[key_name_admin(user)] fired Space lube from \a [src].")
		log_game("[key_name(user)] fired Space lube from \a [src].")
	return

/obj/item/weapon/reagent_containers/spray/proc/Spray_at(atom/A as mob|obj, mob/user, proximity)
	var/obj/item/weapon/reagent_containers/actual_container = external_container ? external_container : src

	playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1, -6)
	if(A.density && proximity)
		A.visible_message("[usr] sprays [A] with [src].")
		actual_container.reagents.splash(A, amount_per_transfer_from_this)
	else
		spawn(0)
			var/obj/effect/effect/water/chempuff/D = new /obj/effect/effect/water/chempuff(get_turf(src))
			var/turf/my_target = get_turf(A)
			D.create_reagents(amount_per_transfer_from_this)
			if(!src || !actual_container)
				return
			actual_container.reagents.trans_to_obj(D, amount_per_transfer_from_this)
			D.set_color()
			D.set_up(my_target, spray_size, step_delay)
	return

/obj/item/weapon/reagent_containers/spray/proc/Spray_at_wide(atom/A as mob|obj, mob/user)
	var/obj/item/weapon/reagent_containers/actual_container = external_container ? external_container : src

	playsound(src.loc, 'sound/effects/spray2.ogg', 75, 1, -3)
	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T, T1, T2)

	for(var/a = 1 to 3)
		spawn(0)
			if(actual_container.reagents.total_volume < 1)
				break
			var/obj/effect/effect/water/chempuff/D = new /obj/effect/effect/water/chempuff(get_turf(src))
			var/turf/my_target = the_targets[a]
			D.create_reagents(amount_per_transfer_from_this)
			if(!src || !actual_container)
				return
			actual_container.reagents.trans_to_obj(D, amount_per_transfer_from_this)
			D.set_color()
			D.set_up(my_target, rand(6, 8), 2)
	return

/obj/item/weapon/reagent_containers/spray/attack_self(mob/user)
	if(!possible_transfer_amounts)
		return
	amount_per_transfer_from_this = next_in_list(amount_per_transfer_from_this, cached_number_list_decode(possible_transfer_amounts))
	spray_size = next_in_list(spray_size, spray_sizes)
	to_chat(user, "<span class='notice'>You adjusted the pressure nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>")

/obj/item/weapon/reagent_containers/spray/examine(mob/user)
	. = ..()
	if(get_dist(src, user) <= 0 && loc == user)
		. += "\n[round(external_container ? external_container.reagents.total_volume : reagents.total_volume)] unit\s left."
	return

/obj/item/weapon/reagent_containers/spray/verb/empty()

	set name = "Empty Spray Bottle"
	set category = "Object"
	set src in usr

	if (alert(usr, "Are you sure you want to empty that?", "Empty Bottle:", "Yes", "No") != "Yes")
		return
	if(isturf(usr.loc))
		to_chat(usr, "<span class='notice'>You empty \the [src] onto the floor.</span>")
		reagents.splash(usr.loc, reagents.total_volume)

//space cleaner
/obj/item/weapon/reagent_containers/spray/cleaner
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	step_delay = 6

/obj/item/weapon/reagent_containers/spray/cleaner/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/space_cleaner, volume)

/obj/item/weapon/reagent_containers/spray/sterilizine
	name = "sterilizine"
	desc = "Great for hiding incriminating bloodstains and sterilizing scalpels."

/obj/item/weapon/reagent_containers/spray/sterilizine/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/sterilizine, volume)

/obj/item/weapon/reagent_containers/spray/hair_remover
	name = "hair remover"
	desc = "Very effective at removing hair, feathers, spines and horns."

/obj/item/weapon/reagent_containers/spray/hair_remover/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/hair_remover, volume)

/obj/item/weapon/reagent_containers/spray/pepper
	name = "pepperspray"
	desc = "Manufactured by Uhang Inc., it fires a mist of condensed capsaicin to blind and down an opponent quickly."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "pepperspray"
	item_state = "pepperspray"
	possible_transfer_amounts = null
	volume = 60
	var/safety = 1
	step_delay = 1

/obj/item/weapon/reagent_containers/spray/pepper/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/capsaicin/condensed, 60)

/obj/item/weapon/reagent_containers/spray/pepper/examine(mob/user)
	. = ..()
	if(get_dist(src, user) <= 1)
		. += "\nThe safety is [safety ? "on" : "off"]."

/obj/item/weapon/reagent_containers/spray/pepper/attack_self(mob/user)
	safety = !safety
	to_chat(usr, "<span class = 'notice'>You switch the safety [safety ? "on" : "off"].</span>")

/obj/item/weapon/reagent_containers/spray/pepper/Spray_at(atom/A as mob|obj)
	if(safety)
		to_chat(usr, "<span class = 'warning'>The safety is on!</span>")
		return
	..()

/obj/item/weapon/reagent_containers/spray/waterflower
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/device.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = null
	volume = 10

/obj/item/weapon/reagent_containers/spray/waterflower/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/water, 10)

/obj/item/weapon/reagent_containers/spray/chemsprayer
	name = "chem sprayer"
	desc = "A utility used to spray large amounts of reagent in a given area."
	icon = 'icons/obj/gun.dmi'
	icon_state = "chemsprayer"
	item_state = "chemsprayer"
	throwforce = 3
	w_class = ITEM_SIZE_LARGE
	possible_transfer_amounts = null
	volume = 600
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3, TECH_ENGINEERING = 3)
	step_delay = 8
	widespray = TRUE

/obj/item/weapon/reagent_containers/spray/plantbgone
	name = "Plant-B-Gone"
	desc = "Kills those pesky weeds!"
	icon = 'icons/obj/hydroponics_machines.dmi'
	icon_state = "plantbgone"
	item_state = "plantbgone"
	volume = 100

/obj/item/weapon/reagent_containers/spray/plantbgone/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/plantbgone, 100)

/obj/item/weapon/reagent_containers/spray/plantbgone/afterattack(atom/A as mob|obj, mob/user as mob, proximity)
	if(!proximity) return

	if(istype(A, /obj/effect/blob)) // blob damage in blob code
		return

	..()
