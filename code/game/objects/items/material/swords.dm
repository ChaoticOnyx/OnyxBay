/obj/item/material/sword
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_HUGE
	force_divisor = 0.5 // 30 when wielded with hardnes 60 (steel)
	thrown_force_divisor = 0.5 // 10 when thrown with weight 20 (steel)
	sharp = 1
	edge = 1
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/material/sword/handle_shield(mob/user, damage, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")
	if(default_parry_check(user, attacker, damage_source) && prob(50))
		user.visible_message("<span class='danger'>\The [user] parries [attack_text] with \the [src]!</span>")
		playsound(user.loc, 'sound/weapons/punchmiss.ogg', 50, 1)
		return 1
	return 0

/obj/item/material/sword/replica
	desc = "What are you standing around staring at this for? Get to looking cringy!"
	edge = 0
	sharp = 0
	force_divisor = 0.1 // 2 when wielded with weight 20 (steel)
	thrown_force_divisor = 0.2
	hitsound = SFX_FIGHTING_SWING // It's dull

/obj/item/material/sword/katana
	name = "katana"
	desc = "Woefully underpowered in D20. This one looks pretty sharp."
	icon_state = "katana"
	item_state = "katana"
	w_class = ITEM_SIZE_LARGE
	slot_flags = SLOT_BELT | SLOT_BACK

/obj/item/material/sword/katana/replica
	desc = "The best friend of a samurai wannabe. This one looks not so sharp."
	edge = 0
	sharp = 0
	force_divisor = 0.1 // 5 when wielded with weight 20 (steel)
	thrown_force_divisor = 0.2
	hitsound = SFX_FIGHTING_SWING
