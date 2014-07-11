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

plyrmr:::all.backends({
	unit.test(
		function(df) 
			plyrmr:::cmp.df(
				as.data.frame(melt(input(df))),
				melt(df)),
		list(rdata.frame))
	
	unit.test(
		function(df) {
			df = cbind(id = 1:nrow(df), df)
			plyrmr:::cmp.df(
				df,
				as.data.frame(
					dcast(
						melt(
							input(df), 
							id.vars = "id"), 
						id ~ variable)))},
		list(rdata.frame))
})