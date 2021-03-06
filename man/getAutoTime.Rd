% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Autotuner-class.R
\name{getAutoTime}
\alias{getAutoTime}
\title{getAutoTime}
\usage{
getAutoTime(Autotuner)
}
\arguments{
\item{Autotuner}{An AutoTuner object.}
}
\value{
The content of the time slot
}
\description{
This function returns the list of numerics stored within
the 'time' slot of the Autotuner Object
}
\examples{
Autotuner <- readRDS(system.file("extdata/Autotuner.rds",
package="Autotuner"))
intensity <- getAutoTime(Autotuner)
}
