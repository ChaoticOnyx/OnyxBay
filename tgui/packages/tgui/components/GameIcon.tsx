interface GameIconProps {
  html: string;
  className?: string | null;
}

export const GameIcon = (props: GameIconProps) => {
  const { html, className } = props;
  const iconSrc = html.match('src=["\'](.*)["\']')[1];

  return (
    <img
      class={`game-icon ${className || ''}`}
      src={iconSrc}
      style={{ '-ms-interpolation-mode': 'nearest-neighbor' }}
    />
  );
};
