# CMG Answer Customer Request (related action + Web API)

Riavvia il lavoro quando il cliente risponde. Sicurezza: Front Office, Teams, Supervisors, Web API.

## Related action su `CMG Case`
- Nome: *Registra risposta cliente*
- Visibilità: `rv!record[recordType!CMG Case.fields.status] = cons!CMG_CASE_STATUS_WAITING_CUSTOMER`
- Context:
  ```
  {
    caseId: rv!identifier,
    customerRequest: index(
      a!queryRecordType(
        recordType: recordType!CMG Customer Request,
        filters: {
          a!queryFilter(recordType!CMG Customer Request.fields.caseId, "=", rv!identifier),
          a!queryFilter(recordType!CMG Customer Request.fields.status, "=", cons!CMG_REQUEST_STATUS_OPEN)
        },
        pagingInfo: a!pagingInfo(1, 1, a!sortInfo(recordType!CMG Customer Request.fields.requestedAt, false))
      ).data, 1, null)
  }
  ```

## Process variable
`caseId` (param), `customerRequest` (param), `cancel`, `case`.

## Nodi
1. **Start** con start form `rule!CMG_F_RegisterCustomerAnswer(case, customerRequest, cancel)`
   (`case` caricato in un local o passato nel context)
2. **XOR** `Cancel?` → End
3. **XOR** `Still Waiting?` – ricarica il case: se lo stato non è più `WAITING_CUSTOMER`
   (es. il follow-up è già scattato) salva solo la risposta e termina: il task è già aperto.
4. **Write Records** `[Customer Request, Case]` – risposta; `followUpAt: null` sul case
5. **Subprocess** `CMG Write Case Activity` (`CUSTOMER_ANSWERED`)
6. **Subprocess** `CMG Change Case Status` (`IN_PROGRESS`)
7. **Start Process** `CMG Work Case` (`caseId`)
8. **End**

## Web API `POST /cmg/cases/{id}/answer`
```
a!localVariables(
  local!caseId: tointeger(index(http!request.pathSegments, 1, null)),
  local!body: a!fromJson(http!request.body),
  if(
    or(a!isNullOrEmpty(local!caseId), a!isNullOrEmpty(local!body.answer)),
    a!httpResponse(statusCode: 400, body: a!toJson(a!map(errors: {"id e answer sono obbligatori"}))),
    a!startProcess(
      processModel: cons!CMG_PM_ANSWER_CUSTOMER_REQUEST,
      processParameters: a!map(caseId: local!caseId, answerText: local!body.answer),
      onSuccess: a!httpResponse(statusCode: 202, body: a!toJson(a!map(caseId: local!caseId))),
      onError: a!httpResponse(statusCode: 500, body: a!toJson(a!map(errors: {"Errore nell'avvio del processo"})))
    )
  )
)
```
Per la Web API aggiungere il parametro `answerText` e, se valorizzato, caricare la richiesta aperta
in uno script task invece di usare la start form.
