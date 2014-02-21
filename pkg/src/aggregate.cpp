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


template<typename Input_, typename State_>
class BinaryOp_ {
	public:
	typedef Input_ Input;
	typedef State_ State;
	virtual State operator()(State state, Input elem) = 0;};

template<typename State_, typename Output_>
class Finish_{
	public:
	typedef State_ State;
	typedef Output_ Output;
	virtual Output operator()(State state) = 0;};
	
template<typename BinaryOp, typename Finish>
typename Finish::Output reduce(
	vector<typename BinaryOp::Input> x, 
	typename BinaryOp::State state, 
	BinaryOp binary_op, 
	Finish finish) {
	for(unsigned int i = 0; i < x.size(); i++) {
		state = binary_op(state, x[i]);}
	return finish(state);}

template<typename Number>
class Sum {
	class BinaryOp: public BinaryOp_<Number, Number> {
		public:
		Number operator()(Number state, Number elem) {
			return state + elem;}};
	class Finish: public Finish_<Number, Number> {
		public:
		Number operator()(Number x) {return x;}};
	public:	
	Number operator()(vector<Number> x) {
	  return reduce(x, Number(), BinaryOp(), Finish());}};

 
template <typename Number> 
class Mean{
	class State {
		public:
		State() {
			acc = 0;
			count = 0;}
		Number acc;
		unsigned int count;};
	class BinaryOp: public BinaryOp_<Number, State > {
		public:
		State operator()(State state, Number elem) {
			state.acc += elem;
			state.count++;
			return state;}};			
	class Finish: public Finish_<State, double> {
		public:
		double operator()(State state) {
			return ((double)state.acc)/state.count;}};
	public:	
	double operator()(vector<Number> x) {
		return reduce(x, State(), BinaryOp(), Finish());}};

template <typename Number>
class Variance{
	class State {
		public:
		State() {
			X = 0;
			X2 = 0;
			count = 0;}
		Number X, X2;
		unsigned int count;};
		
		class BinaryOp: public BinaryOp_<Number, State> {
			public:
			State operator()(State state, Number elem) {
				state.X += elem;
				state.X2 += elem;
				state.count++;
				return state;}};
				
		class Finish: public Finish_<State, double> {
			public:
			double operator()(State state) {
				return ((double) state.X2)/state.count - ((double) state.X*state.X)/(state.count*state.count);}};
		public:
		double operator()(vector<Number> x) {
			return reduce(x, State(), BinaryOp(), Finish());}};

template<typename Number, typename Summary>
vector<Number> fast_summary(List xx) {
	vector<Number> results(xx.size());
  for(unsigned int i = 0; i < xx.size(); i ++) {
    vector<Number> x = as<vector<Number> >(xx[i]);
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

