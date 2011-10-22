// the other procs and vars related to blood should also be moved here at some point

mob/living/carbon/proc/inject_blood(datum/reagent/blood/B)
	// TODO: if the blood types are incompatible, bad things should happen
	if(prob(5)) src.antibodies |= B.antibodies // add the antibodies
	infect_microorganism(src,B.microorganism)