// Some code reducer helpers.
#define SPELL_DATA(path, cost) list("path" = path, "cost" = cost, "icon" = icon2base64html(path))
#define ARTEFACT_DATA(path, cost) SPELL_DATA(path, cost)
