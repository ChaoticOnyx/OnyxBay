decl/hierarchy/sell_order/rnd/
    name = "RND Item"

decl/hierarchy/sell_order/rnd/add_item(var/atom/A)
	for(var/wanted_type in wanted)
		if(istype(A, wanted_type))
			wanted -= list(wanted_type)
			return 1 //selling successful
	..()

decl/hierarchy/sell_order/rnd/check_progress()
	progress = max_progress - length(wanted) //checking how many wanted items left and getting by that
	if(progress == max_progress) //if request complete - get reward
		reward()

decl/hierarchy/sell_order/rnd/New()
		max_progress = length(wanted)
		. = ..()
		return .

decl/hierarchy/sell_order/rnd/plasma_cutter
    name = "Plasma Cutters"
    description = "Our miners at planet LZF-462 need 3 Plasma Cutters for their work. Manufature them and send to us."
    wanted = list(/obj/item/weapon/gun/energy/plasmacutter,
                  /obj/item/weapon/gun/energy/plasmacutter,
                  /obj/item/weapon/gun/energy/plasmacutter)
    cost = 120

decl/hierarchy/sell_order/rnd/railgun
    name = "Railguns"
    description = "Some monsters are attacking our stations. We need experemental weapons against them."
    wanted = list(/obj/item/weapon/gun/magnetic/railgun,
                  /obj/item/weapon/gun/magnetic/railgun)
    cost = 80

decl/hierarchy/sell_order/rnd/laser_cannon
    name = "Laser Cannons"
    description = "Some monsters are attacking our stations. We need experemental weapons against them."
    wanted = list(/obj/item/weapon/gun/energy/lasercannon,
                  /obj/item/weapon/gun/energy/lasercannon)
    cost = 80