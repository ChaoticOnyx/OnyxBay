/*
CONTAINS:
SCALPEL
CIRCULAR SAW

*/

/obj/item/weapon/scalpel/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	if((usr.mutations & 16) && prob(50))
		M << "\red You stab yourself in the eye."
		M.sdisabilities |= 1
		M.weakened += 4
		M.bruteloss += 10

	src.add_fingerprint(user)

	if(!(locate(/obj/machinery/optable, M.loc) && M.resting))
		return ..()

	if(user.zone_sel.selecting == "head")

		var/mob/living/carbon/human/H = M
		if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			// you can't stab someone in the eyes wearing a mask!
			user << "\blue You're going to need to remove that mask/helmet/glasses first."
			return

		switch(M:brain_op_stage)
			if(0.0)
				for(var/mob/O in viewers(M, null))
					if(O == (user || M))
						continue
					if(M == user)
						O.show_message(text("\red [user] begins to cut open his skull with [src]!"), 1)
					else
						O.show_message(text("\red [M] is beginning to have his head cut open with [src] by [user]."), 1)

				if(M != user)
					M << "\red [user] begins to cut open your head with [src]!"
					user << "\red You cut [M]'s head open with [src]!"
				else
					user << "\red You begin to cut open your head with [src]!"
					if(prob(25))
						user << "\red You mess up!"
						M.bruteloss += 15
				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M.organs["head"]
					affecting.take_damage(7)
				else
					M.bruteloss += 7

				M.updatehealth()
				M:brain_op_stage = 1.0
			if(2.0)
				for(var/mob/O in viewers(M, null))
					if(O == (user || M))
						continue
					if(M == user)
						O.show_message(text("\red [user] begin to delicately remove the connections to his brain with [src]!"), 1)
					else
						O.show_message(text("\red [M] is having his connections to the brain delicately severed with [src] by [user]."), 1)

				if(M != user)
					M << "\red [user] begins to cut open your head with [src]!"
					user << "\red You cut [M]'s head open with [src]!"
				else
					user << "\red You begin to delicately remove the connections to the brain with [src]!"
					if(prob(25))
						user << "\red You nick an artery!"
						M.bruteloss += 75

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M.organs["head"]
					affecting.take_damage(7)
				else
					M.bruteloss += 7

				M.updatehealth()
				M:brain_op_stage = 3.0
			else
				..()
		return

	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()

	return






// CIRCULAR SAW

/obj/item/weapon/circular_saw/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	if((usr.mutations & 16) && prob(50))
		M << "\red You cut out your eyes."
		M.sdisabilities |= 1
		M.weakened += 4
		M.bruteloss += 10

	src.add_fingerprint(user)

	if(!(locate(/obj/machinery/optable, M.loc) && M.resting))
		return ..()

	if(user.zone_sel.selecting == "head")

		var/mob/living/carbon/human/H = M
		if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			// you can't stab someone in the eyes wearing a mask!
			user << "\blue You're going to need to remove that mask/helmet/glasses first."
			return

		switch(M:brain_op_stage)
			if(1.0)
				for(var/mob/O in viewers(M, null))
					if(O == (user || M))
						continue
					if(M == user)
						O.show_message(text("\red [user] saws open his skull with [src]!"), 1)
					else
						O.show_message(text("\red [M] has his skull sawed open with [src] by [user]."), 1)

				if(M != user)
					M << "\red [user] begins to saw open your head with [src]!"
					user << "\red You saw [M]'s head open with [src]!"
				else
					user << "\red You begin to saw open your head with [src]!"
					if(prob(25))
						user << "\red You mess up!"
						M.bruteloss += 40

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M.organs["head"]
					affecting.take_damage(7)
				else
					M.bruteloss += 7

				M.updatehealth()
				M:brain_op_stage = 2.0

			if(3.0)
				for(var/mob/O in viewers(M, null))
					if(O == (user || M))
						continue
					if(M == user)
						O.show_message(text("\red [user] severs his brain's connection to the spine with [src]!"), 1)
					else
						O.show_message(text("\red [M] has his spine's connection to the brain severed with [src] by [user]."), 1)

				if(M != user)
					M << "\red [user] severs your brain's connection to the spine with [src]!"
					user << "\red You sever [M]'s brain's connection to the spine with [src]!"
				else
					user << "\red You sever your brain's connection to the spine with [src]!"

				M:brain_op_stage = 4.0
				M.death()

				var/obj/item/brain/B = new /obj/item/brain(M.loc)
				B.owner = M
			else
				..()
		return


	else if((!(user.zone_sel.selecting == "chest")) || (!(user.zone_sel.selecting == "groin")) || ((istype(M, /mob/living/carbon/human))))
		var/datum/organ/external/S = M.organs["[user.zone_sel.selecting]"]
		if(S.destroyed)
			return
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red [M] gets his [S.display_name] sawed off with [src] by [user]."), 1)
		S.destroyed = 1
		M:update_body()
	return

// Surgical scapel
/obj/item/weapon/s_scalpel/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return
//	world << "Start"
	if((usr.mutations & 16) && prob(50))
		M << "\red You stab yourself in the eye."
		M.sdisabilities |= 1
		M.weakened += 4
		M.bruteloss += 10

	src.add_fingerprint(user)

	if(!(locate(/obj/machinery/optable, M.loc) && M.resting))
		return ..()
//	world << "On table"
	var/zone = user.zone_sel.selecting
//	world << zone
	if (istype(M.organs[text("[]", zone)], /datum/organ/external))
	//	world << "Is organ"
		var/datum/organ/external/temp = M.organs[text("[]", zone)]
		var/msg
		if(temp.open)
			msg = "\red [user] starts to close up [M]'s wound in their [temp.display_name] with [src]"
		else
			msg = "\red [user] starts to open up [M]'s [temp.display_name] with [src]"
		for(var/mob/O in viewers(M,null))
			O.show_message(msg,1)


		if(do_mob(user,M,100))
			if(temp.open)
				msg = "\red [user] closes [M]'s wound in their [temp.display_name] with [src]"
				temp.open = 0
				temp.clean = 0
				temp.split = 1
			else
				msg = "\red [user] opens up [M]'s [temp.display_name] with [src]"
				temp.open = 1
				temp.clean = 0
		//	world << msg
		//	world << temp.open
			for(var/mob/O in viewers(M,null))
				O.show_message(msg,1)
			M.UpdateDamageIcon()
		else
			var/a = pick(1,2,3)
			if(a == 1)
				msg = "\red [user]'s move slices open [M]'s wound, causing massive bleeding"
				temp.brute_dam += 70
				temp.clean = 0
			else if(a == 2)
				msg = "\red [user]'s move slices open [M]'s wound, and causes him to accidentally stab himself"
				temp.brute_dam += 70
				var/datum/organ/external/userorgan = user.organs[text("chest")]
				userorgan.brute_dam += 70
				temp.clean = 0
			else if(a == 3)
				msg = "\red [user] quickly stops the surgery"

			for(var/mob/O in viewers(M,null))
				O.show_message(msg,1)

//		user << "This tool is not yet complete"

	return
/*
A kinda of quick time event.
Eg you move slices open [M]'s wound, causing massive bleeding
and then you have (1-3sec to respond to this eg by applying cotton.


*/
/obj/item/weapon/disinfectant
	name = "Surgical disinfectant"
	icon = 'janitor.dmi'
	icon_state = "cleaner"

/obj/item/weapon/disinfectant/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return
//	world << "Start"
	if((usr.mutations & 16) && prob(50))
		M << "\red You stab yourself in the eye."
		M.sdisabilities |= 1
		M.weakened += 4
		M.bruteloss += 10

	src.add_fingerprint(user)

	if(!(locate(/obj/machinery/optable, M.loc) && M.resting))
		return ..()

	var/zone = user.zone_sel.selecting
//	world << zone
	if (istype(M.organs[text("[]", zone)], /datum/organ/external))
	//	world << "Is organ"
		var/datum/organ/external/temp = M.organs[text("[]", zone)]
		var/msg
		msg = "\red [user] starts to clean [M]'s wound in their [temp.display_name] with [src]"
		for(var/mob/O in viewers(M,null))
			O.show_message(msg,1)

		if(do_mob(user,M,50))
			msg = "\red [user] finishes cleaning [M]'s [temp.display_name]"
			temp.clean = 1
		else
			msg = "\red [user] stops cleaning [M]'s [temp.display_name]"
		for(var/mob/O in viewers(M,null))
			O.show_message(msg,1)


/obj/item/weapon/surgicalglue
	name = "Surgical glue"
	icon = 'janitor.dmi'
	icon_state = "cleaner"

/obj/item/weapon/surgicalglue/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return
//	world << "Start"

	src.add_fingerprint(user)

	if(!(locate(/obj/machinery/optable, M.loc) && M.resting))
		return ..()

	var/zone = user.zone_sel.selecting
//	world << zone
	if (istype(M.organs[text("[]", zone)], /datum/organ/external))
	//	world << "Is organ"
		var/datum/organ/external/temp = M.organs[text("[]", zone)]
		var/msg
		msg = "\red [user] starts to glue [M]'s wound in their [temp.display_name] with [src]"
		for(var/mob/O in viewers(M,null))
			O.show_message(msg,1)

		if(do_mob(user,M,50))
			msg = "\red [user] finishes gluing [M]'s wound in their [temp.display_name]"
			temp.split = 0
		else
			msg = "\red [user] stops gluing [M]'s wound in their [temp.display_name]"
		for(var/mob/O in viewers(M,null))
			O.show_message(msg,1)


/obj/item/weapon/surgical_tool
	name = "surgical tool"
	var/list/stage = list() //Stage to act on
	var/time = 50 //Time it takes to use
	var/wound //Wound type to act on

	proc/get_message(var/mnumber,var/M,var/user,var/datum/organ/external/organ)//=Start,2=finish,3=walk away,4=screw up, 5 = closed wound
	proc/screw_up(mob/living/carbon/M as mob,mob/living/carbon/user as mob,var/datum/organ/external/organ)
		organ.brute_dam += 30
/obj/item/weapon/surgical_tool/proc/IsFinalStage(var/stage)
	var/a
	switch(wound)
		if("broken") //Basic broken bone
			a=3
		if("blood")
			a=3
	return stage == a

/obj/item/weapon/surgical_tool/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return
//	world << "Start"
	if((usr.mutations & 16) && prob(50))
		M << "\red You stab yourself in the eye."
		M.sdisabilities |= 1
		M.weakened += 4
		M.bruteloss += 10

	src.add_fingerprint(user)

	if(!(locate(/obj/machinery/optable, M.loc) && M.resting))
		return ..()

	var/zone = user.zone_sel.selecting
//	world << zone
	if (istype(M.organs[text("[]", zone)], /datum/organ/external))
		var/datum/organ/external/temp = M.organs[text("[]", zone)]
		var/msg

		msg = get_message(1,M,user,temp)
		for(var/mob/O in viewers(M,null))
			O.show_message("\red [msg]",1)
		if(do_mob(user,M,time))
			if(temp.open)
				if(temp.wound == wound)
					if(temp.stage in stage)
						temp.stage += 1

						if(IsFinalStage(temp.stage))
							temp.broken = 0
							temp.stage = 0
						msg = get_message(2,M,user,temp)
					else
						msg = get_message(4,M,user,temp)
						screw_up(M,user,temp)
			else
				msg = get_message(5,M,user,temp)
		else
			msg = get_message(3,M,user,temp)

		for(var/mob/O in viewers(M,null))
			O.show_message("\red [msg]",1)


//Broken bone
//Basic
//Open -> Clean -> Bone-gel -> pop-into-place -> Bone-gel -> close -> glue -> clean

//Blood
//Open -> Clean -> Blood-drainer -> nano-bloodifier - >close -> glue -> clean

//Split
//Open -> Clean -> Tweasers -> bone-glue -> close -> glue -> clean

//

/obj/item/weapon/surgical_tool/bonegel
	name = "Bone-gel"
	icon = 'janitor.dmi'
	icon_state = "cleaner"

/obj/item/weapon/surgical_tool/bonegel/New()
	stage += 0
	stage += 2
	wound = "broken"
/obj/item/weapon/surgical_tool/bonegel/get_message(var/n,var/m,var/usr,var/datum/organ/external/organ)
	var/z
	switch(n)
		if(1)
			z="[usr] starts applying bone-gel to [m]'s [organ.display_name]"
		if(2)
			z="[usr] finishes applying bone-gel to [m]'s [organ.display_name]"
		if(3)
			z="[usr] stops applying bone-gel to [m]'s [organ.display_name]"
		if(4)
			z="[usr] applies bone-gel incorrectly to [m]'s [organ.display_name]"
		if(5)
			z="[usr] lubricates [m]'s [organ.display_name]"
	return z

/obj/item/weapon/surgical_tool/bonecracker
	name = "Bone-cracker"
	icon = 'items.dmi'
	icon_state = "wrench"

/obj/item/weapon/surgical_tool/bonecracker/New()
	stage += 1
	wound = "broken"
/obj/item/weapon/surgical_tool/bonecracker/get_message(var/n,var/m,var/usr,var/datum/organ/external/organ)
	var/z
	switch(n)
		if(1)
			z="[usr] starts popping [m]'s [organ.display_name] bone into place"
		if(2)
			z="[usr] finishes popping [m]'s [organ.display_name] bone into place"
		if(3)
			z="[usr] stops popping [m]'s [organ.display_name] bone into place"
		if(4)
			z="[usr] pops [m]'s [organ.display_name] bone into the wrong place"
		if(5)
			z="[usr] preforms chiropractice on [m]'s [organ.display_name]"
	return z

/obj/item/weapon/surgical_tool/blooddrainer
	name = "Blood-disintergrator"
	icon = 'items.dmi'
	icon_state = "wrench"

/obj/item/weapon/surgical_tool/blooddrainer/New()
	stage += 1
	wound = "blood"

/obj/item/weapon/surgical_tool/boneddrainer/get_message(var/n,var/m,var/usr,var/datum/organ/external/organ)
	var/z
	switch(n)
		if(1)
			z="[usr] starts boiling [m]'s [organ.display_name]'s damaged blood"
		if(2)
			z="[usr] finishes boiling [m]'s [organ.display_name]'s damaged blood"
		if(3)
			z="[usr] stops boiling [m]'s [organ.display_name] damaged blood"
		if(4)
			z="[usr] boils all of [m]'s [organ.display_name]'s blood"
		if(5)
			z="[usr] burns [m]'s [organ.display_name]"
	return z

/obj/item/weapon/surgical_tool/newblood
	name = "Nano-blood injector"
	icon = 'items.dmi'
	icon_state = "dnainjector"

/obj/item/weapon/surgical_tool/newblood/New()
	stage += 2
	wound = "blood"

/obj/item/weapon/surgical_tool/newblood/get_message(var/n,var/m,var/usr,var/datum/organ/external/organ)
	var/z
	switch(n)
		if(1)
			z="[usr] starts injecting [m]'s [organ.display_name]'s with nano-blood"
		if(2)
			z="[usr] finishes injecting [m]'s [organ.display_name] with nano-blood"
		if(3)
			z="[usr] stops injecting [m]'s [organ.display_name] with nano-blood"
		if(4)
			z="[usr] finished injecting nano-blood into [m]'s [organ.display_name], where it starts reacting with the normal blood"
		if(5)
			z="[usr] sqirts nano-blood onto [m]'s [organ.display_name]"
	return z

