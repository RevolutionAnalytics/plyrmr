\name{gapply}
\alias{gapply}
\alias{mergeable}
\alias{vectorized}
\title{
Apply a function f to each of the groups of a data set, or set up a method to do just that.
}
\description{
\code{gapply} applies the function f to each of the groups in the data set represented by .data. The return values of such application become the output of the extended pipe. 
}
\usage{
gapply(.data, .f, \dots)
mergeable(f, flag = TRUE)
vectorized(f, flag = TRUE)
}
\arguments{
  \item{.data}{A pipe}
  \item{f,.f}{A function of a data frame returning a data frame (attempts are made to coerce a non data frame return value to a data frame, but your milage may vary; vectors become single column data frames)}
  \item{\dots}{Additional arguments to .f}
   \item{flag}{Wether the function \code{f} is mergeable or vectorized, resp. (see Details)}
}
\details{
\code{gapply} applies a function to each group of the \code{.data} pipe. If the pipe is ungrouped, \code{.f} is applied to arbitrary, reasonably sized chunks. \code{mergeable} and \code{vectorized} return their only argument with an attribute set that guides certain optimizations. By calling \code{mergeable} with the argument flag set to TRUE (the default) the user is guaranteeing that \code{f} as a function of each of the rows in \code{.data} is associative and commutative. By calling \code{vectorized} with the argument flag set to TRUE (the default) the user is declaring that \code{f} can handle multiple groups, which, in the current implementation, means the data passed to \code{f} is grouped with \code{dplyr::group_by} and can be processed with so-called \emph{verbs} in \code{dplyr}, most commonly \code{dplyr::summarize}. One convenient way of using those capabilities in \code{dplyr} functions is to use the related extension to \code{plyrmr}, see \code{\link{extend}}. These two functions are normally used to modify  the \code{.f} argument to \code{gapply}. The potential performance gains associated with the proper use of these functions can be substantial and in the case of \code{mergeable} it may be the only way to complete a calculation successfully. On the other hand, if the function \code{f} doesn't truly fulfil the requirements of \emph{mergeability} or \emph{vectorization} the results of the computation performed by \code{gapply} are unpredictable, that is, it's a bug.
}
\value{
For \code{gapply}, a pipe. \code{mergeable} and \code{vectorized} return the same function passed as argument, with additional attributes.
}
\examples{
#drop last column
as.data.frame(
  gapply(
    input(mtcars), 
    function(x) x[, -ncol(x)]))
}
