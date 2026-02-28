import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const PowerMonitorApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const mode = String(ctx.data?.mode || '');
  const records = ctx.data?.records || {};
  const sensors = records.power_sensors || [];
  const reading = records.sensor_reading;

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="bolt" /> POWER MONITOR
        </div>
      </div>

      {mode === PDA_MODE.POWER_MONITOR && (
        <div className="PDAProgram__panel">
          <div className="PDAProgram__row">
            <div className="PDAProgram__k">Available Sensors</div>
            <div className="PDAProgram__v">{sensors.length}</div>
          </div>

          <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 8 }}>
            {sensors.map((sensor, idx) => (
              <Button
                key={`${sensor.name_tag}-${idx}`}
                icon="plus"
                content={sensor.name_tag}
                onClick={() => ctx.act('cartridge_action', { choice: 'Power Select', target: sensor.name_tag })}
              />
            ))}
          </div>
        </div>
      )}

      {mode === PDA_MODE.POWER_MONITOR_READING && (
        <div className="PDAProgram__panel">
          <Button icon="arrow-left" content="Back" onClick={() => ctx.act('cartridge_action', { choice: 'Power Clear' })} />

          {!reading ? (
            <div style={{ marginTop: 12 }}>Unable to contact sensor controller! Please retry.</div>
          ) : (
            <div style={{ marginTop: 10 }}>
              <table style={{ width: '100%', fontSize: 12, borderCollapse: 'collapse' }}>
                <thead>
                  <tr>
                    <th style={{ textAlign: 'left' }}>Area</th>
                    <th style={{ textAlign: 'right' }}>Cell %</th>
                    <th style={{ textAlign: 'right' }}>Load</th>
                  </tr>
                </thead>
                <tbody>
                  {(reading.apc_data || []).map((row, idx) => (
                    <tr key={idx}>
                      <td>{row.name}</td>
                      <td style={{ textAlign: 'right' }}>{row.cell_charge}%</td>
                      <td style={{ textAlign: 'right' }}>{row.total_load}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
              <div style={{ marginTop: 10 }}>
                Available: {reading.total_avail}
                <br />
                Load: {reading.total_used_all}
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export const PowerMonitorProgram: PdaProgram = {
  id: PDA_MODE.POWER_MONITOR,
  title: 'Power Monitor',
  icon: 'bolt',
  View: (ctx) => <PowerMonitorApp ctx={ctx} />,
};
