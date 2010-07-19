#define KSA_ICON_SIZE 32
#define KSA_MAX_ICON_DIMENSION 1024

#define KSA_TILES_PER_IMAGE (KSA_MAX_ICON_DIMENSION / KSA_ICON_SIZE)

#define KSA_TERMINALERR 5
#define KSA_INPROGRESS 2
#define KSA_BADOUTPUT 2
#define KSA_SUCCESS 1
#define KSA_WATCHDOGSUCCESS 4
#define KSA_WATCHDOGTERMINATE 3


//Call these procs to dump your world to a series of image files (!!)
//NOTE: Does not explicitly support non 32x32 icons or stuff with large pixel_* values, so don't blame me if it doesn't work perfectly

/mob/verb/ksa_DumpImage()
	set name = "Dump Map"
	ksa_DumpInternal()

/mob/verb/ksa_DumpImageSpecific()
	set name = "Dump Map from Offset"
	ksa_DumpInternal(text2num(input("X")), text2num(input("Y")), text2num(input("Z")))

/mob/verb/ksa_DumpImageSuperSpecific()
	set name = "Dump Single Map Section"
	ksa_DumpTile(text2num(input("X")), text2num(input("Y")), text2num(input("Z")))

/datum/ksa_descoper
	var/value = 0
	var/sx
	var/sy
	var/sz

/mob/proc/ksa_DumpInternal(var/sx = 1, var/sy = 1, var/sz = 1)

	var/Number_Images_X = ksa_Ceil(world.maxx / KSA_TILES_PER_IMAGE)
	var/Number_Images_Y = ksa_Ceil(world.maxy / KSA_TILES_PER_IMAGE)

	for(var/ImageZ = sz, ImageZ <= world.maxz, ImageZ++)
		for(var/ImageX = sx, ImageX <= Number_Images_X, ImageX++)
			for(var/ImageY = sy, ImageY <= Number_Images_Y, ImageY++)

				var/datum/ksa_descoper/crashwatch = new /datum/ksa_descoper()
				crashwatch.sx = ImageX
				crashwatch.sy = ImageY
				crashwatch.sz = ImageZ

				world.log << "Making [ImageX]-[ImageY]-[ImageZ]"
				sleep(2)

				spawn(40)
					if (crashwatch.value == KSA_SUCCESS)
						crashwatch.value = KSA_WATCHDOGSUCCESS
					else if (crashwatch.value == (KSA_INPROGRESS|KSA_BADOUTPUT))
						world.log << "Restarting make from [crashwatch.sx] [crashwatch.sy] [crashwatch.sz]"
						spawn(2)
							ksa_DumpInternal(crashwatch.sx, crashwatch.sy, crashwatch.sz)
						crashwatch.value = KSA_WATCHDOGTERMINATE

				crashwatch.value = KSA_INPROGRESS
				var/ccrash2 = ksa_DumpTile(ImageX, ImageY, ImageZ)

				if(crashwatch.value == KSA_INPROGRESS)
					crashwatch.value = ccrash2

				if(ccrash2 == KSA_BADOUTPUT)
					world.log << "Exported non [KSA_MAX_ICON_DIMENSION]x[KSA_MAX_ICON_DIMENSION] image, declaring failed fork."
					sleep(1)

				while (crashwatch.value != KSA_WATCHDOGSUCCESS)
					if (crashwatch.value == KSA_WATCHDOGTERMINATE)
						return
					sleep(10)

				sleep(20)

			sy = 1
		sx = 1
	world.log << "DONE"

/mob/proc/ksa_DumpTile(var/ImageX, var/ImageY, var/ImageZ)
	var/icon/Tile = icon(file("mapbase.png"))
	if (Tile.Width() != KSA_MAX_ICON_DIMENSION || Tile.Height() != KSA_MAX_ICON_DIMENSION)
		world.log << "<B>BASE IMAGE DIMENSIONS ARE NOT [KSA_MAX_ICON_DIMENSION]x[KSA_MAX_ICON_DIMENSION]</B>"
		world.log << "IF THEY ARE, IT MIGHT BE A BUG"
		world.log << "At any rate, export failed.  Try restarting the server"
		world.log << "then resume exporting from [ImageX] [ImageY] [ImageZ]"
		sleep(3)
		return KSA_TERMINALERR

	for(var/WorldX = 1 + ((ImageX - 1) * KSA_TILES_PER_IMAGE), WorldX <= (ImageX * KSA_TILES_PER_IMAGE) && WorldX <= world.maxx, WorldX++)
		for(var/WorldY = 1 + ((ImageY - 1) * KSA_TILES_PER_IMAGE), WorldY <= (ImageY * KSA_TILES_PER_IMAGE) && WorldY <= world.maxy, WorldY++)

			var/atom/Turf = locate(WorldX, WorldY, ImageZ)
			Tile.Blend(icon(Turf.icon, Turf.icon_state, Turf.dir, 1, 0), ICON_OVERLAY, ((WorldX - ((ImageX - 1) * KSA_TILES_PER_IMAGE)) * KSA_ICON_SIZE) - 31, ((WorldY - ((ImageY - 1) * KSA_TILES_PER_IMAGE)) * KSA_ICON_SIZE) - 31)

	for(var/WorldX = 1 + ((ImageX - 1) * KSA_TILES_PER_IMAGE), WorldX <= (ImageX * KSA_TILES_PER_IMAGE) && WorldX <= world.maxx, WorldX++)
		for(var/WorldY = 1 + ((ImageY - 1) * KSA_TILES_PER_IMAGE), WorldY <= (ImageY * KSA_TILES_PER_IMAGE) && WorldY <= world.maxy, WorldY++)

			var/atom/Turf = locate(WorldX, WorldY, ImageZ)

			var/LowestLayerLeftToDraw
			var/KeepDrawing = 1
			var/HighestDrawnLayer = 0

			while (KeepDrawing)
				LowestLayerLeftToDraw = 1e31
				KeepDrawing = 0
				for(var/atom/A in Turf)
					if (A.layer < LowestLayerLeftToDraw && A.layer > HighestDrawnLayer)
						LowestLayerLeftToDraw = A.layer
						KeepDrawing = 1

				for(var/atom/A in Turf)
					if (A.layer >= LowestLayerLeftToDraw)
						Tile.Blend(icon(A.icon, A.icon_state, A.dir, 1, 0), ICON_OVERLAY, ((WorldX - ((ImageX - 1) * KSA_TILES_PER_IMAGE)) * KSA_ICON_SIZE) - 31 + A.pixel_x, ((WorldY - ((ImageY - 1) * KSA_TILES_PER_IMAGE)) * KSA_ICON_SIZE) - 31 + A.pixel_y)
						HighestDrawnLayer = A.layer

			var/area/Li = Turf.loc
			if (Li.sd_light_level < 7 && Li.sd_light_level >= 0)
				Tile.Blend(icon('ss13_dark_alpha7.dmi', "[Li.sd_light_level]", SOUTH, 1, 0), ICON_OVERLAY, ((WorldX - ((ImageX - 1) * KSA_TILES_PER_IMAGE)) * KSA_ICON_SIZE) - 31, ((WorldY - ((ImageY - 1) * KSA_TILES_PER_IMAGE)) * KSA_ICON_SIZE) - 31)

	usr << browse(Tile, "window=picture;file=[ImageX]-[ImageY]-[ImageZ].png;display=0")

	if (Tile.Width() != KSA_MAX_ICON_DIMENSION || Tile.Height() != KSA_MAX_ICON_DIMENSION)
		return KSA_BADOUTPUT

	return KSA_SUCCESS

//prefixed with ksa_ to prevent any duplicate definitions.  Standard Ceiling function (e.g. 2 -> 2; 2.2 -> 3; 2.6 -> 3)
/proc/ksa_Ceil(var/num)
	var/a = round(num, 1)
	if (a < num)
		return a + 1
	return a