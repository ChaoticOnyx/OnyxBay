////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/pill
	name = "pill"
	desc = "A pill."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	item_state = "pill"
	randpixel = 7
	possible_transfer_amounts = null
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	volume = 30
	var/mimic_color = FALSE

	drop_sound = SFX_DROP_FOOD
	pickup_sound = SFX_PICKUP_FOOD

/obj/item/reagent_containers/pill/Initialize()
	. = ..()
	if(!icon_state)
		icon_state = "pill[rand(1, 5)]" //preset pills only use colour changing or unique icons

	if(mimic_color)
		color = reagents.get_color()

/obj/item/reagent_containers/pill/attack(mob/M as mob, mob/user as mob, def_zone)
		//TODO: replace with standard_feed_mob() call.
	if(M == user)
		if(!M.can_eat(src))
			return

		to_chat(M, "<span class='notice'>You swallow \the [src].</span>")
		if(reagents.total_volume)
			reagents.trans_to_mob(M, reagents.total_volume, CHEM_INGEST)
		qdel(src)
		return 1

	else if(istype(M, /mob/living/carbon/human))
		if(!M.can_force_feed(user, src))
			return

		user.visible_message("<span class='warning'>[user] attempts to force [M] to swallow \the [src].</span>")
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		if(!do_mob(user, M))
			return

		if(!isrobot(user) && user.get_active_hand() != src)
			return

		user.visible_message("<span class='warning'>[user] forces [M] to swallow \the [src].</span>")
		var/contained = reagentlist()
		admin_attack_log(user, M, "Fed the victim with [name] (Reagents: [contained])", "Was fed [src] (Reagents: [contained])", "used [src] (Reagents: [contained]) to feed")
		if(reagents.total_volume)
			reagents.trans_to_mob(M, reagents.total_volume, CHEM_INGEST)
		qdel(src)
		return 1

	return 0

/obj/item/reagent_containers/pill/afterattack(obj/target, mob/user, proximity)
	if(!proximity) return

	if(target.is_open_container() && target.reagents)
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='notice'>[target] is empty. Can't dissolve \the [src].</span>")
			return
		to_chat(user, "<span class='notice'>You dissolve \the [src] in [target].</span>")

		admin_attacker_log(user, "spiked \a [target] with a pill. Reagents: [reagentlist()]")
		reagents.trans_to(target, reagents.total_volume)
		for(var/mob/O in viewers(2, user))
			O.show_message("<span class='warning'>[user] puts something in \the [target].</span>", 1)
		qdel(src)
	return

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

//We lied - it's pills all the way down
/obj/item/reagent_containers/pill/tox
	name = "toxins pill"
	desc = "Highly toxic."
	icon_state = "pill4"
	startswith = list(/datum/reagent/toxin)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/cyanide
	name = "strange pill"
	desc = "It's marked 'KCN'. Smells vaguely of almonds."
	icon_state = "pill9"
	startswith = list(/datum/reagent/toxin/cyanide)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/adminordrazine
	name = "Adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pillA"
	startswith = list(/datum/reagent/adminordrazine)

/obj/item/reagent_containers/pill/stox
	name = "Soporific (15u)"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill3"
	startswith = list(/datum/reagent/soporific = 15)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/kelotane
	name = "Kelotane (15u)"
	desc = "Used to treat burns."
	icon_state = "pill2"
	startswith = list(/datum/reagent/kelotane = 15)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/paracetamol
	name = "Paracetamol (15u)"
	desc = "A painkiller for the ages. Chewables!"
	icon_state = "pill3"
	startswith = list(/datum/reagent/painkiller/paracetamol = 15)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/tramadol
	name = "Tramadol (15u)"
	desc = "A simple painkiller."
	icon_state = "pill3"
	startswith = list(/datum/reagent/painkiller/tramadol = 15)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/inaprovaline
	name = "Inaprovaline (30u)"
	desc = "Used to stabilize patients."
	icon_state = "pill1"
	startswith = list(/datum/reagent/inaprovaline)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/dexalin
	name = "Dexalin (15u)"
	desc = "Used to treat oxygen deprivation."
	icon_state = "pill1"
	startswith = list(/datum/reagent/dexalin = 15)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/dexalin_plus
	name = "Dexalin Plus (15u)"
	desc = "Used to treat extreme oxygen deprivation."
	icon_state = "pill2"
	startswith = list(/datum/reagent/dexalinp = 15)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/dermaline
	name = "Dermaline (15u)"
	desc = "Used to treat burn wounds."
	icon_state = "pill2"
	startswith = list(/datum/reagent/dermaline = 15)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/dylovene
	name = "Dylovene (15u)"
	desc = "A broad-spectrum anti-toxin."
	icon_state = "pill1"
	startswith = list(/datum/reagent/dylovene = 15)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/bicaridine
	name = "Bicaridine (20u)"
	desc = "Used to treat physical injuries."
	icon_state = "pill2"
	startswith = list(/datum/reagent/bicaridine = 20)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/happy
	name = "happy pill"
	desc = "Happy happy joy joy!"
	icon_state = "pill4"
	startswith = list(
		/datum/reagent/space_drugs = 15,
		/datum/reagent/sugar = 15)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/zoom
	name = "zoom pill"
	desc = "Zoooom!"
	icon_state = "pill4"
	startswith = list(
		/datum/reagent/impedrezene = 10,
		/datum/reagent/synaptizine = 5,
		/datum/reagent/hyperzine = 5)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/spaceacillin
	name = "Spaceacillin (10u)"
	desc = "Contains antiviral agents."
	icon_state = "pill3"
	startswith = list(/datum/reagent/spaceacillin = 10)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/diet
	name = "diet pill"
	desc = "Guaranteed to get you slim!"
	icon_state = "pill4"
	startswith = list(/datum/reagent/lipozine = 2)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/noexcutite
	name = "Noexcutite (15u)"
	desc = "Feeling jittery? This should calm you down."
	icon_state = "pill4"
	startswith = list(/datum/reagent/noexcutite = 15)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/antidexafen
	name = "Antidexafen (15u)"
	desc = "Common cold mediciation. Safe for babies!"
	icon_state = "pill4"
	startswith = list(
		/datum/reagent/antidexafen = 10,
		/datum/reagent/drink/juice/lemon = 5,
		/datum/reagent/menthol = REM*0.2)
	mimic_color = TRUE

//Psychiatry pills.
/obj/item/reagent_containers/pill/methylphenidate
	name = "Methylphenidate (15u)"
	desc = "Improves the ability to concentrate."
	icon_state = "pill2"
	startswith = list(/datum/reagent/methylphenidate = 15)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/citalopram
	name = "Citalopram (15u)"
	desc = "Mild anti-depressant."
	icon_state = "pill4"
	startswith = list(/datum/reagent/citalopram = 15)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/paroxetine
	name = "Paroxetine (10u)"
	desc = "Before you swallow a bullet: try swallowing this!"
	icon_state = "pill4"
	startswith = list(/datum/reagent/paroxetine = 10)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/hyronalin
	name = "Hyronalin (10u)"
	desc = "Got some rads? Eat this!"
	icon_state = "pill4"
	startswith = list(/datum/reagent/hyronalin = 10)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/glucose
	name = "Glucose (20u)"
	desc = "Used to treat blood loss"
	icon_state = "pill4"
	startswith = list(/datum/reagent/nutriment/glucose = 20)
	mimic_color = TRUE

//Mining pills.
/obj/item/reagent_containers/pill/leporazine
	name = "Thermostabilizine"
	desc = "Contents 15u of leporazine. Effectively stabilizes body temperature."
	icon_state = "pill2"
	startswith = list(/datum/reagent/leporazine = 15)
	mimic_color = TRUE

//Not actually a pill, but pills type provide everything needed for this
/obj/item/reagent_containers/pill/sugar_cube
	name = "sugar cube"
	desc = "Sugar pressed together in block shape that is used to sweeten drinks."
	icon_state = "sugar_cubes"
	startswith = list(/datum/reagent/sugar = 5)
	mimic_color = TRUE

//Not actually a pill, but pills type provide everything needed for this
/obj/item/reagent_containers/pill/cleanerpod
	name = "space cleaner pod"
	desc = "BLAM!-brand non-foaming space cleaner in concentrated form! Use one pod per 100u of water. Should not be consumed, but hey I'm not your mom nor a doctor."
	icon_state = "cleanerpod"
	startswith = list(/datum/reagent/space_cleaner/dry = 10)
	mimic_color = FALSE

//Pills that probably won't be used anywhere, except in merchants or mapping, but who cares?

/obj/item/reagent_containers/pill/oxycodone
	name = "Oxycodone (15u)"
	desc = "A complex painkiller."
	icon_state = "pill3"
	startswith = list(/datum/reagent/painkiller/tramadol/oxycodone = 15)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/metazine
	name = "Metazine (10u)"
	desc = "A combat painkiller."
	icon_state = "pill24"
	startswith = list(/datum/reagent/painkiller = 10)
	mimic_color = FALSE

/obj/item/reagent_containers/pill/tricordrazine
	name = "Tricordrazine (20u)"
	desc = "Used to slowly treat external injuries."
	icon_state = "pill2"
	startswith = list(/datum/reagent/tricordrazine = 20)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/alkysine
	name = "Alkysine (5u)"
	desc = "Do you have a headache? Just eat me!"
	icon_state = "pill2"
	startswith = list(/datum/reagent/alkysine = 5)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/imidazoline
	name = "Imidazoline (10u)"
	desc = "Used to treat eye injuries."
	icon_state = "pill2"
	startswith = list(/datum/reagent/imidazoline = 10)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/ryetalyn
	name = "Ryetalyn (5u)"
	desc = "Used for genetic defects, including cataracts."
	icon_state = "pill3"
	startswith = list(/datum/reagent/ryetalyn = 5)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/peridaxon
	name = "Peridaxon (10u)"
	desc = "Used to restore the internal organs and nervous system."
	icon_state = "pill2"
	startswith = list(/datum/reagent/peridaxon = 10)
	mimic_color = TRUE

/obj/item/reagent_containers/pill/albumin
	name = "Albumin (20u)"
	desc = "Used to restore blood loss."
	icon_state = "pill3"
	startswith = list(
		/datum/reagent/albumin = 15,
		/datum/reagent/iron = 5)
	mimic_color = TRUE
