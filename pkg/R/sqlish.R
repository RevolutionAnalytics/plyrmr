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
	function(.data, .cond) {
		print("driver")
		.cond = lazy(.cond)
		 # copy environment.
		env <- as.environment(as.list(.cond$env))
		parent.env(env) <- .GlobalEnv
		.cond$env <- env
		gapply(.data, where.data.frame_, .cond)}

transmute.pipe = 
	function(.data, ..., .cbind = FALSE, .columns = NULL, .mergeable = FALSE) {
		gapply(
			.data, 
			mergeable(transmute.data.frame_, .mergeable), 
			dot.args = lazy_dots(...),
	    .cbind = .cbind,
			.columns = .columns)}

bind.cols.pipe =
	function(.data, ...) {
		transmute(.data, ..., .cbind = TRUE, .mergeable = FALSE)}
