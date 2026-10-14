# CMG Work Case

Attività critica principale. Avviata da Triage, dalla risposta del cliente, dal follow-up scaduto,
da una revisione respinta o da un'escalation.

## Process variable

| PV | Tipo | Parameter | Note |
|---|---|---|---|
| `caseId` | Integer | ✓ | |
| `assignToSupervisors` | Boolean | ✓ | true dopo un'escalation |
| `case` | CMG Case | | |
| `team` | CMG Team | | |
| `outcome` | Text | | |
| `resolution` | CMG Resolution | | |
| `customerRequest` | CMG Customer Request | | |
| `lastAnswer` | CMG Customer Request | | ultima richiesta chiusa (risposta o scaduta) |
| `comment` | Text | | |

## Nodi

1. **Start**
2. **Script Task** `Load Case` → `pv!case`, `pv!team` (relazione), `pv!lastAnswer`
   (ultima `CMG Customer Request` del case con status `ANSWERED` o `EXPIRED`, se più recente dell'ultimo `WORKED`)
3. **User Input Task** `Work Case`
   - Interfaccia: `rule!CMG_F_WorkCase(case, outcome, resolution, customerRequest, comment, lastAnswer)`
   - Display name: `="Lavora " & pv!case.caseNumber & " – " & pv!case.subject`
   - Assegnazione: `if(pv!assignToSupervisors, cons!CMG_GRP_SUPERVISORS, togroup(pv!team.groupId))`
   - Riassegnazione: *Reassign within pool*
   - Deadline: `pv!case.dueAt` (SLA di risoluzione)
   - Escalation: a −4h dalla deadline priorità task *High* + alert all'owner; a scadenza alert e
     aggiunta di `CMG_GRP_SUPERVISORS`; ogni ora ritorno al pool dei task accettati non lavorati
   - Output: tutti gli AC → PV; `pv!case.owner` ← `tp!owner`
4. **Subprocess** `CMG Write Case Activity` (`WORKED`, outcome, comment, `startedAt: tp!assignedTime`)
5. **XOR** `Outcome?`
   - **RESOLVED**
     6. **Write Records** `[Resolution]`
     7. **Subprocess** `CMG Write Case Activity` (`RESOLUTION_PROPOSED`)
     8. **XOR** `Review Required?` (`rule!CMG_IsReviewRequired(pv!case.priority)`)
        - sì → **Subprocess** `CMG Change Case Status` (`IN_REVIEW`) → **Start Process** `CMG Review Resolution` (`caseId`, `resolutionId`)
        - no → **Start Process** `CMG Close Case` (`caseId`, `RESOLVED`, `resolutionId`)
   - **INFO_REQUESTED**
     9. **Write Records** `[Customer Request, Case]` – request + `followUpAt`, `followUpCount + 1` sul case
     10. **Send E-Mail** `Ask Customer` (domanda + numero case)
     11. **Subprocess** `CMG Change Case Status` (`WAITING_CUSTOMER`)
     12. **End** – *nessuna istanza resta in attesa*
   - **ESCALATED**
     13. **Subprocess** `CMG Write Case Activity` (`ESCALATED`)
     14. **Start Process** `CMG Work Case` (`caseId`, `assignToSupervisors: true`)
   - **NO_RESPONSE**
     15. **Start Process** `CMG Close Case` (`caseId`, `outcome: NO_RESPONSE`, `finalStatus: CLOSED`)
16. **End**
