\name{as.data.frame}
\alias{as.data.frame}
\alias{input}
\alias{output}
\title{
Specify the input and output of a pipe
}
\description{
Input is defined for data frames, file paths and rmr2 big data objects and always represents the starting point of a pipe. Output is used to write the result of a pipe to a specific file path or rmr2 big data object. As.data.frame writes the result of a pipe to a data frame.
}
\usage{
as.data.frame(x)
input(x, format = "native")
output(.data, path = dfs.tempfile(), format = "native")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{a pipe for as.data.frame or a data frame, file path or rmr2 big data object for input}
  \item{.data}{a pipe}
  \item{path}{The path to write to}
  \item{format}{Format to use when writing out to disk.}
}

\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

}
