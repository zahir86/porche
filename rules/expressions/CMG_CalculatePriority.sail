/*
 * CMG_CalculatePriority
 * Rule input: categoryCode (Text), isVip (Boolean), impact (Text)
 * Wrapper sulla decision CMG_DT_CasePriority (hit policy First, vedi docs/analisi.md §5):
 * garantisce un valore di ritorno anche se la decision non trova regole.
 */
a!defaultValue(
  rule!CMG_DT_CasePriority(
    categoryCode: ri!categoryCode,
    isVip: a!defaultValue(ri!isVip, false),
    impact: ri!impact
  ),
  cons!CMG_PRIORITY_LOW
)
