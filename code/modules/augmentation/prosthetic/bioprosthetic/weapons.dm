/obj/item/weapon/melee/prosthetic/bio/fake_arm_blade
	name = "arm blade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter."
	icon_state = "arm_blade"
	force = 1
	sharp = 0
	edge = 0
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/melee/prosthetic/bio/fake_arm_blade/remove_prosthetic()
	name = "fake arm blade"
	desc = "A grotesque blade made out of bone and flesh that can barely cut through flesh."
	..()
