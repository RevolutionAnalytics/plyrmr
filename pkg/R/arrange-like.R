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
				function(k, v) 
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

quantile.pipe = 
	function(x, N = 10^5, ...) {
		midprobs  = 
			function(N) 
				seq(0, 1, length.out = N + 1)[-1] - 1/(2*N)
		map = 
			function(.x) {
				.x = select.numeric(.x)
				if(N >= nrow(.x))
					cbind(.x, .weight = 1)
				else {
					args = c(list(.x), list(...))
					args$weights = rep(1, nrow(.x))
					args$probs = midprobs(N)
					cbind(
						do.call(quantile, args),
						.weight = nrow(.x)/N)}}
		combine = 
			function(.x) {
				if(N >= nrow(.x))
					.x
				else {
					args = c(list(.x[, -ncol(.x), drop = FALSE]), list(...))
					args$weights = .x$.weight
					args$probs = midprobs(N) 
					cbind(
						do.call(quantile, args),
						.weight = sum(args$weights)/N)}}
		reduce = 
			function(.x) 
				quantile(
					.x[, -ncol(.x), drop = FALSE],
					...)
		gapply(gapply(gather(gapply(x, map)), mergeable(combine)), reduce)}

select.numeric = 
	function(x) 
		subset(x, select = sapply(x, is.numeric))

quantile.data.frame = 
	function(x, ...) {
		x = select.numeric(x)	
		l = 
			lapply(
				x,
				function(.y)
					wtd.quantile(.y, ...))
		qn = names(l[[1]])
		y = splat(data.frame)(l)
		rownames(y) = {
			if(any(duplicated(qn)))
				make.names(qn, unique = TRUE) 
			else qn}
		y}

count = function(x, ...) UseMethod("count")

count.default = 
	function(x)
		arrange(
			plyr::count(x),
			freq)


count.data.frame =
	function(x, ...) 
		splat(data.frame.fill)( 
			lapply(
				dots(...),
				function(df)
					plyr::count(x, df)))

merge.counts = 
	function(x, n) {
		last.col = function(x) x[, ncol(x)]
		`last.col<-` = function(x, value) {x[,ncol(x)] = value; x}
		split.cols = 
			function(x) {
				end.cols = grep(names(x), pattern="^freq")
				n = length(names(x))
				rev(
					split(
						1:n, 
						apply(outer(X = 1:n, Y = end.cols, `<=`), 1, sum)))}
		merge.one =
			function(x)
				ddply(
					x, 
					1:(ncol(x)-1), 
					function(x)
						structure(
							sum(last.col(x)),
							names = names(x)[ncol(x)]))		
		prune = 
			function(x, n) {
				x = x[order(x[, ncol(x)], decreasing = TRUE, na.last = NA), ]
				if(is.null(n) || nrow(x) <= n) x
				else {
					last.col(x) = last.col(x)- last.col(x)[n+1]
					x[last.col(x) > 0, ]}}
		splat(data.frame.fill) (
			lapply(
				split.cols(x),
				function(i) prune(merge.one(x[, i]), n)))}

count.pipe = 
	function(x, ..., n = Inf)
		gapply(
			gather(
				gapply(
					x,
					count,
					...)),
			mergeable(Curry(merge.counts, n = n)))

extreme.k= 
	function(.x, ..., .k , .decreasing, .envir = parent.frame()) {
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
		gapply(
			gather(
				gapply(.x, mr.fun)),
			mergeable(mr.fun))}

top.k = 
	function(.x, ..., .k = 1, .envir = parent.frame()) {
		force(.envir)
		extreme.k(.x, .k = .k, ..., .decreasing = TRUE, .envir = .envir)}

bottom.k = 
	function(.x, ..., .k = 1, .envir = parent.frame()) {
		force(.envir)
		extreme.k(.x, .k = .k, ..., .decreasing = FALSE, .envir = .envir)}

moving.window = 
	function(x, index, window, R = 10^4) {
		stopifnot(R >= window)
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

union = function(x, y) UseMethod("union")
union.default = base::union
union.pipe = 
	union.data.frame = 
	function(x, y) unique(rbind(x, y))

intersect = function(x, y) UseMethod("intersect")
intersect.default = base::intersect
intersect.data.frame = 
	intersect.pipe = 
	function(x, y)
		unique(merge(x, y))
