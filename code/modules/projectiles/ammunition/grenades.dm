
/obj/item/ammo_casing/grenade
	name = "grenade shell (practice)"
	desc = "A 40mm grenade shell. This one contains no explosives, but may still knock someone's teeth out."
	icon_state = "40mm"
	spent_icon = "40mm-spent"
	caliber = "40mm"
	projectile_type = /obj/item/projectile/grenade
	matter = list(MATERIAL_STEEL = 360)
	w_class = ITEM_SIZE_SMALL
	fall_sounds = list('sound/effects/weapons/gun/shell_fall.ogg')

/obj/item/ammo_casing/grenade/attackby(obj/item/W, mob/user)
	if(!is_spent && isScrewdriver(W))
		to_chat(user, SPAN("notice", "\The [src] doesn't seem to be disassemblable."))
		return
	return ..()

/obj/item/ammo_casing/grenade/rubber
	name = "grenade shell (rubber)"
	desc = "A 40mm grenade shell. This one doesn't explode on impact, but may Space Jesus have mercy upon the one who gets hit directly."
	icon_state = "40mm_rubber"
	projectile_type = /obj/item/projectile/grenade/rubber

/obj/item/ammo_casing/grenade/he
	name = "grenade shell (HE)"
	desc = "A 40mm HE grenade shell."
	icon_state = "40mm_he"
	projectile_type = /obj/item/projectile/grenade/he

/obj/item/ammo_casing/grenade/hep
	name = "grenade shell (HE+)"
	desc = "A 40mm HE+ grenade shell. When you absolutely need someone to get fucked."
	icon_state = "40mm_hep"
	projectile_type = /obj/item/projectile/grenade/hep

// Loadable shells can be used to turn a mere grenade launcher into a potassium-water doomsday gun.
/obj/item/ammo_casing/grenade/loaded
	name = "grenade shell"
	desc = "A 40mm grenade shell. This one can be loaded with a regular grenade to make it grenade-launcherable."
	icon_state = "40mm_loaded0"
	projectile_type = /obj/item/projectile/grenade/loaded

	var/opened = FALSE
	var/obj/item/grenade/grenade
	var/label_text = ""

/obj/item/ammo_casing/grenade/loaded/Initialize()
	. = ..()
	if(label_text)
		name = "grenade shell"
		AddComponent(/datum/component/label, label_text) // So the name isn't hardcoded and the label can be removed for reusability

	if(ispath(grenade))
		grenade = new grenade(src)

	update_icon()

/obj/item/ammo_casing/grenade/loaded/Destroy()
	if(!QDELETED(grenade))
		QDEL_NULL(grenade)
	return ..()

/obj/item/ammo_casing/grenade/loaded/post_attach_label(datum/component/label/L)
	label_text = L.label_name
	update_icon()

/obj/item/ammo_casing/grenade/loaded/post_remove_label(datum/component/label/L)
	..()
	label_text = null
	update_icon()

/obj/item/ammo_casing/grenade/loaded/proc/open(mob/user)
	if(is_spent || opened == -1)
		return

	opened = !opened
	if(user)
		to_chat(user, SPAN("notice", "You [opened ? "dis" : ""]assemble the shell."))

	update_icon()
	playsound(loc, 'sound/items/Screwdriver.ogg', 25, -3)

/obj/item/ammo_casing/grenade/loaded/on_update_icon()
	if(spent_icon && is_spent)
		ClearOverlays()
		icon_state = spent_icon
		return
	else if(opened != -1)
		icon_state = "40mm_loaded[opened][grenade ? "" : "u"]"
	ClearOverlays()
	if(opened != TRUE && label_text)
		AddOverlays(image(icon, src, "40mm_label"))

/obj/item/ammo_casing/grenade/loaded/attack_self(mob/user)
	if(!is_spent && opened != -1)
		open(user)
		add_fingerprint(user)
		return
	return ..()

/obj/item/ammo_casing/grenade/loaded/attackby(obj/item/W, mob/user)
	if(is_spent)
		return

	if(isScrewdriver(W))
		if(opened == -1)
			to_chat(user, SPAN("notice", "\The [src] doesn't seem to be disassemblable."))
		else
			open(user)
		return

	if(istype(W, /obj/item/grenade))
		if(!user.drop(W))
			return
		to_chat(user, "You install \the [grenade] into \the [src].")
		W.forceMove(src)
		grenade = W
		update_icon()
		return
	return ..()

/obj/item/ammo_casing/grenade/loaded/attack_hand(mob/user)
	if(opened == TRUE && grenade && user.has_in_passive_hand(src))
		to_chat(user, "You remove \the [grenade] from \the [src].")
		user.pick_or_drop(grenade)
		grenade = null
		update_icon()
	else
		..()

/obj/item/ammo_casing/grenade/loaded/expend()
	if(!ispath(projectile_type))
		return

	if(is_spent)
		return

	if(opened == TRUE)
		return null

	var/obj/item/projectile/proj = new projectile_type(src)

	if(istype(proj, /obj/item/projectile/grenade/loaded))
		var/obj/item/projectile/grenade/loaded/L = proj
		L.set_grenade(grenade)
		grenade = null

	// Aurora forensics port, gunpowder residue.
	if(leaves_residue)
		leave_residue()

	is_spent = TRUE
	update_icon()
	return proj

/obj/item/ammo_casing/grenade/loaded/empty
	icon_state = "40mm_loaded1u"
	opened = TRUE

/obj/item/ammo_casing/grenade/loaded/frag
	name = "grenade shell (FRAG)"
	grenade = /obj/item/grenade/frag/shell // For actual use
	label_text = "FRAG"
	opened = -1 // Let's just not

/obj/item/ammo_casing/grenade/loaded/frag/better
	name = "grenade shell (FRAG+)"
	grenade = /obj/item/grenade/frag // For shitspawn or something
	label_text = "FRAG+"

/obj/item/ammo_casing/grenade/loaded/frag/best
	name = "grenade shell (FRAG++)"
	grenade = /obj/item/grenade/frag/high_yield // For REAL shitspawn
	label_text = "FRAG++"

/obj/item/ammo_casing/grenade/loaded/empgrenade
	name = "grenade shell (EMP)"
	grenade = /obj/item/grenade/empgrenade
	label_text = "EMP"
	opened = -1

/obj/item/ammo_casing/grenade/loaded/empgrenade/low_yield
	name = "grenade shell (low yield EMP)"
	grenade = /obj/item/grenade/empgrenade/low_yield
	label_text = "low yield EMP"

/obj/item/ammo_casing/grenade/loaded/smokebomb
	name = "grenade shell (smoke)"
	grenade = /obj/item/grenade/smokebomb
	label_text = "smoke"

/obj/item/ammo_casing/grenade/loaded/incendiary
	name = "grenade shell (incendiary)"
	grenade = /obj/item/grenade/chem_grenade/incendiary
	label_text = "incendiary"

/obj/item/ammo_casing/grenade/loaded/teargas
	name = "grenade shell (tear gas)"
	grenade = /obj/item/grenade/chem_grenade/teargas
	label_text = "tear gas"

/obj/item/ammo_casing/grenade/loaded/cleaner
	name = "grenade shell (cleaner)"
	grenade = /obj/item/grenade/chem_grenade/cleaner
	label_text = "cleaner"

/obj/item/ammo_casing/grenade/loaded/fake
	name = "grenade shell (NE)"
	grenade = /obj/item/grenade/fake
	label_text = "NE"

/obj/item/ammo_casing/grenade/loaded/stingbang
	name = "grenade shell (stingbang)"
	grenade = /obj/item/grenade/frag/stingbang/shell
	label_text = "STING"
	opened = -1
