#define EGG_LAYING_MESSAGES list("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")
/obj/item/organ/internal/heart/gland/egg
	abductor_hint = "roe/enzymatic synthesizer. The abductee will periodically lay eggs filled with random reagents."
	cooldown_low = 300
	cooldown_high = 400
	uses = -1
	mind_control_uses = 2
	mind_control_duration = 1800

/obj/item/organ/internal/heart/gland/egg/activate()
	owner.visible_message(SPAN_DANGER("[owner] [pick(EGG_LAYING_MESSAGES)]"))
	var/turf/T = owner.loc
	new /obj/item/reagent_containers/food/snacks/egg/gland(T)

/obj/item/reagent_containers/food/snacks/egg/gland
	desc = "An egg! It looks weird..."

/obj/item/reagent_containers/food/snacks/egg/gland/Initialize()
	. = ..()
	reagents.add_reagent(pick(subtypesof(/datum/reagent - /datum/reagent/adminordrazine)))

/obj/item/reagent_containers/food/snacks/egg/gland/Process() //Why it's even needed to be proccessed?
		return PROCESS_KILL
