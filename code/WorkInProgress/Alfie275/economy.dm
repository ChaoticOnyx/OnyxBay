/obj/item/weapon/money
	name = "Space Cash"
	desc = "You're rich, bitch!"
	icon = 'items.dmi'
	icon_state = "spacecash"
	opacity = 0
	density = 0
	anchored = 0.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 2
	w_class = 1.0
	var/value
	var/currency
	var/split = 5
	var/round = 0.01

/obj/item/weapon/money/pawnbucks
	name = "Pawn Bucks"
	desc = "100% genuine, bonified PAWN BUCKS! Real money not included."
	value = 10
	currency = "Pawn Bucks"

/obj/item/weapon/money/tickets
	name = "Tickets"
	desc = ""
	value = 5
	currency = "Tickets"
	round = 1

/obj/item/weapon/spacecash
	New() // quickfix until I get the map
		spawn(1)
			new/obj/item/weapon/money(loc)
			del src



/obj/item/weapon/money/proc/updatedesc()
	name = "[currency]"
	desc = "A pile of [value] [currency]"

/obj/item/weapon/money/New(var/nloc, var/nvalue=10,var/ncurrency  = "Space Cash")
	if(!value)
		value = nvalue
	if(!currency)
		currency = ncurrency
	split = round(value/2,round)
	updatedesc()
	return ..(nloc)


/obj/item/weapon/money/attack_self(var/mob/user)
	interact(user)

/obj/item/weapon/money/proc/interact(var/mob/user)


	user.machine = src

	var/dat

	dat += "<BR>[value] [currency]"
	dat += "<BR>New pile:"

	dat += "<A href='?src=\ref[src];sd=5'>-</a>"
	dat += "<A href='?src=\ref[src];sd=1'>-</a>"
	if(round<=0.1)
		dat += "<A href='?src=\ref[src];sd=0.1'>-</a>"
		if(round<=0.01)
			dat += "<A href='?src=\ref[src];sd=0.01'>-</a>"
	dat += "[split]"
	if(round<=0.01)
		dat += "<A href='?src=\ref[src];su=0.01'>+</a>"
	if(round<=0.1)
		dat += "<A href='?src=\ref[src];su=0.1'>+</a>"
	dat += "<A href='?src=\ref[src];su=1'>+</a>"
	dat += "<A href='?src=\ref[src];su=5'>+</a>"
	dat += "<BR><A href='?src=\ref[src];split=1'>split</a>"


	user << browse(dat, "window=computer;size=400x500")

	onclose(user, "computer")
	return






/obj/item/weapon/money/Topic(href, href_list)
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

		if (href_list["su"])
			var/samt = text2num(href_list["su"])
			if(split+samt<value)
				split+=samt
		if (href_list["sd"])
			var/samt = text2num(href_list["sd"])
			if(split-samt>0)
				split-=samt
		if(href_list["split"])
			new type(get_turf(src),split,currency)
			value-=split
			split = round(value/2,round)
			updatedesc()


		src.add_fingerprint(usr)
	src.updateUsrDialog()
	for (var/mob/M in viewers(1, src.loc))
		if (M.client && M.machine == src)
			src.attack_self(M)
	return


/obj/item/weapon/money/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I,/obj/item/weapon/money))
		var/mob/living/carbon/c = user
		if(!uppertext(I:currency)==uppertext(currency))
			c<<"You can't mix currencies!"
			return ..()
		else
			value+=I:value
			c<<"You combine the piles."
			updatedesc()
			del I
	return ..()