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
		all.y = all, 
		suffixes = c(".x", ".y"), 
		incomparables,
		...) {
		stopifnot((all.x && all.y) == all)
		map.x =	function(k,v) keyval(v[, by.x], v)
		map.y =	function(k,v) keyval(v[, by.y], v)
		input(
			equijoin(
				output(x), 
				output(y),
				outer = 
					list(NULL, "full", "left", "right")[c((!all.x && !all.y), all, all.x, all.y)][[1]],
				map.left = map.x,
				map.right = map.y,
				reduce = 
					function(k, x, y) {
						merge(
							x, 
							y, 
							by = by, 
							by.x = by.x, 
							by.y = by.y, 
							all = all, 
							all.x = all.x, 
							all.y = all.y,
							suffixes = suffixes,
							incomparables)
					}))}

quantile.pipe = 
	function(x, ...) {
		qfun = 
			function(.x) {
				midprobs  = 
					function(N) {
						probs = seq(0, 1, 1/N)
						(probs[-1] + probs[-length(probs)])/2}
				quantile(
					.x,
					probs = midprobs(10^4))}
		reduce = 
			function(.x) {
				if(is.root(.x)){
					rmr.str(
					quantile(.x, ...))[,-1]}
				else
					qfun(.x)}
		do(group.together(do(x, qfun)), reduce)}


quantile.data.frame = 
	function(x, ...)
		data.frame(
			strip.nulls(
				lapply(
					x,
					function(.y)
						if(is.numeric(.y))
							quantile(.y, ...))))

extreme.k= 
	function(x, ..., k, decreasing, envir = parent.frame()) {
		force(envir)
		this.order = Curry(order, decreasing = decreasing)
		mr.fun = 
			function(.x) 
				head(
					.x[
						do.call(
							this.order,
							select(.x, ..., .envir = envir)),
						,
						 drop = FALSE], 
					k)
		do(
			group.together(
				do(x, mr.fun)),
			mr.fun)}

top.k = 
	function(x, ..., k = 1, envir = parent.frame()) {
		force(envir)
		extreme.k(x, ..., k = k, decreasing = TRUE, envir = envir)}

bottom.k = 
	function(x, ..., k = 1, envir = parent.frame()) {
		force(envir)
		extreme.k(x, ..., k = k, decreasing = FALSE, envir = envir)}

moving.window = 
	function(x, index, window, R = rmr.options("keyval.length")) {
		partition = 
			function(x) {
				part = 
					function(index, shift)
						ceiling((index + shift*(window - 1))/R)
				index = unlist(x[, index])
				stopifnot(length(index) == nrow(x))
				partT = part(index, T)
				partF = part(index, F)
				unique(
					cbind(
						.part = c(partT, partF), 
						rbind(x, x)))}
		do(
			group(
				do(
					x, 
					partition), 
				.part), 
			identity)}