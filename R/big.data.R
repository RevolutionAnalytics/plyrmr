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


is.big.data = 
	function(x)
		inherits(x, "big.data")

as.character.big.data = 
	function(x, ...) {
		if(is.character(x$data)) as.character(unclass(x))
		else "Temporary file"}

print.big.data = 
	function(x, ...) {
		print(as.character(x))
		invisible(x)}

as.big.data = function(x, ...) UseMethod("as.big.data")

as.big.data.function = 
as.big.data.character =
	function(x, format = "native", ...)
		structure(
			list(
				data = x, 
				format = format),
			class = "big.data")

as.big.data.data.frame = 
	function(x, ...)
		as.big.data(
			suppressWarnings(
				to.dfs(kv = x)),
			format = "native")

as.data.frame.big.data = 
	function(x, ...)
		values(
			from.dfs(
				input = x$data, 
				format = x$format))

as.big.data.list = 
	function(x, ...) {
		data.list =	lapply(x, as.big.data)
		formats = lapply(data.list, function(x) x$format)
		format = unique(formats)
		stopifnot(length(format) == 1)
		as.big.data_cf(
			lapply(
				data.list, 
				function(x) x$data), 
			format[[1]])}

as.big.data.big.data = identity