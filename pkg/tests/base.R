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

#sample

assert.sample.is.subset =
	function(df, method, method.args)
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
								method.args))),
					df)), 
			unique(df))

plyrmr:::all.backends({
	
	test(
		function(df = rdata.frame(ncol = 10), n = rinteger(element = 5, size = ~1))
			assert.sample.is.subset(df, "any", list(n = min(n, nrow(df)))))
	
	test(
		function(df = rdata.frame(ncol = 10), p = rdouble(element = runif, size = ~1))
			assert.sample.is.subset(df, "Bernoulli", list(p = p)))
	
	test(
		function(df = rdata.frame(ncol = 10), n = rinteger(element = 5, size = ~1))
			assert.sample.is.subset(df, "hypergeometric", list(n = min(n, nrow(df)))))
	
})