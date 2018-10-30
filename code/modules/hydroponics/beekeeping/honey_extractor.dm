/obj/machinery/honey_extractor
	name = "honey extractor"
	desc = "A machine used to extract honey and wax from a beehive frame."
	icon = 'icons/obj/virology.dmi'
	icon_state = "centrifuge"
	anchored = 1
	density = 1

	var/processing = 0
	var/honey = 0
	var/a_honey = 0
	var/time = 100

	var/open = FALSE
	component_types = list(
		/obj/item/weapon/circuitboard/honey_extractor,
		/obj/item/weapon/stock_parts/manipulator = 3
	)

/obj/machinery/honey_extractor/attackby(var/obj/item/I, var/mob/user)
	if(processing)
		to_chat(user, "<span class='notice'>\The [src] is currently spinning, wait until it's finished.</span>")
		return
	else if(istype(I, /obj/item/honey_frame))
		if(open)
			to_chat(user, "<span class='notice'>\The [src] is currently open.</span>")
			return
		var/obj/item/honey_frame/H = I
		if(!H.honey)
			to_chat(user, "<span class='notice'>\The [H] is empty, put it into a beehive.</span>")
			return
		user.visible_message("<span class='notice'>\The [user] loads \the [H] into \the [src] and turns it on.</span>", "<span class='notice'>You load \the [H] into \the [src] and turn it on.</span>")
		processing = H.honey
		icon_state = "centrifuge_moving"
		qdel(H)
		spawn(time)
			new /obj/item/honey_frame(loc)
			new /obj/item/stack/wax(loc)
			honey += processing + a_honey
			processing = 0
			icon_state = "centrifuge"
	else if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(open)
			to_chat(user, "<span class='notice'>\The [src] is currently open.</span>")
			return
		if(!honey)
			to_chat(user, "<span class='notice'>There is no honey in \the [src].</span>")
			return
		var/obj/item/weapon/reagent_containers/glass/G = I
		var/transferred = min(G.reagents.maximum_volume - G.reagents.total_volume, honey)
		G.reagents.add_reagent(/datum/reagent/nutriment/honey, transferred)
		honey -= transferred
		user.visible_message("<span class='notice'>\The [user] collects honey from \the [src] into \the [G].</span>", "<span class='notice'>You collect [transferred] units of honey from \the [src] into \the [G].</span>")
		return 1
	else if((isScrewdriver(I) || isCrowbar(I) || isWrench(I)))
		if(default_deconstruction_screwdriver(user, I))
			open = !open
			return
		if(default_deconstruction_crowbar(user, I))
			return
		if(isWrench(I))
			anchored = !anchored
			to_chat(user, "You [anchored ? "attached" : "detached"] the honey extractor.")
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
		if(default_part_replacement(user, I))
			return

/obj/machinery/honey_extractor/RefreshParts()
	..()
	var/man_rating = 0
	for(var/obj/item/weapon/stock_parts/P in component_parts)
		if(ismanipulator(P))
			man_rating += P.rating
			time -= 2 * man_rating
			a_honey = 0.1 * man_rating