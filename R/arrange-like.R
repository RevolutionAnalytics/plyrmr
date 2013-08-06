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


## this is still a mr call, not a pipe, need to integrate from a pre-existing design.

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
					keyval(v[, by, drop = FALSE], v)}
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

quantile.fun = 
	function(x) {
		mr.fun = 
			function(x) {
				midprobs  = 
					function(N) {
						probs = seq(0, 1, 1/N)
						(probs[-1] + probs[-length(probs)])/2}
				quantile(
					x,
					probs = midprobs(10^4))}
		do(
			group.by.f(
				do(x, mr.fun), 
				constant(1)), 
			mr.fun)}

setMethodS3("quantile",	"pipe", quantile.fun)

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
							quantile(y, ...)))))

extreme.k= 
	function(x, k, ..., decreasing) {
		this.order = Curry(order, decreasing = decreasing)
		mr.fun = 
			function(x)
				head(
					x[
						do.call(
							this.order,
							summarize(x, ...))], 
					k)
		do(
			group.by.f(
				do(x, mr.fun),
				constant(1)),
			mr.fun)}

top.k = function(x, k, ...) fwd.args(Curry(extreme.k, decreasing = TRUE))
bottom.k = function(x, k, ...) fwd.args(Curry(extreme.k, decreasing = FALSE))

moving.window = 
	function(x, index, window, f, R = rmr.options("keyval.length")) {
		partition = 
			function(x) {
				part = 
					function(index, shift)
						ceiling((index + shift*window)/R)
				index = unlist(x[, index])
				stopifnot(length(index) == nrow(x))
				partT = part(index, T)
				partF = part(index, F)
				mask = partT != partF
				cbind(x, partT, partF, mask)}
		map =
			function(x)
				rbind(x, x[x$mask, ])
		group = function(x)
			rbind(x$partT, x$partF[x$mask])		
		do(
			group.by.f(
				do(
					do(
						x, 
						partition), 
					map), 
				group), 
			f)}