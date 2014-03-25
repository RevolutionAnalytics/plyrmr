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

where.pipe = 
	function(.data, .cond, .envir = parent.frame()) {
		.envir = copy.env(.envir)
		.cond = substitute(.cond)
		eval(
			substitute(
				gapply(.data, CurryHalfLazy(where, .envir = .envir), .cond),
				list(.cond = .cond)))}

transmute.pipe = 
	function(.data, ..., .cbind = FALSE, .mergeable = FALSE, .envir = parent.frame()) {
		.envir = copy.env(.envir)
		fun = CurryHalfLazy(transmute, .cbind = .cbind, .envir = .envir)
		if(.mergeable) fun = mergeable(fun)
		gapply(.data, fun, ...)}

bind.cols.pipe =
	function(.data, ..., .envir = parent.frame()) {
		.envir = copy.env(.envir)
		transmute(.data, ..., .cbind = TRUE, .mergeable = FALSE, .envir = .envir)}

magic.wand(select)