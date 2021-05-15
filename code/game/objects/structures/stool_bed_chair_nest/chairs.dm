/obj/structure/bed/chair	//YES, chairs are a type of bed, which are a type of stool. This works, believe me.	-Pete
	name = "chair"
	desc = "A four-legged chair, rigid and slightly uncomfortable. Helpful when you don't want to use your legs at the moment."
	icon_state = "chair_preview"
	color = "#999999"
	base_icon = "chair"
	buckle_dir = 0
	buckle_lying = 0 //force people to sit up in chairs when buckled
	buckle_pixel_shift = "x=0;y=0"
	anchored = FALSE
	pull_slowdown = PULL_SLOWDOWN_EXTREME
	var/propelled = 0 // Check for fire-extinguisher-driven chairs
	var/foldable = TRUE

/obj/structure/bed/chair/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(!padding_material && istype(W, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/SK = W
		if(!SK.status)
			to_chat(user, "<span class='notice'>\The [SK] is not ready to be attached!</span>")
			return
		user.drop_item()
		var/obj/structure/bed/chair/e_chair/E = new (src.loc, material.name)
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		E.set_dir(dir)
		E.part = SK
		SK.forceMove(E)
		SK.master = E
		qdel(src)

/obj/structure/bed/chair/attack_tk(mob/user as mob)
	if(buckled_mob)
		..()
	else
		rotate()
	return

/obj/structure/bed/chair/post_buckle_mob()
	update_icon()
	return ..()

/obj/structure/bed/chair/update_icon()
	..()

	var/cache_key = "[base_icon]-[material.name]-over"
	if(isnull(stool_cache[cache_key]))
		var/image/I = image('icons/obj/furniture.dmi', "[base_icon]_over")
		if(material_alteration & MATERIAL_ALTERATION_COLOR)
			I.color = material.icon_colour
		I.layer = ABOVE_HUMAN_LAYER
		stool_cache[cache_key] = I
	overlays |= stool_cache[cache_key]
	// Padding overlay.
	if(padding_material)
		var/padding_cache_key = "[base_icon]-padding-[padding_material.name]-over"
		if(isnull(stool_cache[padding_cache_key]))
			var/image/I =  image(icon, "[base_icon]_padding_over")
			if(material_alteration & MATERIAL_ALTERATION_COLOR)
				I.color = padding_material.icon_colour
			I.layer = ABOVE_HUMAN_LAYER
			stool_cache[padding_cache_key] = I
		overlays |= stool_cache[padding_cache_key]

	if(buckled_mob && padding_material)
		cache_key = "[base_icon]-armrest-[padding_material.name]"
		if(isnull(stool_cache[cache_key]))
			var/image/I = image(icon, "[base_icon]_armrest")
			I.layer = ABOVE_HUMAN_LAYER
			if(material_alteration & MATERIAL_ALTERATION_COLOR)
				I.color = padding_material.icon_colour
			stool_cache[cache_key] = I
		overlays |= stool_cache[cache_key]

/obj/structure/bed/chair/set_dir()
	..()
	if(buckled_mob)
		buckled_mob.set_dir(dir)

/obj/structure/bed/chair/AltClick()
	rotate()

/obj/structure/bed/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	if(!usr || !Adjacent(usr))
		return

	if(usr.stat == DEAD)
		var/area/A = get_area(src)
		if(A?.holy)
			to_chat(usr, SPAN("warning", "\The [src] is on sacred ground, you cannot turn it."))
			return
	else if(usr.incapacitated())
		return

	src.set_dir(turn(src.dir, 90))
	return

/* ======================================================= */
/* -------------------- Folded Chairs -------------------- */
/* ======================================================= */

/obj/item/weapon/foldchair
	name = "chair"
	desc = "A folded chair. Good for smashing noggin-shaped things."
	icon = 'icons/obj/furniture.dmi'
	icon_state = "folded_chair"
	item_state = "table_parts"
	w_class = ITEM_SIZE_GARGANTUAN // Jesus no
	force = 12.5
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4
	mod_weight = 1.25
	mod_reach = 1.15
	mod_handy = 0.3
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	matter = list(MATERIAL_STEEL = 2000)
	var/material/padding_material
	var/material/material

/obj/item/weapon/foldchair/New()
	..()
	if(!material)
		material = get_material_by_name(MATERIAL_STEEL)

/obj/item/weapon/foldchair/attack_self(mob/user)
	var/obj/structure/bed/chair/O = new /obj/structure/bed/chair(user.loc)
	O.add_fingerprint(user)
	O.dir = user.dir
	O.material = material
	O.padding_material = padding_material
	O.update_icon()
	visible_message("[user] unfolds \the [O.name].")
	qdel(src)

/obj/item/weapon/foldchair/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isWrench(W))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		material.place_sheet(get_turf(src))
		if(padding_material)
			padding_material.place_sheet(get_turf(src))
		qdel(src)
	..()

/obj/structure/bed/chair/MouseDrop(over_object, src_location, over_location)
	..()
	if(foldable && (over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if(!ishuman(usr))
			return

		var/mob/living/carbon/human/H = usr
		if(H.restrained())
			return

		fold(usr)

/obj/structure/bed/chair/proc/fold(mob/user)
	if(!foldable)
		return

	var/list/collapse_message = list(SPAN_WARNING("\The [src.name] has collapsed!"), null)

	if(buckled_mob)
		collapse_message = list(\
			SPAN_WARNING("[buckled_mob] falls down [user ? "as [user] collapses" : "from collapsing"] \the [src.name]!"),\
			user ? SPAN_NOTICE("You collapse \the [src.name] and made [buckled_mob] fall down!") : null)

		var/mob/living/occupant = unbuckle_mob()
		var/blocked = occupant.run_armor_check(BP_GROIN, "melee")

		occupant.apply_effect(4, STUN, blocked)
		occupant.apply_effect(4, WEAKEN, blocked)
		occupant.apply_damage(rand(5,10), BRUTE, BP_GROIN, blocked)
		playsound(src, 'sound/effects/fighting/punch1.ogg', 50, 1, -1)
	else if(user)
		collapse_message = list("[user] collapses \the [src.name].", "You collapse \the [src.name].")

	visible_message(collapse_message[1], collapse_message[2])
	var/obj/item/weapon/foldchair/O = new /obj/item/weapon/foldchair(get_turf(src))
	if(user)
		O.add_fingerprint(user)
	O.material = material
	O.padding_material = padding_material
	QDEL_IN(src, 0)

/* ====================================================== */
/* -------------------- Comfy Chairs -------------------- */
/* ====================================================== */

// Leaving this in for the sake of compilation.
/obj/structure/bed/chair/comfy
	desc = "It's a chair. It looks comfy."
	icon_state = "comfychair_preview"
	base_icon = "comfychair"
	foldable = FALSE
	anchored = TRUE

/obj/structure/bed/chair/comfy/brown/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL, MATERIAL_LEATHER)

/obj/structure/bed/chair/comfy/red/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL, MATERIAL_CARPET)

/obj/structure/bed/chair/comfy/teal/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL, "teal")

/obj/structure/bed/chair/comfy/black/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL, "black")

/obj/structure/bed/chair/comfy/green/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL, "green")

/obj/structure/bed/chair/comfy/purp/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL, "purple")

/obj/structure/bed/chair/comfy/blue/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL, "blue")

/obj/structure/bed/chair/comfy/beige/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL, "beige")

/obj/structure/bed/chair/comfy/lime/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL, "lime")

/obj/structure/bed/chair/comfy/captain
	name = "captain chair"
	desc = "It's a chair. Only for the highest ranked asses."
	icon_state = "capchair_preview"
	base_icon = "capchair"
	buckle_movable = 1

/obj/structure/bed/chair/comfy/captain/New(newloc,newmaterial)
	..(newloc, MATERIAL_STEEL, "black")

/* ======================================================= */
/* -------------------- Office Chairs -------------------- */
/* ======================================================= */

/obj/structure/bed/chair/office
	anchored = FALSE
	buckle_movable = 1
	material_alteration = MATERIAL_ALTERATION_NONE
	foldable = FALSE
	pull_slowdown = PULL_SLOWDOWN_TINY

/obj/structure/bed/chair/office/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack) || isWirecutter(W))
		return
	..()

/obj/structure/bed/chair/office/Move()
	. = ..()
	if(buckled_mob)
		var/mob/living/occupant = buckled_mob
		if (occupant && (src.loc != occupant.loc))
			if (propelled)
				for (var/mob/O in src.loc)
					if (O != occupant)
						Bump(O)
			else
				unbuckle_mob()

/obj/structure/bed/chair/office/Bump(atom/A)
	..()
	if(!buckled_mob)
		return

	if(propelled)
		var/mob/living/occupant = unbuckle_mob()

		var/def_zone = ran_zone()
		var/blocked = occupant.run_armor_check(def_zone, "melee")
		occupant.throw_at(A, 3, propelled)
		occupant.apply_effect(6, STUN, blocked)
		occupant.apply_effect(6, WEAKEN, blocked)
		occupant.apply_effect(6, STUTTER, blocked)
		occupant.apply_damage(10, BRUTE, def_zone, blocked)
		playsound(src.loc, "punch", rand(80, 100), 1, -1)
		if(istype(A, /mob/living))
			var/mob/living/victim = A
			def_zone = ran_zone()
			blocked = victim.run_armor_check(def_zone, "melee")
			victim.apply_effect(6, STUN, blocked)
			victim.apply_effect(6, WEAKEN, blocked)
			victim.apply_effect(6, STUTTER, blocked)
			victim.apply_damage(10, BRUTE, def_zone, blocked)
		occupant.visible_message("<span class='danger'>[occupant] crashed into \the [A]!</span>")

/obj/structure/bed/chair/office/light
	base_icon = "officechair_white"
	icon_state = "officechair_white_preview"

/obj/structure/bed/chair/office/dark
	base_icon = "officechair_dark"
	icon_state = "officechair_dark_preview"

/* ===================================================== */
/* -------------------- Misc Chairs -------------------- */
/* ===================================================== */

/obj/structure/bed/chair/wood
	desc = "Old is never too old to not be in fashion."
	base_icon = "wooden_chair"
	icon_state = "wooden_chair_preview"
	material_alteration = MATERIAL_ALTERATION_NAME
	foldable = FALSE

/obj/structure/bed/chair/wood/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack) || istype(W, /obj/item/weapon/wirecutters))
		return
	..()

/obj/structure/bed/chair/wood/New(newloc)
	..(newloc, MATERIAL_WOOD)

/obj/structure/bed/chair/wood/wings
	base_icon = "wooden_chair_wings"
	icon_state = "wooden_chair_wings_preview"

/obj/structure/bed/chair/shuttle
	name = "shuttle chair"
	desc = "It looks *almost* comfortable."
	base_icon = "shuttle_chair"
	icon_state = "shuttle_chair_preview"
	material_alteration = MATERIAL_ALTERATION_NONE
	foldable = FALSE
	anchored = TRUE

/obj/structure/bed/chair/shuttle/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack) || istype(W, /obj/item/weapon/wirecutters))
		return
	..()

/obj/structure/bed/chair/shuttle/blue/New(newloc,newmaterial)
	..(newloc, MATERIAL_PLASTIC,"blue")

/obj/structure/bed/chair/shuttle/red
	base_icon = "shuttle_chaired"
	icon_state = "shuttle_chaired_preview"

/obj/structure/bed/chair/shuttle/red/New(newloc, newmaterial)
	..(newloc, MATERIAL_PLASTIC, MATERIAL_CARPET)

// Colorful chairs
/obj/structure/bed/chair/brown/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL, MATERIAL_LEATHER)

/obj/structure/bed/chair/red/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL, MATERIAL_CARPET)

/obj/structure/bed/chair/teal/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL,"teal")

/obj/structure/bed/chair/black/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL,"black")

/obj/structure/bed/chair/green/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL,"green")

/obj/structure/bed/chair/purp/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL,"purple")

/obj/structure/bed/chair/blue/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL,"blue")

/obj/structure/bed/chair/beige/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL,"beige")

/obj/structure/bed/chair/lime/New(newloc, newmaterial)
	..(newloc, MATERIAL_STEEL,"lime")
