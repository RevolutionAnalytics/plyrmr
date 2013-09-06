\name{sample}
\alias{sample}

\title{Sample a data set}

\description{
Sample a data set, represented by a data frame or pipe, according to different methods.
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
This function is named after the well known base::sample for vectors but accepts different options and behaves differently, reflecting different needs that arise with large data sets. Non numeric columns are dropped.
}
\value{Same object type as x, containing the quantiles of each column, as specified by additional arguments
}
\examples{
sample(mtcars, method = "hypergeometric", n = 5)
as.data.frame(sample(input(mtcars), method = "hypergeometric", n = 5))
}
