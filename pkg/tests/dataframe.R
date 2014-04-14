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

library(plyrmr)
library(quickcheck)
library(functional)

cmp.df = plyrmr:::cmp.df

#where

unit.test(
	function(df) {
		numeric.cols = which(sapply(df, is.numeric ))
		filter.col = numeric.cols[1]
		filter = parse(text=paste(filter.col, ">0"))
		cmp.df(
			where(df, filter),
      subset(df, eval(filter, envir = list2env(df))))},
	list(rdata.frame),
	precondition =
		function(df) 
			any(sapply(df, is.numeric)))


#transmute

unit.test(
	function(df) {
		col = as.name(sample(names(df), 1))
		cmp.df(
			transmute(df, col),
		  select(df, col))},
	list(rdata.frame))

#bind.cols

unit.test(
	function(df) {
		col = as.name(sample(names(df), 1))
		cmp.df(
			bind.cols(df, z = col),
			transform(df, z = eval(col)))},
	list(rdata.frame))

#sample

args = 	
	list(
		any = list(n = Curry(rinteger, len.lambda = 0)),
		Bernoulli = list(p = Curry(rdouble, lambda = 0, min =0, max = 1)),
		hypergeometric = list(n = Curry(rinteger, len.lambda = 0)))

for(method in c("any", "Bernoulli", "hypergeometric")) {
	method.args = args[[method]] 
	unit.test(
		function(df, ...) 
			cmp.df(
				df,
				union(do.call(sample, c(list(df, method = method), list(...))), df)),
		c(list(rdata.frame), method.args),
	precondition = 
		function(df, ...) {
			if(is.element(method, c("any", "hypergeometric")))
				list(...)$n <= nrow(df)
			else TRUE})}