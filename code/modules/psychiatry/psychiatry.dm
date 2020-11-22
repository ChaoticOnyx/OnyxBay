obj/psychiatry/disease
	var/last_attack_time = 0
	var/attack_period = 0
	var/attacks_to_destroy = INFINITY
	var/attacks = 0
	var/mob/living/carbon/human/owner

/obj/psychiatry/disease/proc/attack()
	return

/mob/living/carbon/human/var/list/obj/psychiatry/disease/diseases = list()

/mob/living/carbon/human/proc/handle_psychiatry()
	for(var/obj/psychiatry/disease/x in diseases)
		if(world.time > x.last_attack_time + x.attack_period)
			if(x.attacks > x.attacks_to_destroy)
				qdel(x)
				continue
			x.attack()
			x.last_attack_time = world.time
			++x.attacks

/mob/living/carbon/human/proc/add_disease(obj/psychiatry/disease/disease)
	disease.owner = src
	diseases += list(disease)

/mob/living/carbon/human/proc/add_random_disease()
#define ADD_DISEASE(x) add_disease(new /obj/psychiatry/disease/x)
	switch(rand(0, 3))
		if(0)
			ADD_DISEASE(schizophrenia)
		if(1)
			ADD_DISEASE(ocd)
		if(2)
			ADD_DISEASE(depression)
