library(ggplot2)
source("na_regression_filer.R")

plot_na_fillers <- function(df, independent_var, dependent_var, x_to_predict){
    formula <- as.formula(paste(independent_var, dependent_var, sep="~"))
    #Loess model
    model_loess <- loess(formula,
                        span=0.8, data=df,
                        control=loess.control(surface="direct"))
    pred_loess <- predict(model_loess,
                          data.frame(independent_var=x_to_predict))

    #Linear model
    model_linear <- lm(formula, data=df)
    pred_linear <- predict(model_linear,
                          data.frame(independent_var=x_to_predict))

    #Interpolation


    #Linear predictions
    pred_linear_df <- data.frame(independent_var=x_to_predict,
                           dependent_var=pred_linear,
                           type="linear")
    #loess predictions
    pred_loess_df <- data.frame(independent_var=x_to_predict,
                             dependent_var=pred_loess,
                             type="loess")
    #Interpolation
    #inter_pred <- data.frame(year=inter$x, total_population=inter$y,
    #                         type="inter")

    #Actual values
    actual <- df[, c()]
    actual$type <- "actual"
    plot_data <- rbind(pred_linear_df, pred_loess_df, actual)

    ggplot(plot_data, aes(x=independent_var,
                          y=dependent_var,
                          color=type)) + geom_point(shape=1)
}


library(plyr)

#Check how many observations per municipality
year_list <- character()
d_ <- d[,c("cve", "year", "female-headed_households")]
for(current_cve in unique(d_$cve)){
    data <- subset(d_, cve == current_cve)
    data <- data[complete.cases(data),]
    years <- data$year
    string <- ""
    for (year in years){
        string <- paste(string, year)
    }
    year_list <- append(year_list, string)
}
table(year_list)


#Subset the data
data <- subset(d, cve == "32048")
x <- 1995:2015


y.loess <- loess(total_population ~ year,
                span=0.8, data=data,
                control=loess.control(surface="direct"))
y.predict <- predict(y.loess, data.frame(year=x))
y.linear <- lm(total_population ~ year, data=data)
print(summary(y.linear)$sigma)
y.lin.predict <- predict(y.linear, data.frame(year=x))


#Using the interpolation method
inter <- fill_nas_linear_interpolation(data,
                                        "cve",
                                        "year",
                                        "total_population",
                                        x)

#Create a dataframe with linear predictions
lin_pred <- data.frame(year=x, total_population=y.lin.predict, type="linear")
#loess predictions
loess_pred <- data.frame(year=x, total_population=y.predict, type="loess")
#Interpolation
inter_pred <- data.frame(year=inter$x, total_population=inter$y, type="inter")
#Actual values
actual <- data.frame(year=x, type="actual")
actual <- join(actual, data[, c("year", "total_population")], by="year")
plot_data <- rbind(lin_pred, loess_pred, inter_pred, actual)

ggplot(plot_data, aes(x=year,
                      y=total_population,
                      color=type)) + geom_point(shape=1)


source("../../useful_scripts/na_regression_filler.R")
d__ <- d[,c("cve", "year", "total_population", "median_age")]
cves <- unique(d__$cve)
sub <- subset(d__, cve %in% cves)

# est <- fill_nas_linear_interpolation(
#          sub, "cve",
#          "year",
#          "total_population",
#          1995:2015)

pop <- data.frame()
for (column_name in names(d__)[3:length(d__)]){
  est <- fill_nas_linear_interpolation(d, "cve",
         "year",
         column_name,
         1995:2015)
  pop <- rbind(pop, est)
}

est1 <- fill_nas_linear_interpolation(d, "cve",
         "year",
         names(d__)[3],
         1995:2015)

est1_ <- fill_nas_linear_interpolation(d__, "cve",
         "year",
         names(d__)[3],
         1995:2015)

est2 <- fill_nas_linear_interpolation(d, "cve",
         "year",
         names(d__)[4],
         1995:2015)
pop_ <- rbind(est1, est2)

sub
subset(pop, x %in% c(1995, 2000, 2005, 2010) & cve %in% cves)

head(subset(est1, x %in% c(1995, 2000, 2005, 2010) & cve %in% cves))
head(subset(est1_, x %in% c(1995, 2000, 2005, 2010) & cve %in% cves))

subset(est2, x %in% c(1995, 2000, 2005, 2010) & cve %in% cves)
subset(pop_, x %in% c(1995, 2000, 2005, 2010) & cve %in% cves)






names(est)[names(est) == "x" ] <- "year"
names(est)[names(est) == "y" ] <- "total_population"

est$column_name <- NULL
est$type <- "interpolation"
sub$type <- "actual"
plot_data <- rbind(est, sub)

ggplot(plot_data, aes(x=year,
                      y=total_population,
                      color=type)) + geom_point(shape=1)


test <- subset(df, cve=="09000" & indicator=="total_population")
test[order(test$year),]
test <- subset(d_, cve=="09000")
test <- test[, c("cve", "year", "total_population_estimation")]
subset(test, year %in% c(1995, 2000, 2005, 2010))