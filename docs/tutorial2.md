








# Tutorial

## Predefined operations

Let's start with a simple operation such as adding a column to a data frame. The data set `mtcars` comes with R and describes the characteristics of a few car models:


```r
head(mtcars)
```

```
                   mpg cyl disp  hp drat    wt  qsec vs am gear carb
Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```


One may be interested in how many carburetors per cylinder each model uses, and that's a simple `transform` call away:


```r
transform(mtcars, carb.per.cyl = carb/cyl)
```

```
                     mpg cyl  disp  hp drat    wt  qsec vs am gear carb carb.per.cyl
Mazda RX4           21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4       0.6667
Mazda RX4 Wag       21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4       0.6667
Datsun 710          22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1       0.2500
Hornet 4 Drive      21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1       0.1667
Hornet Sportabout   18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2       0.2500
Valiant             18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1       0.1667
Duster 360          14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4       0.5000
....
```


Now let's imagine that we have a huge data set with the same structure but instead of being stored in memory, it is stored in a HDFS file named "/tmp/mtcars". It's way too big to be loaded with `read.table` or equivalent. With `plyrmr`, no sweat, one just needs to  enter:


```r
transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl)
```

```
[1] "Slots set: input, map \n Input: /tmp/mtcars,native \n"
```


Well, that doesn't look even remotely what we wanted, does it? That's because, when dealing with very large data sets, one needs to be careful not to try and load them in memory unless they have been filtered or summarized to a much smaller size. Therefore in `plyrmr` the general rule is that loading into memory happens only when the user decides so. In this case, we know the data set is small so we can just go ahead with this operation  and enter:


```r
as.data.frame(transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl))
```

```
                     mpg cyl  disp  hp drat    wt  qsec vs am gear carb carb.per.cyl
Mazda.RX4           21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4       0.6667
Mazda.RX4.Wag       21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4       0.6667
Datsun.710          22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1       0.2500
Hornet.4.Drive      21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1       0.1667
Hornet.Sportabout   18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2       0.2500
Valiant             18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1       0.1667
Duster.360          14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4       0.5000
....
```


In fact the `as.data.frame` call not only loads the data into memory, but triggers the computation as well. `plyrmr` uses a technique called *delayed evaluation* to create the opportunity for some optimizations. In general the user need not worry about the details of this, as long as it is clear that the actual computational work may be shifted w.r.t an equivalent computation in memory. If we want to trigger the computation without loading the data in memory but storing it into a file, we need the `output` call, as in:





```r
output(transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl), "/tmp/mtcars.out")
```

```
[1] "/tmp/mtcars.out" "native"         
```


This is the real deal: we have performed a computation on the cluster, in parallel, and the data id never loaded in memory at once, but the syntax and semantics remain the familiar ones. The last run processed all of 32 rows, but on a large enough cluster it could run on 32 terabytes &mdash; don't even think of using `as.data.frame` in that case.
The return value of `output` contains the path and some format information. In general an effort is made throughout `plyrmr` to make return values of functions as useful as possible so as to be able to combine simple expressions into larger ones. Of course you can also store intermediate results to a variable as in:


```r
mtcars.w.ratio = transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl)
as.data.frame(mtcars.w.ratio)
```

```
                     mpg cyl  disp  hp drat    wt  qsec vs am gear carb carb.per.cyl
Mazda.RX4           21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4       0.6667
Mazda.RX4.Wag       21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4       0.6667
Datsun.710          22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1       0.2500
Hornet.4.Drive      21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1       0.1667
Hornet.Sportabout   18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2       0.2500
Valiant             18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1       0.1667
Duster.360          14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4       0.5000
....
```


`transform` is a basic operation on data frames and it is the prototype of a handful of other useful operations:

 * from `base`:
   * `transform`: add new columns
   * `subset`: select columns and rows
 * from `plyr`:
   * `mutate`: similar to `transform`
   * `summarize`: create summaries
 * from `reshape2`:
   * `melt` and `dcast`: convert between *long* and *wide* data frames
 * new in `plyr`:
   * `select`: does everything that `transform` and `summarize` in addition to selecting columns.
   * `where`: select rows
   * these are more suitable for programming then the functions they replace, as will be explained later.
 
`plyrmr` extends all these operations to Hadoop stored data sets trying to maintain semantic equivalence, with limitations that will be made clear later. These functions are not intended as a minimal set of operations: there is a lot of functionality overlap. We just wanted to support existing usage to help transitioning to Hadoop data sets.
 
## Combining Operations

What if none of the basic operations is sufficient to perform a needed data processing step? The first available tool is to combine different operations. Going back to the previous example, let's say we want to select cars with a carburetor per cylinder ratio greater than 1. Do such things even exist? On a data frame, there is a quick way to compute the answer, which is


```r
subset(transform(mtcars, carb.per.cyl = carb/cyl), carb.per.cyl >= 1)
```

```
               mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
Ferrari Dino  19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


Wouldn't it be nice if we could do exactly the same on a Hadoop data set? In fact, we almost can


```r
as.data.frame(
	subset(
		transform(
			input("/tmp/mtcars"), 
			carb.per.cyl = carb/cyl), 
		carb.per.cyl >= 1))
```

```
               mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
Ferrari.Dino  19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
Maserati.Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


Or if deeply nested expressions are not your style:


```r
input.mtcars = input("/tmp/mtcars")
mtcars.w.ratio = transform(input.mtcars, carb.per.cyl = carb/cyl)
mtcars.ratio.gt.1 = subset(mtcars.w.ratio, carb.per.cyl >= 1)
as.data.frame(mtcars.ratio.gt.1)
```

```
               mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
Ferrari.Dino  19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
Maserati.Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


The main differences between the data frame version and the Hadoop data version are the input and the output. All there is in between, pretty much works the same. By the way, `subset` and `transform` work best interactively, at the prompt, but they have some problems when used in other functions or packages. These limitations are inherited from the `base` package functions, not peculiar to their `plyrmr` brethren. `plyrmr` makes an attempt to provide two primitives that match the convenience of `transform` and `subset` without their pitfalls. While we were at it, we also tried to make them more general and give them a cleaner but still familiar (SQL-inspired) interface. Let me introduce `select` and `where`. These are `plyrmr` functions with methods for data frames and Hadoop data sets and they are appropriate for interactive and programming use. The previous examples become, using these functions:


```r
where(select(mtcars, carb.per.cyl = carb/cyl, .replace = FALSE), carb.per.cyl >= 1)
```

```
               mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
Ferrari Dino  19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


and:


```r
as.data.frame(
	where(
		select(
			input("/tmp/mtcars"), 
			carb.per.cyl = carb/cyl,
			.replace = FALSE), 
		carb.per.cyl >= 1))
```

```
               mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
Ferrari.Dino  19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
Maserati.Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


Similar, but they work everywhere. For instance, if we wanted to define a function to reuse what we've just done, we could write:


```r
find.bad.ass.cars = function(data, threshold) subset(transform(data, carb.per.cyl = carb/cyl), carb.per.cyl >= threshold)
find.bad.ass.cars(1)
```

```
Error: object 'carb' not found
```

```r
find.bad.ass.cars.plyrmr = function(data, threshold) where(select(data, carb.per.cyl = carb/cyl, .replace=F), carb.per.cyl >= threshold)
find.bad.ass.cars.plyrmr(mtcars, 1)
```

```
               mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
Ferrari Dino  19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```


As you can see there is an argument for using `plyrmr` even when just dealing with data frames, if you want to transition nicely from interactive R use to development. The R documentation recommends to use `[]` only when programming, but having to rewrite code in a different context, to a computer scientist, is just an admission of defeat. Therefore `plyrmr` provides methods for `transform`, `subset`, `mutate` and `summarize` because of their widespread use, but we would like to see people transition to `where` and `select` eventually,

## Custom operations
Another way to extend the functionality of `plyrmr` built-in data manipulation functions is to take any function that accepts a data frame in input and returns a data frame and use the function `do` to give it Hadoop superpowers (`do` is named after the equivalent primitive in `dplyr`). For instance, you have a function that returns the rightmost column of a data frame. This is not simple to achieve with the functions explored so far, but it is a quick one liner:


```r
last.col = function(x) x[, ncol(x), drop = FALSE]
```


Wouldn't it be great if we could run this on a Hadoop data set? Well, we almost can:


```r
as.data.frame(do(input("/tmp/mtcars"), last.col))
```

```
                    carb
Mazda.RX4              4
Mazda.RX4.Wag          4
Datsun.710             1
Hornet.4.Drive         1
Hornet.Sportabout      2
Valiant                1
Duster.360             4
....
```


What `do` does is to take any function that reads and writes data frames, execute it on a Hadoop data set in parallel on relatively small chunks of the data and pass the results to `as.data.frame` or `output` which send them to their final destination. Wouldn't it absolutely perfect if the `lastcol` function itself knew whether it's working on a Hadoop data set or a data frame and do the right thing?


```r
magic.wand(last.col)
```

```
Warning: Renamed the preexisting function last.col to last.col.default, which was defined in environment base.
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
as.data.frame(last.col(input("/tmp/mtcars")))
```

```
                    carb
Mazda.RX4              4
Mazda.RX4.Wag          4
Datsun.710             1
Hornet.4.Drive         1
Hornet.Sportabout      2
Valiant                1
Duster.360             4
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


But if we did that on a Hadoop data set, we would get:


```r
as.data.frame(summarize(input("/tmp/mtcars"), sum(carb) ))
```

```
     sum.carb.
X1          10
X1.1        11
X1.2        17
X1.3        15
X1.4        10
X1.5        11
X1.6        16
....
```


What does that mean? The data in Hadoop is always grouped, one way or another (this is also a key difference with the current `dplyr` design). It couldn't be otherwise: it is stored on multiple devices and, even if it weren't, we can only load it in memory in small chunks. So think of it as always grouped, initially in arbitrary fashion, that we can change with the functions `group.by`, `group.by.f` and `group.together`. These were inspired by the notion of key in mapreduce, the SQL statement and the `dplyr` function with similar names. In this case, we computed partial sums for each of the arbitrary groups &mdash; here set to a very small size to make the point. Instead we want to group everything together so we can enter:


```r
as.data.frame(summarize(group.together(input("/tmp/mtcars")), sum(carb) ))
```

```
   sum.carb.
X1        90
```


You may have noticed the contradiction between the above statement that data is always in chunks with the availability of a `group.together` function. First there may be cases when the data set is immediately summarized a filtered in an intial phase to the extent that grouping everything together is possible, albeit we could also complete the comuputation in memory in the master R instance in this case. Second, there is an advanced way of grouping recursively, in a tree like fashion, that works with associative and commutative operations such as the sum, which is the default for `group.together`. Anyway, it will all be more clear as we cover other grouping functions.

The `group.by` function takes an input and a number of arguments that are evaluated in the context of the data, exactly like `transform` and `mutate`. The result is a Hadoop data set grouped by the columns defined in those arguments. After this step, all rows that are identical on the columns defined in the `group.by` will be loaded in memory at once and processed in the same call. Here is an example.

Let's say we want to calculate the average milage for cars with the same number of cylinders:


```r
as.data.frame(
	select(
		group.by(
			input("/tmp/mtcars"),
			cyl),
		cyl = unique(cyl),
		mean.mpg = mean(mpg)))
```

```
     cyl mean.mpg
X1     6    19.74
X1.1   4    26.66
X1.2   8    15.10
```


And there you have your scalable Hadoop code to compute group averages. There are some caveats though: we need to be mindful of the size of the groups. If they are very big they will bust memory limits, so we need to reach for some advanced techniques to avoid this problem. If they are very small, like a handful of rows, we may run into some efficiency issues releated to the current R and rmr2 implementations rather than fundamental (so there is hope they will go away one day). 

When the definition of the grouping column is more complicated, we may need to reach for the uber-general `group.by.f` the grouping alter-ego to `do` (in fact, these two are the foundation for everything else in `plyrmr`). Let's go back to the `last.col` example. If we need to group by the last columns of a data frame, this is all we need to do:


```r
as.data.frame(
	select(
		group.by.f(
			input("/tmp/mtcars"),
			last.col),
		unique(carb),
		mean.mpg = mean(mpg)))
```

```
     unique.carb. mean.mpg
X1              4    15.79
X1.1            1    25.34
X1.2            2    22.40
X1.3            3    16.30
X1.4            6    19.70
X1.5            8    15.00
```


This assumes that we know `carb` is the last column, which defeats the purpose of the exercise.  So let's take an additional and final step:



```r
as.data.frame(
	do(
		group.by.f(
			input("/tmp/mtcars"),
			last.col),
		function(x)
			data.frame(
				last.col = unique(last.col(x)),
				mean.mpg = mean(x$mpg),
				row.names = NULL)))
```

```
     carb mean.mpg
X1      4    15.79
X1.1    1    25.34
X1.2    2    22.40
X1.3    3    16.30
X1.4    6    19.70
X1.5    8    15.00
```


