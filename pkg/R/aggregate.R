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



fast.summary = 
	function(xx, type, ...) UseMethod("fast.summary")

.fast.summary.list = 
	function(xx, type) {
		if(length(xx) == 0) 
			xx
		else
			get(
				paste("fast", type, class(xx[[1]]), sep = "."),
				envir = environment(plyrmr::gapply))(xx)}

.fast.summary.default = 
	function(xx, type, index)
		.fast.summary.list(split(xx, index, drop = TRUE), type)

.fast.summary.data.frame = 
	function(xxx, type, index = data.frame(.gather = TRUE)) {
		if(!is.data.frame(index))
			index = data.frame(keycol = index)
		keycol = names(index)
		structure(
			as.data.frame(
				c(
					lapply(
						index,
						function(xx) .fast.summary.default(xx, "first", index)),
					lapply(
						xxx[, rmr2:::default(-match(keycol, names(xxx)), TRUE, is.na), drop = FALSE], 
						function(xx) .fast.summary.default(xx, type, index)))),
			keys = attributes(xxx)$keys)}

fast.summary.pipe = 
	function(x, type)
		gapply(
			x, 
			function(y) 
				.fast.summary.data.frame(
					y, 
					type = type, 
					index = 
						rmr2:::default(
							y[, attributes(y)$keys, drop = FALSE], 
							data.frame(.gather = TRUE), 
							function(x) ncol(x) == 0)))