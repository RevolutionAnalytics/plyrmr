# What's new in `plyrmr` 0.2.0

# Features
* redesigned the API to avoid duplication, split jobs between the all powerful `transmute`, the `transform`-like but humbly-named `bind.cols` and the specialized, `dplyr`-lifted `select`.
* `magic.wand` now knows special tricks to deal with non-standard argument evaluation
* `.data` variable in `transmute`, `bind.cols` and `where` expressions allows to refer to the whole chunk of data, not just one column, for instance to select odd columns: `transmute(mtcars, odd = .data[, c(T,F)])`.
* new pipe operators `%|%` and `%!%`: `select(group(select(input(data), select2.args), group.args), select1.args)` can be written like `data %|% input %|% select(select1.args) %|% group(group.args) %|% select(select2.args)` in a unix shell like fashion. `a %!% b` is a shorthand for `function(x) x %|% a %|% b`.   Works with complex expressions and piping into arguments other than the first using the special `.` variable, as in: `LETTERS %|% grep("A", .)` or `LETTERS %|% paste0(.,.,.)`. Similar to features found in packages `vadr`, `dplyr` and `magrittr`.
* optimizations for nested grouping, saves a job in certain circumstances.
* `where` takes a single argument now. The multiple argument form just calculated a logical `&` of all the arguments, which is an arbitrary default and one more thing to remember. Therefore `where(data, cond1, cond2, cond3)` becomes `where(data, cond1 & cond2 & cond3)`. More clear, same verbosity and symmetric to `where(data, cond1 | cond2 | cond3)`, and we all love symmetries, don't we?
* `transmute` allows fractional recycling `transmute(mtcars, even = c(FALSE, TRUE), triad = 1:3, .cbind = TRUE)`.
* `.columns` argument for `transmute`, allows to select multiple cols with a string character: `transmute`(mtcars, .columns=c("carb", "cyl", "mpg"))`.
* removed `pryr` dependency with modest borrowing of code courtesy of the always supportive @hadley
* prettier default names for new columns
* better composition rules for *mergeable* and non-mergeable operations, information about mergeability is stored in the operation itself. *Mergeability* in this context is when an operation is associative and commutative, which allows an important optimization in Mapreduce.
* operations also encapsulate information about being able to deal with multiple groups at once, but this is still work in progress.

## Bugs
* name changes in recursive group: `mtcars  %|% input %|% gather %|% select(sum(carb))` just works.
* column duplication
* more aggressive *freezing* of environments to make delayed evaluation and pipe optimization semantically neutral
* incorrect writing to "native" format when custom expected
* uncountable corner cases (things like 0-rows, 0-columns etc), but there may be more.
