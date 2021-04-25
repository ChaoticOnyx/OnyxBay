/mob/living/carbon/alien/larva/feral
	name = "alien feral larva"
	real_name = "alien feral larva"
	//icon_state = "larva_taj"

/mob/living/carbon/alien/larva/feral/confirm_evolution()

	to_chat(src, "<span class='notice'><b>You are growing into a beautiful alien! It is time to choose a caste.</b></span>")
	to_chat(src, "<span class='notice'>There are three to choose from:</span>")
	to_chat(src, "<B>Feral Hunters</B> <span class='notice'> are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves. <B>Tajaran genome further improves their claws and tails structure, making them much sharper.</B></span>")
	to_chat(src, "<B>Sentinels</B> <span class='notice'> are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters, but regenerate faster.</span>")
	to_chat(src, "<B>Drones</B> <span class='notice'> are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen.</span>")
	var/alien_caste = alert(src, "Please choose which alien caste you shall belong to.",,"Feral Hunter","Sentinel","Drone")
	return alien_caste ? "Xenomorph [alien_caste]" : null

/mob/living/carbon/alien/larva/primal
	name = "alien primal larva"
	real_name = "alien primal larva"
	//icon_state = "larva_unathi"

/mob/living/carbon/alien/larva/primal/confirm_evolution()

	to_chat(src, "<span class='notice'><b>You are growing into a beautiful alien! It is time to choose a caste.</b></span>")
	to_chat(src, "<span class='notice'>There are three to choose from:</span>")
	to_chat(src, "<B>Hunters</B> <span class='notice'> are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves.</span>")
	to_chat(src, "<B>Primal Sentinels</B> <span class='notice'> are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters, but regenerate faster. <B>Unathi genome slightly increases their thermal resistance and drastically improves regenerative abilities.</B></span>")
	to_chat(src, "<B>Drones</B> <span class='notice'> are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen.</span>")
	var/alien_caste = alert(src, "Please choose which alien caste you shall belong to.",,"Hunter","Primal Sentinel","Drone")
	return alien_caste ? "Xenomorph [alien_caste]" : null

/mob/living/carbon/alien/larva/vile
	name = "alien vile larva"
	real_name = "alien vile larva"
	//icon_state = "larva_skrell"

/mob/living/carbon/alien/larva/vile/confirm_evolution()

	to_chat(src, "<span class='notice'><b>You are growing into a beautiful alien! It is time to choose a caste.</b></span>")
	to_chat(src, "<span class='notice'>There are three to choose from:</span>")
	to_chat(src, "<B>Hunters</B> <span class='notice'> are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves.</span>")
	to_chat(src, "<B>Sentinels</B> <span class='notice'> are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters, but regenerate faster..</span>")
	to_chat(src, "<B>Vile Drones</B> <span class='notice'> are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen. <B>Skrellian genome improves their intelligence, as well as the plasma secretion rate.</B></span> ")
	var/alien_caste = alert(src, "Please choose which alien caste you shall belong to.",,"Hunter","Sentinel","Vile Drone")
	return alien_caste ? "Xenomorph [alien_caste]" : null

