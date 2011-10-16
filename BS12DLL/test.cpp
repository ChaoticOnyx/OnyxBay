extern "C" const char* tick(int argc, char* args[]);
extern "C" const char* allocateMap(int argc, char* args[]);
void process_map();

int main() {
	char* args[] = { "200", "100", "8" };
	allocateMap(3, args);
	process_map();
}
