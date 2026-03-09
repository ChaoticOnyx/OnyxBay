/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { selectBackend } from './backend'
import { selectDebug } from './debug/selectors'
import { Window } from './layouts'
import { KitchenSink } from './debug'

const interfaceModules = import.meta.glob(
  [
    './interfaces/*.tsx',
    './interfaces/*.js',
    './interfaces/*/index.tsx',
    './interfaces/*/index.js',
  ],
  { eager: true }
)

const getInterfaceModule = (name) => {
  const candidates = [
    `./interfaces/${name}.tsx`,
    `./interfaces/${name}.js`,
    `./interfaces/${name}/index.tsx`,
    `./interfaces/${name}/index.js`,
  ]

  for (const path of candidates) {
    if (interfaceModules[path]) {
      return interfaceModules[path]
    }
  }

  return null
}

const routingError = (type, name) => () => {
  return (
    <Window>
      <Window.Content scrollable>
        {type === 'notFound' && (
          <div>
            Interface <b>{name}</b> was not found.
          </div>
        )}
        {type === 'missingExport' && (
          <div>
            Interface <b>{name}</b> is missing an export.
          </div>
        )}
      </Window.Content>
    </Window>
  )
}

const SuspendedWindow = () => {
  return (
    <Window>
      <Window.Content scrollable />
    </Window>
  )
}

export const getRoutedComponent = (store) => {
  const state = store.getState()
  const { suspended, config } = selectBackend(state)
  
  if (suspended) {
    return SuspendedWindow
  }
  
  if (import.meta.env.DEV) {
    const debug = selectDebug(state)
    // Show a kitchen sink
    if (debug.kitchenSink) {
      return KitchenSink
    }
  }
  
  const name = config?.interface
  const esModule = getInterfaceModule(name)
  
  if (!esModule) {
    return routingError('notFound', name)
  }
  
  const Component = esModule[name]
  
  if (!Component) {
    return routingError('missingExport', name)
  }
  
  return Component
}
