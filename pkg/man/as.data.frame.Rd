\name{as.data.frame}
\alias{as.data.frame}
\alias{input}
\alias{output}
\title{
Specify the input and output of a pipe or convert its output into a data frame
}
\description{
\code{input} is defined for data frames, file paths, \code{rmr2} big data objects or a \code{plyrmr} big data object and \code{SparkR} rdds and always represents the starting point of a pipe. \code{output} is used to write the result of a pipe to a specific file path or \code{plyrmr} big data object. \code{as.data.frame} writes the result of a pipe to a data frame. 
}
\usage{
\method{as.data.frame}{pipermr}(x, \dots)
\method{as.data.frame}{pipespark}(x, \dots)
input(x, \dots)
output(.data, path = NULL, format = "native", input.format = format)
}
\arguments{
  \item{x}{a pipe for as.data.frame or a data frame, file path, rmr2 big data object or SparkR rdd for input}
  \item{.data}{a pipe}
  \item{path}{The path to write to, if NULL a temporary location is used (path required for the "spark" backend)}
  \item{format}{Format to use when reading or writing to disk.}
  \item{input.format}{Input format to read the data from disk when format can be used only as an output format}
  \item{\dots}{Additional arguments. For \code{input}, the input format to use. For the \code{as.data.frame} method for pipes, no additional arguments are currently accepted}
}

\value{For \code{as.data.frame}, a data frame. For \code{input}, a pipe. For \code{output}, a \code{plyrmr} big data object. }

\examples{
as.data.frame(
  where(
    input(mtcars),
    cyl > 4))
    
tryCatch(dfs.rmr("/tmp/output"), error = function(e) NULL)

output(
  where(
    input(mtcars),
    cyl > 4),
    "/tmp/output")
    
as.data.frame(
  transmute(
    input("/tmp/output"),
    mpg))    
}
