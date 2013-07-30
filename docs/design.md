# Plyrmr

### Overarching goal
**Capture important subsets of rmr2 use cases while making it easier to use**.

### Specific goals
* make the key value concept go away
* as a consequence, the equivalent of map and reduce functions have only one argument
* the `keyval` function or equivalen is not in the API 

## How
* focus on data frames for now (matrix support should be automatic). Same choice as `dplyr`, motiveated by patterns of usage.
* map and reduce can be single argument functions. If key is present it is cbinded. Return value is also data frame. Hence there is no difference between map and reduce, and they are called simply `do`. The concept of *shuffling* or *grouping* is made available through a separate function call.
* there is an additional call `group.by` to specify the key or grouping. The model is the `index` argument in `tapply` and, more closely, the `group_by` call in `dplyr`.
* Above the abstraction level of `do` and `group.by` there is a layer, insprired by `plyr` in its selection of features, hence the name of this packages, that should allow to express most data manipulation  tasks without defining new functions
* To use familiar function names, widely used generic functions are enriched with additional methods to work on big data: `as.data.frame`, `subset`, `transform`, `mutate` etc. It is a selection from the `base` and `plyr` packages identified by Hadley Wickham as capable of expressing most data manipulation tasks, loosely defined as transformation applied to the data up to but not including modeling. 
* To make these functions more reusable without a severe performance penalty, delayed evaluation is used. This means jobs are not executed in a 1:1 relation with each of these calls. Rather, different manipulations are combined into a sequence and that sequence is mapped to one or more jobs. The evaluation is triggered when:
   * data is brought into main memory with `as.data.frame`
   * data is written to a user-set location with `output`
   * multiple group.by statements are combined, as multiple jobs become necessary in this case
   * other scenarios still to be defined (e.g. a size check on a data set)

## Alternatives to `arrange` (sorting)

It'hard to sort with Hadoop. It's harder to sort with rmr2. The output of a scalable, distributed program is always subdivided into multiple partitions, because there are are always multiple reducers running (same story if it is map-only). So each partition can be sorted and partitions can be range-disjoint, and named in a way that's suggestive of the content (10-quantile, 20-quantile or some such). This is recognized as a form of sorting (see the Terasort benchmark), but it is no replacement for old fashioned sorting (without partitions). One application is eliminating duplicates. If duplicates span partitions, hadoop sorting is of no or modest help. Another is moving window algorithms of some sort, where a function needs to be applied to every group of N data points that are consecutive in some order. Again when the window spans partitions, hadoop sorting doesn't help. So it seems hadoop sorting is no immediate or complete replacement for sorting the old fashioned way. It's great for searching  for instance, since with appropriate partition naming we can do binary search, and indexing is also a possibility, but not for other purposes of statistical and algorithmic interest. `rmr2` has the additional challenge of not allowing custom partitioners, which are used in hadoop sorting (range partitioners). Here we are on a triple quest: 

1. list as many application of sorting as possible, 
2. provide implementations for them based on `rmr2` and 
3. see if any subset of these is *fundamental*, meaning that any application of sorting can be expressed as an application of one of these fundamental sorting-related algorithms

### List of sorting related algorithms

2. Duplicate elimination.
3. Intersections
3. Unions
4. Grouping
5. Joins
1. Quantiles.
2. Moving window algorithms
3. Top-k and bottom k
4. Rank statistics
5. Binning and counting

#### Duplicate elimination

This is easly achived by grouping by value and then returning a single representative element in the reduce phase. Combiner-friendly

#### Intersections

Special case of joins

#### Unions

Can be achieved with multiple inputs and duplicate elimination

#### Grouping

This is built into `rmr2` and actually Hadoop

#### Joins

These are built into `rmr2` but considered not very easy to use. A merge-like interface is in order.

#### Quantiles

 Each quantile doesn't need sorting, but to compute many of them in one pass sorting is a possibility. Could provide approximate algorithm based on recursive weighted merger of quantiles.
 
#### Top-k and bottom-k

These are special cases of quantiles but can easily be addressed without sorting

#### Moving window

This could be implemented on top of grouping, by sending all the data related to the same window (and, for efficiency, to multiple overlapping windows) to each reducer.

#### Rank statistics

This is a tough one

#### Binning and counting

Given pre-defined boundaries, group by those boundaries and compute a function of each bin, which could be as simple as a count. Easily built on top of grouping.
