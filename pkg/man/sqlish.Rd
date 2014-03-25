\name{where}
\alias{where}
\alias{transmute}
\alias{bind.cols}
\title{
Functions to perform sql-like operations.
}
\description{
These functions accept a data set, represented by a pipe or a data frame, and apply the operations specified by the \dots arguments, which are evaluated according to \link{non standard evaluation} rules.
\code{where} allows to filter a subset of the rows. Additional arguments should evaluate to logical or numeric and are used as row indexes. In the case of logical, the element-wise logical and of the arguments is the computed filter. In the case of numeric, a single \dots arguments should be specified. Normal recycling rules apply. \code{transmute} allows to select or generate new columns from a data set. Additional arguments become columns of the new data set and normal recycling rules apply. In the method for pipes, for both functions, additional arguments are evaluated for each group of the pipe.
}
\usage{
where(.data, \dots)
\method{where}{data.frame}(.data, .cond, .envir = parent.frame())
\method{where}{pipe}(.data, .cond, .envir = parent.frame())
bind.cols(.data, \dots)
\method{bind.cols}{data.frame}(.data, \dots, .envir = parent.frame())
\method{bind.cols}{pipe}(.data, \dots, .envir = parent.frame())
select(.data, \dots)
\method{select}{data.frame}(.data, \dots)
\method{select}{pipe}(.data, \dots)
transmute(.data, \dots)
\method{transmute}{data.frame}(.data, \dots, .cbind = FALSE, .columns = NULL, .envir = parent.frame())
\method{transmute}{pipe}(.data, \dots, .cbind = FALSE, .columns = NULL, .mergeable = FALSE, .envir = parent.frame())
}
\arguments{
  \item{.data}{A data set represented by a pipe or a data.frame}
  \item{\dots}{Additional arguments interpreted as columns}
  \item{.cond}{Expression to evaluate to logical and used to transmute rows of the data}
  \item{.cbind}{whether to cbind new columns}
  \item{.columns}{data columns to keep, as a character vector of names}
  \item{.mergeable}{whether the transmutation described by a certain call to \code{transmute} satisfies the properties of mergeability see \code{\link{mergeable}}}
	\item{.envir}{environment in which to evaluate the \dots arguments}
}
\details{
\code{transmute} tries to merge the functionality of \code{base::transform}, \code{plyr::mutate}, \code{plyr::summarize} and the SQL statement by the same name. When argument \code{.cbind} is \code{FALSE}, the default, the first argument columns are discarded and the ones defined in the \dots arguments are used to form a new data frame. In this case the number of rows returned can be different from the number of rows in the \code{.data} argument, subsuming the capabilities of both Hive's UDTF and \code{plyr::summarize}, that is expansion or reduction of the output as compared to the input. When \code{.cbind} is \code{TRUE} the behavior is more like \code{transform} and the numbers of rows returned remains the same as in \code{.data}. Recycling rules are applied to the \dots arguments. Fractional recycling, when the longest argument length is not an integer multiple of the others, is allowed but triggers a warning. \code{bind.cols} is somewhat equivalent to \code{base::subset}, but focuses only on the selection of rows, not columns. Both functions have methods for data frames and pipes. \code{where} and \code{transmute} are more appropriate for programming then their \code{base} and \code{plyr} equivalent, \code{transform}, \code{subset}, \code{mutate} and \code{summarize}, because of the additional \code{.envir} argument which allows to specify an evaluation environment different from that of the caller. See \file{tests/non-standard-eval.R} for examples of \code{transmute} and \code{where} working in contexts where the other functions don't.
}
\value{
The same type as the first argument, either a data frame or a pipe.
}
\examples{
#data.frame
where(mtcars, cyl>4 & mpg > 15)
#pipe
as.data.frame(where(input(mtcars), cyl > 4 & mpg > 15))
# select two columns
as.data.frame(transmute(input(mtcars), cyl, mpg))
# create additional column
as.data.frame(transmute(input(mtcars), ratio = cyl/mpg, .cbind = TRUE))
# summaries
as.data.frame(transmute(input(mtcars), mean(cyl), mean(mpg)))
# summaries by groups
as.data.frame(transmute(group(input(mtcars), cyl), mean(mpg)))
}
