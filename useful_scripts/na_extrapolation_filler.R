library(Hmisc)

fill_nas_linear_extrapolation <- function(df, x_name, y_name, x_to_predict,
                                          error_print=FALSE){
    #Rename df columns
    names(df)[names(df) == x_name] <- "x"
    names(df)[names(df) == y_name] <- "y"

    #Create empty data frame
    res <- data.frame()

    #Get only complete cases (with values for x and y)
    points <- df[, c("x", "y")]
    sub <- df[complete.cases(points), ]
    #Order the points - x increasing
    sub <- sub[order(sub$x), ]

    x <- sub$x
    y <- sub$y


    #Check if you have at least two points
    if(sum(!is.na(x)) < 2 & sum(!is.na(y)) < 2){
        if(error_print){
            print(paste0("Cant extrapolate with a less than two points, ",
                "skipping extrapolation."))
        }
        return(data.frame())
    }

    if(length(x) != length(y)){
        if(error_print){
            print("Different number of x's and y's skipping extrapolation.")
        }
        return(data.frame())
    }

    #Check that the min x_to_predict is still valid (you can't predict)
    #backwards since its only extrapolation
    #The min value you can predict is the second x value given
    if(min(x_to_predict) < x[2]){
        if(error_print){
            print(paste0("You can't predict for values less than ", x[2]))
        }
        #Skipping some numbers
        idx <- x_to_predict >= x[2]
        x_to_predict <- x_to_predict[idx]
    }

    #Do linear etxra with every pair
    #of consecutive points
    for(i in 1:(length(x) - 1)){
        #Create a flag for the last iteration
        #since max_i and idx are going to change
        is_last_iteration <- i == (length(x) - 1)

        #Create vectors with current x and y
        x_i <- x[i: (i + 1)]
        y_i <- y[i: (i + 1)]

        if (is_last_iteration){
            #Calculate the maximum value of x to extrapolate
            max_i <- max(x_to_predict)
            #Which x's can be predicted in the x_to_predict range?
            idx <- x_to_predict >= x_i[2] & x_to_predict <= max_i
        }else{
            #Calculate the maximum value of x to extrapolate
            max_i <- x[i + 2]
            #Which x's can be predicted in the x_to_predict range?
            idx <- x_to_predict >= x_i[2] & x_to_predict < max_i
        }

        #This values can be predicted
        x_i_to_predict <- x_to_predict[idx]
        #Remove values from the x_to_predict
        x_to_predict <- x_to_predict[!idx]
        #Extrapolate
        #print(paste("Approx:", x_i, y_i, sep="*"))
        preds <- approxExtrap(x_i, y_i, xout=x_i_to_predict)

        #Create temporal data frame
        tmp <- data.frame(x=preds$x, y=preds$y)

        #Add predictions to the data frame
        res <- rbind(res, tmp)

    }


    #Order result
    res <- res[order(res$x), ]

    #Rename columns to original values
    names(res)[names(res) == "x"] <- x_name
    names(res)[names(res) == "y"] <- y_name

    #Fill rest of columns
    #Check that all values are the same for the rest of the columns!
    #point_columns <- c(x_name, y_name)

    #for(col_name in setdiff(names(df), point_columns)){
    #    res[[col_name]] <- df[1, col_name]
    #}

    return(res)
}