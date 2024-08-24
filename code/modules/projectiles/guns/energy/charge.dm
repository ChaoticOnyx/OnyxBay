
/obj/item/gun/charge
	name = "charge carbine"
	desc = "C-13 Charge Carbine, NanoTrasen's flagship all-purpose weapon. Even though it's rather cheap and somewhat unwieldy, it can use a wide range of energy-based ammunition."
	icon_state = "charge_rifle-preview"
	item_state = "erifle"
	modifystate = "charge_rifle"
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

	var/obj/item/cell/ammo/charge/power_supply
	var/projectile_type = /obj/item/projectile/energy/electrode/stunsphere
	var/cell_type = /obj/item/cell/ammo/charge/stun // What we start with


/obj/item/gun/charge/Initialize()
	. = ..()
	if(cell_type)
		power_supply = new cell_type(src)
	update_mode()

/obj/item/gun/charge/Destroy()
	QDEL_NULL(power_supply)
	return ..()

/obj/item/gun/charge/attackby(obj/item/A, mob/user)
	if(istype(A, obj/item/cell/ammo/charge))
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


/obj/item/gun/charge/proc/load_cell(obj/item/cell/ammo/charge/A, atom/movable/loader)
	if(power_supply)
		to_chat(loader, SPAN("warning", "\The [src] already has a magazine cell loaded."))
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

	playsound(loc, mag_insert_sound, rand(45, 60), FALSE)
	update_mode()

/obj/item/gun/charge/proc/unload_cell(atom/movable/unloader, allow_dump = TRUE, dump_loc = null)
	if(!power_supply)
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

	playsound(src.loc, mag_eject_sound, 50, 1)
	power_supply.update_icon()
	power_supply = null
	update_mode()

/obj/item/gun/charge/proc/update_mode(update_icons = TRUE)
	ClearOverlays()
	if(!power_supply)
		icon_state = "[modifystate]-empty"


/obj/item/cell/ammo/charge
	name = "magazine cell"
	desc = "A power cell designed to be used as a magazine for charge-based weapons. This one must not be seen at all."
	icon = 'icons/obj/ammo.dmi'
	item_state = "cell"
	icon_state = "charge"
	maxcharge = 160

	var/modifystate = ""
	var/projectile_type
	var/firemodes = list(
		list(mode_name = "semiauto",       fire_delay = null, charge_cost = 20, burst = 2),
		list(mode_name = "2-round bursts", fire_delay = 2,    charge_cost = 40, burst = 1)
	)

/obj/item/cell/ammo/charge/stun
	name = "magazine cell (stun)"
	desc = "A power cell designed to be used as a magazine for charge-based weapons. This one turns the weapon into a non-lethal taser rifle."
	icon_state = "charge_stun"

	modifystate = "stun"
	projectile_type = /obj/item/projectile/energy/electrode/lesser

/obj/item/cell/ammo/charge/blaster
	name = "magazine cell (blaster)"
	desc = "A power cell designed to be used as a magazine for charge-based weapons. This one allows the weapon to shoot concentrated blasts of energy. While the blasts deal more damage than lasers, they are not as good at penetrating armor."
	icon_state = "charge_blaster"

	modifystate = "blaster"
	projectile_type = /obj/item/projectile/energy/electrode/lesser


/obj/item/cell/ammo/charge/accelerator
	name = "magazine cell (accelerator)"
	desc = "A power cell designed to be used as a magazine for charge-based weapons. This one allows the weapon to synthesize dense chunks of unstable particles and accelerate them, effectively shooting \"temporary\" bullets."
	icon_state = "charge_phazer"

	modifystate = "phazer"
	projectile_type = /obj/item/projectile/energy/electrode/lesser
