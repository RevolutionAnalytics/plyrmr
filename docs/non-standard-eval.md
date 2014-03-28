








The main goal of plyrmr if providing big-data close equivalents of well known and useful data frame manipulations. So why try to reinvent the wheel with `bind.cols`, `transmute` and `where`. The main reason is that those functions work best interactively, at the prompt, but they have some problems when used in other functions or packages. These limitations are inherited from the `base` package functions, not peculiar to their `plyrmr` brethren. `plyrmr` makes an attempt to provide two functions that match the convenience of `select` and `where` without their pitfalls. While we were at it, we also tried to make them more general and give them a cleaner but still familiar (SQL-inspired) interface. Let me introduce `select` and `where`. These are `plyrmr` functions with methods for data frames and Hadoop data sets and they are appropriate for interactive and programming use. The previous examples become, using these functions:
	

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


The exact reason why `where` needs an additional argument in this scenario and what to provide are out of scope for this tutorial, but the message is that with `where` and `select` you can transition nicely from interactive R use to development. The R documentation recommends to use `[]` only when programming, but having to rewrite code in a different context, to a computer scientist, is just an admission of defeat and negates one of the reasons R is so successful (many thanks to Hadley Wickham for valuable discussions on this subject, see also [this github issue](https://github.com/hadley/dplyr/issues/352)).

For `select` though we managed to overcome the non-standard evaluation problem, so this motivation is somewhat historical
