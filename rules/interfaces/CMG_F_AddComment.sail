/*
 * CMG_F_AddComment  –  related action "Aggiungi commento"
 * Rule input:
 *   case     (CMG Case)
 *   comment  (CMG Comment)
 *   cancel   (Boolean)
 * Un commento non è un task e non cambia lo stato del case.
 */
a!formLayout(
  titleBar: "Commento – " & ri!case[recordType!CMG Case.fields.caseNumber],
  contents: {
    a!paragraphField(
      label: "Commento",
      labelPosition: "ABOVE",
      value: ri!comment[recordType!CMG Comment.fields.text],
      saveInto: ri!comment[recordType!CMG Comment.fields.text],
      required: true,
      characterLimit: 4000
    ),
    a!checkboxField(
      label: "Visibilità",
      labelPosition: "COLLAPSED",
      choiceLabels: { "Nota interna (non visibile al cliente)" },
      choiceValues: { true },
      value: if(a!defaultValue(ri!comment[recordType!CMG Comment.fields.isInternal], true), true, null),
      saveInto: a!save(
        ri!comment[recordType!CMG Comment.fields.isInternal],
        a!isNotNullOrEmpty(save!value)
      )
    )
  },
  buttons: a!buttonLayout(
    primaryButtons: a!buttonWidget(
      label: "Salva",
      style: "SOLID",
      submit: true,
      validate: true,
      saveInto: {
        a!save(ri!comment[recordType!CMG Comment.fields.caseId], ri!case[recordType!CMG Case.fields.id]),
        a!save(
          ri!comment[recordType!CMG Comment.fields.isInternal],
          a!defaultValue(ri!comment[recordType!CMG Comment.fields.isInternal], true)
        ),
        a!save(ri!comment[recordType!CMG Comment.fields.createdBy], loggedInUser()),
        a!save(ri!comment[recordType!CMG Comment.fields.createdAt], now()),
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
