fill_nas_linear_interpolation <- function(df, x_name, y_name, x_to_predict){
    #Subset df to only keep columns of interest
    #df <- df[, c(split_factor, x_name, y_name)]

    #Rename df columns
    names(df)[names(df) == x_name] <- "x"
    names(df)[names(df) == y_name] <- "y"

    #Create empty data frame
    res <- data.frame()

    #Get only complete cases (with values for x and y)
    points <- df[, c("x", "y")]
    sub <- df[complete.cases(points), ]

    x <- sub$x
    y <- sub$y

    #Check if you have at least two points
    if(length(x) < 2 | length(x) < 2){
        print(paste0("Cant interpolate with a less than two points, ",
                "skipping interpolation."))
        return(data.frame())
    }

    if(length(x) != length(y)){
        print(paste0("Different number of x's and y's skipping interpolation."))
        return(data.frame())
    }

    #Do linear interpolations with every pair
    #of consecutive points
    for(i in 1:(length(x) - 1)){
        #Create vectors with current x and y
        x_i <- x[i: (i + 1)]
        y_i <- y[i: (i + 1)]
        #Which x's can be predicte in the x_to_predict range?
        idx <- x_to_predict >= min(x_i) & x_to_predict <= max(x_i)
        #This values can be predicted
        x_i_to_predict <- x_to_predict[idx]
        #Remove values from the x_to_predict
        x_to_predict <- x_to_predict[!idx]
        #Interpolate
        preds <- approx(x_i, y_i, xout=x_i_to_predict)

        #Create temporal data frame
        tmp <- data.frame(x=preds$x, y=preds$y)

        #Add predictions to the data frame
        res <- rbind(res, tmp)

    }

    #Subset result for current id
    res_sub <- res
    #Order by increasing x
    res_sub <- res_sub[order(res_sub$x), ]

    #Check if there are still x's to predict
    #if yes, it should be because they do not
    #fall inside the range of the original data
    if(length(x_to_predict) > 0){
        #Check is it's needed to predict forward
        #print("Checking interpolation limits...")
        if(max(x_to_predict) > max(res_sub$x)){
            #print("Forward interpolation...")
            ##Do linear regression for the highest x values using the two
            #previous points
            #Get the highest x_to_predict value
            x <- tail(res_sub, 2)$x
            y <- tail(res_sub, 2)$y
            x_i_to_predict <- max(x):max(x_to_predict)
            m <- lm(y~x)
            preds <- predict(m, data.frame(x=x_i_to_predict))
            #Add rows to the data frame
            tmp <- data.frame(x=x_i_to_predict, y=preds)

            #Drop prediction used to create the linear model
            tmp <- tmp[2:nrow(tmp), ]
            #Append rows to the data frame
            res <- rbind(res, tmp)
        }

        #Check if it's needed to predict backward
        if(min(x_to_predict) < min(res_sub$x)){
            #print("Backward interpolation...")
            #Do linear regression for the lowest x values using the two
            #following points
            x <- head(res_sub, 2)$x
            y <- head(res_sub, 2)$y
            x_i_to_predict <- min(x_to_predict):min(x)
            m <- lm(y~x)
            preds <- predict(m, data.frame(x=x_i_to_predict))
            #Create tmp data frame
            tmp <- data.frame(x=x_i_to_predict, y=preds)
            #Add split column
            #tmp[split_factor] <- current_id
            #Add column name that was estimate
            #tmp["column_name"] <- y_name
            #Drop prediction used to create the linear model
            tmp <- tmp[1:(nrow(tmp) - 1), ]
            #Add rows to main data frame
            res <- rbind(res, tmp)
        }
    }

    #Order result
    res <- res[order(res$x), ]

    #Rename columns to original values
    names(res)[names(res) == "x"] <- x_name
    names(res)[names(res) == "y"] <- y_name

    #Fill rest of columns
    #Check that all values are the same for the rest of the columns!
    point_columns <- c(x_name, y_name)

    for(col_name in setdiff(names(df), point_columns)){
        res[[col_name]] <- df[1, col_name]
    }

    return(res)

}


# test <- data.frame(x=1:10, y=1:10, type="data", otherType="moreData")
# fill_nas_linear_interpolation(test, "x", "y", 1:15)

# x_ <- c(NA,2,3,4,5,6,7,NA,9,10)
# y_ <- c(NA,2,3,4,5,6,7,8,9,10)
# test <- data.frame(x=x_, y=y_, type="data", otherType="moreData")
# fill_nas_linear_interpolation(test, "x", "y", 1:15)