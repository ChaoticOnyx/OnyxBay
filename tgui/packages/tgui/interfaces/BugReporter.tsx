import { useBackend, useLocalState } from "../backend";
import { Window } from "../layouts";
import { Section, Box, Input, TextArea, Button } from "../components";

export const BugReporter = (props: any, context: any) => {
  const { act } = useBackend(context);

  const [title, setReportTitle] = useLocalState(context, "name", "");
  const [messageText, setReportText] = useLocalState(context, "message", "");

  return (
    <Window width={340} height={440}>
      <Window.Content>
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
            <Button
              fluid
              icon="envelope-open-text"
              Send
              Report
              onClick={() =>
                act("sendReport", {
                  title: title,
                  text: messageText,
                })
              }
            />
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
