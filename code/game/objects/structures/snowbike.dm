/obj/vehicle/bike/thermal/snowbike
	name = "Snowbike"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "snowbike_1_on"
	bike_icon = "snowbike"
	prefilled = 1
	land_speed = 2
	space_speed = 0

/obj/vehicle/bike/thermal/snowbike/New()
	bike_icon = "snowbike_[rand(1,3)]"
	..()

/obj/item/key/snowbike
	name = "key"
	desc = "A keyring with a small steel key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "seckeys"
	w_class = 1

/obj/vehicle/bike/update_icon()
	..()
