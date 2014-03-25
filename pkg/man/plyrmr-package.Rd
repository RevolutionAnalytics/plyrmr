\name{plyrmr-package}
\alias{plyrmr-package}
\alias{plyrmr}
\docType{package}
\title{
Easy big data manipulation plyr-style with R and Hadoop }
\description{
Like rmr2, allows to write mapreduce jobs in R. Unlike it, it doesn't require the user to define function for even the simplest tasks. When necessary, user defined functions are simpler than the equivalent in rmr2 as they accept a data frame and return a data frame. The need to define keys is side-stepped using a SQL-inspired notion of grouping, also present in dplyr. Abstraction and reuse are encouraged through a more sophisticated mapping between user calls and mapreduce, enabled by delayed evaluation.
}
\details{
\tabular{ll}{
Package: \tab plyrmr\cr
Type: \tab Package\cr
Version: \tab see packageDescription()\cr
Date: \tab see packageDescription()\cr
License: \tab Apache 2.0\cr
}
}
\author{rhadoop@revolutionanalytics.com}
