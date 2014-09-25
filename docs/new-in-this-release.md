# What's new in `plyrmr` 0.5.0



## Features

### New functions for big data sets: nrow, ncol, dim

They do what you expect them to do, but were a glaring omission among common data frame functions.

### New function VAR helps using plyrmr inside other functions

It is convenient to type `bind.cols(mtcars, cyl/2)`, but what do you do when you want to have the data and the column to be parametrized with variables? Typically, you are writing a function 


```r
half.some.column = function(data, col) bind.cols(data, col/2)
```

Nope, doesn't do what one expects.


```r
half.some.column(mtcars, cyl)
```

```
## Error: object 'cyl' not found
```

```r
half.some.column(mtcars, "cyl")
```

```
## Error: non-numeric argument to binary operator
```

```r
half.some.column(mtcars, as.name("cyl"))
```

```
## Error: non-numeric argument to binary operator
```

Nada, nope, rien. Try `VAR`


```r
half.some.column = function(data, col) bind.cols(data, VAR(col)/2)
head(half.some.column(mtcars, "cyl"))
```

```
##                    mpg cyl disp  hp drat    wt  qsec vs am gear carb
## Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
## Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
## Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
## Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
## Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
## Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
##                   col.divided.by.2
## Mazda RX4                        3
## Mazda RX4 Wag                    3
## Datsun 710                       2
## Hornet 4 Drive                   3
## Hornet Sportabout                4
## Valiant                          3
```

Finally! And it works also with column numbers


```r
head(bind.cols(mtcars, z = VAR(1)/2))
```

```
##                    mpg cyl disp  hp drat    wt  qsec vs am gear carb     z
## Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4 10.50
## Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4 10.50
## Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1 11.40
## Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1 10.70
## Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2  9.35
## Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1  9.05
```
### Memoization of hadoop execution helps avoiding useless recomputation

When dealing with big data, wasteful recomputation should not be taken lightly. `plyrmr` now does that on your behalf.




```r
ncol(input("/tmp/mtcars"))
```

```
## [1] 11
```
This does actual work,


```r
ncol(input("/tmp/mtcars"))
```

```
## [1] 11
```
This one doesn't. It's that easy.


```
## NULL
```


### Higher order function for creating data frame functions

Just a little convenience for when you'd like to apply the same vector function to each column of a data frame. 


```r
log.data.frame = each.column(log)
head(log.data.frame(mtcars))
```

```
##     mpg   cyl  disp    hp  drat     wt  qsec   vs   am  gear   carb
## 1 3.045 1.792 5.075 4.700 1.361 0.9632 2.801 -Inf    0 1.386 1.3863
## 2 3.045 1.792 5.075 4.700 1.361 1.0561 2.834 -Inf    0 1.386 1.3863
## 3 3.127 1.386 4.682 4.533 1.348 0.8416 2.924    0    0 1.386 0.0000
## 4 3.063 1.792 5.553 4.700 1.125 1.1678 2.967    0 -Inf 1.099 0.0000
## 5 2.929 2.079 5.886 5.165 1.147 1.2355 2.834 -Inf -Inf 1.099 0.6931
## 6 2.896 1.792 5.416 4.654 1.015 1.2413 3.007    0 -Inf 1.099 0.0000
```

### Dropped support for base functions transform and subset 

As part of a major clean-up of how non-standard evaluation is handled (a.k.a ... expression arguments), they are gone. They were in an  extension pack anyway and they required lots of complex code to deal with their own way of dealing with non standard eval arguments. There are plenty of alternatives anyway.


## Bugs



