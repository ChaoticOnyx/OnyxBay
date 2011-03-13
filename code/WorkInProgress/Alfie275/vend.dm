/obj/machinery/vendingm
	name = "Vendomat"
	desc = "A generic vending machine."
	icon = 'vending.dmi'
	icon_state = "generic"
	anchored = 1
	density = 1
	var/active = 1 //No sales pitches if off!
	var/vend_ready = 1 //Are we ready to vend?? Is it time??
	var/vend_delay = 10 //How long does it take to vend?
	var/balance = 3
	var/currency = "Space Cash"
	var/obj/item/weapon/money/profits
	var/list/prices = new()
	var/list/stock = new()
	var/list/products = new()
	req_access = list(15)
	var/icon_vend //Icon_state when vending!
	var/icon_deny //Icon_state when vending!
	var/emagged = 0
	var/locked = 1
	var/seconds_electrified = 0 //Shock customers like an airlock.
	var/shoot_inventory = 0 //Fire items at customers! We're broken!
	var/extended_inventory = 0 //can we access the hidden inventory?
	var/panel_open = 0 //Hacking that vending machine. Gonna get a free candy bar.
	var/wires = 15
	var/charge_type = ""

/obj/machinery/vendingm/proc/UpdateProducts()
	stock = new()
	products = new()
	for(var/obj/o in contents)
		stock["[o.type]"] +=1
		if(!products["[o.type]"])
			products["[o.type]"] = o.name

/obj/machinery/vendingm/proc/Restock()

/obj/machinery/vendingm/proc/SetPrice()

/obj/machinery/vendingm/New()
	profits = new(null,0,currency)
	SetPrice()
	Restock()
	UpdateProducts()





/obj/machinery/vendingm/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/emag))
		src.emagged = 1
		user << "You short out the [src]"
		return
	else if(istype(W, /obj/item/weapon/card/id))
		if(check_access(W))
			if(locked)
				locked = 0
				user << "You unlock the [src.name]"
			else
				user << "You lock the [src.name]"
				locked = 1

	else if (istype(W,/obj/item/weapon/vending_charge/))
		DoCharge(W,user)
			//points += W.charge_amt
			//del(W)
	else if (istype(W,/obj/item/weapon/money))
		if(currency==W:currency)
			user<<"You insert the [W.name] into the money slot."
			balance+=W:value
			profits.value += W:value
			user.drop_item()
			del W
		else
			user << "The [src] rejects your money."
			state("\red ERROR: WRONG CURRENCY")
	else
		if(locked)
			..()
		else
			user << "You place the [W.name] into the vending machine."
			user.drop_item()
			W.loc = src;
			UpdateProducts()





/obj/machinery/vendingm/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vendingm/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vendingm/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return
	user.machine = src



	var/dat = "<TT><b>Select an item:</b></TT><br>"

	if (src.products.len == 0)
		dat += "<font color = 'red'>No product loaded!</font>"
	else


		dat += "<TABLE width=100%><TR><TD><TT><B>Product:</B></TT></TD> <TD><TT><B>Cost:</B></TT></TD><TD><TT><B>Stock:</B></TT></TD><TD></TD></TR>"

		for (var/V in products)
			dat += "<TR><TD><TT><FONT color = 'blue'><B>[products[V]]</B></TT></TD>"
			dat += " <TD><TT>[prices[V]]</TT></TD><TD><TT><B>[stock[V]]</B></TT></TD> </font>"
			if (prices["[V]"] <= balance)
				dat += "<TD><TT><a href='byond://?src=\ref[src];vend=[V]'>Vend</A></TT></TD></TR>"
			else
				dat += "<TD><TT><font color = 'red'>NOT ENOUGH BALANCE</font></TD></TT></TR>"
			//dat += "<br>"

	dat += "</TABLE><br><TT><b>Balance: [balance]</b><br></TT>"
	dat += "</TABLE><br><TT><a href='byond://?src=\ref[src];refund=1'>Refund</A><br></TT>"
	if(!locked)
		dat += "</TABLE><br><TT><a href='byond://?src=\ref[src];maintenance=1'>Maintenance	</A><br></TT>"
	user << browse(dat, "window=vending")
	onclose(user, "vending")
	return

/obj/machinery/vendingm/Topic(href, href_list)
	if(stat & (BROKEN|NOPOWER))
		return
	if(usr.stat || usr.restrained())
		return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		if ((href_list["vend"]) && (src.vend_ready))



			src.vend_ready = 0 //One thing at a time!!

			var/path = href_list["vend"]
			var/product_path = text2path(path)
			var/obj/o
			var/found = 0
			for(var/obj/p in contents)
				if(!found)
					if(p.type == product_path)
						o = p
						found = 1
			if(!found)
				return

			o.loc = src.loc
			UpdateProducts()
			balance-=prices["[path]"]



			use_power(5)
			if (src.icon_vend) //Show the vending animation if needed
				flick(src.icon_vend,src)
				src.vend_ready = 1
				for (var/mob/M in viewers(1, src.loc))
					if (M.client && M.machine == src)
						src.attack_hand(M)
				return

			src.updateUsrDialog()
			for (var/mob/M in viewers(1, src.loc))
				if (M.client && M.machine == src)
					src.attack_hand(M)
			return

		else if (href_list["refund"])
			if(profits.value<balance)
				state("\red ERROR: Cannot refund full amount, refunding as much as possible")
				var/ramt = profits.value
				if(!ramt)
					return
				profits.value-=ramt
				balance-=ramt
				new/obj/item/weapon/money(loc,ramt,"Space Cash")
			else
				new/obj/item/weapon/money(loc,balance,"Space Cash")
			for (var/mob/M in viewers(1, src.loc))
				if (M.client && M.machine == src)
					src.attack_hand(M)

		else if (href_list["maintenance"])
			var/dat
			dat	+= "Balance: [balance]"
			dat += "<br>Profits: [profits.value]"
			dat += "<br><TT><a href='byond://?src=\ref[src];empty=1'>Empty</A><br></TT>"
			dat += "<br><TT><a href='byond://?src=\ref[src];profit=1'>Collect profits</A><br></TT>"
			dat += "<br><TT><a href='byond://?src=\ref[src];prices=1'>Set prices</A><br></TT>"
			dat += "<br><TT><a href='byond://?src=\ref[src];balance=1'>Set Balance</A><br></TT>"
			usr << browse(dat, "window=vending")

		else if (href_list["prices"])
			var/dat
			dat += "<TABLE><TR><TD>Item</TD><TD>Price</TD></TR>"
			for(var/V in prices)
				var/obj/o = new V
				dat += "<br><TR><TD>[o.name]</TD><TD>[prices[V]]</TD><TD><a href='byond://?src=\ref[src];price=[V]'>Set Price</A></TD></TR>"
			dat += "</TABLE><br><TT><a href='byond://?src=\ref[src];maintenance=1'>Back</A><br></TT>"
			usr << browse(dat, "window=vending")

		else if (href_list["price"])
			var/V = href_list["price"]
			var/newp = input("Enter new price:" ) as num
			prices[V] = newp

		else if (href_list["balance"])
			var/newb = input("Enter new balance:" ) as num
			balance = newb

		else if (href_list["profit"])
			new/obj/item/weapon/money(loc,profits.value,profits.currency)
			profits.value = 0

		else if (href_list["empty"])
			for(var/obj/o in contents)
				o.loc = loc
			UpdateProducts()

		src.add_fingerprint(usr)
		src.updateUsrDialog()

	else
		usr << browse(null, "window=vending")
		return
	return




/obj/machinery/vendingm/proc/DoCharge(obj/item/weapon/vending_charge/V as obj, mob/user as mob)
	if(charge_type == V.charge_type)
		Restock()
		UpdateProducts()
		del(V)
		user << "You restock the machine."

/obj/machinery/vendingm/drink
	name = "Drinks Machine"
	desc = "A drink vending machine."
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	vend_delay = 34
	charge_type = "coffee"


/obj/machinery/vendingm/drink/SetPrice()
	prices["/obj/item/weapon/reagent_containers/food/drinks/coffee"] = 0.5
	prices["/obj/item/weapon/reagent_containers/food/drinks/cola"] = 0.4

/obj/machinery/vendingm/drink/Restock()
	contents+=new/obj/item/weapon/reagent_containers/food/drinks/coffee()
	contents+=new/obj/item/weapon/reagent_containers/food/drinks/coffee()
	contents+=new/obj/item/weapon/reagent_containers/food/drinks/coffee()
	contents+=new/obj/item/weapon/reagent_containers/food/drinks/coffee()
	contents+=new/obj/item/weapon/reagent_containers/food/drinks/coffee()
	contents+=new/obj/item/weapon/reagent_containers/food/drinks/coffee()

	contents+=new/obj/item/weapon/reagent_containers/food/drinks/cola()
	contents+=new/obj/item/weapon/reagent_containers/food/drinks/cola()
	contents+=new/obj/item/weapon/reagent_containers/food/drinks/cola()
	contents+=new/obj/item/weapon/reagent_containers/food/drinks/cola()
	contents+=new/obj/item/weapon/reagent_containers/food/drinks/cola()
	contents+=new/obj/item/weapon/reagent_containers/food/drinks/cola()


/obj/machinery/vendingm/snack
	name = "Snack Machine"
	desc = "All manner of tasty, but unhealthy snacks"
	icon_state = "snack"
	charge_type = "snack"

/obj/machinery/vendingm/snack/SetPrice()
	prices["/obj/item/weapon/reagent_containers/food/snacks/donut"] = 0.5

/obj/machinery/vendingm/snack/Restock()
	contents+=new/obj/item/weapon/reagent_containers/food/snacks/donut()
	contents+=new/obj/item/weapon/reagent_containers/food/snacks/donut()
	contents+=new/obj/item/weapon/reagent_containers/food/snacks/donut()
	contents+=new/obj/item/weapon/reagent_containers/food/snacks/donut()
	contents+=new/obj/item/weapon/reagent_containers/food/snacks/donut()
	contents+=new/obj/item/weapon/reagent_containers/food/snacks/donut()
	contents+=new/obj/item/weapon/reagent_containers/food/snacks/donut()
	contents+=new/obj/item/weapon/reagent_containers/food/snacks/donut()
	contents+=new/obj/item/weapon/reagent_containers/food/snacks/donut()
	contents+=new/obj/item/weapon/reagent_containers/food/snacks/donut()



/obj/machinery/vendingm/cigarette
	name = "Cigarette Vendor"
	desc = "If you want to get cancer, might as well do it in style"
	icon_state = "cigs"
	charge_type = "cigarette"

/obj/machinery/vendingm/cigarette/SetPrice()
	prices["/obj/item/weapon/cigpacket"] = 0.5
	prices["/obj/item/weapon/zippo/lighter"] = 1
	prices["/obj/item/weapon/zippo"] = 2

/obj/machinery/vendingm/cigarette/Restock()
	contents+=new/obj/item/weapon/cigpacket()
	contents+=new/obj/item/weapon/cigpacket()
	contents+=new/obj/item/weapon/cigpacket()
	contents+=new/obj/item/weapon/cigpacket()
	contents+=new/obj/item/weapon/cigpacket()

/*
/obj/machinery/vending/cigarette/New()
	spawn(1)
		new/obj/machinery/vendingm/cigarette(loc)
		del src

/obj/machinery/vending/snack/New()
	spawn(1)
		new/obj/machinery/vendingm/snack(loc)
		del src

/obj/machinery/vending/coffee/New()
	spawn(1)
		new/obj/machinery/vendingm/drink(loc)
		del src*/


/obj/machinery/vendingm/prize
	name = "Prizes"
	desc = "Spend your tickets here!"
	charge_type = ""
	currency = "Tickets"
	balance = 0

/obj/machinery/vendingm/prize/New()
	..()
	profits = new/obj/item/weapon/money/tickets(null,0,"Tickets")

/obj/machinery/vendingm/prize/SetPrice()
	prices["/obj/item/device/radio/beacon"] = 10
	prices["/obj/item/weapon/c_tube"] = 50

/obj/machinery/vendingm/prize/Restock()
	var/count = 5
	while(count)
		var/obj/item/device/radio/beacon/b = new()
		b.name = "Blinky light toy"
		b.desc = "It blinks!!!"
		contents+=b;
		count--;
	count = 3
	while(count)
		var/obj/prize = new /obj/item/weapon/c_tube(src.loc)
		prize.name = "toy sword"
		prize.icon = 'weapons.dmi'
		prize.icon_state = "sword1"
		prize.desc = "A sword made of cheap plastic."
		contents+=prize
		count--;

