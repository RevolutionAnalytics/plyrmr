\name{moving.window}
\alias{moving.window}
\title{
Group the data in a way that is compatible with computing a moving window statistics
}
\description{
Group the data so that records with consecutive values of index are grouped together and there is a window size overlap between groups, so as to make possible computing a moving window statistics.
}
\usage{
moving.window(x, index, window, R = rmr.options("keyval.length"))
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
A data set represented by pipe
}
  \item{index}{The column to use to partition the data, as character or numeric vector of length one.
}
  \item{window}{Size of the window, resulting in a window - 1 overlap between groups}
  \item{R}{Only for performance, size of the reduce size groups, see details}
}

\value{
A pipe with the results of applying f to each window}
\examples{
as.data.frame(
  do(
    moving.window(
      input(data.frame(t= 1:20, x = rnorm(20))), 
      "t", 
      3), 
    function(x) 
      if(nrow(x) >= 3) 
        data.frame(y = filter(x$x, rep(1/3,3)))))
}
