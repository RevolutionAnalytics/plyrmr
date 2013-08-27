





# plyrmr

Load package and turn off Hadoop for quick demo

```r
suppressMessages(library(plyrmr))
rmr.options(backend = "local")
```

```
NULL
```

```r
rmr.options(keyval.length = 5)
```

```
NULL
```

```r
set.seed(0)
```


Create a dataset with `input`


```r
mtcars.in = input(mtcars)
```


or simply start from a HDFS path then select some larger engines


```r
mtcars.5cyl.up = subset(mtcars.in, cyl > 4)
```


then group them by cyl


```r
grouped = group.by(mtcars.5cyl.up, cyl)
```


then look at the average carbs


```r
avg.carbs = summarize(grouped, mean(carb), mean.HP = mean(hp))
```


nothing happened yet, is it real?


```r
as.data.frame(avg.carbs)
```

```
     mean.carb. mean.HP
X1        3.429   122.3
X1.1      3.500   209.2
```


This triggers a mapreduce job and brings the result into memory as a data frame. If it's too big, you can write it to a specific location.


```r
file.remove("/tmp/avg.carbs")
```

```
Warning: cannot remove file '/tmp/avg.carbs', reason 'No such file or
directory'
```

```
[1] FALSE
```

```r
avg.carbs.out = output(avg.carbs, "/tmp/avg.carbs")
```


You can still read it, if small enough


```r
as.data.frame(avg.carbs.out)
```

```
     mean.carb. mean.HP
X1        3.429   122.3
X1.1      3.500   209.2
```


Most functions are modeled after familiar ones

```
  transform #from base
  subset #from base
  mutate #from plyr
  summarize #from plyr
  select # synonym for summarize
```

`group.by` takes some dataset and column specs. `group.by.f` takes a function that generates the grouping columns on the fly.
`do` takes a data set and a function and applies it to chunks of data. It's neither a map or a reduce, this is decided based on 
how it combines with `group.by`. All the functions listed above are implemented with `do` in one line of code. An actual MR job 
is triggered by `from.dfs`, `output` or combining two of `group.by` or `group.by.f` together, since we can't easily optimize
away two groupings into one reduce phase. Comments and suggestions to rhadoop@revolutionanalytics.com.


