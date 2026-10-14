# CMG Write Case Activity (utility, subprocess sincrono)

Audit trail: un record `CMG Activity` per ogni azione significativa.

## Process variable

| PV | Tipo | Parameter | Note |
|---|---|---|---|
| `caseId` | Integer | ✓ | |
| `type` | Text | ✓ | costante `CMG_ACTIVITY_*` |
| `description` | Text | ✓ | |
| `outcome` | Text | ✓ | |
| `performedBy` | Text (Username) | ✓ | default `pp!initiator` |
| `startedAt` | Date and Time | ✓ | es. `tp!assignedTime` del task |

## Nodi

1. **Start**
2. **Write Records** `[Activity]`
   - Records: `recordType!CMG Activity(caseId: pv!caseId, type: pv!type, description: pv!description, outcome: pv!outcome, startedAt: pv!startedAt, performedBy: a!defaultValue(pv!performedBy, pp!initiator), performedAt: now())`
3. **End**
