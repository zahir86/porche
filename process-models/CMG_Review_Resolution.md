# CMG Review Resolution (four-eyes)

## Process variable
`caseId` (Integer, param), `resolutionId` (Integer, param), `case`, `resolution`.

## Nodi

1. **Start**
2. **Script Task** `Load` → `pv!case`, `pv!resolution` (`a!queryRecordByIdentifier`)
3. **User Input Task** `Review Resolution`
   - Interfaccia: `rule!CMG_F_ReviewResolution(case, resolution)`
   - Assegnazione: membri di `CMG_GRP_SUPERVISORS` **escluso chi ha proposto**:
     `topeople(remove(getdistinctusers(cons!CMG_GRP_SUPERVISORS), wherecontains(pv!resolution.proposedBy, getdistinctusers(cons!CMG_GRP_SUPERVISORS))))`
   - Deadline: `rule!CMG_CalculateDueAt(pv!case.priority, now(), "REACTION")`, escalation ad alert ai manager
4. **Write Records** `[Resolution]` (esito, commento, reviewedBy/At)
5. **Subprocess** `CMG Write Case Activity` (`REVIEWED`, outcome = `reviewOutcome`)
6. **XOR** `Approved?`
   - `APPROVED` → **Start Process** `CMG Close Case` (`caseId`, `RESOLVED`, `resolutionId`)
   - `REJECTED` → **Subprocess** `CMG Change Case Status` (`IN_PROGRESS`, reason = commento) →
     **Start Process** `CMG Work Case` (`caseId`)
7. **End**
