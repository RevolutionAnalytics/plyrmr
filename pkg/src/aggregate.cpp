//Copyright 2014 Revolution Analytics
//   
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS, 
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

#include <vector>
#include <Rcpp.h>

using namespace Rcpp; 
using namespace std;


template<typename I, typename S>
class Reduce {
	public:
	virtual S operator()(S state, I elem) = 0;};

template<typename S, typename O>
class Finish{
	public:
	virtual O operator()(S state) = 0;};
	
template<typename I, typename S, typename R, typename F, typename O>
O aggregate(vector<I> x, S state, R reduce, F finish, O out) {
	for(unsigned int i = 0; i < x.size(); i++) {
		state = reduce(state, x[i]);}
	return finish(state);}

//sum
template<typename N>
class Sum {
	class Sum2: public Reduce<N, N> {
		public:
		N operator()(N state, N elem) {
			return state + elem;}};
	
	class IdFinish: public Finish<N, N> {
		public:
		N operator()(N x) {return x;}};
	public:	
	N operator()(vector<N> x) {
	  return aggregate(x, N(), Sum2(), IdFinish(), N());}};
 
//mean
template <typename N> 
class Mean{
	class MeanState {
		public:
		MeanState() {
			acc = 0;
			count = 0;}
			N acc;
			unsigned int count;};
			
	class MeanSum: public Reduce<N, MeanState > {
		public:
		MeanState operator()(MeanState state, N elem) {
			state.acc += elem;
			state.count++;
			return state;}};
			
	class RatioFinish: public Finish<MeanState, double> {
		public:
		double operator()(MeanState state) {
			return ((double)state.acc)/state.count;}};
	public:	
	double operator()(vector<N> x) {
		return aggregate(x, MeanState(), MeanSum(), RatioFinish(), N());}};


template<typename N, typename Summary>
vector<N> fast_summary(List xx) {
	vector<N> results(xx.size());
  for(unsigned int i = 0; i < xx.size(); i ++) {
    vector<N> x = as<vector<N> >(xx[i]);
    results[i] = Summary()(x);}
  return results;}

// [[Rcpp::export("fast.sum.integer")]]
std::vector<int> fast_sum_integer(List xx) {
	return fast_summary<int, Sum<int> >(xx);}

// [[Rcpp::export("fast.sum.numeric")]]
std::vector<double> fast_sum_numeric(List xx) {
	return fast_summary<double, Sum<double> >(xx);}

// [[Rcpp::export("fast.mean.integer")]]
std::vector<int> fast_mean_integer(List xx) {
	return fast_summary<int, Mean<int> >(xx);}

// [[Rcpp::export("fast.mean.numeric")]]
std::vector<double> fast_mean_numeric(List xx) {
	return fast_summary<double, Mean<double> >(xx);}

