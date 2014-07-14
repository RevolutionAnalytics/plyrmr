







Plyrmr
====================================
author: Antonio Piccolboni
autosize: true
incremental: true

Revolution Analytics

mtcars
====
title:false

```r
mtcars
```

```
                     mpg cyl  disp  hp vs gear carb
Mazda RX4           21.0   6 160.0 110  0    4    4
Mazda RX4 Wag       21.0   6 160.0 110  0    4    4
Datsun 710          22.8   4 108.0  93  1    4    1
Hornet 4 Drive      21.4   6 258.0 110  1    3    1
Hornet Sportabout   18.7   8 360.0 175  0    3    2
Valiant             18.1   6 225.0 105  1    3    1
Duster 360          14.3   8 360.0 245  0    3    4
....
```
bind.cols
====
title:false

```r
bind.cols(mtcars, carb.per.cyl = carb/cyl)
```

```
                     mpg cyl  disp  hp vs gear carb carb.per.cyl
Mazda RX4           21.0   6 160.0 110  0    4    4       0.6667
Mazda RX4 Wag       21.0   6 160.0 110  0    4    4       0.6667
Datsun 710          22.8   4 108.0  93  1    4    1       0.2500
Hornet 4 Drive      21.4   6 258.0 110  1    3    1       0.1667
Hornet Sportabout   18.7   8 360.0 175  0    3    2       0.2500
Valiant             18.1   6 225.0 105  1    3    1       0.1667
Duster 360          14.3   8 360.0 245  0    3    4       0.5000
....
```

bind.cols-input
====
title:false


```r
bind.cols(input("/tmp/mtcars"), carb.per.cyl = carb/cyl)
```

```
                     mpg cyl  disp  hp vs gear carb carb.per.cyl
Mazda RX4           21.0   6 160.0 110  0    4    4       0.6667
Mazda RX4 Wag       21.0   6 160.0 110  0    4    4       0.6667
Datsun 710          22.8   4 108.0  93  1    4    1       0.2500
Hornet 4 Drive      21.4   6 258.0 110  1    3    1       0.1667
Hornet Sportabout   18.7   8 360.0 175  0    3    2       0.2500
Valiant             18.1   6 225.0 105  1    3    1       0.1667
Duster 360          14.3   8 360.0 245  0    3    4       0.5000
....
```

as.data.frame
===
title:false


```r
as.data.frame(bind.cols(input("/tmp/mtcars"), carb.per.cyl = carb/cyl))
```

```
                     mpg cyl  disp  hp vs gear carb carb.per.cyl
Mazda RX4           21.0   6 160.0 110  0    4    4       0.6667
Mazda RX4 Wag       21.0   6 160.0 110  0    4    4       0.6667
Datsun 710          22.8   4 108.0  93  1    4    1       0.2500
Hornet 4 Drive      21.4   6 258.0 110  1    3    1       0.1667
Hornet Sportabout   18.7   8 360.0 175  0    3    2       0.2500
Valiant             18.1   6 225.0 105  1    3    1       0.1667
Duster 360          14.3   8 360.0 245  0    3    4       0.5000
....
```



output
====
title:false


```r
output(
	bind.cols(
		input("/tmp/mtcars"), 
		carb.per.cyl = carb/cyl), 
	"/tmp/mtcars.out")
```

```
                     mpg cyl  disp  hp vs gear carb carb.per.cyl
Mazda RX4           21.0   6 160.0 110  0    4    4       0.6667
Mazda RX4 Wag       21.0   6 160.0 110  0    4    4       0.6667
Datsun 710          22.8   4 108.0  93  1    4    1       0.2500
Hornet 4 Drive      21.4   6 258.0 110  1    3    1       0.1667
Hornet Sportabout   18.7   8 360.0 175  0    3    2       0.2500
Valiant             18.1   6 225.0 105  1    3    1       0.1667
Duster 360          14.3   8 360.0 245  0    3    4       0.5000
....
```

predefined-ops
====
title:false

|package| functions|
|-------|-----|
|base| sample, union, intersect, rbind, unique, merge|
|plyr| mutate, transmute|
|reshape2| melt, dcast|
|plyrmr| bind.cols, transmute, select, where, count.cols, quantile.cols, top.k, bottom.k|

where-bind.cols
====
title:false

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

where-bind.cols-input
====
title:false


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

assignment-chain
====
title:false


```r
x =	bind.cols(mtcars, carb.per.cyl = carb/cyl) 
where(x, carb.per.cyl >= 1)
```


```r
mtcars %>%
	bind.cols(carb.per.cyl = carb/cyl) %>%
	where(carb.per.cyl >= 1)
```

gapply
====
title:false

```r
last.col = function(x) x[, ncol(x), drop = FALSE]
```


```r
gapply(input("/tmp/mtcars"), last.col)
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
magic.wand
====
title:false

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
Mazda RX4              4
Mazda RX4 Wag          4
Datsun 710             1
Hornet 4 Drive         1
Hornet Sportabout      2
Valiant                1
Duster 360             4
....
```
transmute
====
title:false

```r
mtcars %>% transmute(sum(carb))
```

```
  sum.carb.
1        90
```




transmute-input
====
title:false


```r
input("/tmp/mtcars3", format = if3) %>%
	transmute(sum(carb)) 
```

```
    sum.carb.
1          10
1.1        29
1.2        19
1.3        19
1.4        13
```



```r
input("/tmp/mtcars3", format = if3) %>%
	gather() %>%
	transmute(sum(carb), .mergeable = TRUE)
```

```
  sum.carb.
1        90
```




transmute-group
====
title:false

```r
input("/tmp/mtcars") %>%
	group(cyl) %>%
	transmute(mean.mpg = mean(mpg))
```

```
    cyl mean.mpg
1     6    19.74
1.1   4    26.66
1.2   8    15.10
```

transmute-group.f
====
title:false

```r
input("/tmp/mtcars") %>%
	group.f(last.col) %>%
	transmute(mean.mpg = mean(mpg)) 
```

```
    carb mean.mpg
1      4    15.79
1.1    1    25.34
1.2    2    22.40
1.3    3    16.30
1.4    6    19.70
1.5    8    15.00
```

group-quantile
====
title:false


```r
input("/tmp/mtcars") %>%
	group(carb) %>%
	quantile.cols() 
```

```
       carb   mpg cyl   disp    hp  vs gear
0%        4 10.40   6 160.00 110.0 0.0  3.0
25%       4 13.55   6 167.60 123.0 0.0  3.0
50%       4 15.25   8 350.50 210.0 0.0  3.5
75%       4 18.85   8 420.00 241.2 0.0  4.0
100%      4 21.00   8 472.00 264.0 1.0  5.0
0%.1      1 18.10   4  71.10  65.0 1.0  3.0
25%.1     1 21.45   4  78.85  66.0 1.0  3.0
....
```

group-lm
====
title:false


```r
models = 
	input("/tmp/mtcars") %>%
	group(carb) %>%
	transmute(model = list(lm(mpg~cyl+disp))) %>%
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
