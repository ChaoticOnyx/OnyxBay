/obj/sign
	icon = 'Signs.dmi'
	anchored = 1.0
	opacity = 0
	density = 0

/obj/sign/ex_act(severity)
	switch(severity)
		if (1)
			del(src)
		if (2)
			if (prob(50))
				del(src)
		if (3)
			if (prob(5))
				del(src)

/obj/sign/bio
	desc = "A warning sign which reads 'BIO HAZARD'"
	name = "BIO HAZARD"
	icon_state = "bio"

/obj/sign/electrical
	desc = "A warning sign which reads 'ELECTRICAL HAZARD'"
	name = "ELECTRICAL HAZARD"
	icon_state = "electrical"

/obj/sign/flammable
	desc = "A warning sign which reads 'FLAMMABLE AREA'"
	name = "FLAMMABLE AREA"
	icon_state = "flammable"

/obj/sign/nosmoking
	desc = "A warning sign which reads 'NO SMOKING'"
	name = "NO SMOKING"
	icon_state = "nosmoking"

/obj/sign/securearea
	desc = "A warning sign which reads 'SECURE AREA'"
	name = "SECURE AREA"
	icon_state = "securearea"

/obj/sign/space
	desc = "A warning sign which reads 'SPACE DEPRESSURIZATION'"
	name = "SPACE DEPRESSURIZATION"
	icon_state = "space"

