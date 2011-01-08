/obj/spawner/bomb
	name = "bomb"
	icon = 'screen1.dmi'
	icon_state = "x"
	var/btype = 0  //0 = radio, 1= prox, 2=time
	var/explosive = 1	// 0= firebomb
	var/btemp = 500	// bomb temperature (degC)
	var/active = 0

/obj/spawner/bomb/radio
	btype = 0

/obj/spawner/bomb/proximity
	btype = 1

/obj/spawner/bomb/timer
	btype = 2

/obj/spawner/bomb/timer/syndicate
	btemp = 450

/obj/spawner/bomb/suicide
	btype = 3

/obj/spawner/newbomb
	// Remember to delete it if you use it for anything else other than uplinks. See the commented line in its New() - Abi
	// Going in depth: the reason we do not do a Del() in its New()is because then we cannot access its properties.
	// I might be doing this wrong / not knowing of a Byond function. If I'm doing it wrong, let me know please.
	name = "bomb"
	icon = 'screen1.dmi'
	icon_state = "x"
	var/btype = 0 // 0=radio, 1=prox, 2=time
	var/btemp1 = 1500
	var/btemp2 = 1000	// tank temperatures

/obj/spawner/newbomb/timer
	btype = 2

/obj/spawner/newbomb/timer/syndicate
	name = "Low-Yield Bomb"
	btemp1 = 1500
	btemp2 = 1000

/obj/spawner/newbomb/proximity
	btype = 1

/obj/spawner/newbomb/radio
	btype = 0