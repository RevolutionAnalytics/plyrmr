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

constant = 
	function(x)
		function(...) x

comp = 
	function(...) {
		funs = list(...)
		funs = funs[!sapply(funs, is.null)]
		do.call(Compose, funs)}

to.fun1 = 
	function(f, ...)
		function(x)
			f(x, ...)

make.map.fun = 
	function(keyf, valf) {
		if(is.null(keyf)) 
			keyf1 = constant(NULL)
		else
			keyf1 = 	{
				function(k)
					rowSums(
						apply(k,2,cksum))%%100} 
		function(k, v) {
			v = valf(cbind.kv(k, v))
			k = keyf(v)
			keyval(keyf1(k), cbind.kv(k, v))}}

make.reduce.fun = 
	function(valf)
		function(k, v)
			keyval(NULL, valf(v))
						 
cbind.kv = 
	function(key, val) {
		if(is.null(key)) val
		else as.data.frame(cbind(key, val))}

pipe.attr = "plyrmr.pipe"

is.pipe = 
	function(x)
		!is.null(
			attr(
				x = x, 
				which = pipe.attr, 
				exact = TRUE))

to.pipe = 
	function(x) {
		if(is.pipe(x)) x
		else {
			p = input(x)
			attr(p, pipe.attr) = TRUE
			p}}

input  = 
	function(input, input.format = "native") {
		p = list(
			input = input, 
			input.format = input.format)
		attr(p, pipe.attr) = TRUE
		p}

do = 
	function(x, f, ...){
		x = to.pipe(x)
		f1 = to.fun1(f, ...)
		if(is.null(x$group.by))
			x$map = comp(f1, x$map)
		else
			x$reduce = comp(f1, x$reduce)
		x}

group.by = 
	function(x, ...){
		x = to.pipe(x)
		group.by.f(
			x, 
			function(y) 
				y[, as.character(c(...)), drop = FALSE])}

group.by.f = 
	function(x, f, ...) {
		x = to.pipe(x)
		f1 = to.fun1(f, ...)
		if(is.null(x$group.by)){
			x$group.by = f1
			x}
		else
			group.by.f(to.pipe(run(x)), f1)}

run = 
	function(pipe) 
		mapreduce(
			input = pipe$input,
			input.format = pipe$input.format,
			map = 
				make.map.fun(
					keyf = {
						if(is.null(pipe$group.by))
							constant(NULL)
						else
							pipe$group.by}, 
					valf = pipe$map),
			reduce  = 
				if(!is.null(pipe$reduce))
					make.reduce.fun(valf = pipe$reduce))

output = 
	function(x, output, output.format) {
		x$output.format = output.format
		x$output = output
		run(x)}

from.dfs = 
	function(x)
		values(rmr2::from.dfs(run(x)))

to.dfs = rmr2::to.dfs

subset.mr = function(x, ...) do(x, subset, ...)
filter.mr = subset.mr
transform.mr = function(x, ...) do(x, transform, ...)
mutate.mr = function(x, ...) do(x, mutate, ...)
summarize.mr = function(x, ...) do(x, summarize, ...)
select.mr = summarize.mr

merge.mr = 
	function(
		x, 
		y, 
		by, 
		by.x = by, 
		by.y = by, 
		all = FALSE, 
		all.x = all, 
		all.y = all) {
		mk.map = 
			function(by)
				function(k, v) {
					v = cbind.kv(k, v)
					keyval(v[, by], v)}
		equijoin(
			left.input = x, 
			right.input = y, 
			map.left = mk.map(by.x), 
			map.right = mk.map(by.y), 
			outer = 
				switch(
					all.x + all.y, 
					"", 
					if(all.x) "left" else "right", 
					"full"))}

quantile.mr = 
	function(x, ..., probs = 1000, na.rm = FALSE, names = TRUE) {
		midprobs  = 
			function(N) {
				probs = seq(0, 1, 1/N)
				(probs[-1] + probs[-length(probs)])/2}
		mr.fun = 
			function(reduce = T)
				function(k, v) {
					v = cbind.kv(k, v)
					keyval(
						1, 
						quantile(
							v, 
							..., 
							probs = {
								if(!reduce)
									midprobs(ceiling(probs*length(v)/rmr.options("keyval.length")))
								else
									midprobs(probs)}, 
							na.rm = na.rm, 
							names = names, 
							type = 8))}
		from.dfs(
			mapreduce(
				x, 
				map = mr.fun(F), 
				reduce = mr.fun(T), 
				combine = mr.fun(F)))}

top.k.mr = 
	function(x, k, by, decreasing) {
		mr.fun = 
			function(k, v) {
				v = cbind.kv(k, v)
				keyval(
					1, 
					head(
						v[
							do.call(
								Curry(
									order, 
									decreasing = decreasing), 
								v[, c("cyl", "carb")]), ], 
						k))}
		from.dfs(
			mapreduce(
				x, 
				map = mr.fun, 
				reduce = mr.fun, 
				combine = T))}

moving.window.mr  = 
	function(x, index, window, fun, R = rmr.options("keyval.length"))
		mapreduce(
			input = x, 
			map = 
				function(k, v) {
					v = cbind.kv(k, v)
					partition  = 
						function(index, shift)
							ceiling((index + shift * window)/R)
					index = v[, index]
					parT = partition(index, T)
					parF = partition(index, F)
					mask = parT !=  parF
					c.keyval(
						keyval(parT, v), 
						keyval(parF[mask], v[mask,]))}, 
			reduce = 
				function(k, v)
					cbind(k, fun(v)))
