library(dplyr)
library(readr)
library(stringr)
library(Hmisc)
library(ggplot2)



gdata <- read_tsv('guitars_strat.txt')

gtbl <- as.tbl(gdata)

### data cleaning
#fix nulls
gtbl[gtbl == "null"] = NA
#get rid of duplicates
gtbl <- gtbl %>% unique

#create age variable
gtbl <- gtbl %>% 
  mutate(age = 2018 - as.numeric(year))

#convert price to numeric

gtbl$price <- as.numeric(gsub("[\\$,]", "", gtbl$price))

#convert shipping to numeric
gtbl$shipping <- ifelse(grepl("Free",gtbl$shipping),'0',as.numeric(str_extract(gtbl$shipping,'[0-9]+')))

#convert handed
gtbl$handed.code <- factor(gtbl$handed, levels=c("Right Handed","Left Handed"), labels=c(0,1))
gtbl$handed.code <- as.integer(as.character(gtbl$handed.code))

#create pickups column
gtbl$pickups <- ifelse(grepl('hss', gtbl$title),'hss','sss')

#clean finish variable
#
gtbl$finish <- tolower(gtbl$finish)
gtbl$finish <- ifelse(grepl('burst',gtbl$finish), 'sunburst', gtbl$finish)
gtbl$finish <- ifelse(grepl('red',gtbl$finish), 'red', gtbl$finish)
gtbl$finish <- ifelse(grepl('white',gtbl$finish), 'white', gtbl$finish)
gtbl$finish <- ifelse(grepl('black',gtbl$finish), 'black', gtbl$finish)
gtbl$finish <- ifelse(grepl('natural',gtbl$finish), 'natural', gtbl$finish)
finish_list = c('white', 'sunburst','red','natural','black')
gtbl$new.finish <- ifelse(gtbl$finish %in% finish_list, gtbl$finish,'other')
#

#clean fretboard material
gtbl$title <- gsub('[[:punct:] ]+',' ',gtbl$title)
gtbl$title <- tolower(gtbl$title)
gtbl$fretboard_material <- tolower(gtbl$fretboard_material)
gtbl$fretboard_material <- ifelse(grepl('maple', gtbl$title), 
                                  'maple',ifelse(grepl('rosewood', gtbl$title),
                                                 'rosewood', gtbl$fretboard_material))
#write out cleaned data
write.table(gtbl, file = "clean_guitar_data.txt", sep = "\t",
            row.names = TRUE, col.names = NA)

#look at strats <3000
pricetbl <- gtbl %>% filter(price < 3000)

### End cleaning

##price and age relationship
#scatterplot for price and age
ggplot(pricetbl, aes(x=age, y=(price))) + 
  geom_point(shape=1) + 
  theme_minimal() +
  geom_smooth(method = "loess", se = F) + 
  labs(x="Age", 
       y="Price", 
       title="Scatterplot")

#polynomial model
model <- lm(price ~ age + I(age^2), data = pricetbl)
summary(model)
plot(model)

#finish model
model2 <- lm(price ~ new.finish, data = pricetbl)
summary(model2)
anova(model2)
par(mfrow=c(2,2))
plot(model2)

#multivariate model?
model4 <- lm(price ~ fretboard_material, data = pricetbl)
summary(model4)


#viz


ggplot(pricetbl, aes(x=reorder(new.finish,price,FUN=median), y=price)) + 
  geom_boxplot(varwidth = T) + 
  theme_minimal() +
  labs(title="Stratocasters under $3000", 
       x="Finish",
       y="Price")

#relationship bewteen age and price means good(used) are worth the most but renders condition insignificant
ggplot(pricetbl %>% filter(condition %in% c('Mint (Used)','Excellent (Used)', 'Very Good (Used)', 'Good (Used)', 'Fair (Used)', 'Brand New (New)')), 
       aes(x=reorder(condition,price,FUN=median), y=price)) + 
  geom_boxplot(varwidth=T) + 
  theme_minimal() +
  labs(title="Fender Stratocasters under $3000", 
       x="Condition",
       y="Price")
anova(lm(price~condition, data = pricetbl))
anova(lm(price~condition + age + condition:age, data = pricetbl))

ggplot(pricetbl, aes(age)) +
  geom_density()+
  labs(title='Age Density',
       subtitle= 'With Median Indicator',
       x = 'Age')+
  geom_vline(aes(xintercept=median(pricetbl$age, na.rm=T)))

ggplot(pricetbl, aes(price)) +
  geom_density()+
  labs(title='Price Density',
       subtitle = 'With Median Indicator',
       x = 'Price')+
  geom_vline(aes(xintercept=median(pricetbl$price)))

 
ggplot(pricetbl, aes(new.finish) ) + 
  geom_bar() + 
  theme_minimal() + 
  labs(title="Finish",
       x='Finish')






