# `dplyr` vs `plyrmr`

## Goals

`dplyr` is for data frames and also supports a number of data bases (table equivalent to a data frame). Computation is offloaded to the data base by R to SQL translation. `plyrmr` is for big data (Hadoop mapreduce and in the future, spark). Computation is performed in-cluster in multiple R instances.

## Backends

For `dplyr`, backends support "hit or miss" compatibility. If a function works on a backend it has to be correct, but if it doesn't, so be it. Needless to say, many things that are possible on data frames are not on SQL backends, because the R interpreter is no available in-data-base. For `plyrmr`, the main backend is hadoop. local is for learning and debugging and lacks a few features and spark is in the works. The goals is semantic equivalence between backends. This is not always easy but it's a reference point. The tests are 50% or more backend compatibility tests. 

## Abstraction leaks

One wouldn't want to admit it, but some backends are more important than others and affect the API. The biggest diffence is that ungrouped data in `dplyr` is in one chunk, in `plyrmr` is split in arbitrary chunks. `plyrmr` has `gather` but it can only be run with a combiner. For `dplyr`, one influence is efficiency on data frames where it has the goal of being the fastest package or close. This is the official reason for not having multi-row summaries. Other leaks are SQL-related, like some of the windowed operators. `plyrmr`'s abstraction leaks are related to the map reduce model and R efficiency issues, like the mergeable and vectorized properties that have no equivalent in `dplyr`. Also, grouping on a set of columns that define at least one large group can hit memory limits. In `dplyr` it's either all in memory anyway, or certain backends will limit aggregation so that this problem doesn't occur (implicit combiners).

## Programming vs interactive

`plyrmr` has had the goal, from the very beginning, to support programming as well as interactive use. For `dplyr`, interactive use came second, but it's catching up. 

## Freeness in composition

Is a guiding principle for `plyrmr`, so that `data %|% group(x) %|% group(y)` is the same as `data %|% group(x) %|% group(y)`. In `dplyr` the former is equivalent to `data %|% group(y)`. If you are not familiar with abstract algebra, what this mean is that complex expression should do more complex things than simple expressions, more or less. The two packages differ on their default choices: in either there is the possibility of simulating the grouping of the other package with options or a separate `ungroup` call.

## Expressive naming

`plyrmr` aims for expressive names. Hence we question the choice of `transform` or `mutate` for functions that can only add columns and for a library that embraces immutability as one of its cornerstones. We strive to avoid name clashes with functions in bundled packages (e.g. `filter`). We use patterns to suggest semantics (e.g. `gapply` sounds like a member of the apply family, whereas `do` doesn't).

## Simple, orthogonal rules

`plyrmr`, with few exceptions, avoids the use of heuristics to guess what the user meant (the exception probably being variable renaming with combiners, and then only because no better solution was available). `dplyr` sometimes enforces odd rules and limitations under the assumption that any breach would only allow to write incorrect programs. This is called being "an opinionated package" in @hadley-speak. For instance (`%|%` is `plyrmr` and `%>%` is re-exported by `dplyr` from `magrittr`):


```r
suppressPackageStartupMessages(library(`plyrmr`))
4 %|% sqrt #`plyrmr`
```

```
## [1] 2
```

```r
4 %>% sqrt #`dplyr`
```

```
## [1] 2
```

```r
4 %|% sqrt(..) #`plyrmr`
```

```
## [1] 2
```

```r
4 %>%  sqrt(.)  #`dplyr`
```

```
## [1] 2
```

```r
2 %|% sqrt(..*..) #`plyrmr`
```

```
## [1] 2
```

```r
2 %>%  sqrt(.*.)  #`dplyr`
```

```
## Error: object '.' not found
```

The author does not regard the last failure as a bug, but as a feature. It protects naive programming from hurting themselves and doing naughty things. `plyrmr` always sides with composition of syntactic forms, simplicity of rules and principle of least surprise.

## No rownames left behind

In a break from ordinary defintion of data frames, `dplyr` does not support row names. `plyrmr` tries to do so (with uber-powerful functions like transmute the goal may be ill defined and hard to reach). After implementing this feature, we have a fairly vivid understanding of why `dplyr` doesn't.
