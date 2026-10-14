# CMG Triage Case

## Process variable

| PV | Tipo | Parameter |
|---|---|---|
| `caseId` | Integer | ✓ |
| `case` | CMG Case | |
| `outcome` | Text | |
| `comment` | Text | |
| `team` | CMG Team | |
| `taskStartedAt` | Date and Time | |

## Nodi

1. **Start**
2. **Script Task** `Load Case` → `pv!case` ← `rule!CMG_Q_GetCaseById(pv!caseId)`
3. **User Input Task** `Triage Case`
   - Interfaccia: `rule!CMG_F_TriageCase(case: ac!case, outcome: ac!outcome, comment: ac!comment)`
   - Display name: `="Triage " & pv!case.caseNumber & " – " & pv!case.subject`
   - Assegnazione: `cons!CMG_GRP_TRIAGE` (svuotare il campo prima di impostarlo)
   - Riassegnazione: *Reassign within pool*
   - Deadline: `rule!CMG_CalculateDueAt(pv!case.priority, now(), "REACTION")`
   - Escalation:
     - a metà tempo: priorità task → *High*
     - a scadenza: alert a `CMG_GRP_SUPERVISORS`, aggiungi assegnatari `CMG_GRP_SUPERVISORS`
     - **ricorrente ogni ora**: se accettato e non completato, riporta al pool (anti-accumulo)
   - Output: `pv!case`, `pv!outcome`, `pv!comment`, `pv!taskStartedAt` ← `tp!assignedTime`
4. **XOR** `Accepted?`
   - `ACCEPTED` →
     5. **Script Task** `Recalculate` – priorità, `dueAt` (da `createdAt`), `pv!team` ← `rule!CMG_GetTeamForCategory(pv!case.categoryId)`, `pv!case.teamId` ← `pv!team.id`
     6. **Write Records** `[Case]`
     7. **Subprocess** `CMG Write Case Activity` (`TRIAGED`, outcome, comment, `tp!owner`)
     8. **Subprocess** `CMG Change Case Status` (`IN_PROGRESS`)
     9. **Start Process** `CMG Work Case` (`caseId`)
   - `DUPLICATE` / `INVALID` →
     10. **Write Records** `[Case]` (salva `parentCaseId` per i duplicati)
     11. **Subprocess** `CMG Write Case Activity` (`TRIAGED`, outcome, comment)
     12. **Start Process** `CMG Close Case` (`caseId`, `outcome: pv!outcome`, `finalStatus: CANCELLED`)
13. **End**
