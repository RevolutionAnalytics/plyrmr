\name{non standard evaluation}
\alias{non standard evaluation}
\title{Non standard evaluation for \dots arguments}
\description{In \code{plyrmr}, following models in \code{base} and \code{plyr}, several functions accept a data set, represented by a pipe or a data frame, followed by \dots arguments. These are not evaluated  according to the normal rules of the R language but in an environment that includes the variables contained in the data set itself. By default, the parent of this environemnt is the local environment where the function is called, but, whenever a \code{.envir} argument is present, this can be specified by the caller, for example for \code{\link{where}} and \code{\link{select}}. The latter feature may not be of much use in interactive R session but is necessary for programming. Other types of non standard evaluation exist, such as for the \code{select} argument of \code{\link{subset}}, please see the manual for \code{\link[base]{subset}} for details. These are not used in \code{plyrmr}. A special variable \code{.data} is also present in the evaluation environment and allows to refer to all the columns as a data.frame}
\examples{
t = 4
# t from the caller environment, cyl from the data
as.data.frame(where(input(mtcars), cyl > t))
#select the last column
select(mtcars, last.col = .data[, ncol(.data)])
}