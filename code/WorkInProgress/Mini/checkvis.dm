/proc/checkcameravis(atom/A)
	for(var/obj/machinery/camera/C in view(6, A.loc))
		return 1
	return 0
