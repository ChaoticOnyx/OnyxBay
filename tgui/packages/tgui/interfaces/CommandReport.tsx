import { useBackend, useLocalState } from "../backend";
import { Window } from "../layouts";
import {
  Section,
  Input,
  TextArea,
  Button,
  Stack,
  NoticeBox,
  Dropdown,
} from "../components";

interface CommandReportData {
  commandNamePresets: string[];
  announcerSounds: string[];
}

export const CommandReport = (props: CommandReportData, context: any) => {
  const { data, act } = useBackend<CommandReportData>(context);
  const { commandNamePresets, announcerSounds } = data;

  const [title, setTitle] = useLocalState(context, "title", "Central Command");
  const setCustomTitle = (title: string, use: boolean) => {
    setTitle(title);
    setUseCustomTitle(use);
  };
  const [useCustomTitle, setUseCustomTitle] = useLocalState(
    context,
    "customTitle",
    false
  );
  const [text, setText] = useLocalState(context, "text", "");
  const [sender, setSender] = useLocalState(context, "sender", "Common");
  const [sound, setSound] = useLocalState(
    context,
    "sound",
    "/datum/announce/command_report"
  );
  const [announceContents, setAnnounceContents] = useLocalState(
    context,
    "true",
    true
  );
  const [doNewscast, setDoNewscast] = useLocalState(context, "newscast", true);
  const [printReport, setPrintReport] = useLocalState(context, "report", true);
  const [reportSent, setReportSent] = useLocalState(
    context,
    "reportSent",
    false
  );
  return (
    <Window title="Create Command Report" width={330} height={690}>
      <Stack fill vertical>
        <Stack.Item>
          <Section title="Set Central Command name" textAlign="center">
            <Dropdown
              textAlign="center"
              width="100%"
              selected={title}
              options={commandNamePresets}
              onSelected={(value: string) => {
                value === "Custom Command Name"
                  ? setCustomTitle(value, true)
                  : setCustomTitle(value, false);
              }}
            />
            {useCustomTitle && (
              <Input
                textAlign="center"
                mt={1}
                width="100%"
                value={title}
                placeholder={title}
                onChange={(_, value: string) => {
                  setCustomTitle(value, true);
                }}
              />
            )}
          </Section>
        </Stack.Item>
        <Stack.Item>
          <Section title="Set announcement sound" textAlign="center">
            <Dropdown
              width="100%"
              selected={sound}
              options={announcerSounds}
              onSelected={(value: string) => setSound(value)}
            />
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Set report text" textAlign="center">
            <TextArea
              height="200px"
              mb={1}
              onChange={(_, value: string) => setText(value)}
              value={text}
            />
          </Section>
        </Stack.Item>
        <Stack.Item>
          <Section title="Set sender" textAlign="center">
            <Input
              maxLength={100}
              placeholder={sender}
              fluid
              onChange={(_, value: string) => {
                setSender(value);
              }}
            />
          </Section>
        </Stack.Item>
        <Stack.Item>
          <Section title="Report options" textAlign="center">
            <Stack vertical>
              <Stack.Item>
                <Button.Checkbox
                  fluid
                  checked={announceContents}
                  onClick={() => setAnnounceContents(!announceContents)}
                >
                  Announce Contents
                </Button.Checkbox>
                <Button.Checkbox
                  fluid
                  checked={doNewscast}
                  onClick={() => setDoNewscast(!doNewscast)}
                  tooltipPosition="top"
                >
                  Do Newscast
                </Button.Checkbox>
                <Button.Checkbox
                  fluid
                  checked={printReport}
                  onClick={() => setPrintReport(!printReport)}
                  tooltipPosition="top"
                >
                  Print Report
                </Button.Checkbox>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Button.Confirm
            fluid
            icon="check"
            textAlign="center"
            color="good"
            content="Submit Report"
            onClick={() => {
              act("submit_report", {
                title: title,
                sound: sound,
                text: text,
                sender: sender,
                announceContents: announceContents,
                doNewscast: doNewscast,
                printReport: printReport,
              });
              setReportSent(true);
            }}
          />
        </Stack.Item>
      </Stack>
    </Window>
  );
};
