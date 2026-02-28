import { Icon } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const AtmosScanApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const reading = ctx.data?.aircontents || { reading: 0 };

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="wind" /> ATMOSPHERIC SCAN
        </div>
        <div className="PDAProgram__sub">Live local atmosphere readout</div>
      </div>

      <div className="PDAProgram__panel">
        {!reading.reading ? (
          <div className="pda-bad">Unable to get air reading</div>
        ) : (
          <>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Pressure</div>
              <div className="PDAProgram__v">{reading.pressure} kPa</div>
            </div>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Temperature</div>
              <div className="PDAProgram__v">{reading.temp} C</div>
            </div>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Oxygen</div>
              <div className="PDAProgram__v">{reading.oxygen}%</div>
            </div>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Nitrogen</div>
              <div className="PDAProgram__v">{reading.nitrogen}%</div>
            </div>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Carbon Dioxide</div>
              <div className="PDAProgram__v">{reading.carbon_dioxide}%</div>
            </div>
            {!!Number(reading.other) && (
              <div className="PDAProgram__row">
                <div className="PDAProgram__k">Unknown</div>
                <div className="PDAProgram__v">{reading.other}%</div>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
};

export const AtmosScanProgram: PdaProgram = {
  id: PDA_MODE.ATMOS_SCAN,
  title: 'Atmos Scan',
  icon: 'wind',
  View: (ctx) => <AtmosScanApp ctx={ctx} />,
};
