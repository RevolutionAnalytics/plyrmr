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



names.pipe =
	function(x, ...)
		names(
			as.data.frame(
				sample(
					ungroup(x),  
					method = "any",
					n = 1)))

sample.pipe = 
	function(x, method = c("any", "Bernoulli", "hypergeometric"), ...) {
		method = match.arg(method)
		switch(
			method,
			any = 
				gapply(
					gather(
						gapply(x, sample.data.frame, method, ...)),
					mergeable(sample.data.frame), method, ...),
			Bernoulli = 
				gapply(x, sample.data.frame, method, ...),
			hypergeometric = 
				gapply(
					top.k(
						gapply(
							x, 
							function(x) 
								cbind(
									x, 
									.priority = runif(nrow(x)))), 
						.k = list(...)[["n"]], 
						.priority), 
					function(x)	x[,-ncol(x)]))}

dim.pipe = 
	function(x)
		transmute(
			gather(
				gapply(
					x, 
					function(x) data.frame(nrow = nrow(x), ncol = ncol(x)))),
			nrow = sum(nrow), 
			ncol = ncol[1],
			.mergeable = TRUE)

nrow = function(x) UseMethod("nrow")
nrow.default = base::nrow
nrow.pipe = function(x) select(dim.pipe(x), nrow)

ncol = function(x) UseMethod("ncol")
ncol.default = base::ncol
ncol.pipe = function(x) length(names(x))

