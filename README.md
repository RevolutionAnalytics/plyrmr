





# plyrmr

Load package and turn off Hadoop for quick demo

```r
suppressMessages(library(plyrmr))
rmr.options(backend = "local")
```

```
NULL
```

```r
set.seed(0)
```


Create a dataset with `input`


```r
mtcars.in = input(mtcars)
```


or simply start from a HDFS path then select some larger engines


```r
mtcars.5cyl.up = subset(mtcars.in, cyl > 4)
```


then group them by cyl


```r
grouped = group.by(mtcars.5cyl.up, cyl)
```


then look at the average carbs


```r
avg.carbs = summarize(grouped, mean(carb), mean.HP = mean(hp))
```


nothing happened yet, is it real?


```r
as.data.frame(avg.carbs)
```

```
   mean.carb. mean.HP
X1      3.429   122.3
X2      3.500   209.2
```


This triggers a mapreduce job and brings the result into memory as a data frame. If it's too big, you can write it to a specific location.


```r
file.remove("/tmp/avg.carbs")
```

```
Warning: cannot remove file '/tmp/avg.carbs', reason 'No such file or
directory'
```

```
[1] FALSE
```

```r
avg.carbs.out = output(avg.carbs, "/tmp/avg.carbs")
```


You can still read it, if small enough


```r
as.data.frame(avg.carbs.out)
```

```
   mean.carb. mean.HP
X1      3.429   122.3
X2      3.500   209.2
```


Most functions are modeled after familiar ones

```
  transform #from base
  subset #from base
  mutate #from plyr
  summarize #from plyr
  select # synonym for summarize
```

`group.by` takes some dataset and column specs. `group.by.f` takes a function that generates the grouping columns on the fly.
`do` takes a data set and a function and applies it to chunks of data. It's neither a map or a reduce, this is decided based on 
how it combines with `group.by`. All the functions listed above are implemented with `do` in one line of code. An actual MR job 
is triggered by `from.dfs`, `output` or combining two of `group.by` or `group.by.f` together, since we can't easily optimize
away two groupings into one reduce phase. Comments and suggestions to rhadoop@revolutionanalytics.com.


## Tutorial

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
X1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
X2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
X3  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
X4  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
X5  18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
X6  18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
X7  14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
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
[1] "Slots set: input, map \n Input: Temporary file \n"
```


But if we turn a `pipe` into a data frame, we see the data as expected. 


```r
as.data.frame(small.squares)
```

```
     x  x2
X1   1   1
X2   2   4
X3   3   9
X4   4  16
X5   5  25
X6   6  36
X7   7  49
....
```


Turning a `pipe` into a data frame is one of a few triggering events that will start the actual computation. This is powered by `rmr2`, hence it can be hadoop backed, hence it can operate on very large data sets. An almost identical syntax can be used to perform the same operation on a data frame and a Hadoop data set. When operating on very large data sets, we can't use `as.data.frame`, because there isn't enough RAM available. The alternative is the `output` primitive, which will trigger the actual computation described by a `pipe` and store the results to a user-specified path:


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
X1   1   1
X2   2   4
X3   3   9
X4   4  16
X5   5  25
X6   6  36
X7   7  49
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
1   9   9     4
2  10  10     6
3  11  11     5
4  12  12    10
5  13  13     5
6  14  14     5
7  15  15     5
....
```


Let's create a `plyrmr` data set with `input`


```r
data = input(data)
```


The equivalent in `plyrmr` is not as close in syntax as before, because we followed more closely the syntax of an experimental package by the same author as `plyr` called `dplyr`, which is focused on data frames and adds multiple backends and can be considered a specialization and evolution of `plyr`. `dplyr` is temporarily incompatible with `rmr2` and not as well known as `plyr` yet and so it is not used here, but was a reference point in the design of `plyrmr`. `plyrmr`, like `dplyr` has a separate `group.by` primitive (`group_by` in `dplyr`), named after its SQL equivalent, that defines a grouping of a data set based on a column (expressions are not supported yet).


```r
counts = summarize(group.by(data, x), val = unique(x), count = length(x))
```


What we can see here is that we can combine two `pipes` by composing two functions. We can check the results with


```r
as.data.frame(counts)
```

```
    val count
X1   13     5
X2   20     1
X3   12    10
X4   11     5
X5   18     2
X6    9     4
X7   14     5
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
X1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
X2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
X3  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
X4  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
X5  18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
X6  18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
X7  14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
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
X1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
X2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
X3  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
X4  18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
X5  18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
X6  14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
X7  19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
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
X1  21.0   6
X2  21.0   6
X3  22.8   4
X4  21.4   6
X5  18.7   8
X6  18.1   6
X7  14.3   8
....
```


Deceptively similar, but works on petabytes. In fact `summarize` doesn't seem the right name for this function, which can do a lot more. So we aliased to `select`, following dplyr, to allow the programmer to express intent.


```r
big.mtcars.cyl.carb =select(big.mtcars, mpg = mpg, cyl = cyl)
as.data.frame(big.mtcars.cyl.carb)
```

```
Error: object 'envir' not found
```


We are now going to tackle the extreme data reduction task, whereby we go from a data set to a single number (per column), in this case taking the sum. This is very simple in 	`plyr`


```r
summarize(mtcars, cyl = sum(cyl), carb = sum(carb))
```

```
  cyl carb
1 198   90
```


but a little more complex in `plyrmr`, and why that's the case merits a little explanation. `plyr::summarize` works on data frames and has all the data available simultaneously. This is not true for "plyrmr" because large data sets are processed piecemeal. So we need to perform the sum on each chunk of data, group the results together, sum again. `group.by(data, 1)` just means group everything together, in fact there is handy alias for that, `group.together` 


```r
big.mtcars.partial.sums = summarize(big.mtcars, cyl = sum(cyl), carb = sum(carb))
big.mtcars.sum = summarize(group.by(big.mtcars.partial.sums, 1), cyl = sum(cyl), carb = sum(carb))
as.data.frame(big.mtcars.sum)
```

```
   cyl carb
X1 198   90
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


The equivalent in `plyrmr` is `group.by`


```r
big.mtcars.by.cyl = group.by(big.mtcars, cyl)
big.mtcars.sum.by.cyl	= summarize(big.mtcars.by.cyl, cyl = sum(cyl), carb = sum(carb))
as.data.frame(big.mtcars.sum.by.cyl)
```

```
   cyl carb
X1  42   24
X2  44   17
X3 112   49
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
1      A    46
2      B    46
3      C    40
4      D    46
5      E    53
6      F    30
7      G    38
....
```


In fact the name `summarize` seems again unsatisfactory for self-documenting code here. We are looking for at least an alias that could capture this kind of usage. Maybe `explode`? 


```r
words = summarize(input(data), words = unlist(strsplit(lines, " ")))
wordcount = summarize(group.by(words, words), word = unique(words), count = length(words))
as.data.frame(wordcount)
```

```
    word count
X1     B    46
X2     N    38
X3     X    33
X4     Z    44
X5     V    43
X6     I    37
X7     M    35
....
```


## The fundamental primitives: `do`  and `group.by.f`



