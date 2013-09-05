\name{as.data.frame}
\alias{as.data.frame}
\alias{input}
\alias{output}
\title{
Specify the input and output of a pipe or get its output in a data fame
}
\description{
\code{input} is defined for data frames, file paths and rmr2 big data objects and always represents the starting point of a pipe. \code{output} is used to write the result of a pipe to a specific file path or rmr2 big data object. \code{as.data.frame} writes the result of a pipe to a data frame. 
}
\usage{
\method{as.data.frame}{pipe}(x, \dots)
input(x, \dots)
output(.data, path = NULL, format = "native", input.format = format)
}
\arguments{
  \item{x}{a pipe for as.data.frame or a data frame, file path or rmr2 big data object for input}
  \item{.data}{a pipe}
  \item{path}{The path to write to, if NULL a temporary location is used}
  \item{format}{Format to use when reading or writing to disk.}
  \item{input.format}{input format to read the data from disk when format can be used only as an output format}
  \item{\dots}{Additional arguments. For input, the input format to use. For the as.data.frame methods for pipe, no additional arguments are currently accepted}
}

\value{For as.data.frame, a data frame. For input, a pipe. For ouput, a big data object. }

\examples{
as.data.frame(
  where(
    input(mtcars),
    cyl > 4))
    
output(
  where(
    input(mtcars),
    cyl > 4),
    "/tmp/output")
    
as.data.frame(
  select(
    input("/tmp/output"),
    mpg))    
dfs.rmr("/tmp/output")
}
