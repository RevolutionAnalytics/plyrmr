## @knitr startup
options(warn = -1)
#rm(mtcars)
suppressPackageStartupMessages(library("plyrmr"))
plyrmr.options(backend = "spark")
#invisible(rmr.options(backend="local"))
#invisible(dfs.rmr("/tmp/mtcars"))
file.remove("/tmp/mtcars")
# mtcars = cbind(model = row.names(mtcars), mtcars)
# row.names(mtcars) = NULL
#invisible(output(input(mtcars), "/tmp/mtcars"))
#workaround for lack of output features in SparkR
#will work only in local mode
write.table(mtcars, file = "/tmp/mtcars", row.names = F, col.names = FALSE)
## @knitr mtcars
mtcars
## @knitr bind.cols
bind.cols(mtcars, carb.per.cyl = carb/cyl)
## @knitr bind.cols-input
bind.cols(input(mtcars), carb.per.cyl = carb/cyl)
## @knitr as.data.frame-bind.cols-input
as.data.frame(bind.cols(input(mtcars), carb.per.cyl = carb/cyl))
## @knitr invisible-dfs.rmr
#invisible(dfs.rmr("/tmp/mtcars.out"))
## @knitr output-bind.cols-input
#output(bind.cols(input(mtcars), carb.per.cyl = carb/cyl), "/tmp/mtcars.out")
## @knitr mtcars-w-ratio
mtcars.w.ratio = bind.cols(input(mtcars), carb.per.cyl = carb/cyl)
as.data.frame(mtcars.w.ratio)
## @knitr where-bind.cols
where(
	bind.cols(
		mtcars, 
		carb.per.cyl = carb/cyl), 
	carb.per.cyl >= 1)
## @knitr where-bind.cols-input
where(
	transmute(
		input(mtcars),
		carb.per.cyl = carb/cyl,
		.cbind = TRUE ),
	carb.per.cyl >= 1)
## @knitr assignment-chain
x =	bind.cols(mtcars, carb.per.cyl = carb/cyl) 
where(x, carb.per.cyl >= 1)
## @knitr pipe-operator
mtcars %|%
	bind.cols(carb.per.cyl = carb/cyl) %|%
	where(carb.per.cyl >= 1)
## @knitr end
if(FALSE) {
## @knitr process.mtcars.1
where.mtcars.1 = function(...) where(mtcars, ...)
high.carb.cyl.1 = function(x) {where.mtcars.1(carb/cyl >= x) }
high.carb.cyl.1(1) 
## @knitr end
}
## @knitr process.mtcars.2
where.mtcars.2 = function(...) where(mtcars, ..., .envir = parent.frame())
high.carb.cyl.2 = function(x) {where.mtcars.2(carb/cyl >= x) }
high.carb.cyl.2(1)
## @knitr last.col
last.col = function(x) x[, ncol(x), drop = FALSE]
## @knitr gapply-input
gapply(input(mtcars), last.col)
## @knitr magic.wand
magic.wand(last.col)
last.col(mtcars)
last.col(input(mtcars))
## @knitr transmute
transmute(mtcars, sum(carb))
## @knitr transmute-input-setup
invisible({
	rmr.options(backend = "hadoop")
	if3 = make.input.format("native", read.size = 1000)
	of3 = make.output.format("native", write.size = 1000)
	if(dfs.exists("/tmp/mtcars3")) dfs.rmr("/tmp/mtcars3")
	to.dfs(mtcars, format = of3, output = "/tmp/mtcars3")})
## @knitr transmute-input
transmute(input("/tmp/mtcars3", format = if3), sum(carb))
## @knitr transmute-gather
input("/tmp/mtcars3", format = if3) %|%
	gather() %|%
	transmute(sum(carb), .mergeable = TRUE)
## @knitr transmute-gather-cleanup
invisible(suppressWarnings(rmr.options(backend = "local")))
## @knitr transmute-group
input(mtcars) %|%
	group(cyl) %|%
	transmute(mean.mpg = mean(mpg))
## @knitr transmute-group.f
input(mtcars) %|%
	group.f(last.col) %|%
	transmute(mean.mpg = mean(mpg)) 
## @knitr group-quantile
input(mtcars) %|%
	group(carb) %|%
	quantile.cols() 
## @knitr group-lm
models = 
	input(mtcars) %|%
	group(carb) %|%
	transmute(model = list(lm(mpg~cyl+disp))) %|%
	as.data.frame()
models
models[1,2]
