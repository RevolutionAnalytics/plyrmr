\name{count}
\alias{count}
\title{
Approximate or exact counting of categorical data}
\description{
This function works separately on each column, computing the frequency of each element or level. When \code{n} is specified, a variant of the Space Saving algorithm is applied, which will return all items with a count \code{N/n} or larger where \code{N} is the total number of rows.
}
\usage{
count(x, ...)
\method{count}{data.frame}(x)
\method{count}{pipe}(x, n)
}
\arguments{
  \item{x}{A data set represented by a pipe or data frame}
  \item{n}{The maximum number of items or levels to be counted}
  \item{\dots}{Additional arguments for methods}
}
\details{
}
\value{
A data set with two columns per non numeric column in the original data set, one with the elements (all of them or only a subset as explained in the Details Section) and one with the corresponding counts. The type  of the output is the same as the type of the input.
}
\examples{
as.data.frame(count(input(data.frame(a = sample(LETTERS[1:5], 10, replace = TRUE), b = sample(LETTERS[1:10], 10, replace = TRUE)))))
}
