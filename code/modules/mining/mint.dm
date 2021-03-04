/**********************Mint**************************/


/obj/machinery/mineral/mint
	name = "Coin press"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "coinpress0"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/amt_silver = 0 //amount of silver
	var/amt_gold = 0   //amount of gold
	var/amt_diamond = 0
	var/amt_iron = 0
	var/amt_plasma = 0
	var/amt_uranium = 0
	var/newCoins = 0   //how many coins the machine made in it's last load
	var/processing = 0
	var/chosen //which material will be used to make coins
	var/coinsToProduce = 10


/obj/machinery/mineral/mint/Initialize()
	. = ..()
	for (var/dir in GLOB.cardinal)
		src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
		if(src.input) break
	for (var/dir in GLOB.cardinal)
		src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
		if(src.output) break

/obj/machinery/mineral/mint/Process()
	if ( src.input)
		var/obj/item/stack/O
		O = locate(/obj/item/stack, input.loc)
		if(O)
			var/processed = 1
			switch(O.get_material_name())
				if(MATERIAL_GOLD)
					amt_gold += 100 * O.get_amount()
				if(MATERIAL_SILVER)
					amt_silver += 100 * O.get_amount()
				if(MATERIAL_DIAMOND)
					amt_diamond += 100 * O.get_amount()
				if(MATERIAL_PLASMA)
					amt_plasma += 100 * O.get_amount()
				if(MATERIAL_URANIUM)
					amt_uranium += 100 * O.get_amount()
				if(MATERIAL_IRON)
					amt_iron += 100 * O.get_amount()
				else
					processed = 0
			if(processed)
				qdel(O)

/obj/machinery/mineral/mint/attack_hand(user as mob)

	var/dat = "<meta charset=\"utf-8\"><b>Coin Press</b><br>"

	if (!input)
		dat += text("input connection status: ")
		dat += text("<b><font color='red'>NOT CONNECTED</font></b><br>")
	if (!output)
		dat += text("<br>output connection status: ")
		dat += text("<b><font color='red'>NOT CONNECTED</font></b><br>")

	dat += text("<br><font color='#ffcc00'><b>Gold inserted: </b>[amt_gold]</font> ")
	if (chosen == MATERIAL_GOLD)
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=gold'>Choose</A>")
	dat += text("<br><font color='#888888'><b>Silver inserted: </b>[amt_silver]</font> ")
	if (chosen == MATERIAL_SILVER)
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=silver'>Choose</A>")
	dat += text("<br><font color='#555555'><b>Iron inserted: </b>[amt_iron]</font> ")
	if (chosen == MATERIAL_IRON)
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=iron'>Choose</A>")
	dat += text("<br><font color='#8888ff'><b>Diamond inserted: </b>[amt_diamond]</font> ")
	if (chosen == MATERIAL_DIAMOND)
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=diamond'>Choose</A>")
	dat += text("<br><font color='#ff8800'><b>Plasma inserted: </b>[amt_plasma]</font> ")
	if (chosen == MATERIAL_PLASMA)
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=plasma'>Choose</A>")
	dat += text("<br><font color='#008800'><b>Uranium inserted: </b>[amt_uranium]</font> ")
	if (chosen == MATERIAL_URANIUM)
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=uranium'>Choose</A>")

	dat += text("<br><br>Will produce [coinsToProduce] [chosen] coins if enough materials are available.<br>")
	//dat += text("The dial which controls the number of conins to produce seems to be stuck. A technician has already been dispatched to fix this.")
	dat += text("<A href='?src=\ref[src];chooseAmt=-10'>-10</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=-5'>-5</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=-1'>-1</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=1'>+1</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=5'>+5</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=10'>+10</A> ")

	dat += text("<br><br>In total this machine produced <font color='green'><b>[newCoins]</b></font> coins.")
	dat += text("<br><A href='?src=\ref[src];makeCoins=[1]'>Make coins</A>")
	user << browse("[dat]", "window=mint")

/obj/machinery/mineral/mint/Topic(href, href_list)
	if(..())
		return 1
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(processing==1)
		to_chat(usr, "<span class='notice'>The machine is processing.</span>")
		return
	if(href_list["choose"])
		chosen = href_list["choose"]
	if(href_list["chooseAmt"])
		coinsToProduce = between(0, coinsToProduce + text2num(href_list["chooseAmt"]), 1000)
	if(href_list["makeCoins"])
		var/temp_coins = coinsToProduce
		if (src.output)
			processing = 1;
			icon_state = "coinpress1"
			var/M = output.loc
			switch(chosen)
				if(MATERIAL_IRON)
					while(amt_iron > 0 && coinsToProduce > 0)
						new /obj/item/weapon/coin/iron(M)
						amt_iron -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if(MATERIAL_GOLD)
					while(amt_gold > 0 && coinsToProduce > 0)
						new /obj/item/weapon/coin/gold(M)
						amt_gold -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if(MATERIAL_SILVER)
					while(amt_silver > 0 && coinsToProduce > 0)
						new /obj/item/weapon/coin/silver(M)
						amt_silver -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if(MATERIAL_DIAMOND)
					while(amt_diamond > 0 && coinsToProduce > 0)
						new /obj/item/weapon/coin/diamond(M)
						amt_diamond -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if(MATERIAL_PLASMA)
					while(amt_plasma > 0 && coinsToProduce > 0)
						new /obj/item/weapon/coin/plasma(M)
						amt_plasma -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if(MATERIAL_URANIUM)
					while(amt_uranium > 0 && coinsToProduce > 0)
						new /obj/item/weapon/coin/uranium(M)
						amt_uranium -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5)
			icon_state = "coinpress0"
			processing = 0;
			coinsToProduce = temp_coins
	src.updateUsrDialog()
	return