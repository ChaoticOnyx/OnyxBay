interface GameIconProps {
  html: string;
  className?: string | null;
  style?: any | null;
  title?: string | null;
}

export const GameIcon = (props: GameIconProps) => {
  const { html, className, style } = props;
  const iconSrc = html.match('src=["\'](.*)["\']')[1];

  return (
    <img
      {...props}
      class={`game-icon ${className || ''}`}
      src={iconSrc}
      style={{ '-ms-interpolation-mode': 'nearest-neighbor', ...style }}
    />
  );
};
