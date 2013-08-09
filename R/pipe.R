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
		funs = funs[!sapply(funs, is.null)]
		do.call(Compose, funs)}

make.map.fun = 
	function(keyf, valf) {
		if(is.null(keyf)) 
			keyf = constant(NULL)
		if(is.null(valf)) 
			valf = identity 
		function(k, v) {
			v = valf(v)
			k = keyf(v)
			keyval(k, v)}}

make.combine.fun = 
	function(valf) 
		make.map.fun(identity, valf)

make.reduce.fun = 
	function(valf) 
		make.map.fun(NULL, valf)

to.fun1 = 
	function(f, ...)
		function(.x)
			f(.x, ...)

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
			paste(names(x), collapse = ", "), "\n",
			"Input:",
			as.character(x$input),
			"\n"))

setMethodS3(
	"print",
	"pipe",
	function(x) {
		print(as.character(x))
		invisible(x)})

protect = 
	function(x) {
		envx= environment(x)
		nenv = as.environment(as.list(envx))
		parent.env(nenv) = parent.env(envx)
		environment(x) = nenv
		x}

do = 
	function(.data, f, ...){
		f1 = to.fun1(protect(f), ...)
		if(is.null(.data$group.by))
			.data$map = comp(.data$map, f1)
		else
			.data$reduce = comp(.data$reduce, f1)
		.data}

group.by = 
	function(.data, ..., recursive = FALSE)
		group.by.f(
			.data, 
			function(.y) 
				do.call.do(.y, summarize, ...))

group.by.f = 
	function(.data, f, ..., recursive = FALSE) {
		f1 = to.fun1(protect(f), ...)
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
	function(mr.args)
		as.big.data(
			do.call(mapreduce, mr.args))

run = 
	function(.data) {
		pipe = .data
		if(
			all(
				sapply(
					pipe[qw(map, reduce, group.by)], 
					is.null))) { 
			if(!is.null(pipe$output)) {
				dfs.mv(pipe$input, pipe$output)
				as.big.data(pipe$output)}
			else {
				pipe$input}}
		else {
			mr.args = list()
			simple.args = qw(input, input.format, output, output.format)
			mr.args[simple.args] = pipe[simple.args]
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
			mrexec(mr.args)}}

output = 
	function(.data, path = NULL, format = NULL) {
		.data$output.format = format
		.data$output = path
		as.big.data(.data)}

setMethodS3(
	"as.big.data",
	"pipe",
	run)

ungroup = as.big.data.pipe

as.pipe = function(x, ...) UseMethod("as.pipe")

setMethodS3(
	"as.pipe",
	"big.data",
	function(x, format = NULL) 
		structure(
			strip.null.args(
				input = x,
				input.format = format),
			class = "pipe"))

setMethodS3(
	"as.pipe", 
	"data.frame", 
	Compose(as.big.data, as.pipe))

setMethodS3(
	"as.pipe", 
	"character", 
	Compose(as.big.data, as.pipe))

setMethodS3(
	"as.pipe", 
	"function", 
	Compose(as.big.data, as.pipe))

setMethodS3(
	"as.pipe",
	"list",
	Compose(as.big.data, as.pipe)) 

setMethodS3(
	"as.data.frame",
	"pipe",
	Compose(as.big.data,as.data.frame))

input  = as.pipe