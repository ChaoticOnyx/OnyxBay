/obj/structure/largecrate
	name = "large crate"
	desc = "A hefty wooden crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "densecrate"
	density = 1
	atom_flags = ATOM_FLAG_CLIMBABLE
	pull_slowdown = PULL_SLOWDOWN_HEAVY
	turf_height_offset = 22
	climb_delay = 4 SECONDS // It's tall AF.

/obj/structure/largecrate/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/largecrate/LateInitialize(mapload, ...)
	. = ..()
	if(mapload) // if it's the map loading phase, relevant items at the crate's loc are put in the contents
		add_think_ctx("store_contents_mapload", CALLBACK(src, nameof(.proc/store_contents)), world.time + 1 SECOND)

/obj/structure/largecrate/proc/store_contents()
	for(var/obj/I in loc)
		if(I.density || I.anchored || I == src || !I.simulated || QDELETED(I))
			continue
		if(istype(I, /obj/effect) || istype(I, /obj/random))
			continue
		I.forceMove(src)
	remove_think_ctx("store_contents_mapload")

/obj/structure/largecrate/attack_hand(mob/user)
	to_chat(user, "<span class='notice'>You need a crowbar to pry this open!</span>")
	return

/obj/structure/largecrate/attackby(obj/item/W, mob/user)
	if(isCrowbar(W))
		new /obj/item/stack/material/wood(src)
		var/turf/T = get_turf(src)
		for(var/atom/movable/AM in contents)
			if(AM.simulated) AM.forceMove(T)
		user.visible_message("<span class='notice'>[user] pries \the [src] open.</span>", \
							 "<span class='notice'>You pry open \the [src].</span>", \
							 "<span class='notice'>You hear splitting wood.</span>")
		qdel(src)
	else
		return attack_hand(user)

/obj/structure/largecrate/hoverpod
	name = "\improper Hoverpod assembly crate"
	desc = "It comes in a box for the fabricator's sake. Where does the wood come from? ... And why is it lighter?"
	icon_state = "mulecrate"

/obj/structure/largecrate/hoverpod/Initialize()
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME
	var/obj/mecha/working/hoverpod/H = new (src)

	ME = new /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	ME.attach(H)
	ME = new /obj/item/mecha_parts/mecha_equipment/tool/passenger
	ME.attach(H)

/obj/structure/largecrate/animal
	icon_state = "mulecrate"
	var/held_count = 1
	var/held_type

/obj/structure/largecrate/animal/Initialize()
	. = ..()
	if(held_type)
		for(var/i = 1;i<=held_count;i++)
			new held_type(src)


/obj/structure/largecrate/animal/mulebot
	name = "Mulebot crate"
	held_type = /mob/living/bot/mulebot


/obj/structure/largecrate/animal/corgi
	name = "corgi carrier"
	held_type = /mob/living/simple_animal/corgi

/obj/structure/largecrate/animal/corgi/ian
	held_type = /mob/living/simple_animal/corgi/Ian

/obj/structure/largecrate/animal/corgi/lisa
	held_type = /mob/living/simple_animal/corgi/Lisa

/obj/structure/largecrate/animal/corgi/puppy
	held_type = /mob/living/simple_animal/corgi/puppy


/obj/structure/largecrate/animal/cow
	name = "cow crate"
	held_type = /mob/living/simple_animal/cow


/obj/structure/largecrate/animal/goat
	name = "goat crate"
	held_type = /mob/living/simple_animal/hostile/retaliate/goat


/obj/structure/largecrate/animal/pig
	name = "pig crate"
	held_type = /mob/living/simple_animal/pig


/obj/structure/largecrate/animal/cat
	name = "cat carrier"
	held_type = /mob/living/simple_animal/cat

/obj/structure/largecrate/animal/cat/bones
	held_type = /mob/living/simple_animal/cat/fluff/bones

/obj/structure/largecrate/animal/cat/runtime
	held_type = /mob/living/simple_animal/cat/fluff/Runtime


/obj/structure/largecrate/animal/chick
	name = "chicken crate"
	held_count = 5
	held_type = /mob/living/simple_animal/chick


/obj/structure/largecrate/animal/parrot
	name = "parrot crate"
	held_type = /mob/living/simple_animal/parrot

/obj/structure/largecrate/animal/parrot/poly
	held_type = /mob/living/simple_animal/parrot/Poly


/obj/structure/largecrate/animal/vatgrownbody/male
	name = "vat-grown body crate"
	icon_state = "vatgrowncrate_male"
	held_type = /obj/structure/closet/body_bag/cryobag/vatgrownbody/male

/obj/structure/largecrate/animal/vatgrownbody/female
	name = "vat-grown body crate"
	icon_state = "vatgrowncrate_female"
	held_type = /obj/structure/closet/body_bag/cryobag/vatgrownbody/female
