/obj/item/weapon/material/sword
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_HUGE
	mod_weight = 1.75
	mod_reach = 1.65
	mod_handy = 1.25
	force_const = 12
	thrown_force_const = 5
	force_divisor = 0.4 // 24 when wielded with hardnes 60 (steel)
	thrown_force_divisor = 0.3 // 6 when thrown with weight 20 (steel)
	sharp = 1
	edge = 1
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/material/sword/replica
	desc = "What are you standing around staring at this for? Get to looking cringy!"
	edge = 0
	sharp = 0
	force_const = 2.5
	force_divisor = 0.2
	thrown_force_divisor = 0.2

/obj/item/weapon/material/sword/katana
	name = "katana"
	desc = "Woefully underpowered in D20. This one looks pretty sharp."
	icon_state = "katana"
	item_state = "katana"
	w_class = ITEM_SIZE_LARGE
	mod_weight = 1.3
	mod_reach = 1.5
	mod_handy = 1.5
	slot_flags = SLOT_BELT | SLOT_BACK

/obj/item/weapon/material/sword/katana/replica
	desc = "The best friend of a samurai wannabe. This one looks not so sharp."
	edge = 0
	sharp = 0
	force_const = 2.5
	force_divisor = 0.2
	thrown_force_divisor = 0.2
