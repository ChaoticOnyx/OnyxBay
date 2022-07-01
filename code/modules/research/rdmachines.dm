//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.

var/list/default_material_composition = list(MATERIAL_STEEL = 0, MATERIAL_GLASS = 0, MATERIAL_GOLD = 0, MATERIAL_SILVER = 0, MATERIAL_PLASMA = 0, MATERIAL_URANIUM = 0, MATERIAL_DIAMOND = 0)
/obj/machinery/r_n_d
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = 1
	anchored = 1
	var/busy = 0
	var/obj/machinery/computer/rdconsole/linked_console

	var/list/materials = list()

/obj/machinery/r_n_d/attack_hand(mob/user as mob)
	return

/obj/machinery/r_n_d/dismantle()
	for(var/obj/I in component_parts)
		if(istype(I, /obj/item/reagent_containers/vessel/beaker))
			reagents.trans_to_obj(I, reagents.total_volume)
	for(var/f in materials)
		if(materials[f] >= SHEET_MATERIAL_AMOUNT)
			var/material/M = get_material_by_name(f)
			if(M?.stack_type)
				var/obj/item/stack/S = M.place_sheet(loc)
				S.amount = round(materials[f] / SHEET_MATERIAL_AMOUNT)
	..()


/obj/machinery/r_n_d/proc/eject(material, amount)
	if(!(material in materials))
		return
	var/material/mat = get_material_by_name(material)
	var/obj/item/stack/material/sheetType = mat.stack_type
	var/perUnit = initial(sheetType.perunit)
	var/eject = round(materials[material] / perUnit)
	eject = amount == -1 ? eject : min(eject, amount)
	if(eject < 1)
		return
	new sheetType(loc, eject)
	materials[material] -= eject * perUnit

/obj/machinery/r_n_d/proc/TotalMaterials()
	for(var/f in materials)
		. += materials[f]

/obj/machinery/r_n_d/proc/getLackingMaterials(datum/design/D)
	var/list/ret = list()
	for(var/M in D.materials)
		if(materials[M] < D.materials[M])
			ret += "[D.materials[M] - materials[M]] [M]"
	for(var/C in D.chemicals)
		if(!reagents.has_reagent(C, D.chemicals[C]))
			var/datum/reagent/R = C
			ret += lowertext(initial(R.name))
	return english_list(ret)
