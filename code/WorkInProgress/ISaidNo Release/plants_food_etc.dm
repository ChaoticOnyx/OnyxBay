// plants_food_etc.dm edited to remove other people's stuff

// Seeds


//Strumpetplaya's edits to get this shit to at least compile

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


//End Strumpetplaya's edits.

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

/obj/item/weapon/seed/cannabis/
	name = "cannabis seed"
	icon_state = "seed-br"
	New()
		..()
		src.planttype = new /datum/plant/cannabis(src)

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
/*	Strumpetplaya - commented out
/obj/item/weapon/seed/pumpkin/
	name = "pumpkin seed"
	icon_state = "seed-br"
	New()
		..()
		src.planttype = new /datum/plant/pumpkin(src)
*/
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

// Plants/Food

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
	heal_amt = 1
	throwforce = 0
	force = 0
	New()
		..()
		src.planttype = new /datum/plant/tomato(src)

/obj/item/weapon/reagent_containers/food/snacks/plant/tomato/explosive
	name = "tomato"
	desc = "You say tomato, I toolbox you."

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

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/ingredient/meat/synthmeat))
			user << "\blue You combine the [src] and [W] to create a Synthorange!"
			var/obj/item/weapon/reagent_containers/food/snacks/plant/orange/synth/P = new(usr.loc)
			var/datum/plantgenes/DNA = src.plantgenes
			var/datum/plantgenes/PDNA = P.plantgenes
			PDNA.growtime = DNA.growtime
			PDNA.harvtime = DNA.harvtime
			PDNA.harvests = DNA.harvests
			PDNA.cropsize = DNA.cropsize
			PDNA.potency = DNA.potency
			PDNA.endurance = DNA.endurance
			PDNA.mutantvar = DNA.mutantvar
			del W
			del src
		..()

/obj/item/weapon/reagent_containers/food/snacks/plant/orange/synth
	name = "synthorange"
	desc = "Bitter. Moreso."
	icon_state = "orange"
	amount = 3
	heal_amt = 2
	heal(var/mob/M)
		M.r_Tourette += 5

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
		if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/faggot))
			user << "\blue You combine the [src] and [W] to create a George Melon!"
			var/obj/item/weapon/reagent_containers/food/snacks/plant/melon/george/P = new(usr.loc)
			var/datum/plantgenes/DNA = src.plantgenes
			var/datum/plantgenes/PDNA = P.plantgenes
			PDNA.growtime = DNA.growtime
			PDNA.harvtime = DNA.harvtime
			PDNA.harvests = DNA.harvests
			PDNA.cropsize = DNA.cropsize
			PDNA.potency = DNA.potency
			PDNA.endurance = DNA.endurance
			PDNA.mutantvar = DNA.mutantvar
			del W
			del src
		else if (istype(W, /obj/item/weapon/axe) || istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/kitchen/utensil/knife) || istype(W, /obj/item/weapon/scalpel) || istype(W, /obj/item/weapon/sword))
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

/obj/item/weapon/reagent_containers/food/snacks/plant/melon/george
	name = "george melon"
	desc = "That treacherous fruit."
	icon_state = "george_melon"
	throwforce = 0
	w_class = 3.0
	edible = 0

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/axe) || istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/kitchen/utensil/knife) || istype(W, /obj/item/weapon/scalpel) || istype(W, /obj/item/weapon/sword))
			for(var/mob/O in viewers(user, null)) O.show_message(text("[] cuts [] into slices.", user, src), 1)
			var/makeslices = 6
			while (makeslices > 0)
				var/obj/item/weapon/reagent_containers/food/snacks/plant/melonslice/george/P = new(usr.loc)
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

/obj/item/weapon/reagent_containers/food/snacks/plant/melonslice/george
	name = "george melon slice"
	desc = "The most robust of all snacks."
	icon_state = "george_melon_slice"
	throwforce = 5
	w_class = 1.0
	amount = 1
	heal_amt = 2

	heal(var/mob/M)
		switch(rand(1,5))
			if(1)
				M << "\red What an explosive burst of flavor!"
				var/turf/T = get_turf(M.loc)
				explosion(T, -1, -1, 1, 1)
			if(2)
				M << "\red So juicy!"
				M.reagents.add_reagent(pick("capsaicin","psilocybin","LSD","THC","ethanol","poo","tricordrazine","hyperzine","impedrezene","mutagen","radium","acid","mercury","space_drugs","stoxin"), rand(10,40))
			if(3)
				M << "\blue How refreshing!"
				M.bruteloss -= 30
				M.fireloss -= 30
				M.toxloss -= 30
				M.oxyloss -= 30
				M.brainloss -= 30
			if(4)
				M << "\blue This flavor is out of this world!"
				M.reagents.add_reagent("space_drugs", 30)
				M.reagents.add_reagent("THC", 30)
				M.reagents.add_reagent("LSD", 30)
				M.reagents.add_reagent("psilocybin", 30)
			if(5)
				M << "\red What stunning texture!"
				M.paralysis += 5
				M.stunned += 10
				M.weakened += 10
				M.stuttering += 20

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

/obj/item/weapon/reagent_containers/food/snacks/plant/chili/chilly
	name = "chilly pepper"
	desc = "It's cold to the touch."
	icon = 'hydroponics.dmi'
	icon_state = "chilly"
	planttype = /datum/plant/chili
	w_class = 1.0
	amount = 1
	heal_amt = 2
	New()
		..()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.maximum_volume = 100
		R.my_atom = src
		var/datum/plantgenes/DNA = src.plantgenes
		R.add_reagent("cryostylane", DNA.potency)
	heal(var/mob/M)
		M:emote("shiver")
		var/datum/plantgenes/DNA = src.plantgenes
		M.bodytemperature -= DNA.potency
		M << "\red You feel cold!"

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
	amount = 3
	heal_amt = 1
	New()
		..()
		src.planttype = new /datum/plant/apple(src)
	heal(var/mob/M)
		M.bruteloss -= src.heal_amt
		M.fireloss -= src.heal_amt
		M.toxloss -= src.heal_amt
		M.oxyloss -= src.heal_amt
		M.brainloss -= src.heal_amt
/* Strumpetplaya - commenting this out as it has components we don't support.
	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W,/obj/item/weapon/rods))
			user << "\blue You create an apple on a stick..."
			new/obj/item/weapon/reagent_containers/food/snacks/plant/apple/stick(get_turf(src))
			W:amount--
			if(!W:amount) del(W)
			del(src)
		else ..()
*/
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
/* Strumpetplaya - commenting this out as it has components we don't support.
/obj/item/weapon/reagent_containers/food/snacks/plant/pumpkin/
	name = "pumpkin"
	desc = "Spooky!"
	icon_state = "pumpkin"
	edible = 0
	New()
		..()
		src.planttype = new /datum/plant/pumpkin(src)
	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/axe) || istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/kitchen/utensil/knife) || istype(W, /obj/item/weapon/scalpel) || istype(W, /obj/item/weapon/sword))
			for(var/mob/O in viewers(user, null))
				O.show_message(text("[] carefully and creatively carves [].", user, src), 1)
			new /obj/item/clothing/head/pumpkin(user.loc)
			del src
*/
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

/obj/item/weapon/reagent_containers/food/snacks/plant/slurryfruit/omega
	name = "omega slurrypod"
	desc = "An extremely poisonous, bitter fruit.  A strange light pulses from within."
	icon = 'hydroponics.dmi'
	icon_state = "slurrymut"
	amount = 1
	heal_amt = -1

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.maximum_volume = 50
		R.my_atom = src
		R.add_reagent("toxic_slurry", rand(30,60))
		if(prob(3))
			R.add_reagent("necrovirus",5)

/obj/item/weapon/reagent_containers/food/snacks/plant/potato/
	name = "potato"
	desc = "It needs peeling first."
	icon = 'hydroponics.dmi'
	icon_state = "potato"
	amount = 1
	heal_amt = 0
	New()
		..()
		src.planttype = new /datum/plant/potato(src)
	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/kitchen/utensil/knife))
			if (src.icon_state == "potato")
				for(var/mob/O in viewers(user, null))
					O.show_message(text("[] peels [].", user, src), 1)
				src.icon_state = "potato-peeled"
				src.desc = "It needs to be cooked."
			else if (src.icon_state == "potato-peeled")
				for(var/mob/O in viewers(user, null))
					O.show_message(text("[] chops up [].", user, src), 1)
				new /obj/item/weapon/reagent_containers/food/snacks/ingredient/chips(get_turf(src))
				del src
		else ..()

	heal(var/mob/M)
		M << "\red Raw potato tastes pretty nasty..."

// Inedible Produce

/obj/item/weapon/plant/
	name = "plant"
	desc = "You shouldn't be able to see this item ingame!"
	icon = 'hydromisc.dmi'
	var/potency = 0 // only used for the herbs

	New()
		..()
		src.pixel_x = rand(-8, 8)
		src.pixel_y = rand(-8, 8)

/obj/item/weapon/plant/cannabis/
	name = "cannabis leaf"
	desc = "Leafs for reefin'!"
	icon = 'hydromisc.dmi'
	icon_state = "cannabisleaf"
	potency = 1

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/paper/))
			user << "\red You roll up the leaf into the paper."
			var/obj/item/clothing/mask/cigarette/weed/P = new(user.loc)
			P.name = pick("joint","doobie","spliff","roach","blunt","roll","fatty","reefer")
			del W
			del src

/obj/item/weapon/plant/cannabis/mega
	name = "cannabis leaf"
	desc = "Is it supposed to be glowing like that...?"
	icon_state = "megaweedleaf"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/paper/))
			user << "\red You roll up the leaf into the paper."
			var/obj/item/clothing/mask/cigarette/weed/mega/P = new(user.loc)
			P.name = pick("joint","doobie","spliff","roach","blunt","roll","fatty","reefer")
			del W
			del src

/obj/item/weapon/plant/cannabis/black
	name = "cannabis leaf"
	desc = "Looks a bit dark. Oh well."
	icon_state = "blackweedleaf"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/paper/))
			user << "\red You roll up the leaf into the paper."
			var/obj/item/clothing/mask/cigarette/weed/black/P = new(user.loc)
			P.name = pick("joint","doobie","spliff","roach","blunt","roll","fatty","reefer")
			del W
			del src

/obj/item/weapon/plant/cannabis/white
	name = "cannabis leaf"
	desc = "It feels smooth and nice to the touch."
	icon_state = "whiteweedleaf"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/paper/))
			user << "\red You roll up the leaf into the paper."
			var/obj/item/clothing/mask/cigarette/weed/white/P = new(user.loc)
			P.name = pick("joint","doobie","spliff","roach","blunt","roll","fatty","reefer")
			del W
			del src

/obj/item/weapon/plant/wheat/
	name = "wheat"
	desc = "Never eat shredded wheat."
	icon = 'hydroponics.dmi'
	icon_state = "wheat"

/obj/item/weapon/plant/wheat/metal
	name = "steelwheat"
	desc = "Never eat iron filings."
	icon_state = "metalwheat"

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

// Ingredients

/obj/item/weapon/reagent_containers/food/snacks/ingredient/
	name = "ingredient"
	desc = "you shouldnt be able to see this"
	amount = 1
	heal_amt = 0

/obj/item/weapon/reagent_containers/food/snacks/ingredient/meat/
	name = "raw meat"
	desc = "you shouldnt be able to see this either!!"
	amount = 1
	heal_amt = 0

	heal(var/mob/M)
		if (prob(33)) M << "\red You briefly think you probably shouldn't be eating raw meat."
		/* Strumpetplaya - commenting this out as it has components we don't support.
		if (prob(33)) M.contract_disease(new /datum/ailment/disease/food_poisoning, 1)
		*/
/obj/item/weapon/reagent_containers/food/snacks/ingredient/meat/humanmeat
	name = "-meat"
	desc = "A slab of meat."
	icon_state = "meat"
	var/subjectname = ""
	var/subjectjob = null
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	name = "monkeymeat"
	desc = "A slab of meat from a monkey."
	icon_state = "meat"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/ingredient/meat/synthmeat
	name = "synthmeat"
	desc = "Synthetic meat grown in hydroponics."
	icon_state = "meat"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/ingredient/meat/mysterymeat
	name = "mystery meat"
	desc = "What the fuck is this??"
	icon_state = "mysterymeat"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/ingredient/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"

/obj/item/weapon/reagent_containers/food/snacks/ingredient/flour
	name = "flour"
	desc = "Some flour"
	icon_state = "flour"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/ingredient/sugar
	name = "sugar"
	desc = "How sweet."
	icon_state = "sugar"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/ingredient/cheese
	name = "cheese"
	desc = "Some kind of curdled milk product."
	icon_state = "cheese"
	amount = 2
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/ingredient/gcheese
	name = "weird cheese"
	desc = "Some kind of... gooey, messy, gloopy thing. Similar to cheese, but only in the looser sense of the word."
	icon_state = "gcheese"
	amount = 2
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.my_atom = src
		R.add_reagent("mercury", 5)
		R.add_reagent("LSD", 5)
		R.add_reagent("ethanol", 5)
/* Strumpetplaya - commenting this out as it has components we don't support.
/obj/item/weapon/reagent_containers/food/snacks/ingredient/dough
	name = "dough"
	desc = "Used for making bready things."
	icon_state = "dough"
	amount = 1

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/ingredient/sugar))
			user << "\blue You add [W] to [src] to make sweet dough!"
			new /obj/item/weapon/reagent_containers/food/snacks/ingredient/dough_s(get_turf(src))
			del W
			del src
		else if (istype(W, /obj/item/weapon/kitchen/rollingpin))
			user << "\blue You flatten out the dough."
			new /obj/item/weapon/reagent_containers/food/snacks/ingredient/pizza1(get_turf(src))
			del src
		else ..()

/obj/item/weapon/reagent_containers/food/snacks/ingredient/dough_s
	name = "sweet dough"
	desc = "Used for making cakey things."
	icon_state = "dough_s"
	amount = 1

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/axe) || istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/kitchen/utensil/knife) || istype(W, /obj/item/weapon/scalpel) || istype(W, /obj/item/weapon/sword))
			user << "\blue You cut [src] into smaller pieces..."
			for(var/i = 1, i <= 4, i++)
				new /obj/item/weapon/reagent_containers/food/snacks/ingredient/dough_cookie(get_turf(src))
			del(src)
		else ..()

/obj/item/weapon/reagent_containers/food/snacks/ingredient/pizza1
	name = "unfinished pizza base"
	desc = "You need to add tomatoes..."
	icon_state = "pizzabase"
	amount = 1

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/condiment/ketchup) || istype(W, /obj/item/weapon/reagent_containers/food/snacks/plant/tomato))
			user << "\blue You add [W] to [src]."
			new /obj/item/weapon/reagent_containers/food/snacks/ingredient/pizza2(get_turf(src))
			del W
			del src
		else if (istype(W, /obj/item/weapon/axe) || istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/kitchen/utensil/knife) || istype(W, /obj/item/weapon/scalpel) || istype(W, /obj/item/weapon/sword))
			user << "\blue You cut [src] into smaller pieces..."
			for(var/i = 1, i <= 3, i++)
				new /obj/item/weapon/reagent_containers/food/snacks/ingredient/tortilla(get_turf(src))
			del(src)
		else ..()

	attack_self(var/mob/user as mob)
		user << "\blue You knead the [src] back into a blob."
		new /obj/item/weapon/reagent_containers/food/snacks/ingredient/dough(get_turf(src))
		del src
*/
/obj/item/weapon/reagent_containers/food/snacks/ingredient/pizza2
	name = "half-finished pizza base"
	desc = "You need to add cheese..."
	icon_state = "pizzabase2"
	amount = 1

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/ingredient/cheese))
			user << "\blue You add [W] to [src]."
			new /obj/item/weapon/reagent_containers/food/snacks/ingredient/pizza3(get_turf(src))
			del W
			del src
		else ..()

/obj/item/weapon/reagent_containers/food/snacks/ingredient/pizza3
	name = "pizza base"
	desc = "It's ready to be cooked!"
	icon_state = "pizzabase3"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/ingredient/chips
	name = "uncooked chips"
	desc = "Cook them up into some nice fries."
	icon_state = "pchips"
	amount = 6
	heal_amt = 0

	heal(var/mob/M)
		M << "\red Raw potato tastes pretty nasty..."

/obj/item/weapon/reagent_containers/food/snacks/soup
	name = "soup"
	desc = "A soup of indeterminable type."
	icon_state = "gruel"
	needspoon = 1
	amount = 6
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/soup/tomato
	name = "tomato soup"
	desc = "A rich and creamy soup made from tomatoes."
	icon_state = "tomsoup"
	needspoon = 1
	amount = 6
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/soup/chili
	name = "chili con carne"
	desc = "Meat pieces in a spicy pepper sauce. Delicious."
	icon_state = "tomsoup"
	needspoon = 1
	amount = 6
	heal_amt = 2

	New()
		..()
		reagents.add_reagent("capsaicin", 20)

/obj/item/weapon/reagent_containers/food/snacks/soup/queso
	name = "chili con queso"
	desc = "Spicy mexican cheese stuff."
	icon_state = "custard"
	needspoon = 1
	amount = 6
	heal_amt = 2

	New()
		..()
		reagents.add_reagent("capsaicin", 10)

/obj/item/weapon/reagent_containers/food/snacks/soup/superchili
	name = "chili con flagration"
	desc = "God damn. This stuff smells strong."
	icon_state = "tomsoup"
	needspoon = 1
	amount = 6
	heal_amt = 2

	New()
		..()
		reagents.add_reagent("capsaicin", 50)

/obj/item/weapon/reagent_containers/food/snacks/soup/ultrachili
	name = "El Diablo"
	desc = "You feel overheated just looking at this dish."
	icon_state = "hotchili"
	needspoon = 1
	amount = 2
	heal_amt = 6

	New()
		..()
		reagents.add_reagent("capsaicin", 150)

	heal(var/mob/M)
		if (prob(20))
			if(istype(M, /mob/living/carbon))
				var/mob/living/carbon/H = M
				H << "\red Oh christ too hot!!!!"
				/* Strumpetplaya - commenting this out as it has components we don't support.
				H.burning += 25
				*/
		..()

/obj/item/weapon/reagent_containers/food/snacks/soup/gruel
	name = "gruel"
	desc = "Asking if you can have more is probably ill-advised."
	icon_state = "gruel"
	needspoon = 1
	amount = 6
	heal_amt = 0

	heal(var/mob/M)
		if (prob(15)) M << "\red You feel depressed."

/obj/item/weapon/reagent_containers/food/snacks/salad
	name = "salad"
	desc = "A meal of mostly plants. Good for healthy eating."
	icon_state = "salad"
	needfork = 1
	amount = 4
	heal_amt = 2

	heal(var/mob/M)
		if (istype(M, /mob/living/carbon/human))
			if (M.nutrition > 200) M.nutrition -= 30

// Condiments

/obj/item/weapon/reagent_containers/food/snacks/condiment/ironfilings
	name = "iron filings"
	desc = "You probably shouldn't eat these."
	icon_state = "ironfilings"
	heal_amt = 0
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/condiment
	name = "condiment"
	desc = "you shouldnt be able to see this"
	amount = 1
	heal_amt = 0
	heal(var/mob/M)
		M << "\red It's just not good enough on its own..."
	afterattack(atom/target, mob/user, flag)
		if (istype(target, /obj/item/weapon/reagent_containers/food/snacks/))
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\blue [] adds [] to [].", user, src, target), 1)
			del src
		else return

/obj/item/weapon/reagent_containers/food/snacks/condiment/ketchup
	name = "ketchup"
	desc = "Pureéd tomatoes as a sauce."
	icon_state = "ketchup"
	New()
		..()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		R.add_reagent("juice_tomato", 20)

	afterattack(atom/target, mob/user, flag)
		if (istype(target, /obj/item/weapon/reagent_containers/food/snacks/))
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\blue [] adds [] to [].", user, src, target), 1)
			src.reagents.trans_to(target, 100)
			del src
		else return

/obj/item/weapon/reagent_containers/food/snacks/condiment/mayo
	name = "mayonnaise"
	desc = "The subject of many a tiresome innuendo."
	icon_state = "cookie_light"

/obj/item/weapon/reagent_containers/food/snacks/condiment/hotsauce
	name = "hot sauce"
	desc = "Dangerously spicy!"
	icon_state = "hot_sauce"
	New()
		..()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.maximum_volume = 100
		R.my_atom = src

	afterattack(atom/target, mob/user, flag)
		if (istype(target, /obj/item/weapon/reagent_containers/food/snacks/))
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\blue [] adds [] to [].", user, src, target), 1)
			src.reagents.trans_to(target, 100)
			del src
		else return

/obj/item/weapon/reagent_containers/food/snacks/condiment/coldsauce
	name = "cold sauce"
	desc = "This isn't very hot at all!"
	icon_state = "cold_sauce"
	New()
		..()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.maximum_volume = 100
		R.my_atom = src

	afterattack(atom/target, mob/user, flag)
		if (istype(target, /obj/item/weapon/reagent_containers/food/snacks/))
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\blue [] adds [] to [].", user, src, target), 1)
			src.reagents.trans_to(target, 100)
			del src
		else return

/obj/item/weapon/reagent_containers/food/snacks/condiment/cream
	name = "cream"
	desc = "Not related to any kind of crop."
	icon_state = "cookie_light"

/obj/item/weapon/reagent_containers/food/snacks/condiment/custard
	name = "custard"
	desc = "A perennial favourite of clowns."
	icon_state = "custard"
	needspoon = 1
	amount = 2
	heal_amt = 3

// Food

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles"
	icon_state = "waffles"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/faggot
	name = "meatball"
	desc = "A great meal all round."
	icon_state = "faggot"
	amount = 1
	heal_amt = 2

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/condiment/)) src.amount += 1

/obj/item/weapon/reagent_containers/food/snacks/swedishmeatball
	name = "swedish meatballs"
	desc = "It's even got a little rice-paper swedish flag in it. How cute."
	icon_state = "swede_mball"
	needfork = 1
	amount = 6
	heal_amt = 2

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/condiment/)) src.amount += 1
/* Strumpetplaya - commenting this out as it has components we don't support.
	heal(var/mob/M)
		M.give_power(new /datum/power/accent_swedish, 180)
		..()
*/
/obj/item/weapon/reagent_containers/food/snacks/burger/
	name = "burger"
	desc = "A burger."
	icon_state = "burger"
	amount = 5
	heal_amt = 2

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/condiment/)) src.amount += 1

/obj/item/weapon/reagent_containers/food/snacks/burger/assburger
	name = "assburger"
	desc = "This burger gives off an air of awkwardness."
	icon_state = "assburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	New()
		var/datum/reagents/R = new/datum/reagents(5)
		reagents = R
		R.my_atom = src
		R.add_reagent("prions", 5)

/obj/item/weapon/reagent_containers/food/snacks/burger/humanburger
	name = "burger"
	var/hname = ""
	var/job = null
	desc = "A bloody burger."
	icon_state = "burger"
	heal(var/mob/M)
		if(src.job == "Clown")
			M.unlock_medal("That Tasted Funny", 1)
		..()

/obj/item/weapon/reagent_containers/food/snacks/burger/monkeyburger
	name = "monkeyburger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "burger"

/obj/item/weapon/reagent_containers/food/snacks/burger/fishburger
	name = "Fish-Fil-A"
	desc = "A delicious alternative to heart-grinding beef patties."
	icon_state = "burger"

/obj/item/weapon/reagent_containers/food/snacks/burger/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	amount = 3
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(5)
		reagents = R
		R.my_atom = src
		R.add_reagent("nanites", 5)

/obj/item/weapon/reagent_containers/food/snacks/burger/synthburger
	name = "burger"
	desc = "A thoroughly artificial snack."
	icon_state = "mburger"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/burger/mysteryburger
	name = "dubious burger"
	desc = "A burger of indeterminate meat type."
	icon_state = "brainburger"
	amount = 5
	heal_amt = 1

	heal(var/mob/M)
		if(prob(8))
			var/effect = rand(1,4)
			switch(effect)
				if(1)
					M << "\red Ugh. Tasted all greasy and gristly."
					M.nutrition += 20
				if(2)
					M << "\red Good grief, that tasted awful!"
					M.toxloss += 2
				if(3)
					M << "\red There was a cyst in that burger. Now your mouth is full of pus OH JESUS THATS DISGUSTING OH FUCK"
					M.nutrition -= 20
					for(var/mob/O in viewers(M, null)) O.show_message(text("\red [] suddenly and violently vomits!", M), 1)
					playsound(M.loc, 'splat.ogg', 50, 1)
					new /obj/decal/cleanable/vomit(M.loc)
				if(4)
					M << "\red You bite down on a chunk of bone, hurting your teeth."
					M.bruteloss += 2
		..()

/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	heal_amt = 1
	New()
		..()
		if(rand(1,3) == 1)
			src.icon_state = "donut2"
			src.name = "frosted donut"
			src.heal_amt = 2
	heal(var/mob/M)
		if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Forensic Technician"))
			src.heal_amt *= 2
			..()
			src.heal_amt /= 2

/obj/item/weapon/reagent_containers/food/snacks/mushroom
	name = "space mushroom"
	desc = "A mushroom cap of Space Fungus. Probably tastes pretty bad."
	icon_state = "mushroom"
	amount = 1
	heal_amt = 0
	heal(var/mob/M)
		var/ranchance = rand(1,10)
		if (ranchance == 1)
			M << "\red You feel very sick."
			M.reagents.add_reagent("cyanide", rand(1,5))
		else if (ranchance <= 5 && ranchance != 1)
			M << "\red That tasted absolutely FOUL."
			/* Strumpetplaya - commenting this out as it has components we don't support.
			M.contract_disease(new /datum/ailment/disease/food_poisoning, 1)
			*/
		else M << "\red Yuck!"

/obj/item/weapon/reagent_containers/food/snacks/mushroom/amanita
	name = "space mushroom"
	desc = "A mushroom cap of Space Fungus. This one is quite different."
	icon_state = "mushroom-M1"
	amount = 1
	heal_amt = 3
	New()
		..()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.maximum_volume = 50
		R.my_atom = src
		R.add_reagent("amanitin", rand(5,50))

/obj/item/weapon/reagent_containers/food/snacks/mushroom/psilocybin
	name = "space mushroom"
	desc = "A mushroom cap of Space Fungus. It's slightly more vibrant than usual."
	icon_state = "mushroom-M2"
	amount = 1
	heal_amt = 1
	New()
		..()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.maximum_volume = 50
		R.my_atom = src
		R.add_reagent("psylocybin", rand(5,50))

// Foods

/obj/item/weapon/reagent_containers/food/snacks/sandwich/meat_h
	name = "manwich"
	desc = "Human meat between two loaves of bread."
	icon_state = "sandwich_m"
	amount = 4
	heal_amt = 2
	var/hname = null
	var/job = null

/obj/item/weapon/reagent_containers/food/snacks/sandwich/meat_m
	name = "monkey sandwich"
	desc = "Meat between two loaves of bread."
	icon_state = "sandwich_m"
	amount = 4
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/sandwich/meat_s
	name = "synthmeat sandwich"
	desc = "Synthetic meat between two loaves of bread."
	icon_state = "sandwich_m"
	amount = 4
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/sandwich/cheese
	name = "cheese sandwich"
	desc = "Cheese between two loaves of bread."
	icon_state = "sandwich_c"
	amount = 4
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/pizza/
	name = "plain pizza"
	desc = "A plain cheese and tomato pizza."
	icon_state = "pizza_p"
	amount = 6
	heal_amt = 3
	var/sliced = 0
	var/slice_icon = "pslice"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/axe) || istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/kitchen/utensil/knife) || istype(W, /obj/item/weapon/scalpel) || istype(W, /obj/item/weapon/sword))
			if (src.sliced == 1)
				user << "\red This has already been sliced."
				return
			user << "\blue You cut the pizza into slices."
			var/makeslices = src.amount
			while (makeslices > 0)
				var/obj/item/weapon/reagent_containers/food/snacks/pizza/P = new src.type(get_turf(src))
				P.sliced = 1
				P.amount = 1
				P.icon_state = src.slice_icon
				P.pixel_x = rand(-6, 6)
				P.pixel_y = rand(-6, 6)
				makeslices--
			del src

/obj/item/weapon/reagent_containers/food/snacks/pizza/meat
	name = "meat pizza"
	desc = "Delightful meat toppings!"
	icon_state = "pizza_m"
	amount = 6
	heal_amt = 4
	slice_icon = "psliceM"

/obj/item/weapon/reagent_containers/food/snacks/pizza/fung/
	name = "mushroom pizza"
	desc = "A pizza topped with some mushrooms."
	icon_state = "pizza_v"
	amount = 6
	heal_amt = 4
	slice_icon = "psliceV"

/obj/item/weapon/reagent_containers/food/snacks/pizza/fung/psilocybin
	name = "mushroom pizza"
	desc = "A pizza topped with some mushrooms."
	icon_state = "pizza_v"
	amount = 6
	heal_amt = 4

	New()
		var/datum/reagents/R = new/datum/reagents(60)
		reagents = R
		R.my_atom = src
		R.add_reagent("psilocybin", 20)
		R.add_reagent("LSD", 20)
		R.add_reagent("space_drugs", 20)

/obj/item/weapon/reagent_containers/food/snacks/pizza/fung/amanita
	name = "mushroom pizza"
	desc = "A pizza topped with some mushrooms."
	icon_state = "pizza_v"
	amount = 6
	heal_amt = 4

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("amanitin", 30)

/obj/item/weapon/reagent_containers/food/snacks/breadloaf
	name = "loaf of bread"
	desc = "I'm loafin' it!"
	icon_state = "breadloaf"
	amount = 1
	heal_amt = 1

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (user == M)
			user << "\red You can't just cram that in your mouth, you greedy beast!"
			for(var/mob/O in viewers(user, null))
				O.show_message(text("<b>[]</b> stares at [] in a confused manner.", user, src), 1)
			return
		else
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red <b>[]</b> futilely attempts to shove [] into []'s mouth!", user, src, M), 1)
			return

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/axe) || istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/kitchen/utensil/knife) || istype(W, /obj/item/weapon/scalpel) || istype(W, /obj/item/weapon/sword))
			for(var/mob/O in viewers(user, null))
				O.show_message(text("[] cuts [] into slices.", user, src), 1)
			var/makeslices = 6
			while (makeslices > 0)
				new/obj/item/weapon/reagent_containers/food/snacks/breadslice(usr.loc)
				makeslices -= 1
			del src
		else ..()

/obj/item/weapon/reagent_containers/food/snacks/breadslice
	name = "slice of bread"
	desc = "That's slice."
	icon_state = "breadslice"
	amount = 1
	heal_amt = 1

	New()
		..()
		src.pixel_x += rand(-3,3)
		src.pixel_y += rand(-3,3)

/obj/item/weapon/reagent_containers/food/snacks/toastslice
	name = "slice of toast"
	desc = "Crispy cooked bread."
	icon_state = "toast"
	amount = 2
	heal_amt = 1

	New()
		..()
		src.pixel_x += rand(-3,3)
		src.pixel_y += rand(-3,3)

/obj/item/weapon/reagent_containers/food/snacks/toastcheese
	name = "cheese on toast"
	desc = "A quick cheesy snack."
	icon_state = "cheesetoast"
	amount = 2
	heal_amt = 2

	New()
		..()
		src.pixel_x += rand(-3,3)
		src.pixel_y += rand(-3,3)

/obj/item/weapon/reagent_containers/food/snacks/burger/cheeseburger
	name = "cheeseburger"
	desc = "Tasty, but not paticularly healthy."
	icon_state = "cheeseburger"
	amount = 6
	heal_amt = 2
/* Strumpetplaya - commenting this out as it has components we don't support.
/obj/item/weapon/reagent_containers/food/snacks/burger/cheeseburger_m
	name = "monkey cheese burger"
	desc = "How very dadaist."
	icon_state = "cheeseburger"
	amount = 6
	heal_amt = 2

	heal(var/mob/M)
		if(prob(3) && ishuman(M))
			M <<"\red You wackily and randomly turn into a lizard."
			M:mutantrace = new /datum/mutantrace/lizard(M)
			return
		if(prob(3))
			M <<"\red You wackily and randomly turn into a monkey."
			M:monkeyize()
			return

/obj/item/weapon/reagent_containers/food/snacks/burger/bigburger
	name = "Coronator"
	desc = "The king of burgers. You can feel your digestive system shutting down just LOOKING at it."
	icon_state = "bigburger"
	amount = 10
	heal_amt = 5

	heal(var/mob/M)
		M.nutrition += 50
		if (prob(33)) M.contract_disease(new /datum/ailment/disease/gastric_ejections, 1)
		if (prob(8))
			spawn(600)
				if (prob(75)) M << "\red You feel kind of sick..."
				spawn(300)
					M << "\red You are crippled by a horrible pain in your chest!"
					M.emote("choke")
					for(var/mob/O in viewers(M, null))
						O.show_message(text("<b>[]</b> grasps their chest and collapses!", M), 1)
					M.paralysis += 60
					M.weakened += 80
					M.stunned += 80
					M.stuttering += 120
					M.bruteloss += 40

/obj/item/weapon/reagent_containers/food/snacks/burger/monsterburger
	name = "THE MONSTER"
	desc = "There are no words to describe the sheer unhealthiness of this abomination."
	icon_state = "giantburger"
	amount = 1
	heal_amt = 50
	throwforce = 10

	heal(var/mob/M)
		M.nutrition += 50
		if (prob(66)) M.contract_disease(new /datum/ailment/disease/gastric_ejections, 1)
		if (prob(99))
			spawn(600)
				if (prob(75)) M << "\red You feel kind of sick..."
				spawn(300)
					M << "\red You are crippled by a horrible pain in your chest!"
					M.emote("choke")
					for(var/mob/O in viewers(M, null))
						O.show_message(text("<b>[]</b> grasps their chest and collapses!", M), 1)
					M.paralysis += 60
					M.weakened += 80
					M.stunned += 80
					M.stuttering += 120
					M.bruteloss += 40
*/
/obj/item/weapon/reagent_containers/food/snacks/fries
	name = "fries"
	desc = "Lightly salted potato fingers."
	icon_state = "fries"
	amount = 6
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/steak_h
	name = "steak"
	desc = "Made of people."
	icon_state = "steak"
	amount = 2
	heal_amt = 3
	var/hname = null
	var/job = null

/obj/item/weapon/reagent_containers/food/snacks/steak_m
	name = "monkey steak"
	desc = "You'll go bananas for it."
	icon_state = "steak"
	amount = 2
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/steak_s
	name = "synth-steak"
	desc = "And they thought processed food was artificial..."
	icon_state = "steak"
	amount = 2
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/bakedpotato
	name = "baked potato"
	desc = "Would go good with some cheese or steak."
	icon_state = "bakedpotato"
	amount = 6
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/pie/
	name = "pie"
	desc = "A null pie. You shouldn't be able to see this!"
	needspoon = 1
	var/splat = 0 // for thrown pies

/obj/item/weapon/reagent_containers/food/snacks/pie/custard
	name = "custard pie"
	desc = "It smells delicious. You just want to plant your face in it."
	icon_state = "pie"
	splat = 1
	needspoon = 1
	amount = 3
	throwforce = 0
	force = 0

/obj/item/weapon/reagent_containers/food/snacks/pie/apple
	name = "apple pie"
	desc = "It smells delicious."
	icon_state = "pie"
	amount = 3
	heal_amt = 4

/obj/item/weapon/reagent_containers/food/snacks/pie/pumpkin
	name = "pumpkin pie"
	desc = "An autumn favourite."
	icon_state = "pumpie"
	amount = 3
	heal_amt = 4

/obj/item/weapon/reagent_containers/food/snacks/pie/cream
	name = "cream pie"
	desc = "More often used in pranks than culinary matters..."
	icon_state = "creampie"
	splat = 1
	needspoon = 1
	throwforce = 0
	force = 0
	amount = 2
	heal_amt = 6

/obj/item/weapon/reagent_containers/food/snacks/pie/ass
	name = "asspie"
	desc = "Awkward."
	icon_state = "asspie"
	splat = 1
	throwforce = 0
	force = 0
	amount = 3
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/yoghurt/
	name = "yoghurt"
	desc = "A plain yoghurt."
	icon_state = "yoghurt"
	needspoon = 1
	amount = 6
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/yoghurt/frozen
	name = "frozen yoghurt"
	desc = "A delightful tub of frozen yoghurt."
	heal_amt = 2

	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		R.add_reagent("cryostylane", 20)

// Bad food

/obj/item/weapon/reagent_containers/food/snacks/yuck
	name = "?????"
	desc = "How the hell did they manage to cook this abomination..?!"
	icon_state = "yuck"
	amount = 1
	heal_amt = 0

	heal(var/mob/M)
		M << "\red Ugh! Eating that was a terrible idea!"
		M.stunned += 2
		M.weakened += 2
		/* Strumpetplaya - commenting this out as it has components we don't support.
		M.contract_disease(new /datum/ailment/disease/food_poisoning, 1)
		*/

/obj/item/weapon/reagent_containers/food/snacks/yuckburn
	name = "smoldering mess"
	desc = "This looks more like charcoal than food..."
	icon_state = "burnt"
	amount = 1
	heal_amt = 0

	heal(var/mob/M)
		M << "\red Ugh! Eating that was a terrible idea!"
		M.stunned += 2
		M.weakened += 2
		/* Strumpetplaya - commenting this out as it has components we don't support.
		M.contract_disease(new /datum/ailment/disease/food_poisoning, 1)
		*/
// Misc Shit

/obj/item/clothing/mask/cigarette/weed/
	name = "joint"
	desc = "420 smoke weed errday"

	New()
		var/datum/reagents/R = new/datum/reagents(600)
		reagents = R
		R.my_atom = src
		R.add_reagent("space_drugs", 300)
		//R.add_reagent("THC", 300)

/obj/item/clothing/mask/cigarette/weed/mega
	name = "joint"
	desc = "This thing smells weird even unlit."

	New()
		var/datum/reagents/R = new/datum/reagents(600)
		reagents = R
		R.my_atom = src
		R.add_reagent("space_drugs", 300)
		//R.add_reagent("LSD", 300)

/obj/item/clothing/mask/cigarette/weed/black
	name = "joint"
	desc = "There's a really strong odor coming from this..."

	New()
		var/datum/reagents/R = new/datum/reagents(600)
		reagents = R
		R.my_atom = src
		R.add_reagent("cyanide", 300)

/obj/item/clothing/mask/cigarette/weed/white
	name = "joint"
	desc = "It has an unusual minty scent."

	New()
		var/datum/reagents/R = new/datum/reagents(600)
		reagents = R
		R.my_atom = src
		R.add_reagent("THC", 100)
		R.add_reagent("bicaridine", 25)
		R.add_reagent("kelotane", 25)
		R.add_reagent("anti_toxin", 25)
		R.add_reagent("hyronalin", 25)
/* Strumpetplaya - commenting this out as it has components we don't support.
/obj/item/clothing/head/pumpkin
	name = "carved pumpkin"
	desc = "Spookier!"
	icon_state = "pumpkin"
	flags = FPRINT | TABLEPASS | HEADSPACE | HEADCOVERSEYES | HEADCOVERSMOUTH
	see_face = 0.0
	item_state = "pumpkin"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/device/flashlight))
			for(var/mob/O in viewers(user, null)) O.show_message(text("[] adds [] to [].", user, W, src), 1)
			W.name = "pumpkin lantern"
			W.desc = "Spookiest!"
			W.icon = 'halloween.dmi'
			W.icon_state = "flight[W:on]"
			W.item_state = "pumpkin"
			del src
*/
// Drinks

/obj/item/weapon/reagent_containers/food/drinks/cola_bottle/lime
	name = "Lime-Aid"
	desc = "Antihol mixed with lime juice. A well-known cure for hangovers."
	label = "limeaid"
	labeled = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("antihol", 20)
		R.add_reagent("juice_lime", 20)

/obj/item/weapon/reagent_containers/food/drinks/cola_bottle/bottledwater
	name = "Decirprevo Bottled Water"
	desc = "Bottled from our cool natural springs on Europa."
	label = "water"
	labeled = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("water", 50)

/obj/item/weapon/reagent_containers/food/drinks/cola_bottle/grones
	name = "Grones Soda"
	desc = "They make all kinds of flavors these days, good lord."
	label = "grones"
	heal_amt = 1
	labeled = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		var/flavor = rand(1,14)
		switch(flavor)
			if(1)
				src.name = "Grones Soda - Wicked Sick Pumpkin Prolapse"
				R.add_reagent("diarrhea", 10)
			if(2)
				src.name = "Grones Soda - Ballin' Banana Testicular Torsion"
				R.add_reagent("urine", 10)
			if(3)
				src.name = "Grones Soda - Radical Roadkill Rampage"
				R.add_reagent("blood", 10)
			if(4)
				src.name = "Grones Soda - Sweet Cherry Brain Haemorrhage"
				R.add_reagent("impedrezine", 10)
			if(5)
				src.name = "Grones Soda - Awesome Asbestos Candy Apple"
				R.add_reagent("lithium", 10)
			if(6)
				src.name = "Grones Soda - Salt-Free Senile Dementia"
				R.add_reagent("mercury", 10)
			if(7)
				src.name = "Grones Soda - High Fructose Traumatic Stress Disorder"
				R.add_reagent("cryptobiolin", 10)
			if(8)
				src.name = "Grones Soda - Tangy Dismembered Orphan Tears"
				R.add_reagent("inaprovaline", 10)
			if(9)
				src.name = "Grones Soda - Chunky Infected Laceration Salsa"
				R.add_reagent("anti_toxin", 10)
			if(10)
				src.name = "Grones Soda - Manic Depressive Multivitamin Dewberry"
				R.add_reagent("hyperzine", 10)
			if(11)
				src.name = "Grones Soda - Anti-Bacterial Air Freshener"
				R.add_reagent("spaceacillin", 10)
			if(12)
				src.name = "Grones Soda - Icy Fresh Social Incompetence"
				R.add_reagent("THC", 10)
			if(13)
				src.name = "Grones Soda - Minty Restraining Order Pepper Spray"
				R.add_reagent("capsaicin", 10)
			if(14)
				src.name = "Grones Soda - Cool Keratin Rush"
				R.add_reagent("hairgrownium", 10)
		R.add_reagent("cola", 20)

/obj/item/weapon/reagent_containers/food/drinks/cola_bottle/orange
	name = "Orange-Aid"
	desc = "A vitamin tonic that promotes good eyesight."
	label = "orangeaid"
	heal_amt = 1
	labeled = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("imidazoline", 20)
		R.add_reagent("juice_orange", 20)

/obj/item/weapon/reagent_containers/food/drinks/beer
	name = "Space Beer"
	desc = "Beer. in space."
	icon_state = "beer"
	heal_amt = 1
	g_amt = 40
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("beer", 30)

/obj/item/weapon/reagent_containers/food/drinks/wine
	name = "Wine"
	desc = "Not to be confused with pubbie tears."
	icon_state = "wine"
	heal_amt = 1
	g_amt = 40
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("wine", 30)

/obj/item/weapon/reagent_containers/food/drinks/cider
	name = "Cider"
	desc = "Made from apples."
	icon_state = "cider"
	heal_amt = 1
	g_amt = 40
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("cider", 30)

/obj/item/weapon/reagent_containers/food/drinks/rum
	name = "Rum"
	desc = "Yo ho ho and all that."
	icon_state = "rum"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("rum", 30)

/obj/item/weapon/reagent_containers/food/drinks/rum_spaced
	name = "Spaced Rum"
	desc = "Rum which has been exposed to cosmic radiation. Don't worry, radiation does everything!"
	icon_state = "rum"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(60)
		reagents = R
		R.my_atom = src
		R.add_reagent("rum", 30)
		R.add_reagent("yobihodazine", 30)

/obj/item/weapon/reagent_containers/food/drinks/mead
	name = "Mead"
	desc = "A pillager's tipple."
	icon_state = "mead"
	heal_amt = 1
	g_amt = 40
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("mead", 30)

/obj/item/weapon/reagent_containers/food/drinks/vintage
	name = "2110 Vintage"
	desc = "A bottle marked '2110 Vintage'. ...wait, this isn't wine..."
	icon_state = "mead"
	heal_amt = 1
	g_amt = 40
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("urine", 30)

/obj/item/weapon/reagent_containers/food/drinks/vodka
	name = "Vodka"
	desc = "Russian stuff. Pretty good quality."
	icon_state = "vodka"
	heal_amt = 1
	g_amt = 60
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("vodka", 30)

/obj/item/weapon/reagent_containers/food/drinks/thegoodstuff
	name = "Stinkeye's Special Reserve"
	desc = "An old bottle labelled 'The Good Stuff'. This probably has enough kick to knock an elephant on its ass."
	icon_state = "whiskey"
	heal_amt = 1
	g_amt = 60
	New()
		var/datum/reagents/R = new/datum/reagents(250)
		reagents = R
		R.my_atom = src
		R.add_reagent("beer", 30)
		R.add_reagent("wine", 30)
		R.add_reagent("cider", 30)
		R.add_reagent("vodka", 30)
		R.add_reagent("ethanol", 30)
		R.add_reagent("eyeofnewt", 30);

/obj/item/weapon/reagent_containers/food/drinks/bojackson
	name = "Bo Jack Daniel's"
	desc = "Bo knows how to get you drunk, by diddley!"
	icon_state = "spicedrum"
	heal_amt = 1
	g_amt = 40
	New()
		var/datum/reagents/R = new/datum/reagents(60)
		reagents = R
		R.my_atom = src
		R.add_reagent("bojack", 60)

/obj/item/weapon/reagent_containers/food/drinks/chickensoup
	name = "Chicken Soup"
	desc = "Got something to do with souls. Maybe. Do chickens even have souls?"
	icon_state = "coffee"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("chickensoup", 30)

/obj/item/weapon/reagent_containers/food/drinks/cola
	name = "space cola"
	desc = "Cola. in space."
	icon_state = "cola"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("cola", 30)

		if(prob(50))
			src.icon_state = "cola-blue"