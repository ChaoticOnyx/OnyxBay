/obj/item/gun/energy/temperature
	name = "temperature gun"
	icon_state = "freezegun"
	item_state = "freezegun"
	fire_sound = 'sound/effects/weapons/energy/pulse3.ogg'
	desc = "A gun that can increase temperatures. It has a small label on the side, 'More extreme temperatures will cost more charge!'"
	var/temperature = T20C
	var/current_temperature = T20C
	charge_cost = 10
	max_shots = 10
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 4, TECH_POWER = 3, TECH_MAGNET = 2)
	slot_flags = SLOT_BELT|SLOT_BACK
	one_hand_penalty = 2
	wielded_item_state = "gun_wielded"

	projectile_type = /obj/item/projectile/temp
	cell_type = /obj/item/cell/high
	combustion = 0


/obj/item/gun/energy/temperature/_examine_text(mob/user)
	. = ..()
	. += "\nThe temperature sensor shows: [round(temperature-T0C)]&deg;C"

/obj/item/gun/energy/temperature/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/gun/energy/temperature/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()


/obj/item/gun/energy/temperature/attack_self(mob/living/user)
	user.set_machine(src)
	var/temp_text = ""
	if(temperature > (T0C - 50))
		temp_text = "<FONT color=black>[temperature] ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F)</FONT>"
	else
		temp_text = "<FONT color=blue>[temperature] ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F)</FONT>"

	var/dat = {"<meta charset=\"utf-8\"><B>Freeze Gun Configuration: </B><BR>
	Current output temperature: [temp_text]<BR>
	Target output temperature: <A href='?src=\ref[src];temp=-100'>-</A> <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> <A href='?src=\ref[src];temp=100'>+</A><BR>
	"}

	show_browser(user, dat, "window=freezegun;size=450x300;can_resize=1;can_close=1;can_minimize=1")
	onclose(user, "window=freezegun", src)

/obj/item/gun/energy/temperature/Topic(user, href_list, state = GLOB.inventory_state)
	..()

/obj/item/gun/energy/temperature/OnTopic(user, href_list)
	if(href_list["temp"])
		var/amount = text2num(href_list["temp"])
		if(amount > 0)
			current_temperature = min(800, current_temperature+amount)
		else
			current_temperature = max(100, current_temperature+amount)
		. = TOPIC_REFRESH

		attack_self(user)

/obj/item/gun/energy/temperature/Process()
	switch(temperature)
		if(100 to 200) charge_cost = 10
		if(201 to 200) charge_cost = 20
		if(301 to 300) charge_cost = 30
		if(401 to 400) charge_cost = 40
		if(401 to 500) charge_cost = 50
		if(501 to 600) charge_cost = 60
		if(601 to 700) charge_cost = 70
		if(701 to 800) charge_cost = 80

	if(current_temperature != temperature)
		var/difference = abs(current_temperature - temperature)
		if(difference >= 10)
			if(current_temperature < temperature)
				temperature -= 10
			else
				temperature += 10
		else
			temperature = current_temperature

/obj/item/gun/energy/temperature/Fire(atom/target, mob/living/user, clickparams, pointblank, reflex)
	if(temperature >= 450)
		temperature -= rand(0,100)
	. = ..()

/obj/item/gun/energy/temperature/consume_next_projectile()
	if(!power_supply) return null
	if(!ispath(projectile_type)) return null
	if(!power_supply.checked_use(charge_cost)) return null
	var/obj/item/projectile/temp/temp_proj = new projectile_type(src)
	temp_proj.temperature = current_temperature
	return temp_proj
