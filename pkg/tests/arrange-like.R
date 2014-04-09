# Copyright 2014 Revolution Analytics
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

library(plyr)
library(quickcheck)
library(plyrmr)


cmp.df = 
	function(A, B) {
		ord = splat(order)
		all(A[ord(A),] == B[ord(B),])}

unit.test(
	function(A, B, x) {
		xa = x[1:min(length(x), nrow(A))]
		xb = x[1:min(length(x), nrow(B))]
		A = splat(cbind)(plyrmr:::fract.recycling(list(x = xa, A)))
		B = splat(cbind)(plyrmr:::fract.recycling(list(x = xb, B)))
		cmp.df(
			as.data.frame(
				merge(input(A), input(B), by = "x")),
			merge(A, B, by = "x"))},
	list(tdgg.data.frame(), tdgg.data.frame(), tdgg.logical()))