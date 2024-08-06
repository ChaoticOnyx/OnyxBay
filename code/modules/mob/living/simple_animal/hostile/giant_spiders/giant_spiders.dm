GLOBAL_LIST_EMPTY(spidermobs) //all sentient spider mobs

/datum/language/spider
	name = LANGUAGE_SPIDER
	desc = "A strange language that can be understood both by the sounds made and by the movement needed to create those sounds."
	signlang_verb = list("chitters", "grinds its mouthparts", "chitters and grinds its mouthparts")
	key = "p"
	language_flags = RESTRICTED | SIGNLANG | NO_STUTTER | NONVERBAL
	colour = ".spider"
	shorthand = "SR"

//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/giant_spider
	name = "giant spider"
	desc = "Furry and brown, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 10
	see_invisible = 15
	meat_type = /obj/item/reagent_containers/food/meat/xeno
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "pokes"
	stop_automated_movement_when_pulled = 0
	maxHealth = 200
	health = 200
	melee_damage_lower = 15
	melee_damage_upper = 25
	heat_damage_per_tick = 20
	cold_damage_per_tick = 20
	faction = "spiders"
	move_to_delay = 6
	speed = 1
	controllable = TRUE
	bodyparts = /decl/simple_animal_bodyparts/spider
	mob_bump_flag = ALLMOBS
	mob_swap_flags = ALLMOBS
	mob_push_flags = ALLMOBS
	///How much of a reagent the mob injects on attack
	var/poison_per_bite = 4
	///What reagent the mob injects targets with
	var/poison_type = /datum/reagent/toxin
	///Whether or not the spider is in the middle of an action.
	var/is_busy = FALSE
	///How quickly the spider can place down webbing.  One is base speed, larger numbers are slower.
	var/web_speed = 1
	///Whether or not the spider can create sealed webs.
	var/web_sealer = FALSE
	///The web laying ability
	var/datum/action/innate/spider/lay_web/lay_web
	///The message that the mother spider left for this spider when the egg was layed.
	var/directive = ""
	/// Short description of what this mob is capable of, for radial menu uses
	var/menu_description = "Versatile spider variant for frontline combat with high health and damage."

/mob/living/simple_animal/hostile/giant_spider/Login()
	. = ..()
	if(!client)
		return FALSE
	if(directive)
		to_chat(src, SPAN("spider", "Your mother left you a directive! Follow it at all costs."))
		to_chat(src, SPAN("spider", "<b>[directive]</b>"))
	GLOB.spidermobs[src] = TRUE
	update_action_buttons()

/mob/living/simple_animal/hostile/giant_spider/Destroy()
	GLOB.spidermobs -= src
	return ..()

/mob/living/simple_animal/hostile/giant_spider/New(location, atom/parent)
	get_light_and_color(parent)
	InitializeHud()

	GLOB.spidermobs.Add(src)

	lay_web = new
	lay_web.Grant(src)
	var/language = new /datum/language/spider
	languages.Add(language)
	default_language = language
	..()

/mob/living/simple_animal/hostile/giant_spider/UnarmedAttack(atom/target)
	. = ..()
	if(!.)
		return
	if(isliving(target))
		var/mob/living/L = .
		if(L.reagents)
			to_chat(L, SPAN_WARNING("You feel a tiny prick."))
			L.reagents.add_reagent(poison_type, 5)

/**
 * # Spider Hunter
 *
 * A subtype of the giant spider with purple eyes and toxin injection.
 *
 * A subtype of the giant spider which is faster, has toxin injection, but less health and damage.  This spider is only slightly slower than a human.
 */
/mob/living/simple_animal/hostile/giant_spider/hunter
	name = "hunter spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 100
	health = 100
	melee_damage_lower = 15
	melee_damage_upper = 20
	poison_per_bite = 10
	move_to_delay = 4
	speed = -0.1
	menu_description = "Fast spider variant specializing in catching running prey and toxin injection, but has less health and damage."

/**
 * # Spider Nurse
 *
 * A subtype of the giant spider with green eyes that specializes in support.
 *
 * A subtype of the giant spider which specializes in support skills.  Nurses can place down webbing in a quarter of the time
 * that other species can and can wrap other spiders' wounds, healing them.  Note that it cannot heal itself.
 */
/mob/living/simple_animal/hostile/giant_spider/nurse
	name = "nurse spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	gender = FEMALE
	maxHealth = 60
	health = 60
	speed = 0.75
	melee_damage_lower = 5
	melee_damage_upper = 20
	poison_per_bite = 4
	web_speed = 0.25
	web_sealer = TRUE
	menu_description = "Support spider variant specializing in healing their brethren and placing webbings very swiftly, but has very low amount of health and deals low damage."

/mob/living/simple_animal/hostile/giant_spider/nurse/Life()
	. = ..()
	process_med_hud(src)



/mob/living/simple_animal/hostile/giant_spider/nurse/UnarmedAttack(atom/target)
	. = target
	if(is_busy)
		return
	if(!istype(target, /mob/living/simple_animal/hostile/giant_spider))
		return ..()
	var/mob/living/simple_animal/hostile/giant_spider/hurt_spider = target

	if(hurt_spider == src)
		to_chat(src, SPAN_WARNING("You don't have the dexerity to wrap your own wounds."))
		return

	if(hurt_spider.health >= hurt_spider.maxHealth)
		to_chat(src, SPAN_WARNING("You can't find any wounds to wrap up."))
		return

	if(hurt_spider.is_ic_dead())
		to_chat(src, SPAN_WARNING("You're a nurse, not a miracle worker."))
		return

	visible_message(SPAN_NOTICE("[src] begins wrapping the wounds of [hurt_spider]."),SPAN_NOTICE("You begin wrapping the wounds of [hurt_spider]."))

	is_busy = TRUE

	if(do_after(src, 20, target = hurt_spider))
		hurt_spider.heal_overall_damage(20, 20)
		new /obj/effect/heal(get_turf(hurt_spider), "#80F5FF")
		visible_message(SPAN_NOTICE("[src] wraps the wounds of [hurt_spider]."),SPAN_NOTICE("You wrap the wounds of [hurt_spider]."))

	is_busy = FALSE

/**
 * # Tarantula
 *
 * The tank of spider subtypes.  Is incredibly slow when not on webbing, but has a lunge and the highest health and damage of any spider type.
 *
 * A subtype of the giant spider which specializes in pure strength and staying power.  Is slowed down greatly when not on webbing, but can lunge
 * to throw off attackers and possibly to stun them, allowing the tarantula to net an easy kill.
 */
/mob/living/simple_animal/hostile/giant_spider/tarantula
	name = "tarantula"
	desc = "Furry and black, it makes you shudder to look at it. This one has abyssal red eyes."
	icon_state = "tarantula"
	icon_living = "tarantula"
	icon_dead = "tarantula_dead"
	maxHealth = 400 // woah nelly
	health = 400
	melee_damage_lower = 35
	melee_damage_upper = 40
	poison_per_bite = 0
	move_to_delay = 8
	speed = 3
	menu_description = "Tank spider variant with an enormous amount of health and damage, but is very slow when not on webbing. It also has a charge ability to close distance with a target after a small windup."
	/// Whether or not the tarantula is currently walking on webbing.
	var/silk_walking = TRUE
	/// Charging ability
	var/datum/action/cooldown/charge/basic_charge/charge

/mob/living/simple_animal/hostile/giant_spider/tarantula/Initialize(mapload)
	. = ..()
	charge = new /datum/action/cooldown/charge/basic_charge/spider()
	charge.Grant(src)

/mob/living/simple_animal/hostile/giant_spider/tarantula/Destroy()
	QDEL_NULL(charge)
	return ..()

/mob/living/simple_animal/hostile/giant_spider/tarantula/MoveToTarget()
	if(client)
		return
	if(charge.IsAvailable())
		charge.ActivateOnClick(target_mob)
		return
	..()


/**
 * # Spider Viper
 *
 * The assassin of spider subtypes.  Essentially a juiced up version of the hunter.
 *
 * A subtype of the giant spider which specializes in speed and poison.  Injects a deadlier toxin than other spiders, moves extremely fast,
 * but like the hunter has a limited amount of health.
 */
/mob/living/simple_animal/hostile/giant_spider/viper
	name = "viper spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has effervescent purple eyes."
	icon_state = "viper"
	icon_living = "viper"
	icon_dead = "viper_dead"
	maxHealth = 60
	health = 60
	melee_damage_lower = 5
	melee_damage_upper = 10
	poison_per_bite = 7
	move_to_delay = 4
	poison_type = /datum/reagent/toxin/cyanide
	speed = -0.7
	menu_description = "Assassin spider variant with an unmatched speed and very deadly poison, but has very low amount of health and damage."

/**
 * # Spider Broodmother
 *
 * The reproductive line of spider subtypes.  Is the only subtype to lay eggs, which is the only way for spiders to reproduce.
 *
 * A subtype of the giant spider which is the crux of a spider horde.  Can lay normal eggs at any time which become normal spider types,
 * but by consuming human bodies can lay special eggs which can become one of the more specialized subtypes, including possibly another broodmother.
 * However, this spider subtype has no offensive capability and can be quickly dispatched without assistance from other spiders.  They are also capable
 * of sending messages to all living spiders, being a communication line for the rest of the horde.
 */
/mob/living/simple_animal/hostile/giant_spider/midwife
	name = "broodmother spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has scintillating green eyes. Might also be hiding a real knife somewhere."
	gender = FEMALE
	icon_state = "midwife"
	icon_living = "midwife"
	icon_dead = "midwife_dead"
	maxHealth = 300
	health = 300
	melee_damage_lower = 5
	melee_damage_upper = 25
	poison_per_bite = 5
	web_sealer = TRUE
	menu_description = "Royal spider variant specializing in reproduction and leadership, but has very low amount of health and deals low damage."
	///If the spider is trying to cocoon something, what that something is.
	var/atom/movable/cocoon_target
	///How many humans this spider has drained but not layed enriched eggs for.
	var/fed = 0
	///How long it takes for a broodmother to lay eggs.
	var/egg_lay_time = 15 SECONDS
	///The ability for the spider to wrap targets.
	var/datum/action/innate/spider/wrap/wrap
	///The ability for the spider to lay basic eggs.
	var/datum/action/innate/spider/lay_eggs/lay_eggs
	///The ability for the spider to lay enriched eggs.
	var/datum/action/innate/spider/lay_eggs/enriched/lay_eggs_enriched
	///The ability for the spider to set a directive, a message shown to the child spider player when the player takes control.
	var/datum/action/innate/spider/set_directive/set_directive
	///A shared list of all the mobs consumed by any spider so that the same target can't be drained several times.
	var/static/list/consumed_mobs = list() //the tags of mobs that have been consumed by nurse spiders to lay eggs
	///The ability for the spider to send a message to all currently living spiders.
	var/datum/action/innate/spider/comm/letmetalkpls

/mob/living/simple_animal/hostile/giant_spider/midwife/Initialize(mapload)
	. = ..()
	wrap = new
	wrap.Grant(src)
	lay_eggs = new
	lay_eggs.Grant(src)
	lay_eggs_enriched = new
	lay_eggs_enriched.Grant(src)
	set_directive = new
	set_directive.Grant(src)
	letmetalkpls = new
	letmetalkpls.Grant(src)

/**
 * Attempts to cocoon the spider's current cocoon_target.
 *
 * Attempts to coccon the spider's cocoon_target after a do_after.
 * If the target is a human who hasn't been drained before, ups the spider's fed counter so it can lay enriched eggs.
 */
/mob/living/simple_animal/hostile/giant_spider/midwife/proc/cocoon()
	if(is_ic_dead() || !cocoon_target || cocoon_target.anchored)
		return
	if(cocoon_target == src)
		to_chat(src, SPAN_WARNING("You can't wrap yourself!"))
		return
	if(istype(cocoon_target, /mob/living/simple_animal/hostile/giant_spider))
		to_chat(src, SPAN_WARNING("You can't wrap other spiders!"))
		return
	if(!Adjacent(cocoon_target))
		to_chat(src, SPAN_WARNING("You can't reach [cocoon_target]!"))
		return
	if(is_busy)
		to_chat(src, SPAN_WARNING("You're already doing something else!"))
		return
	is_busy = TRUE
	visible_message(SPAN_NOTICE("[src] begins to secrete a sticky substance around [cocoon_target]."),SPAN_NOTICE("You begin wrapping [cocoon_target] into a cocoon."))
	stop_automated_movement = TRUE
	if(do_after(src, 50, target = cocoon_target))
		if(is_busy)
			var/obj/structure/spider/cocoon/casing = new(cocoon_target.loc)
			if(isliving(cocoon_target))
				var/mob/living/living_target = cocoon_target
				if(ishuman(living_target) && (!living_target.is_ooc_dead() || !consumed_mobs[living_target.tag])) //if they're not dead, you can consume them anyway
					consumed_mobs[living_target.tag] = TRUE
					fed++
					visible_message(SPAN_NOTICE("[src] sticks a proboscis into [living_target] and sucks a viscous substance out."),SPAN_NOTICE("You suck the nutriment out of [living_target], feeding you enough to lay a cluster of eggs."))
					living_target.death() //you just ate them, they're dead.
				else
					to_chat(src, SPAN_WARNING("[living_target] cannot sate your hunger!"))
			cocoon_target.forceMove(casing)
			if(cocoon_target.density || ismob(cocoon_target))
				casing.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
	cocoon_target = null
	is_busy = FALSE
	stop_automated_movement = FALSE


/**
 * # Giant Ice Spider
 *
 * A giant spider immune to temperature damage.  Injects frost oil.
 *
 * A subtype of the giant spider which is immune to temperature damage, unlike its normal counterpart.
 * Currently unused in the game unless spawned by admins.
 */
/mob/living/simple_animal/hostile/giant_spider/ice
	name = "giant ice spider"
	minbodytemp = 0
	maxbodytemp = 1500
	poison_type = /datum/reagent/frostoil
	color = rgb(114,228,250)
	menu_description = "Versatile ice spider variant for frontline combat with high health and damage. Immune to temperature damage."

/**
 * # Ice Nurse Spider
 *
 * A nurse spider immune to temperature damage.  Injects frost oil.
 *
 * Same thing as the giant ice spider but mirrors the nurse subtype.  Also unused.
 */
/mob/living/simple_animal/hostile/giant_spider/nurse/ice
	name = "giant ice spider"
	minbodytemp = 0
	maxbodytemp = 1500
	poison_type = /datum/reagent/frostoil
	color = rgb(114,228,250)
	menu_description = "Support ice spider variant specializing in healing their brethren and placing webbings very swiftly, but has very low amount of health and deals low damage. Immune to temperature damage."

/**
 * # Ice Hunter Spider
 *
 * A hunter spider immune to temperature damage.  Injects frost oil.
 *
 * Same thing as the giant ice spider but mirrors the hunter subtype.  Also unused.
 */
/mob/living/simple_animal/hostile/giant_spider/hunter/ice
	name = "giant ice spider"
	minbodytemp = 0
	maxbodytemp = 1500
	poison_type = /datum/reagent/frostoil
	color = rgb(114,228,250)
	menu_description = "Fast ice spider variant specializing in catching running prey and frost oil injection, but has less health and damage. Immune to temperature damage."

/**
 * # Scrawny Hunter Spider
 *
 * A hunter spider that trades damage for health, unable to smash enviroments.
 *
 * Mainly used as a minor threat in abandoned places, such as areas in maintenance or a ruin.
 */
/mob/living/simple_animal/hostile/giant_spider/hunter/scrawny
	name = "scrawny spider"
	environment_smash = 0
	health = 60
	maxHealth = 60
	melee_damage_lower = 5
	melee_damage_upper = 10
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes, and looks abnormally thin and frail."
	menu_description = "Fast spider variant specializing in catching running prey and toxin injection, but has less damage than a normal hunter spider at the cost of a little more health."

/**
 * # Scrawny Tarantula
 *
 * A weaker version of the Tarantula, unable to smash enviroments.
 *
 * Mainly used as a moderately strong but slow threat in abandoned places, such as areas in maintenance or a ruin.
 */
/mob/living/simple_animal/hostile/giant_spider/tarantula/scrawny
	name = "scrawny tarantula"
	environment_smash = 0
	health = 150
	maxHealth = 150
	melee_damage_lower = 20
	melee_damage_upper = 25
	desc = "Furry and black, it makes you shudder to look at it. This one has abyssal red eyes, and looks abnormally thin and frail."
	menu_description = "A weaker variant of the tarantula with reduced amount of health and damage, very slow when not on webbing. It also has a charge ability to close distance with a target after a small windup."

/**
 * # Scrawny Nurse Spider
 *
 * A weaker version of the nurse spider with reduced health, unable to smash enviroments.
 *
 * Mainly used as a weak threat in abandoned places, such as areas in maintenance or a ruin.
 */
/mob/living/simple_animal/hostile/giant_spider/nurse/scrawny
	name = "scrawny nurse spider"
	environment_smash = 0
	health = 30
	maxHealth = 30
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes, and looks abnormally thin and frail."
	menu_description = "Weaker version of the nurse spider, specializing in healing their brethren and placing webbings very swiftly, but has very low amount of health and deals low damage."

/**
 * # Flesh Spider
 *
 * A giant spider subtype specifically created by changelings.  Built to be self-sufficient, unlike other spider types.
 *
 * A subtype of giant spider which only occurs from changelings.  Has the base stats of a hunter, but they can heal themselves.
 * They also produce web in 70% of the time of the base spider.  They also occasionally leave puddles of blood when they walk around.  Flavorful!
 */
/mob/living/simple_animal/hostile/giant_spider/hunter/flesh
	desc = "A odd fleshy creature in the shape of a spider.  Its eyes are pitch black and soulless."
	icon_state = "flesh_spider"
	icon_living = "flesh_spider"
	icon_dead = "flesh_spider_dead"
	web_speed = 0.7
	menu_description = "Self-sufficient spider variant capable of healing themselves and producing webbbing fast, but has less health and damage."

/mob/living/simple_animal/hostile/giant_spider/hunter/flesh/Initialize(mapload)
	. = ..()
	var/obj/effect/decal/cleanable/blood/gibs/gibs
	gibs.streak(GLOB.alldirs)

/mob/living/simple_animal/hostile/giant_spider/hunter/flesh/AttackingTarget()
	if(is_busy)
		return
	if(src == target_mob)
		if(health >= maxHealth)
			to_chat(src, SPAN_WARNING("You're not injured, there's no reason to heal."))
			return
		visible_message(SPAN_NOTICE("[src] begins mending themselves..."),SPAN_NOTICE("You begin mending your wounds..."))
		is_busy = TRUE
		if(do_after(src, 20))
			heal_overall_damage(50, 50)
			new /obj/effect/heal(get_turf(src), "#80F5FF")
			visible_message(SPAN_NOTICE("[src]'s wounds mend together."),SPAN_NOTICE("You mend your wounds together."))
		is_busy = FALSE
		return
	return ..()

/**
 * # Viper Spider (Wizard)
 *
 * A viper spider buffed slightly so I don't need to hear anyone complain about me nerfing an already useless wizard ability.
 *
 * A viper spider with buffed attributes.  All I changed was its health value and gave it the ability to ventcrawl.  The crux of the wizard meta.
 */
/mob/living/simple_animal/hostile/giant_spider/viper/wizard
	maxHealth = 80
	health = 80
	menu_description = "Stronger assassin spider variant with an unmatched speed, high amount of health and very deadly poison, but deals very low amount of damage. It also has ability to ventcrawl."
/decl/simple_animal_bodyparts/spider
	hit_zones = list("cephalothorax", "abdomen", "left forelegs", "right forelegs", "left hind legs", "right hind legs", "pedipalp", "mouthparts")
