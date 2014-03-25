








# Tutorial

## Predefined operations

Let's start with a simple operation such as adding a column to a data frame. The data set `mtcars` comes with R and contains specification and performance data  about a few car models:


```r
mtcars
```

```
                 model  mpg cyl  disp  hp drat    wt  qsec vs am gear carb
1            Mazda RX4 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
2        Mazda RX4 Wag 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
3           Datsun 710 22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
4       Hornet 4 Drive 21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
5    Hornet Sportabout 18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
6              Valiant 18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
7           Duster 360 14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
....
```


One may be interested in how many carburetors per cylinder each model uses, and that's a simple `select` call away:


```r
bind.cols(mtcars, carb.per.cyl = carb/cyl)
```

```
                 model  mpg cyl  disp  hp drat    wt  qsec vs am gear carb carb.per.cyl
1            Mazda RX4 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4       0.6667
2        Mazda RX4 Wag 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4       0.6667
3           Datsun 710 22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1       0.2500
4       Hornet 4 Drive 21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1       0.1667
5    Hornet Sportabout 18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2       0.2500
6              Valiant 18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1       0.1667
7           Duster 360 14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4       0.5000
....
```


`bind.cols` is `plyrmr`'s own version of `transform` and provides a model that is common to many functions in `plyr` and `plyrmr`. The function name gives a general idea of what the function is for. The first argument is always the data set to be processed. The following arguments provide the details of what type of processing is going to take place, in the form of one or more optionally named expressions. These expressions can refer to the columns of the data frame as if they were additional variables, according to *non standard evaluation* rules.
Now let's imagine that we have a huge data set with the same structure but instead of being stored in memory, it is stored in a HDFS file named "/tmp/mtcars". It's way too big to be loaded with `read.table` or equivalent. With `plyrmr` one just needs to  enter:




What we see are only a few arbitrary rows from the resulting data set. This is not only a consequence of the limited screen real estate, but also, in the case of large data sets, of the capacity gap between memory of a single machine and big data. In general, we can't expect to be able to load big data in memory. Sometimes, after summarization or filtering, the result of processing big data is small enough to fit into main memory. In this example, we know the data set is small so we can just go ahead and enter:


```r
as.data.frame(bind.cols(input("/tmp/mtcars"), carb.per.cyl = carb/cyl))
```

```
                 model  mpg cyl  disp  hp drat    wt  qsec vs am gear carb carb.per.cyl
1            Mazda RX4 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4       0.6667
2        Mazda RX4 Wag 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4       0.6667
3           Datsun 710 22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1       0.2500
4       Hornet 4 Drive 21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1       0.1667
5    Hornet Sportabout 18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2       0.2500
6              Valiant 18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1       0.1667
7           Duster 360 14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4       0.5000
....
```


If we can't make this assumption, we may need to write the results of a computation out to a specific path, that is we need the `output` call:







This is the real deal: we have performed a computation on the cluster, in parallel, and the data is never loaded into memory at once, but the syntax and semantics remain the familiar ones. The last run processed all of 32 rows, but on a large enough cluster it could run on 32 terabytes &mdash; in that case you can not use `as.data.frame`.
Even if `output` appears to return the data to be printed, that's only a sampling. The main effect of the `output` call is to write out to the specified file.

`select` is one of several functions that `plyrmr` provides in a Hadoop-powered version:

 * from `base`:
   * `select`: add new columns
   * `where`: select columns and rows
 * from `plyr`:
    * `summarize`: create summaries
 * from `reshape2`:
   * `melt` and `dcast`: convert between *long* and *wide* data frames
 * new in `plyrmr`:
   * `select`: does everything that `select` and `summarize` do in addition to selecting columns.
   * `where`: select rows
   * these are more suitable for programming then the functions they replace, as will be explained later.
 * summary:
   * `count.cols`
   * `quantile.cols`
   * `sample`
 * extract
   * top.k
   * bottom.k
 
`plyrmr` extends all these operations to Hadoop data sets, trying to maintain semantic equivalence, with limitations that will be made clear later. These functions are not intended as a minimal set of operations: there is a lot of functionality overlap. We just wanted to support existing usage to help users transitioning to Hadoop programming.
 
## Combining Operations

What if none of the basic operations is sufficient to perform a needed data processing step? The first available tool is to combine different operations. Going back to the previous example, let's say we want to select cars with a carburetor per cylinder ratio greater than 1. Do such things even exist? On a data frame, there is a quick way to compute the answer, which is


```r
mtcars %|%
	bind.cols(carb.per.cyl = carb/cyl) %|%
	where(carb.per.cyl >= 1)
```

```
           model  mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
30  Ferrari Dino 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
31 Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


Wouldn't it be nice if we could do exactly the same on a Hadoop data set? In fact, we almost can:


```r
x = 
	input("/tmp/mtcars") %|%
	bind.cols(carb.per.cyl = carb/cyl) %|%
	where(carb.per.cyl >= 1)
as.data.frame(x)
```

```
          model  mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
1  Ferrari Dino 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
2 Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


The main differences between the data frame version and the Hadoop data version are the input and the output. All there is in between, pretty much works the same. 

## The pipe operator

You may have noticed that the last example consists of a fairly complex expression, with function calls nested inside other function calls multiple times. The drawbacks of that are twofold. First, the order in which functions appear in the code, top to bottom, is the opposite of the order in which they are executed. Second, additional arguments to each function can be very far from the name of the function. This problem can be mitigated with proper indentation, but it still is a problem. One workaround is to rewrite complex expressions as chains of assignments:


```r
x =	bind.cols(mtcars, carb.per.cyl = carb/cyl) 
where(x, carb.per.cyl >= 1)
```

```
           model  mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
30  Ferrari Dino 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
31 Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


The purists will find that introducing one variable for each intermediate step quite unsightly. To avoid this plyrmr offers a UNIX-style pipe operator, inspired by two R implementations, by [@crowding](https://github.com/crowding/vadr/blob/master/R/chain.R) and [@hadley](https://github.com/hadley/dplyr/blob/master/R/chain.r).


```r
mtcars %|%
	bind.cols(carb.per.cyl = carb/cyl) %|%
	where(carb.per.cyl >= 1)
```

```
           model  mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
30  Ferrari Dino 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
31 Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


What this does is providing the value of the leftmost expression as the first unnamed argument of the next function call, evaluate this combination and continue to the next operator. Actually, that's the default behavior, but you can specify any function argument in a complex expression to be the designated one with the special name `.`. Rather than arguing over which style is best, it's probably best to bask in the flexibility made possible by the R language and your indefatigable developers and pick the one that fits one's style or a specific situation. In particular, pipes can not express more complex data flows where two flows merge or one splits. In the following I will alternate between these three notations (nested, assignment chain and pipe operator) based on which seems the clearest. It should be safe to assume that each example can be translated into any of the three.


## Why you should use `plyrmr`'s `bind.cols`, `transmute` and `where`
TODO: rewrite this part
work best interactively, at the prompt, but they have some problems when used in other functions or packages. These limitations are inherited from the `base` package functions, not peculiar to their `plyrmr` brethren. `plyrmr` makes an attempt to provide two functions that match the convenience of `select` and `where` without their pitfalls. While we were at it, we also tried to make them more general and give them a cleaner but still familiar (SQL-inspired) interface. Let me introduce `select` and `where`. These are `plyrmr` functions with methods for data frames and Hadoop data sets and they are appropriate for interactive and programming use. The previous examples become, using these functions:


```r
mtcars %|%
	bind.cols(carb.per.cyl = carb/cyl) %|%
	where(carb.per.cyl >= 1)
```

```
           model  mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
30  Ferrari Dino 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
31 Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


and:


```r
x = 
	input("/tmp/mtcars") %|%
	bind.cols(carb.per.cyl = carb/cyl) %|%
	where(carb.per.cyl >= 1)
as.data.frame(x)
```

```
          model  mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
1  Ferrari Dino 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
2 Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


Similar, but they work everywhere. For instance, if `where` is called within some function, which is in its turn used in some other function, we can have the following situation:


```r
where.mtcars.1 = function(...) where(mtcars, ...)
high.carb.cyl.1 = function(x) {where.mtcars.1(carb/cyl >= x) }
high.carb.cyl.1(1) 
```

```
Error: (list) object cannot be coerced to type 'double'
```


Unfortunately, it doesn't work. With `where` instead:


```r
where.mtcars.2 = function(...) where(mtcars, ..., .envir = parent.frame())
high.carb.cyl.2 = function(x) {where.mtcars.2(carb/cyl >= x) }
high.carb.cyl.2(1)
```

```
           model  mpg cyl disp  hp drat   wt qsec vs am gear carb
30  Ferrari Dino 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6
31 Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8
```


The exact reason why `where` needs an additional argument in this scenario and what to provide are out of scope for this tutorial, but the message is that with `where` and `select` you can transition nicely from interactive R use to development. The R documentation recommends to use `[]` only when programming, but having to rewrite code in a different context, to a computer scientist, is just an admission of defeat. Therefore `plyrmr` provides methods for `select`, `where`,  and `summarize` because of their widespread use, but we recommend to check out `where` and `select` (many thanks to Hadley Wickham for valuable discussions on this issue).

## Custom operations
Another way to extend the functionality of `plyrmr` built-in data manipulation functions is to take any function that accepts a data frame in input and returns a data frame and use the function `do` to give it Hadoop superpowers (`do` is named after the equivalent function in `dplyr`, but the idea is not new). For instance, you have a function that returns the rightmost column of a data frame. This is not simple to achieve with the functions explored so far, but it is a quick one liner:


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


What `do` does is take any function that reads and writes data frames, execute it on a Hadoop data set in parallel on relatively small chunks of the data and pass the results to `as.data.frame` or `output` which send them to their final destination. Wouldn't it absolutely perfect if the `lastcol` function itself knew whether it's working on a Hadoop data set or a data frame and do the right thing? It actually is possible:


```r
magic.wand(last.col)
last.col(mtcars)
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


For people familiar with object oriented programming in R, this function takes an existing data frame function, meaning one with a data frame as its first argument and return value and creates a generic function by the same name, with a method for data frames equal to the original function and one for big data sets using do as shown above. The internal R dispatch machinery decides which of the methods to call based on the class of the first argument.

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
1        10
2        14
3        11
4         5
5        15
6        16
7         9
....
```


That's not what we wanted and that's the where the size of the data cannot be ignored or abstracted away. Think of data in Hadoop as always grouped, one way or another. It couldn't be otherwise: it is stored on multiple devices and, even if it weren't, we can only load it into memory in small chunks of it at a time. In this specific example, the data is small and to highlight this problem I created an input format that reads the data in unreasonably small chunks, but in Hadoop application this is the norm. So think of the data as always grouped, initially in arbitrary fashion and later in the way we determine using the functions `group`, `group.f` and `gather` and more. These were inspired by the notion of key in mapreduce, the SQL statement and the `dplyr` function with similar names. In this case, we computed partial sums for each of the arbitrary groups &mdash; here set to a very small size to make the point. Instead we want to group everything together so we can enter:


```r
input("/tmp/mtcars3", format = if3) %|%
	gather() %|%
	transmute(sum(carb), .mergeable = TRUE)
```

```
  sum.carb.
1        90
```





You may have noticed the contradiction between the above statement that data is always in chunks with the availability of a `gather` function. Luckily, there is an advanced way of grouping recursively, in a tree like fashion, that works with associative and commutative operations such as the sum, which is the default for `gather`. Anyway, it will all be more clear as we cover other grouping functions.

The `group` function takes an input and a number of arguments that are evaluated in the context of the data, exactly like `select`. The result is a Hadoop data set grouped by the columns defined in those arguments. After this step, all rows that are identical on the columns defined in the `group` call will be loaded into memory at once and processed in the same call. Here is an example. Let's say we want to calculate the average mileage for cars with the same number of cylinders:


```r
input("/tmp/mtcars") %|%
	group(cyl) %|%
	transmute(mean.mpg = mean(mpg))
```

```
  cyl mean.mpg
1   6    19.74
2   4    26.66
3   8    15.10
```


This is mostly a scalable programs, but there are some caveats: we need to be mindful of the size of the groups. If they are very big they will bust memory limits, so we need to reach for some advanced techniques to avoid this problem. If they are very small, like a handful of rows, we may run into some efficiency issues related to the current R and `rmr2` implementations rather than fundamental (so there is hope they will go away one day). 

When the definition of the grouping column is more complicated, we may need to reach for the uber-general `group.f`, the grouping relative of `do` (in fact, these two functions are the foundation for everything else in `plyrmr`). Let's go back to the `last.col` example. If we need to group by the last columns of a data frame, this is all we need to do:




## Better than SQL

Despite the SQL-ish flavor and undeniable SQL inspiration for some of these operations, we want to highlight a few ways in which `plyrmr` is much more powerful than SQL. The first is that summaries or aggregation don't need to be limited to a single row. One form of aggregation are summaries and summaries can have many elements, even thousands. Momenta, quantiles, histograms, samples, they all have multiple entries. You could represent them as multiple columns up to a certain size, but removing the SQL limitation on aggregations is a good thing. Here how it works. Let's say you want to examine the quantiles of the gas mileage data in each group of cars with the same number of carburetors


```r
input("/tmp/mtcars") %|%
	group(carb) %|%
	quantile.cols() 
```

```
   carb   mpg   cyl   disp     hp  drat    wt  qsec       vs     am  gear
1     4 10.86 6.000 161.20 112.05 3.012 2.844 15.20 0.000000 0.0000 3.000
2     4 13.92 6.195 185.39 131.01 3.271 3.326 16.25 0.000000 0.0000 3.002
3     4 15.25 8.000 350.50 210.00 3.815 3.505 17.22 0.000000 0.0000 3.500
4     4 18.19 8.000 392.87 234.85 3.908 4.408 17.85 0.000000 0.4219 3.998
5     4 20.72 8.000 460.48 250.75 4.011 5.354 18.43 0.842500 1.0000 4.302
6     1 21.18 4.000  78.21  65.93 3.151 1.968 18.96 1.000000 0.0000 3.000
7     1 22.09 4.000  91.94  78.05 3.652 2.205 19.36 1.000000 0.4450 3.445
....
```




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
1    4 c(22.693....
2    1 c(9.2859....
3    2 c(32.723....
4    3 c(16.3, ....
5    6 c(19.7, ....
6    8 c(15, NA....
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

