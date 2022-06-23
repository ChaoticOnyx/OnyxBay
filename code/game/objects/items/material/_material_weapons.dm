// SEE code/modules/materials/materials.dm FOR DETAILS ON INHERITED DATUM.
// This class of weapons takes force and appearance data from a material datum.
// They are also fragile based on material data and many can break/smash apart.
/obj/item/material
	icon = 'icons/obj/weapons.dmi'
	health = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	gender = NEUTER
	throw_range = 7
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.0
	mod_reach = 1.0
	mod_handy = 1.0
	sharp = 0
	edge = 0

	var/applies_material_colour = 1
	var/unbreakable
	var/force_const = 0 //Flat damage
	var/thrown_force_const = 0 //Throw flat damage
	var/force_divisor = 0.5 //Depends on hardness
	var/thrown_force_divisor = 0.5 //Depends on weight
	var/default_material = MATERIAL_STEEL
	var/material/material
	var/material_amount = 1 // Number of material sheets contained in the item. Doesn't have to exactly match the amount of material spent for crafting as some may be lost during welding/carving.
	var/drops_debris = 1
	var/m_overlay = 0

/obj/item/material/New(newloc, material_key)
	..(newloc)
	if(!material_key)
		material_key = default_material
	set_material(material_key)
	if(!material)
		qdel(src)
		return

	matter = material.get_matter()
	if(matter.len)
		for(var/material_type in matter)
			if(!isnull(matter[material_type]))
				matter[material_type] *= force_divisor // May require a new var instead.

/obj/item/material/get_material()
	return material

/obj/item/material/proc/update_force()
	if(edge || sharp)
		force = material.get_edge_damage()
	else
		force = material.get_blunt_damage()
	force = force_const + round(force*force_divisor, 0.1)
	throwforce = thrown_force_const + round(material.get_blunt_damage()*thrown_force_divisor, 0.1)
	//spawn(1)
//		log_debug("[src] has force [force] and throwforce [throwforce] when made from default material [material.name]")


/obj/item/material/proc/set_material(new_material)
	material = get_material_by_name(new_material)
	if(!material)
		qdel(src)
	else
		SetName("[material.display_name] [initial(name)]")
		health = round(material.integrity/10)
		if(applies_material_colour)
			if(m_overlay)
				var/icon/mat_overlay = new /icon("icon" = 'icons/obj/weapons.dmi', "icon_state" = "[src.icon_state]_overlay")
				mat_overlay.Blend(material.icon_colour, ICON_ADD)
				overlays += mat_overlay
				//mob_icon.Blend(mat_overlay, ICON_OVERLAY)
			else
				color = material.icon_colour
		if(material.products_need_process())
			START_PROCESSING(SSobj, src)
		if(material.conductive)
			obj_flags |= OBJ_FLAG_CONDUCTIBLE
		else
			obj_flags &= (~OBJ_FLAG_CONDUCTIBLE)
		if(material.reagent_path)
			create_reagents(material_amount * REAGENTS_PER_MATERIAL_SHEET)
			reagents.add_reagent(material.reagent_path, material_amount * REAGENTS_PER_MATERIAL_SHEET)
		update_force()

/obj/item/material/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/material/apply_hit_effect()
	. = ..()
	if(!unbreakable)
		if(!prob(material.hardness))
			if(material.is_brittle())
				health = 0
			else
				health--
		check_health()

/obj/item/material/proc/check_health(consumed)
	if(health<=0)
		shatter(consumed)

/obj/item/material/proc/shatter(consumed)
	var/turf/T = get_turf(src)
	T.visible_message("<span class='danger'>\The [src] [material.destruction_desc]!</span>")
	if(istype(loc, /mob/living))
		var/mob/living/M = loc
		M.drop_from_inventory(src)
	playsound(src, SFX_BREAK_WINDOW, 70, 1)
	if(!consumed && drops_debris) material.place_shard(T)
	qdel(src)
/*
Commenting this out pending rebalancing of radiation based on small objects.
/obj/item/material/process()
	if(!material.radioactivity)
		return
	for(var/mob/living/L in range(1,src))
		L.apply_effect(round(material.radioactivity/30),IRRADIATE, blocked = L.getarmor(null, "rad"))
*/

/*
// Commenting this out while fires are so spectacularly lethal, as I can't seem to get this balanced appropriately.
/obj/item/material/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	TemperatureAct(exposed_temperature)

// This might need adjustment. Will work that out later.
/obj/item/material/proc/TemperatureAct(temperature)
	health -= material.combustion_effect(get_turf(src), temperature, 0.1)
	check_health(1)

/obj/item/material/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W
		if(material.ignition_point && WT.remove_fuel(0, user))
			TemperatureAct(150)
	else
		return ..()
*/
