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
		function(df = rdata.frame())
			cmp.df(
				df,
				as.data.frame(gapply(input(df), identity))))
	
	#group
	cg = quickcheck:::atomic.generators
	cg = cg[-which(names(cg) == "rraw")]
	rdata.frame.noraw = function() rdata.frame(element = cg, ncol = 10)
	# tmp hack because summarize doesn't support raw
	
	test(
		function(df = rdata.frame.noraw()) {
			df$col.2 = as.numeric(df$col.2)
			cmp.df(
				summarize(group_by(df, col.1), mean(col.2)),
				as.data.frame(transmute(group(input(df), col.1), mean(col.2))))})
	
	#group.f is tested implicitly in the above and has no direct equivalent in dplyr
	
	#ungroup what is a good test for ungroup?
	
	test(
		function(df = rdata.frame.noraw()){
			df$col.2 = as.numeric(df$col.2)
			cmp.df(
				summarize(group_by(df, col.1), mean(col.2)),
				as.data.frame(transmute(ungroup(group(input(df), col.1, col.2), col.2), mean(col.2))))})
	
	#gather
	
	rdata.frame.w.numeric.col =
		function() {
			df = rdata.frame(nrow = 20)
			cbind(rnumeric(size = ~nrow(df)), df)}
			
	test(
		function(df = rdata.frame.w.numeric.col())
			nrow(
				as.data.frame(
					transmute(
						gather(input(df)),
						mean(as.numeric(col.1)),
						.mergeable = TRUE))) == 1)
	
	#as.data.frame and input
	test(
		function(df = rdata.frame())
			cmp.df(
				df,
				as.data.frame(input(df))))
})