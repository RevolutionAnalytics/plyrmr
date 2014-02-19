









Plyrmr
====================================
author: Antonio Piccolboni for Revolution Analytics
autosize: true 
incremental: true

mtcars
====
title:false

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

transform
====
title:false

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


as.data.frame
===
title:false


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

mtcars-w-ratio
====
title:false

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

subset-transform
====
title:false

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




```r
x =	transform(mtcars, carb.per.cyl = carb/cyl) 
subset(x, carb.per.cyl >= 1)
```





```r
mtcars %|%
	transform(carb.per.cyl = carb/cyl) %|%
	subset(carb.per.cyl >= 1)
```


where-select
===
title:false


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


process.mtcars
====
title:false

```r
subset.mtcars.1 = function(...) subset(mtcars, ...)
high.carb.cyl.1 = function(x) {subset.mtcars.1(carb/cyl >= x) }
high.carb.cyl.1(1) 
```

```
Error: (list) object cannot be coerced to type 'double'
```



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

do
====
title:false

```r
last.col = function(x) x[, ncol(x), drop = FALSE]
```



```r
do(input("/tmp/mtcars"), last.col)
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

magic.wand
====
title:false

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

summarize
====
title:false

```r
summarize(mtcars, sum(carb))
```

```
  sum(carb)
1        90
```







```r
summarize(input("/tmp/mtcars3", format = if3), sum(carb))
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




```r
input("/tmp/mtcars3", format = if3) %|%
	gather() %|%
	summarize(sum(carb))
```

```
  sum.carb.
1        90
```




select-group
====
title:false

```r
input("/tmp/mtcars") %|%
	group(cyl) %|%
	select(mean.mpg = mean(mpg))
```

```
  cyl mean.mpg
1   6    19.74
2   4    26.66
3   8    15.10
```



```r
input("/tmp/mtcars") %|%
	group.f(last.col) %|%
	select(mean.mpg = mean(mpg)) 
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


group-quantile
====
title:false


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


group-lm
====
title:false


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

