/obj/item/weapon/reagent_containers/
	var/label = null
	var/labeled = 0
	var/needspoon = 0
	var/needfork = 0

/datum/reagent/poo
	name = "Compost"
	id = "poo"
	description = "Let's face it... it's poo."
	reagent_state = SOLID

/obj/item/weapon/seed/
	name = "plant seed"
	desc = "Plant this in soil to grow something."
	icon = 'hydromisc.dmi'
	w_class = 1.0
	var/planttype = null
	var/plantgenes = /datum/plantgenes
	var/isstrange = 0
	var/generation = 0
	var/radiation = 0

	New()
		..()
		src.plantgenes = new /datum/plantgenes(src)
		src.pixel_x = rand(-8, 8)
		src.pixel_y = rand(-8, 8)

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/plantanalyzer/))
			// PLANTANZ
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\blue [] uses the [] on [].", user, W, src), 1)
			if (src.isstrange || !src.planttype)
				user << "\red Cannot scan."
				return
			var/datum/plant/stored = src.planttype
			var/datum/plantgenes/DNA = src.plantgenes
			user << "\blue <B>Analysis of [src.name]:</B>"
			user << "<B>Species:</B> [stored.name]"
			user << "<B>Generation:</B> [src.generation]"
			user << ""
			user << "<B>Maturation Rate:</B> [DNA.growtime]"
			user << "<B>Production Rate:</B> [DNA.harvtime]"
			if (!stored.isgrass) user << "<B>Lifespan:</B> [DNA.harvests]"
			else user << "<B>Lifespan:</B> Limited"
			user << "<B>Yield:</B> [DNA.cropsize]"
			user << "<B>Potency:</B> [DNA.potency]"
			user << "<B>Endurance:</B> [DNA.endurance]"
			if (DNA.mutantvar && stored.mutable) user << "\red <B>ALERT:</B> Abnormal genetic patterns detected!"
			for (var/X in DNA.commuts)
				if (X == "immortal") user << "\red <B>ALERT:</B> Detected Immortality gene strain."
				if (X == "seedless") user << "\red <B>ALERT:</B> Detected Seedless gene strain."
		return

/obj/item/weapon/seed/tomato/
	name = "tomato seed"
	icon_state = "seed-w"
	New()
		..()
		src.planttype = new /datum/plant/tomato(src)

/obj/item/weapon/seed/orange/
	name = "orange seed"
	icon_state = "seed-w"
	New()
		..()
		src.planttype = new /datum/plant/orange(src)

/obj/item/weapon/seed/melon/
	name = "melon seed"
	icon_state = "seed-b"
	New()
		..()
		src.planttype = new /datum/plant/melon(src)

/obj/item/weapon/seed/grape/
	name = "grape seed"
	icon_state = "seed-w"
	planttype = /datum/plant/grape
	New()
		..()
		src.planttype = new /datum/plant/grape(src)

/obj/item/weapon/seed/chili/
	name = "chili seed"
	icon_state = "seed-w"
	planttype = /datum/plant/chili
	New()
		..()
		src.planttype = new /datum/plant/chili(src)

/obj/item/weapon/seed/wheat/
	name = "wheat seed"
	icon_state = "seed-br"
	New()
		..()
		src.planttype = new /datum/plant/wheat(src)
/obj/item/weapon/seed/synthmeat/
	name = "synthmeat seed"
	icon_state = "seed-b"
	New()
		..()
		src.planttype = new /datum/plant/synthmeat(src)

/obj/item/weapon/seed/apple/
	name = "apple seed"
	icon_state = "seed-br"
	New()
		..()
		src.planttype = new /datum/plant/apple(src)

/obj/item/weapon/seed/banana/
	name = "banana seed"
	icon_state = "seed-br"
	planttype = /datum/plant/banana
	New()
		..()
		src.planttype = new /datum/plant/banana(src)

/obj/item/weapon/seed/sugar/
	name = "sugarcane seed"
	icon_state = "seed-br"
	New()
		..()
		src.planttype = new /datum/plant/sugar(src)

/obj/item/weapon/seed/maneater/
	name = "strange seed"
	icon_state = "seed-w"
	New()
		..()
		src.planttype = new /datum/plant/maneater(src)

/obj/item/weapon/seed/contusine/
	name = "contusine seed"
	icon_state = "seed-b"
	New()
		..()
		src.planttype = new /datum/plant/contusine(src)

/obj/item/weapon/seed/nureous/
	name = "nureous seed"
	icon_state = "seed-b"
	New()
		..()
		src.planttype = new /datum/plant/nureous(src)

/obj/item/weapon/seed/asomna/
	name = "asomna seed"
	icon_state = "seed-br"
	New()
		..()
		src.planttype = new /datum/plant/asomna(src)

/obj/item/weapon/seed/commol/
	name = "commol seed"
	icon_state = "seed-w"
	New()
		..()
		src.planttype = new /datum/plant/commol(src)

/obj/item/weapon/seed/carrot/
	name = "carrot seed"
	icon_state = "seed-br"
	New()
		..()
		src.planttype = new /datum/plant/carrot(src)

/obj/item/weapon/seed/lettuce/
	name = "lettuce seed"
	icon_state = "seed-br"
	New()
		..()
		src.planttype = new /datum/plant/lettuce(src)

/obj/item/weapon/seed/lime/
	name = "lime seed"
	icon_state = "seed-w"
	New()
		..()
		src.planttype = new /datum/plant/lime(src)

/obj/item/weapon/seed/lemon/
	name = "lemon seed"
	icon_state = "seed-w"
	New()
		..()
		src.planttype = new /datum/plant/lemon(src)

/obj/item/weapon/seed/venne/
	name = "venne seed"
	icon_state = "seed-br"
	New()
		..()
		src.planttype = new /datum/plant/venne(src)

/obj/item/weapon/seed/potato/
	name = "potato seed"
	icon_state = "seed-br"
	New()
		..()
		src.planttype = new /datum/plant/potato(src)

/obj/item/weapon/seed/fungus/
	name = "fungus spore"
	icon_state = "seed-br"
	New()
		..()
		src.planttype = new /datum/plant/fungus(src)

/obj/item/weapon/seed/lasher/
	name = "lasher seed"
	icon_state = "seed-b"
	New()
		..()
		src.planttype = new /datum/plant/lasher(src)

/obj/item/weapon/seed/creeper/
	name = "creeper seed"
	icon_state = "seed-w"
	New()
		..()
		src.planttype = new /datum/plant/creeper(src)

/obj/item/weapon/seed/radweed/
	name = "radweed seed"
	icon_state = "seed-w"
	New()
		..()
		src.planttype = new /datum/plant/radweed(src)

/obj/item/weapon/seed/slurrypod/
	name = "slurrypod seed"
	icon_state = "seed-b"
	New()
		..()
		src.planttype = new /datum/plant/slurrypod(src)

/obj/item/weapon/seed/crystal/
	name = "crystal seed"
	icon_state = "seed-b"
	New()
		..()
		src.planttype = new /datum/plant/crystal(src)

/obj/item/weapon/seed/plasmabloom/
	name = "bio-plasma fragment"
	icon_state = "seed-b"
	New()
		..()
		src.planttype = new /datum/plant/plasmabloom(src)

/obj/item/weapon/seed/grass/
	name = "spacegrass seed"
	icon_state = "seed-b"
	New()
		..()
		src.planttype = new /datum/plant/grass(src)

/obj/item/weapon/reagent_containers/food/snacks/plant/
	name = "fruit or vegetable"
	var/planttype = null
	var/plantgenes = null
	edible = 1
	var/generation = 0

	New()
		..()
		src.plantgenes = new /datum/plantgenes(src)
		src.pixel_x = rand(-8, 8)
		src.pixel_y = rand(-8, 8)

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (src.edible == 0)
			if (user == M)
				user << "\red You can't just cram that in your mouth, you greedy beast!"
				for(var/mob/O in viewers(user, null))
					O.show_message(text("<b>[]</b> stares at [] in a confused manner.", user, src), 1)
				return
			else
				for(var/mob/O in viewers(user, null))
					O.show_message(text("\red <b>[]</b> futilely attempts to shove [] into []'s mouth!", user, src, M), 1)
				return
		..()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		// PLANTANZ
		if (istype(W, /obj/item/weapon/plantanalyzer/))
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\blue [] uses the [] on [].", user, W, src), 1)
			if (!src.planttype)
				user << "\red Cannot scan."
				return
			var/datum/plant/stored = src.planttype
			var/datum/plantgenes/DNA = src.plantgenes
			user << "\blue <B>Analysis of [src.name]:</B>"
			user << "<B>Species:</B> [stored.name]"
			user << "<B>Generation:</B> [src.generation]"
			user << ""
			user << "<B>Maturation Rate:</B> [DNA.growtime]"
			user << "<B>Production Rate:</B> [DNA.harvtime]"
			if (!stored.isgrass) user << "<B>Lifespan:</B> [DNA.harvests]"
			else user << "<B>Lifespan:</B> Limited"
			user << "<B>Yield:</B> [DNA.cropsize]"
			user << "<B>Potency:</B> [DNA.potency]"
			user << "<B>Endurance:</B> [DNA.endurance]"
			if (DNA.mutantvar && stored.mutable) user << "\red <B>ALERT:</B> Abnormal genetic patterns detected!"
			for (var/X in DNA.commuts)
				if (X == "immortal") user << "\red <B>ALERT:</B> Detected Immortality gene strain."
				if (X == "seedless") user << "\red <B>ALERT:</B> Detected Seedless gene strain."
		return

/obj/item/weapon/reagent_containers/food/snacks/plant/tomato/
	name = "tomato"
	desc = "You say tomato, I toolbox you."
	icon = 'hydroponics.dmi'
	icon_state = "tomato"
	amount = 1
	heal_amt = 2
	throwforce = 0
	force = 0
	New()
		..()
		src.planttype = new /datum/plant/tomato(src)

/obj/item/weapon/reagent_containers/food/snacks/plant/orange/
	name = "orange"
	desc = "Bitter."
	icon = 'hydroponics.dmi'
	icon_state = "orange"
	amount = 3
	heal_amt = 1
	New()
		..()
		src.planttype = new /datum/plant/orange(src)

/obj/item/weapon/reagent_containers/food/snacks/plant/grape/
	name = "grapes"
	desc = "Not the green ones."
	icon = 'hydroponics.dmi'
	icon_state = "grapes"
	amount = 5
	heal_amt = 1
	New()
		..()
		src.planttype = new /datum/plant/grape(src)

/obj/item/weapon/reagent_containers/food/snacks/plant/melon/
	name = "melon"
	desc = "You should cut it into slices first!"
	icon = 'hydroponics.dmi'
	icon_state = "melon"
	throwforce = 8
	w_class = 3.0
	edible = 0

	New()
		..()
		src.planttype = new /datum/plant/melon(src)

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/axe) || istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/kitchen/utensil/knife) || istype(W, /obj/item/weapon/scalpel) || istype(W, /obj/item/weapon/sword))
			for(var/mob/O in viewers(user, null)) O.show_message(text("[] cuts [] into slices.", user, src), 1)
			var/makeslices = 6
			while (makeslices > 0)
				var/obj/item/weapon/reagent_containers/food/snacks/plant/melonslice/P = new(usr.loc)
				var/datum/plantgenes/DNA = src.plantgenes
				var/datum/plantgenes/PDNA = P.plantgenes
				PDNA.growtime = DNA.growtime
				PDNA.harvtime = DNA.harvtime
				PDNA.harvests = DNA.harvests
				PDNA.cropsize = DNA.cropsize
				PDNA.potency = DNA.potency
				PDNA.endurance = DNA.endurance
				PDNA.mutantvar = DNA.mutantvar
				makeslices -= 1
			del src
		..()

/obj/item/weapon/reagent_containers/food/snacks/plant/melonslice/
	name = "melon slice"
	desc = "That's better!"
	icon = 'hydroponics.dmi'
	icon_state = "melon_slice"
	throwforce = 0
	w_class = 1.0
	amount = 1
	heal_amt = 2

	New()
		..()
		src.planttype = new /datum/plant/melon(src)

/obj/item/weapon/reagent_containers/food/snacks/plant/chili/
	name = "chili pepper"
	desc = "Caution: May or may not be red hot."
	icon = 'hydroponics.dmi'
	icon_state = "chili"
	w_class = 1.0
	amount = 1
	heal_amt = 2
	New()
		..()
		src.planttype = new /datum/plant/chili(src)
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.maximum_volume = 100
		R.my_atom = src
		var/datum/plantgenes/DNA = src.plantgenes
		R.add_reagent("capsaicin", DNA.potency)

/obj/item/weapon/reagent_containers/food/snacks/plant/lettuce/
	name = "lettuce leaf"
	desc = "Not spinach at all. Nope. Nuh-uh."
	icon = 'hydroponics.dmi'
	icon_state = "spinach"
	w_class = 1.0
	amount = 1
	heal_amt = 1

	New()
		..()
		src.planttype = new /datum/plant/lettuce(src)

/obj/item/weapon/reagent_containers/food/snacks/plant/apple/
	name = "apple"
	desc = "Implied by folklore to repel medical staff."
	icon = 'hydroponics.dmi'
	icon_state = "apple"
	amount = 1
	heal_amt = 2
	New()
		..()
		src.planttype = new /datum/plant/apple(src)

/obj/item/weapon/reagent_containers/food/snacks/plant/banana/
	name = "unpeeled banana"
	desc = "Cavendish, of course."
	icon = 'hydroponics.dmi'
	icon_state = "banana"
	amount = 2
	heal_amt = 2
	New()
		..()
		src.planttype = new /datum/plant/banana(src)
	heal(var/mob/M)
		if (src.icon_state == "banana")
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red [] eats the banana without peeling it. What a dumb beast!", M), 1)
			M.toxloss += 5 // banana peels are toxic!
			del src
	attack_self(var/mob/user as mob)
		if (src.icon_state == "banana")
			if(user.mutations & 16 && prob(50))
				for(var/mob/N in viewers(user, null))
					if(N.client)
						N.show_message(text("\red <B>[user] accidentally pokes their eye out with the banana."), 1)
				user.eye_blurry += 5
				user.weakened = max(3, user.weakened)
				return
			user << "\blue You peel the banana."
			src.name = "banana"
			src.icon_state = "banana-fruit"
			new /obj/item/weapon/bananapeel(user.loc)

/obj/item/weapon/reagent_containers/food/snacks/plant/carrot/
	name = "carrot"
	desc = "Think of how many snowmen were mutilated to power the carrot industry."
	icon = 'hydroponics.dmi'
	icon_state = "carrot"
	w_class = 1.0
	amount = 3
	heal_amt = 1
	New()
		..()
		src.planttype = new /datum/plant/carrot(src)

/obj/item/weapon/reagent_containers/food/snacks/plant/lime/
	name = "lime"
	desc = "A very sour green fruit."
	icon = 'hydroponics.dmi'
	icon_state = "lime"
	amount = 2
	heal_amt = 1
	New()
		..()
		src.planttype = new /datum/plant/lime(src)

/obj/item/weapon/reagent_containers/food/snacks/plant/lemon/
	name = "lemon"
	desc = "Suprisingly not a commentary on the station's workmanship."
	icon = 'hydroponics.dmi'
	icon_state = "lemon"
	amount = 2
	heal_amt = 1
	New()
		..()
		src.planttype = new /datum/plant/lime(src)

/obj/item/weapon/reagent_containers/food/snacks/plant/slurryfruit/
	name = "slurrypod"
	desc = "An extremely poisonous, bitter fruit.  The slurrypod fruit is regarded as a delicacy in some outer colony worlds."
	icon = 'hydroponics.dmi'
	icon_state = "slurry"
	amount = 1
	heal_amt = -1

	New()
		..()
		src.planttype = new /datum/plant/slurrypod(src)
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.maximum_volume = 50
		R.my_atom = src
		R.add_reagent("toxic_slurry", rand(10,50))

/obj/item/weapon/reagent_containers/food/snacks/plant/potato/
	name = "potato"
	desc = "It needs peeling first."
	icon = 'hydroponics.dmi'
	icon_state = "potato"
	amount = 1
	heal_amt = 1
	New()
		..()
		src.planttype = new /datum/plant/potato(src)

/obj/item/weapon/plant/
	name = "plant"
	desc = "You shouldn't be able to see this item ingame!"
	icon = 'hydromisc.dmi'
	var/potency = 0 // only used for the herbs

	New()
		..()
		src.pixel_x = rand(-8, 8)
		src.pixel_y = rand(-8, 8)

/obj/item/weapon/plant/wheat/
	name = "wheat"
	desc = "Never eat shredded wheat."
	icon = 'hydroponics.dmi'
	icon_state = "wheat"

/obj/item/weapon/plant/sugar/
	name = "sugar cane"
	desc = "Grown lovingly in our space plantations."
	icon = 'hydroponics.dmi'
	icon_state = "sugarcane"

/obj/item/weapon/plant/contusine
	name = "contusine herb leaves"
	desc = "The chemical Bicaridine can be extracted from these leaves."
	icon = 'hydroponics.dmi'
	icon_state = "contusine"
	potency = 8

/obj/item/weapon/plant/nureous
	name = "nureous herb leaves"
	desc = "The chemical Hyronalin can be extracted from these leaves."
	icon = 'hydroponics.dmi'
	icon_state = "nureous"
	potency = 8

/obj/item/weapon/plant/asomna
	name = "asomna herb leaves"
	desc = "The chemical Inaprovaline can be extracted from these leaves."
	icon = 'hydroponics.dmi'
	icon_state = "asomna"
	potency = 8

/obj/item/weapon/plant/commol
	name = "commol herb leaves"
	desc = "The chemical Kelotane can be extracted from these leaves."
	icon = 'hydroponics.dmi'
	icon_state = "commol"
	potency = 8

/obj/item/weapon/plant/venne
	name = "venne herb leaves"
	desc = "The chemical Dylovene can be extracted from these leaves."
	icon = 'hydroponics.dmi'
	icon_state = "venne"
	potency = 8