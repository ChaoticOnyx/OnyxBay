import { useBackend } from "../backend";
import { Box, Button, NoticeBox, Section, Stack, Divider } from "../components";
import { Window } from "../layouts";
import { resolveAsset } from "../assets";

type PageMeta = { i: number; title: string };

type Data = {
  error?: string | null;
  browsing?: boolean;

  filename: string;

  files?: { name: string; size: number }[];
  usbconnected?: boolean;
  usbfiles?: { name: string; size: number }[];

  page_index?: number;
  page_count?: number;
  page_html?: string;
  pages?: PageMeta[];

  PC_hasheader?: boolean;

  PC_batteryicon?: string;
  PC_batterypercent?: string;
  PC_showbatteryicon?: boolean;

  PC_ntneticon?: string;
  PC_apclinkicon?: string;

  PC_stationtime?: string;

  PC_programheaders?: { icon: string }[];

  PC_showexitprogram?: boolean;
};

const MAX_PAGES_UI = 50;

const PcHeader = (props: { act: any; data: any }) => {
  const { act, data } = props;
  if (!data?.PC_hasheader) return null;

  const img = (name?: string, title?: string) => {
    if (!name) return null;
    const src = resolveAsset(name);
    return <Box as="img" src={src} title={title} className="WordProcessor__hdrIcon" />;
  };

  return (
    <Box className="WordProcessor__topbar">
      <Stack align="center">
        <Stack.Item grow>
          <Box className="WordProcessor__topbarLeft">
            {!!data.PC_showbatteryicon && (
              <>
                {img(data.PC_batteryicon, "Battery")}
                {!!data.PC_batterypercent && (
                  <Box className="WordProcessor__counter">{data.PC_batterypercent}</Box>
                )}
              </>
            )}

            {img(data.PC_ntneticon, "NTNet")}
            {img(data.PC_apclinkicon, "APC Link")}

            {!!data.PC_stationtime && (
              <Box className="WordProcessor__counter">{data.PC_stationtime}</Box>
            )}

            {(data.PC_programheaders || []).map((p, idx) => (
              <Box key={idx}>{img(p.icon, "Program")}</Box>
            ))}
          </Box>
        </Stack.Item>

        <Stack.Item>
          <Box className="WordProcessor__topbarRight">
            <Button className="WordProcessor__btnWide" icon="power-off" onClick={() => act("PC_shutdown")}>
              Shutdown
            </Button>

            {!!data.PC_showexitprogram && (
              <>
                <Button className="WordProcessor__btnWide" icon="xmark" onClick={() => act("PC_exit")}>
                  Exit
                </Button>
                <Button className="WordProcessor__btnWide" icon="window-minimize" onClick={() => act("PC_minimize")}>
                  Minimize
                </Button>
              </>
            )}
          </Box>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

export const WordProcessor = (props, context) => {
  const { act, data } = useBackend<Data>(context);

  const browsing = !!data.browsing;

  const pageIndex = data.page_index || 1;
  const pageCountRaw = data.page_count || 1;
  const pageCount = Math.min(pageCountRaw, MAX_PAGES_UI);

  const canPrev = pageIndex > 1;
  const canNext = pageIndex < pageCount;

  const visiblePages = (data.pages || []).slice(0, MAX_PAGES_UI);

  return (
    <Window width={820} height={550} title="NanoWord">
      <Window.Content scrollable={false} className="WordProcessor__windowContent">
        <Box className="WordProcessor">
          <PcHeader act={act} data={data} />

          {!!data.error ? (
            <NoticeBox>
              <Box mb={1}>
                <b>Ошибка:</b> {data.error}
              </Box>
              <Button onClick={() => act("back_to_menu")}>Назад</Button>
            </NoticeBox>
          ) : (
            <Box className="WordProcessor__main">
              <Section
                fill
                title={browsing ? "Документы" : `Документ: ${data.filename}`}
                className="WordProcessor__content"
                buttons={
                  <Box className="WordProcessor__docBar WordProcessor__docBarScroll">
                    {!browsing ? (
                      <>
                        <Button className="WordProcessor__btnWide" icon="file" onClick={() => act("new_file")}>
                          Новый
                        </Button>
                        <Button className="WordProcessor__btnWide" icon="folder-open" onClick={() => act("load_menu")}>
                          Загрузить
                        </Button>
                        <Button className="WordProcessor__btnWide" icon="floppy-disk" onClick={() => act("save_file")}>
                          Сохранить
                        </Button>
                        <Button className="WordProcessor__btnWide" icon="file-export" onClick={() => act("save_as")}>
                          Сохранить как
                        </Button>

                        <Divider vertical />

                        <Button className="WordProcessor__btnWide" icon="circle-question" onClick={() => act("taghelp")}>
                          Справка
                        </Button>
                        <Button className="WordProcessor__btnWide" icon="print" onClick={() => act("print_all")}>
                          Печать…
                        </Button>
                      </>
                    ) : (
                      <Button className="WordProcessor__btnWide" icon="arrow-left" onClick={() => act("close_browser")}>
                        Назад к редактору
                      </Button>
                    )}
                  </Box>
                }
              >
                {browsing ? (
                  <Stack vertical>
                    <Section title="Локальные документы">
                      <Stack vertical>
                        {(data.files || []).map((f) => (
                          <Stack key={f.name} align="center">
                            <Box grow>{f.name}</Box>
                            <Box mr={1}>{f.size} GQ</Box>
                            <Button onClick={() => act("open_file", { name: f.name })}>Открыть</Button>
                          </Stack>
                        ))}
                        {!data.files?.length && <Box italic opacity={0.7}>Нет файлов</Box>}
                      </Stack>
                    </Section>

                    {!!data.usbconnected && (
                      <Section title="Портативный носитель">
                        <Stack vertical>
                          {(data.usbfiles || []).map((f) => (
                            <Stack key={f.name} align="center">
                              <Box grow>{f.name}</Box>
                              <Box mr={1}>{f.size} GQ</Box>
                              <Button onClick={() => act("open_file", { name: f.name })}>Открыть</Button>
                            </Stack>
                          ))}
                          {!data.usbfiles?.length && <Box italic opacity={0.7}>Нет файлов</Box>}
                        </Stack>
                      </Section>
                    )}
                  </Stack>
                ) : (
                  <Stack fill className="WordProcessor__cols">
                    {/* Левая панель страниц */}
                    <Stack.Item basis="210px" shrink={0} className="WordProcessor__sidebar">
                      <Section title="Стр.">
                        <Box className="WordProcessor__pagesHeader">
                          <Box className="WordProcessor__pager">
                            <Button
                              className="WordProcessor__btn"
                              icon="arrow-left"
                              disabled={!canPrev}
                              onClick={() => act("set_page", { i: pageIndex - 1 })}
                              title="Предыдущая"
                            />
                            <Box className="WordProcessor__pagerText">
                              {Math.min(pageIndex, pageCount)}/{pageCount}
                            </Box>
                            <Button
                              className="WordProcessor__btn"
                              icon="arrow-right"
                              disabled={!canNext}
                              onClick={() => act("set_page", { i: pageIndex + 1 })}
                              title="Следующая"
                            />
                          </Box>

                          <Box className="WordProcessor__pageActions">
                            <Button
                              className="WordProcessor__btn"
                              icon="plus"
                              title={pageCountRaw >= MAX_PAGES_UI ? "Лимит 50 страниц" : "Добавить после"}
                              disabled={pageCountRaw >= MAX_PAGES_UI}
                              onClick={() => act("add_page_after", { i: pageIndex })}
                            />
                            <Button className="WordProcessor__btn" icon="clone" title="Дублировать" onClick={() => act("duplicate_page", { i: pageIndex })} />
                            <Button className="WordProcessor__btn" icon="trash" title="Удалить" onClick={() => act("delete_page", { i: pageIndex })} />
                          </Box>
                        </Box>

                        <Box className="WordProcessor__pagesGrid">
                          {visiblePages.map((p) => (
                            <Button
                              key={p.i}
                              className="WordProcessor__pageNumBtn"
                              selected={p.i === pageIndex}
                              onClick={() => act("set_page", { i: p.i })}
                              title={`Страница ${p.i}`}
                            >
                              {p.i}
                            </Button>
                          ))}
                        </Box>

                        {pageCountRaw > MAX_PAGES_UI && (
                          <Box mt={1} opacity={0.75} italic>
                            Показаны первые {MAX_PAGES_UI} страниц.
                          </Box>
                        )}
                      </Section>
                    </Stack.Item>

                    {/* Правая панель предпросмотра */}
                    <Stack.Item grow className="WordProcessor__rightCol">
                      <Section
                        fill
                        title={`${Math.min(pageIndex, pageCount)}/${pageCount}`}
                        buttons={
                          <Stack align="center">
                            <Button className="WordProcessor__btnWide" icon="pen" onClick={() => act("edit_page", { i: pageIndex })}>
                              Редактировать
                            </Button>
                            <Button className="WordProcessor__btnWide" icon="eye" onClick={() => act("preview_page", { i: pageIndex })}>
                              Превью
                            </Button>
                            <Button className="WordProcessor__btnWide" icon="print" onClick={() => act("print_page", { i: pageIndex })}>
                              Печать
                            </Button>
                          </Stack>
                        }
                      >
                        {/* КЛЮЧ: делаем внутренний контейнер height:100% */}
                        <Box className="WordProcessor__rightFill">
                          <Box className="WordProcessor__rightBody">
                            <div className="WordProcessor__previewWrap">
                              <div
                                className="WordProcessor__preview"
                                // @ts-ignore
                                dangerouslySetInnerHTML={{ __html: data.page_html || "" }}
                              />
                            </div>
                          </Box>
                        </Box>
                      </Section>
                    </Stack.Item>
                  </Stack>
                )}
              </Section>
            </Box>
          )}
        </Box>
      </Window.Content>
    </Window>
  );
};
