import { Component } from 'inferno';
import { Icon } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';

type CrewRow = {
  name: string;
  job: string;
  dept: 'Command' | 'Security' | 'Engineering' | 'Medical' | 'Science' | 'Service' | 'Cargo';
  status: 'Active' | 'SSD' | 'Missing';
};

const CREW: CrewRow[] = [
  { name: 'S. Batten', job: 'Captain', dept: 'Command', status: 'Active' },
  { name: 'A. Kerr', job: 'Head of Security', dept: 'Security', status: 'Active' },
  { name: "M. O'Brien", job: 'Chief Engineer', dept: 'Engineering', status: 'Active' },
  { name: 'M. Solus', job: 'Chief Medical Officer', dept: 'Medical', status: 'SSD' },
  { name: 'D. Vale', job: 'Research Director', dept: 'Science', status: 'Active' },
  { name: 'J. Doe', job: 'Assistant', dept: 'Service', status: 'Active' },
  { name: 'K. Rigg', job: 'Quartermaster', dept: 'Cargo', status: 'Missing' },
];

function deptClass(d: CrewRow['dept']) {
  if (d === 'Command') return 'pda-accent';
  if (d === 'Security') return 'pda-bad';
  if (d === 'Engineering') return 'pda-avg';
  if (d === 'Medical') return 'pda-good';
  if (d === 'Science') return 'pda-accent';
  return 'pda-dim';
}

function statusClass(s: CrewRow['status']) {
  if (s === 'Active') return 'pda-good';
  if (s === 'SSD') return 'pda-avg';
  return 'pda-bad';
}

class CrewManifestApp extends Component<{ ctx: PdaProgramContext }> {
  render() {
    // no tabs, no toggles — just the table (как старый)
    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="users" /> CREW MANIFEST
          </div>
          <div className="PDAProgram__sub">
            Cached station roster • UI-only mock
          </div>
        </div>

        <div className="PDAProgram__panel">
          <table className="PDATable">
            <thead>
              <tr>
                <th style={{ width: '44%' }}>Name</th>
                <th style={{ width: '36%' }}>Assignment</th>
                <th style={{ width: '20%' }}>Status</th>
              </tr>
            </thead>
            <tbody>
              {CREW.map((c, i) => (
                <tr key={i}>
                  <td>
                    <span className="pda-accent">{c.name}</span>
                    <div className={deptClass(c.dept)} style={{ fontSize: '10px', opacity: 0.85 }}>
                      {c.dept}
                    </div>
                  </td>
                  <td>
                    <span className="pda-dim">{c.job}</span>
                  </td>
                  <td>
                    <span className={statusClass(c.status)}>{c.status}</span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          <div className="PDAProgram__footerHint" style={{ marginTop: '10px' }}>
            No filters/tabs (matches old manifest screen)
          </div>
        </div>
      </div>
    );
  }
}

export const CrewManifestProgram: PdaProgram = {
  id: 'crew_manifest',
  title: 'Crew Manifest',
  icon: 'users',
  View: (ctx) => <CrewManifestApp ctx={ctx} />,
};
