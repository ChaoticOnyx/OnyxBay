import { useBackend, useLocalState } from "../backend";
import { Window } from "../layouts";
import {
  Section,
  Box,
  Input,
  TextArea,
  Button,
  Stack,
  NoticeBox,
} from "../components";

export const BugReporter = (props: any, context: any) => {
  const { act } = useBackend(context);

  const [title, setReportTitle] = useLocalState(context, "name", "");
  const [messageText, setReportText] = useLocalState(context, "message", "");
  const [reportSent, setReportSent] = useLocalState(context, "false", false);

  return (
    <Window width={340} height={440}>
      <Window.Content>
        <Stack fill vertical>
          {reportSent ? (
            <>
              <NoticeBox fontSize={2}>
                Onyx community thanks you for sending this report!
              </NoticeBox>
              <Button
                fluid
                fontSize={1.2}
                onClick={() => {
                  setReportSent(false);
                }}
                textAlign="center"
              >
                Send another report
              </Button>
            </>
          ) : (
            <Stack.Item>
              <Section fontSize="16px" title="Title" textAlign="center">
                <Box fontSize="16px">
                  <Input
                    maxLength={100}
                    placeholder="Title of your report..."
                    fluid
                    onChange={(_, value: string) => {
                      setReportTitle(value);
                    }}
                  />
                </Box>
              </Section>
              <Section fontSize="16px" title="Report" textAlign="center">
                <Box>
                  <TextArea
                    fontSize="14px"
                    placeholder="Type the report you want to send..."
                    height="200px"
                    mb={1}
                    maxLength={1024}
                    onChange={(_, value: string) => {
                      setReportText(value);
                    }}
                  />
                </Box>
                <Box>
                  <Button.Confirm
                    fluid
                    icon="envelope-open-text"
                    onClick={() => {
                      act("sendReport", {
                        title: title,
                        text: messageText,
                      });
                      setReportSent(true);
                    }}
                  >
                    {" "}
                    Send Report
                  </Button.Confirm>
                </Box>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
