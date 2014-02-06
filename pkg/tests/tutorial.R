## @knitr startup
options(warn = -1)
rm(mtcars)
suppressPackageStartupMessages(library("plyrmr"))
invisible(rmr.options(backend="local"))
invisible(dfs.rmr("/tmp/mtcars"))
mtcars = cbind(model = row.names(mtcars), mtcars)
row.names(mtcars) = NULL
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
## @knitr assignment-chain
x =	transform(mtcars, carb.per.cyl = carb/cyl) 
subset(x, carb.per.cyl >= 1)
## @knitr subset-transform-input
x =
	subset(
		transform(
			input("/tmp/mtcars"),
			carb.per.cyl = carb/cyl),
		carb.per.cyl >= 1)
as.data.frame(x)
## @knitr pipe-operator
mtcars %|%
	transform(carb.per.cyl = carb/cyl) %|%
	subset(carb.per.cyl >= 1)
## @knitr where-select
mtcars %|%
	select(carb.per.cyl = carb/cyl, .replace = FALSE) %|%
	where(carb.per.cyl >= 1)
## @knitr where-select-input
x = 
	input("/tmp/mtcars") %|%
	select(carb.per.cyl = carb/cyl, .replace = FALSE) %|%
	where(carb.per.cyl >= 1)
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
## @knitr summarize-input-setup
invisible({
	rmr.options(backend = "hadoop")
	if3 = make.input.format("native", read.size = 1000)
	of3 = make.output.format("native", write.size = 1000)
	dfs.rmr("/tmp/mtcars3")
	to.dfs(mtcars, format = of3, output = "/tmp/mtcars3")})
## @knitr summarize-input
as.data.frame(summarize(input("/tmp/mtcars3", format = if3), sum(carb) ))
## @knitr summarize-gather
input("/tmp/mtcars3", format = if3) %|%
	gather() %|%
	summarize(carb = sum(carb)) %|%
	as.data.frame()
## @knitr summarize-gather-cleanup
invisible(suppressWarnings(rmr.options(backend = "local")))
## @knitr select-group
input("/tmp/mtcars") %|%
	group(cyl) %|%
	select(mean.mpg = mean(mpg)) %|%
	as.data.frame()
## @knitr select-group.f
input("/tmp/mtcars") %|%
	group.f(last.col) %|%
	select(mean.mpg = mean(mpg)) %|%
	as.data.frame()
## @knitr group-quantile
input("/tmp/mtcars") %|%
	group(carb) %|%
	quantile.cols() %|%
	as.data.frame()
## @knitr group-lm
input("/tmp/mtcars") %|%
	group(carb) %|%
	select(model = list(lm(mpg~cyl+disp))) %|%
	as.data.frame()
