# Copyright 2013 Revolution Analytics
#    
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## @knitr load-library
suppressPackageStartupMessages(library(plyrmr))
## @knitr local-backend
rmr.options(backend = "local")
## @knitr input
big.mtcars = input(mtcars) # or input(path)
## @knitr as.data.frame
as.data.frame(big.mtcars)
## @knitr small-integers
data = data.frame(x = 1:10)
## @knitr squares-data-frame
mutate(data, x2 = x^2)
## @knitr input-small-integers
data = input(data)
## @knitr squares-plyrmr
small.squares = mutate(data, x2 = x^2)
small.squares
## @knitr squares-results
as.data.frame(small.squares)
## @knitr output
file.remove("/tmp/small.squares")
output(small.squares, "/tmp/small.squares")
## @knitr as.data.frame-output
as.data.frame(input("/tmp/small.squares"))
## @knitr binomial-sample
data = data.frame(x = rbinom(32, n = 50, prob = 0.4))
## @knitr count-data-frame
ddply(data, "x", summarize, val = unique(x), count = length(x))
## @knitr input-binomial-sample
data = input(data)
## @knitr count-plyrmr
counts = summarize(group(data, x), val = unique(x), count = length(x))
## @knitr count-results
as.data.frame(counts)
## @knitr identity-data-frame
transform(mtcars)
## @knitr identity-plyrmr
big.mtcars.again = transform(big.mtcars)
as.data.frame(big.mtcars.again)
## @knitr subset-data-frame
subset(mtcars, cyl > 4)
## @knitr subset-plyrmr
big.mtcars.cyl.gt.4 = subset(big.mtcars, cyl > 4)
as.data.frame(big.mtcars.cyl.gt.4)
## @knitr select-data-frame
summarize(mtcars, mpg = mpg, cyl = cyl)
## @knitr select-plyrmr
big.mtcars.cyl.carb = summarize(big.mtcars, mpg = mpg, cyl = cyl)
as.data.frame(big.mtcars.cyl.carb)
## @knitr select-plyrmr-alternative
big.mtcars.cyl.carb =select(big.mtcars, mpg = mpg, cyl = cyl)
as.data.frame(big.mtcars.cyl.carb)
## @knitr big-sum-data-frame
summarize(mtcars, cyl = sum(cyl), carb = sum(carb))
## @knitr big-sum-plyrmr
big.mtcars.partial.sums = summarize(big.mtcars, cyl = sum(cyl), carb = sum(carb))
big.mtcars.sum = summarize(group(big.mtcars.partial.sums, 1), cyl = sum(cyl), carb = sum(carb))
as.data.frame(big.mtcars.sum)
## @knitr group-sum-data-frame
ddply(mtcars, "cyl", summarize, cyl = sum(cyl), carb = sum(carb))
## @knitr group-sum-plyrmr
big.mtcars.by.cyl = group(big.mtcars, cyl)
big.mtcars.sum.by.cyl	= summarize(big.mtcars.by.cyl, cyl = sum(cyl), carb = sum(carb))
as.data.frame(big.mtcars.sum.by.cyl)
## @knitr textual-data 
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
## @knitr wordcount-data-frame
words = summarize(data, words = unlist(strsplit(lines, " ")))
ddply(words, "words", summarize, count = length(words))
## @knitr wordcount-plyrmr
words = summarize(input(data), words = unlist(strsplit(lines, " ")))
wordcount = summarize(group(words, words), word = unique(words), count = length(words))
as.data.frame(wordcount)
## @knitr

