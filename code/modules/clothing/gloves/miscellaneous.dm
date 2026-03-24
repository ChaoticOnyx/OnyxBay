/obj/item/clothing/gloves/captain
	name = "captain's gloves"
	desc = "Regal blue gloves, with a nice gold trim. Swanky."
	icon_state = "captain"
	armor = list(melee = 70, bullet = 60, laser = 50, energy = 60, bomb = 0, bio = 30)
	siemens_coefficient = 0 // These are ELITE

/obj/item/clothing/gloves/insulated
	name = "insulated gloves"
	desc = "These gloves will protect the wearer from electric shocks."
	color = COLOR_YELLOW
	icon_state = "white"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	armor = list(melee = 20, bullet = 5, laser = 10, energy = 70, bomb = 0, bio = 30)

	drop_sound = SFX_DROP_RUBBER
	pickup_sound = SFX_PICKUP_RUBBER

	item_state_slots = list(
		slot_l_hand_str = "ygloves",
		slot_r_hand_str = "ygloves",
		)

/obj/item/clothing/gloves/insulated/cheap                             //Cheap Chinese Crap
	name = "budget insulated gloves"
	desc = "These gloves are cheap copies of the coveted gloves, no way this can end badly."
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in New()

/obj/item/clothing/gloves/insulated/cheap/New()
	..()
	//average of 0.4, better than regular gloves' 0.75
	siemens_coefficient = pick(0, 0.1, 0.2, 0.3, 0.4, 0.6, 1.3)

/obj/item/clothing/gloves/forensic
	name = "forensic gloves"
	desc = "Specially made gloves for forensic technicians. The luminescent threads woven into the material stand out under scrutiny."
	icon_state = "forensic"
	item_state = "black"
	siemens_coefficient = 0.50
	permeability_coefficient = 0.05
	armor = list(melee = 15, bullet = 10, laser = 10, energy = 5, bomb = 0, bio = 0)

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/thick
	name = "work gloves"
	desc = "These work gloves are thick and fire-resistant."
	icon_state = "black"
	siemens_coefficient = 0.5
	permeability_coefficient = 0.05
	armor = list(melee = 50, bullet = 40, laser = 60, energy = 15, bomb = 0, bio = 0)

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/thick/modified
	item_flags = ITEM_FLAG_PREMODIFIED

/obj/item/clothing/gloves/thick/botany
	name = "thick leather gloves"
	desc = "These leather work gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin."
	icon_state = "leather"

/obj/item/clothing/gloves/thick/botany/modified
	item_flags = ITEM_FLAG_PREMODIFIED

/obj/item/clothing/gloves/swat
	name = "\improper SWAT Gloves"
	desc = "These tactical gloves are superior fire, impact and bullet resistance."
	icon_state = "swat"
	item_state = "swat"
	force = 5
	siemens_coefficient = 0.3
	permeability_coefficient = 0.05
	armor = list(melee = 80, bullet = 80, laser = 80, energy = 25, bomb = 50, bio = 30)

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/swat/combat //Combined effect of SWAT gloves and insulated gloves
	name = "\improper Combat gloves"
	desc = "These tactical gloves are superior fire, impact and bullet resistance. They also appear to have insulating rubber on them."
	icon_state = "combat"
	item_state = "combat"
	siemens_coefficient = 0

/obj/item/clothing/gloves/security
	name = "\improper Security Gloves"
	desc = "These tactical gloves are somewhat fire and impact-resistant."
	icon_state = "sec_black"
	item_state = "sec_black"
	siemens_coefficient = 0.5
	permeability_coefficient = 0.05
	armor = list(melee = 50, bullet = 40, laser = 60, energy = 15, bomb = 0, bio = 0)

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/security/gray
	name = "\improper Gray Security Gloves"
	icon_state = "sec_gray"
	item_state = "sec_gray"

/obj/item/clothing/gloves/security/blue
	name = "\improper Blue Security Gloves"
	icon_state = "sec_blue"
	item_state = "sec_blue"

/obj/item/clothing/gloves/security/navy
	name = "\improper Navy Security Gloves"
	icon_state = "sec_navy"
	item_state = "sec_navy"

/obj/item/clothing/gloves/security/green
	name = "\improper Green Security Gloves"
	icon_state = "sec_green"
	item_state = "sec_green"

/obj/item/clothing/gloves/security/tan
	name = "\improper Tan Security Gloves"
	icon_state = "sec_tan"
	item_state = "sec_tan"

/obj/item/clothing/gloves/latex
	name = "latex gloves"
	desc = "Sterile latex gloves."
	icon_state = "white"
	siemens_coefficient = 1.1 //thin latex gloves, much more conductive than fabric gloves (basically a capacitor for AC)
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 95)

	drop_sound = SFX_DROP_RUBBER
	pickup_sound = SFX_PICKUP_RUBBER

	item_state_slots = list(
		slot_l_hand_str = "lgloves",
		slot_r_hand_str = "lgloves",
		)

/obj/item/clothing/gloves/latex/modified
	item_flags = ITEM_FLAG_PREMODIFIED

/obj/item/clothing/gloves/latex/nitrile
	name = "nitrile gloves"
	desc = "Sterile nitrile gloves"
	icon_state = "nitrile"

/obj/item/clothing/gloves/latex/nitrile/modified
	item_flags = ITEM_FLAG_PREMODIFIED

/obj/item/clothing/gloves/duty
	name = "work gloves"
	desc = "These brown duty gloves are made from a durable synthetic."
	icon_state = "work"
	siemens_coefficient = 0.50
	armor = list(melee = 50, bullet = 40, laser = 60, energy = 45, bomb = 0, bio = 0)

/obj/item/clothing/gloves/duty/modified
	item_flags = ITEM_FLAG_PREMODIFIED

/obj/item/clothing/gloves/tactical
	name = "tactical gloves"
	desc = "These brown tactical gloves are made from a durable synthetic, and have hardened knuckles."
	icon_state = "work"
	force = 5
	siemens_coefficient = 0.50
	permeability_coefficient = 0.05
	armor = list(melee = 50, bullet = 40, laser = 60, energy = 15, bomb = 20, bio = 0)

/obj/item/clothing/gloves/guards
	name = "arm guards"
	desc = "A pair of synthetic gloves and arm pads reinforced with armor plating."
	icon_state = "guards"
	body_parts_covered = HANDS|ARMS
	w_class = ITEM_SIZE_NORMAL
	siemens_coefficient = 0.7
	permeability_coefficient = 0.03
	armor = list(melee = 70, bullet = 40, laser = 60, energy = 25, bomb = 0, bio = 0)
