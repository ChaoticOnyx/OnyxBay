///////////////////////////////////////////////////////////////////////
//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	siemens_coefficient = 0.75
	coverage = 1.0
	body_parts_covered = HANDS
	slot_flags = SLOT_GLOVES
	attack_verb = list("challenged")
	species_restricted = list("exclude", SPECIES_UNATHI, SPECIES_TAJARA, SPECIES_VOX)
	blood_overlay_type = "bloodyhands"

	drop_sound = SFX_DROP_GLOVES
	pickup_sound = SFX_PICKUP_GLOVES

	var/transfer_blood = 0
	var/mob/living/carbon/human/bloody_hands_mob

	var/wired = FALSE
	var/wire_color

	var/clipped = FALSE

	var/weakref/ring = null            // Covered ring (obj/item/clothing/ring)
	var/weakref/wearer = null          // Used for covered rings when dropping (mob/living/carbon/human)

	var/unarmed_damage_override = null // Overrides unarmed attack damage if not null

/obj/item/clothing/gloves/Initialize()
	if(item_flags & ITEM_FLAG_PREMODIFIED)
		cut_fingertops()
	. = ..()

/obj/item/clothing/gloves/Destroy()
	var/mob/living/carbon/human/H = wearer?.resolve()
	var/obj/item/clothing/ring/R = ring?.resolve()
	if(istype(H) && istype(R)) //Put the ring back on if the check fails.
		H.equip_to_slot_if_possible(R, slot_gloves)
		ring = null
	QDEL_NULL(ring)
	wearer = null
	bloody_hands_mob = null
	return ..()

/obj/item/clothing/gloves/update_clothing_icon()
	if(ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_gloves()

/obj/item/clothing/gloves/on_update_icon(needs_updating=FALSE)
	if(!needs_updating)
		return ..()

	ClearOverlays()

	if(wired)
		AddOverlays(image(icon, "gloves_wire"))

/obj/item/clothing/gloves/get_fibers()
	var/fiber_id = copytext(md5("\ref[src] fiber"), 1, 6)

	return "material from a pair of [name] ([fiber_id])"

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(atom/A, proximity)
	return FALSE // return TRUE to cancel attack_hand()

/obj/item/clothing/gloves/attackby(obj/item/W, mob/user)
	if(isWirecutter(W) || istype(W, /obj/item/scalpel))
		if(wired)
			wired = FALSE
			update_icon(TRUE)
			new /obj/item/stack/cable_coil(user.loc, 15, wire_color)
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
			to_chat(user, SPAN("notice", "You remove the wires from \the [src]."))
			return

		if(clipped)
			to_chat(user, SPAN("notice", "\The [src] have already been modified!"))
			update_icon()
			return

		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		user.visible_message(SPAN("warning", "\The [user] modifies \the [src] with \the [W]."), SPAN("warning", "You modify \the [src] with \the [W]."))

		cut_fingertops() // apply change, so relevant xenos can wear these
		return

	if(isCoil(W) && !wired)
		if(istype(src, /obj/item/clothing/gloves/rig))
			to_chat(user, SPAN("notice", "That definitely won't work."))
			return
		var/obj/item/stack/cable_coil/C = W
		if(C.use(15))
			wired = TRUE
			wire_color = C.color
			update_icon(TRUE)
			user.visible_message(SPAN("warning", "\The [user] attaches some wires to \the [src]."), SPAN("notice", "You attach some wires to \the [src]."))
			return

	if(istype(W, /obj/item/tape_roll) && wired && user.drop(src))
		user.visible_message(SPAN("warning", "\The [user] secures the wires on \the [src] with \the [W]."), SPAN("notice", "You secure the wires on \the [src] with \the [W]."))
		new /obj/item/clothing/gloves/stun(loc, src)
		return

// Applies "clipped" and removes relevant restricted species from the list,
// making them wearable by the specified species, does nothing if already cut
/obj/item/clothing/gloves/proc/cut_fingertops()
	if(clipped)
		return

	clipped = TRUE
	coverage /= 2
	name = "modified [name]"
	desc = "[desc]<br>They have been modified to accommodate a different shape."
	if("exclude" in species_restricted)
		species_restricted -= SPECIES_UNATHI
		species_restricted -= SPECIES_TAJARA
	return

/obj/item/clothing/gloves/mob_can_equip(mob/user)
	var/mob/living/carbon/human/H = user

	if(istype(H.gloves, /obj/item/clothing/ring))
		var/obj/item/clothing/ring/R = H.gloves
		ring = weakref(R)
		if(!R.undergloves)
			to_chat(user, "You are unable to wear \the [src] as \the [R] are in the way.")
			ring = null
			return FALSE
		H.drop(R, src, TRUE) // Remove the ring (or other under-glove item in the hand slot?) so you can put on the gloves.

	if(!..())
		var/obj/item/clothing/ring/R = ring?.resolve()
		if(istype(R)) //Put the ring back on if the check fails.
			if(H.equip_to_slot_if_possible(R, slot_gloves))
				ring = null
		return FALSE

	var/obj/item/clothing/ring/R = ring?.resolve()
	if(istype(R))
		to_chat(user, "You slip \the [src] on over \the [R].")
	wearer = weakref(H)
	return TRUE

/obj/item/clothing/gloves/dropped()
	..()
	var/mob/living/carbon/human/H = wearer?.resolve()
	var/obj/item/clothing/ring/R = ring?.resolve()
	if(istype(R) && istype(H))
		if(!H.equip_to_slot_if_possible(R, slot_gloves))
			R.forceMove(get_turf(src))
	ring = null
	wearer = null

/obj/item/clothing/gloves/clean_blood()
	. = ..()
	if(.)
		transfer_blood = 0
