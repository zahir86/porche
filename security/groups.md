# Sicurezza – CMG

## Gruppi

```
CMG All Users                     (gruppo padre, viewer dell'applicazione)
├── CMG Front Office
├── CMG Triage
├── CMG Teams                     (contenitore)
│   ├── CMG Team Technical
│   ├── CMG Team Administrative
│   └── CMG Team Commercial
├── CMG Supervisors
└── CMG Managers
CMG Administrators                (admin di tutti gli oggetti, alert di processo)
CMG Web API                       (service user cmg.api.service)
```

Il `groupId` dei team va salvato in `CMG_Team.groupId`: l'assegnazione dei task è dinamica
(`togroup(rv!record[...team.groupId])`) e i team si configurano senza toccare i process model.

## Matrice

| Oggetto | Administrators | All Users | Front Office | Triage | Teams | Supervisors | Managers | Web API |
|---|---|---|---|---|---|---|---|---|
| Application | Admin | Viewer | | | | | | |
| Record `CMG Case` | Admin | Viewer (record-level, vedi sotto) | | | | | | Viewer |
| Record action *Nuovo case* | | | ✓ | ✓ | | ✓ | | |
| Related action *Aggiungi commento* | | ✓ | | | | | | |
| Related action *Registra risposta cliente* | | | ✓ | | ✓ | ✓ | | |
| Related action *Riassegna team* | | | | | | ✓ | | |
| Related action *Annulla case* | | | | | | ✓ | | |
| Related action *Crea case collegato* | | | ✓ | | | ✓ | | |
| PM `CMG Create Case` | Admin | | Initiator | Initiator | | Initiator | | Initiator |
| PM fasi (Triage/Work/Review/Close) | Admin | Viewer | | | | Manager | | |
| Data store / tabelle | Admin | Viewer | | | | | | Viewer |
| Report e pagina Monitoring | | | | | | ✓ | ✓ | |

Il ruolo **Manager** sui process model di fase consente ai supervisor di riassegnare qualsiasi task.

## Record-level security (`CMG Case`)

Regole di visibilità sul record type:
- `CMG Supervisors`, `CMG Managers`, `CMG Triage`, `CMG Front Office` → tutti i case.
- Membri di un team → solo i case con `team.groupId` uguale a un gruppo di cui sono membri
  (regola: *users in group field* `team.groupId`).

`showWhen` nasconde i commenti interni in eventuali viste esterne, ma **la visibilità non sostituisce
la security**: le related action sono protette dalla security del process model.

## Web API

Web API `CMG Case API` (`/cmg/cases`, POST per creare un case, POST `/cmg/cases/{id}/answer` per la risposta
del cliente), security = `CMG Web API`. Ogni campo in ingresso viene validato da
`CMG_ValidateCaseApiInput`; in caso di errore si risponde `400` con l'elenco degli errori.
