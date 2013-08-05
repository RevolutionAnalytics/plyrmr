\name{group.by}
\alias{group.by}
\alias{group.by.f}
\alias{group.together}
\alias{ungroup}

\title{
Control grouping in plyrmr computations}
\description{
Large data sets can not be processed by bringing all the data into memory at once. One alternative is to group records by a key or index and process one group at a time, provided they are not too big. The functions documented here allow to do that in plyrmr.
}
\usage{
group.by(.data, ...)
group.by.f(.data, f, ...)
group.together(.data)
ungroup(.data, ...)

}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{.data}{
%%     ~~Describe \code{.data} here~~
}
  \item{f}{
%%     ~~Describe \code{.data} here~~
}
  \item{\dots}{
%%     ~~Describe \code{\dots} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (.data, ...) 
{
    group.by.f(.data, function(y) summarize(y, ...))
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
