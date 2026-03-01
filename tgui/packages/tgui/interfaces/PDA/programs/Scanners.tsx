import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

type ScannerProps = {
  ctx: PdaProgramContext;
  title: string;
  icon: string;
  onLabel: string;
  offLabel: string;
  scanMode: number;
  choice: string;
};

const ScannerProgramView = (props: ScannerProps) => {
  const {
    ctx,
    title,
    icon,
    onLabel,
    offLabel,
    scanMode,
    choice,
  } = props;

  const currentMode = Number(ctx.data?.scanmode || 0);
  const enabled = currentMode === scanMode;

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name={icon} /> {title.toUpperCase()}
        </div>
        <div className="PDAProgram__sub">Cartridge utility</div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">State</div>
          <div className="PDAProgram__v">{enabled ? 'ON' : 'OFF'}</div>
        </div>

        <div style={{ marginTop: 10 }}>
          <Button
            icon="power-off"
            content={enabled ? offLabel : onLabel}
            onClick={() => ctx.act(choice)}
          />
        </div>
      </div>
    </div>
  );
};

export const ReagentScannerProgram: PdaProgram = {
  id: PDA_MODE.REAGENT_SCANNER,
  title: 'Reagent Scanner',
  icon: 'flask',
  canRun: (ctx) => !!ctx.data?.cartridge?.access?.access_reagent_scanner,
  View: (ctx) => (
    <ScannerProgramView
      ctx={ctx}
      title="Reagent Scanner"
      icon="flask"
      onLabel="Enable Reagent Scanner"
      offLabel="Disable Reagent Scanner"
      scanMode={3}
      choice="reagent_scan"
    />
  ),
};

export const HalogenCounterProgram: PdaProgram = {
  id: PDA_MODE.HALOGEN_COUNTER,
  title: 'Halogen Counter',
  icon: 'radiation',
  canRun: (ctx) => !!ctx.data?.cartridge?.access?.access_engine,
  View: (ctx) => (
    <ScannerProgramView
      ctx={ctx}
      title="Halogen Counter"
      icon="radiation"
      onLabel="Enable Halogen Counter"
      offLabel="Disable Halogen Counter"
      scanMode={4}
      choice="halogen_counter"
    />
  ),
};

export const GasScannerProgram: PdaProgram = {
  id: PDA_MODE.GAS_SCANNER,
  title: 'Gas Scanner',
  icon: 'smog',
  canRun: (ctx) => !!ctx.data?.cartridge?.access?.access_atmos,
  View: (ctx) => (
    <ScannerProgramView
      ctx={ctx}
      title="Gas Scanner"
      icon="smog"
      onLabel="Enable Gas Scanner"
      offLabel="Disable Gas Scanner"
      scanMode={5}
      choice="gas_scan"
    />
  ),
};
