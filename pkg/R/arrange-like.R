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
		map =
			function(by.what)
				function(k,v) 
					keyval(
						if(is.null(by.what)) v else	v[, by.what], 
						v)
		map.x = map(by.x)
		map.y =	map(by.y)
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

quantile.cols = function(x, ...) UseMethod("quantile.cols")

quantile.cols.pipe = 
	function(x, ...) {
		N = max(10, rmr.options("keyval.length")/10)
		midprobs  = 
			function() {
				probs = seq(0, 1, 1/N)
				(probs[-1] + probs[-length(probs)])/2}
		map = 
			function(.x) {
				.x = select.numeric(.x)
				args = c(list(.x), list(...))
				args$weights = rep(1, nrow(.x))
				args$probs = midprobs()
				cbind(
					do.call(quantile.cols, args), 
					.weight = nrow(.x)/N)}
		combine = 
			function(.x) {
				args = c(list(.x[,-ncol(.x)]), list(...))
				args$weights = .x$.weight
				args$probs = midprobs() 
				cbind(
					do.call(quantile.cols, args), 
					.weight = sum(args$weights)/N)}
		reduce = 
			function(.x) 
				quantile.cols(
					as.data.frame(.x)[,-ncol(.x)], 
					...)
		gapply(gapply(gather(gapply(x, map)), mergeable(combine)), reduce)}

select.numeric = 
	function(x) 
		subset(x, select = sapply(x, is.numeric))

quantile.cols.data.frame = 
	function(x, ...) {
		x = select.numeric(x)	
		l = 
			lapply(
				x,
				function(.y)
					wtd.quantile(.y, ...))
		qn = names(l[[1]])
		y = splat(data.frame)(l)
		rownames(y) = qn
		y}

count.cols = function(x, ...) UseMethod("count.cols")

count.cols.default = 
	function(x)
		arrange(
			count(data.frame(x=x)), 
			freq)


count.cols.data.frame =
	function(x) 
		splat(data.frame.fill)( 
			lapply(
				x,
				count.cols))

merge.counts = 
	function(x, n) {
		select.cols = 
			function(x)
				grep(names(x),pattern=".freq$")
		merge.one =
			function(x)
				ddply(x, 1, function(x) {y = sum(x[, 2]); names(y) = names(x)[2]; y})		
		prune = 
			function(x, n) {
				x = x[order(x[,2], decreasing = TRUE, na.last = NA),]
				if(is.null(n) || nrow(x) <= n) x
				else {
					x[,2] = x[,2] - x[n+1, 2]
					x[x[,2] > 0, ]}}
		splat(data.frame.fill) (
			lapply(
				select.cols(x),
				function(i) prune(merge.one(x[,c(i - 1, i)]), n)))}

count.cols.pipe = 
	function(x, n = Inf)
		gapply(
			gather(
				gapply(
					x,
					count.cols)),
			mergeable(Curry(merge.counts, n = n)))

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
							transmute(.x, ..., .envir = .envir)),
						,
						drop = FALSE], 
					.k)
		ungroup(
			gapply(
				gather(
					gapply(.x, mr.fun)),
				mergeable(mr.fun)))}

top.k = 
	function(.x, .k = 1, ...,  .envir = parent.frame()) {
		force(.envir)
		extreme.k(.x, .k = .k, ..., .decreasing = TRUE, .envir = .envir)}

bottom.k = 
	function(.x, .k = 1, ..., .envir = parent.frame()) {
		force(.envir)
		extreme.k(.x, .k = .k, ..., .decreasing = FALSE, .envir = .envir)}

moving.window = 
	function(x, index, window, R) {
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
			gapply(
				x, 
				partition), 
			.part)}

unique.pipe = 
	function(x, incomparables = FALSE, fromLast = FALSE, ...) {
		uniquec = 
			mergeable(
				Curry(unique, incomparables = incomparables, fromLast = fromLast))
		gapply(
			group.f(
				gapply(x, uniquec),
				identity),
			uniquec)}

rbind = function(...) UseMethod("rbind")
rbind.default = base::rbind
rbind.pipe = function(...)
	gapply(input(lapply(list(...), output)), identity)

union = function(x,y) UseMethod("union")
union.default = base::union
union.pipe = 
	union.data.frame = 
	function(x, y) unique(rbind(x,y))

intersect = function(x,y) UseMethod("intersect")
intersect.default = base::intersect
intersect.data.frame = 
	intersect.pipe = 
	function(x,y)
		unique(merge(x,y))
