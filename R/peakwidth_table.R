#' @title peakwidth_table
#'
#' @description This function is designed to generate estimates of peakwidth
#' for each peak within the peakList and some properties of each peak. After
#' this is done, the table of estimates is exported.
#'
#' @param Autotuner An Autotuner objected containing sample specific raw
#' data.
#' @param returned_peaks A scalar number of peaks to return for visual
#' inspection. Five is the minimum possible value.
#'
#' @details The actual calculations used to estimate peakwidth are done within
#' the function "peakwidth_est".
#'
#' @return This function will return a peak table with information on
#' the peak width for each detected peak across samples, the name
#' attribute for when the peak starts and ends, and the time points
#' associated with each of those parameters and for the midpoint.
peakwidth_table <- function(Autotuner, returned_peaks = 10) {

    peakList <- Autotuner@peaks
    # Checking input ----------------------------------------------------------
    assertthat::assert_that(length(peakList) > 0,
                          msg = paste("Input to peakwidth_table is null.",
                                      "See output of extract_peaks."))


    # initializing storage objects --------------------------------------------
    # initializing data storage
    peakTable <- data.frame()
    counter <- 1

    # Extracting peak width properties from all data TIC peaaks ---------------
    for(sampleIndex in seq_along(peakList)) {

        # extracting relevant info for each sample
        time <- Autotuner@time[[sampleIndex]]
        intensity <- Autotuner@intensity[[sampleIndex]]
        peaks <- peakList[[sampleIndex]]

        # generating peak widths for each returned peak ------------------------
        # returns a data frame with estimated sample peakwidths
        peakIndexTable <- data.frame()
        for(peakColIndex in seq_len(ncol(peaks))) {

            tempPeakWidthEst <- peakwidth_est(peak_vector =
                                                  peaks[,peakColIndex],
                                            time,
                                            intensity,
                                            start = NULL,
                                            end = NULL,
                                            old_r2 = NULL)


            #### ADD HARD CHECK HERE TO ENSURE PEAK DOESN'T GO ON FOREVER
            if(length(time)/5 < diff(tempPeakWidthEst)) {
                stop(paste("One peak was over 1/5 of all scans in length.",
                           "This is probably an error."))
            }

            ## 2019-06-20
            ## Adding check to handle corner case when peak goes beyond
            ## boundary of TIC
            if(tempPeakWidthEst[2] > length(time)) {
                tempPeakWidthEst[2] <- length(time)
            }

            peakIndexTable <- rbind(peakIndexTable, c(tempPeakWidthEst,
                                                      peakColIndex))

        }
        colnames(peakIndexTable) <- c("peakStart", "peakEnd", "peakID")


        # Storing peakwidth info for each peak and each sample -----------------
        # inner loop - itterating through columns of peak index table
        for(curPeakIndexCol in seq_along(peakIndexTable$peakStart)) {

            ## start and end indexes
            start <- peakIndexTable$peakStart[curPeakIndexCol]
            end <- peakIndexTable$peakEnd[curPeakIndexCol]


            ## extracting peak width
            storeRow <- data.frame(
                peak_width = time[end] - time[start],
                Start_time = time[start],
                End_time = time[end],
                Start_name = names(time)[start],
                End_name = names(time)[end],
                Sample = sampleIndex,
                Mid_point_time = (time[start]+time[end])/2,
                Max_intensity = max(intensity[start:end]),
                ## consider changing with with which.is.max function
                Maxima_time = time[start + which(intensity[start:end] %in%
                                                     max(intensity[start:end]))]
            )

            peakTable <- rbind(peakTable, storeRow)
            counter <- counter + 1

        }

    }

    return(peakTable)
}
