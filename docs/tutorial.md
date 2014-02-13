








# Tutorial

## Predefined operations

Let's start with a simple operation such as adding a column to a data frame. The data set `mtcars` comes with R and describes the characteristics of a few car models:


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


One may be interested in how many carburetors per cylinder each model uses, and that's a simple `transform` call away:


```r
transform(mtcars, carb.per.cyl = carb/cyl)
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


Now let's imagine that we have a huge data set with the same structure but instead of being stored in memory, it is stored in a HDFS file named "/tmp/mtcars". It's way too big to be loaded with `read.table` or equivalent. With `plyrmr` one just needs to  enter:


```r
transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl)
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


Well, that doesn't look like what we wanted, does it? That's because, when dealing with very large data sets, one needs to be careful not to try and load them into memory unless they have been filtered or summarized to a much smaller size. Therefore in `plyrmr` the general rule is that loading into memory happens only when the user decides so. In this case, we know the data set is small so we can just go ahead with this operation  and enter:


```r
as.data.frame(transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl))
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


In fact the `as.data.frame` call not only loads the data into memory, but triggers the computation as well. `plyrmr` uses a technique called *delayed evaluation* to create the opportunity for some optimizations. In general the user need not worry about the details of this, as long as it is clear that the actual computational work may be shifted w.r.t. an equivalent computation in memory. If we want to trigger the computation without loading the data into memory but storing it into a file, we need the `output` call, as in:





```r
output(transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl), "/tmp/mtcars.out")
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


This is the real deal: we have performed a computation on the cluster, in parallel, and the data is never loaded into memory at once, but the syntax and semantics remain the familiar ones. The last run processed all of 32 rows, but on a large enough cluster it could run on 32 terabytes &mdash; don't even think of using `as.data.frame` in that case.
The return value of `output` contains the path and some format information. In general an effort is made throughout `plyrmr` to make return values of functions as useful as possible so as to be able to combine simple expressions into larger ones. You can also store intermediate results to a variable as in:


```r
mtcars.w.ratio = transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl)
as.data.frame(mtcars.w.ratio)
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


`transform` is one of several functions that `plyrmr` provides in a Hadoop-powered version:

 * from `base`:
   * `transform`: add new columns
   * `subset`: select columns and rows
 * from `plyr`:
   * `mutate`: similar to `transform`
   * `summarize`: create summaries
 * from `reshape2`:
   * `melt` and `dcast`: convert between *long* and *wide* data frames
 * new in `plyr`:
   * `select`: does everything that `transform` and `summarize` do in addition to selecting columns.
   * `where`: select rows
   * these are more suitable for programming then the functions they replace, as will be explained later.
 
`plyrmr` extends all these operations to Hadoop data sets, trying to maintain semantic equivalence, with limitations that will be made clear later. These functions are not intended as a minimal set of operations: there is a lot of functionality overlap. We just wanted to support existing usage to help users transitioning to Hadoop programming.
 
## Combining Operations

What if none of the basic operations is sufficient to perform a needed data processing step? The first available tool is to combine different operations. Going back to the previous example, let's say we want to select cars with a carburetor per cylinder ratio greater than 1. Do such things even exist? On a data frame, there is a quick way to compute the answer, which is


```r
subset(
	transform(
		mtcars, 
		carb.per.cyl = carb/cyl), 
	carb.per.cyl >= 1)
```

```
           model  mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
30  Ferrari Dino 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
31 Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


Wouldn't it be nice if we could do exactly the same on a Hadoop data set? In fact, we almost can:


```r
x =
	subset(
		transform(
			input("/tmp/mtcars"),
			carb.per.cyl = carb/cyl),
		carb.per.cyl >= 1)
as.data.frame(x)
```

```
          model  mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
1  Ferrari Dino 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
2 Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


The main differences between the data frame version and the Hadoop data version are the input and the output. All there is in between, pretty much works the same. 

## The pipe operator

You may have noticed that the last example consists of a fairly complex expression, with function calls nested inside other function calls multiple times. The drawbacks of that are twofold. First, the order in which functions appear in the code, top to bottom, is the opposite of the order in which things happen. Second, additional arguments to each function can be very far from the name of the function. This problem can be mitigated with proper indentation, but it still is a problem. One workaround is to rewrite complex expressions as chains of assignments:


```r
x =	transform(mtcars, carb.per.cyl = carb/cyl) 
subset(x, carb.per.cyl >= 1)
```

```
           model  mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
30  Ferrari Dino 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
31 Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


The purists will find that introducing one variable for each intermediate step quite unsightly. To avoid this plyrmr offers a unix-style pipe operator, inspired by two precedents, by [@crowding](https://github.com/crowding/vadr/blob/master/R/chain.R) and [@hadley](https://github.com/hadley/dplyr/blob/master/R/chain.r).


```r
mtcars %|%
	transform(carb.per.cyl = carb/cyl) %|%
	subset(carb.per.cyl >= 1)
```

```
           model  mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
30  Ferrari Dino 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
31 Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


What this does is providing the value of the leftmost expression as the first unnamed argument of the next function call, evaluate this combination and continue to the next operator. Rather than arguing over which style is best, it's probably best to bask in the flexibility made possible by the R language and your indefatigable developers and pick the one that's best case-by-case. In particular, pipes can not express more complex data flows where two flows merge or one splits. In the following I will alternate between these three notations (nested, assignment chaing and pipe operator) based on which seems the clearest. It should be safe to assume that each example can be translated into any of the three.


## Why you should use `plyrmr`'s `select` and `where`
`subset` and `transform` work best interactively, at the prompt, but they have some problems when used in other functions or packages. These limitations are inherited from the `base` package functions, not peculiar to their `plyrmr` brethren. `plyrmr` makes an attempt to provide two functions that match the convenience of `transform` and `subset` without their pitfalls. While we were at it, we also tried to make them more general and give them a cleaner but still familiar (SQL-inspired) interface. Let me introduce `select` and `where`. These are `plyrmr` functions with methods for data frames and Hadoop data sets and they are appropriate for interactive and programming use. The previous examples become, using these functions:


```r
mtcars %|%
	select(carb.per.cyl = carb/cyl, .replace = FALSE) %|%
	where(carb.per.cyl >= 1)
```

```
            model  mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
X30  Ferrari Dino 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
X31 Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


and:


```r
x = 
	input("/tmp/mtcars") %|%
	select(carb.per.cyl = carb/cyl, .replace = FALSE) %|%
	where(carb.per.cyl >= 1)
as.data.frame(x)
```

```
          model  mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
1  Ferrari Dino 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
2 Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


Similar, but they work everywhere. For instance, if `subset` is called within some function, which is in its turn used in some other function, we can have the following situation:


```r
subset.mtcars.1 = function(...) subset(mtcars, ...)
high.carb.cyl.1 = function(x) {subset.mtcars.1(carb/cyl >= x) }
high.carb.cyl.1(1) 
```

```
Error: (list) object cannot be coerced to type 'double'
```


Unfortunately, it doesn't work. With `where` instead:


```r
subset.mtcars.2 = function(...) where(mtcars, ..., .envir = parent.frame())
high.carb.cyl.2 = function(x) {subset.mtcars.2(carb/cyl >= x) }
high.carb.cyl.2(1)
```

```
           model  mpg cyl disp  hp drat   wt qsec vs am gear carb
30  Ferrari Dino 19.7   6  145 175 3.62 2.77 15.5  0  1    5    6
31 Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8
```


The exact reason why `where` needs an additional argument in this scenario and what to provide are out of scope for this tutorial, but the message is that with `where` and `select` you can transition nicely from interactive R use to development. The R documentation recommends to use `[]` only when programming, but having to rewrite code in a different context, to a computer scientist, is just an admission of defeat. Therefore `plyrmr` provides methods for `transform`, `subset`, `mutate` and `summarize` because of their widespread use, but we recommend to check out `where` and `select` (many thanks to Hadley Wickham for valuable discussions on this issue).

## Custom operations
Another way to extend the functionality of `plyrmr` built-in data manipulation functions is to take any function that accepts a data frame in input and returns a data frame and use the function `do` to give it Hadoop superpowers (`do` is named after the equivalent function in `dplyr`, but the idea is not new). For instance, you have a function that returns the rightmost column of a data frame. This is not simple to achieve with the functions explored so far, but it is a quick one liner:


```r
last.col = function(x) x[, ncol(x), drop = FALSE]
```


Wouldn't it be great if we could run this on a Hadoop data set? Well, we almost can:


```r
as.data.frame(do(input("/tmp/mtcars"), last.col))
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
as.data.frame(last.col(input("/tmp/mtcars")))
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



## Grouping

Until now we performed row by row operations, whereby each row in the results depends on a single row in the input. In this case we don't care if the data is grouped in one way or another. In most other cases, this distinction is important. For instance, if we wanted to compute the total number of carburetors, we could enter:


```r
summarize(mtcars, sum(carb))
```

```
  sum(carb)
1        90
```


What happens if we do this on a Hadoop data set?


```
Error: Please make sure that the env. variable HADOOP_CMD is set
```



```r
as.data.frame(summarize(input("/tmp/mtcars3", format = if3), sum(carb) ))
```

```
Error: Please make sure that the env. variable HADOOP_CMD is set
```

```
Error: Please make sure that the env. variable HADOOP_STREAMING is set
```

```
Error: Please make sure that the env. variable HADOOP_CMD is set
```


Bingo, the same, but there's a catch. Unfortunately this example is misleading because it's based on a small data set that fits into main memory. In general, the data in Hadoop is always grouped, one way or another. It couldn't be otherwise: it is stored on multiple devices and, even if it weren't, we can only load it into memory in small chunks. In this specific example, there is only one chunk, but in general there would be multiple chunksSo think of it as always grouped, initially in arbitrary fashion and later in the way we determine using the functions `group`, `group.f` and `gather`. These were inspired by the notion of key in mapreduce, the SQL statement and the `dplyr` function with similar names. In this case, we computed partial sums for each of the arbitrary groups &mdash; here set to a very small size to make the point. Instead we want to group everything together so we can enter:


```r
input("/tmp/mtcars3", format = if3) %|%
	gather() %|%
	summarize(carb = sum(carb)) %|%
	as.data.frame()
```

```
Error: Please make sure that the env. variable HADOOP_CMD is set
```

```
Error: Please make sure that the env. variable HADOOP_STREAMING is set
```

```
Error: Please make sure that the env. variable HADOOP_CMD is set
```





You may have noticed the contradiction between the above statement that data is always in chunks with the availability of a `gather` function. Luckily, there is an advanced way of grouping recursively, in a tree like fashion, that works with associative and commutative operations such as the sum, which is the default for `gather`. Anyway, it will all be more clear as we cover other grouping functions.

The `group` function takes an input and a number of arguments that are evaluated in the context of the data, exactly like `transform` and `mutate`. The result is a Hadoop data set grouped by the columns defined in those arguments. After this step, all rows that are identical on the columns defined in the `group` call will be loaded into memory at once and processed in the same call. Here is an example. Let's say we want to calculate the average milage for cars with the same number of cylinders:


```r
input("/tmp/mtcars") %|%
	group(cyl) %|%
	select(mean.mpg = mean(mpg)) %|%
	as.data.frame()
```

```
  cyl mean.mpg
1   6    19.74
2   4    26.66
3   8    15.10
```


This is mostly a scalable programs, but there are some caveats: we need to be mindful of the size of the groups. If they are very big they will bust memory limits, so we need to reach for some advanced techniques to avoid this problem. If they are very small, like a handful of rows, we may run into some efficiency issues releated to the current R and `rmr2` implementations rather than fundamental (so there is hope they will go away one day). 

When the definition of the grouping column is more complicated, we may need to reach for the uber-general `group.f`, the grouping relative of `do` (in fact, these two functions are the foundation for everything else in `plyrmr`). Let's go back to the `last.col` example. If we need to group by the last columns of a data frame, this is all we need to do:


```r
input("/tmp/mtcars") %|%
	group.f(last.col) %|%
	select(mean.mpg = mean(mpg)) %|%
	as.data.frame()
```

```
  carb mean.mpg
1    4    15.79
2    1    25.34
3    2    22.40
4    3    16.30
5    6    19.70
6    8    15.00
```


## Better than SQL

Despite the SQL-ish flavor and undeniable SQL inspiration for some of these operations, we want to highlight a few ways in which `plyrmr` is much more powerful than SQL. The first is that summaries or aggregation don't need to be limited to a single row. One form of aggregation are summaries and summaries can have many elements, even thousands. Momenta, quantiles, histograms, samples, they all have multiple entries. You could represent them as multiple columns up to a certain size, but removing the SQL limitation on aggregations is a good thing. Here how it works. Let's say you want to examine the quantiles of the gas milage data in each group of cars with the same number of carburetors


```r
input("/tmp/mtcars") %|%
	group(carb) %|%
	quantile.cols() %|%
	as.data.frame()
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
	select(model = list(lm(mpg~cyl+disp))) %|%
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

