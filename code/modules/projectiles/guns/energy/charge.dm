
#define BARREL_TIMER 5
/obj/item/gun/charge
	name = "charge carbine"
	desc = "C-13 Charge Carbine, NanoTrasen's flagship all-purpose weapon. Even though it's rather cheap and somewhat unwieldy, it can use a wide range of energy-based ammunition."
	icon_state = "charge_rifle-preview"
	item_state = "erifle"
	improper_held_icon = TRUE
	slot_flags = SLOT_BELT|SLOT_BACK
	w_class = ITEM_SIZE_LARGE

	force = 12.5
	mod_weight = 1.0
	mod_reach = 0.8
	mod_handy = 1.0

	one_hand_penalty = 3
	accuracy = 0.0
	fire_delay = null
	burst_accuracy = list(0)
	burst = 1
	burst_delay = 2

	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 5, TECH_POWER = 3)
	matter = list(MATERIAL_STEEL = 2500)

	firemodes = list(
		list(mode_name = "semiauto",       fire_delay = null, charge_cost = 20, burst = 1),
		list(mode_name = "2-round bursts", fire_delay = 2,    charge_cost = 40, burst = 2)
	)

	var/mag_insert_sound = SFX_MAGAZINE_INSERT
	var/mag_eject_sound = 'sound/weapons/empty.ogg'
	var/charge_cost = 20
	var/modifystate = "charge_rifle"
	var/barrel_overlay = ""
	var/cell_cooldown = 0

	var/obj/item/cell/ammo/charge/power_supply
	var/projectile_type = /obj/item/projectile/energy/electrode/stunsphere
	var/cell_type = /obj/item/cell/ammo/charge/stun // What we start with


/obj/item/gun/charge/Initialize()
	. = ..()
	if(cell_type)
		power_supply = new cell_type(src)
	update_cell(FALSE)

/obj/item/gun/charge/Destroy()
	QDEL_NULL(power_supply)
	return ..()

/obj/item/gun/charge/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/cell/ammo/charge))
		load_cell(A, user)
		return
	return ..()

/obj/item/gun/charge/attack_hand(mob/user)
	if(user.get_inactive_hand() == src)
		unload_cell(user, allow_dump = FALSE)
		return
	return ..()

/obj/item/gun/charge/examine(mob/user, infix)
	. = ..()
	if(power_supply)
		. += "It has \a [power_supply] loaded."
	. += "Has <b>[power_supply ? round(power_supply.charge / charge_cost) : "0"]</b> shot\s remaining."

/obj/item/gun/charge/switch_firemodes()
	. = ..()
	if(.)
		update_icon()
		playsound(src, 'sound/effects/weapons/energy/toggle_mode1.ogg', rand(50, 75), FALSE)

/obj/item/gun/charge/emp_act(severity)
	..()
	update_icon()

/obj/item/gun/charge/consume_next_projectile()
	if(!power_supply)
		return null

	if(!ispath(projectile_type))
		return null

	if(!power_supply.checked_use(charge_cost))
		return null

	var/obj/item/projectile/BB = new projectile_type(src)
	if(BB.projectile_light)
		BB.layer = ABOVE_LIGHTING_LAYER
		BB.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		BB.set_light(BB.projectile_max_bright, BB.projectile_inner_range, BB.projectile_outer_range, BB.projectile_falloff_curve, BB.projectile_brightness_color)
	return BB


/obj/item/gun/charge/on_update_icon()
	..()
	ClearOverlays()
	if(!power_supply)
		icon_state = "[modifystate]-empty"
		return

	icon_state = modifystate

	if(round(power_supply.charge / charge_cost) == 0)
		AddOverlays("[modifystate]-noammo")
	else if(burst == 1)
		AddOverlays("[modifystate]-semiauto")
	else
		AddOverlays("[modifystate]-burst")

	var/ratio = (power_supply.charge >= charge_cost) ? max(round(CELL_PERCENT(power_supply), 25), 25) : 0
	AddOverlays("[modifystate]-[power_supply.barrel_overlay][ratio]")

/obj/item/gun/charge/proc/update_barrel_overlay(opening)
	if(opening)
		CutOverlays(barrel_overlay, ATOM_ICON_CACHE_PROTECTED)
		CutOverlays("[modifystate]_closing", ATOM_ICON_CACHE_PROTECTED)

		barrel_overlay = "[modifystate]-[power_supply.barrel_overlay]"
		AddOverlays(barrel_overlay, ATOM_ICON_CACHE_PROTECTED)
		AddOverlays("[modifystate]_opening", ATOM_ICON_CACHE_PROTECTED)
		ImmediateOverlayUpdate()
		spawn(BARREL_TIMER)
			CutOverlays("[modifystate]_opening", ATOM_ICON_CACHE_PROTECTED)
			ImmediateOverlayUpdate()
	else
		CutOverlays("[modifystate]_opening", ATOM_ICON_CACHE_PROTECTED)
		AddOverlays("[modifystate]_closing", ATOM_ICON_CACHE_PROTECTED)
		ImmediateOverlayUpdate()
		spawn(BARREL_TIMER)
			CutOverlays("[modifystate]_closing", ATOM_ICON_CACHE_PROTECTED)
			AddOverlays("[modifystate]_closed", ATOM_ICON_CACHE_PROTECTED)
			ImmediateOverlayUpdate()


/obj/item/gun/charge/proc/update_cell(should_update_icons = TRUE)
	if(!power_supply)
		if(should_update_icons)
			update_icon()
			update_barrel_overlay(FALSE)
		return

	var/_sel_mode = sel_mode // So we don't have to switch between semiauto and bursts every time we reload
	set_firemodes(power_supply.firemodes)
	sel_mode= _sel_mode
	set_firemode()

	update_icon()
	update_barrel_overlay(TRUE)
	return

/obj/item/gun/charge/proc/check_load_cooldown(mob/user)
	if(istype(user))
		to_chat(user, SPAN("notice", "\The [src] is still reassembling!"))
	return (world.time >= cell_cooldown)

/obj/item/gun/charge/proc/set_load_cooldown()
	cell_cooldown = world.time + BARREL_TIMER

/obj/item/gun/charge/proc/load_cell(obj/item/cell/ammo/charge/A, atom/movable/loader)
	if(power_supply)
		to_chat(loader, SPAN("warning", "\The [src] already has a magazine cell loaded."))
		return

	if(!check_load_cooldown(loader))
		return

	if(ismob(loader))
		var/mob/user = loader
		user.drop(A, src)
	else
		A.forceMove(src)

	power_supply = A
	loader.visible_message(
		"[loader] inserts \the [A] into \the [src].",
		SPAN("notice", "You insert \the [A] into \the [src].")
		)

	set_load_cooldown()
	playsound(loc, mag_insert_sound, rand(45, 60), FALSE)

	update_cell()
	return

/obj/item/gun/charge/proc/unload_cell(atom/movable/unloader, allow_dump = TRUE, dump_loc = null)
	if(!power_supply)
		return

	if(!check_load_cooldown(unloader))
		return

	if(allow_dump)
		power_supply.dropInto(isnull(dump_loc) ? unloader.loc : dump_loc)
		unloader.visible_message(
			"[unloader] ejects [power_supply] from \the [src].",
			SPAN("notice", "You eject [power_supply] from \the [src].")
			)
	else if(ismob(unloader))
		var/mob/user = unloader
		user.pick_or_drop(power_supply)
		unloader.visible_message(
			"[user] removes [power_supply] from \the [src].",
			SPAN("notice", "You remove [power_supply] from \the [src].")
			)
	else if(Adjacent(src, unloader))
		power_supply.forceMove(get_turf(unloader))

	set_load_cooldown()
	playsound(src.loc, mag_eject_sound, 50, 1)
	power_supply.update_icon()
	power_supply = null

	update_cell()
	return


/obj/item/cell/ammo/charge
	name = "magazine cell"
	desc = "A power cell designed to be used as a magazine for charge-based weapons. This one must not be seen at all."
	icon = 'icons/obj/ammo.dmi'
	item_state = "cell"
	icon_state = "charge"
	maxcharge = 160

	var/barrel_overlay = ""
	var/firemodes = list(
		list(mode_name = "semiauto",       fire_delay = 2, charge_cost = 20, burst = 1, projectile_type = null),
		list(mode_name = "2-round bursts", fire_delay = 2, charge_cost = 20, burst = 2, projectile_type = null)
	)

/obj/item/cell/ammo/charge/stun
	name = "magazine cell (stun)"
	desc = "A power cell designed to be used as a magazine for charge-based weapons. This one turns the weapon into a non-lethal taser rifle."
	icon_state = "charge_stun"

	barrel_overlay = "stun"
	firemodes = list(
		list(mode_name = "semiauto",       fire_delay = 2, charge_cost = 20, burst = 1, projectile_type = /obj/item/projectile/energy/electrode/lesser),
		list(mode_name = "2-round bursts", fire_delay = 2, charge_cost = 20, burst = 2, projectile_type = /obj/item/projectile/energy/electrode/lesser)
	)

/obj/item/cell/ammo/charge/blaster
	name = "magazine cell (blaster)"
	desc = "A power cell designed to be used as a magazine for charge-based weapons. This one allows the weapon to shoot concentrated blasts of energy. While the blasts deal more damage than lasers, they are not as good at penetrating armor."
	icon_state = "charge_blaster"

	barrel_overlay = "blaster"
	firemodes = list(
		list(mode_name = "semiauto",       fire_delay = 2, charge_cost = 20, burst = 1, projectile_type = /obj/item/projectile/energy/laser/lesser),
		list(mode_name = "2-round bursts", fire_delay = 2, charge_cost = 20, burst = 2, projectile_type = /obj/item/projectile/energy/laser/lesser)
	)


/obj/item/cell/ammo/charge/accelerator
	name = "magazine cell (accelerator)"
	desc = "A power cell designed to be used as a magazine for charge-based weapons. This one allows the weapon to synthesize dense chunks of unstable particles and accelerate them, effectively shooting \"temporary\" bullets."
	icon_state = "charge_phazer"

	barrel_overlay = "phazer"
	firemodes = list(
		list(mode_name = "semiauto",       fire_delay = 2, charge_cost = 20, burst = 1, projectile_type = /obj/item/projectile/bullet/charge),
		list(mode_name = "2-round bursts", fire_delay = 2, charge_cost = 20, burst = 2, projectile_type = /obj/item/projectile/bullet/charge)
	)

#undef BARREL_TIMER
