









Plyrmr
====================================
author: Antonio Piccolboni
autosize: true 
incremental: true

====

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

====

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



```r
transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl)
```

```
[1] "Got it! To generate results call the functions output or as.data.frame on this object. Computation has been delayed at least in part."
```



```r
as.data.frame(transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl))
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

====

```r
invisible(dfs.rmr("/tmp/mtcars.out"))
```

====

```r
output(transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl), "/tmp/mtcars.out")
```

```
[1] "Big Data object /tmp/mtcars.out" "Big Data object native"         
```

====

```r
mtcars.w.ratio = transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl)
as.data.frame(mtcars.w.ratio)
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

====

```r
subset(
	transform(
		mtcars, 
		carb.per.cyl = carb/cyl), 
	carb.per.cyl >= 1)
```

```
               mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
Ferrari Dino  19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```

====

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
               mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
Ferrari Dino  19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```

====

```r
where(
	select(
		mtcars, 
		carb.per.cyl = carb/cyl, 
		.replace = FALSE), 
	carb.per.cyl >= 1)
```

```
               mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
Ferrari Dino  19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```

====

```r
x = 
	where(
		select(
			input("/tmp/mtcars"), 
			carb.per.cyl = carb/cyl, 
			.replace = FALSE), 
		carb.per.cyl >= 1)
as.data.frame(x)
```

```
               mpg cyl disp  hp drat   wt qsec vs am gear carb carb.per.cyl
Ferrari Dino  19.7   6  145 175 3.62 2.77 15.5  0  1    5    6            1
Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8            1
```

====

```r
process.mtcars.1 = function(...) subset(mtcars, ...)
high.carb.cyl.1 = function(x) {process.mtcars.1(carb/cyl >= x) }
high.carb.cyl.1(1) 
```

```
Error: (list) object cannot be coerced to type 'double'
```

====

```r
process.mtcars.2 = function(...) where(mtcars, ..., .envir = parent.frame())
high.carb.cyl.2 = function(x) {process.mtcars.2(carb/cyl >= x) }
high.carb.cyl.2(1)
```

```
               mpg cyl disp  hp drat   wt qsec vs am gear carb
Ferrari Dino  19.7   6  145 175 3.62 2.77 15.5  0  1    5    6
Maserati Bora 15.0   8  301 335 3.54 3.57 14.6  0  1    5    8
```

====

```r
last.col = function(x) x[, ncol(x), drop = FALSE]
```

====

```r
as.data.frame(do(input("/tmp/mtcars"), last.col))
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

====

```r
magic.wand(last.col)
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
Mazda RX4              4
Mazda RX4 Wag          4
Datsun 710             1
Hornet 4 Drive         1
Hornet Sportabout      2
Valiant                1
Duster 360             4
....
```

====

```r
summarize(mtcars, sum(carb))
```

```
  sum(carb)
1        90
```

====

```r
as.data.frame(summarize(input("/tmp/mtcars"), sum(carb) ))
```

```
    sum.carb.
1          10
1.1        11
1.2        17
1.3        15
1.4        10
1.5        11
1.6        16
....
```

====


====

```r
as.data.frame(
	select(
		group(
			input("/tmp/mtcars"),
			cyl),
		mean.mpg = mean(mpg)))
```

```
    cyl mean.mpg
1     6    19.74
1.1   4    26.66
1.2   8    15.10
```

====

```r
as.data.frame(
	select(
		group.f(
			input("/tmp/mtcars"),
			last.col),
		mean.mpg = mean(mpg)))
```

```
    carb mean.mpg
1.2    2    22.40
1.3    3    16.30
1      4    15.79
1.1    1    25.34
1.4    6    19.70
1.5    8    15.00
```
