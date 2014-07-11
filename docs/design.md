# Plyrmr

### Overarching goal
**Capture important subsets of rmr2 use cases while making it easier to use**.

### Specific goals
* make the key value concept go away
* as a consequence, the equivalent of map and reduce functions have only one argument
* make defining new functions not necessary in at least a subset of cases, and simpler when necessary.
* the `keyval` function or equivalent is not in the API 

## How
* focus on data frames for now (matrix support should be automatic). Same choice as `dplyr`, motiveated by patterns of usage.
* map and reduce can be single argument functions. If key is present it is cbinded. Return value is also data frame. Hence there is no difference between map and reduce, and they are called simply `do`. The concept of *shuffling* or *grouping* is made available through a separate function call.
* there is an additional call `group` to specify the key or grouping. The model is the `index` argument in `tapply` and, more closely, the `group_by` call in `dplyr`.
* Above the abstraction level of `do` and `group` there is a layer, insprired by `plyr` in its selection of features, hence the name of this packages, that should allow to express most data manipulation  tasks without defining new functions
* To use familiar function names, widely used generic functions are extended with additional methods to work on Hadoop-stored data sets: `as.data.frame`, `subset`, `transform`, `mutate` etc. It is a selection from the `base` and `plyr` packages identified by Hadley Wickham as capable of expressing most data manipulation tasks, loosely defined as transformation applied to the data up to but not including modeling. Sometimes some equivalent functions are present in the API, when the name used in base or plyr seems counterintuitive. Eventually we may have to decide between following `base` and `plyr` most closely for familiarity or deviate slightly when better choices are available &mdash; see also `dplyr` for some fresh thinking on data maniplulation by the author of `plyr` himself. Backward compatibility at all costs in not reasonable.
* To make these functions more reusable without a severe performance penalty, delayed evaluation is used. This means jobs are not executed in a 1:1 relation with each of these calls. Rather, different manipulations are combined into a sequence and that sequence is mapped to one or more jobs. The evaluation is triggered when:
   * data is brought into main memory with `as.data.frame`
   * data is written to a user-set location with `output`
   * multiple group statements are combined, as multiple jobs become necessary in this case
   * other scenarios still to be defined, e.g. a size check on a data set
* a notable omission from the data manipulation set of primitives is anything related to order &mdash; equivalent to `arrange` in `dplyr`. This is because the partitioning of data make sorting less useful and even ill-defined in Hadoop, despite the existence of sorting benchmarks like Terasort. In that case, a data set is considered sorted when each partition is sorted and partitions are range disjoint and possibly names in a way to represent their relative order &mdash; we will call this setting *partitioned sorting* (PS). This is not sufficient to solve a number of problems that are normally solved with a sort and additional processing steps. For instance, computing the ranks requires PS plus knowledge of the size of the partitions and possibly an additional job to add those sizes to within-partitions ranks. It's possible but the additional work over PS seems substantial. Another example is a moving window statistics, for instance as implemented by the function `filter` in R. When a window falls across partitions, it is not clear how to compute the statistics for that window. Given these consideration, we decided to provide a number of partial alternative to PS that are more readily implemented in Hadoop and cover a number of common statistical uses, as detailed in the next section. If these are necessary and sufficient to replace total ordering remains to be seen, and this part of the API should be considered even more fluid than the rest.


## Alternatives to `arrange` (sorting)

 Here we are on a triple quest: 

1. list as many application of sorting as possible, 
2. provide implementations for them based on `rmr2` and 
3. see if any subset of these is *fundamental*, meaning that any application of sorting can be expressed as an application of one of these fundamental sorting-related algorithms

### List of sorting related algorithms

2. Duplicate elimination. DONE
3. Intersections DONE
3. Unions DONE
4. Grouping DONE
5. Joins DONE
1. Quantiles. DONE
2. Moving window algorithms DONE
3. Top-k and bottom k DONE
4. Rank statistics TODO
5. Binning and counting (counting done, binning todo)

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
