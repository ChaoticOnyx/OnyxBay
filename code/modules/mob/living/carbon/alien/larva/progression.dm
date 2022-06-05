#define DESC_EVOLVE "<span class='notice'><b>You are growing into a beautiful alien! It is time to choose a caste.</b>\nThere are three to choose from:</span>"
#define DESC_HUNTER "\n<B>Hunters</B> <span class='notice'> are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves.</span>"
#define DESC_SENTINEL "\n<B>Sentinels</B> <span class='notice'> are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters, but regenerate faster.</span>"
#define DESC_DRONE "\n<B>Drones</B> <span class='notice'> are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen.</span>"
#define DESC_HUNTER_FERAL "\n<B>Feral Hunters</B> <span class='notice'> are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves. <B>Tajaran genome further improves their claws and tails structure, making them much sharper.</B></span>"
#define DESC_SENTINEL_PRIMAL "\n<B>Primal Sentinels</B> <span class='notice'> are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters, but regenerate faster. <B>Unathi genome slightly increases their thermal resistance and drastically improves regenerative abilities.</B></span>"
#define DESC_DRONE_VILE "\n<B>Vile Drones</B> <span class='notice'> are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen. <B>Skrellian genome improves their intelligence, as well as the plasma secretion rate.</B></span>"

/mob/living/carbon/alien/larva/confirm_evolution()
	to_chat(src, DESC_EVOLVE + DESC_HUNTER + DESC_SENTINEL + DESC_DRONE)
	var/alien_caste = alert(src, "Please choose which alien caste you shall belong to.",,"Hunter","Sentinel","Drone")
	return alien_caste ? "Xenomorph [alien_caste]" : null

/mob/living/carbon/alien/larva/show_evolution_blurb()
	return
