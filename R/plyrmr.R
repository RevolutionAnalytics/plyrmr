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


subsetfun = function(x, ...) do(x, subset, ...)
setMethodS3("subset", "pipe", subsetfun)
setMethodS3("filter", "pipe", subsetfun)
setMethodS3("transform", "pipe", function(x, ...) do(x, transform, ...))
setMethodS3("mutate", "pipe", function(x, ...) do(x, mutate, ...))
summarizefun = function(x, ...) do(x, summarize, ...)
setMethodS3("summarize", "pipe", summarizefun)
setMethodS3("select", "pipe", summarizefun)

