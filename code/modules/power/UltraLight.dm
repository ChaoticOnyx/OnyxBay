var/const
	//These two have no purpose other than to clarify flags
	UL_LUMINOSITY = 0 //Use luminosity lighting, like sd_DAL
	UL_SQUARELIGHT = 0 //Use a traditional luminosity - getDist() lighting model

	UL_RGB = 1 //Use RGB lighting instead of luminosity only
	UL_ROUNDLIGHT = 2 //Use a rounded falloff lighting model

	UL_I_FALLOFF_SQUARE = 0
	UL_I_FALLOFF_ROUND = 1

	UL_I_LUMINOSITY = 0
	UL_I_RGB = 1

var
	ul_LightingEnabled = 1
	ul_LightingResolution = 1
	ul_Steps = 7
	ul_LightingModel = UL_I_RGB
	ul_FalloffStyle = UL_I_FALLOFF_SQUARE
	ul_TopLuminosity = 0
	ul_Layer = 10

atom/var
	LuminosityRed = 0
	LuminosityGreen = 0
	LuminosityBlue = 0
	ul_Extinguished = 1

turf/var
	LightLevelRed = 0
	LightLevelGreen = 0
	LightLevelBlue = 0

area/var
	ul_Overlay = null
	ul_Lighting = 1
	LightLevelRed = 0
	LightLevelGreen = 0
	LightLevelBlue = 0


proc/ul_BulkMove(atom/SourceAnchor, atom/DestAnchor, Height, Width, ReplaceTurfWith = world.turf)
	//TODO
	return

proc/ul_Clamp(Value)
	return min(max(Value, 0), ul_Steps)

atom/proc/ul_SetLuminosity(Red, Green = Red, Blue = Red)
	if(ul_IsLuminous())
		ul_Extinguish()
	LuminosityRed = Red
	LuminosityGreen = Green
	LuminosityBlue = Blue
	luminosity = ul_Luminosity()	//Adding this line
	if(ul_IsLuminous())
		ul_Illuminate()
	return

atom/proc/ul_Illuminate(list/V = view(ul_Luminosity(), src))

	if (!ul_Extinguished)
		return

	ul_Extinguished = 0

	ul_UpdateTopLuminosity()

	for(var/turf/Affected in V)
		var/Falloff = src.ul_FalloffAmount(Affected)

		var/DeltaRed = LuminosityRed - Falloff
		var/DeltaGreen = LuminosityGreen - Falloff
		var/DeltaBlue = LuminosityBlue - Falloff

		Affected.LightLevelRed += DeltaRed
		Affected.LightLevelGreen += DeltaGreen
		Affected.LightLevelBlue += DeltaBlue

		Affected.ul_UpdateLight()

		if (DeltaRed > 0 || DeltaGreen > 0 || DeltaBlue > 0)
			Affected.ul_LightLevelChanged()

			for(var/atom/AffectedAtom in Affected.contents)
				AffectedAtom.ul_LightLevelChanged()

	return

atom/proc/ul_Extinguish(list/LightingZone = view(ul_Luminosity(), src))

	if (ul_Extinguished)
		return

	ul_Extinguished = 1

	for(var/turf/Affected in LightingZone)

		var/Falloff = ul_FalloffAmount(Affected)

		var/DeltaRed = LuminosityRed - Falloff
		var/DeltaGreen = LuminosityGreen - Falloff
		var/DeltaBlue = LuminosityBlue - Falloff

		Affected.LightLevelRed -= max(DeltaRed, 0)
		Affected.LightLevelGreen -= max(DeltaGreen, 0)
		Affected.LightLevelBlue -= max(DeltaBlue, 0)

		Affected.ul_UpdateLight()

		if (DeltaRed > 0 || DeltaGreen > 0 || DeltaBlue > 0)
			Affected.ul_LightLevelChanged()

			for(var/atom/AffectedAtom in Affected)
				AffectedAtom.ul_LightLevelChanged()
	return


atom/New()
	..()
	if(ul_IsLuminous())
		spawn(1)
			ul_Illuminate()
	return

atom/Del()
	if(ul_IsLuminous())
		ul_Extinguish()
	..()
	return

atom/proc/ul_FalloffAmount(atom/ref)
	if (ul_FalloffStyle == UL_I_FALLOFF_ROUND)
		return round(ul_LightingResolution * (((ref.x - src.x) ** 2 + (ref.y - src.y) ** 2) ** 0.5), 1)
	else if (ul_FalloffStyle == UL_I_FALLOFF_SQUARE)
		return get_dist(src, ref)
	return 0


atom/proc/ul_SetOpacity(NewOpacity)
	if(opacity != NewOpacity)
		var/list/Blanked = ul_BlankLocal()
		var/atom/T = src
		while(T && !isturf(T))
			T = T.loc

		opacity = NewOpacity

		if(T)
			T:LightLevelRed = 0
			T:LightLevelGreen = 0
			T:LightLevelBlue = 0

		ul_UnblankLocal(Blanked)
	return

atom/proc/ul_UnblankLocal(list/ReApply = view(ul_TopLuminosity, src))
	for(var/atom/Light in ReApply)
		if(Light.ul_IsLuminous())
			Light.ul_Illuminate()
	return

atom/proc/ul_BlankLocal()
	var/list/Blanked = list( )
	var/TurfAdjust = isturf(src) ? 1 : 0
	for(var/atom/Affected in view(ul_TopLuminosity, src))
		if(Affected.ul_IsLuminous() && (ul_FalloffAmount(Affected) <= Affected.luminosity + TurfAdjust))
			Affected.ul_Extinguish()
			Blanked += Affected

	return Blanked


atom/movable/Move()
	ul_Extinguish()
	..()
	ul_Illuminate()
	return

atom/proc/ul_UpdateTopLuminosity()

	if (ul_TopLuminosity < LuminosityRed)
		ul_TopLuminosity = LuminosityRed

	if (ul_TopLuminosity < LuminosityGreen)
		ul_TopLuminosity = LuminosityGreen

	if (ul_TopLuminosity < LuminosityBlue)
		ul_TopLuminosity = LuminosityBlue

	return



atom/proc/ul_Luminosity()
	return max(LuminosityRed, LuminosityGreen, LuminosityBlue)

atom/proc/ul_IsLuminous(Red = LuminosityRed, Green = LuminosityGreen, Blue = LuminosityBlue)
	return (Red > 0 || Green > 0 || Blue > 0)

atom/proc/ul_LightLevelChanged()
	//Designed for client projects to use.  Called on items when the turf they are in has its light level changed

	return


turf/proc/ul_UpdateLight()

	var/area/Loc = src.loc
	if(!istype(Loc) || !Loc.ul_Lighting) return
	// change the turf's area depending on its brightness
	// restrict light to valid levels
	var/ltag = copytext(Loc.tag,1,findtext(Loc.tag,":UL")) + ":UL[ul_Clamp(LightLevelRed)]_[ul_Clamp(LightLevelGreen)]_[ul_Clamp(LightLevelBlue)]"

	if(Loc.tag!=ltag)	//skip if already in this area
		var/area/A = locate(ltag)	// find an appropriate area
		if(!A)
			A = new Loc.type()    // create area if it wasn't found
			A.tag = ltag

			// replicate vars
			for(var/V in Loc.vars-list("contents", "tag"))
				if(issaved(Loc.vars[V])) A.vars[V] = Loc.vars[V]

			A.tag = ltag

			A.ul_Light(LightLevelRed, LightLevelGreen, LightLevelBlue)
		A.contents += src	// move the turf into the area

	return

turf/proc/ul_Recalculate()
	var/list/Reset = ul_BlankLocal()
	LightLevelRed = 0
	LightLevelGreen = 0
	LightLevelBlue = 0
	ul_UnblankLocal(Reset)
	return



area/proc/ul_Light(Red = LightLevelRed as num, Green = LightLevelGreen as num, Blue = LightLevelBlue as num)
	if(!src)
		return

	overlays -= ul_Overlay

	LightLevelRed = Red
	LightLevelGreen = Green
	LightLevelBlue = Blue

	if(ul_Clamp(LightLevelRed) > 0 || ul_Clamp(LightLevelGreen) > 0 || ul_Clamp(LightLevelBlue) > 0)
		luminosity = 1
	else
		luminosity = 0

	ul_Overlay = image('ULIcons.dmi', , num2text(ul_Clamp(Red)) + "-" + num2text(ul_Clamp(Green)) + "-" + num2text(ul_Clamp(Blue)), ul_Layer)

	overlays += ul_Overlay

	return

area/Del()
	..()
	related -= src

area/proc/ul_Prep(var/ULCreated)
	if(!tag)
		tag = "[type]"
	spawn(1)
		if(ul_Lighting)
			if(!ULCreated)
				ul_Light()