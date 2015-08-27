#Fill rows using a linear model
#Input:
#   data frame - Data frame contaning columns to fill nas
#   split_column - Name of the column used to split observations
#   formula - Formula used for regression
#   values to estimate for - Vector of X to get estimations
#Oputput:
#   data frame (split_column, variable, estimation)

fill_nas_regression <- function(df, split_column, formula, x){
    no_nas_df <- data.frame()
    y_name <- as.character(formula)[[2]]
    #Iterate over all ids
    for(current_id in unique(df[[split_column]])){
        #Subset data for a single municipality
        sub <- df[df[[split_column]] == current_id,]

        #Fit a linear model, if possible
        tryCatch({
            model <- lm(formula, sub)
            #Get R^2 metric
            r_2 <- summary(model)$r.squared
            if(r_2 < 0.8){
                print(paste("R^2: ",
                                    r_2,
                                    current_id,
                                    split_column))
            }

            #Estimate values
            estimation <- predict(model, data.frame(year=x))
            #Create data frame
            fit <- data.frame(x, estimation)
            #Add split column
            fit[split_column] <- current_id
            #Add column name that was estimate
            fit["estimated_column"] <- y_name
            #Add rows to data frame
            no_nas_df <- rbind(no_nas_df, fit)
        }
        , warning = function(w) {
            # print(paste0("Warning: ",
            #              w, " ",
            #              current_id, " ",
            #              as.character(formula),
            #              ))
        }
        , error = function(e) {
            # print(paste0("Error: ",
            #              e, " ",
            #              current_id, " ",
            #              as.character(formula),
            #              ))
        })
    }
    no_nas_df
}

fill_nas_loess_regression <- function(df, split_column, formula, x){
    no_nas_df <- data.frame()

    #Iterate over all ids
    for(current_id in unique(df[[split_column]])){
        #Subset data for a single municipality
        sub <- df[df[[split_column]] == current_id,]

        #Fit a linear model, if possible
        tryCatch({
            model <- loess(formula, span=1.0, data=sub,
                    control=loess.control(surface="direct"))
            #Estimate values
            estimation <- predict(model, data.frame(year=x))
            #Create data frame
            fit <- data.frame(x, estimation)
            #Add split column
            fit[split_column] <- current_id
            #Add column name that was estimate
            fit["estimated_column"] <- as.character(formula)[[2]]
            #Add rows to data frame
            no_nas_df <- rbind(no_nas_df, fit)
        }
        , warning = function(w) {
            print(paste0("Warning: ",
                         w, " ",
                         current_id, " ",
                         as.character(formula),
                         ))
        }
        , error = function(e) {
            print(paste0("Error: ",
                         e, " ",
                         current_id, " ",
                         as.character(formula),
                         ))
        })
    }
    no_nas_df
}

fill_nas_linear_interpolation <- function(df, split_factor, x_name, y_name,
                                          x_to_predict){
    #Subset df to only keep columns of interest
    df <- df[,c(split_factor, x_name, y_name)]

    #Rename df columns
    names(df)[names(df) == x_name] <- "x"
    names(df)[names(df) == y_name] <- "y"
    #Create empty data frame
    res <- data.frame()

    #Create a copy of the x_to_predict vector
    #so following interpolations don't have an empty vector
    x_to_predict_copy <- x_to_predict

    #Iterate over all ids (cves)
    for(current_id in unique(df[[split_factor]])){
        #print(current_id)
        #Reset x_to_predict vector
        x_to_predict <- x_to_predict_copy

        #Subset data for a single municipality
        sub <- df[df[[split_factor]] == current_id,]
        #Get only complete cases
        sub <- sub[complete.cases(sub),]
        #print("SUB"); print(sub)
        x <- sub$x
        y <- sub$y
        #Check if you have at least two points
        if(length(x)<2){
            print(paste0("Cant interpolate with a less than two points, ",
                    "skipping interpolation."))
            next
        }

        #print(paste(current_id, y_name))
        #print(sub)

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

            #print("TMP"); print(current_id); print(tmp)

            #Add split column
            tmp[split_factor] <- current_id
            #Add column name that was estimate
            tmp["column_name"] <- y_name

            #Add predictions to the data frame
            res <- rbind(res, tmp)

        }

        #Subset result for current id
        res_sub <- res[res[[split_factor]] == current_id,]
        #Order by increasing x
        res_sub <- res_sub[order(res_sub$x),]

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
                #Add split column
                tmp[split_factor] <- current_id
                #Add column name that was estimate
                tmp["column_name"] <- y_name
                #Drop prediction used to create the linear model
                tmp <- tmp[2:nrow(tmp),]
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
                tmp[split_factor] <- current_id
                #Add column name that was estimate
                tmp["column_name"] <- y_name
                #Drop prediction used to create the linear model
                tmp <- tmp[1:(nrow(tmp) - 1),]
                #Add rows to main data frame
                res <- rbind(res, tmp)
            }
        }
    }
    #Order result
    res <- res[order(res[[split_factor]], res$x),]
    
    #Rename columns to original values
    #names(res)[names(res) == "x"] <- x_name
    #names(res)[names(res) == "y"] <- y_name

    return(res)

}