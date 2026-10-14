/*
 * CMG_F_CreateCase  –  start form della record action "Nuovo case"
 * Rule input:
 *   case          (CMG Case)      case da creare
 *   newCustomer   (CMG Customer)  valorizzato solo se il cliente non esiste
 *   isNewCustomer (Boolean)
 *   cancel        (Boolean)
 * I valori iniziali (status, createdAt/By) sono impostati nel saveInto del submit:
 * un unico punto da controllare. Priorità e SLA li calcola il processo.
 */
a!localVariables(
  local!categories: a!queryRecordType(
    recordType: recordType!CMG Category,
    fields: {
      recordType!CMG Category.fields.id,
      recordType!CMG Category.fields.name
    },
    filters: a!queryFilter(
      field: recordType!CMG Category.fields.isActive,
      operator: "=",
      value: true
    ),
    pagingInfo: a!pagingInfo(
      startIndex: 1,
      batchSize: 100,
      sort: a!sortInfo(field: recordType!CMG Category.fields.name, ascending: true)
    )
  ).data,
  a!formLayout(
    titleBar: "Nuovo case",
    instructions: "Registra la richiesta del cliente. Priorità, scadenza e assegnazione vengono calcolate automaticamente.",
    contents: {
      a!sectionLayout(
        label: "Cliente",
        contents: {
          a!radioButtonField(
            label: "Il cliente è già registrato?",
            labelPosition: "ABOVE",
            choiceLabels: { "Sì, cerca cliente", "No, nuovo cliente" },
            choiceValues: { false, true },
            value: a!defaultValue(ri!isNewCustomer, false),
            saveInto: {
              ri!isNewCustomer,
              a!save(ri!case[recordType!CMG Case.fields.customerId], null)
            },
            choiceLayout: "COMPACT"
          ),
          a!recordPickerField(
            label: "Cliente",
            labelPosition: "ABOVE",
            placeholder: "Cerca per nome o codice cliente",
            recordType: recordType!CMG Customer,
            maxSelections: 1,
            value: ri!case[recordType!CMG Case.fields.customerId],
            saveInto: ri!case[recordType!CMG Case.fields.customerId],
            required: true,
            showWhen: not(a!defaultValue(ri!isNewCustomer, false))
          ),
          a!columnsLayout(
            showWhen: a!defaultValue(ri!isNewCustomer, false),
            columns: {
              a!columnLayout(
                contents: {
                  a!textField(
                    label: "Nome / Ragione sociale",
                    labelPosition: "ABOVE",
                    value: ri!newCustomer[recordType!CMG Customer.fields.name],
                    saveInto: ri!newCustomer[recordType!CMG Customer.fields.name],
                    required: true,
                    characterLimit: 255
                  ),
                  a!textField(
                    label: "Codice cliente (CRM)",
                    labelPosition: "ABOVE",
                    value: ri!newCustomer[recordType!CMG Customer.fields.externalId],
                    saveInto: ri!newCustomer[recordType!CMG Customer.fields.externalId],
                    characterLimit: 100
                  )
                }
              ),
              a!columnLayout(
                contents: {
                  a!textField(
                    label: "Email",
                    labelPosition: "ABOVE",
                    value: ri!newCustomer[recordType!CMG Customer.fields.email],
                    saveInto: ri!newCustomer[recordType!CMG Customer.fields.email],
                    characterLimit: 255,
                    validations: if(
                      or(
                        a!isNullOrEmpty(ri!newCustomer[recordType!CMG Customer.fields.email]),
                        find("@", ri!newCustomer[recordType!CMG Customer.fields.email]) > 1
                      ),
                      null,
                      "Inserisci un indirizzo email valido"
                    )
                  ),
                  a!textField(
                    label: "Telefono",
                    labelPosition: "ABOVE",
                    value: ri!newCustomer[recordType!CMG Customer.fields.phone],
                    saveInto: ri!newCustomer[recordType!CMG Customer.fields.phone],
                    characterLimit: 50
                  )
                }
              )
            }
          )
        }
      ),
      a!sectionLayout(
        label: "Richiesta",
        contents: {
          a!columnsLayout(
            columns: {
              a!columnLayout(
                contents: {
                  a!dropdownField(
                    label: "Categoria",
                    labelPosition: "ABOVE",
                    placeholder: "Seleziona (se nota)",
                    instructions: "Se non sei sicuro lascia vuoto: la definisce il triage.",
                    choiceLabels: local!categories[recordType!CMG Category.fields.name],
                    choiceValues: local!categories[recordType!CMG Category.fields.id],
                    value: ri!case[recordType!CMG Case.fields.categoryId],
                    saveInto: ri!case[recordType!CMG Case.fields.categoryId]
                  )
                }
              ),
              a!columnLayout(
                contents: {
                  a!dropdownField(
                    label: "Canale",
                    labelPosition: "ABOVE",
                    choiceLabels: { "Email", "Telefono", "Web", "API" },
                    choiceValues: {
                      cons!CMG_CHANNEL_EMAIL,
                      cons!CMG_CHANNEL_PHONE,
                      cons!CMG_CHANNEL_WEB,
                      cons!CMG_CHANNEL_API
                    },
                    value: ri!case[recordType!CMG Case.fields.channel],
                    saveInto: ri!case[recordType!CMG Case.fields.channel],
                    required: true
                  )
                }
              ),
              a!columnLayout(
                contents: {
                  a!dropdownField(
                    label: "Impatto per il cliente",
                    labelPosition: "ABOVE",
                    choiceLabels: { "Basso", "Medio", "Alto", "Bloccante" },
                    choiceValues: {
                      cons!CMG_IMPACT_LOW,
                      cons!CMG_IMPACT_MEDIUM,
                      cons!CMG_IMPACT_HIGH,
                      cons!CMG_IMPACT_BLOCKING
                    },
                    value: ri!case[recordType!CMG Case.fields.impact],
                    saveInto: ri!case[recordType!CMG Case.fields.impact],
                    required: true
                  )
                }
              )
            }
          ),
          a!textField(
            label: "Oggetto",
            labelPosition: "ABOVE",
            value: ri!case[recordType!CMG Case.fields.subject],
            saveInto: ri!case[recordType!CMG Case.fields.subject],
            required: true,
            characterLimit: 255
          ),
          a!paragraphField(
            label: "Descrizione",
            labelPosition: "ABOVE",
            instructions: "Cosa chiede il cliente, cosa è successo, cosa si aspetta.",
            value: ri!case[recordType!CMG Case.fields.description],
            saveInto: ri!case[recordType!CMG Case.fields.description],
            required: true,
            characterLimit: 4000,
            height: "MEDIUM"
          )
        }
      )
    },
    buttons: a!buttonLayout(
      primaryButtons: a!buttonWidget(
        label: "Crea case",
        style: "SOLID",
        submit: true,
        validate: true,
        saveInto: {
          a!save(ri!case[recordType!CMG Case.fields.status], cons!CMG_CASE_STATUS_NEW),
          a!save(ri!case[recordType!CMG Case.fields.priority], cons!CMG_PRIORITY_LOW),
          a!save(ri!case[recordType!CMG Case.fields.isCompleted], false),
          a!save(ri!case[recordType!CMG Case.fields.followUpCount], 0),
          a!save(ri!case[recordType!CMG Case.fields.createdAt], now()),
          a!save(ri!case[recordType!CMG Case.fields.createdBy], loggedInUser()),
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
)
