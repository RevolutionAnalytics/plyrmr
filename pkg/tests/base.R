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

#sample

args = 	
	list(
		any = list(n = Curry(rinteger, len.lambda = 0)),
		Bernoulli = list(p = Curry(rdouble, lambda = 0, min =0, max = 1)),
		hypergeometric = list(n = Curry(rinteger, len.lambda = 0)))


for(method in names(args)) {
	method.args = args[[method]] 
	for(be in c("local", "hadoop")) {
		rmr.options(backend = be)
		unit.test(
			function(df, ...) 
				cmp.df(
					df,
					as.data.frame(union(do.call(sample, c(list(input(df), method = method), list(...))), input(df)))),
			c(list(rdata.frame), method.args),
			precondition = 
				function(df, ...) {
					if(is.element(method, c("any", "hypergeometric")))
						list(...)$n <= nrow(df)
					else TRUE})}}