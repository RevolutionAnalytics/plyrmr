



```r
# the default output hook
hook_output = knit_hooks$get('output')
knit_hooks$set(output = function(x, options) {
  if (!is.null(n <- options$out.lines)) {
    x = unlist(stringr::str_split(x, '\n'))
    if (length(x) > n) {
      # truncate the output
      x = c(head(x, n), '....\n')
    }
    x = paste(x, collapse = '\n') # paste first n lines together
  }
  hook_output(x, options)
})
opts_chunk$set(out.lines = 8)
```


plyrmr
=====

Load package and turn off Hadoop for quick demo

```r
suppressMessages(library(plyrmr))
rmr.options(backend = "local")
```

```
NULL
```


Create a dataset with `input`


```r
mtcars.in = input(mtcars)
```


or simply start from a hdfs path then select some larger engines


```r
mtcars.5cyl.up = subset(mtcars.in, cyl > 4)
```


then group them by cyl


```r
grouped = group.by(mtcars.5cyl.up, "cyl")
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
   mean(carb) mean.HP
1       3.429   122.3
11      3.500   209.2
```


This triggers a mapred job and brings the result into mem as a df. If it's too big, you can write it to a specific location.


```r
file.remove("/tmp/avg.carbs")
```

```
[1] TRUE
```

```r
avg.carbs.out = output(avg.carbs, "/tmp/avg.carbs")
```


You can still read it, if small enough


```r
as.data.frame(avg.carbs.out)
```

```
   mean(carb) mean.HP
1       3.429   122.3
11      3.500   209.2
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
`do` takes a data set and a function and appliess it to chunks of data. It's neither a map or a reduce, this is decided based on 
how it combines with `group.by`. All the functions listed above are implemented with `do` in one line of code. An actual MR job 
is triggered by `from.dfs`, `output` or combining two of `group.by` or `group.by.f` together, since we can't easily optimize
away two groupings into one reduce phase. Comments and suggestions to rhadoop@revolutionanalytics.com.


## Tutorial



```r
big.mtcars = input(mtcars) # or input(path) or any pipe
```



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



```r
data = data.frame(x = 1:10)
```



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



```r
data = input(data)
```



```r
small.squares = mutate(data, x2 = x^2)
```



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



```r
data = data.frame(x = rbinom(32, n = 50, prob = 0.4))
```



```r
ddply(data, "x", summarize, val = unique(x), count = length(x))
```

```
    x val count
1   7   7     1
2   8   8     3
3   9   9     4
4  10  10     5
5  11  11     6
6  12  12     6
7  13  13     8
....
```



```r
data = input(data)
```



```r
counts = summarize(group.by(data, "x"), val = unique(x), count = length(x))
```



```r
as.data.frame(counts)
```

```
    val count
1     8     3
11   11     6
12   13     8
13   12     6
14    9     4
15    7     1
16   16     4
....
```



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



```r
summarize(mtcars, cyl = sum(cyl), carb = sum(carb))
```

```
  cyl carb
1 198   90
```



```r
big.mtcars.grouped = group.together(big.mtcars)
big.mtcars.sum = summarize(big.mtcars.grouped, cyl = sum(cyl), carb = sum(carb))
as.data.frame(big.mtcars.sum)
```

```
  cyl carb
1 198   90
```



```r
ddply(mtcars, "cyl", summarize, cyl = sum(cyl), carb = sum(carb))
```

```
  cyl carb
1  44   17
2  42   24
3 112   49
```



```r
big.mtcars.by.cyl = group.by(big.mtcars, "cyl")
big.mtcars.sum.by.cyl	= summarize(big.mtcars.by.cyl, cyl = sum(cyl), carb = sum(carb))
as.data.frame(big.mtcars.sum.by.cyl)
```

```
   cyl carb
1   42   24
11  44   17
12 112   49
```



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

 

```r
words = summarize(data, words = unlist(strsplit(lines, " ")))
ddply(words, "words", summarize, count = length(words))
```

```
   words count
1      A    36
2      B    39
3      C    41
4      D    45
5      E    46
6      F    34
7      G    31
....
```



```r
words = summarize(input(data), words = unlist(strsplit(lines, " ")))
wordcount = summarize(group.by(words, "words"), word = unique(words), count = length(words))
as.data.frame(wordcount)
```

```
    word count
1      U    34
11     N    34
12     I    37
13     F    34
14     E    46
15     R    44
16     S    35
....
```




