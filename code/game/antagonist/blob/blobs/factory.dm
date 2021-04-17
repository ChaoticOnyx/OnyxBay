/obj/effect/blob/factory
	name = "factory blob"
	icon_state = "factory"
	desc = "A part of a blob. It makes the sound of organic tissue being torn."
	health = 100
	maxhealth = 100
	fire_resist = 2
	var/list/spores = list()
	var/max_spores = 2
	var/spore_delay = 50
	spawning = 0
	layer = BLOB_FACTORY_LAYER
	destroy_sound = "sound/effects/blobsplatspecial.ogg"

/obj/effect/blob/factory/New(loc,newlook = null)
	..()

	flick("morph_factory",src)
	spore_delay = world.time + (2 SECONDS)

/obj/effect/blob/factory/run_action()
	if(spores.len >= max_spores)
		return 0

	if(spore_delay > world.time)
		return 0

	spore_delay = world.time + (40 SECONDS) // 30 seconds

	flick("factorypulse",src)
	anim(target = loc, a_icon = icon, flick_anim = "sporepulse", sleeptime = 150)

	spawn(10)
		new /mob/living/simple_animal/hostile/blobspore(src.loc, src)

	return 1

/obj/effect/blob/factory/Destroy()
	if (spores.len)
		for(var/mob/living/simple_animal/hostile/blobspore/S in spores)
			S.death()

	if (!manual_remove && overmind)
		to_chat(overmind,"<span class='warning'>A factory blob that you had created has been destroyed.</span> <b><a href='?src=\ref[overmind];blobjump=\ref[loc]'>(JUMP)</a></b>")
		overmind.special_blobs -= src
		overmind.update_specialblobs()

	..()

/obj/effect/blob/factory/update_icon(spawnend)
	spawn(1)
		overlays.len = 0
		underlays.len = 0

		underlays += image(icon,"roots")

		if(!spawning)
			for(var/obj/effect/blob/B in orange(src,1))
				overlays += image(icon,"factoryconnect",dir = get_dir(src,B))
		if(spawnend)
			spawn(10)
				update_icon()

		..()

/////////////BLOB SPORE///////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/simple_animal/hostile/blobspore
	name = "Blob Spore"
	desc = "A form of blob antibodies that attack foreign entities."
	icon = 'icons/mob/blob/blob.dmi'
	icon_state = "blobpod"
	icon_living = "blobpod"
	pass_flags = PASS_FLAG_BLOB
	health = 30
	maxHealth = 30
	melee_damage_lower = 16
	melee_damage_upper = 26
	attacktext = "hits"
	attack_sound = 'sound/weapons/rapidslice.ogg'
	var/obj/effect/blob/factory/factory = null
	faction = "blob"
	minbodytemp = 0
	maxbodytemp = 360
	plane = DEFAULT_PLANE
	layer = BLOB_SPORE_LAYER

/mob/living/simple_animal/hostile/blobspore/New(loc, obj/effect/blob/factory/linked_node)
	if(istype(linked_node))
		factory = linked_node
		factory.spores += src
		icon = factory.icon

	..()

/mob/living/simple_animal/hostile/blobspore/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()

	adjustBruteLoss(Clamp(0.01 * exposed_temperature, 1, 5))

/mob/living/simple_animal/hostile/blobspore/blob_act()
	return

/mob/living/simple_animal/hostile/blobspore/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover, /obj/effect/blob))
		return 1

	return ..()

/mob/living/simple_animal/hostile/blobspore/death(gibbed = FALSE)
	..(TRUE) //Gibs regardless
	playsound(src, "gib", 50, 1)
	qdel(src)

/mob/living/simple_animal/hostile/blobspore/Destroy()
	//creating a pathogenic cloud upon death
	anim(target = loc, a_icon = icon, flick_anim = "blob_act", sleeptime = 15, direction = SOUTH)

	if(factory)
		factory.spores -= src
	..()

/mob/living/simple_animal/hostile/blobspore/UnarmedAttack(mob/living/target)
	. = ..()
