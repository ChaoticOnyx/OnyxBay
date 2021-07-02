// rust-g lib definition

#ifndef WINDOWS_RUST_G_DLL_LOCATION
	#define WINDOWS_RUST_G_DLL_LOCATION "libs/rust_g.dll"
#endif

#ifndef UNIX_RUST_G_DLL_LOCATION
	#define UNIX_RUST_G_DLL_LOCATION "libs/librust_g.so"
#endif

#ifndef RUST_G_LOCATION
	#define RUST_G_LOCATION (world.system_type == MS_WINDOWS ? WINDOWS_RUST_G_DLL_LOCATION : UNIX_RUST_G_DLL_LOCATION)
#endif
