\name{transform}
\alias{transform}
\alias{subset}
\alias{mutate}
\alias{summarize}
\title{
Data manipulation functions to add, modify, select, or otherwise process data frame type data.
}
\description{
These functions are inspired by and actually implemented on top of equally named functions in packages \code{\link{plyr}} and \code{\link{base}}. In their \code{\link{plyrmr}} implementation they act on each group of a pipe. These functions are now generic: you can call them on a data frame or on plyrmr pipe.
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
  \item{_data, .data, x}{The input data, represent by a data frame or pipe. Three different argument names are used only for compatibility with pre-existing data frame functions}
  \item{\dots}{See the equally named functions in \link{base} and \link{plyrmr} for explanation about how these arguments are evaluated and used}
}
\details{
See the manuals for \link[base]{transform}, \link[base]{subset}, \link[plyr]{mutate} and \link[plyr]{summarize} for details. The method for pipes applies the data frame methods for each function, or the function itself if non-generic, to each group of the pipe. See \code{\link{group}} for details on grouping.
}
\value{
Same type as the first argument, a data frame or a pipe.
}

\examples{
transform(
  mtcars, 
  carb.per.cyl = carb/cyl)

as.data.frame(
  transform(
    input(mtcars), 
    carb.per.cyl = carb/cyl))
}
