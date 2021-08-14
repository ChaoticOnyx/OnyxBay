/datum/design/item/prosfab
	build_type = PROSFAB

/datum/design/item/prosfab/pros
	category = "Prosthetics"

/datum/design/item/prosfab/pros/Fabricate(newloc, fabricator)
	if(istype(fabricator, /obj/machinery/pros_fabricator))

		var/obj/machinery/pros_fabricator/prosfab = fabricator
		var/obj/item/organ/O = new build_path(newloc)

		var/datum/robolimb/manf = all_robolimbs["Unbranded"]
		var/new_species

		if(!prosfab.manufacturer)
			new_species = SPECIES_HUMAN

		else
			manf = all_robolimbs[prosfab.manufacturer]
			new_species = prosfab.species


		O.species = all_species[new_species]

		O.robotize(manf.company)
		O.dna = new/datum/dna()
		O.dna.ResetUI()
		O.dna.ResetSE()

		spawn(10)
			O.dir = 2

		return O

	return ..()

/datum/design/item/prosfab/pros/torso/Fabricate(newloc, fabricator)
	if(istype(fabricator, /obj/machinery/pros_fabricator))

		var/obj/machinery/pros_fabricator/prosfab = fabricator

		var/datum/robolimb/manf = all_robolimbs["Unbranded"]
		var/new_species
		var/new_gender
		var/new_build

		if(!prosfab.manufacturer)
			new_species = SPECIES_HUMAN
			new_gender = MALE
			new_build = "Default"

		else
			manf = all_robolimbs[prosfab.manufacturer]
			new_species = prosfab.species
			new_gender = prosfab.pros_gender
			new_build = prosfab.pros_build

		// Create a new, nonliving human.
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(newloc)

		H.death(0, "no message")

		H.set_species(new_species)
		H.gender = new_gender
		H.fully_replace_character_name(name)

		// Some body build magic !
		var/datum/species/S = all_species[new_species]

		if(S.get_body_build_datum_list(new_gender))

			var/datum_build_list =  S.get_body_build_datum_list(new_gender)

			for(var/datum/body_build/BB in datum_build_list)

				if(BB.name != new_build)
					continue

				var/new_body_build = BB
				H.change_body_build(new_body_build)

		// Removes all external organs other than chest and groin.
		for(var/obj/item/organ/O in H.organs)

			if(O.organ_tag == BP_CHEST || O.organ_tag == BP_GROIN)
				continue

			H.organs -= O
			H.organs_by_name.Remove(O.organ_tag)
			qdel(O)

		// Robotize remaining organs.
		for(var/obj/item/organ/external/O in H.organs)

			O.robotize(manf.company)
			O.dna = new/datum/dna()
			O.dna.ResetUI()
			O.dna.ResetSE()

		H.real_name = "Synthmorph #[rand(100,999)]"
		H.name = H.real_name
		H.dir = 2
		H.add_language(LANGUAGE_EAL)

		return H

//////////////////// Prosthetics ////////////////////
/datum/design/item/prosfab/pros/torso
	name = "FBP Torso"
	id = "pros_torso"
	build_path = /obj/item/organ/external/chest
	time = 35
	materials = list(DEFAULT_WALL_MATERIAL = 30000, "glass" = 7500)

/datum/design/item/prosfab/pros/head
	name = "Prosthetic Head"
	id = "pros_head"
	build_path = /obj/item/organ/external/head
	time = 30
	materials = list(MATERIAL_STEEL = 18750, MATERIAL_GLASS = 3750)

/datum/design/item/prosfab/pros/l_arm
	name = "Prosthetic Left Arm"
	id = "pros_l_arm"
	build_path = /obj/item/organ/external/arm
	time = 20
	materials = list(MATERIAL_STEEL = 10125)

/datum/design/item/prosfab/pros/l_hand
	name = "Prosthetic Left Hand"
	id = "pros_l_hand"
	build_path = /obj/item/organ/external/hand
	time = 15
	materials = list(MATERIAL_STEEL = 3375)

/datum/design/item/prosfab/pros/r_arm
	name = "Prosthetic Right Arm"
	id = "pros_r_arm"
	build_path = /obj/item/organ/external/arm/right
	time = 20
	materials = list(MATERIAL_STEEL = 10125)

/datum/design/item/prosfab/pros/r_hand
	name = "Prosthetic Right Hand"
	id = "pros_r_hand"
	build_path = /obj/item/organ/external/hand/right
	time = 15
	materials = list(MATERIAL_STEEL = 3375)

/datum/design/item/prosfab/pros/l_leg
	name = "Prosthetic Left Leg"
	id = "pros_l_leg"
	build_path = /obj/item/organ/external/leg
	time = 20
	materials = list(MATERIAL_STEEL = 8437)

/datum/design/item/prosfab/pros/l_foot
	name = "Prosthetic Left Foot"
	id = "pros_l_foot"
	build_path = /obj/item/organ/external/foot
	time = 15
	materials = list(MATERIAL_STEEL = 2813)

/datum/design/item/prosfab/pros/r_leg
	name = "Prosthetic Right Leg"
	id = "pros_r_leg"
	build_path = /obj/item/organ/external/leg/right
	time = 20
	materials = list(MATERIAL_STEEL = 8437)

/datum/design/item/prosfab/pros/r_foot
	name = "Prosthetic Right Foot"
	id = "pros_r_foot"
	build_path = /obj/item/organ/external/foot/right
	time = 15
	materials = list(MATERIAL_STEEL = 2813)

/datum/design/item/prosfab/pros/internal
	category = "Prosthetics, Internal"

/datum/design/item/prosfab/pros/internal/cell
	name = "Prosthetic Powercell"
	id = "pros_cell"
	build_path = /obj/item/organ/internal/cell
	time = 15
	materials = list(MATERIAL_STEEL = 7500, MATERIAL_GLASS = 3000)

/datum/design/item/prosfab/pros/internal/eyes
	name = "Prosthetic Eyes"
	id = "pros_eyes"
	build_path = /obj/item/organ/internal/eyes/robot
	time = 15
	materials = list(MATERIAL_STEEL = 5625, MATERIAL_GLASS = 5625)

/datum/design/item/prosfab/pros/internal/heart
	name = "Prosthetic Heart"
	id = "pros_heart"
	build_path = /obj/item/organ/internal/heart
	time = 15
	materials = list(MATERIAL_STEEL = 5625, MATERIAL_GLASS = 1000)

/datum/design/item/prosfab/pros/internal/lungs
	name = "Prosthetic Lungs"
	id = "pros_lung"
	build_path = /obj/item/organ/internal/lungs
	time = 15
	materials = list(MATERIAL_STEEL = 5625, MATERIAL_GLASS = 1000)

/datum/design/item/prosfab/pros/internal/liver
	name = "Prosthetic Liver"
	id = "pros_liver"
	build_path = /obj/item/organ/internal/liver
	time = 15
	materials = list(MATERIAL_STEEL = 5625, MATERIAL_GLASS = 1000)

/datum/design/item/prosfab/pros/internal/kidneys
	name = "Prosthetic Kidneys"
	id = "pros_kidney"
	build_path = /obj/item/organ/internal/kidneys
	time = 15
	materials = list(MATERIAL_STEEL = 5625, MATERIAL_GLASS = 1000)

