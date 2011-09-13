/proc/checkcameravis(atom/A)
	for(var/obj/machinery/camera/C in view(6, A.loc))
		if(C.status)
			return 1
	return 0
