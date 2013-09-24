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

merge.pipe = 
	function(
		x, 
		y, 
		by = NULL, 
		by.x = by, 
		by.y = by, 
		all = FALSE, 
		all.x = all, 
		all.y = all, 
		suffixes = c(".x", ".y"), 
		incomparables = NULL,
		...) {
		stopifnot((all.x && all.y) == all)
		ox = output(x)
		oy = output(y)
		stopifnot(ox$format == oy$format)
		map.x =	
			function(k,v) 
				keyval(
					if(is.null(by.x)) v else	v[, by.x], 
					v)
		map.y =	
			function(k,v) 
				keyval(
					if(is.null(by.y)) v else	v[, by.y], 
					v)
		input(
			equijoin(
				ox$data, 
				oy$data,
				input.format = ox$format,
				outer = 
					list(NULL, "full", "left", "right")[c((!all.x && !all.y), all, all.x, all.y)][[1]],
				map.left = map.x,
				map.right = map.y,
				reduce = 
					function(k, x, y) {
						by = {
							if(is.null(by)) 
								intersect(names(x), names(y))
							else by}
						by.x = {
							if(is.null(by.x)) by
							else by.x} 
						by.y = {
							if(is.null(by.y)) by
							else by.y}
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
							incomparables = incomparables)
					}))}

quantile.pipe = 
	function(x, ...) {
		qfun = 
			function(.x) {
				midprobs  = 
					function(N) {
						probs = seq(0, 1, 1/N)
						(probs[-1] + probs[-length(probs)])/2}
				args = c(list(.x), list(...))
				args$probs = midprobs(rmr.options("keyval.length")) 
				do.call(quantile, args)}
		reduce = 
			function(.x) {
				if(is.root()){
					quantile(.x, ...)}
				else
					qfun(.x)}
		do(group.together(do(x, qfun)), reduce)}


quantile.data.frame = 
	function(x, ...) {
		y = 
			data.frame(
				strip.nulls(
					lapply(
						x,
						function(.y)
							if(is.numeric(.y))
								quantile(.y, ...))))
		y}

count.cols = function(x, ...) UseMethod("count.cols")

count.cols.default = 
	function(x)
		arrange(
			as.data.frame(table(x)), 
			Freq)

count.cols.data.frame =
	function(x) {
		y = 
			splat(data.frame.fill)( 
				strip.nulls(
					splat(c)(
						lapply(
							x,
							function(z)
								if(!is.numeric(z))
									count.cols(z)))))
		y}

merge.counts = 
	function(x, n) {
		merge.one =
			function(x)
				ddply(x, 1, function(x) {y = sum(x[, 2]); names(y) = names(x)[2]; y})		
		prune = 
			function(x, n) {
				if(is.null(n) || nrow(x) <= n) x
				else {
					x = x[order(x[,2], decreasing = TRUE),]
					x[,2] = x[,2] - x[n+1, 2]
					x[x[,2] > 0, ]}}
		y = 
			splat(data.frame.fill) (
				splat(c)(
					lapply(
						1:((ncol(x) - 1)/2),
						function(i) prune(merge.one(x[,c(2*i, 2*i + 1)]), n))))
		y}

count.cols.pipe = 
	function(x, n)
		do(
			group.together(
				do(
					x,
					count.cols)),
			Curry(merge.counts, n = n))

extreme.k= 
	function(.x, .k , ...,  .decreasing, .envir = parent.frame()) {
		force(.envir)
		this.order = Curry(order, decreasing = .decreasing)
		mr.fun = 
			function(.x) 
				head(
					.x[
						do.call(
							this.order,
							select(.x, ..., .envir = .envir)),
						,
						drop = FALSE], 
					.k)
		ungroup(
			do(
				group.together(
					do(.x, mr.fun)),
				mr.fun))}

top.k = 
	function(.x, .k = 1, ...,  .envir = parent.frame()) {
		force(.envir)
		extreme.k(.x, .k = .k, ..., .decreasing = TRUE, .envir = .envir)}

bottom.k = 
	function(.x, .k = 1, ..., .envir = parent.frame()) {
		force(.envir)
		extreme.k(.x, .k = .k, ..., .decreasing = FALSE, .envir = .envir)}

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
		group(
			do(
				x, 
				partition), 
			.part)}

unique.pipe = 
	function(x, incomparables = FALSE, fromLast = FALSE, ...) {
		uniquec = Curry(unique, incomparables = incomparables, fromLast = fromLast)
		do(
			group.f(
				do(x, uniquec),
				identity,
				.recursive = TRUE),
			uniquec)}

rbind = function(...) UseMethod("rbind")
rbind.default = base::rbind
rbind.pipe = function(...)
	do(input(lapply(list(...), output)), identity)

union = function(x,y) UseMethod("union")
union.default = base::union
union.pipe = 
	union.data.frame = 
	function(x, y) unique(rbind(x,y))

intersect = function(x,y) UseMethod("intersect")
intersect.default = base::intersect
intersect.data.frame = 
	intersect.pipe = 
	function(x, incomparables = FALSE, fromLast = FALSE, ...) {
		uniquec = Curry(unique, incomparables = incomparables, fromLast = fromLast)
		do(
			group.f(
				x,
				identity,
				.recursive = TRUE),
			function(x) if(nrow(x) > 1) x[1,] else NULL)}
