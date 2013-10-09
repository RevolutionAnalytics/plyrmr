\name{merge}
\alias{merge}
\title{
Function to merge data sets represented by pipes as in a relational  join
}
\description{
A methods for the generic function merge that implements the same operation as the method for frames, only on big data sets.
}
\usage{
\method{merge}{pipe}(x, y, by = NULL, by.x = by, by.y = by, all = FALSE, all.x = all, all.y = all, suffixes = c(".x", ".y"), incomparables = NULL, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x, y}{Two data sets represented by pipes}
  \item{by, by.x, by.y}{Specification of the columns used for merging.}
  \item{all,all.x,all.y}{Logicals specifying whether a full, left or right outer join should be performed}
  \item{suffixes}{Length two character vector to specify suffixes for column names}
  \item{incomparables}{values which cannot be matched}
  \item{\dots}{Additional arguments for methods}
}
\details{
See \code{\link[base]{merge}} for details
}
\value{
The merged data set represented by a pipe}
\examples{
as.data.frame(merge(input(mtcars), input(mtcars), by = c("carb", "cyl")))
}
