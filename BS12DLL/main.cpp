#include <boost/lexical_cast.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/regex.hpp>
#include <string.h>
#include <string>

using boost::lexical_cast;
using boost::bad_lexical_cast;

#ifdef __WIN32
#include "windows.h"
#endif

#include "main.h"
#include "tile.hpp"

// Store metadata about the simulation.
struct Simulation {
	int maxx, maxy, maxz;
	int x, y, z; // the cursor/tile we're currently working with
};

// uses static information to get the map position
static inline Tile* get_map() {
	char** memrange = (char**) 0x50000000;
	return (Tile*) (*memrange)+sizeof(Simulation);
}

// uses static information to get the metadata
static inline Simulation* get_simulation() {
	Simulation** memrange = (Simulation**) 0x50000000;
	return *memrange;
}

static inline Tile* get_tile() {
	Simulation* sim = get_simulation();
	Tile* map = get_map();
	return &map[sim->x + sim->y * sim->maxx + sim->z * sim->maxy * sim->maxx];
}


// allocateMap(x,y,z)
extern "C" __declspec(dllexport) const char* allocateMap(int argc, char* args[]) {
	int x = lexical_cast<int>(args[0]);
	int y = lexical_cast<int>(args[1]);
	int z = lexical_cast<int>(args[2]);

	#ifdef _WIN32
		void** memrange = (void**) VirtualAlloc((void*) 0x50000000, 32, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
		if(memrange != (void*) 0x50000000) {
			return "failure";
		}
		size_t alloc_size = x * y * z * sizeof(Tile) + sizeof(Simulation);
		*memrange = malloc(alloc_size);
		if(!*memrange) return "failure";

		// initialize all the tiles to zero
		memset(*memrange, 0, alloc_size);

		Simulation* metadata = get_simulation();
		metadata->maxx = x;
		metadata->maxy = y;
		metadata->maxz = z;

		return "success";
	#endif
}

uint32* pointer_to_gas(Tile* tile, std::string gasname) {
	if(gasname == "oxygen") return &tile->oxygen;
	else return 0;
}

// setTile(x,y,z)
extern "C" __declspec(dllexport) const char* setTile(int argc, char* args[]) {
	Simulation* sim = get_simulation();
	sim->x = lexical_cast<int>(args[0]);
	sim->y = lexical_cast<int>(args[1]);
	sim->z = lexical_cast<int>(args[2]);
	return 0;
}

// setGas(gasname, amount)
extern "C" __declspec(dllexport) const char* setGas(int argc, char* args[]) {
	std::string gasname = lexical_cast<std::string>(args[0]);
	int32 amount = lexical_cast<int32>(args[1]);

	Tile* tile = get_tile();

	uint32* gas = pointer_to_gas(tile, gasname);
	if(gas) *gas = amount;

	return 0;

}

// addGas(gasname, amount)
extern "C" __declspec(dllexport) const char* addGas(int argc, char* args[]) {
	std::string gasname = lexical_cast<std::string>(args[0]);
	int32 amount = lexical_cast<int32>(args[1]);

	Tile* tile = get_tile();

	uint32* gas = pointer_to_gas(tile, gasname);
	if(gas) *gas += amount;

	return 0;
}

// getGas(gasname)
extern "C" __declspec(dllexport) const char* getGas(int argc, char* args[]) {
	std::string gasname = lexical_cast<std::string>(args[0]);

	Tile* tile = get_tile();

	uint32* gas = pointer_to_gas(tile, gasname);
	std::string rval = lexical_cast<std::string>(*gas);
	return rval.c_str();
}

// getTotalGas()
extern "C" __declspec(dllexport) const char* getTotalGas(int argc, char* args[]) {
	std::string gasname = lexical_cast<std::string>(args[0]);

	Tile* tile = get_tile();

	// return the sum of all gases
	std::string rval = lexical_cast<std::string>(tile->oxygen + tile->toxins + tile->co2 + tile->n2);
	return rval.c_str();
}

// setDensity()
extern "C" __declspec(dllexport) const char* setDensity(int argc, char* args[]) {
	Tile* tile = get_tile();

	tile->flags |= DENSITY;

	return 0;
}

// unsetDensity()
extern "C" __declspec(dllexport) const char* unsetDensity(int argc, char* args[]) {
	Tile* tile = get_tile();

	tile->flags &= ~DENSITY;

	return 0;
}

// setDefaultAtmosphere
extern "C" __declspec(dllexport) const char* setDefaultAtmosphere(int argc, char* args[]) {
	Tile* tile = get_tile();

	tile->n2     = 80000;
	tile->oxygen = 20000;

	return 0;
}
