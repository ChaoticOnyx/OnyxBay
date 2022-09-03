import { round } from "common/math";
import { useBackend, useLocalState } from "../backend";
import { Button, Divider, Icon, Modal, Stack } from "../components";
import { Window } from "../layouts";

type Option = {
  id: string;
  name: string;
  description: string;
  event_id?: string;
  weight: number;
};

type Event = {
  id: string;
  name: string;
  description: string;
  mtth: number;
  chance: number;
  waiting_option: boolean;
  fire_conditions: boolean;
  options: Option[];
  conditions_description: string;
};

type InputData = {
  events: Event[];
};

function EventTooltip(props: { event: Event }, context: any) {
  const event = props.event;
  const rawHtml = {
    __html: event.conditions_description,
  };

  return (
    <>
      <b>Id:</b> {event.id}
      <br />
      <b>MTTH:</b> {event.mtth}
      <Divider hidden />
      {event.description}
      <Divider />
      <span
        class="ConditionsDescription"
        dangerouslySetInnerHTML={rawHtml}
      ></span>
    </>
  );
}

function EventButton(
  props: { event: Event; onChoose: (event: Event) => void },
  context: any
) {
  const { act } = useBackend<InputData>(context);
  const event = props.event;

  return (
    <Stack align="center" mt="5px">
      <Stack.Item width="100%">
        <Button
          tooltip={<EventTooltip event={event} />}
          disabled={!event.fire_conditions}
          color={event.waiting_option ? "violet" : ""}
          onClick={() => {
            if (event.waiting_option) {
              props.onChoose(event);
            }
          }}
          fluid
        >
          <Stack align="center">
            <Stack.Item>{round(event.chance, 0)}%</Stack.Item>
            <Stack.Item width="100%">
              <b>{event.name}</b>{" "}
              {event.waiting_option ? "- choose an option" : ""}
            </Stack.Item>
            <Stack.Item>
              {event.fire_conditions ? (
                <Icon color="good" name="check"></Icon>
              ) : (
                <Icon color="bad" name="times"></Icon>
              )}
            </Stack.Item>
          </Stack>
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={!event.fire_conditions || event.waiting_option}
          icon="fire"
          tooltip="Force"
          onClick={() => act("force", { event_id: event.id })}
        ></Button>
      </Stack.Item>
    </Stack>
  );
}

function OptionTooltip(props: { option: Option }, context: any) {
  const option = props.option;

  return (
    <>
      <b>Id:</b> {option.id}
      <br />
      <b>Event Id:</b> {option.event_id || "null"}
      <Divider hidden />
      {option.description}
    </>
  );
}

function EventDecision(
  props: { event: Event; onClose: () => void },
  context: any
) {
  const { act } = useBackend<InputData>(context);
  const event = props.event;

  const prefered = event.options.sort((a, b) => a.weight - b.weight)[0];

  return (
    <Modal width="300px">
      <b>{event.name}</b>

      <Divider hidden />

      {event.description}

      <Divider />

      {event.options.map((o) => {
        return (
          <Button
            onClick={() => {
              act("choose", {
                option_id: o.id,
                event_id: event.id,
              });
              props.onClose();
            }}
            tooltip={<OptionTooltip option={o} />}
            textAlign="center"
            color={o.id === prefered.id ? "pink" : ""}
            fluid
          >
            {o.name} {o.id === prefered.id ? <em>(prefered by AI)</em> : ""}
          </Button>
        );
      })}

      <Button
        textAlign="center"
        tooltip="Ignore it"
        onClick={() => props.onClose()}
        fluid
      >
        Ok
      </Button>
    </Modal>
  );
}

export function EventsPanel(props: any, context: any) {
  const { getTheme, data, act } = useBackend<InputData>(context);
  const [selectedEvent, setSelectedEvent] = useLocalState<Event | null>(
    context,
    "selectedEvent",
    null
  );

  if (selectedEvent) {
    if (!selectedEvent.waiting_option) {
      setSelectedEvent(null);
    }
  }

  return (
    <Window width={500} height={300}>
      <Window.Content scrollable>
        {data.events.map((e) => {
          return (
            <EventButton event={e} onChoose={(e) => setSelectedEvent(e)} />
          );
        })}
        {selectedEvent !== null ? (
          <EventDecision
            event={selectedEvent}
            onClose={() => setSelectedEvent(null)}
          />
        ) : (
          ""
        )}
      </Window.Content>
    </Window>
  );
}
