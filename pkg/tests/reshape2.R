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

library(plyrmr)
library(quickcheck)

rdata.frame.numeric.col =
	function() {
		df = rdata.frame(nrow = 10, ncol = 20)
		x = rnumeric(size = ~nrow(df))
		cbind(x,df)}

# numeric col is workaround for reshape2 bug https://github.com/hadley/reshape/issues/46

plyrmr:::all.backends({
	test(
		function(df = rdata.frame.numeric.col()) 
			plyrmr:::cmp.df(
				as.data.frame(melt(input(df))),
				melt(df)))
	
	test(
		function(df = rdata.frame()) {
			df = plyrmr:::deraw(cbind(id = 1:nrow(df), df))
			plyrmr:::cmp.df(
				dcast(
					melt(
						df, 
						id.vars = "id"), 
					id ~ variable),
				as.data.frame(
					dcast(
						melt(
							input(df), 
							id.vars = "id"), 
						id ~ variable)))})
})