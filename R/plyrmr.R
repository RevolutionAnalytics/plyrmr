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


subsetfun = function(x, ...) do(x, subset, ...)
setMethodS3("subset", "pipe", subsetfun)
setMethodS3("filter", "pipe", subsetfun)
setMethodS3("transform", "pipe", function(x, ...) do(x, transform, ...))
setMethodS3("mutate", "pipe", function(x, ...) do(x, mutate, ...))
summarizefun = function(x, ...) do(x, summarize, ...)
setMethodS3("summarize", "pipe", summarizefun)
setMethodS3("select", "pipe", summarizefun)

## below are ordinary jobs, not pipes, need to integrate from a pre-existing design.

merge.pipe = 
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

quantile.pipe = 
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

top.k.pipe = 
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

moving.window.pipe  = 
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
