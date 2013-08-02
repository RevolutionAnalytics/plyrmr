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

# data manip
cbind.kv = 
	function(key, val) {
		if(is.null(key)) val
		else {
			key = as.data.frame(key)
			colnames(key) = 
				make.names(
					paste("key", colnames(key), sep = "."),
					unique = TRUE)			
			data.frame(key = key, val)}}

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
			v = valf(cbind.kv(k, v))
			k = keyf(v)
			keyval(k, v)}}

make.reduce.fun = 
	function(valf) {
		if(is.null(valf)) 
			valf = identity
		function(k, v) {	
			keyval(NULL, valf(cbind.kv(k, v)))}}

to.fun1 = 
	function(f, ...)
		function(x)
			f(x, ...)

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
		cat(as.character(x))
		invisible(x)})

do = 
	function(.data, f, ...){
		f1 = to.fun1(f, ...)
		if(is.null(.data$group.by))
			.data$map = comp(.data$map, f1)
		else
			.data$reduce = comp(.data$reduce, f1)
		.data}

group.by = 
	function(.data, ...){
		group.by.f(
			.data, 
			function(y) 
				y[, as.character(c(...)), drop = FALSE])}

group.by.f = 
	function(.data, f, ...) {
		f1 = to.fun1(f, ...)
		if(is.null(.data$group.by)){
			.data$group.by = f1
			.data}
		else
			group.by.f(input(run(.data)), f1)}

group.together = Curry(group.by.f, f = constant(1))

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
	function(pipe) {
		if(
			all(
				sapply(
					pipe[qw(map, reduce, group.by)], 
					is.null)))
			pipe$input
		else {
			mr.args = list()
			simple.args = qw(input, input.format, output, output.format)
			mr.args[simple.args] = pipe[simple.args]
			mr.args = strip.nulls(mr.args)
			mr.args$map = 
				make.map.fun(
					keyf = pipe$group.by, 
					valf = pipe$map)
			if(!is.null(pipe$reduce))
				mr.args$reduce =
				make.reduce.fun(valf = pipe$reduce)
			mrexec(mr.args)}}

output = 
	function(.data, path, format = NULL) {
		.data$output.format = format
		.data$output = path
		as.big.data(.data)}

setMethodS3(
	"as.big.data",
	"pipe",
	run)

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
	"as.data.frame",
	"pipe",
	Compose(as.big.data,as.data.frame))

input  = as.pipe