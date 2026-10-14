/*
 * CMG_FormatValue
 * Rule input: value (Text)
 * WAITING_CUSTOMER -> "Waiting Customer". Per etichette tradotte usare
 * CMG_GetStatusLabel.
 */
if(
  a!isNullOrEmpty(ri!value),
  ri!value,
  proper(substitute(ri!value, "_", " "))
)
