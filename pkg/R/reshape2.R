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


magic.wand(melt, non.standard.args = FALSE)

dcast = function(data, formula, ...) UseMethod("dcast")

dcast.pipe = 
	function(data, formula, ...) {
		id.vars =  lapply(all.vars(as.list(formula)[[2]]), as.name)
		gapply(
			do.call(
				group,
				c(
					list(
						data), 
					id.vars)), 
			Curry(dcast, formula = formula),
			...)}

dcast.default =	reshape2::dcast