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
		else cbind(key,val)}

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
		function(k, v) {
			v = valf(cbind.kv(k, v))
			k = keyf(v)
			keyval(k, v)}}

make.reduce.fun = 
	function(valf)
		function(k, v) {
			keyval(NULL, valf(cbind.kv(k, v)))}

to.fun1 = 
	function(f, ...)
		function(x)
			f(x, ...)

#pipes

is.pipe = 
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
	function(x, f, ...){
		f1 = to.fun1(f, ...)
		if(is.null(x$group.by))
			x$map = comp(x$map, f1)
		else
			x$reduce = comp(x$reduce, f1)
		x}

group.by = 
	function(x, ...){
		group.by.f(
			x, 
			function(y) 
				y[, as.character(c(...)), drop = FALSE])}

group.by.f = 
	function(x, f, ...) {
		f1 = to.fun1(f, ...)
		if(is.null(x$group.by)){
			x$group.by = f1
			x}
		else
			group.by.f(input(run(x)), f1)}

mr.options = 
	function(x, ...) {
		args = list(...)
		x[names(args)] = args
		x }

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
	function(x, path, format = NULL) {
		x$output.format = format
		x$output = path
		as.big.data(x)}

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