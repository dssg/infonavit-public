rm(list=ls())
library(RPostgreSQL)

library(ggplot2)
library(grid)
library(ExtremeBounds)



load("/mnt/scratch/master_v2/test_data08_12.rda")

head(test_data)
attach(test_data)

test_data$cv_credito <- NULL
test_data$cur_year <- NULL
test_data$cur_year <- NULL
test_data$abandon_year <- NULL
test_data$abandon_month <- NULL
test_data$abandon_past <- NULL
test_data$cv_credito <- NULL
test_data$coloniaid <- NULL
test_data$cur_year <- NULL
test_data$colonia_num_loans <- NULL
test_data$colonia_num_abd <- NULL
test_data$abandoned <- NULL
test_data$mun_region <- NULL
test_data$mun_geo_zone <- NULL
test_data$colonia_abd_percent <- NULL

#log distance measures
test_data[grep("no_", names(test_data))]<-log(test_data[grep("no_", names(test_data))]+1)

#robust standard error caclulation
library("sandwich")
se.robust <- function(model.object) {
	  model.fit <- vcovHC(model.object, type = "HC")
  out <- sqrt(diag(model.fit))
    return(out)
}

#Keep rows that dont have nas
idx <- rowSums(is.na(test_data)) == 0
test_data <- test_data[idx,]

idx_aban <- test_data['abandoned_y'] == 1
test_data_aban = test_data[idx_aban,]
dim(test_data_aban)

idx_not_aban <- test_data['abandoned_y'] == 0
test_data_notaban = test_data[idx_not_aban,]
dim(test_data_notaban)

test_data_notaban_sample = test_data_notaban[sample(nrow(test_data_notaban), 50000), ]
dim(test_data_notaban_sample)


test_data_total <- rbind(test_data_aban,test_data_notaban_sample) 
dim(test_data_total)
rm(test_data)
rm(test_data_aban)
rm(test_data_notaban)
rm(test_data_notaban_sample)
rm(idx_aban)
rm(idx_not_aban)
rm(idx)

test_data_total$abandoned_y <- as.factor(test_data_total$abandoned_y)

system.time(

mylogit <- glm(abandoned_y ~ personal_age + loan_sales_price, data = test_data_total,family = "binomial")
)
summary(mylogit)


#define a wrapper for calling the logistic regression in the glm package
logit.funct <- function(formula, data ) {
	  re.logit <- glm(formula=formula, data = data, family = "binomial")
  d <- 1
    return(re.logit)
}

system.time(
restrictive.ebaa <- eba(y = "abandoned_y", doubtful = c((grep("[1-9]+_[1-9]+_*", names(test_data_total),value = TRUE))), data =  test_data_total,  draws =4000, vif = 5, se.fun = se.robust, weights= "lri", k=0:3, reg.fun=logit.funct)
)

print(restrictive.ebaa)

print(restrictive.ebaa)

