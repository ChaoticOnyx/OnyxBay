/** Functions used for actual airflow. **/

// actual airflow Simulation
void process_tile(Simulation* sim, Tile* map, int x, int y, int z) {
	Tile* local = &map[get_tile_offset(sim, x, y, z)];

	if(! (local->flags & NONSPACE)) return; // don't do atmos processing for space

	if(x == 0) local->flags &= CWEST;
	else if(x==sim->maxx) local->flags &= CEAST;
	if(y == 0) local->flags &= CSOUTH;
	else if(y == sim->maxy) local->flags &= CNORTH;
	if(z == 0) local->flags &= CUP;
	else if(z == sim->maxz) local->flags &= CDOWN;

	// check if there's a space neighbour
	int space = 0; // space will contain the negation of all the flags of the neighbours, OR'd together
	if(!(local->flags & CNORTH)) {
		Tile* neighbour = &map[get_tile_offset(sim, x, y+1, z)];
		space |= ~neighbour->flags;
	}
	if(!(local->flags & CSOUTH)) {
		Tile* neighbour = &map[get_tile_offset(sim, x, y+1, z)];
		space |= ~neighbour->flags;
	}
	if(!(local->flags & CWEST)) {
		Tile* neighbour = &map[get_tile_offset(sim, x, y+1, z)];
		space |= ~neighbour->flags;
	}
	if(!(local->flags & CEAST)) {
		Tile* neighbour = &map[get_tile_offset(sim, x, y+1, z)];
		space |= ~neighbour->flags;
	}
	if(!(local->flags & CUP)) {
		Tile* neighbour = &map[get_tile_offset(sim, x, y+1, z)];
		space |= ~neighbour->flags;
	}
	if(!(local->flags & CDOWN)) {
		Tile* neighbour = &map[get_tile_offset(sim, x, y+1, z)];
		space |= ~neighbour->flags;
	}

	// if the following condition is true, we have a space neighbour
	if(space & NONSPACE) goto Space;

	for(int gas=0; gas<gases_end; gas++) {
		int target_volume = 0;
		int number_neighbours = 0;

		// I'm ORing flags instead of using IF because IF is pretty expensive
		if(!(local->flags & CNORTH)) {
			target_volume += map[get_tile_offset(sim, x, y + 1, z)].gases[gas];
			number_neighbours++;
		}
		if(!(local->flags & CSOUTH)) {
			target_volume += map[get_tile_offset(sim, x, y - 1, z)].gases[gas];
			number_neighbours++;
		}
		if(!(local->flags & CWEST)) {
			target_volume += map[get_tile_offset(sim, x - 1, y, z)].gases[gas];
			number_neighbours++;
		}
		if(!(local->flags & CEAST)) {
			target_volume += map[get_tile_offset(sim, x + 1, y, z)].gases[gas];
			number_neighbours++;
		}
		if(!(local->flags & CUP)) {
			target_volume += map[get_tile_offset(sim, x, y, z-1)].gases[gas];
			number_neighbours++;
		}
		if(!(local->flags & CDOWN)) {
			target_volume += map[get_tile_offset(sim, x, y, z+1)].gases[gas];
			number_neighbours++;
		}

		target_volume /= number_neighbours;

		if(!(local->flags & CNORTH)) {
			Tile* neighbour = &map[get_tile_offset(sim, x, y+1, z)];
			int delta = target_volume - neighbour->gases[gas];
			local->gases[gas]     += delta;
			neighbour->gases[gas] -= delta;
		}
		if(!(local->flags & CSOUTH)) {
			Tile* neighbour = &map[get_tile_offset(sim, x, y-1, z)];
			int delta = target_volume - neighbour->gases[gas];
			local->gases[gas]     += delta;
			neighbour->gases[gas] -= delta;
		}
		if(!(local->flags & CWEST)) {
			Tile* neighbour = &map[get_tile_offset(sim, x-1, y, z)];
			int delta = target_volume - neighbour->gases[gas];
			local->gases[gas]     += delta;
			neighbour->gases[gas] -= delta;
		}
		if(!(local->flags & CEAST)) {
			Tile* neighbour = &map[get_tile_offset(sim, x+1, y, z)];
			int delta = target_volume - neighbour->gases[gas];
			local->gases[gas]     += delta;
			neighbour->gases[gas] -= delta;
		}
		if(!(local->flags & CUP)) {
			Tile* neighbour = &map[get_tile_offset(sim, x, y, z-1)];
			int delta = target_volume - neighbour->gases[gas];
			local->gases[gas]     += delta;
			neighbour->gases[gas] -= delta;
		}
		if(!(local->flags & CDOWN)) {
			Tile* neighbour = &map[get_tile_offset(sim, x, y, z+1)];
			int delta = target_volume - neighbour->gases[gas];
			local->gases[gas]     += delta;
			neighbour->gases[gas] -= delta;
		}
	}

	return;

	Space:
	for(int gas=0; gas<gases_end; gas++) {
		local->gases[gas] = 0;
	}
}

// run a processing tick
void process_map() {
	Tile* map = get_map();
	Simulation* sim = get_simulation();
	for(int x=0; x < sim->maxx; x++) for(int y=0; y<sim->maxy; y++) for(int z=0; z<sim->maxz; z++) {
		process_tile(sim, map, x, y, z);
	}
}
