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

cmp.df = plyrmr:::cmp.df

plyrmr:::all.backends({
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
					unique(
						rbind(
							as.data.frame(				
								do.call(
									sample, 
									c(
										list(
											input(df), 
											method = method), 
										dotargs))),
							df)), 
					unique(df))},
			c(list(fun(rdata.frame(ncol = 10))), method.args))}})