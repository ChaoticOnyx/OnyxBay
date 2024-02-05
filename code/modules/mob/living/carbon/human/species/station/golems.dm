/datum/species/golem
	name = SPECIES_GOLEM
	name_plural = "golems"

	icobase = 'icons/mob/human_races/golems/r_golem.dmi'
	language = LANGUAGE_GALCOM
	additional_langs = LANGUAGE_SOL_COMMON
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/punch)
	generic_attack_mod = 1.5
	appearance_flags = HAS_SKIN_COLOR | HAS_SKIN_TONE_NORMAL
	has_eyes_icon = FALSE
	species_flags = SPECIES_FLAG_NO_PAIN | SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_POISON | SPECIES_FLAG_NO_BLOOD | SPECIES_FLAG_NO_ANTAG_TARGET | SPECIES_FLAG_NO_MINOR_CUT | SPECIES_FLAG_NO_EMBED | SPECIES_NO_LACE | SPECIES_FLAG_NO_FIRE
	spawn_flags = SPECIES_IS_RESTRICTED

	siemens_coefficient = 0
	breath_type = null
	poison_type = null

	blood_color = "#515573"
	fixed_mut_color = "#080808"
	flesh_color = "#080808"

	var/info_text = "As an <span class='danger'>Iron Golem</span>, you don't have any special traits."
	var/prefix = "Iron"

	var/list/special_names = list("Tarkus")
	var/human_surname_chance = 3
	var/special_name_chance = 5

	has_organ = list(
		BP_BRAIN = /obj/item/organ/internal/cerebrum/brain/golem,
		BP_ADAMANTINE_RESONATOR = /obj/item/organ/internal/adamantine_resonator
		)

	inherent_traits = list(
		TRAIT_RADIMMUNE
	)

	cold_level_1 = 200
	cold_level_2 = 160
	cold_level_3 = 80
	heat_level_1 = 500
	heat_level_2 = 800
	heat_level_3 = 1200

	passive_temp_gain = 0
	hazard_high_pressure = 720
	warning_high_pressure = 550
	warning_low_pressure = 20
	hazard_low_pressure = 0
	body_temperature = 310.15


	heat_discomfort_level = 415
	cold_discomfort_level = 225

	brute_mod = 0.75
	radiation_mod = 0

	death_message = "becomes completely motionless..."

/datum/species/golem/get_random_name(gender)
	var/golem_surname = pick(GLOB.golem_names)
	// 3% chance that our golem has a human surname, because
	// cultural contamination
	if(prob(human_surname_chance))
		golem_surname = pick(GLOB.last_names)
	else if(special_names?.len && prob(special_name_chance))
		golem_surname = pick(special_names)

	var/golem_name = "[prefix] [golem_surname]"
	return golem_name

/datum/species/golem/handle_post_spawn(mob/living/carbon/human/H)
	SHOULD_CALL_PARENT(TRUE)
	if(H.mind)
		H.mind.assigned_role = "Golem"
		H.mind.special_role = "Golem"
	H.dna.mcolor = fixed_mut_color
	H.UpdateAppearance(mutcolor_update=TRUE)
	..()

/datum/species/golem/is_eligible_for_antag_spawn(antag_id)
	return FALSE

/datum/species/golem/adamantine
	name = SPECIES_GOLEM_ADAMANTINE
	fixed_mut_color = "#002B2D"
	info_text = "As an <span class='danger'>Adamantine Golem</span>, you possess special vocal cords allowing you to \"resonate\" messages to all golems. Your unique mineral makeup makes you immune to most types of magic."
	prefix = "Adamantine"
	special_names = null
	inherent_traits = list(
		TRAIT_RADIMMUNE,
		TRAIT_ANTIMAGIC
	)
	has_organ = list(
		BP_BRAIN = /obj/item/organ/internal/cerebrum/brain/golem,
		BP_ADAMANTINE_RESONATOR = /obj/item/organ/internal/adamantine_resonator,
		BP_ADAMANTINE_VOCAL_CORDS = /obj/item/organ/internal/vocal_cords/adamantine
	)

//The suicide bombers of golemkind
/datum/species/golem/plasma
	name = SPECIES_GOLEM_PLASMA
	fixed_mut_color = "#4C1564"
	meat_type = /obj/item/stack/material/plasma
	species_flags = SPECIES_FLAG_NO_PAIN | SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_POISON | SPECIES_FLAG_NO_BLOOD | SPECIES_FLAG_NO_ANTAG_TARGET | SPECIES_FLAG_NO_MINOR_CUT | SPECIES_FLAG_NO_EMBED | SPECIES_NO_LACE
	heat_level_1 = 400
	heat_level_2 = 500
	heat_level_3 = 1000

	info_text = "As a <span class='danger'>Plasma Golem</span>, you burn easily. Be careful, if you get hot enough while burning, you'll blow up!"
	prefix = "Plasma"
	special_names = list("Flood","Fire","Bar","Man")

	var/boom_warning = FALSE
	var/datum/action/innate/ignite/ignite

/datum/species/golem/plasma/handle_environment_special(mob/living/carbon/human/H)
	if(H.bodytemperature > 380)
		if(!boom_warning && H.on_fire)
			to_chat(H, SPAN_DANGER("You feel like you could blow up at any moment!"))
			boom_warning = TRUE
	else
		if(boom_warning)
			to_chat(H, SPAN_NOTICE("You feel more stable."))
			boom_warning = FALSE

	if(H.bodytemperature > 420 && H.on_fire && prob(25))
		explosion(H, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 4)
		if(H)
			H.investigate_log("has been gibbed as [H] body explodes.")
			H.gib()
	if(H.fire_stacks < 2) //flammable
		H.adjust_fire_stacks(0.5 * 0.1)
	..()

/datum/species/golem/plasma/handle_post_spawn(mob/living/carbon/human/H)
	..()
	if(ishuman(H))
		var/datum/action/innate/ignite/ignite = new
		ignite.Grant(H)
		spawn(1)
			H.update_action_buttons()

/datum/species/golem/plasma/on_species_loss(mob/living/carbon/human/H)
	var/datum/action/innate/ignite/ignite = H.actions.Find(/datum/action/innate/ignite)
	if(ignite)
		ignite.Remove(H)
		spawn(1)
			H.update_action_buttons()
	..()

/datum/action/innate/ignite
	name = "Ignite"
	//desc = "Set yourself aflame, bringing yourself closer to exploding!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "sacredflame"

/datum/action/innate/ignite/Activate()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.fire_stacks)
			to_chat(owner, SPAN_NOTICE("You ignite yourself!"))
		else
			to_chat(owner, SPAN_WARNING("You try to ignite yourself, but fail!"))
			return
		H.IgniteMob() //firestacks are already there passively

//Harder to hurt
/datum/species/golem/diamond
	name = SPECIES_GOLEM_DIAMOND
	fixed_mut_color = "#2C797A"
	brute_mod = 0.45
	meat_type = /obj/item/stack/material/diamond
	info_text = "As a <span class='danger'>Diamond Golem</span>, you are more resistant than the average golem."
	prefix = "Diamond"
	special_names = list("Back","Grill")


//Faster but softer and less armoured
/datum/species/golem/gold
	name = SPECIES_GOLEM_GOLD
	fixed_mut_color = "#484800"
	movespeed_modifier = /datum/movespeed_modifier/golem_gold
	brute_mod = 0.90 //down from 55
	meat_type = /obj/item/stack/material/gold
	info_text = "As a <span class='danger'>Gold Golem</span>, you are faster but less resistant than the average golem."
	prefix = "Golden"
	special_names = list("Boy")


//Heavier, thus higher chance of stunning when punching
/datum/species/golem/silver
	name = SPECIES_GOLEM_SILVER
	fixed_mut_color = "#5F5F5F"
	meat_type = /obj/item/stack/material/silver
	info_text = "As a <span class='danger'>Silver Golem</span>, your attacks have a higher chance of stunning. Being made of silver, your body is immune to spirits of the damned and runic golems."
	prefix = "Silver"
	special_names = list("Surfer", "Chariot", "Lining")


/datum/species/golem/silver/handle_post_spawn(mob/living/carbon/human/H)
	..()
	ADD_TRAIT(H, TRAIT_HOLY)

/datum/species/golem/silver/on_species_loss(mob/living/carbon/human/H)
	REMOVE_TRAIT(H, TRAIT_HOLY)
	..()


//Harder to stun, deals more damage, massively slowpokes, but gravproof and obstructive. Basically, The Wall.
/datum/species/golem/plasteel
	name = SPECIES_GOLEM_PLASTEEL
	fixed_mut_color = "#000000"
	bump_flag = HEAVY
	push_flags = ALLMOBS
	swap_flags = ALLMOBS
	movespeed_modifier = /datum/movespeed_modifier/golem_plasteel

	meat_type = /obj/item/stack/material/plasteel
	info_text = "As a <span class='danger'>Plasteel Golem</span>, you are slower, but harder to stun, and hit very hard when punching. You also magnetically attach to surfaces and so don't float without gravity and cannot have positions swapped with other beings."
	prefix = "Plasteel"
	special_names = null
	unarmed_types = list(
		/datum/unarmed_attack/punch/strong/golem/plasteel,
		/datum/unarmed_attack/kick/strong/golem/plasteel,
		/datum/unarmed_attack/stomp/strong/golem/plasteel
	)
/datum/species/golem/plasteel/handle_post_spawn(mob/living/carbon/human/H)
	..()
	species_flags |= SPECIES_FLAG_NO_SLIP

/datum/species/golem/titanium
	name = SPECIES_GOLEM_TITANIUM
	fixed_mut_color = "#5F5F5F"
	meat_type = /obj/item/stack/material/plasteel/titanium
	info_text = "As a <span class='danger'>Titanium Golem</span>, you are slightly more resistant to burn damage."
	burn_mod = 0.9
	prefix = "Titanium"
	special_names = list("Dioxide")

/datum/species/golem/plastitanium
	name = SPECIES_GOLEM_PLASTITANIUM
	fixed_mut_color = "#262737"
	meat_type = /obj/item/stack/material/ocp
	info_text = "As a <span class='danger'>Plastitanium Golem</span>, you are slightly more resistant to burn damage."
	burn_mod = 0.8
	prefix = "Plastitanium"
	special_names = null

//No ashshtorms & lava
/datum/species/golem/plastitanium/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	//ADD_TRAIT(H, TRAIT_LAVA_IMMUNE)
	//ADD_TRAIT(H, TRAIT_ASHSTORM_IMMUNE)

/datum/species/golem/plastitanium/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	//REMOVE_TRAIT(H, TRAIT_LAVA_IMMUNE)
	//REMOVE_TRAIT(H, TRAIT_ASHSTORM_IMMUNE)

/datum/species/golem/wood
	name = SPECIES_GOLEM_WOOD
	fixed_mut_color = "#512704"
	meat_type = /obj/item/stack/material/wood
	//Can burn and take damage from heat
	brute_mod = 0.8
	burn_mod = 1.55
	info_text = "As a <span class='danger'>Wooden Golem</span>, you have plant-like traits: you take damage from extreme temperatures, can be set on fire, and have lower armor than a normal golem. You regenerate when in the light and wither in the darkness."
	prefix = "Wooden"
	species_flags = SPECIES_FLAG_NO_PAIN | SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_POISON | SPECIES_FLAG_NO_BLOOD | SPECIES_FLAG_NO_ANTAG_TARGET | SPECIES_FLAG_NO_MINOR_CUT | SPECIES_FLAG_NO_EMBED | SPECIES_NO_LACE
	heat_level_1 = 400
	heat_level_2 = 500
	heat_level_3 = 1000
	special_names = list("Bark", "Willow", "Catalpa", "Woody", "Oak", "Sap", "Twig", "Branch", "Maple", "Birch", "Elm", "Basswood", "Cottonwood", "Larch", "Aspen", "Ash", "Beech", "Buckeye", "Cedar", "Chestnut", "Cypress", "Fir", "Hawthorn", "Hazel", "Hickory", "Ironwood", "Juniper", "Leaf", "Mangrove", "Palm", "Pawpaw", "Pine", "Poplar", "Redwood", "Redbud", "Sassafras", "Spruce", "Sumac", "Trunk", "Walnut", "Yew")
	human_surname_chance = 0
	special_name_chance = 100


/datum/species/golem/wood/handle_environment_special(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1, T.get_lumcount()) - 0.5
		H.add_nutrition(5 * light_amount)
		if(H.nutrition > STOMACH_FULLNESS_HIGH)
			H.nutrition = STOMACH_FULLNESS_HIGH
		if(light_amount > 0.2) //if there's enough light, heal
			H.heal_overall_damage(brute = 0.5*0.1, burn = 0.5*0.1)
			H.adjustToxLoss(-0.5)
			H.adjustOxyLoss(-0.5)

	if(H.nutrition < STOMACH_FULLNESS_LOW + 50)
		H.take_overall_damage(brute = 2)
	if(H.fire_stacks < 2) //flammable
		H.adjust_fire_stacks(0.5)

//Radioactive puncher, hits for burn but only as hard as human, slightly more durable against brute but less against everything else
/datum/component/golem/uranium
	var/radiation_emission_cooldown = 0

/datum/component/golem/uranium/proc/radiation_emission(mob/living/carbon/human/H)
	if(!COOLDOWN_FINISHED(src, radiation_emission_cooldown))
		return
	else
		var/datum/radiation_source/rad_source = SSradiation.radiate(H, new /datum/radiation/preset/artifact)
		rad_source.info.energy = (100 MEGA ELECTRONVOLT)
		rad_source.schedule_decay(5 SECONDS)
		COOLDOWN_START(src, radiation_emission_cooldown, 60 SECONDS)

/datum/species/golem/uranium
	name = SPECIES_GOLEM_URANIUM
	fixed_mut_color = "#295800"
	meat_type = /obj/item/stack/material/uranium
	info_text = "As an <span class='danger'>Uranium Golem</span>, your very touch burns and irradiates organic lifeforms. You don't hit as hard as most golems, but you are far more durable against blunt force trauma."
	brute_mod = 0.5
	prefix = "Uranium"
	special_names = list("Oxide", "Rod", "Meltdown", "235")

/datum/species/golem/uranium/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.AddComponent(/datum/component/golem/uranium)

/datum/species/golem/uranium/handle_damage(mob/living/carbon/human/H)
	var/datum/component/golem/uranium/golem_comp = H.get_component(/datum/component/golem/uranium)
	if(COOLDOWN_FINISHED(golem_comp, radiation_emission_cooldown) && H.stat != DEAD)
		golem_comp.radiation_emission(H)
	..()

//Immune to physical bullets and resistant to brute, but very vulnerable to burn damage. Dusts on death.
/datum/species/golem/sand
	name = SPECIES_GOLEM_SAND
	fixed_mut_color = "#88703b"
	meat_type = /obj/item/ore/glass //this is sand
	burn_mod = 3 //melts easily
	brute_mod = 0.15
	info_text = "As a <span class='danger'>Sand Golem</span>, you are immune to physical bullets and take very little brute damage, but are extremely vulnerable to burn damage and energy weapons. You will also turn to sand when dying, preventing any form of recovery."
	prefix = "Sand"
	special_names = list("Castle", "Bag", "Dune", "Worm", "Storm")

/datum/species/golem/sand/get_random_skin_tone()
	return -55

/datum/species/golem/sand/handle_death(mob/living/carbon/human/H)
	H.visible_message(SPAN_DANGER("[H] turns into a pile of sand!"))
	for(var/obj/item/W in H)
		H.drop(W)
	if(H.getFireLoss()>75)
		for(var/i in 1 to rand(3,5))
			new /obj/item/stack/material/glass(get_turf(H))
	qdel(H)

//Reflects lasers and resistant to burn damage, but very vulnerable to brute damage. Shatters on death.
/datum/species/golem/glass
	name = SPECIES_GOLEM_GLASS
	fixed_mut_color = "#367B9C" //transparent body
	meat_type = /obj/item/material/shard
	brute_mod = 3 //very fragile
	burn_mod = 0.25
	info_text = "As a <span class='danger'>Glass Golem</span>, you reflect lasers and energy weapons, and are very resistant to burn damage. However, you are extremely vulnerable to brute damage. On death, you'll shatter beyond any hope of recovery."
	prefix = "Glass"
	special_names = list("Lens", "Prism", "Fiber", "Bead")

/datum/species/golem/glass/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.alpha = 150

/datum/species/golem/glass/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	H.alpha = 255

/datum/species/golem/glass/handle_death(mob/living/carbon/human/H)
	playsound(H, 'sound/effects/materials/glass/glassbr.ogg', 70, TRUE)
	H.visible_message(SPAN_DANGER("[H] shatters!"))
	for(var/obj/item/W in H)
		H.drop(W)
	for(var/i in 1 to rand(3,5))
		new /obj/item/material/shard(get_turf(H))
	qdel(H)

/datum/species/golem/glass/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H)) //self-shots don't reflect
		if(P.check_armour == LASER || P.check_armour == ENERGY)
			H.visible_message(SPAN_DANGER("The [P.name] gets reflected by [H]'s glass skin!"), \
			SPAN_DANGER("The [P.name] gets reflected by [H]'s glass skin!"))
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				// redirect the projectile
				P.firer = H
				P.redirect(clamp(new_x, 1, world.maxx), clamp(new_y, 1, world.maxy), locate(clamp(new_x, 1, world.maxx), clamp(new_y, 1, world.maxy), H.z), H)
			return FALSE
	return ..()

//Teleports when hit or when it wants to
/datum/component/golem/bluespace
	var/datum/action/cooldown/unstable_teleport/unstable_teleport
	var/teleport_cooldown = 200
	var/last_teleport = 0

/datum/component/golem/bluespace/proc/reactive_teleport(mob/living/carbon/human/H)
	H.visible_message(SPAN_WARNING("[H] teleports!"), SPAN_DANGER("You destabilize and teleport!"))
	new /obj/effect/sparks(get_turf(H))
	playsound(get_turf(H), SFX_SPARK, 50, TRUE)
	do_teleport(H, get_turf(H), 6)
	playsound(get_turf(H), 'sound/effects/weapons/energy/emitter2.ogg', 50, TRUE)
	last_teleport = world.time

/datum/species/golem/bluespace
	name = SPECIES_GOLEM_BLUESPACE
	fixed_mut_color = "#020284"
	meat_type = /obj/item/stack/telecrystal/bluespace_crystal
	info_text = "As a <span class='danger'>Bluespace Golem</span>, you are spatially unstable: You will teleport when hit, and you can teleport manually at a long distance."
	prefix = "Bluespace"
	special_names = list("Crystal", "Polycrystal")

/datum/species/golem/bluespace/handle_post_spawn(mob/living/carbon/human/H)
	..()
	if(ishuman(H))
		var/datum/component/golem/bluespace/golem_comp = H.AddComponent(/datum/component/golem/bluespace)
		golem_comp.unstable_teleport = new
		golem_comp.unstable_teleport.Grant(H)
		golem_comp.last_teleport = world.time
		spawn(1)
			H.update_action_buttons()

/datum/species/golem/bluespace/on_species_loss(mob/living/carbon/human/H)
	var/datum/component/golem/bluespace/golem_comp = H.get_component(/datum/component/golem/bluespace)
	golem_comp.unstable_teleport.Remove(H)
	spawn(1)
		H.update_action_buttons()
	qdel(golem_comp)
	..()

/datum/species/golem/bluespace/handle_damage(mob/living/carbon/human/H)
	..()
	var/datum/component/golem/bluespace/golem_comp = H.get_component(/datum/component/golem/bluespace)
	if(world.time > golem_comp.last_teleport + golem_comp.teleport_cooldown && H.stat != DEAD)
		golem_comp.reactive_teleport(H)

/datum/action/cooldown/unstable_teleport
	name = "Unstable Teleport"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "jaunt"
	button_icon = 'icons/hud/actions.dmi'
	cooldown_time = 15 SECONDS

/datum/action/cooldown/unstable_teleport/Activate()
	var/mob/living/carbon/human/H = owner
	H.visible_message(SPAN_WARNING("[H] starts vibrating!"), SPAN_DANGER("You start charging your bluespace core..."))
	playsound(get_turf(H), 'sound/weapons/flash.ogg', 25, TRUE)
	addtimer(CALLBACK(src, nameof(.proc/teleport), H), 1.5 SECONDS)
	return TRUE

/datum/action/cooldown/unstable_teleport/proc/teleport(mob/living/carbon/human/H)
	StartCooldown()
	H.visible_message(SPAN_WARNING("[H] disappears in a shower of sparks!"), SPAN_DANGER("You teleport!"))
	var/datum/effect/effect/system/spark_spread/spark_system = new
	spark_system.set_up(10, 0, src)
	spark_system.attach(H)
	spark_system.start()
	do_teleport(H, get_turf(H), 15,)
	playsound(get_turf(H), 'sound/effects/weapons/energy/emitter2.ogg')

/datum/component/golem/runic
	/// A ref to our jaunt spell that we get on species gain.
	var/datum/spell/targeted/ethereal_jaunt/shift/jaunt
	/// A ref to our gaze spell that we get on species gain.
	var/datum/spell/targeted/abyssal_gaze/abyssal_gaze

/datum/species/golem/runic
	name = SPECIES_GOLEM_CULT
	info_text = "As a <span class='danger'>Runic Golem</span>, you possess eldritch powers granted by the Elder Goddess Nar'Sie."
	prefix = "Runic"
	special_names = null
	fixed_mut_color = null
	icobase = 'icons/mob/human_races/golems/r_cult.dmi'


/datum/species/golem/runic/get_random_name(gender)
	var/edgy_first_name = pick("Razor","Blood","Dark","Evil","Cold","Pale","Black","Silent","Chaos","Deadly","Coldsteel")
	var/edgy_last_name = pick("Edge","Night","Death","Razor","Blade","Steel","Calamity","Twilight","Shadow","Nightmare") //dammit Razor Razor
	var/golem_name = "[edgy_first_name] [edgy_last_name]"
	return golem_name

/datum/species/golem/runic/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	var/datum/component/golem/runic/golem_comp = H.AddComponent(/datum/component/golem/runic)
	golem_comp.jaunt = new
	H.add_spell(golem_comp.jaunt, "const")

	golem_comp.abyssal_gaze = new
	H.add_spell(golem_comp.abyssal_gaze, "const")

/datum/species/golem/runic/on_species_loss(mob/living/carbon/human/H)
	var/datum/component/golem/runic/golem_comp = H.get_component(/datum/component/golem/runic)
	H.remove_spell(golem_comp.jaunt)
	H.remove_spell(golem_comp.abyssal_gaze)
	qdel(golem_comp)
	return ..()

/datum/species/golem/cloth
	name = SPECIES_GOLEM_CLOTH
	icobase = 'icons/mob/human_races/golems/r_cloth.dmi'
	info_text = "As a <span class='danger'>Cloth Golem</span>, you are able to reform yourself after death, provided your remains aren't burned or destroyed. You are, of course, very flammable. \
	Being made of cloth, your body is immune to spirits of the damned and runic golems. You are faster than that of other golems, but weaker and less resilient."
	species_flags = SPECIES_FLAG_NO_PAIN | SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_POISON | SPECIES_FLAG_NO_BLOOD | SPECIES_FLAG_NO_ANTAG_TARGET | SPECIES_FLAG_NO_MINOR_CUT | SPECIES_FLAG_NO_EMBED | SPECIES_NO_LACE
	heat_level_1 = 400
	heat_level_2 = 500
	heat_level_3 = 1000
	brute_mod = 0.9 //feels no pain, but not too resistant
	burn_mod = 2 // don't get burned
	movespeed_modifier = /datum/movespeed_modifier/golem_cloth
	prefix = "Cloth"
	special_names = null

/datum/species/golem/cloth/handle_post_spawn(mob/living/carbon/human/H)
	..()
	ADD_TRAIT(H, TRAIT_HOLY)

/datum/species/golem/cloth/on_species_loss(mob/living/carbon/human/H)
	REMOVE_TRAIT(H, TRAIT_HOLY)
	..()

/datum/species/golem/cloth/New()
	if(Holiday=="Halloween")
		spawn_flags = SPECIES_CAN_JOIN
	return ..()

/datum/species/golem/cloth/get_random_name(gender)
	var/pharaoh_name = pick("Neferkare", "Hudjefa", "Khufu", "Mentuhotep", "Ahmose", "Amenhotep", "Thutmose", "Hatshepsut", "Tutankhamun", "Ramses", "Seti", \
	"Merenptah", "Djer", "Semerkhet", "Nynetjer", "Khafre", "Pepi", "Intef", "Ay") //yes, Ay was an actual pharaoh
	var/golem_name = "[pharaoh_name] \Roman[rand(1,99)]"
	return golem_name

/datum/species/golem/cloth/handle_environment_special(mob/living/carbon/human/H)
	if(H.fire_stacks < 2)
		H.adjust_fire_stacks(1) //always prone to burning
	..()

/datum/species/golem/cloth/handle_death(mob/living/carbon/human/H)
	if(H.on_fire)
		H.visible_message(SPAN_DANGER("[H] burns into ash!"))
		H.dust()
		return

	H.visible_message(SPAN_DANGER("[H] falls apart into a pile of bandages!"))
	new /obj/structure/cloth_pile(get_turf(H), H)
	..()

/obj/structure/cloth_pile
	name = "pile of bandages"
	desc = "It emits a strange aura, as if there was still life within it..."
	icon = 'icons/obj/structures.dmi'
	icon_state = "pile_bandages"

	var/revive_time = 120 SECONDS
	var/burn_time = 5 SECONDS
	var/on_fire = FALSE
	var/mob/living/carbon/human/cloth_golem

/obj/structure/cloth_pile/Initialize(mapload, mob/living/carbon/human/H)
	. = ..()
	if(!QDELETED(H) && is_species(H, /datum/species/golem/cloth))
		H.__unequip()
		H.forceMove(src)
		cloth_golem = H
		to_chat(cloth_golem, SPAN_NOTICE("You start gathering your life energy, preparing to rise again..."))
		addtimer(CALLBACK(src, nameof(.proc/revive)), revive_time)
	else
		return INITIALIZE_HINT_QDEL

/obj/structure/cloth_pile/Destroy()
	if(cloth_golem)
		QDEL_NULL(cloth_golem)
	return ..()

/obj/structure/cloth_pile/proc/revive()
	if(QDELETED(src) || QDELETED(cloth_golem)) //QDELETED also checks for null, so if no cloth golem is set this won't runtime
		return

	invisibility = INVISIBILITY_MAXIMUM //disappear before the animation
	new /obj/effect/mummy_animation(get_turf(src))
	cloth_golem.revive()
	sleep(2 SECONDS)
	cloth_golem.forceMove(get_turf(src))
	cloth_golem.visible_message(SPAN_DANGER("[src] rises and reforms into [cloth_golem]!"),SPAN_DANGER("You reform into yourself!"))
	cloth_golem = null
	qdel(src)


/obj/structure/cloth_pile/proc/update_name()
	if(on_fire)
		SetName("burning [initial(name)]")
	else
		SetName("dry [initial(name)]")

/obj/structure/cloth_pile/on_update_icon()
	if(on_fire)
		icon_state = "pile_bandages_lit"
	else
		icon_state = "pile_bandages"

/obj/structure/cloth_pile/proc/ignite()
	if(on_fire)
		return

	set_next_think(world.time)
	set_light(0.5, 0.1, 2, 2, "#e38f46")
	on_fire = 1
	update_name()
	update_icon()

/obj/structure/cloth_pile/attackby(obj/item/P, mob/living/carbon/human/user, params)
	. = ..()

	if(!on_fire && P.get_temperature_as_from_ignitor())
		ignite()
		visible_message(SPAN_DANGER("[src] bursts into flames!"))

/obj/structure/cloth_pile/think()
	var/turf/location = get_turf(loc)
	if(location)
		location.hotspot_expose(700, 5)

	if(burn_time <= 0)
		new /obj/effect/decal/cleanable/ash(loc)
		set_next_think(0)
		qdel(src)
		return
	update_name()
	burn_time--

	set_next_think(world.time+0.1)



/datum/species/golem/plastic
	name = SPECIES_GOLEM_PLASTIC
	prefix = "Plastic"
	special_names = list("Sheet", "Bag", "Bottle")
	fixed_mut_color = "#0a0a0a"
	info_text = "As a <span class='danger'>Plastic Golem</span>, you are capable of ventcrawling and passing through plastic flaps as long as you are naked."
	inherent_verbs = list(
		/mob/living/proc/ventcrawl
	)

/datum/component/golem/bronze
	var/last_gong_time = 0
	var/gong_cooldown = 25 SECONDS

/datum/species/golem/bronze
	name = SPECIES_GOLEM_BRONZE
	prefix = "Bronze"
	special_names = list("Bell")
	info_text = "As a <span class='danger'>Bronze Golem</span>, you are very resistant to loud noises, and make loud noises if something hard hits you, however this ability does hurt your hearing."
	icobase = 'icons/mob/human_races/golems/r_clock.dmi'

/datum/species/golem/bronze/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.AddComponent(/datum/component/golem/bronze)

/datum/species/golem/bronze/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	var/datum/component/golem/bronze/golem_comp = H.get_component(/datum/component/golem/bronze)
	qdel(golem_comp)

/datum/species/golem/bronze/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	var/datum/component/golem/bronze/golem_comp = H.get_component(/datum/component/golem/bronze)
	if(!(world.time > golem_comp.last_gong_time + golem_comp.gong_cooldown))
		return ..()
	if(P.check_armour == BULLET || P.check_armour == BOMB)
		gong(H)
		return FALSE

/datum/species/golem/bronze/handle_damage(mob/living/carbon/human/H)
	..()
	var/datum/component/golem/bronze/golem_comp = H.get_component(/datum/component/golem/bronze)
	if(world.time > golem_comp.last_gong_time + golem_comp.gong_cooldown)
		gong(H)

/datum/species/golem/bronze/proc/gong(mob/living/carbon/human/H)
	var/datum/component/golem/bronze/golem_comp = H.get_component(/datum/component/golem/bronze)
	golem_comp.last_gong_time = world.time
	for(var/mob/living/carbon/human/M in hearers(7, H.loc))
		if(M.stat == DEAD) //F
			continue
		if(M == H)
			H.show_message(SPAN_OCCULT(FONT_SMALL("You cringe with pain as your body rings around you!")), AUDIBLE_MESSAGE)
			H.playsound_local(H, 'sound/effects/gong.ogg', 100, TRUE)
			H.make_jittery(14 SECONDS)
		var/distance = max(0,get_dist(get_turf(H),get_turf(M)))
		switch(distance)
			if(0 to 1)
				M.show_message(SPAN_OCCULT(FONT_SMALL(("GONG!"))), AUDIBLE_MESSAGE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 100, TRUE)
				M.confused += 10
				M.make_jittery(8 SECONDS)
			if(2 to 3)
				M.show_message(SPAN_OCCULT("GONG!"), AUDIBLE_MESSAGE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 75, TRUE)
				M.make_jittery(6 SECONDS)
			else
				M.show_message(SPAN_WARNING("GONG!"), AUDIBLE_MESSAGE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 50, TRUE)

/datum/component/golem/cardboard
	var/datum/action/cooldown/golem/create_brother/create_action

/datum/species/golem/cardboard //Faster but weaker, can also make new shells on its own
	name = SPECIES_GOLEM_CARDBOARD
	prefix = "Cardboard"
	special_names = list("Box")
	icobase = 'icons/mob/human_races/golems/r_cardboard.dmi'
	info_text = "As a <span class='danger'>Cardboard Golem</span>, you aren't very strong, but you are a bit quicker and can easily create more brethren by using cardboard on yourself. Cardboard makes a poor building material for tongues, so you'll have difficulty speaking."
	fixed_mut_color = null
	brute_mod = 0.85
	burn_mod = 1.25
	movespeed_modifier = /datum/movespeed_modifier/golem_cardboard
	species_flags = SPECIES_FLAG_NO_PAIN | SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_POISON | SPECIES_FLAG_NO_BLOOD | SPECIES_FLAG_NO_ANTAG_TARGET | SPECIES_FLAG_NO_MINOR_CUT | SPECIES_FLAG_NO_EMBED | SPECIES_NO_LACE
	heat_level_1 = 400
	heat_level_2 = 500
	heat_level_3 = 1000

/datum/species/golem/cardboard/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	var/datum/component/golem/cardboard/golem_comp = H.AddComponent(/datum/component/golem/cardboard)
	golem_comp.create_action = new
	golem_comp.create_action.Grant(H)
	spawn(1)
		H.update_action_buttons()

/datum/species/golem/cardboard/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	var/datum/component/golem/cardboard/golem_comp = H.get_component(/datum/component/golem/cardboard)
	golem_comp.create_action.Remove(H)
	spawn(1)
		H.update_action_buttons()
	qdel(golem_comp)

/datum/action/cooldown/golem/create_brother

/datum/action/cooldown/golem/create_brother/Activate(atom/target)
	var/obj/item/I = owner.get_active_hand()
	if(!istype(I, /obj/item/stack/material/cardboard))
		to_chat(owner, SPAN_WARNING("You need to hold cardboard in hand!"))
		return

	var/obj/item/stack/C = I
	if(C.amount < 10)
		to_chat(owner, SPAN_WARNING("You do not have enough cardboard!"))
		return FALSE

	to_chat(owner, SPAN_NOTICE("You attempt to create a new cardboard brother."))
	var/mob/living/master = owner.mind.enslaved_to?.resolve()
	if(do_after(owner, 30, target = owner))
		if(!C.use(10))
			to_chat(owner, SPAN_WARNING("You do not have enough cardboard!"))
			return FALSE
		to_chat(owner, SPAN_NOTICE("You create a new cardboard golem shell."))
		StartCooldown()
		if(master)
			new /obj/effect/mob_spawn/ghost_role/human/golem/servant(get_turf(owner), SPECIES_GOLEM_CARDBOARD, master)
		else
			new /obj/effect/mob_spawn/ghost_role/human/golem(get_turf(owner), SPECIES_GOLEM_CARDBOARD)

/datum/species/golem/leather
	name = "Leather Golem"
	name = SPECIES_GOLEM_LEATHER
	special_names = list("Face", "Man", "Belt") //Ah dude 4 strength 4 stam leather belt AHHH
	species_flags = SPECIES_FLAG_NO_PAIN | SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_POISON | SPECIES_FLAG_NO_BLOOD | SPECIES_FLAG_NO_ANTAG_TARGET | SPECIES_FLAG_NO_MINOR_CUT | SPECIES_FLAG_NO_EMBED | SPECIES_NO_LACE
	heat_level_1 = 400
	heat_level_2 = 500
	heat_level_3 = 1000
	prefix = "Leather"
	fixed_mut_color = "#2E1600"
	info_text = "As a <span class='danger'>Leather Golem</span>, you are flammable, but you can grab things with incredible ease, allowing all your grabs to start at a strong level."

/datum/species/golem/mhydrogen //Effectively most other metal-based golem types rolled into one - immune to all weather, lava, flashes, and magic, while being just as hardened as diamond golems.
	name = SPECIES_GOLEM_HYDROGEN
	fixed_mut_color = "#3A3A55"
	brute_mod = 0.5
	info_text = "As a <span class='danger'>Metallic Hydrogen Golem</span>, you were forged in the highest pressures and the highest heats. Your unique material makeup makes you immune to magic and most environmental damage, while helping you resist most other attacks."
	prefix = "Metallic Hydrogen"
	special_names = list("Pressure","Crush")

/datum/species/golem/mhydrogen/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H, TRAIT_ANTIMAGIC)

/datum/species/golem/mhydrogen/on_species_loss(mob/living/carbon/human/H)
	REMOVE_TRAIT(H, TRAIT_ANTIMAGIC)
	return ..()
