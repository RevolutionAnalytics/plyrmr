





# Tutorial

## Introduction

`Plyrmr` is a package that allows to manipulate very large data sets (VLDSs). Because it's backed by Hadoop, large means up to petabytes in scale. It's based on another package, `rmr2`, which provides the foundation for writing programs according to the mapreduce paradigm. `Plyrmr` endeavors to add a layer of abstraction and, hopefully, conveninence and ease of use on top of `rmr2`. To achieve that, it takes inspiration from the data manipulation style promoted by Hadley Wickham in his very popular packages `plyr` and `reshape2` and the very new `dplyr` and adapts it to the VLDS setting.

## Basic concepts


### Programming model

VLDSs reside on disk and on multiple machines and they need to be processed on groups of machines called clusters, by definition of *very large*. Therefore, you can't load them as a whole into R, that is into main memory at any given time. You can only process small chunks, regroup them, process the resulting chunks and repeat. This matches very nicely into Hadley's organization of basic data manipulations into a system called "split-apply-combine", with one fundamental difference: the combine and split operation are combined into a single operation. This is necessary, because VLDSs are too big to exist in their "combined" form: they can exist only in one of many "split" states: fortunately we have control on how the split is defined. So instead of Hadley's three pronged approach to data manipulation, we have a two pronged one that maps naturally to the underlying map-reduce paradigm. The idea of `plyrmr` is to take the `plyr` style of data processing and map it to the underlying mapreduce paradigm trying to keep a similar syntax and semantics.   

### Data model

The model is the data.frame. The data is always represented as data frames, each of which contains part of the data. People used to `rmr2` or `plyr` may find this a restriction, and indeed it was a simplifying assumption in the desing phase. 

### Initialization


```r
suppressPackageStartupMessages(library(plyrmr))
```



```r
rmr.options(backend = "local")
```

```
NULL
```



### Building blocks

In `plyrmr` there are `pipes`, which are R expressions describing a computation. The simplest pipe has an input. The input can be a data frame, a file or another pipe, the first two of which need to be wrapped in an `input` call. The computation can be triggered with either `output` or `as.data.frame`, the first resulting in the data being written to a file and the second creating a data frame. So a trivial pipe could be

```
as.data.frame(input(mtcars))
```

To do something useful we need to create more complex expressions combining essentially two sets of basic ingredients: processing steps and grouping steps. We can also combine pipes into more complex ones. As we said, the data is always chunked, due to its size. The initial state is arbitrary, meaning that the data is sorted and grouped arbitrarily, but grouping can be modified with the primitive `group.f`. The fundamental processing primitive is `do`, which applies a function to each chunk. The function should transform a data frame into another data frame. For instance, if we wanted to compute the number of carburators per cylinder for the cars in the `mtcars` data set (all of 32, of course this is only for illustrative purposes), one could simply do

```
transform(mtcars, ratio = carb/cyl)

```

This is a regular data frame processing function from the package `base`. Now what if we wanted to do this on a VLDS? This is a row-by-row operation, hence the order and grouping of data does not matter. This allows us to define a pipe as follows

```
do(input(mtcars), transform, ratio = carb/cyl)
```













To identify input data we need the function `input`. If we want to process file `"some/path"`, we need to call `input("some/path")`. If we want to create a small data set on the fly, we can pass a data frame as argument. This is most useful for learning and testing purposes. This is an example of the latter: 


```r
big.mtcars = input(mtcars) # or input(path)
```

Also for compatibility with `rmr2` we can pass the output of a `mapreduce` call to `input`.
The reverse step is to take some data and turn it into a data frame (do this only on small data sets such as in this example):
	

```r
as.data.frame(big.mtcars)
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


Let's start now with some simple processing, like taking the square of some numbers. In R and particularly using the `plyr` package and its approach to data manipulation, you could proceed as follows. First create a data frame with some numbers:

```r
data = data.frame(x = 1:10)
```


Then add a column of squares with `mutate` (which is very similar to `transform` in the `base` package).


```r
mutate(data, x2 = x^2)
```

```
    x  x2
1   1   1
2   2   4
3   3   9
4   4  16
5   5  25
6   6  36
7   7  49
....
```


Let's make this an input data set according to the `plyrmr`.


```r
data = input(data)
```


We can call `mutate` on this data set and store the result in a variable. It doesn't look like that variable has data at all in it, in fact it doesn't. It's a `pipe`, a description of a sequence of processing steps. Nothing gets actually computed until necessary. 


```r
small.squares = mutate(data, x2 = x^2)
small.squares
```

```
[1] "Slots set: input, ungroup, map \n Input: Temporary file \n"
```


But if we turn a `pipe` into a data frame, we see the data as expected. 


```r
as.data.frame(small.squares)
```

```
    x  x2
1   1   1
2   2   4
3   3   9
4   4  16
5   5  25
6   6  36
7   7  49
....
```


Turning a `pipe` into a data frame is one of a few triggering events that will start the actual computation. This is powered by `rmr2`, hence it can be hadoop backed, hence it can operate on VLDSs. An almost identical syntax can be used to perform the same operation on a data frame and a Hadoop data set. When operating on VLDSs, we can't use `as.data.frame`, because there isn't enough RAM available. The alternative is the `output` primitive, which will trigger the actual computation described by a `pipe` and store the results to a user-specified path:


```r
file.remove("/tmp/small.squares")
```

```
Warning: cannot remove file '/tmp/small.squares', reason 'No such file or
directory'
```

```
[1] FALSE
```

```r
output(small.squares, "/tmp/small.squares")
```

```
[1] "/tmp/small.squares" "native"            
```


And let's check that it actually worked:
	
	```r
	as.data.frame(input("/tmp/small.squares"))
	```
	
	```
	    x  x2
	1   1   1
	2   2   4
	3   3   9
	4   4  16
	5   5  25
	6   6  36
	7   7  49
	....
	```

With `output` and refraining from using `as.data.frame` we can process hadoop sized data sets. Of course we can use `as.data.frame` after a number of data reduction steps. Another role of output is as a bridge with `rmr2`. You can just write `mapreduce(ouput(...))` and combine the best of the two packages.

Let's move to some counting task. We create a data frame with a single column containing a sample from the binomial distribution, just for illustration purposes.


```r
data = data.frame(x = rbinom(32, n = 50, prob = 0.4))
```


Counting the number of occurrences of each outcome is a single line task in `plyr`. `ddply` splits a data frame according to a variable and summarize creates a new data frame with the columns specified in its additional arguments.


```r
ddply(data, "x", summarize, val = unique(x), count = length(x))
```

```
    x val count
1   7   7     1
2   9   9     2
3  10  10     5
4  11  11     6
5  12  12    10
6  13  13     5
7  14  14     6
....
```


Let's create a `plyrmr` data set with `input`


```r
data = input(data)
```


The equivalent in `plyrmr` is not as close in syntax as before, because we followed more closely the syntax of an experimental package by the same author as `plyr` called `dplyr`, which is focused on data frames and adds multiple backends and can be considered a specialization and evolution of `plyr`. `dplyr` is temporarily incompatible with `rmr2` and not as well known as `plyr` yet and so it is not used here, but was a reference point in the design of `plyrmr`. `plyrmr`, like `dplyr` has a separate `group` primitive (`group_by` in `dplyr`), named after its SQL equivalent, that defines a grouping of a data set based on a column (expressions are not supported yet).


```r
counts = summarize(group(data, x), val = unique(x), count = length(x))
```


What we can see here is that we can combine two `pipes` by composing two functions. We can check the results with


```r
as.data.frame(counts)
```

```
      x val count
1.8  19  19     1
1.11 10  10     5
1.5  14  14     6
1.10  7   7     1
1    13  13     5
1.7  15  15     6
1.3  17  17     3
....
```

Please note that the results are not in the same order. This is always true with Hadoop and if other examples in this tutorial seem to show the opposite it's only because of the tiny size of the data sets involved. Not incidentally, theoreticians have formalized this computational model as MUD (Massive Unordered Distributed, see [this paper](http://arxiv.org/abs/cs/0611108)). 

Writing an identity function is not particularly interesting and won't make you rich, but it's a boilerplate test. Here is one way of expressing the identity in R:


```r
transform(mtcars)
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


And here is the equivalent in plyrmr.


```r
big.mtcars.again = transform(big.mtcars)
as.data.frame(big.mtcars.again)
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


Now let's take a baby step: select certain rows. The function `subset` in `base` comes in handy.


```r
subset(mtcars, cyl > 4)
```

```
                     mpg cyl  disp  hp drat    wt  qsec vs am gear carb
Mazda RX4           21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
Mazda RX4 Wag       21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
Hornet 4 Drive      21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
Hornet Sportabout   18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
Valiant             18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
Duster 360          14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
Merc 280            19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
....
```


We now can do exactly the same on a Hadoop data set:
	
	
	```r
	big.mtcars.cyl.gt.4 = subset(big.mtcars, cyl > 4)
	as.data.frame(big.mtcars.cyl.gt.4)
	```
	
	```
	                     mpg cyl  disp  hp drat    wt  qsec vs am gear carb
	Mazda RX4           21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
	Mazda RX4 Wag       21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
	Hornet 4 Drive      21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
	Hornet Sportabout   18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
	Valiant             18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
	Duster 360          14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
	Merc 280            19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
	....
	```


Next baby step up from selecting rows is selecting columns:
	
	```r
	summarize(mtcars, mpg = mpg, cyl = cyl)
	```
	
	```
	    mpg cyl
	1  21.0   6
	2  21.0   6
	3  22.8   4
	4  21.4   6
	5  18.7   8
	6  18.1   6
	7  14.3   8
	....
	```


And in `plyrmr`

```r
big.mtcars.cyl.carb = summarize(big.mtcars, mpg = mpg, cyl = cyl)
as.data.frame(big.mtcars.cyl.carb)
```

```
    mpg cyl
1  21.0   6
2  21.0   6
3  22.8   4
4  21.4   6
5  18.7   8
6  18.1   6
7  14.3   8
....
```


Deceptively similar, but works on petabytes. In fact `summarize` doesn't seem the right name for this function, which can do a lot more. So we aliased to `select`, following dplyr, to allow the programmer to express intent.


```r
big.mtcars.cyl.carb =select(big.mtcars, mpg = mpg, cyl = cyl)
as.data.frame(big.mtcars.cyl.carb)
```

```
    mpg cyl
1  21.0   6
2  21.0   6
3  22.8   4
4  21.4   6
5  18.7   8
6  18.1   6
7  14.3   8
....
```


We are now going to tackle the extreme data reduction task, whereby we go from a data set to a single number (per column), in this case taking the sum. This is very simple in 	`plyr`


```r
summarize(mtcars, cyl = sum(cyl), carb = sum(carb))
```

```
  cyl carb
1 198   90
```


but a little more complex in `plyrmr`, and why that's the case merits a little explanation. `plyr::summarize` works on data frames and has all the data available simultaneously. This is not true for "plyrmr" because large data sets are processed piecemeal. So we need to perform the sum on each chunk of data, group the results together, sum again. `group(data, 1)` just means group everything together, in fact there is handy alias for that, `group.together` 


```r
big.mtcars.partial.sums = summarize(big.mtcars, cyl = sum(cyl), carb = sum(carb))
big.mtcars.sum = summarize(group(big.mtcars.partial.sums, 1), cyl = sum(cyl), carb = sum(carb))
as.data.frame(big.mtcars.sum)
```

```
  X1 cyl carb
1  1 198   90
```


In many other use cases, instead of a single summary, we are interested in summaries by group. In `plyr` this calls for the `ddply` function (`group_by` in `dplyr`)
	
	```r
	ddply(mtcars, "cyl", summarize, cyl = sum(cyl), carb = sum(carb))
	```
	
	```
	  cyl carb
	1  44   17
	2  42   24
	3 112   49
	```


The equivalent in `plyrmr` is `group`


```r
big.mtcars.by.cyl = group(big.mtcars, cyl)
big.mtcars.sum.by.cyl	= summarize(big.mtcars.by.cyl, cyl = sum(cyl), carb = sum(carb))
as.data.frame(big.mtcars.sum.by.cyl)
```

```
    cyl carb
1     6   24
1.1   4   17
1.2   8   49
```


We are ready to write the wordcount function, the "hello world" equivalent of the Hadoop world. The task is to read in a data frame with lines of text, split the lines into words and count how many times each word occurs. First let's make up some fake text data to keep things self-contained.


```r
data = 
	data.frame(
		lines = 
			sapply(
				split(
					as.character(
						sample(LETTERS, 1000, replace = TRUE)), 
					1:1000%%20), 
				paste, 
				collapse = " "), 
		stringsAsFactors = FALSE)
```


This is how the task can be accomplised working on a data frame. 
 


```r
words = summarize(data, words = unlist(strsplit(lines, " ")))
ddply(words, "words", summarize, count = length(words))
```

```
   words count
1      A    48
2      B    42
3      C    31
4      D    34
5      E    38
6      F    36
7      G    41
....
```


In fact the name `summarize` seems again unsatisfactory for self-documenting code here. We are looking for at least an alias that could capture this kind of usage. Maybe `explode`? 


```r
words = summarize(input(data), words = unlist(strsplit(lines, " ")))
wordcount = summarize(group(words, words), word = unique(words), count = length(words))
as.data.frame(wordcount)
```

```
     words word count
1.7      F    F    36
1        U    U    35
1.18     G    G    41
1.17     N    N    43
1.20     B    B    42
1.3      H    H    34
1.10     S    S    36
....
```


## The fundamental primitives: `do`  and `group.f`




