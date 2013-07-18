plyrmr
=====

Create a dataset with to.dfs

```
mtcars.mr = to.dfs(mtcars)
```

or simply start from a hdfs path then select some big ones

```
big.ones = subset.mr(mtcars.mr, cyl > 4)
```

then group them by cyl

```
grouped = group.by(big.ones, "cyl")
```

then look at the average carbs

```
avg.carbs = summarize.mr(grouped, mean(carb), mean(hp))
```

nothing happened yet, is it real?

```
from.dfs(avg.carbs)
```

This triggers a mapred job and brings the result into mem as a df. If it's too big, you can 

```
output(avg.carbs, "/data/cars/avg.carbs")
```

Most functions are modeled after familiar ones

```
  transform.mr #from base
  subset.mr #from base
  filter.mr #synonim for subset
  mutate.mr #from plyr
  summarize.mr #from plyr
  select.mr # synonym for summarize
```

`group.by` takes some dataset and column specs. `group.by.f` takes a function that generates the grouping columns on the fly.
`do` takes a data set and a function and appliess it to chunks of data. It's neither a map or a reduce, this is decided based on 
how it combines with `group.by`. All the functions listed above are implemented with `do` in one line of code. An actual MR job 
is triggered by `from.dfs`, `output` or combining two of `group.by` or `group.by.f` together, since we can't easily optimize
away two groupings into one reduce phase. Comments and suggestions to rhadoop@revolutionanalytics.com.
