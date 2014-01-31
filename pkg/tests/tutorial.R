## @knitr startup
suppressPackageStartupMessages(library("plyrmr"))
invisible(rmr.options(backend="local"))
invisible(dfs.rmr("/tmp/mtcars"))
invisible(output(input(mtcars), "/tmp/mtcars"))
## @knitr mtcars
mtcars
## @knitr transform
transform(mtcars, carb.per.cyl = carb/cyl)
## @knitr transform-input
transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl)
## @knitr as.data.frame-transform-input
as.data.frame(transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl))
## @knitr invisible-dfs.rmr
invisible(dfs.rmr("/tmp/mtcars.out"))
## @knitr output-transform-input
output(transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl), "/tmp/mtcars.out")
## @knitr mtcars-w-ratio
mtcars.w.ratio = transform(input("/tmp/mtcars"), carb.per.cyl = carb/cyl)
as.data.frame(mtcars.w.ratio)
## @knitr subset-transform
subset(
	transform(
		mtcars, 
		carb.per.cyl = carb/cyl), 
	carb.per.cyl >= 1)
## @knitr subset-transform-input
x = 
	subset(
		transform(
			input("/tmp/mtcars"), 
			carb.per.cyl = carb/cyl), 
		carb.per.cyl >= 1)
as.data.frame(x)
## @knitr where-select
where(
	select(
		mtcars, 
		carb.per.cyl = carb/cyl, 
		.replace = FALSE), 
	carb.per.cyl >= 1)
## @knitr where-select-input
x = 
	where(
		select(
			input("/tmp/mtcars"), 
			carb.per.cyl = carb/cyl, 
			.replace = FALSE), 
		carb.per.cyl >= 1)
as.data.frame(x)
## @knitr end
if(FALSE) {
## @knitr process.mtcars.1
process.mtcars.1 = function(...) subset(mtcars, ...)
high.carb.cyl.1 = function(x) {process.mtcars.1(carb/cyl >= x) }
high.carb.cyl.1(1) 
## @knitr end
}
## @knitr process.mtcars.2
process.mtcars.2 = function(...) where(mtcars, ..., .envir = parent.frame())
high.carb.cyl.2 = function(x) {process.mtcars.2(carb/cyl >= x) }
high.carb.cyl.2(1)
## @knitr last.col
last.col = function(x) x[, ncol(x), drop = FALSE]
## @knitr do-input
as.data.frame(do(input("/tmp/mtcars"), last.col))
## @knitr magic.wand
magic.wand(last.col)
last.col(mtcars)
as.data.frame(last.col(input("/tmp/mtcars")))
## @knitr summarize
summarize(mtcars, sum(carb))
## @knitr summarize-input
as.data.frame(summarize(input("/tmp/mtcars"), sum(carb) ))
## @knitr summarize-gather
as.data.frame(
	summarize(
		gather(input("/tmp/mtcars")), 
		sum(carb) ))
## @knitr select-group
as.data.frame(
	select(
		group(
			input("/tmp/mtcars"),
			cyl),
		mean.mpg = mean(mpg)))
## @knitr select-group.f
as.data.frame(
	select(
		group.f(
			input("/tmp/mtcars"),
			last.col),
		mean.mpg = mean(mpg)))
