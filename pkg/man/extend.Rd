\name{extend}
\alias{extend}
\title{The extend function}
\description{
  Allows to extend the package with big data versions of data frame functions from packages base and dplyr
}
\usage{
	extend(pack=c("base", "dplyr"), envir = parent.frame())
	magic.wand(f, non.standard.args = TRUE, add.envir.arg =
                 non.standard.args, envir = parent.frame())
}
\arguments{
	\item{pack}{The package from which the functions to be converted should be taken}
  \item{envir}{The environment to which new functions should be added}
  \item{non.standard.args}{whether \code{f} accepts arguments to be evaluated using \link{non standard evaluation} rules, like \code{\link{transform}}}
  \item{add.envir.arg}{whether \code{f} accepts the \code{.envir} argument for the correct implementation of \link{non standard evaluation}. Hopefully this argument will become a minor standard shared by plyrmr and dplyr.}
   \item{f}{A function of a data frame returning a data frame (attempts are made to coerce a non data frame return value to a data frame, but your milage may vary; vectors become single column data frames).}
}
\details{
	Extend defines big data versions for \code{transform} and \code{subset} from package base and \code{mutate}, \code{summarize} and \code{filter} from dplyr. These functions don't add fundamentally new capabilities to plyrmr, but may be preferred by people already familiar with them. Hence they are not part of the package, but can be defined on demand.
}
\value{
NULL, useful only for its side-effects}
\examples{
extend("base")}
