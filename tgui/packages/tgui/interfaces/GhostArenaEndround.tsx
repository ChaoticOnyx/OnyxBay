import { useBackend } from "../backend";
import { Box, Icon, Stack, Button, Section, NoticeBox, LabeledList, Flex, Divider } from '../components';
import { Window } from "../layouts"

type Player = {
  name: string;
  kills: number;
  deaths: number;
  color: string;
};

type Gamemode = {
  name: string;
};

type Map = {
  name: string;
};

type Data = {
  players: Player[];
  gamemodeVote: string[];
  mapVote: string[];
  timeRemaining: number;
  winner: string;
  roundend: boolean;
};

function PlayersList(props: Player[], context: any) {
  const { act } = useBackend<Data>(context);
  return (
    <LabeledList>
      {props.map(player => (
        <Box key={player.name}>
          <LabeledList.Item
            label={(player.name)}
            buttons={
              <Stack>
                <Stack.Item fontSize="14px" color={player.color}>
                Kills: {player.kills}
                </Stack.Item>
                <Stack.Item fontSize="14px" color={player.color}>
                Deaths:  {player.deaths}
                </Stack.Item>
              </Stack>
            }>
          </LabeledList.Item>
          <LabeledList.Divider/>
        </Box>
      ))}
    </LabeledList>
  );
}

function MapList(props: string[], context: any) {
  const { act } = useBackend<Data>(context);

  return (
        <LabeledList>
        {props.map(map_name => (
          <Box key={map_name}>
          <LabeledList.Item
                    label={map_name.replace(/^\w/, (c) => c.toUpperCase())}
                    textAlign="right"
                    buttons={
                      <Button
                        onClick={() => {
                          act('map_vote', { map_name: map_name });
                        }}>
                        Vote
                      </Button>
                    }>
            </LabeledList.Item>
            <LabeledList.Divider />
            </Box>
        ))}
        </LabeledList>

  );
}

function GamemodeList(props: string[], context: any) {
  const { act } = useBackend<Data>(context);

  return (
      <Stack vertical>
        <LabeledList>
        {props.map(gamemode_name => (
          <Box key={gamemode_name}>
          <LabeledList.Item
                    label={gamemode_name.replace(/^\w/, (c) => c.toUpperCase())}
                    textAlign="right"
                    buttons={
                      <Button
                        onClick={() => {
                          act('gamemode_vote', { gamemode: gamemode_name });
                        }}>
                        Vote
                      </Button>
                    }>
            </LabeledList.Item>
            <LabeledList.Divider />
            </Box>
        ))}
        </LabeledList>
      </Stack>
  );
}

const TimePanel = (props, context) => {
  const { act, data } = useBackend<Data>(context);

  return (
    <Stack.Item mt={1}>
      <Section>
        <Stack justify="space-between">
          <Box fontSize={1.5}>
            Time Remaining:&nbsp;
            {data.timeRemaining}s
          </Box>
        </Stack>
      </Section>
    </Stack.Item>
  );
};

export function GhostArenaEndround(props: any, context: any) {
  const { getTheme, data, act } = useBackend<Data>(context);

  return (
    <Window theme={getTheme("neutral")} width={700} height={400}>
      <Window.Content scrollable>
        <TimePanel />
        {data.roundend ? (
        <Section title={"Winner"}>
          {data.winner ? (
            data.winner
          ) : (
            <NoticeBox>No winners, Toolbox Strike has just started!</NoticeBox>
          )}
        </Section>
        ):(<></>)}
        <Section title={"Scoreboard"}>
          {data.players.length ? (
            PlayersList(data.players, context)
          ) : (
            <NoticeBox>No teams found, Toolbox Strike: Greytide Offensive seems to be offline!</NoticeBox>
          )}
        </Section>
        {data.roundend?(
        <Flex direction="row">
            <Flex.Item grow >
              <Section fill title={"Map Vote"}>
                {data.mapVote.length ? (
                MapList(data.mapVote, context)
                ) : (
                  <NoticeBox>No teams found, Toolbox Strike: Greytide Offensive seems to be offline!</NoticeBox>
                )}
              </Section>
            </Flex.Item>
            <Divider vertical />
            <Flex.Item grow>
              <Section fill title={"Gamemode Vote"}>
                {data.gamemodeVote.length ? (
                GamemodeList(data.gamemodeVote, context)
                ) : (
                  <NoticeBox>No teams found, Toolbox Strike: Greytide Offensive seems to be offline!</NoticeBox>
                )}
              </Section>
            </Flex.Item>
        </Flex>
        ):(<></>)}
      </Window.Content>
    </Window>
  );
}
