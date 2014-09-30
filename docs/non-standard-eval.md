# Non-standard-evaluation
NOW OUTDATED!








The main goal of plyrmr if providing big-data close equivalents of well known and useful data frame manipulations, such as `transform` and `subset`. So why try to reinvent the wheel with `bind.cols`, `transmute` and `where`. The main reason is that those functions work best interactively, at the prompt, but they have some problems when used in other functions or packages. These limitations are inherited from the `base` package functions, not peculiar to their `plyrmr` brethren. `plyrmr` makes an attempt to provide two functions that match the convenience of `select` and `where` without their pitfalls. While we were at it, we also tried to make them more general and give them a cleaner but still familiar (SQL-inspired) interface. Let me introduce `select` and `where`. These are `plyrmr` functions with methods for data frames and Hadoop data sets and they are appropriate for interactive and programming use. The previous examples become, using these functions:
	

```r
where(
	bind.cols(
		mtcars, 
		carb.per.cyl = carb/cyl), 
	carb.per.cyl >= 1)
```

```
               mpg cyl disp  hp vs gear carb carb.per.cyl
Ferrari Dino  19.7   6  145 175  0    5    6            1
Maserati Bora 15.0   8  301 335  0    5    8            1
```

and:
	

```r
where(
	bind.cols(
		input("/tmp/mtcars"),
		carb.per.cyl = carb/cyl),
	carb.per.cyl >= 1)
```

```
               mpg cyl disp  hp vs gear carb carb.per.cyl
Ferrari Dino  19.7   6  145 175  0    5    6            1
Maserati Bora 15.0   8  301 335  0    5    8            1
```

Similar, but they work everywhere. For instance, if `where` is called within some function, which is in its turn used in some other function, we can have the following situation:
	

```r
subset.mtcars = function(...) subset(mtcars, ...)
high.carb.cyl = function(x) {subset.mtcars(carb/cyl >= x) }
high.carb.cyl.1(1) 
```

```
Error: could not find function "high.carb.cyl.1"
```

Unfortunately, it doesn't work. With `where` instead:


```r
where.mtcars = 
	function(...) where(mtcars, ...)
high.carb.cyl = function(x) {where.mtcars(carb/cyl >= x) }
high.carb.cyl(1)
```

```
               mpg cyl disp  hp vs gear carb
Ferrari Dino  19.7   6  145 175  0    5    6
Maserati Bora 15.0   8  301 335  0    5    8
```

The R documentation recommends to use `[]` only when programming, but having to rewrite code in a different context, to a computer scientist, is just an admission of defeat and negates one of the reasons R is so successful (many thanks to Hadley Wickham for valuable discussions on this subject, see also [this github issue](https://github.com/hadley/dplyr/issues/352)). Similar `dplyr` functions used to have the same problem as `base` function, but in the latest version they have fixed the evaluation behavior (so well in fact that we have switched to using their approach). For the relation between `plyrmr` and `dplyr` see [Plyrmr vs. dplyr](plyrmr_vs_dplyr.md).
