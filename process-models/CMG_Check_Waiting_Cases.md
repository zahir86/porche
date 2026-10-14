# CMG Check Waiting Cases (schedulato)

Nessuna istanza resta in attesa del cliente: questo processo controlla i follow-up scaduti.

- **Timer** sullo Start: ogni ora nei giorni lavorativi (calendario di processo).
- Security: eseguito come service user.

## Nodi
1. **Start (timer)**
2. **Script Task** `Find Expired` → `pv!caseIds` ← id dei `CMG Case` con
   `status = WAITING_CUSTOMER` e `followUpAt <= now()` (`a!queryRecordType`, batch 100)
3. **XOR** `Any?` → no → End
4. **Write Records** `[Customer Request]` – richieste `OPEN` di quei case → `EXPIRED`
5. **Subprocess** `CMG Expire Follow Up` – **MNI** su `pv!caseIds` (pochi elementi, batch ≤ 100):
   `CMG Write Case Activity` (`FOLLOW_UP_EXPIRED`) → `CMG Change Case Status` (`IN_PROGRESS`)
   → *Start Process* `CMG Work Case`
6. **End**
