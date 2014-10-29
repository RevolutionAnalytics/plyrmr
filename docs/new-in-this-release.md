# What's new in `plyrmr` 0.5.0





## Features

### New functions for big data sets: nrow, ncol, dim



They do what you expect them to do, but were a glaring omission among common data frame functions. `nrow` and `dim` return big data objects because they act on each group when the `group` function is used. For instance:


```r
mtcars.in %|% nrow
```

```
  nrow
1   32
```

```r
mtcars.in %|% group(cyl) %|% nrow
```

```
    cyl nrow
1     4   11
1.1   6    7
1.2   8   14
```

Notwithstanding the size of this example, you see the possibility for `nrow` to produce billions of rows, therefore an implcit conversion to `data.frame` would reduce its usefulness. Just pipe it through `as.data.frame` if that's what you want.

### New function VAR helps using plyrmr inside other functions

It is convenient to type `bind.cols(mtcars, cyl/2)`, but what do you do when you want to parametrize the data and the column? Typically, you are writing a function 


```r
halve.some.column = function(data, col) bind.cols(data, col/2)
```

Should work right?


```r
halve.some.column(mtcars, cyl)
```

```
Error: object 'cyl' not found
```

```r
halve.some.column(mtcars, "cyl")
```

```
Error: non-numeric argument to binary operator
```

```r
halve.some.column(mtcars, as.name("cyl"))
```

```
Error: non-numeric argument to binary operator
```

Nada, nope, rien. Try `VAR`.


```r
halve.some.column = 
	function(data, col) bind.cols(data, VAR(col)/2)
head(halve.some.column(mtcars, "cyl"))
```

```
                   mpg cyl disp  hp drat    wt  qsec vs am gear carb col.divided.by.2
Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4                3
Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4                3
Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1                2
Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1                3
Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2                4
Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1                3
```

Finally! And it works also with column numbers


```r
mtcars.in %|% bind.cols(z = VAR(1)/2) 
```

```
                     mpg cyl  disp  hp drat    wt  qsec vs am gear carb     z
Mazda RX4           21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4 10.50
Mazda RX4 Wag       21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4 10.50
Datsun 710          22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1 11.40
Hornet 4 Drive      21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1 10.70
Hornet Sportabout   18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2  9.35
Valiant             18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1  9.05
Duster 360          14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4  7.15
Merc 240D           24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2 12.20
Merc 230            22.8   4 140.8  95 3.92 3.150 22.90  1  0    4    2 11.40
Merc 280            19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4  9.60
Merc 280C           17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4  8.90
Merc 450SE          16.4   8 275.8 180 3.07 4.070 17.40  0  0    3    3  8.20
Merc 450SL          17.3   8 275.8 180 3.07 3.730 17.60  0  0    3    3  8.65
Merc 450SLC         15.2   8 275.8 180 3.07 3.780 18.00  0  0    3    3  7.60
Cadillac Fleetwood  10.4   8 472.0 205 2.93 5.250 17.98  0  0    3    4  5.20
Lincoln Continental 10.4   8 460.0 215 3.00 5.424 17.82  0  0    3    4  5.20
Chrysler Imperial   14.7   8 440.0 230 3.23 5.345 17.42  0  0    3    4  7.35
Fiat 128            32.4   4  78.7  66 4.08 2.200 19.47  1  1    4    1 16.20
Honda Civic         30.4   4  75.7  52 4.93 1.615 18.52  1  1    4    2 15.20
Toyota Corolla      33.9   4  71.1  65 4.22 1.835 19.90  1  1    4    1 16.95
Toyota Corona       21.5   4 120.1  97 3.70 2.465 20.01  1  0    3    1 10.75
Dodge Challenger    15.5   8 318.0 150 2.76 3.520 16.87  0  0    3    2  7.75
AMC Javelin         15.2   8 304.0 150 3.15 3.435 17.30  0  0    3    2  7.60
Camaro Z28          13.3   8 350.0 245 3.73 3.840 15.41  0  0    3    4  6.65
Pontiac Firebird    19.2   8 400.0 175 3.08 3.845 17.05  0  0    3    2  9.60
Fiat X1-9           27.3   4  79.0  66 4.08 1.935 18.90  1  1    4    1 13.65
Porsche 914-2       26.0   4 120.3  91 4.43 2.140 16.70  0  1    5    2 13.00
Lotus Europa        30.4   4  95.1 113 3.77 1.513 16.90  1  1    5    2 15.20
Ford Pantera L      15.8   8 351.0 264 4.22 3.170 14.50  0  1    5    4  7.90
Ferrari Dino        19.7   6 145.0 175 3.62 2.770 15.50  0  1    5    6  9.85
Maserati Bora       15.0   8 301.0 335 3.54 3.570 14.60  0  1    5    8  7.50
Volvo 142E          21.4   4 121.0 109 4.11 2.780 18.60  1  1    4    2 10.70
```

### Automagically avoid useless recomputation

When dealing with big data, wasteful recomputation should not be taken lightly. `plyrmr` now does that on your behalf.



```r
mtcars.in %|% ncol
```

```
[1] 11
```

This does actual work,


```r
mtcars.in %|% ncol
```

```
[1] 11
```

This one doesn't. It's that easy.

### Better naming for columns in count output

For example:


```r
mtcars.in %|% count(carb:cyl, carb:gear)
```

```
   carb_cyl.carb carb_cyl.cyl carb_cyl.freq carb_gear.carb carb_gear.gear carb_gear.freq
1              2            4             6              4              3              5
2              4            8             6              1              4              4
3              1            4             5              2              3              4
4              2            8             4              2              4              4
5              4            6             4              4              4              4
6              3            8             3              1              3              3
7              1            6             2              3              3              3
8              6            6             1              2              5              2
9              8            8             1              4              5              1
10            NA           NA            NA              6              5              1
11            NA           NA            NA              8              5              1
```

Let me try to spell it out. For each ... argument, there are as many columns in the result as there are variables in that argument, plus 1. The last one is for the counts. The others are for the combination of values being counted. All the column names start with an id for the ... arg followed by a column specific part. The arg identifier is an underscore separated concatenation of variables in that argument. The column specific part is either the name of a variable or "freq". NA is used as filler when necessary. It's probably easier to look at the example.

### Function `summarize_mergeable`

When using the `dplyr` extension pack you may notice two new functions by a similar name: `summarize` and `summarize_mergeable`. The latter should be used when the summarization is associative and commutative, like a sum, to reap important performance benefits, but can't be used with operations like `mean`, which do no enjoy the same properties. It's the same as the `.mergeable` argument to `transmute`, but instead of trying to monkey patch `summarize` to accept an additional argument I went for the additional function. Remember `summarize` can only be used for single row summaries and gives important performance benefits when summarizing many small groups.

### Higher order function for creating data frame functions

Just a little convenience for when you'd like to apply the same vector function to each column of a data frame. 


```r
log.data.frame = each.column(log)
mtcars %|% log.data.frame %|% head
```

```
    mpg   cyl  disp    hp  drat     wt  qsec   vs   am  gear   carb
1 3.045 1.792 5.075 4.700 1.361 0.9632 2.801 -Inf    0 1.386 1.3863
2 3.045 1.792 5.075 4.700 1.361 1.0561 2.834 -Inf    0 1.386 1.3863
3 3.127 1.386 4.682 4.533 1.348 0.8416 2.924    0    0 1.386 0.0000
4 3.063 1.792 5.553 4.700 1.125 1.1678 2.967    0 -Inf 1.099 0.0000
5 2.929 2.079 5.886 5.165 1.147 1.2355 2.834 -Inf -Inf 1.099 0.6931
6 2.896 1.792 5.416 4.654 1.015 1.2413 3.007    0 -Inf 1.099 0.0000
```

With this function, you can do things like:


```r
mtcars.in %|% gapply(log.data.frame) %|% as.data.frame %|% head
```

```
    mpg   cyl  disp    hp  drat     wt  qsec   vs   am  gear   carb
1 3.045 1.792 5.075 4.700 1.361 0.9632 2.801 -Inf    0 1.386 1.3863
2 3.045 1.792 5.075 4.700 1.361 1.0561 2.834 -Inf    0 1.386 1.3863
3 3.127 1.386 4.682 4.533 1.348 0.8416 2.924    0    0 1.386 0.0000
4 3.063 1.792 5.553 4.700 1.125 1.1678 2.967    0 -Inf 1.099 0.0000
5 2.929 2.079 5.886 5.165 1.147 1.2355 2.834 -Inf -Inf 1.099 0.6931
6 2.896 1.792 5.416 4.654 1.015 1.2413 3.007    0 -Inf 1.099 0.0000
```



### Dropped support for base functions transform and subset 

As part of a major clean-up of how non-standard evaluation is handled (a.k.a ... expression arguments), base functions `transform` and `subset` are not supported anymore. They were part of an extension pack and they required lots of complex code to make up for a brittle way of handling ... arguments. There are plenty of alternatives anyway: `where`, `select`, `bind.cols`, and, from the `dplyr` extension pack, `filter` and `mutate` .

## Bugs

What bugs? Nothing major to report for `plyrmr` but the new use cases that it makes possible put pressure on dear old `rmr2`, hence it's necessary to upgrade it to version `3.3.0`.



