\name{quantile}
\alias{quantile}
\title{
Compute the quantiles of a data set}
\description{
Find the quantiles of a data set}
\usage{
quantile(x, \dots)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
A pipe or a data frame
}
  \item{\dots}{
Additional arguments}
}
\details{
The goal here is to approach the interface of base::quantile but we are still pretty far. The quantile function is made into a generic function and methods are provided for data frames and pipes. The algorithm used doesn't have mathematical approximation guarantees, but seems to work in practice.
}
\value{
A pipe or a data frame, depending on class(x)}

\examples{
quantile(mtcars)
as.data.frame(quantile(input(mtcars)))
}
