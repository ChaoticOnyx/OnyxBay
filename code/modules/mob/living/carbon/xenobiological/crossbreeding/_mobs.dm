/// Transformed slime - from Burning Black
/mob/living/carbon/metroid/transformed_slime

// Just in case.
/mob/living/carbon/metroid/transformed_slime/Reproduce()
	to_chat(src, SPAN_WARNING("I can't reproduce...")) // Mood
	return

//Slime corgi - Chilling Pink
/mob/living/simple_animal/corgi/puppy/slime
	name = "\improper slime corgi puppy"
	real_name = "slime corgi puppy"
	desc = "An unbearably cute pink slime corgi puppy."
	icon_state = "slime_puppy"
	icon_living = "slime_puppy"
	icon_dead = "slime_puppy_dead"
	speak_emote = list("blorbles", "bubbles", "borks")
	emote_hear = list("bubbles!", "splorts.", "splops!")
	emote_see = list("gets goop everywhere.", "flops.", "jiggles!")
