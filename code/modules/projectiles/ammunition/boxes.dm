/obj/item/ammo_magazine/a357
	//name = "ammo box (.357)"
	//desc = "A box of .357 ammo"
	//icon_state = "357"
	name = "speed loader (.357)"
	desc = "A speed loader for revolvers."
	icon_state = "38"
	caliber = "357"
	ammo_type = /obj/item/ammo_casing/a357
	matter = list(MATERIAL_STEEL = 1260)
	max_ammo = 6
	multiple_sprites = 1

/obj/item/ammo_magazine/c50
	name = "speed loader (.50)"
	desc = "A speed loader for revolvers."
	icon_state = "38"
	caliber = ".50"
	ammo_type = /obj/item/ammo_casing/a50
	matter = list(MATERIAL_STEEL = 1260)
	max_ammo = 6
	multiple_sprites = 1

/obj/item/ammo_magazine/c38
	name = "speed loader (.38)"
	desc = "A speed loader for revolvers."
	icon_state = "38"
	caliber = ".38"
	matter = list(MATERIAL_STEEL = 360)
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6
	multiple_sprites = 1

/obj/item/ammo_magazine/c38/rubber
	name = "speed loader (.38, rubber)"
	icon_state = "R38"
	ammo_type = /obj/item/ammo_casing/c38/rubber

/obj/item/ammo_magazine/c38/emp
	name = "speed loader (.38 EMP)"
	icon_state = "E38"
	ammo_type = /obj/item/ammo_casing/c38/emp

/obj/item/ammo_magazine/c38/spec
	name = "speed loader (.38 SPEC)"
	desc = "A five-round speed loader for M2019."
	icon_state = "38spec"
	ammo_type = /obj/item/ammo_casing/c38/spec
	matter = list(MATERIAL_STEEL = 1000)
	max_ammo = 5

/obj/item/ammo_magazine/c38/chem
	name = "speed loader (.38 CHEM)"
	desc = "A five-round speed loader for M2019."
	icon_state = "38chem"
	ammo_type = /obj/item/ammo_casing/c38/chem
	matter = list(MATERIAL_STEEL = 1500)
	max_ammo = 5

/obj/item/ammo_magazine/c44
	name = "speed loader (.44 magnum)"
	desc = "A speed loader for revolvers."
	icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c44
	matter = list(MATERIAL_STEEL = 450)
	caliber = ".44"
	max_ammo = 6
	multiple_sprites = 1

/obj/item/ammo_magazine/c44/rubber
	name = "speed loader (.44 magnum, rubber)"
	icon_state = "R38"
	ammo_type = /obj/item/ammo_casing/c44/rubber

/obj/item/ammo_magazine/c45m
	name = "magazine (.45)"
	icon_state = "45"
	mag_type = MAGAZINE
	ammo_type = /obj/item/ammo_casing/c45
	matter = list(MATERIAL_STEEL = 525) //metal costs are very roughly based around 1 .45 casing = 75 metal
	caliber = ".45"
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_magazine/c45m/empty
	initial_ammo = 0

/obj/item/ammo_magazine/c45m/rubber
	name = "magazine (.45, rubber)"
	icon_state = "45r"
	ammo_type = /obj/item/ammo_casing/c45/rubber

/obj/item/ammo_magazine/c45m/practice
	name = "magazine (.45, practice)"
	ammo_type = /obj/item/ammo_casing/c45/practice

/obj/item/ammo_magazine/c45m/flash
	name = "magazine (.45, flash)"
	ammo_type = /obj/item/ammo_casing/c45/flash

/obj/item/ammo_magazine/c45m/stun
	name = "magazine (.45, stun)"
	icon_state = "45s"
	desc = "A magazine for some kind of gun. This one has yellow strips on its sides."
	ammo_type = /obj/item/ammo_casing/c45/stun

/obj/item/ammo_magazine/c45uzi
	name = "stick magazine (.45)"
	icon_state = "uzi45"
	mag_type = MAGAZINE
	ammo_type = /obj/item/ammo_casing/c45
	matter = list(MATERIAL_STEEL = 1200)
	caliber = ".45"
	max_ammo = 16
	multiple_sprites = 1

/obj/item/ammo_magazine/c45uzi/empty
	initial_ammo = 0

/obj/item/ammo_magazine/mc9mm
	name = "magazine (9mm)"
	icon_state = "9x19p"
	origin_tech = list(TECH_COMBAT = 2)
	mag_type = MAGAZINE
	matter = list(MATERIAL_STEEL = 480)
	caliber = "9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 10
	multiple_sprites = 1

/obj/item/ammo_magazine/mc9mm/empty
	initial_ammo = 0

/obj/item/ammo_magazine/mc9mm/flash
	name = "magazine (9mm, flash)"
	ammo_type = /obj/item/ammo_casing/c9mm/flash

/obj/item/ammo_magazine/box/c9mm
	name = "ammunition box (9mm)"
	icon_state = "9mm"
	origin_tech = list(TECH_COMBAT = 2)
	matter = list(MATERIAL_STEEL = 1800)
	caliber = "9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 30

/obj/item/ammo_magazine/box/c9mm/empty
	initial_ammo = 0

/obj/item/ammo_magazine/box/emp
	name = "ammunition box (.38, haywire)"
	icon_state = "empbox"
	origin_tech = list(TECH_COMBAT = 2)
	max_ammo = 10
	ammo_type = /obj/item/ammo_casing/c38/emp
	caliber = ".38"

/obj/item/ammo_magazine/box/emp/c45
	name = "ammunition box (.45, haywire)"
	ammo_type = /obj/item/ammo_casing/c45/emp
	caliber = ".45"

/obj/item/ammo_magazine/box/emp/a10mm
	name = "ammunition box (10mm, haywire)"
	ammo_type = /obj/item/ammo_casing/a10mm/emp
	caliber = "10mm"

/obj/item/ammo_magazine/mc9mmt
	name = "top mounted magazine (9mm)"
	icon_state = "9mmt"
	mag_type = MAGAZINE
	ammo_type = /obj/item/ammo_casing/c9mm
	matter = list(MATERIAL_STEEL = 1200)
	caliber = "9mm"
	max_ammo = 20
	multiple_sprites = 1

/obj/item/ammo_magazine/mc9mmt/empty
	initial_ammo = 0

/obj/item/ammo_magazine/mc9mmt/rubber
	name = "top mounted magazine (9mm, rubber)"
	icon_state = "9mmtr"
	ammo_type = /obj/item/ammo_casing/c9mm/rubber

/obj/item/ammo_magazine/mc9mmt/practice
	name = "top mounted magazine (9mm, practice)"
	ammo_type = /obj/item/ammo_casing/c9mm/practice

/obj/item/ammo_magazine/box/c45
	name = "ammunition box (.45)"
	icon_state = "9mm"
	origin_tech = list(TECH_COMBAT = 2)
	caliber = ".45"
	matter = list(MATERIAL_STEEL = 2250)
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 30

/obj/item/ammo_magazine/box/c45/empty
	initial_ammo = 0

/obj/item/ammo_magazine/a10mm
	name = "magazine (10mm)"
	icon_state = "10mm"
	origin_tech = list(TECH_COMBAT = 2)
	mag_type = MAGAZINE
	caliber = "10mm"
	matter = list(MATERIAL_STEEL = 1500)
	ammo_type = /obj/item/ammo_casing/a10mm
	max_ammo = 20
	multiple_sprites = 1

/obj/item/ammo_magazine/a10mm/empty
	initial_ammo = 0

/obj/item/ammo_magazine/a762
	name = "magazine (7.62mm)"
	icon_state = "5.56"
	origin_tech = list(TECH_COMBAT = 2)
	mag_type = MAGAZINE
	caliber = "a762"
	matter = list(MATERIAL_STEEL = 1800)
	ammo_type = /obj/item/ammo_casing/a762
	max_ammo = 15 //if we lived in a world where normal mags had 30 rounds, this would be a 20 round mag
	multiple_sprites = 1

/obj/item/ammo_magazine/a762/empty
	initial_ammo = 0

/obj/item/ammo_magazine/a762/practice
	name = "magazine (7.62mm, practice)"
	ammo_type = /obj/item/ammo_casing/a762/practice

/obj/item/ammo_magazine/a50
	name = "magazine (.50)"
	icon_state = "50ae"
	origin_tech = list(TECH_COMBAT = 2)
	mag_type = MAGAZINE
	caliber = ".50"
	matter = list(MATERIAL_STEEL = 1260)
	ammo_type = /obj/item/ammo_casing/a50
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_magazine/a50/empty
	initial_ammo = 0

/obj/item/ammo_magazine/a75
	name = "ammo magazine (20mm)"
	icon_state = "75"
	mag_type = MAGAZINE
	caliber = "75"
	ammo_type = /obj/item/ammo_casing/a75
	multiple_sprites = 1
	max_ammo = 4

/obj/item/ammo_magazine/a75/empty
	initial_ammo = 0

/obj/item/ammo_magazine/box/a556
	name = "magazine box (5.56mm)"
	icon_state = "a556"
	origin_tech = list(TECH_COMBAT = 2)
	mag_type = MAGAZINE
	caliber = "a556"
	matter = list(MATERIAL_STEEL = 5400)
	ammo_type = /obj/item/ammo_casing/a556
	max_ammo = 60
	multiple_sprites = 1

/obj/item/ammo_magazine/box/a556/empty
	initial_ammo = 0

/obj/item/ammo_magazine/c556
	name = "magazine (5.56mm)"
	icon_state = "c762"
	mag_type = MAGAZINE
	caliber = "a556"
	matter = list(MATERIAL_STEEL = 2250)
	ammo_type = /obj/item/ammo_casing/a556
	max_ammo = 25
	multiple_sprites = 1

/obj/item/ammo_magazine/caps
	name = "speed loader (caps)"
	desc = "A cheap plastic speed loader for some kind of revolver."
	icon_state = "T38"
	caliber = "caps"
	color = "#ff0000"
	ammo_type = /obj/item/ammo_casing/cap
	matter = list(MATERIAL_STEEL = 600)
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_magazine/lawgiver
	name = "lawgiver magazine"
	desc = "State-of-the-art bluespace technology allows this magazine to generate new rounds from energy, requiring only a power source to refill the full suite of ammunition types."
	icon_state = "lawgiver"
	mag_type = MAGAZINE
	ammo_type = null
	caliber = "lawgiver"
	max_ammo = 0
	display_default_ammo_left = FALSE
	var/list/ammo_counters

/obj/item/ammo_magazine/lawgiver/Initialize()
	. = ..()
	var/list/new_ammo_counters = list()
	for(var/list/mode in GLOB.lawgiver_modes)
		new_ammo_counters[mode["mode_name"]] = LAWGIVER_MAX_AMMO
	ammo_counters = new_ammo_counters
	update_icon()

/obj/item/ammo_magazine/lawgiver/attack_self()
	return

/obj/item/ammo_magazine/lawgiver/emp_act(severity)
	if(prob(25))
		discharge_magazine()

/obj/item/ammo_magazine/lawgiver/proc/discharge_magazine()
	for(var/mode_name in ammo_counters)
		if(prob(15))
			ammo_counters[mode_name] = max(1, ammo_counters[mode_name] - rand(1, LAWGIVER_MAX_AMMO % 3))

/obj/item/ammo_magazine/lawgiver/proc/generate_description()
    var/dat = "\n"
    for(var/list/mode in GLOB.lawgiver_modes)
        var/ammo_left = round(ammo_counters[mode["mode_name"]], 0.1)
        dat += "It has [ammo_left] [mode["mode_name"]] charge[ammo_left != 1 ? "s" : ""] left.\n"
    return SPAN("info", dat)

/obj/item/ammo_magazine/lawgiver/examine(mob/user, infix)
	. = ..()
	. += generate_description()

/obj/item/ammo_magazine/lawgiver/proc/isFull()
	for(var/mode in ammo_counters)
		if(ammo_counters[mode] != LAWGIVER_MAX_AMMO)
			return FALSE
	return TRUE

/obj/item/ammo_magazine/c792
	name = "clip (7.92mm)"
	icon_state = "c792"
	mag_type = SPEEDLOADER
	caliber = "7.92"
	matter = list(MATERIAL_STEEL = 2000)
	ammo_type = /obj/item/ammo_casing/a792
	max_ammo = 5
	multiple_sprites = TRUE
