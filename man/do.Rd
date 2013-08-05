\name{do}
\alias{do}
\title{
Execute a function on a pipe.
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
do(.data, f, ...)
}
\arguments{
  \item{.data}{A pipe
}
  \item{f}{
A function of a data frame returning a data frame}
  \item{\dots}{
Additional arguments to f}
}
\details{
f is called on chunks of the data. The chunks are either arbitrary (faster) or determined by group.by and related functions.
}
\value{
A pipe with the return values of f applied to each chunk.
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

}
