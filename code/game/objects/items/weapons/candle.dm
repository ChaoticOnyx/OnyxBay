/obj/item/flame/candle
	name = "red candle"
	desc = "A small pillar candle. Its specially-formulated fuel-oxidizer wax mixture allows continued combustion in airless environments."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"
	w_class = ITEM_SIZE_TINY
	mod_weight = 0.25
	mod_reach = 0.25
	mod_handy = 0.25
	light_color = "#e09d37"
	var/wax

/obj/item/flame/candle/New()
	wax = rand(27 MINUTES, 33 MINUTES) / SSobj.wait // Enough for 27-33 minutes. 30 minutes on average, adjusted for subsystem tickrate.
	..()

/obj/item/flame/candle/update_icon()
	var/i
	if(wax > 1500)
		i = 1
	else if(wax > 800)
		i = 2
	else i = 3
	icon_state = "candle[i][lit ? "_lit" : ""]"

/obj/item/flame/candle/attackby(obj/item/W, mob/user)
	..()
	if(W.get_temperature_as_from_ignitor())
		light(user)

/obj/item/flame/candle/resolve_attackby(atom/A, mob/user)
	. = ..()
	if(istype(A, /obj/item/flame/candle) && get_temperature_as_from_ignitor())
		var/obj/item/flame/candle/other_candle = A
		other_candle.light()

/obj/item/flame/candle/proc/light(mob/user)
	if(!lit)
		lit = TRUE
		visible_message(SPAN("notice", "\The [user] lights the [name]."))
		set_light(0.3, 0.25, 2.0, 4.0)
		START_PROCESSING(SSobj, src)

/obj/item/flame/candle/Process()
	if(!lit)
		return
	wax--
	if(!wax)
		new /obj/item/trash/candle(src.loc)
		qdel(src)
	update_icon()
	if(istype(loc, /turf)) //start a fire if possible
		var/turf/T = loc
		T.hotspot_expose(700, 5)

/obj/item/flame/candle/attack_self(mob/user as mob)
	if(lit)
		lit = 0
		update_icon()
		set_light(0)
