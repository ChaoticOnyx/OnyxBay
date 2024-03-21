# Profiling

В билде есть поддержка профайлера [byond-tracy](https://github.com/mafemergency/byond-tracy) версии [cc015b63c4569929ab8e57a0dc2ab4363a77b188](https://github.com/mafemergency/byond-tracy/commit/cc015b63c4569929ab8e57a0dc2ab4363a77b188). Для его включения нужно скомпилироавть билд с `#define TRACY_PROFILER`.

## Использование

Для получения данных от профайлера к нему нужно подключиться с помощью Tracy, его можно скачать [отсюда](https://github.com/wolfpld/tracy) (выберите одну из поддерживаемых byond-tracy версию). Подключение можно начать в любой удобный момент времени - до или после старта билда.

Собранные данные можно сохранять в отдельный файл.
