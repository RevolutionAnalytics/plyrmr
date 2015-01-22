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
	function(df = rdata.frame(), x = rnumeric()) {
		df = cbind(df, col.n  = suppressWarnings(cbind(x, df[,1]))[1:nrow(df),1])	
		numeric.cols = which(sapply(df, is.numeric ))
		filter.col = names(numeric.cols[1])
		cmp.df(
			where(df, eval(as.name(filter.col)) > 0),
      subset(df, eval(as.name(filter.col)) > 0))})


#transmute

test(
	function(df = rdata.frame()) {
		col = as.name(sample(names(df), 1))
		cmp.df(
			transmute(df, eval(col)),
			plyrmr::select(df, eval(col)))})

#bind.cols

test(
	function(df = rdata.frame()) {
		col = as.name(sample(names(df), 1))
		cmp.df(
			bind.cols(df, z = eval(col)),
			transform(df, z = eval(col)))})

#sample

assert.sample.is.subset = 
	function(df, method, method.args)
		cmp.df(
			df,
			union(do.call(sample, c(list(df, method = method), method.args)), df))

test(
	function(df = rdata.frame(ncol = 10), n = rinteger(element = 5, size = ~1))
		assert.sample.is.subset(df, "any", list(n = min(n, nrow(df)))))

test(
	function(df = rdata.frame(ncol = 10), p = rdouble(element = runif, size = ~1))
		assert.sample.is.subset(df, "Bernoulli", list(p = p)))

test(
	function(df = rdata.frame(ncol = 10), n = rinteger(element = 5, size = ~1))
		assert.sample.is.subset(df, "hypergeometric", list(n = min(n, nrow(df)))))
