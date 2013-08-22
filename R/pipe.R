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

# function manip
comp = 
	function(...) {
		funs = list(...)
		funs = strip.nulls(funs)
		if(length(funs) == 1)
			funs[[1]]
		else		
			do.call(Compose, funs)}

make.map.fun = 
	function(keyf, valf) {
		if(is.null(keyf)) 
			keyf = constant(NULL)
		if(is.null(valf)) 
			valf = identity 
		function(k, v) {
			v = as.data.frame(valf(v))
			k = keyf(v)
			keyval(k, v)}}

make.combine.fun = 
	function(valf) 
		make.map.fun(identity, function(.x) as.data.frame(valf(.x)))

make.reduce.fun = 
	function(valf) 
		make.map.fun(NULL, function(.x) as.data.frame(valf(.x)))

to.fun1 = 
	function(f, ...)
		function(.x)
			do.call(f, c(list(.x), dots(...)))

#pipes

is.data = 
	function(x)
		inherits(x, "pipe")

setMethodS3(
	"as.character",
	"pipe",
	function(x) 
		paste(
			"Slots set:", 
			paste(names(unclass(x)), collapse = ", "), "\n",
			"Input:",
			as.character(x[["input"]]),
			"\n"))

setMethodS3(
	"print",
	"pipe",
	function(x) {
		print(as.character(x))
		invisible(x)})

do =  
	function(.data, f, ...){
		dot.args = dots(...)
		f1 = 
			freeze.env(
				function(.x) 
					do.call(f, c(list(.x), dot.args)))
		if(is.null(.data$group.by))
			.data$map = comp(.data$map, f1)
		else
			.data$reduce = comp(.data$reduce, f1)
		.data}

group.by = 
	function(.data, ..., recursive = FALSE) {
		dot.args = dots(...)
		group.by.f(
			.data, 
			function(.y) 
				do.call(select, c(list(.y), dot.args)))}

group.by.f = 
	function(.data, f, ..., recursive = FALSE) {
		dot.args = dots(...)
		f1 = 
			freeze.env(
				function(.x) 
					do.call(f, c(list(.x), dot.args)))
		if(is.null(.data$group.by)){
			.data$group.by = f1
			if(recursive) 
				.data$recursive.group = TRUE
			.data}
		else
			group.by.f(
				input(run(.data)), 
				f1, 
				recursive = recursive)}

group.together = 
	function(.data, recursive = FALSE) 
		group.by(.data, 1, recursive = recursive)

mr.options = 
	function(.data, ...) {
		args = list(...)
		.data[names(args)] = args
		.data }

mrexec =
	function(mr.args, input.format)
		as.big.data(
			do.call(mapreduce, mr.args),
			format = input.format)

run = 
	function(.data, input.format) {
		pipe = .data
		if(
			all(
				sapply(
					pipe[qw(map, reduce, group.by)], 
					is.null))) { 
			if(!is.null(pipe[["output"]])) {
				dfs.mv(pipe[["input"]]$data, pipe[["output"]])
				as.big.data(pipe[["output"]], pipe[["input"]]$format)}
			else {
				pipe[["input"]]}}
		else {
			mr.args = list()
			mr.args$input = pipe$input$data
			mr.args$input.format = pipe$input$format
			mr.args$output = pipe[['output']]
			mr.args$output.format = pipe[['output.format']]
			mr.args = strip.nulls(mr.args)
			mr.args$map = 
				make.map.fun(
					keyf = pipe$group.by, 
					valf = pipe$map)
			if(!is.null(pipe$reduce) &&
				 	!is.null(pipe$group.by)) {
				mr.args$reduce = 
					make.reduce.fun(
						valf = pipe$reduce)}
			if(!is.null(pipe$recursive.group) &&
				 	pipe$recursive.group) {
				mr.args.combine =
					make.combine.fun(pipe$reduce)}
			mrexec(mr.args, input.format)}}

output = 
	function(.data, path = NULL, format = "native", input.format = format) {
		if(missing(input.format) && !is.character(format))
			stop("need to specify a custom input format for a custom output")
		.data[["output.format"]] = format
		.data[["output"]] = path
		as.big.data(.data, input.format)}

setMethodS3(
	"as.big.data",
	"pipe",
	run)

ungroup = as.big.data.pipe

as.pipe = function(x, ...) UseMethod("as.pipe")

setMethodS3(
	"as.pipe",
	"big.data",
	function(x) 
		structure(
			strip.null.args(
				input = x),
			class = "pipe"))

as.pipe.1 = 
	function(x) 
		as.pipe(as.big.data(x, "native"))

as.pipe.2 = 
	function(x, format = "native") 
		as.pipe(as.big.data(x, format))

setMethodS3(
	"as.pipe", 
	"data.frame", 
	as.pipe.1)

setMethodS3(
	"as.pipe", 
	"character", 
	as.pipe.2)

setMethodS3(
	"as.pipe", 
	"function", 
	as.pipe.2)

setMethodS3(
	"as.pipe",
	"list",
	Compose(as.big.data, as.pipe)) 

setMethodS3(
	"as.data.frame",
	"pipe",
	function(x)
		as.data.frame(
			as.big.data(x, "native")))

input  = as.pipe

magic.wand = 
	function(f) 
		setMethodS3(
			as.character(substitute(f)), 
			"pipe", 
			function(.data, ...) 
				do(.data, f, ...),
			envir=parent.frame())
