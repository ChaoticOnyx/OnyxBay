/obj/item/melee
	icon = 'icons/obj/weapons.dmi'

/obj/item/melee/whip
	name = "whip"
	desc = "A generic whip."
	icon_state = "chain"
	item_state = "chain"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 0.8
	mod_reach = 1.5
	mod_handy = 1.15
	origin_tech = list(TECH_COMBAT = 4)
	attack_verb = list("flicked", "whipped", "lashed")


/obj/item/melee/whip/abyssal
	name = "abyssal whip"
	desc = "A weapon from the abyss. Requires 70 attack to wield."
	icon_state = "whip"
	item_state = "whip"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	force = 16 //max hit with 60 strength and no equipment. Duel Arena no No forfeit - Snapshot
	throwforce = 7
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_COMBAT = 4)
	attack_verb = list("flicked", "whipped", "lashed")

/obj/item/melee/whip/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	icon_state = "chain"
	item_state = "whip"

/obj/item/material/sword/replica/officersword
	name = "fleet officer's sword"
	desc = "A polished sword issued to officers of the fleet."
	icon_state = "officersword"
	item_state = "officersword"
	slot_flags = SLOT_BELT
	applies_material_colour = FALSE

/obj/item/material/sword/replica/officersword/marine
	name = "marine NCO's sword"
	desc = "A polished sword issued to SCG Marine NCOs."
	icon_state = "marinesword"

/obj/item/material/sword/replica/officersword/marineofficer
	name = "marine officer's sword"
	desc = "A curved sword issued to SCG Marine officers."
	icon_state = "marineofficersword"
	item_state = "marineofficersword"

/obj/item/material/sword/replica/officersword/pettyofficer
	name = "chief petty officer's cutlass"
	desc = "A polished cutlass issued to chief petty officers of the fleet."
	icon_state = "pettyofficersword"
	item_state = "pettyofficersword"

/obj/item/melee/mimesword
	name = "Baguette"
	desc = "Bon slashettit! For some reason it looks extremly sharp."
	icon = 'icons/obj/food.dmi'
	icon_state = "baguette"
	slot_flags = SLOT_BELT
	force = 15
	throwforce = 7
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 0.7
	mod_reach = 1.2
	mod_handy = 1.1
	attack_verb = list("bashed", "mime'd", "baguetted", "slashed")

	var/times_consumed = 0

/obj/item/melee/mimesword/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/mime = user
	if(I_HELP && !(mime.check_mouth_coverage()))
		if(prob(force+rand(0,force/2)))
			to_chat(mime, SPAN("warning", "You accidentally stabbed yourself in the head, while trying to consume [src]!"))
			mime.apply_damage(force, BRUTE, BP_HEAD, 0, 0, used_weapon = "very, very sharp baguette")
			mime.embed(src, BP_HEAD)
			return
		
		to_chat(mime, SPAN("notice", "You take a bite of [src], making it even sharper!"))
		force += rand(5,10)
		times_consumed += 1
		playsound(mime.loc, SFX_EAT, rand(45, 60), FALSE)
	. = ..()

/obj/item/melee/mimesword/_examine_text(mob/user)
	. = ..()
	if(times_consumed)
		.+="\nIt has been sharpened [times_consumed] times."
	