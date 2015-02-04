# Copyright 2014 Revolution Analytics
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

library(quickcheck)
library(plyrmr)

cmp.df = plyrmr:::cmp.df

#quantile.data.frame

test(
	function(df = rdata.frame(),  x = rnumeric()) {
		df = cbind(df, col.n  = suppressWarnings(cbind(x, df[,1]))[1:nrow(df),1])		
		cmp.df(
			data.frame(
				rmr2:::purge.nulls(
					lapply(
						seq_along(df), 
						function(i) 
							if(is.numeric(df[[i]])) 
								structure(
									list(quantile(df[[i]])),
									names = names(df)[[i]])))), 
			quantile(df))})

plyrmr:::all.backends({
	#merge
	test(
		function(A = rdata.frame(), B = rdata.frame(), x = rlogical()) {
			xa = x[1:min(length(x), nrow(A))]
			xb = x[1:min(length(x), nrow(B))]
			A = plyr::splat(cbind)(plyrmr:::fract.recycling(list(x = xa, A)))
			B = plyr::splat(cbind)(plyrmr:::fract.recycling(list(x = xb, B)))
			cmp.df(
				as.data.frame(
					merge(input(A), input(B), by = "x")),
				merge(A, B, by = "x"))})
	
	#quantile.pipe
	# at this size doesn't really test approximation
	test(
		function(df = rdata.frame(), x = rnumeric()) {
			df = cbind(df, col.n  = suppressWarnings(cbind(x, df[,1]))[1:nrow(df),1])		
			cmp.df(
				quantile(df),
				as.data.frame(
					quantile(input(df))))})
	
	
	#counts
	deraw = 
		function(df)
			data.frame(lapply(df, function(x) if(is.raw(x)) as.integer(x) else x))
	args.fun =
		function(df)
			sapply(
				1:3, 
				function(i) 
					Reduce(
						x = lapply(sample(names(df), rpois(1,3) + 1, replace = TRUE), as.name),
						function(l,r) call(":", l, r)))
	test(
		function(
			df = deraw(rdata.frame()),
			args = args.fun(df)) {
			A = do.call(count, c(list(df), args))
			B = as.data.frame(do.call(count, c(list(input(df)), args)))
			all(
				sapply(
					plyrmr:::split.cols(A),
					function(i) 
						cmp.df(
							A[, i, drop = FALSE], 
							B[, i, drop = FALSE])))})
	
	#top/bottom k
	
	lapply(
		list(
			list(top.k, tail), 
			list(bottom.k, head)),
		function(fun.pair)
			test(
				function(
					ply.fun = fun.pair[[1]],
					base.fun = fun.pair[[2]],
					df = deraw(rdata.frame()),
					cols = sample(names(df)))
					cmp.df(
						base.fun(df[plyr::splat(order)(df[, cols, drop = FALSE]),, drop = FALSE]),
						as.data.frame(
							plyr::splat(ply.fun)(
								c(
									list(input(df), .k = 6), 
									lapply(cols, as.symbol)))))))
	
	
	#test for moving window delayed until sematics more clear
	
	#unique
	rdata.frame.nonunique =
		function(){
			df = deraw(rdata.frame())
			df = df[sample(1:nrow(df), 2*nrow(df), replace = TRUE), , drop = FALSE]
			deraw(df)}
	
	test(
		function(df = rdata.frame.nonunique())
			cmp.df(
				unique(df),
				as.data.frame(unique(input(df)))))
	
	#union 
	gen = function(df) sample(x = 1:nrow(df), size = nrow(df)/2,  replace = FALSE)
	
	test(
		function(
			df = rdata.frame(nrow = 20),
			rows1 = gen(df), 
			rows2 = gen(df)){
			df = deraw(df)
			df1 = df[rows1, , drop = FALSE] 
			df2 = df[rows2, , drop = FALSE] 
			cmp.df(
				plyrmr::union(df1, df2),
				as.data.frame(plyrmr::union(input(df1), input(df2))))})
	
	#intersection 		
	test(
		function(
			df = rdata.frame(nrow = 20), 
			rows1 = gen(df), 
			rows2 = gen(df)){
			df = deraw(df)
			df1 = df[rows1, , drop = FALSE] 
			df2 = df[rows2, , drop = FALSE] 
			cmp.df(
				plyrmr::intersect(df1, df2),
				as.data.frame(plyrmr::intersect(input(df1), input(df2))))})})

