// Some code reducer helpers.
#define SPELL_DATA(path, cost) list("path" = path, "cost" = cost)
#define ARTIFACT_DATA(path, cost) SPELL_DATA(path, cost)
#define SACRIFICE_DATA(path) list("path" = path)
