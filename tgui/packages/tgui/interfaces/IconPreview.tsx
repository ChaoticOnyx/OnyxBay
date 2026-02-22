import { useBackend } from "../backend";
import { Box, Flex } from "../components";
import { Window } from "../layouts"

interface IconPreview {
  icon: string;
}

const PREVIEW_SQUARE_SIZE = 256

export const IconPreview = (props: any, context: any) => {
  const { data } = useBackend<IconPreview>(context)
  const { icon } = data

  const handleDidMount = (domNode: HTMLElement) => {
    const imageElement = domNode.getElementsByTagName('img')[0]
    if (!imageElement) return

    const applyScale = () => {
      const scale =
        PREVIEW_SQUARE_SIZE /
        Math.max(imageElement.naturalWidth, imageElement.naturalHeight)

      imageElement.style.imageRendering = 'pixelated'
      imageElement.style.transform = `scale(${scale})`
    }

    if (imageElement.complete && imageElement.naturalWidth !== 0) {
      applyScale()
    } else {
      imageElement.onload = applyScale
    }
  }

  return <Window width={300} height={300}>
    <Window.Content>
      <Flex width="100%" height="100%" justify="center" align="center">
        <Flex.Item onComponentDidMount={handleDidMount} dangerouslySetInnerHTML={{ __html: icon }} />
      </Flex>
    </Window.Content>
  </Window >
}
