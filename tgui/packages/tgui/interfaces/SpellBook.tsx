import { useBackend } from '../backend';
import { Button, Divider, Flex } from '../components';
import { GameIcon } from '../components/GameIcon';
import { Window } from '../layouts';

interface Class {
  name:              string;
  icon:              string;
  description:       string;
  spellPoints:       number;
  flags:             Flags;
  spells:            Spell[];
  artefacts:         Artefact[];
  sacrificeObjects:  SacrificeObject[];
  sacrificeReagents: any[];
}

interface Artefact {
  path: string;
  cost: number;
  icon: string;
}

interface Spell {
  path: string;
  cost: number;
  icon: string;
}

interface Flags {
  noRevert:         number;
  locked:           number;
  canMakeContracts: number;
  investable:       number;
}

interface SacrificeObject {
  path: string;
  icon: string;
}

interface InputData {
  page: number;
  classes: Class[];
}

const classElement = (props: Class, context: any) => {
  return <Flex class='ClassCard' direction='column'>
    <Flex.Item>
      <h2><GameIcon html={props.icon} />{props.name} <Button style={{
        'float': 'right',
        'font-size': '0.8em'
      }} content='Choose' /></h2> 
    </Flex.Item>
    <Flex.Item>
      {props.description}
    </Flex.Item>
    <Flex.Item>
      <h3>Spells:</h3>
      <Divider />
      {props.spells.map((s, i) => {
        return <Button title={s.path} className='SpellButton'><GameIcon html={s.icon} /></Button>
      })}
      <Divider />
    </Flex.Item>
    <Flex.Item>
      <h3>Artefacts:</h3>
      <Divider />
      {props.artefacts.map((a, i) => {
        return <Button title={a.path} className='ArtefactButton'><GameIcon html={a.icon} /></Button>
      })}
      <Divider/>
    </Flex.Item>
  </Flex>
}

const classesPage = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);
  const { classes } = data;

  return <Flex direction='column'>
    {classes.map((c, i) => classElement(c, context))}
  </Flex>
}

const PAGES = {
  0: {
    render: classesPage
  }
}

export const SpellBook = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);

  return <Window theme='spellbook' width={600} height={800}>
    <Window.Content scrollable>
      {PAGES[data.page].render(props, context)}
    </Window.Content>
  </Window>
}