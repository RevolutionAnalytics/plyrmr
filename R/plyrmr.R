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


subset.fun = function(x, ...) do(x, subset, ...)
setMethodS3("subset", "pipe", subset.fun)

setMethodS3("transform", "pipe", function(`_data`, ...) do(`_data`, transform, ...))
mutate =  function(.data, ...) UseMethod("mutate")
setMethodS3("mutate", "pipe", function(.data, ...) do(.data, mutate, ...))
setMethodS3("mutate", "default", plyr::mutate)

summarize.fun = function(.data, ...) do.call(do, c(list(.data, summarize), named_dots(...)))

summarize = function(.data, ...) UseMethod("summarize")
setMethodS3("summarize", "pipe", summarize.fun)
setMethodS3("summarize", "default", plyr::summarize)
select = function(.data, ...) UseMethod("select")
setMethodS3("select", "pipe", summarize.fun)

setMethodS3(
	"names",
	"pipe",
	function(x)
		as.data.frame(
			group.by.f(
				do(
					x, 
					function(.y) 
						data.frame(names = names(.y))), 
				function(.x) unique(.x$names), recursive=T)))

