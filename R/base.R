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

setMethodS3(
	"subset", 
	"pipe", 
	function(x, ...) 
		do(x, subset, ...))

setMethodS3(
	"transform", 
	"pipe", 
	function(`_data`, ...)
		do(`_data`, transform, ...))


setMethodS3(
	"names",
	"pipe",
	function(x, ...)
		as.data.frame(
			do(
				group.by(
					do(
						x,  
						names),
					x,
					recursive = TRUE),
				unique))[['x']])

suppressWarnings(
	setMethodS3(
		"sample",
		"pipe",
		function(x, method = c("any", "Bernoulli", "hypergeometric"), ...) {
			method = match.arg(method)
			sample.curried = Curry(sample, method = method, ...)
			switch(
				method,
				any = 
					do(
						group.together(
							do(x, sample.curried),
							recursive = TRUE),
						sample.curried),
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
							list(...)[["n"]], 
							.priority), 
						function(x)
							x[,-ncol(x)]))}))

