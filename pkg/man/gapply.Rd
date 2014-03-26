\name{gapply}
\alias{gapply}
\alias{magic.wand}
\alias{mergeable}
\alias{vectorized}
\title{
Apply a function f to each of the groups of a data set, or set up a method to do just that.
}
\description{
\code{gapply} applies the function f to each of the groups in the data set represented by .data. The return values of such application become the output of the extended pipe.  \code{magic.wand} creates a method for class pipe for a function named like \code{f} which does exactly what \code{gapply(x, f, ...)} does. 
}
\usage{
gapply(.data, .f, \dots)
magic.wand(f)
mergeable(f)
vectorized(f)
}
\arguments{
  \item{.data}{A pipe}
  \item{f,.f}{A function of a data frame returning a data frame (attempts are made to coerce a non data frame return value to a data frame, but your milage may vary; vectors become single column data frames)}
  \item{\dots}{Additional arguments to f}
}
\details{
\code{gapply} applies a function to each group of the \code{.data} pipe. If the pipe is ungrouped, \code{.f} is applied to arbitrary, reasonably sized chunks. \code{magic.wand} creates a generic named \code{f} with two methods, one for data.frames, which calls \code{f} itself and one for pipes which calls \code{gapply(.data, f, \dots)}. \code{mergeable} and \code{vectorized} return their only argument with an attribute set that guides certain optimizations. By calling \code{mergeable} the user is guaranteeing tha \code{f} as a function of each of the rows in .\code{.data} is associative and commutative. By calling \code{vectorized} the user is declaring that \code{f} can handle multiple groups. TODO requirements of a vectorized function. These two functions are normally used to modify  the \code{.f} argument to \code{gapply}. The potential performance gains associated to the proper use of these functions can be substantial and in the case of \code{mergeable} it may be the only way to complete a calculation successfully. On the other hand, if the function \code{f} doesn not truly fulfil the requirements of \emph{mergeability} or \emph{vectorization} the results of the computation performed by \code{gapply} are unpredictable, that is, it's a bug.
}
\value{
For gapply, a pipe. magic.wand is used only for its side effects
}
\examples{
#drop last column
as.data.frame(
  gapply(
    input(mtcars), 
    function(x) x[, -ncol(x)]))
#extend row.names to work on pipes
magic.wand(row.names)
}
