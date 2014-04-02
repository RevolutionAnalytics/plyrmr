








# Tutorial

## Predefined operations

Let's start with a simple operation such as adding a column to a data frame. The data set `mtcars` comes with R and contains specification and performance data  about a few car models:


```r
mtcars
```

```
                     mpg cyl  disp  hp drat    wt  qsec vs am gear carb
Mazda RX4           21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
Mazda RX4 Wag       21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
Datsun 710          22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
Hornet 4 Drive      21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
Hornet Sportabout   18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
Valiant             18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
Duster 360          14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
....
```


One may be interested in how many carburetors per cylinder each model uses, and that's a simple `bind.cols` call away:


```r
bind.cols(mtcars, carb.per.cyl = carb/cyl)
```

```
    mpg cyl  disp  hp drat    wt  qsec vs am gear carb carb.per.cyl
1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4       0.6667
2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4       0.6667
3  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1       0.2500
4  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1       0.1667
5  18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2       0.2500
6  18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1       0.1667
7  14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4       0.5000
....
```


`bind.cols` is `plyrmr`'s own version of `transform` and provides a model that is common to many functions in `plyr` and `plyrmr`. The function name gives a general idea of what the function is for. The first argument is always the data set to be processed. The following arguments provide the details of what type of processing is going to take place, in the form of one or more optionally named expressions. These expressions can refer to the columns of the data frame as if they were additional variables, according to *non standard evaluation* rules.
Now let's imagine that we have a huge data set with the same structure but instead of being stored in memory, it is stored in a HDFS file named "/tmp/mtcars". It's way too big to be loaded with `read.table` or equivalent. With `plyrmr` one just needs to enter:


```r
bind.cols(input("/tmp/mtcars"), carb.per.cyl = carb/cyl)
```

```
    mpg cyl  disp  hp drat    wt  qsec vs am gear carb carb.per.cyl
1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4       0.6667
2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4       0.6667
3  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1       0.2500
4  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1       0.1667
5  18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2       0.2500
6  18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1       0.1667
7  14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4       0.5000
....
```


What we see are only a few arbitrary rows from the resulting data set. This is not only a consequence of the limited screen real estate, but also, in the case of large data sets, of the capacity gap between memory of a single machine and big data. In general, we can't expect to be able to load big data in memory. Sometimes, after summarization or filtering, the result of processing big data is small enough to fit into main memory. In this example, we know the data set is small so we can just go ahead and enter:


```r
as.data.frame(bind.cols(input("/tmp/mtcars"), carb.per.cyl = carb/cyl))
```

```
    mpg cyl  disp  hp drat    wt  qsec vs am gear carb carb.per.cyl
1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4       0.6667
2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4       0.6667
3  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1       0.2500
4  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1       0.1667
5  18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2       0.2500
6  18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1       0.1667
7  14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4       0.5000
....
```


If we can't make this assumption, we may need to write the results of a computation out to a specific path, that is we need the `output` call:





```r
output(bind.cols(input("/tmp/mtcars"), carb.per.cyl = carb/cyl), "/tmp/mtcars.out")
```

```
    mpg cyl  disp  hp drat    wt  qsec vs am gear carb carb.per.cyl
1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4       0.6667
2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4       0.6667
3  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1       0.2500
4  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1       0.1667
5  18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2       0.2500
6  18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1       0.1667
7  14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4       0.5000
....
```


This is the real deal: we have performed a computation on the cluster, in parallel, and the data is never loaded into memory at once, but the syntax and semantics remain the familiar ones. The last run processed all of 32 rows, but on a large enough cluster it could run on 32 terabytes &mdash; in that case you can not use `as.data.frame`.
Even if `output` appears to return the data to be printed, that's only a sampling. The main effect of the `output` call is to write out to the specified file.

`bind.cols` is one of several functions that `plyrmr` provides in a Hadoop-powered version:

 * data manip:
   * `bind.cols`: add new columns
   * `select`: select columns
   * `where`: select rows
   * `transmute`: all of the above plus summaries
 * from `reshape2`:
   * `melt` and `dcast`: convert between *long* and *wide* data frames
 * summary:
   * `count.cols`
   * `quantile.cols`
   * `sample`
 * extract
   * top.k
   * bottom.k


## Why does `plyrmr` have `bind.cols`, `transmute` and `where` instead of `transform`, `summarize` and `subset`

The main goal of plyrmr if providing big-data close equivalents of well known and useful data frame manipulations and in fact an early design did not define any new functions for data frames. So why try to reinvent the wheel with `bind.cols`, `transmute` and `where`? The main reason is that `transform`, `mutate` & C. work best interactively, at the prompt, but they have some problems when used in other functions or packages. The evaluation of arguments can break, and the reason is very technical and covered in [another document](non-standard-eval.md). But most recently we've been able to overcome this problem at least for `select`, so why not go the whole nine yards? First of all, we need multi-row summaries. These are not possible in either `plyr` or `dplyr` as of this writing (there is an issue open about this, so things may change). Multi-row summaries are extremely important in statistics (quantiles, sketches etc). Next is support for list columns, which are needed for things like models, see the last section. Third, we can't stand functions that pretend to do more than they actually can, like `transform`. It's a silly vocabulary land grab that doesn't help anyone. Finally, we hate grumpy defaults, like functions that silently drop unnamed arguments, such as  &mdash; you've guessed it  &mdash; `transform`. Functions in `plyrmr` try a little harder to be helpful and, in that case, make up sensible names. It's possible that as `dplyr` matures we will buy into that API more extensively. Alredy today, you can use a `magic.wand` (see below) to give Hadoop powers to many functions in `dplyr`.


## Combining Operations

What if none of the basic operations is sufficient to perform a needed data processing step? The first available tool is to combine different operations. Going back to the previous example, let's say we want to select cars with a carburetor per cylinder ratio greater than 1. Do such things even exist? On a data frame, there is a quick way to compute the answer, which is


```r
where(
	bind.cols(
		mtcars, 
		carb.per.cyl = carb/cyl), 
	carb.per.cyl >= 1)
```

```
    mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
30 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
31 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


Wouldn't it be nice if we could do exactly the same on a Hadoop data set? In fact, we almost can:


```r
where(
	transmute(
		input("/tmp/mtcars"),
		carb.per.cyl = carb/cyl,
		.cbind = TRUE ),
	carb.per.cyl >= 1)
```

```
   mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
1 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
2 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


The main differences between the data frame version and the Hadoop data version are the input and the output. All there is in between, pretty much works the same. 

## The pipe operator

You may have noticed that the last example consists of a fairly complex expression, with function calls nested inside other function calls multiple times. The drawbacks of that are twofold. First, the order in which functions appear in the code, top to bottom, is the opposite of the order in which they are executed. Second, additional arguments to each function can be very far from the name of the function. This problem can be mitigated with proper indentation, but it still is a problem. One workaround is to rewrite complex expressions as chains of assignments:


```r
x =	bind.cols(mtcars, carb.per.cyl = carb/cyl) 
where(x, carb.per.cyl >= 1)
```

```
    mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
30 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
31 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


The purists will find that introducing one variable for each intermediate step quite unsightly. To avoid this plyrmr offers a UNIX-style pipe operator, inspired by two R implementations, by [@crowding](https://github.com/crowding/vadr/blob/master/R/chain.R) and [@hadley](https://github.com/hadley/dplyr/blob/master/R/chain.r).


```r
mtcars %|%
	bind.cols(carb.per.cyl = carb/cyl) %|%
	where(carb.per.cyl >= 1)
```

```
    mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
30 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
31 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


This operator provides the value of the leftmost expression as the first unnamed argument of the next function call and evaluates it. When multiple operators are chained, the associate to the left. If the first argument is not the right one, you can specify any function argument in a complex expression to be the designated one with the special name `.` as in `2 %|% sqrt(1/.)` Rather than arguing over which style is superior, it's probably best to bask in the flexibility made possible by the R language and your indefatigable developers and pick the one that fits your style or a specific situation. In particular, pipes can not express more complex data flows where two flows merge or one splits. In the following I will alternate between these three notations (nested, assignment chain and pipe operator) based on which seems the clearest. It should be safe to assume that each example can be translated into any of the three.


## Custom operations
Another way to extend the functionality of `plyrmr` built-in data manipulation functions is to take any function that accepts a data frame in input and returns a data frame and use the function `gapply` to give it Hadoop powers. For instance, you have a function that returns the rightmost column of a data frame. This is not simple to achieve with the functions explored so far, but it is a quick one liner:


```r
last.col = function(x) x[, ncol(x), drop = FALSE]
```


Wouldn't it be great if we could run this on a Hadoop data set? Well, we almost can:


```r
as.data.frame(gapply(input("/tmp/mtcars"), last.col))
```

```
   carb
1     4
2     4
3     1
4     1
5     2
6     1
7     4
....
```


`gapply` takes any function that accepts and returns data frames, executes it on a Hadoop data set in parallel on relatively small chunks of the data and passes the results to `as.data.frame` or `output` which send them to their final destination. Wouldn't it absolutely perfect if the `lastcol` function itself knew whether it's working on a Hadoop data set or a data frame and do the right thing? It actually is possible:


```r
magic.wand(last.col)
```

```
NULL
```

```r
last.col(mtcars)
```

```
                    carb
Mazda RX4              4
Mazda RX4 Wag          4
Datsun 710             1
Hornet 4 Drive         1
Hornet Sportabout      2
Valiant                1
Duster 360             4
....
```

```r
last.col(input("/tmp/mtcars"))
```

```
   carb
1     4
2     4
3     1
4     1
5     2
6     1
7     4
....
```


For people familiar with object oriented programming in R, this function takes an existing data frame function, meaning one with a data frame as its first argument and return value, and creates a generic function by the same name, with a method for data frames equal to the original function and one for big data sets using do as shown above. The internal R dispatch machinery decides which of the methods to call based on the class of the first argument. If `dplyr` is your style, you can keep using it on Hadoop data calling `magic.wand(mutate, TRUE)` or `magic.wand(filter, TRUE)`. The optional second and third arguments to `magic.wand` help the function process its argument's arguments in the way appropriate for that function, more details in `help(magic.wand)`.

## Grouping

Until now we performed row by row operations, whereby each row in the results depends on a single row in the input. In this case we don't care if the data is grouped in one way or another. In most other cases, this distinction is important. For instance, if we wanted to compute the total number of carburetors, we could enter:


```r
transmute(mtcars, sum(carb))
```

```
  sum.carb.
1        90
```


What happens if we do this on a Hadoop data set?





```r
transmute(input("/tmp/mtcars3", format = if3), sum(carb))
```

```
  sum.carb.
1        20
2        11
3         6
4        15
5        17
6        11
7        10
....
```


That's not what we wanted and that's the where the size of the data cannot be ignored or abstracted away. Think of data in Hadoop as always grouped, one way or another. It couldn't be otherwise: it is stored on multiple devices and, even if it weren't, we can only load it into memory in small chunks. In this specific example, the data is small and to highlight this problem I created an input format that reads the data in unreasonably small chunks, but in Hadoop applications this is the norm. So think of the data as always grouped, initially in arbitrary fashion and later in the way we determine using the functions `group`, `group.f`, `gather` and more. These were inspired by the notion of key in mapreduce, the SQL statement and the `dplyr` function with similar names. In this case, we computed partial sums for each of the arbitrary groups &mdash; here set to a very small size to make the point. Instead we want to group everything together so we can enter:


```r
input("/tmp/mtcars3", format = if3) %|%
	gather() %|%
	transmute(sum(carb), .mergeable = TRUE)
```

```
  sum.carb.
1        90
```





You may have noticed the contradiction between the above statement that data is always in chunks with the availability of a `gather` function. Luckily, there is an advanced way of grouping recursively, in a tree like fashion, that works with associative and commutative operations such as the sum, which is enabled by the `.mergeable` argument and makes `gather` possible. Anyway, it will all be more clear as we cover other grouping functions.

The `group` function takes an input and a number of arguments that are evaluated in the context of the data, exactly like `bind.cols`. The result is a Hadoop data set grouped by the columns defined in those arguments. After this step, all rows that are identical on the columns defined in the `group` call will be loaded into memory at once and processed in the same call. Here is an example. Let's say we want to calculate the average mileage for cars with the same number of cylinders:


```r
input("/tmp/mtcars") %|%
	group(cyl) %|%
	transmute(mean.mpg = mean(mpg))
```

```
    cyl mean.mpg
1     6    19.74
1.1   4    26.66
1.2   8    15.10
```


This is mostly a scalable programs, but there are some caveats: we need to be mindful of the size of the groups. If they are very big they will bust memory limits, so we need to reach for some advanced techniques to avoid this problem. If they are very small, like a handful of rows, we may run into some efficiency issues related to the current R and `rmr2` implementations rather than fundamental (so there is hope they will go away one day). 

When the definition of the grouping column is more complicated, we may need to reach for the uber-general `group.f`, the grouping relative of `gapply` (in fact, these two functions are the foundation for everything else in `plyrmr`). Let's go back to the `last.col` example. If we need to group by the last columns of a data frame, this is all we need to do:




## Better than SQL

Despite the SQL-ish flavor and undeniable SQL inspiration for some of these operations, we want to highlight a few ways in which `plyrmr` is much more powerful than SQL. The first is that summaries or aggregation don't need to be limited to a single row. One form of aggregation are summaries and summaries can have many elements, even thousands. Momenta, quantiles, histograms, samples, they all have multiple entries. You could represent them as multiple columns up to a certain size, but removing the SQL limitation on aggregations is a good thing. Let's say you want to examine the quantiles of the gas mileage data in each group of cars with the same number of carburetors


```r
input("/tmp/mtcars") %|%
	group(carb) %|%
	quantile.cols() 
```

```
    carb   mpg   cyl   disp     hp  drat    wt  qsec       vs     am  gear
1      4 10.86 6.000 161.20 112.05 3.012 2.844 15.20 0.000000 0.0000 3.000
2      4 13.92 6.195 185.39 131.01 3.271 3.326 16.25 0.000000 0.0000 3.002
3      4 15.25 8.000 350.50 210.00 3.815 3.505 17.22 0.000000 0.0000 3.500
4      4 18.19 8.000 392.87 234.85 3.908 4.408 17.85 0.000000 0.4219 3.998
5      4 20.72 8.000 460.48 250.75 4.011 5.354 18.43 0.842500 1.0000 4.302
1.1    1 21.18 4.000  78.21  65.93 3.151 1.968 18.96 1.000000 0.0000 3.000
2.1    1 22.09 4.000  91.94  78.05 3.652 2.205 19.36 1.000000 0.4450 3.445
....
```



And what to say about working in a real programming language, and one with an unmatched library of statistical methods for good measure? You know how many aggregate functions ANSI SQL 92 has? 5, according to my references. What if you wanted to compute a linear model for each group? Forget it, or write some extension against a DBMS-specific API in some vendor-selected language. Not so with `plyrmr`:


```r
models = 
	input("/tmp/mtcars") %|%
	group(carb) %|%
	transmute(model = list(lm(mpg~cyl+disp))) %|%
	as.data.frame()
models
```

```
    carb        model
1      4 c(22.693....
1.1    1 c(9.2859....
1.2    2 c(32.723....
1.3    3 c(16.3, ....
1.4    6 c(19.7, ....
1.5    8 c(15, NA....
```

```r
models[1,2]
```

```
[[1]]

Call:
lm(formula = mpg ~ cyl + disp)

Coefficients:
(Intercept)          cyl         disp  
     22.694        0.329       -0.030  
....
```

