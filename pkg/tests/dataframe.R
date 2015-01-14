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

test(
	function(df, x) {
		df = cbind(df, col.n  = suppressWarnings(cbind(x, df[,1]))[1:nrow(df),1])	
		numeric.cols = which(sapply(df, is.numeric ))
		filter.col = names(numeric.cols[1])
		cmp.df(
			where(df, eval(as.name(filter.col)) > 0),
      subset(df, eval(as.name(filter.col)) > 0))},
	list(rdata.frame, rnumeric))


#transmute

test(
	function(df) {
		col = as.name(sample(names(df), 1))
		cmp.df(
			transmute(df, eval(col)),
			plyrmr::select(df, eval(col)))},
	list(rdata.frame))

#bind.cols

test(
	function(df) {
		col = as.name(sample(names(df), 1))
		cmp.df(
			bind.cols(df, z = eval(col)),
			transform(df, z = eval(col)))},
	list(rdata.frame))

#sample

args = 	
	list(
		any = list(n = fun(rinteger(element = 5, size = constant(1)))),
		Bernoulli = list(p = fun(rdouble(element = runif, size = constant(1)))),
		hypergeometric = list(n = fun(rinteger(element = 5, size = constant(1)))))

for(method in names(args)) {
	method.args = args[[method]] 
	test(
		function(df, ...) {
			dotargs = list(...)
			if(is.element(method, c("any", "hypergeometric")))
				dotargs$n = min(dotargs$n, nrow(df))
			cmp.df(
				df,
				union(do.call(sample, c(list(df, method = method), dotargs)), df))},
		c(list(rdata.frame), method.args))}