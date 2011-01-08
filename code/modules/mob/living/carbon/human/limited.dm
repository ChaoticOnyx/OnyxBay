mob/living/carbon/human/limited
	name = "limited"
	var/cansay = 0
	var/moveenabled = 0
	var/canlive
	var/atom/moveatom
	Move(NewLoc,Dir=0)
		if(src.moveenabled)
			if(src.moveatom)
				src.moveatom:Move(NewLoc,Dir)
			else
				..()

	Life()
		if(src.canlive)
			..()
	say()
		if(src.cansay)
			..()
	DblClick()
		return