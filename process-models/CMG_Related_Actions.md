# Record type `CMG Case` – azioni e viste

## Record list (vista per gli operatori)
Colonne: Case (`caseNumber`), Oggetto, Cliente, Stato (`CMG_GetStatusLabel`), Priorità (tag),
Team, Owner, Scadenza (rossa se scaduta). Ordinamento: `dueAt` crescente.
Filtri utente: Stato, Priorità, Team, Categoria, Canale, "Solo aperti" (`isCompleted = false`, default).

## Record view
- **Summary**: `rule!CMG_D_CaseSummary(caseId: rv!identifier)`
- **Attività**: grid di `CMG Activity` (`rule!CMG_Q_GetCaseActivities`)
- **Documenti**: grid di `CMG Case Document` con `a!documentDownloadLink`
- Record title: `rv!record[recordType!CMG Case.fields.caseNumber] & " – " & rv!record[recordType!CMG Case.fields.subject]`

## Record action
| Azione | Process model | Security |
|---|---|---|
| Nuovo case | `CMG Create Case` | Front Office, Triage, Supervisors |

## Related action
| Azione | Process model | Visibile quando | Security |
|---|---|---|---|
| Aggiungi commento | `CMG Add Comment` (form `CMG_F_AddComment` → Write Records `[Comment]` → Activity `COMMENTED`) | sempre | All Users |
| Registra risposta cliente | `CMG Answer Customer Request` | `status = WAITING_CUSTOMER` | Front Office, Teams, Supervisors |
| Riassegna team | `CMG Reassign Team` (form con dropdown team; aggiorna `teamId`, activity; i task aperti si riassegnano dal process report) | non completato | Supervisors |
| Annulla case | `CMG Cancel Case` (motivazione obbligatoria → cancella il processo di fase attivo → `CMG Close Case` con `CANCELLED`) | non completato | Supervisors |
| Crea case collegato | `CMG Create Case` con context `{case: {parentCaseId: rv!identifier, customerId: rv!record.customerId, categoryId: rv!record.categoryId}}` | completato | Front Office, Supervisors |

"Annulla case" non è un semplice cancel: ha un flusso di cleanup con esito definito (`CANCELLED`),
audit e comunicazione al cliente.

## Site `CMG Case Management`
1. **Le mie attività** – task report (solo i task CMG, ordinati per priorità e scadenza)
2. **Case** – record list `CMG Case`
3. **Clienti** – record list `CMG Customer`
4. **Monitoring** – `rule!CMG_D_Monitoring()` (Supervisors, Managers)
5. **Report** – `rule!CMG_D_Reports()` (Managers)
