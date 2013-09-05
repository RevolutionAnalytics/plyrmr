\name{transform}
\alias{transform}
\alias{subset}
\alias{mutate}
\alias{summarize}
\title{
Data manipulation functions to add, modify, select, or otherwise process data frame type data.
}
\description{
These functions are inspired by and actually use in their implementation equally named functions in packages plyr and base. In this plyrmr implementation they act on the data in chunks, either arbitrary or as defined by group. These functions are generic: you can call them on a data.frame or on plyrmr pipe.
}
\usage{
\method{transform}{pipe}(`_data`, \dots)
\method{subset}{pipe}(x, \dots)
mutate(.data, \dots)
\method{mutate}{pipe}(.data, \dots)
summarize(.data, \dots)
\method{summarize}{pipe}(.data, \dots)
}

\arguments{
  \item{_data, .data, x}{The input data, represent by an object of class pipe. The different names depends on the names used in the generic functions of which these are methods. The meaning is the same.}
  \item{\dots}{See the equally named functions in base and plyrmr}
}
\details{
These are also generic functions and have methods for data frames. Whenever order and grouping of records is immaterial to the computation, operating on a data.frame or a pipe containing the sames data should be the same \code{all(f(x) == f(input(x)))}.}
\value{
An object of class pipe.
}

\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

}
