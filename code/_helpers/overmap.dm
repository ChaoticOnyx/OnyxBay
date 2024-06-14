/**
A more accurate get_dist, that takes into account the looping edges of the overmap.
[Here's the algorithm in desmos](https://www.desmos.com/calculator/6akddpjzio)
*/

/proc/overmap_dist(atom/A,atom/B)
	if (!A || !B)
		return 0
	var/TX = (world.maxx / 2) - (TRANSITION_EDGE + 1)
	var/TY = (world.maxy / 2) - (TRANSITION_EDGE + 1)
	var/CX = A.x - B.x
	var/CY = A.y - B.y
	if (CX < -TX)
		CX = ((-CX % TX) - TX)
	else if (CX > TX)
		CX = (TX - (CX % TX))

	if (CY < -TY)
		CY = ((-CY % TY) - TY)
	else if (CY > TY)
		CY = (TY - (CY % TY))

	return sqrt(CX**2 + CY**2)

/**
Another get_angle that works better with the looping edges of the overmap
*/

/proc/overmap_angle(atom/A,atom/B)
	if (!A || !B)
		return 0
	var/TX = (world.maxx / 2) - (TRANSITION_EDGE + 1)
	var/TY = (world.maxy / 2) - (TRANSITION_EDGE + 1)
	var/CX = A.x - B.x//most of this is copied from the above proc
	var/CY = A.y - B.y
	if (CX < -TX)
		CX = ((-CX % TX) - TX)
	else if (CX > TX)
		CX = (TX - (CX % TX))
	else
		CX = -CX

	if (CY < -TY)
		CY = ((-CY % TY) - TY)
	else if (CY > TY)
		CY = (TY - (CY % TY))
	else
		CY = -CY

	if(!CY)//straight up copied from Get_Angle
		return (CX>=0)?90:270
	.=arctan(CX/CY)
	if(CY<0)
		.+=180
	else if(CX<0)
		.+=360

/atom/proc/get_overmap(failsafe = FALSE) //Helper proc to get the overmap ship representing a given area.
	if(isovermap(loc))
		return loc

	if(!z) // We're in something's contents
		if(!loc) // Or not...
			return FALSE

		return loc.get_overmap() // Begin recursion!

	return SSstar_system.find_main_overmap()
