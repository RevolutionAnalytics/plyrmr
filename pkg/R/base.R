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

subset.pipe =
	function(x, ...) 
		do(x, subset, ...)

transform.pipe =  
	function(`_data`, ...)
		do(`_data`, transform, ...)

names.pipe =
	function(x, ...)
		as.data.frame(
			do(
				group(
					do(
						x,  
						names),
					x),
				mergeable(unique)))[['x']]

sample.pipe = 
	function(x, method = c("any", "Bernoulli", "hypergeometric"), ...) {
		method = match.arg(method)
		sample.curried = Curry(sample, method = method, ...)
		switch(
			method,
			any = 
				ungroup(
					do(
						gather(
							do(x, sample.curried)),
						mergeable(sample.curried))),
			Bernoulli = 
				do(x, sample.curried),
			hypergeometric = 
				do(
					top.k(
						do(
							x, 
							function(x) 
								cbind(
									x, 
									.priority = runif(nrow(x)))), 
						.k = list(...)[["n"]], 
						.priority), 
					function(x)	x[,-ncol(x)]))}

