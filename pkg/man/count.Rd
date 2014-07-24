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
\method{count}{pipe}(x, ..., n = Inf)
}
\arguments{
  \item{x}{A data set represented by a pipe or data frame}
  \item{n}{The maximum number of items or levels to be counted}
  \item{\dots}{One or more expressions containing one or more column names (as variables) separated by \code{:}}
}
\details{
Approximate or exact (n = Inf) counting is applied to each column or combination thereof supplied in the additional arguments. "Combination" means that a row is counted together with another row  if and only if they are equal in each of the columns named in one of the additional arguments (separate count for each argument).
}
\value{
A data frame with a set of columns for each of the additonal arguments. Each set has a column for each variable named in one argument and one column for the count, named "freq" or "freq." followed by TODO and as many rows as there are distinct combination of values or up to a maximum of \code{n}. T
}
\examples{
as.data.frame(count(input(data.frame(a = sample(LETTERS[1:5], 10, replace = TRUE), b = sample(LETTERS[1:10], 10, replace = TRUE)))))
}
