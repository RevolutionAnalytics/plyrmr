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

as.big.data_cf =
	function(x)
		structure(x, class = "big.data")

setMethodS3(
	"as.big.data", 
	"function",	
	as.big.data_cf)

setMethodS3(
	"as.big.data", 
	"character",	
	as.big.data_cf)

setMethodS3(
	"as.big.data",
	"data.frame", 
	function(x, format = NULL)
		as.big.data(
			suppressWarnings(
				fwd.args(
					to.dfs,
					c(
						x = "kv",
						path = "output")))))

setMethodS3(
	"as.data.frame",
	"big.data", 
	function(x, format = NULL)
		values(
				fwd.args(
					from.dfs,
					c(
						x = "input",
						path = "output"))))
