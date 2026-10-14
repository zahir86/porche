/*
 * CMG_F_RegisterCustomerAnswer  –  related action "Registra risposta cliente"
 * Rule input:
 *   case             (CMG Case)
 *   customerRequest  (CMG Customer Request)  richiesta aperta (dal Context della related action)
 *   cancel           (Boolean)
 * Visibile solo con case in WAITING_CUSTOMER (condizione di visibilità della related action).
 */
a!formLayout(
  titleBar: "Risposta del cliente – " & ri!case[recordType!CMG Case.fields.caseNumber],
  instructions: "Il case tornerà subito in lavorazione all'operatore.",
  contents: {
    a!paragraphField(
      label: "Domanda inviata",
      labelPosition: "ABOVE",
      readOnly: true,
      value: ri!customerRequest[recordType!CMG Customer Request.fields.question]
    ),
    a!paragraphField(
      label: "Risposta",
      labelPosition: "ABOVE",
      value: ri!customerRequest[recordType!CMG Customer Request.fields.answer],
      saveInto: ri!customerRequest[recordType!CMG Customer Request.fields.answer],
      required: true,
      characterLimit: 4000
    )
  },
  buttons: a!buttonLayout(
    primaryButtons: a!buttonWidget(
      label: "Registra risposta",
      style: "SOLID",
      submit: true,
      validate: true,
      saveInto: {
        a!save(ri!customerRequest[recordType!CMG Customer Request.fields.answeredAt], now()),
        a!save(ri!customerRequest[recordType!CMG Customer Request.fields.status], cons!CMG_REQUEST_STATUS_ANSWERED),
        a!save(ri!cancel, false)
      }
    ),
    secondaryButtons: a!buttonWidget(
      label: "Annulla",
      style: "LINK",
      submit: true,
      validate: false,
      value: true,
      saveInto: ri!cancel
    )
  )
)
