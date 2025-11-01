
<!-- README.md is generated from README.Rmd. Please edit that file -->

### Résumé

Il est commun de désaisonnaliser des séries économiques pour étudier la
conjoncture et déterminer l’état du cycle dans lequel se trouve
l’économie. Toutefois, lorsqu’elles sont trop bruitées, un lissage
supplémentaire est nécessaire pour supprimer l’irrégulier et extraire la
tendance de court terme, appelée tendance-cycle, qui combine la tendance
de long terme et les fluctuations cycliques de court terme. Cet article
décrit l’intérêt de publier cette composante tendance-cycle, les
méthodes utilisées par Statistique Canada et l’Australian Bureau of
Statistic (les deux seuls instituts à publier cette composante) ainsi
que deux extensions permettant de réduire le biais des estimations en
temps réel et de prendre directement en compte l’impact de points
atypiques afin d’éviter qu’ils ne biaisent l’estimation. Cet article
détaille également des recommandations de présentation de cette
composante et comment facilement mettre en production son estimation
grâce à des rapports automatisés. Ces derniers sont appliqués à une
dizaine de publications de l’Insee (environ 80 séries).

Cette étude est accompagné d’un *package* R, `publishTC`, permettant de
facilement mettre en œuvre toutes les méthodes et recommandations. Elle
est également entièrement reproductible et tous les codes utilisés sont
disponibles sous <https://github.com/AQLT/publishTC.wp>.

Mots clés : séries temporelles, tendance-cycle, désaisonnalisation,
points de retournement.

### Abstract

It is common practice to seasonally adjust economic series in order to
study business outlook and determine the state of the cycle at which the
economy stands. However, when they are too noisy, additional smoothing
is required to remove the irregularity and extract the short-term trend,
known as the trend-cycle, which combines the long-term trend and
short-term cyclical fluctuations. This article describes the advantages
of publishing this trend-cycle component, the methods used by Statistics
Canada and the Australian Bureau of Statistics (the only two institutes
to publish this component) as well as two extensions that reduce the
bias of real-time estimates and take direct account of the impact of
atypical points to prevent them from biasing estimates. This article
also describes recommendations for the presentation of this component
and how to put it into production using automated reports. These, by
applying it to a dozen INSEE publications (around 80 series).

This study is accompanied by an R package, `publishTC`, making it easy
to implement all the methods and recommendations. It is fully
reproducible and all the codes used are available under
<https://github.com/AQLT/publishTC.wp>.

Keywords: time series, trend-cycle, seasonal adjustment, turning points.
