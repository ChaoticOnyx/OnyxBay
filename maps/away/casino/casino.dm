/obj/machinery/computer/shuttle_control/explore/casino_cutter
	name = "cutter control console"
	shuttle_tag = "Casino Cutter"

/obj/structure/casino/roulette
	name = "roulette"
	desc = "Spin the roulette to try your luck."
	icon = 'maps/away/casino/casino_sprites.dmi'
	icon_state = "roulette_r"
	density = 0
	anchored = 1
	var/busy=0

/obj/structure/casino/roulette/attack_hand(mob/user as mob)
	if (busy)
		to_chat(user,"<span class='notice'>You cannot spin now! \The [src] is already spinning.</span> ")
		return
	visible_message("<span class='notice'>\ [user]  spins the roulette and throws inside little ball.</span>")
	busy = 1
	var/n = rand(0,36)
	var/color = "green"
	add_fingerprint(user)
	if ((n>0 && n<11) || (n>18 && n<29))
		if (n%2)
			color="red"
	else
		color="black"
	if ( (n>10 && n<19) || (n>28) )
		if (n%2)
			color="black"
	else
		color="red"
	spawn(5 SECONDS)
		visible_message("<span class='notice'>\The [src] stops spinning, the ball landing on [n], [color].</span>")
		busy=0

/obj/structure/casino/roulette_chart
	name = "roulette chart"
	desc = "Roulette chart. Place your bets! "
	icon = 'maps/away/casino/casino_sprites.dmi'
	icon_state = "roulette_l"
	density = 0
	anchored = 1

/obj/structure/casino/bj_table
	name = "blackjack table"
	desc = "This is a blackjack table. "
	icon = 'maps/away/casino/casino_sprites.dmi'
	icon_state = "bj_left"
	density = 0
	anchored = 1

/obj/structure/casino/bj_table/bj_right
	icon_state = "bj_right"

/obj/structure/casino/oh_bandit
	name = "one armed bandit"
	desc = "Turned off slot machine. "
	icon = 'maps/away/casino/casino_sprites.dmi'
	icon_state = "slot_machine"
	density = 0
	anchored = 1

/obj/structure/casino/craps
	name = "craps table"
	desc = "Craps table: roll dice!"
	icon = 'maps/away/casino/casino_sprites.dmi'
	icon_state = "craps_top"
	density = 0
	anchored = 1

/obj/structure/casino/craps/craps_down
	icon_state = "craps_down"

//========================used bullet casings=======================
/obj/item/ammo_casing/a556/used/Initialize()
	. = ..()
	expend()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)


/obj/item/ammo_casing/c45/used/Initialize()
	. = ..()
	expend()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)

/obj/item/ammo_casing/a50/used/Initialize()
	. = ..()
	expend()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)

/obj/item/ammo_casing/a10mm/used/Initialize()
	. = ..()
	expend()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)

/obj/item/ammo_casing/c9mm/used/Initialize()
	. = ..()
	expend()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)

/obj/item/ammo_casing/shotgun/pellet/used/Initialize()
	. = ..()
	expend()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
