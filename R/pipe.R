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

# of perl fame
qw = function(...) as.character(match.call())[-1]

# data manip
cbind.kv = 
	function(key, val, key.names = F) {
		if(is.null(key)) val
		else {
			if(key.names)
				names(key) = paste(names(key), "plyrmr.keys", sep = ".")
			as.data.frame(cbind(key,val))}}

# function manip
comp = 
	function(...) {
		funs = list(...)
		funs = funs[!sapply(funs, is.null)]
		do.call(Compose, funs)}

constant = 
	function(x)
		function(...) x

make.map.fun = 
	function(keyf, valf) {
		if(is.null(keyf)) 
			keyf = keyf1 = constant(NULL)
		else
			keyf1 = 	{
				function(k)
					rowSums(
						apply(k,2,cksum))%%100} 
		function(k, v) {
			v = valf(cbind.kv(k, v))
			k = keyf(v)
			keyval(keyf1(k), cbind.kv(k, v, T))}}

make.reduce.fun = 
	function(valf)
		function(k, v) {
			key.names = grep(names(v), pattern =  "plyrmr.keys", value = T)
			v = ddply(v, key.names, valf)
			keyval(NULL, v)}

to.fun1 = 
	function(f, ...)
		function(x)
			f(x, ...)

#pipes

is.pipe = 
	function(x)
		class(x) == "pipe"

setMethodS3(
	"as.pipe",
	"big.data",
	function(x, format = NULL) 
		structure(
		  strip.nulls.list(
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
	function(x)
		as.data.frame(as.big.data(x)))

input  = as.pipe

options = 
	function(x, ...) {
		args = list(...)
		x 
	}

do = 
	function(x, f, ...){
		f1 = to.fun1(f, ...)
		if(is.null(x$group.by))
			x$map = comp(f1, x$map)
		else
			x$reduce = comp(f1, x$reduce)
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
			group.by.f(to.pipe(run(x)), f1)}

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
			same.names = qw(input, input.format, output, output.format)
			mr.args[same.names] = pipe[same.names]
			mr.args = mr.args[!sapply(mr.args, is.null)]
			mr.args$map = 
				make.map.fun(
					keyf = pipe$group.by, 
					valf = pipe$map)
			if(!is.null(pipe$reduce))
				mr.args$reduce =
				make.reduce.fun(valf = pipe$reduce)
			as.big.data(
				do.call(mapreduce, mr.args))}}

setMethodS3(
	"as.big.data",
	"pipe",
	run)

output = 
	function(x, path, format = NULL) {
		x$output.format = format
		x$output = path
		run(x)}

as.data.frame.pipe = 
	function(x)
		as.data.frame(
			run(x))
