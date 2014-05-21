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

library(plyr)
library(quickcheck)
library(plyrmr)

cmp.df = plyrmr:::cmp.df
skip.spark = plyrmr:::skip.spark

#quantile.cols.data.frame

unit.test(
	function(df)
		cmp.df(
			data.frame(
				rmr2:::purge.nulls(
					lapply(
						df, 
						function(x) 
							if(is.numeric(x)) 
								quantile(x)))), 
			quantile.cols(df)),
	list(rdata.frame),
	precondition = function(x) sum(sapply(x, is.numeric)) > 0)

plyrmr:::all.backends({
	#merge
	skip.spark(
		unit.test(
			function(A, B, x) {
				xa = x[1:min(length(x), nrow(A))]
				xb = x[1:min(length(x), nrow(B))]
				A = splat(cbind)(plyrmr:::fract.recycling(list(x = xa, A)))
				B = splat(cbind)(plyrmr:::fract.recycling(list(x = xb, B)))
				cmp.df(
					as.data.frame(
						merge(input(A), input(B), by = "x")),
					merge(A, B, by = "x"))},
			list(rdata.frame, rdata.frame, rlogical)))
	
	#quantile.cols.pipe
	# at this size doesn't really test approximation
	unit.test(
		function(df)
			cmp.df(
				quantile.cols(df),
				as.data.frame(
					quantile.cols(input(df)))),
		list(rdata.frame),
		precondition = function(x) sum(sapply(x, is.numeric)) > 0)
	
	#counts
	
	unit.test(
		function(df){
			A = count.cols(df)
			B = as.data.frame(count.cols(input(df)))
			all(
				sapply(
					1:((max(ncol(A), ncol(B)))/2),
					function(i){
						i = 2*i
						cmp.df(
							A[,(i - 1):i],
							B[,(i - 1):i])}))},
		list(rdata.frame))
	
	#top/bottom k
	
	unit.test(
		function(df){
			cols = sample(names(df))
			cmp.df(
				head(df[splat(order)(df[, cols]),]),
				as.data.frame(
					splat(bottom.k)(
						c(
							list(input(df), .k = 6), 
							lapply(cols, as.symbol)))))},
		list(rdata.frame))
	
	unit.test(
		function(df){
			cols = sample(names(df))
			cmp.df(
				tail(df[splat(order)(df[, cols]),]),
				as.data.frame(
					splat(top.k)(
						c(
							list(input(df), .k = 6), 
							lapply(cols, as.symbol)))))},
		list(rdata.frame))
	
	#test for moving window delayed until sematics more clear
	
	#unique
	
	unit.test(
		function(df){
			df = df[sample(1:nrow(df), 2*nrow(df), replace = TRUE), , drop = FALSE]
			cmp.df(
				unique(df),
				as.data.frame(unique(input(df))))},
		list(rdata.frame))
	
	#union 
	
	skip.spark(
		unit.test(
			function(df){
				df1 = df[sample(1:nrow(df), floor(nrow(df)/2)), , drop = FALSE] 
				df2 = df[sample(1:nrow(df), floor(nrow(df)/2)), , drop = FALSE] 
				cmp.df(
					union(df1, df2),
					as.data.frame(union(input(df1), input(df2))))},
			list(rdata.frame)))
	
	#intersection 
	
	skip.spark(
		unit.test(
			function(df){
				df1 = df[sample(1:nrow(df), floor(nrow(df)/2)), , drop = FALSE] 
				df2 = df[sample(1:nrow(df), floor(nrow(df)/2)), , drop = FALSE] 
				cmp.df(
					intersect(df1, df2),
					as.data.frame(intersect(input(df1), input(df2))))},
			list(rdata.frame)))
})