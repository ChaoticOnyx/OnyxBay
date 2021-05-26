/mob/living/carbon/metroid/proc/GetMutations()
	switch(src.colour)
		if("green")
			return list("orange", "metal", "blue", "purple")
		if("purple")
			return list("dark purple", "dark blue", "grey", "grey")
		if("metal")
			return list("silver", "yellow", "gold", "gold")
		if("orange")
			return list("dark purple", "yellow", "red", "red")
		if("blue")
			return list("dark blue", "silver", "pink", "pink")
		//Tier 3
		if("dark blue")
			return list("purple", "cerulean", "blue", "blue")
		if("dark purple")
			return list("purple", "sepia", "orange", "orange")
		if("yellow")
			return list("bluespace", "metal", "orange", "orange")
		if("silver")
			return list("metal", "pyrite", "blue", "blue")
		//Tier 4
		if("pink")
			return list("pink", "pink", "light pink", "light pink")
		if("red")
			return list("red", "red", "oil", "oil")
		if("gold")
			return list("gold", "gold", "adamantine", "adamantine")
		if("grey")
			return list("grey", "grey", "black", "black")
		// Tier 5
		else
			return list()

/mob/living/carbon/metroid/proc/GetCoreType()
	switch(src.colour)
		// Tier 1
		if("green")
			return /obj/item/metroid_extract/green
		// Tier 2
		if("purple")
			return /obj/item/metroid_extract/purple
		if("metal")
			return /obj/item/metroid_extract/metal
		if("orange")
			return /obj/item/metroid_extract/orange
		if("blue")
			return /obj/item/metroid_extract/blue
		// Tier 3
		if("dark blue")
			return /obj/item/metroid_extract/darkblue
		if("dark purple")
			return /obj/item/metroid_extract/darkpurple
		if("yellow")
			return /obj/item/metroid_extract/yellow
		if("silver")
			return /obj/item/metroid_extract/silver
		// Tier 4
		if("pink")
			return /obj/item/metroid_extract/pink
		if("red")
			return /obj/item/metroid_extract/red
		if("gold")
			return /obj/item/metroid_extract/gold
		if("grey")
			return /obj/item/metroid_extract/grey
		if("sepia")
			return /obj/item/metroid_extract/sepia
		if("bluespace")
			return /obj/item/metroid_extract/bluespace
		if("cerulean")
			return /obj/item/metroid_extract/cerulean
		if("pyrite")
			return /obj/item/metroid_extract/pyrite
		//Tier 5
		if("light pink")
			return /obj/item/metroid_extract/lightpink
		if("oil")
			return /obj/item/metroid_extract/oil
		if("adamantine")
			return /obj/item/metroid_extract/adamantine
		if("black")
			return /obj/item/metroid_extract/black
	return /obj/item/metroid_extract/green
