/obj/structure/sofa
	name = "comfy sofa"
	desc = "So lovely, uh."
	icon = 'icons/obj/furniture.dmi'
	icon_state = "sofa_right"
	anchored = TRUE
	can_buckle = TRUE


/obj/structure/sofa/left
	icon_state = "sofa_left"


/obj/structure/sofa/update_icon()
	..()
	if(src.dir == NORTH)
		src.layer = 5
	else
		src.layer = OBJ_LAYER


/obj/structure/sofa/black
	icon_state = "couchblack_middle"

/obj/structure/sofa/black/left
	icon_state = "couchblack_left"

/obj/structure/sofa/black/right
	icon_state = "couchblack_right"


/obj/structure/sofa/beige
	icon_state = "couchbeige_middle"

/obj/structure/sofa/beige/left
	icon_state = "couchbeige_left"

/obj/structure/sofa/beige/right
	icon_state = "couchbeige_right"


/obj/structure/sofa/brown
	icon_state = "couchbrown_middle"

/obj/structure/sofa/brown/left
	icon_state = "couchbrown_left"

/obj/structure/sofa/brown/right
	icon_state = "couchbrown_right"