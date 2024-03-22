import { useBackend } from "../backend";
import { Button, LabeledList, Section, Stack } from "../components";
import { Window } from "../layouts";

interface Language {
  name: string;
  shorthand: string;
  prefix: string;
  key: string;
  desc: string;
  can_speak: boolean;
  synthesizer: boolean;
}

interface InputData {
  adminMode: string;
  defaultLanguage: string;
  isSilicon: boolean;
  languages: Language[];
}

export const LanguageMenu = (props: any, context: any) => {
  const { act, data, getTheme } = useBackend<InputData>(context);
  return (
    <Window title="Language Menu" width={300} height={250}>
      <Window.Content scrollable>
        <Section fitted title="Known Languages" />
        <Stack vertical>
          {data.languages?.map((language) => (
            <Stack.Item>
              <Stack>
                <Stack.Item grow>
                  <Button
                    fluid
                    bold
                    color={
                      data.defaultLanguage === language.name
                        ? "good"
                        : "default"
                    }
                    disabled={!language.can_speak}
                    tooltip={language.desc}
                    content={`${language.name} (${language.prefix}${language.key})`}
                    onClick={() =>
                      act("choose_language", { language: language.name })
                    }
                  >
                    {data.isSilicon && !language.synthesizer
                      ? " NOT SUPPORTED!"
                      : ""}
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  {data.adminMode ? (
                    <Button
                      icon="trash"
                      color="bad"
                      tooltip="Remove language"
                      onClick={() =>
                        act("remove_language", { language: language.name })
                      }
                    ></Button>
                  ) : (
                    <></>
                  )}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
