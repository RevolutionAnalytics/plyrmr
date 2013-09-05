\name{sample}
\alias{sample}

\title{
Function to sample from big data sets and data frames
}
\description{
Albeit methods for a generic function whose default method is the well known base::sample, the methods for data frames and pipes have a different behavior, but they are still meant to perform sampling,
}
\usage{
sample(x, \dots)
\method{sample}{pipe}(x, method = c("any", "Bernoulli", "hypergeometric"), ...)
\method{sample}{data.frame}(x, method = c("any", "Bernoulli", "hypergeometric"), ...)
}
\arguments{
  \item{x}{A data set represented by a data frame or a pipe}
  \item{method}{the desired sampling method: any means any subset of rows (no statistical guarantees), Bernoulli means i.i.d Bernoulli trials and hypergeometric mean sampling without replacement}
  \item{\dots}{Additional arguments depending on method. n is sample size  for methods any and hypergeometric, p is probability of being in the sample for Bernoulli}
}
\details{
}
\value{Same object type as x, containing the quantiles of each column, as specified by additional arguments
}
\examples{
sample(mtcars, method = "hypergeometric", n = 5)
as.data.frame(sample(input(mtcars), method = "hypergeometric", n = 5))
}
