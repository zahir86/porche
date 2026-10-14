/*
 * CMG_ValidateCaseApiInput
 * Rule input: body (Map, risultato di a!fromJson)
 * Mai fidarsi dei dati in ingresso: restituisce a!map(valid, errors).
 */
a!localVariables(
  local!errors: reject(
    a!isNullOrEmpty(_),
    {
      if(a!isNullOrEmpty(ri!body.customerExternalId), "customerExternalId è obbligatorio", null),
      if(a!isNullOrEmpty(ri!body.subject), "subject è obbligatorio", null),
      if(len(tostring(ri!body.subject)) > 255, "subject supera i 255 caratteri", null),
      if(len(tostring(ri!body.description)) > 4000, "description supera i 4000 caratteri", null),
      if(
        and(
          a!isNotNullOrEmpty(ri!body.impact),
          not(
            contains(
              { cons!CMG_IMPACT_LOW, cons!CMG_IMPACT_MEDIUM, cons!CMG_IMPACT_HIGH, cons!CMG_IMPACT_BLOCKING },
              tostring(ri!body.impact)
            )
          )
        ),
        "impact non valido",
        null
      ),
      if(
        and(
          a!isNotNullOrEmpty(ri!body.email),
          or(
            find("@", tostring(ri!body.email)) < 2,
            find(".", tostring(ri!body.email), find("@", tostring(ri!body.email))) = 0,
            find(" ", tostring(ri!body.email)) > 0
          )
        ),
        "email non valida",
        null
      )
    }
  ),
  a!map(
    valid: a!isNullOrEmpty(local!errors),
    errors: local!errors
  )
)
