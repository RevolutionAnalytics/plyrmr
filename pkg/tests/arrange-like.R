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
	function(df,  x) {
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
			quantile(df))},
	list(rdata.frame, rnumeric))

#merge
plyrmr:::all.backends(
	skip = "spark", 
	test(
		function(A, B, x) {
			xa = x[1:min(length(x), nrow(A))]
			xb = x[1:min(length(x), nrow(B))]
			A = plyr::splat(cbind)(plyrmr:::fract.recycling(list(x = xa, A)))
			B = plyr::splat(cbind)(plyrmr:::fract.recycling(list(x = xb, B)))
			cmp.df(
				as.data.frame(
					merge(input(A), input(B), by = "x")),
				merge(A, B, by = "x"))},
		list(rdata.frame, rdata.frame, rlogical)))

#quantile.pipe
# at this size doesn't really test approximation
plyrmr:::all.backends({
	test(
		function(df, x) {
			df = cbind(df, col.n  = suppressWarnings(cbind(x, df[,1]))[1:nrow(df),1])		
			cmp.df(
				quantile(df),
				as.data.frame(
					quantile(input(df))))},
		list(rdata.frame, rnumeric))
	
	
	#counts
	deraw = 
		function(df)
			data.frame(lapply(df, function(x) if(is.raw(x)) as.integer(x) else x))
	test(
		function(df){
			df = deraw(df)
			args = 
				sapply(
					1:3, 
					function(i) 
						Reduce(
							x = lapply(sample(names(df), rpois(1,3) + 1, replace = TRUE), as.name),
							function(l,r) call(":", l, r)))
			test(
				function(df, args) {
					A = do.call(count, c(list(df), args))
					B = as.data.frame(do.call(count, c(list(input(df)), args)))
					all(
						sapply(
							plyrmr:::split.cols(A),
							function(i) 
								cmp.df(
									A[, i, drop = FALSE], 
									B[, i, drop = FALSE])))},
				list(constant(df), constant(args)),
				sample.size = 1)},
		list(rdata.frame))
	
	#top/bottom k
	
	test(
		function(df){
			df = deraw(df)
			cols = sample(names(df))
			test(
				function(df, cols)
					cmp.df(
						head(df[plyr::splat(order)(df[, cols, drop = FALSE]),, drop = FALSE]),
						as.data.frame(
							plyr::splat(bottom.k)(
								c(
									list(input(df), .k = 6), 
									lapply(cols, as.symbol))))),
				list(constant(df), constant(cols)),
				sample.size = 1)},
		list(rdata.frame))
	
	test(
		function(df){
			df = deraw(df)
			cols = sample(names(df))
			test(
				function(df, cols)
					cmp.df(
						tail(df[plyr::splat(order)(df[, cols, drop = FALSE]),, drop = FALSE]),
						as.data.frame(
							plyr::splat(top.k)(
								c(
									list(input(df), .k = 6), 
									lapply(cols, as.symbol))))),
				list(constant(df), constant(cols)),
				sample.size = 1)},
		list(rdata.frame))
	
	#test for moving window delayed until sematics more clear
	
	#unique
	
	test(
		function(df){
			df = deraw(df)
			df = df[sample(1:nrow(df), 2*nrow(df), replace = TRUE), , drop = FALSE]
			test(
				function(df)
					cmp.df(
						unique(df),
						as.data.frame(unique(input(df)))),
				list(constant(df)),
				sample.size = 1)},
		list(rdata.frame))})

plyrmr:::all.backends(
	skip = "spark", {
		#union 
		test(
			function(df){
				df = deraw(df)
				half = floor(nrow(df)/2)
				gen = fun(sample(x = 1:nrow(df), size = half,  replace = FALSE))
				test(
					function(df, rows1, rows2) {
						df1 = df[rows1, , drop = FALSE] 
						df2 = df[rows2, , drop = FALSE] 
						cmp.df(
							plyrmr::union(df1, df2),
							as.data.frame(plyrmr::union(input(df1), input(df2))))},
					list(constant(df), gen, gen),
					sample.size = 1)},
			list(rdata.frame))
		
		#intersection 		
		test(
			function(df){
				df = deraw(df)
				half = floor(nrow(df)/2)
				gen = fun(sample(x = 1:nrow(df), size = half,  replace = FALSE))
				test(
					function(df, rows1, rows2) {
						df1 = df[rows1, , drop = FALSE] 
						df2 = df[rows2, , drop = FALSE] 
						cmp.df(
							plyrmr::intersect(df1, df2),
							as.data.frame(plyrmr::intersect(input(df1), input(df2))))},
					list(constant(df), gen, gen),
					sample.size = 1)},
			list(rdata.frame))})
