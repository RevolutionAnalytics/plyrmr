\name{do}
\alias{do}
\alias{magic.wand}
\title{
Apply a function f to each of the groups of a data set, or set up a method to do just that.
}
\description{
\code{do} applies the function f to each of the groups in the data set represented by .data. The return values of such application become the output of the extended pipe.  \code{magic.wand} creates a method for class pipe for a function named like \code{f} which does exactly what do does. 
}
\usage{
do(.data, .f, \dots)
magic.wand(f)
}
\arguments{
  \item{.data}{A pipe}
  \item{f,.f}{A function of a data frame returning a data frame (attempts are made to coerce a non data frame return value to a data frame, but your milage may vary; vectors become single column data frames)}
  \item{\dots}{Additional arguments to f}
}
\details{

}
\value{
For do, a pipe. magic.wand is used only for its side effects
}
\examples{
#drop last column
as.data.frame(
  do(
    input(mtcars), 
    function(x) x[, -ncol(x)]))
}
