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
class BinaryOp_ {
	public:
	typedef I Input;
	typedef S State;
	virtual S operator()(S state, I elem) = 0;};

template<typename S, typename O>
class Finish_{
	public:
	typedef S State;
	typedef O Output;
	virtual O operator()(S state) = 0;};
	
template<typename R, typename F>
typename F::Output reduce(
	vector<typename R::Input> x, 
	typename R::State state, 
	R binary_op, 
	F finish) {
	for(unsigned int i = 0; i < x.size(); i++) {
		state = binary_op(state, x[i]);}
	return finish(state);}


template<typename N>
class Sum {
	class BinaryOp: public BinaryOp_<N, N> {
		public:
		N operator()(N state, N elem) {
			return state + elem;}};
	
	class Finish: public Finish_<N, N> {
		public:
		N operator()(N x) {return x;}};
	public:	
	N operator()(vector<N> x) {
	  return reduce(x, N(), BinaryOp(), Finish());}};
 
template <typename N> 
class Mean{
	class State {
		public:
		State() {
			acc = 0;
			count = 0;}
		N acc;
		unsigned int count;};
			
	class BinaryOp: public BinaryOp_<N, State > {
		public:
		State operator()(State state, N elem) {
			state.acc += elem;
			state.count++;
			return state;}};
			
	class Finish: public Finish_<State, double> {
		public:
		double operator()(State state) {
			return ((double)state.acc)/state.count;}};
	public:	
	double operator()(vector<N> x) {
		return reduce(x, State(), BinaryOp(), Finish());}};

template <typename N>
class Variance{
	class State {
		public:
		State() {
			X = 0;
			X2 = 0;
			count = 0;}
		N X, X2;
		unsigned int count;};
		
		class BinaryOp: public BinaryOp_<N, State> {
			public:
			State operator()(State state, N elem) {
				state.X += elem;
				state.X2 += elem;
				state.count++;
				return state;}};
				
		class Finish: public Finish_<State, double> {
			public:
			double operator()(State state) {
				return ((double) state.X2)/state.count - ((double) state.X*state.X)/(state.count*state.count);}};
		public:
		double operator()(vector<N> x) {
			return reduce(x, State(), BinaryOp(), Finish());}};

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

