/obj/machinery/factory/canning
	name = "Canning machine"
	desc = "It's some factory machine that does canning grown food"

	accepting_types = list(
		/obj/item/reagent_containers/food/grown
	)

/obj/machinery/factory/canning/process_item(obj/item/reagent_containers/food/grown/current_atom)
	if(isnull(current_atom))
		current_atom = items_inside[length(items_inside)]
	if(!istype(current_atom))
		return
	. = ..()
	if(.)
		var/obj/item/reagent_containers/food/packaged/tin/eject_atom = new(loc)
		eject_atom.name = "Can of \the [initial(current_atom.name)]"
		eject_atom.bitesize += round(current_atom.reagents.total_volume / 2, 1)
		current_atom.reagents.trans_to(eject_atom.reagents, current_atom.reagents.total_volume)
		return eject_product(eject_atom)
