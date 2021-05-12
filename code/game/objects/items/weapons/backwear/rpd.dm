
/obj/item/weapon/backwear/powered/rpd
	name = "rapid piping pack"
	desc = "A heavy and bulky backpack-shaped device. It can be used to quickly set up or dismantle pipelines using nothing but electrical power."
	icon_state = "pipe1"
	base_icon = "pipe"
	item_state = "backwear_rpd"
	hitsound = 'sound/effects/fighting/smash.ogg'
	gear_detachable = FALSE
	gear = /obj/item/weapon/rpd
	bcell = null
	atom_flags = null
	origin_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 2)
	matter = list(MATERIAL_STEEL = 1500, MATERIAL_GLASS = 500)

/obj/item/weapon/backwear/powered/rpd/loaded
	bcell = /obj/item/weapon/cell/standard

#define RPD_DISPENSE "dispense"
#define RPD_WRENCH   "wrench"
#define RPD_RECYCLE  "recycle"

/obj/item/weapon/rpd
	name = "rapid piping device"
	desc = "A device used to rapidly pipe things."
	icon = 'icons/obj/backwear.dmi'
	icon_state = "rpd_dispense"
	item_state = "rpd"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.0
	mod_reach = 0.75
	mod_handy = 1.0
	canremove = 0
	unacidable = 1 //TODO: make these replaceable so we won't need such ducttaping
	origin_tech = null
	matter = null

	var/obj/item/weapon/backwear/powered/base_unit
	var/interaction_mode = RPD_DISPENSE
	var/mode = 1
	var/inuse = 0
	var/list/datum/item_types = list()
	var/datum/dispense_type/selected = null // Using robot_item_dispenser's datums cuz they work perfectly
	var/activate_sound = 'sound/items/polaroid3.ogg'
	var/recycling_time = 30

/obj/item/weapon/rpd/examine(mob/user)
	. = ..()
	. += "\n[selected.name] is chosen to be produced."

/obj/item/weapon/rpd/New(newloc, obj/item/weapon/backwear/base)
	selected = item_types[1]
	base_unit = base
	..(newloc)

/obj/item/weapon/rpd/update_icon()
	icon_state = "rpd_[interaction_mode]"

/obj/item/weapon/rpd/Destroy() //it shouldn't happen unless the base unit is destroyed but still
	if(base_unit)
		if(base_unit.gear == src)
			base_unit.gear = null
			base_unit.update_icon()
		base_unit = null
	return ..()

/obj/item/weapon/rpd/dropped(mob/user)
	..()
	if(base_unit)
		base_unit.reattach_gear(user)

/obj/item/weapon/rpd/attack_self(mob/user)
	var/t = ""
	for(var/i = 1 to item_types.len)
		if(t)
			t += ", "
		if(mode == i)
			t += "<b>[item_types[i]]</b>"
		else
			t += "<a href='?src=\ref[src];product_index=[i]'>[item_types[i]]</a>"
	t = "Available products: [t]."
	to_chat(user, t)

/obj/item/weapon/rpd/OnTopic(href, list/href_list)
	if(href_list["rpd_mode"])
		interaction_mode = href_list["rpd_mode"]
		to_chat(usr, "Changed RPD interaction mode to [interaction_mode].")
		update_icon()
		return TOPIC_REFRESH
	if(href_list["product_index"])
		var/index = text2num(href_list["product_index"])
		if(index > 0 && index <= item_types.len)
			playsound(loc, 'sound/effects/pop.ogg', 50, 0)
			mode = index
			selected = item_types[mode]
			to_chat(usr, "Changed dispensing mode to [selected.name].")
		return TOPIC_REFRESH

/obj/item/weapon/rpd/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return

	if(inuse)
		return

	if(!base_unit?.bcell)
		to_chat(user, SPAN("warning", "\The [base_unit] has no power source installed!"))
		return

	var/obj/item/weapon/cell/BC = base_unit.bcell

	if(interaction_mode == RPD_RECYCLE)
		for(var/datum/dispense_type/T in item_types)
			if(istype(A, T.item_type))
				inuse = 1
				user.visible_message(SPAN("notice", "[user] starts recycling \the [A]..."))
				if(do_after(user, recycling_time, src))
					to_chat(user, SPAN("notice", "\The [src] consumes [A] and you get some energy back."))
					qdel(A)
					BC.add_charge(T.energy / 2)
					inuse = 0
				else
					to_chat(user, SPAN("warning", "You failed to recycle \the [A]."))
					inuse = 0
				break

	if(interaction_mode == RPD_DISPENSE)
		if(BC.charge <= selected.energy)
			to_chat(user, SPAN("warning", "Not enough energy."))
			return

		if(!istype(A, /obj/structure/table) && !istype(A, /turf/simulated/floor))
			return

		if (!selected.item_type)
			return

		playsound(src.loc, activate_sound, 10, 1)
		to_chat(user, SPAN("notice", "Dispensing [selected.name]..."))
		inuse = 1
		if(do_after(user, selected.delay, src))
			inuse = 0
			var/obj/product = null
			if(selected.item_type == /obj/item/pipe)
				var/datum/dispense_type/pipe/PD = selected
				var/pipe_dir = 1
				if(PD.pipe_type == 1 || PD.pipe_type == 30 || PD.pipe_type == 32) //if it bend we need to change direction
					pipe_dir = 5
				var/obj/item/pipe/O = new (get_turf(A), PD.pipe_type, pipe_dir) //apparently you need to call New() if you want icon and name change
				O.update()
				product = O
			else if(selected.item_type == /obj/structure/disposalconstruct)
				var/datum/dispense_type/pipe/PD = selected
				var/obj/structure/disposalconstruct/O = product
				O.ptype = PD.pipe_type
				if(O.ptype == 6 || O.ptype == 7 || O.ptype == 8)
					O.set_density(1)
				O.update()

			user.visible_message(SPAN("notice", "[user]'s [src] spits out \the [selected.name]."))
			product.loc = get_turf(A)
			BC.use(selected.energy)
		else
			inuse = 0

/obj/item/weapon/rpd/New()	//Fuck the guy who coded pipes
	item_types += new /datum/dispense_type/pipe("pipe", /obj/item/pipe, 0, 25, 50)
	item_types += new /datum/dispense_type/pipe("bent pipe", /obj/item/pipe, 1, 25, 50)
	item_types += new /datum/dispense_type/pipe("manifold", /obj/item/pipe, 5, 35, 75)
	item_types += new /datum/dispense_type/pipe("4-way manifold", /obj/item/pipe, 19, 35, 75)
	item_types += new /datum/dispense_type/pipe("pipe cap", /obj/item/pipe, 20, 25, 50)

	item_types += new /datum/dispense_type/pipe("pipe", /obj/item/pipe, 29, 25, 50)
	item_types += new /datum/dispense_type/pipe("bent pipe", /obj/item/pipe, 30, 25, 50)
	item_types += new /datum/dispense_type/pipe("manifold", /obj/item/pipe, 33, 35, 75)
	item_types += new /datum/dispense_type/pipe("4-way manifold", /obj/item/pipe, 35, 35, 75)
	item_types += new /datum/dispense_type/pipe("pipe cap", /obj/item/pipe, 40, 25, 50)

	item_types += new /datum/dispense_type/pipe("pipe", /obj/item/pipe, 31, 25, 50)
	item_types += new /datum/dispense_type/pipe("bent pipe", /obj/item/pipe, 32, 25, 50)
	item_types += new /datum/dispense_type/pipe("manifold", /obj/item/pipe, 34, 35, 75)
	item_types += new /datum/dispense_type/pipe("4-way manifold", /obj/item/pipe, 36, 35, 75)
	item_types += new /datum/dispense_type/pipe("pipe cap", /obj/item/pipe, 42, 25, 50)

	item_types += new /datum/dispense_type("pipe pressure meter", /obj/item/pipe_meter, 40, 125)
	item_types += new /datum/dispense_type/pipe("vent pump", /obj/item/pipe, 7, 25, 50)
	item_types += new /datum/dispense_type/pipe("scrubber pump", /obj/item/pipe, 11, 25, 50)
	item_types += new /datum/dispense_type/pipe("pump", /obj/item/pipe, 10, 35, 75)
	item_types += new /datum/dispense_type/pipe("universal pipe adapter", /obj/item/pipe, 28, 35, 75)
	item_types += new /datum/dispense_type/pipe("shutoff valve", /obj/item/pipe, 44, 35, 75)
	item_types += new /datum/dispense_type/pipe("connector", /obj/item/pipe, 4, 35, 75)

	item_types += new /datum/dispense_type/pipe("pipe", /obj/structure/disposalconstruct, 0, 40, 200)
	item_types += new /datum/dispense_type/pipe("bent pipe", /obj/structure/disposalconstruct, 1, 40, 200)
	item_types += new /datum/dispense_type/pipe("junction", /obj/structure/disposalconstruct, 2, 40, 200)
	item_types += new /datum/dispense_type/pipe("Y junction", /obj/structure/disposalconstruct, 4, 40, 200)
	item_types += new /datum/dispense_type/pipe("trunk", /obj/structure/disposalconstruct, 5, 40, 200)
	item_types += new /datum/dispense_type/pipe("bin", /obj/structure/disposalconstruct, 6, 60, 300)
	item_types += new /datum/dispense_type/pipe("outlet", /obj/structure/disposalconstruct, 7, 60, 300)
	item_types += new /datum/dispense_type/pipe("chute", /obj/structure/disposalconstruct, 8, 60, 300)
	..()

/obj/item/weapon/rpd/attack_self(mob/user)
	var/t = "RPD Mode: "
	t += "<a href='?src=\ref[src];rpd_mode=[RPD_DISPENSE]'>[RPD_DISPENSE]</a>, "
	t += "<a href='?src=\ref[src];rpd_mode=[RPD_WRENCH]'>[RPD_WRENCH]</a>, "
	t += "<a href='?src=\ref[src];rpd_mode=[RPD_RECYCLE]'>[RPD_RECYCLE]</a>"
	to_chat(user, t)
	t = "Available products:\nRegular pipes: "
	for(var/i = 1 , i < 6, i++)
		if(i != 1)
			t += ", "
		if(mode == i)
			t += "<b>[item_types[i]]</b>"
		else
			t += "<a href='?src=\ref[src];product_index=[i]'>[item_types[i]]</a>"
	to_chat(user, t)
	t = "Supply pipes: "
	for(var/i = 6 , i < 11, i++)
		if(i != 6)
			t += ", "
		if(mode == i)
			t += "<b>[item_types[i]]</b>"
		else
			t += "<a href='?src=\ref[src];product_index=[i]'>[item_types[i]]</a>"
	to_chat(user, t)
	t = "Scrubber pipes: "
	for(var/i = 11 , i < 16, i++)
		if(i != 11)
			t += ", "
		if(mode == i)
			t += "<b>[item_types[i]]</b>"
		else
			t += "<a href='?src=\ref[src];product_index=[i]'>[item_types[i]]</a>"
	to_chat(user, t)
	t = "Pipe devices: "
	for(var/i = 16 , i < 23, i++)
		if(i != 16)
			t += ", "
		if(mode == i)
			t += "<b>[item_types[i]]</b>"
		else
			t += "<a href='?src=\ref[src];product_index=[i]'>[item_types[i]]</a>"
	to_chat(user, t)
	t = "Disposal Pipes and devices: "
	for(var/i = 23 , i < 31, i++)
		if(i != 23)
			t += ", "
		if(mode == i)
			t += "<b>[item_types[i]]</b>"
		else
			t += "<a href='?src=\ref[src];product_index=[i]'>[item_types[i]]</a>"
	to_chat(user, t)
