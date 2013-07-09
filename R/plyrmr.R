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


cbind.kv = 
	function(k, v) {
		if(is.null(k)) v
		else cbind(k,v)}

mk.mr.fun = 
	function(f)
		function(.data, ...) 
			mapreduce(
				.data,
				map = 
					function(k,v) {
						v = cbind.kv(k, v)
						f(v, ...)})

transform.mr = mk.mr.fun(transform)

subset.mr = mk.mr.fun(subset.mr)
filter.mr = subset.mr

mutate.mr = mk.mr.fun(mutate)
summarize.mr = mk.mr.fun(summarize)
select.mr = summarize.mr


ddply.mr = 
	function(.data,.variables, .fun, .null)
		mapreduce(
			.data, 
			map = 
				function(k,v) {
					v = cbind.kv(k, v)
					keyval(summarize(v, .variables), v)},
			reduce = 
				function(k, vv)
					ddply(vv, .variables, .fun))

save.mr =
	function(big.data, path)
	{ 
		#backend indepenendent mv here
	}

from.dfs = function(...) values(rmr2::from.dfs(...))
