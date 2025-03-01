
<!-- README.md is generated from README.Rmd. Please edit that file -->

# publishTC

Why not publish the trend-cycle? The goal of `publishTC` is to
facilitate the computation of trend-cycle component:

- Using the Cascade Linear Filter (CLF) and the surrogate
  cut-and-normalise asymmetric filters, as done by [Statistique
  Canada](https://www.statcan.gc.ca/en/dai/btd/trend-cycle);

- Using the classical Henderson symmetric filter and the surrogate
  Musgrave asymmetric filters, as done by Australian Bureau of
  Statistics (Trewin 2003);

- Using a local Parametrization of the Musgrave asymmetric filters, as
  described in Quartier-la-Tente (2024);

- Extending the Henderson symmetric fiter and the surrogate Musgrave
  asymmetric filters to take into account additive outliers and level
  shifts, as described in Quartier-la-Tente (2025).

# Bibliography

Dagum, E. B., & Luati, A. (2008). A Cascade Linear Filter to Reduce
Revisions and False Turning Points for Real Time Trend-Cycle Estimation.
*Econometric Reviews* 28 (1-3): 40‑59.
<https://doi.org/10.1080/07474930802387837>

Henderson, R. (1916). Note on graduation by adjusted average.
*Transactions of the actuarial society of America* 17: 43‑48.

Musgrave, J. (1964). A set of end weights to end all end weights. *US
Census Bureau \[custodian\]*.

Trewin, D. (2003). A guide to interpreting time series - Monitoring
trends. *Australian Bureau of Statistics Information Paper*.
<https://www.abs.gov.au/AUSSTATS/abs@.nsf/Lookup/1349.0Main+Features12003?OpenDocument>.

Quartier-la-Tente, A. (2024). Improving Real-Time Trend Estimates Using
Local Parametrization of Polynomial Regression Filters. *Journal of
Official Statistics, 40*(4), 685-715.
<https://doi.org/10.1177/0282423X241283207>.

Quartier-la-Tente, A. (2025). Estimation de la tendance-cycle avec des
méthodes robustes aux points atypiques.
<https://github.com/AQLT/robustMA>.
