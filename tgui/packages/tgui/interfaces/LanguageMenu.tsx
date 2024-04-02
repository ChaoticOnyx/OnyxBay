import { BooleanLike } from "common/react";
import { useBackend } from "../backend";
import { Button, Stack } from "../components";
import { Window } from "../layouts";

interface Language {
  key: string;
  name: string;
  desc: string;
  index: string;
  shorthand: string;
  canSpeak: BooleanLike;
  isKnown: BooleanLike;
  isSynthesized: BooleanLike;
}

interface InputData {
  isAdmin: string;
  isSilicon: boolean;
  languages: Language[];
  languagePrefix: string;
  currentLanguage: string;
}

export const LanguageMenu = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const { isAdmin, isSilicon, languages, languagePrefix, currentLanguage } =
    data;

  const onAddHandler = (language_key: string) => {
    act("add_language", { value: language_key });
  };
  const onRemoveHandler = (language_key: string) => {
    act("remove_language", { value: language_key });
  };
  const onChoiceHandler = (language_key: string) => {
    act("choose_language", { value: language_key });
  };

  return (
    <Window title="Language Menu" width={250} height={300}>
      <Window.Content scrollable style={{ "background-image": "none" }}>
        <Stack vertical>
          {languages.map((language) => (
            <Stack.Item>
              <LanguageButton
                key={language.key}
                prefix={languagePrefix}
                selected={language.name == currentLanguage}
                disabled={!!isSilicon && !!language.isSynthesized}
                advanced={!!isAdmin}
                language={language}
                onAdd={onAddHandler}
                onRemove={onRemoveHandler}
                onChoice={onChoiceHandler}
              />
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};

interface LanguageButtonProps {
  prefix: string;
  selected: Boolean;
  disabled: Boolean;
  advanced: Boolean;
  language: Language;
  onAdd: (language_key: string) => void;
  onRemove: (language_key: string) => void;
  onChoice: (language_key: string) => void;
}

const LanguageButton = (props: LanguageButtonProps, context: any) => {
  const {
    prefix,
    selected,
    disabled,
    advanced,
    language,
    onAdd,
    onRemove,
    onChoice,
  } = props;

  return (
    <Stack fill>
      {(language.isKnown && (
        <>
          <Stack.Item grow>
            <Button
              bold
              fluid
              selected={selected}
              disabled={disabled || !language.canSpeak}
              tooltip={language.desc}
              content={`${language.name} (${prefix}${language.key})`}
              onClick={() => onChoice(language.index)}
            />
          </Stack.Item>
          {advanced && (
            <Stack.Item>
              <Button
                icon="trash"
                color="bad"
                tooltip="Remove language"
                onClick={() => onRemove(language.index)}
              />
            </Stack.Item>
          )}
        </>
      )) ||
        (advanced && (
          <Stack.Item grow>
            <Button
              bold
              fluid
              icon="plus"
              color="good"
              tooltip={language.desc}
              content={`${language.name} (${prefix}${language.key})`}
              onClick={() => onAdd(language.index)}
            />
          </Stack.Item>
        ))}
    </Stack>
  );
};
