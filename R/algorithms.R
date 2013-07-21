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

quantilefun = 
	function(x, ...) {
		mr.fun = 
			function(is.map)
				function(x) {
					midprobs  = 
						function(N) {
							probs = seq(0, 1, 1/N)
							(probs[-1] + probs[-length(probs)])/2}
					probs = {
						if(is.map)
							midprobs(ceiling(probs*length(vec)/rmr.options("keyval.length")))
						else
							midprobs(probs)}
					quantile(
						x,
						probs = probs)}
		do(
			group.by(
				do(x, mr.fun(T)), 
				constant(1)), 
			mr.fun(F))}

setMethodS3(
	"quantile",
	"data.frame",
	function(x, ...)
		data.frame(
			strip.nulls(
				lapply(
					x,
					function(y)
						if(is.numeric(y))
							quantile(y),
					...))))

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
