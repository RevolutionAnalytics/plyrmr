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
library(dplyr)

cmp.df = plyrmr:::cmp.df

for(be in c("local", "hadoop")) {
	rmr.options(backend = be)
	
	#gapply
	
	unit.test(
		function(df)
			cmp.df(
				df,
				as.data.frame(gapply(input(df), identity))),
		list(rdata.frame))
	
	#group
	unit.test(
		function(df)
			cmp.df(
				summarize(group_by(df, col.1), mean(col.2)),
				as.data.frame(transmute(group(input(df), col.1), mean(as.numeric(col.2))))),
		list(rdata.frame),
		precondition = function(df) ncol(df) >=2)	

	#group.f is tested implicitly in the above and has no direct equivalent in dplyr
	
	#ungroup what is a good test for ungroup?
	 
	#gather
	unit.test(
		function(df)
			nrow(as.data.frame(transmute(gather(input(df)), mean(as.numeric(col.1)), .mergeable = TRUE))) == 1,
		list(rdata.frame))
	
	#as.data.frame and input
	unit.test(
		function(df)
			cmp.df(
				df,
				as.data.frame(input(df))),
		list(rdata.frame))
	
}