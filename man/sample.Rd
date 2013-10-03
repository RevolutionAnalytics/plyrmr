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
  \item{method}{the desired sampling method: \code{"any"} means any subset of rows (no statistical guarantees), \code{"Bernoulli"} means i.i.d Bernoulli trials and \code{"hypergeometric"} mean sampling without replacement}
  \item{\dots}{Additional arguments depending on method. \code{n} is sample size  for methods  \code{"any"} and \code{"hypergeometric"}, \code{p} is probability of being in the sample for \code{"Bernoulli"}}
}
\details{
This function is named after the well known \code{base::sample} for vectors but accepts different options and behaves differently, reflecting different needs that arise with large data sets.
}
\value{Same class as \code{x}, representing the sampled data set}
}
\examples{
sample(mtcars, method = "hypergeometric", n = 5)
as.data.frame(sample(input(mtcars), method = "hypergeometric", n = 5))
}
