/* eslint-disable camelcase */
import { useBackend } from '../backend'
import { Button, Collapsible, LabeledList } from '../components'
import { Window } from '../layouts'

type Preference = {
  description: string
  key: string
  category: string
  options: string[]
  selected_option: string
}

type InputData = {
  preferences: Preference[]
}

type PreferenceEntryProps = {
  preference: Preference
}

function PreferenceEntry (props: PreferenceEntryProps, context: any) {
  const { act } = useBackend<InputData>(context)
  const { preference } = props

  return (
    <LabeledList.Item label={preference.description}>
      {preference.options.map(option => (
        <Button
          key={option}
          onClick={() =>
            act('set_preference', {
              key: preference.key,
              value: option
            })
          }
          className='Button--segmented PreferenceOption'
          selected={preference.selected_option === option}>
          {option}
        </Button>
      ))}
    </LabeledList.Item>
  )
}

type PreferenceCategoryProps = {
  preferences: Preference[]
  category: string
}

function PreferencesCategory (props: PreferenceCategoryProps, context: any) {
  return (
    <Collapsible
      className='PreferencesCategory'
      title={<b>{props.category}</b>}>
      <LabeledList>
        {props.preferences.map(preference => (
          <PreferenceEntry key={preference.key} preference={preference} />
        ))}
      </LabeledList>
    </Collapsible>
  )
}

export function PlayerSettings (props: any, context: any) {
  const { data } = useBackend<InputData>(context)

  const preferencesPerCategory = {}

  for (const preference of data.preferences) {
    if (!(preference.category in preferencesPerCategory)) {
      preferencesPerCategory[preference.category] = []
    }

    preferencesPerCategory[preference.category].push(preference)
  }

  return (
    <Window width={700} height={700}>
      <Window.Content className='SettingsWindow' scrollable>
        {Object.keys(preferencesPerCategory)
          .sort()
          .map(category => {
            const preferences = preferencesPerCategory[category]

            return (
              <PreferencesCategory
                key={category}
                preferences={preferences}
                category={category}
              />
            )
          })}
      </Window.Content>
    </Window>
  )
}
