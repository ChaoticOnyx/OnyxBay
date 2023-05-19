/obj/item/melee/prosthetic/bio/fake_arm_blade
	name = "arm blade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter."
	icon_state = "arm_blade"
	force = 5
	sharp = 0
	edge = 0
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/melee/prosthetic/bio/fake_arm_blade/dropped(mob/user)
	if(!canremove)
		playsound(user, 'sound/effects/blob/blobattack.ogg', 30, 1)
		remove_prosthetic()
	..()

/obj/item/melee/prosthetic/bio/fake_arm_blade/remove_prosthetic()
	name = "cut arm blade"
	desc = "A grotesque dull blade made out of bone and flesh that can barely cut anything."
	canremove = TRUE // Prevents it from sticking to outher people.
	..()
