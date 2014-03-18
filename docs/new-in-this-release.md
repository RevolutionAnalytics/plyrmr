# What's new in `plyrmr` 0.2.0

# Features
* `.data` variable in `select` and `where` expressions allow to refer to the whole chunk of data, not just one column, for instance to select odd columns: ` select(mtcars, odd = .data[, c(T,F)])`.
* new pipe operators `%|%` and `%!%`: `select(group(select(input(data), select2.args), group.args), select1.args)` can be written like `data %|% input %|% select(select1.args) %|% group(group.args) %|% select(select2.args)` in a unix shell like fashion. `a %!% b` is a shorthand for `function(x) x %|% a %|% b`.   Works with complex expressions and piping into arguments other than the first using the special `.` variable, as in: `LETTERS %|% grep("A", .)` or `LETTERS %|% paste0(.,.,.)`. Similar to features found in packages `vadr`, `dplyr` and `magrittr`.
* optimizations for nested grouping, saves a job in certain circumstances.
* heuristic to avoid name changes in recursive group: `mtcars  %|% input %|% gather %|% select(sum(carb))` just works.
* `where` takes a single argument now. The multiple argument form just calculated a logical `&` of all the arguments, which is an arbitrary default and one more thing to remember. Therefore `where(data, cond1, cond2, cond3)` becomes `where(data, cond1 & cond2 & cond3)`. More clear, same verbosity and symmetric to `where(data, cond1 | cond2 | cond3)`, and we all love symmetries, don't we?
* `select` allows fractional recycling `select(mtcars, even = c(FALSE, TRUE), triad = 1:3, .replace = FALSE)`.
* `.columns` argument for `select`, allows to select multiple cols with a string character: `select(mtcars, .columns=c("carb", "cyl", "mpg"))`.

## Bugs
* fixed bug that resulted in column duplication
* removed `pryr` dependency with modest borrowing of code courtesy of the always supportive @hadley
* more aggressive *freezing* of environments to make delayed evaluation and pipe optimization semantically neutral
* uncountable corner cases addressed (things like 0-rows, 0-columns etc), but there may be more.
