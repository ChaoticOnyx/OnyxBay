/obj/structure/barricade/material
	name = "barricade"
	desc = "This space is blocked off by a barricade."

	icon = 'icons/obj/structures.dmi'
	icon_state = "barricade"

	atom_flags = ATOM_FLAG_CLIMBABLE
	turf_height_offset = 3 // It looks so shitty I dunno what offset to use. 3 will go for now I guess. ~ TobyThorne
	climb_delay = 5 SECONDS // Matching the old delay. RIP fatties.

	/// Reference to a material datum this object was made from.
	var/material/material


/obj/structure/barricade/material/Initialize(mapload, material_name)
	. = ..()

	if(!material_name)
		material_name = MATERIAL_WOOD

	var/material = get_material_by_name(material_name)
	if(!material)
		return INITIALIZE_HINT_QDEL

	_apply_material(material)


/obj/structure/barricade/material/proc/_apply_material(material/new_material)
	material = new_material

	name = "[material.display_name] barricade"
	desc = "This space is blocked off by a barricade made of [material.display_name]."

	color = material.icon_colour
	maxdamage = material.integrity


/obj/structure/barricade/material/Destroy()
	material = null
	return ..()


/obj/structure/barricade/material/get_material()
	return material


/obj/structure/barricade/material/attackby(obj/item/W, mob/user)
	if(isCrowbar(W))
		_deconstruct(user)
		return

	if(isstack(W))
		_repair_damage(W, user)
		return

	return ..()


/obj/structure/barricade/material/proc/_deconstruct(mob/user)
	show_splash_text(user, "starting deconstruction.", "You begin deconstructing <b>\the [src]</b>!")
	if(do_after(user, 20, src, luck_check_type = LUCK_CHECK_ENG))
		show_splash_text(user, "barricade deconstucted.", "You deconstruct <b>\the [src]</b>!")
		playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)

		_dismantle()
		return

	show_splash_text(user, "action interrupted!", "You must remain still while deconstructing!")


/obj/structure/barricade/material/proc/_repair_damage(obj/item/stack/S, mob/user)
	if(damage == 0 || S.get_material_name() != material.name)
		return

	if(S.get_amount() < 1)
		show_splash_text(user, "not enough material!", "There's not enough [S] to repair <b>\the [src]</b>!")
		return

	show_splash_text(user, "starting repair.", "You begin to repair <b>\the [src]</b>.")
	if(do_after(user, 20, src, luck_check_type = LUCK_CHECK_ENG) && damage != 0)
		if(S.use(1))
			damage = 0

			show_splash_text(user, "repair finished.", "You have repaired <b>\the [src]!</b>")
			return

	show_splash_text(user, "action interrupted!", "You must remain still while repairing!")


/obj/structure/barricade/material/Break()
	_dismantle()


/obj/structure/barricade/material/proc/_dismantle()
	material.place_dismantled_product(get_turf(src))
	qdel(src)
