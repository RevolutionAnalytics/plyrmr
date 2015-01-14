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


library(quickcheck)
library(plyrmr)
library(dplyr)

cmp.df = plyrmr:::cmp.df

plyrmr:::all.backends({
	
	#gapply
	
	test(
		function(df)
			cmp.df(
				df,
				as.data.frame(gapply(input(df), identity))),
		list(rdata.frame))
	
	#group
	cg = quickcheck:::column.generators()
	cg = cg[-which(names(cg) == "rraw")]
	rdata.frame.noraw = fun(rdata.frame(element = cg, ncol = 10))
	# tmp hack because summarize doesn't support raw
	
	test(
		function(df) {
			df$col.2 = as.numeric(df$col.2)
			cmp.df(
				summarize(group_by(df, col.1), mean(col.2)),
				as.data.frame(transmute(group(input(df), col.1), mean(col.2))))},
		list(rdata.frame.noraw))
	
	#group.f is tested implicitly in the above and has no direct equivalent in dplyr
	
	#ungroup what is a good test for ungroup?
	
	test(
		function(df)
			cmp.df(
				summarize(group_by(df, col.1), mean(col.2)),
				as.data.frame(transmute(ungroup(group(input(df), col.1, col.2), col.2), mean(col.2)))),
		list(rdata.frame.noraw))	
	
	#,	precondition = function(df) ncol(df) >=2 && is.numeric(df$col.2)
	
	#gather
	test(
		function(df)
			nrow(as.data.frame(transmute(gather(input(df)), mean(col.1), .mergeable = TRUE))) == 1,
		list(rdata.frame), 
		precondition = function(df) is.numeric(df$col.1))
	
	#as.data.frame and input
	test(
		function(df)
			cmp.df(
				df,
				as.data.frame(input(df))),
		list(rdata.frame))
})