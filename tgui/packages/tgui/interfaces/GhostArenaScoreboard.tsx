import { useBackend } from "../backend";
import { Button, LabeledList, NoticeBox, ProgressBar, Section, Stack } from "../components"
import { Window } from "../layouts"

type Player = {
  name: string;
  kills: number;
  assists: number;
  deaths: number;
};

type InputData = {
  players: Player[];
};

function PlayersList(props: Player[], context: any) {
  const { act } = useBackend<InputData>(context);
  return (
    <Stack vertical>
      {props.map(player => (
        <Stack.Item>
          <Section
          fill
          title={(player.name)}
          buttons={
            <Stack>
              <Stack.Item fontSize="14px" color="green">
                {player.kills} Kills:
              </Stack.Item>
              <Stack.Item fontSize="14px" color="green">
                {player.assists} Assists:
              </Stack.Item>
              <Stack.Item fontSize="14px" color="green">
                {player.deaths} Deaths:
              </Stack.Item>
            </Stack>
          }>
          </Section>
        </Stack.Item>
      ))}
    </Stack>
  );
}

export function GhostArenaScoreboard(props: any, context: any) {
  const { getTheme, data, act } = useBackend<InputData>(context);

  return (
    <Window theme={getTheme("neutral")} width={400} height={300}>
      <Window.Content fitted>
        {data.players.length ? (
          PlayersList(data.players, context)
        ) : (
          <NoticeBox>No teams found, Toolbox Strike: Greytide Offensive seems to be offline!</NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
}
