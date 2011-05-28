/////////////////IM SORRY FOR THIS CODE \\\\\\\\\\\\\\\\\\\
//////////////REALLY SORRY \\\\\\\\\\\\\\\\

// We forgive you, sir


// Custom foods (?)

/obj/item/weapon/reagent_containers/food/custom/breadsys/bread
	name = "bread"
	icon = 'food2.dmi'
	icon_state = "bread3"
	var/amount = 3
	var/stateontop = "bread"

/obj/item/weapon/reagent_containers/food/custom/breadsys/butterpack
	name = "Butter"
	icon = 'food2.dmi'
	icon_state = "butterpack"

/obj/item/weapon/reagent_containers/food/custom/breadsys/loaf
	name = "loaf of bread"
	icon = 'food2.dmi'
	icon_state = "loaf3"
	var/amount = 6

/obj/item/weapon/reagent_containers/food/custom/breadsys/ontop
	icon = 'food2.dmi'
	var/stateontop = "sals" //state when ontop a sandvich

/obj/item/weapon/reagent_containers/food/custom/breadsys/ontop/salami
	name = "salami"
	icon_state = "sal"
	stateontop = "sals"

/obj/item/weapon/reagent_containers/food/custom/breadsys/ontop/butter
	name = "butter"
	icon_state = "butter"
	stateontop = "butter"

obj/closet/sandvich
	name = "Food Supply Closet"
obj/closet/sandvich/New()
	new /obj/item/weapon/reagent_containers/food/custom/breadsys/ontop/salami(src)
	new /obj/item/weapon/reagent_containers/food/custom/breadsys/ontop/salami(src)
	new /obj/item/weapon/reagent_containers/food/custom/breadsys/ontop/salami(src)
	new /obj/item/weapon/reagent_containers/food/custom/breadsys/ontop/salami(src)
	new /obj/item/weapon/reagent_containers/food/custom/breadsys/ontop/salami(src)
	new /obj/item/weapon/reagent_containers/food/custom/breadsys/ontop/salami(src)
	new /obj/item/weapon/reagent_containers/food/custom/breadsys/ontop/salami(src)
	new /obj/item/weapon/reagent_containers/food/custom/breadsys/ontop/salami(src)
	new /obj/item/weapon/reagent_containers/food/custom/breadsys/butterpack(src)
	new /obj/item/weapon/reagent_containers/food/custom/breadsys/butterpack(src)


// Loaf code
/obj/item/weapon/reagent_containers/food/custom/breadsys/loaf/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		new /obj/item/weapon/reagent_containers/food/custom/breadsys/bread(src.loc)
		user << "You slice a piece of bread"
		amount--
		if(amount <= 4)
			icon_state = "loaf2"
		if(amount <= 2)
			icon_state = "loaf1"
		if(amount < 1)
			del(src)


// Butterpack code
/obj/item/weapon/reagent_containers/food/custom/breadsys/butterpack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		W:butter = 1
		user << "You put some butter on \the [W]"
	else
		..()


// Bread code
/obj/item/weapon/reagent_containers/food/custom/breadsys/bread/attack(mob/M as mob, mob/user as mob)
	if(M == user)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red [] takes a bite off []", user, src), 1)
		src.amount--
		if(src.amount <= 0)
			for(var/mob/X in viewers(M, null))
				X.show_message(text(" [] finishes eating []", user, src), 1)
				del src
		updateicon()
		return

	else
		for(var/mob/S in viewers(M, null))
			S.show_message(text("\red [] is forcing [] to take a bite of []", user, M, src), 1)
		src.amount--
		if(src.amount == 0)
			for(var/mob/V in viewers(M, null))
				V.show_message(text("[] finishes eating []", user, src), 1)
			del src
		updateicon()
		return


/obj/item/weapon/reagent_containers/food/custom/breadsys/bread/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/custom/breadsys/ontop))
		var/state = W:stateontop
		if(!state)
			return
		if(src.name != "sandwich")
			src.name = "sandwich"
		overlays += image(W.icon,icon_state = state)
		user.drop_item(W)
		W.loc = src
		user << "You put a [W] ontop of the [src]"
	else if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		if(!W:butter)
			user << "You need butter..."
		if(src.name != "sandwich")
			src.name = "sandwich"
		var/obj/item/weapon/reagent_containers/food/custom/breadsys/ontop/butter/X = new(src)
		src.overlays += image(X.icon,icon_state = X.stateontop)
		W:butter = 0
		user << "You put some [X] ontop of the [src]"
	else if(W.type == /obj/item/weapon/reagent_containers/food/custom/breadsys/bread/)
		user.drop_item(W)
		W.loc = src
		if(src.name != "sandwich")
			src.name = "sandwich"
		overlays += image(W.icon,icon_state = W.icon_state)
		user << "You put [W] ontop of the [src]"
	updateicon()


/obj/item/weapon/reagent_containers/food/custom/breadsys/bread/proc/updateicon()
	src.overlays = null
	var/num = amount
	for(var/obj/item/weapon/reagent_containers/food/custom/breadsys/ontop/X in src)
		var/iconx = "[X.stateontop][num]"
		overlays += image(X.icon,iconx)