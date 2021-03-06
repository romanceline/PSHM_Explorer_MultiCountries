

# pkgs <- c("dplyr",'plotly',"stringr","ggplot2","flextable","readxl","tidyr","ggridges","rmarkdown","RColorBrewer","directlabels","gridExtra")
# for (i in pkgs) {
#     if (!i %in% installed.packages()) {
#     install.packages(i)
#     }
#     library(i, character.only = TRUE)
# }

library(shiny)
library(plotly)
library(dplyr)
library(ggplot2)
library(stringr)
library(flextable)
library(readxl)
library(tidyr)
library(ggridges)
library(directlabels)
library(gridExtra)
library(rmarkdown)
library(RColorBrewer)
library(lubridate)
library(gridExtra)
library(ggpubr)
library(cowplot)
library(shinyjs)
library(ggiraph)
library(zoo)
library(forecast)
library(imputeTS)


### Part 1 - Read all datasets, files involved in the slide deck production

#setwd("C:/Users/romanc/Documents/GitHub/PSHM_Explorer_MultiCountries")

#StringencyIndex<-read.csv('StringencyIndex_.csv',row.names=NULL) %>% mutate(Date=as.Date(Date))
# 
# StringencyIndex_<-data.frame()
# for (country in unique(StringencyIndex$ADM0NAME)){
#   StringencyIndex_Country<-StringencyIndex %>% filter(ADM0NAME==country) %>% arrange(Date)
#   StringencyIndex_Country_<-data.frame()
#   for (date in unique(StringencyIndex_Country$Date)[-1]){
#     if ((StringencyIndex_Country %>% filter(Date==date))$GlobalIndex == (StringencyIndex_Country %>% filter(Date==date-1))$GlobalIndex){
#       Different<-'No'
#     }
#     else {Different<-'Yes'}
#     StringencyIndex_Country_Row<-StringencyIndex_Country %>% filter(Date==date) %>% mutate(Change=Different)
#     StringencyIndex_Country_<-bind_rows(StringencyIndex_Country_Row, StringencyIndex_Country_)
#   }
#   StringencyIndex_<-bind_rows(StringencyIndex_Country_,StringencyIndex_)
# }

#write.csv(StringencyIndex_,'StringencyIndex.csv')
StringencyIndex<-read.csv('StringencyIndex.csv')

StringencyIndex<-StringencyIndex %>% rename(Schools=School,Businesses=Workplace,Movements=StayHome,Borders=Travels) %>% 
  mutate(Date=as.Date(Date)) %>% mutate(ADM0NAME=if_else(ADM0NAME=='Republic of Moldova','Republic Of Moldova',ADM0NAME),
                                        ADM0NAME=if_else(ADM0NAME=='Bosnia and Herzegovina','Bosnia And Herzegovina',ADM0NAME)) %>% 
  arrange(ADM0NAME)

Legend<-read.csv('Legend.csv') %>% pivot_longer(cols=c(X.1:X.100)) %>% select(-c(X,name)) %>% 
  mutate(Country=if_else(Country=='Kosovo','Kosovo(1)',Country))

MyPalette<-c("#008dc9ff", "#d86422ff", "#20313bff", "#d4aa7dff", "#197278ff","#686868", "#f2545bff", "#90a9b7ff", "#224870ff", "#66a182ff", "#885053ff")

KeyDates_SeverityIndex<-read_excel('KeyDates.xlsx',sheet='Severity Index') %>% 
  mutate(Date=as.Date(parse_date_time(Date,c("dmy", "ymd","mdy")))) %>% 
  select(Date,ADM0NAME,Narrative_All) %>% 
  mutate(ADM0NAME=if_else(ADM0NAME=='Republic of Moldova','Republic Of Moldova',ADM0NAME),
         ADM0NAME=if_else(ADM0NAME=='Bosnia and Herzegovina','Bosnia And Herzegovina',ADM0NAME))
KeyDates_Schools<-read_excel('KeyDates.xlsx',sheet='Schools') %>% 
  mutate(Date=as.Date(parse_date_time(Date,c("dmy", "ymd","mdy")))) %>% 
  select(Date,ADM0NAME,Narrative_Schools) %>% 
  mutate(ADM0NAME=if_else(ADM0NAME=='Republic of Moldova','Republic Of Moldova',ADM0NAME),
         ADM0NAME=if_else(ADM0NAME=='Bosnia and Herzegovina','Bosnia And Herzegovina',ADM0NAME))
KeyDates_Masks<-read_excel('KeyDates.xlsx',sheet='Masks') %>% 
  mutate(Date=as.Date(parse_date_time(Date,c("dmy", "ymd","mdy")))) %>% 
  select(Date,ADM0NAME,Narrative_Masks) %>% 
  mutate(ADM0NAME=if_else(ADM0NAME=='Republic of Moldova','Republic Of Moldova',ADM0NAME),
         ADM0NAME=if_else(ADM0NAME=='Bosnia and Herzegovina','Bosnia And Herzegovina',ADM0NAME))
KeyDates_Businesses<-read_excel('KeyDates.xlsx',sheet='Businesses') %>% 
  mutate(Date=as.Date(parse_date_time(Date,c("dmy", "ymd","mdy")))) %>% 
  select(Date,ADM0NAME,Narrative_Businesses) %>% 
  mutate(ADM0NAME=if_else(ADM0NAME=='Republic of Moldova','Republic Of Moldova',ADM0NAME),
         ADM0NAME=if_else(ADM0NAME=='Bosnia and Herzegovina','Bosnia And Herzegovina',ADM0NAME))
KeyDates_Movements<-read_excel('KeyDates.xlsx',sheet='Movements') %>% 
  mutate(Date=as.Date(parse_date_time(Date,c("dmy", "ymd","mdy")))) %>% 
  select(Date,ADM0NAME,Narrative_Movements)
KeyDates_Borders<-read_excel('KeyDates.xlsx',sheet='Borders') %>% 
  mutate(Date=as.Date(parse_date_time(Date,c("dmy", "ymd","mdy")))) %>% 
  select(Date,ADM0NAME,Narrative_Borders) %>% 
  mutate(ADM0NAME=if_else(ADM0NAME=='Republic of Moldova','Republic Of Moldova',ADM0NAME),
         ADM0NAME=if_else(ADM0NAME=='Bosnia and Herzegovina','Bosnia And Herzegovina',ADM0NAME))
KeyDates_Gatherings<-read_excel('KeyDates.xlsx',sheet='Gatherings') %>% 
  mutate(Date=as.Date(parse_date_time(Date,c("dmy", "ymd","mdy"))))%>% 
  select(Date,ADM0NAME,Narrative_Gatherings) %>% 
  mutate(ADM0NAME=if_else(ADM0NAME=='Republic of Moldova','Republic Of Moldova',ADM0NAME),
         ADM0NAME=if_else(ADM0NAME=='Bosnia and Herzegovina','Bosnia And Herzegovina',ADM0NAME))


MainDataset<-read.csv("qry_covid_running_cases_country_date_.CSV") %>% 
  mutate(ADM0NAME=str_to_title(ADM0NAME),
         DateReport1=as.Date(parse_date_time(DateReport1,c("dmy", "ymd","mdy")))) %>% 
  mutate(ADM0NAME=if_else(ADM0NAME=='Kosovo','Kosovo(1)',ADM0NAME))

PopulationDataset<-read.csv('ref_Country.csv') %>% select(ADM0NAME,UNPOP2019) %>% mutate(ADM0NAME=str_to_title(ADM0NAME))

MainDataset<-MainDataset %>% left_join(StringencyIndex,by=c("ADM0NAME" = "ADM0NAME", "DateReport1" = "Date")) %>%
  left_join(KeyDates_SeverityIndex,by=c("ADM0NAME" = "ADM0NAME", "DateReport1" = "Date")) %>%
  left_join(KeyDates_Masks,by=c("ADM0NAME" = "ADM0NAME", "DateReport1" = "Date")) %>%
  left_join(KeyDates_Schools,by=c("ADM0NAME" = "ADM0NAME", "DateReport1" = "Date")) %>%
  left_join(KeyDates_Businesses,by=c("ADM0NAME" = "ADM0NAME", "DateReport1" = "Date")) %>%
  left_join(KeyDates_Borders,by=c("ADM0NAME" = "ADM0NAME", "DateReport1" = "Date")) %>%
  left_join(KeyDates_Gatherings,by=c("ADM0NAME" = "ADM0NAME", "DateReport1" = "Date")) %>%
  left_join(KeyDates_Movements,by=c("ADM0NAME" = "ADM0NAME", "DateReport1" = "Date"))

# MainDataset<-StringencyIndex %>% left_join(MainDataset,by=c("ADM0NAME" = "ADM0NAME", "Date" = "DateReport1")) %>% 
#   left_join(KeyDates_SeverityIndex,by=c("ADM0NAME" = "ADM0NAME", "Date" = "Date")) %>% 
#   left_join(KeyDates_Masks,by=c("ADM0NAME" = "ADM0NAME", "Date" = "Date")) %>% 
#   left_join(KeyDates_Schools,by=c("ADM0NAME" = "ADM0NAME", "Date" = "Date")) %>% 
#   left_join(KeyDates_Businesses,by=c("ADM0NAME" = "ADM0NAME", "Date" = "Date")) %>% 
#   left_join(KeyDates_Borders,by=c("ADM0NAME" = "ADM0NAME", "Date" = "Date")) %>% 
#   left_join(KeyDates_Gatherings,by=c("ADM0NAME" = "ADM0NAME", "Date" = "Date")) %>% 
#   left_join(KeyDates_Movements,by=c("ADM0NAME" = "ADM0NAME", "Date" = "Date"))
  
RelativeDays<-function(ctr){
  DatasetCountry<-MainDataset %>% filter(ADM0NAME==ctr)
  minDateAll<-min((DatasetCountry %>% filter(!is.na(Narrative_All)))$DateReport1)
  minDateSchools<-min((DatasetCountry %>% filter(!is.na(Narrative_Schools)))$DateReport1)
  minDateMasks<-min((DatasetCountry %>% filter(!is.na(Narrative_Masks)))$DateReport1)
  minDateGatherings<-min((DatasetCountry %>% filter(!is.na(Narrative_Gatherings)))$DateReport1)
  minDateBusinesses<-min((DatasetCountry %>% filter(!is.na(Narrative_Businesses)))$DateReport1)
  minDateBorders<-min((DatasetCountry %>% filter(!is.na(Narrative_Borders)))$DateReport1)
  minDateMovements<-min((DatasetCountry %>% filter(!is.na(Narrative_Movements)))$DateReport1)
  DatasetCountry<-DatasetCountry %>% mutate(Days_All=DateReport1-minDateAll) %>% 
    mutate(Days_Schools=as.numeric(DateReport1-minDateSchools)) %>% 
    mutate(Days_Masks=as.numeric(DateReport1-minDateMasks)) %>% 
    mutate(Days_Gatherings=as.numeric(DateReport1-minDateGatherings)) %>% 
    mutate(Days_Movements=as.numeric(DateReport1-minDateMovements)) %>% 
    mutate(Days_Borders=as.numeric(DateReport1-minDateBorders)) %>% 
    mutate(Days_Businesses=as.numeric(DateReport1-minDateBusinesses))
  return(DatasetCountry)
} 
              

BuildNewDataset<-function(ctr){
  CountryDataset<-RelativeDays(ctr) 
  CountryDataset_<-data.frame()
  for (date in unique(CountryDataset$DateReport1)){
    valueYesterday_Cases<-(CountryDataset %>% filter(DateReport1==date-1))$NewCases
    valueToday_Cases<-(CountryDataset %>% filter(DateReport1==date))$NewCases
    valueTomorrow_Cases<-(CountryDataset %>% filter(DateReport1==date+1))$NewCases
    MovingAverage_Cases<-(valueYesterday_Cases[1]+valueToday_Cases[1]+valueTomorrow_Cases[1])/3
    valueYesterday_Deaths<-(CountryDataset %>% filter(DateReport1==date-1))$NewDeaths
    valueToday_Deaths<-(CountryDataset %>% filter(DateReport1==date))$NewDeaths
    valueTomorrow_Deaths<-(CountryDataset %>% filter(DateReport1==date+1))$NewDeaths
    MovingAverage_Deaths<-(valueYesterday_Deaths[1]+valueToday_Deaths[1]+valueTomorrow_Deaths[1])/3
    CountryDataset_Atdate<-CountryDataset %>% filter(DateReport1==date)
    CountryDataset_Atdate$ThreeDaysAverage_Cases<- MovingAverage_Cases
    CountryDataset_Atdate$ThreeDaysAverage_Deaths<- MovingAverage_Deaths
    CountryDataset_<-bind_rows(CountryDataset_,CountryDataset_Atdate)
  }
  CountryDataset_<-CountryDataset_ %>% select(-c("WHO_Code","TotalCases","TotalDeaths","epiWeek")) %>% 
    mutate(log10_MovingAverage_Cases=log10(ThreeDaysAverage_Cases),
           log10_MovingAverage_Deaths=log10(ThreeDaysAverage_Deaths))
  return(CountryDataset_)
}

DatasetToSmooth<-function(ctr){
  CountryDataset<-BuildNewDataset(ctr)
  CountryDataset<-CountryDataset %>% mutate(log_cases=log10(NewCases),log_deaths=log10(NewDeaths))}


DatasetWithSplineValues<-function(ctr){
  CountryDataset<-DatasetToSmooth(ctr)
  CountryDataset_Cases<-DatasetToSmooth(ctr) %>% filter(!is.na(ThreeDaysAverage_Cases)) %>% select(DateReport1,ThreeDaysAverage_Cases)
  CountryDataset_Deaths<-DatasetToSmooth(ctr) %>% filter(!is.na(ThreeDaysAverage_Deaths)) %>% select(DateReport1,ThreeDaysAverage_Deaths)
  CountryDataset_logCases<-DatasetToSmooth(ctr) %>% filter(!is.na(log10_MovingAverage_Cases)) %>% 
    select(DateReport1,log10_MovingAverage_Cases) %>% filter(log10_MovingAverage_Cases!=-Inf)
  CountryDataset_logDeaths<-DatasetToSmooth(ctr) %>% filter(!is.na(log10_MovingAverage_Deaths)) %>% 
    select(DateReport1,log10_MovingAverage_Deaths) %>% filter(log10_MovingAverage_Deaths!=-Inf)
  Spline_3DaysAverageCases<-smooth.spline(x=CountryDataset_Cases$DateReport1,y=CountryDataset_Cases$ThreeDaysAverage_Cases,spar=0.5)
  Spline_3DaysAverageDeaths<-smooth.spline(x=CountryDataset_Deaths$DateReport1,y=CountryDataset_Deaths$ThreeDaysAverage_Deaths,spar=0.5)
  Spline_3DaysAverage_LogCases<-smooth.spline(x=CountryDataset_logCases$DateReport1,y=CountryDataset_logCases$log10_MovingAverage_Cases,spar=0.5)
  Spline_3DaysAverage_LogDeaths<-smooth.spline(x=CountryDataset_logDeaths$DateReport1,y=CountryDataset_logDeaths$log10_MovingAverage_Deaths,spar=0.5)
  ValuesSpline_3DaysAverageCases<-data.frame(SplineValue_3DaysAverageCases=predict(Spline_3DaysAverageCases,deriv=0))
  ValuesSpline_3DaysAverageDeaths<-data.frame(SplineValue_3DaysAverageDeaths=predict(Spline_3DaysAverageDeaths,deriv=0))
  ValuesSpline_3DaysAverage_LogCases<-data.frame(SplineValue_3DaysAverage_LogCases=predict(Spline_3DaysAverage_LogCases,deriv=0))
  ValuesSpline_3DaysAverage_LogDeaths<-data.frame(SplineValue_3DaysAverage_LogDeaths=predict(Spline_3DaysAverage_LogDeaths,deriv=0))
  CountryDataset_Cases<-data.frame(CountryDataset_Cases,ValuesSpline_3DaysAverageCases) %>% 
    select(DateReport1,"Spline_3DaysAverageCases"="SplineValue_3DaysAverageCases.y")
  CountryDataset_Deaths<-data.frame(CountryDataset_Deaths,ValuesSpline_3DaysAverageDeaths) %>% 
    select(DateReport1,"Spline_3DaysAverageDeaths"="SplineValue_3DaysAverageDeaths.y")
  CountryDataset_logCases<-data.frame(CountryDataset_logCases,ValuesSpline_3DaysAverage_LogCases) %>% 
    select(DateReport1,"Spline_3DaysAverage_logCases"="SplineValue_3DaysAverage_LogCases.y")
  CountryDataset_logDeaths<-data.frame(CountryDataset_logDeaths,ValuesSpline_3DaysAverage_LogDeaths) %>% 
    select(DateReport1,"Spline_3DaysAverage_logDeaths"="SplineValue_3DaysAverage_LogDeaths.y")
  CountryDataset_<-CountryDataset %>% 
    left_join(CountryDataset_Cases,by='DateReport1') %>% 
    left_join(CountryDataset_Deaths,by='DateReport1') %>% 
    left_join(CountryDataset_logCases,by='DateReport1') %>% 
    left_join(CountryDataset_logDeaths,by='DateReport1') 
  
  x <- zoo(CountryDataset_$Spline_3DaysAverage_logCases,CountryDataset_$DateReport1)
  x <- na_interpolation(x, option = "linear") %>% fortify.zoo
  
  y <- zoo(CountryDataset_$Spline_3DaysAverage_logDeaths,CountryDataset_$DateReport1)
  y <- na_interpolation(y, option = "linear") %>% fortify.zoo
  
  CountryDataset_<-CountryDataset_ %>% left_join(x,by=c('DateReport1'='Index')) %>% rename(Spline_3DaysAverage_logCases_='.')
  CountryDataset_<-CountryDataset_ %>% left_join(y,by=c('DateReport1'='Index')) %>% rename(Spline_3DaysAverage_logDeaths_='.')
  
  
  return(CountryDataset_)
  }


CheckAtLeast4Values<-function(){
  ListCountriesOkToSpline<-data.frame()
  for (ctr in unique(MainDataset$ADM0NAME)){
    CountryDataset<-MainDataset %>% filter(ADM0NAME==ctr)
    CountryDataset<-CountryDataset %>% filter(NewDeaths!=0)
    if ((nrow(CountryDataset)) > 3){
      ListCountriesOkToSpline<-c(ctr,ListCountriesOkToSpline)}
  }
  return(ListCountriesOkToSpline)}


# GlobalDataset_<-data.frame()
# for (ctr in CheckAtLeast4Values()){
#   GlobalDataset<-DatasetWithSplineValues(ctr)
#   GlobalDataset_<-bind_rows(GlobalDataset_,GlobalDataset)
# }
# 
# GlobalDataset_<-write.csv(GlobalDataset_,'GlobalDataset.csv')

GlobalDataset_<-read.csv('GlobalDataset.csv') %>% mutate(DateReport1=as.Date(DateReport1)) %>% 
  mutate(ADM0NAME=if_else(ADM0NAME=='Kosovo','Kosovo(1)',ADM0NAME))
  
Dataset_Cases_Normal<-GlobalDataset_ %>% select(ADM0NAME,DateReport1,GlobalIndex,Masks,Schools,Businesses,Gatherings,Movements,Borders,
                                                Narrative_All,Narrative_Masks,Narrative_Schools,Narrative_Businesses,Narrative_Borders,Narrative_Gatherings,Narrative_Movements,
                                                Days_All,Days_Schools,Days_Masks,Days_Gatherings,Days_Movements,Days_Borders,Days_Businesses,
                                                RealValue=NewCases,SplineValue=Spline_3DaysAverageCases)
                                                

Dataset_Deaths_Normal<-GlobalDataset_ %>% select(ADM0NAME,DateReport1,GlobalIndex,Masks,Schools,Businesses,Gatherings,Movements,Borders,
                                                 Narrative_All,Narrative_Masks,Narrative_Schools,Narrative_Businesses,Narrative_Borders,Narrative_Gatherings,Narrative_Movements,
                                                 Days_All,Days_Schools,Days_Masks,Days_Gatherings,Days_Movements,Days_Borders,Days_Businesses,
                                                 RealValue=NewDeaths,SplineValue=Spline_3DaysAverageDeaths)

Dataset_Cases_Log<-GlobalDataset_ %>% select(ADM0NAME,DateReport1,GlobalIndex,Masks,Schools,Businesses,Gatherings,Movements,Borders,
                                             Narrative_All,Narrative_Masks,Narrative_Schools,Narrative_Businesses,Narrative_Borders,Narrative_Gatherings,Narrative_Movements,
                                             Days_All,Days_Schools,Days_Masks,Days_Gatherings,Days_Movements,Days_Borders,Days_Businesses,
                                             RealValue=log_cases,SplineValue=Spline_3DaysAverage_logCases_)

Dataset_Deaths_Log<-GlobalDataset_ %>% select(ADM0NAME,DateReport1,GlobalIndex,Masks,Schools,Businesses,Gatherings,Movements,Borders,
                                             Narrative_All,Narrative_Masks,Narrative_Schools,Narrative_Businesses,Narrative_Borders,Narrative_Gatherings,Narrative_Movements,
                                             Days_All,Days_Schools,Days_Masks,Days_Gatherings,Days_Movements,Days_Borders,Days_Businesses,
                                             RealValue=log_deaths,SplineValue=Spline_3DaysAverage_logDeaths_)
  

Dataset_ToPlot<-function(ListCountries,Log,CasesOrDeaths,StartDate,EndDate,Measure,TimeScale){

  if (CasesOrDeaths=='Cases' & Log=='False'){
    Dataset<-Dataset_Cases_Normal
  }
  
  if (CasesOrDeaths=='Cases' & Log=='True'){
    Dataset<-Dataset_Cases_Log 
  }
  
  if (CasesOrDeaths=='Deaths' & Log=='False'){
    Dataset<-Dataset_Deaths_Normal
  }
  
  if (CasesOrDeaths=='Deaths' & Log=='True'){
    Dataset<-Dataset_Deaths_Log
  }
  Dataset<-Dataset %>% filter(ADM0NAME %in% ListCountries) %>% 
    filter(DateReport1>=StartDate,DateReport1<=EndDate)
  
  if (Measure=='Schools'){
    Dataset<-Dataset %>% select(ADM0NAME,DateReport1,Index=Schools,Days=Days_Schools,Narrative=Narrative_Schools,RealValue,SplineValue)
  }
  
  if (Measure=='Masks'){
    Dataset<-Dataset %>% select(ADM0NAME,DateReport1,Index=Masks,Days=Days_Masks,Narrative=Narrative_Masks,RealValue,SplineValue)
  }
  
  if (Measure=='Businesses'){
    Dataset<-Dataset %>% select(ADM0NAME,DateReport1,Index=Businesses,Days=Days_Businesses,Narrative=Narrative_Businesses,RealValue,SplineValue)
  }
  
  if (Measure=='Borders'){
    Dataset<-Dataset %>% select(ADM0NAME,DateReport1,Index=Borders,Days=Days_Borders,Narrative=Narrative_Borders,RealValue,SplineValue)
  }
  
  if (Measure=='Movements'){
    Dataset<-Dataset %>% select(ADM0NAME,DateReport1,Index=Movements,Days=Days_Movements,Narrative=Narrative_Movements,RealValue,SplineValue)
  }
  
  if (Measure=='Gatherings'){
    Dataset<-Dataset %>% select(ADM0NAME,DateReport1,Index=Gatherings,Days=Days_Gatherings,Narrative=Narrative_Gatherings,RealValue,SplineValue)
  }
  
  if (Measure=='All'){
    Dataset<-Dataset %>% select(ADM0NAME,DateReport1,Index=GlobalIndex,Days=Days_All,Narrative=Narrative_All,RealValue,SplineValue)
  }
  if(TimeScale=='Absolute'){
  Dataset<-Dataset %>% mutate(X_axis=DateReport1)}
  if(TimeScale=='Relative'){
    Dataset<-Dataset %>% mutate(X_axis=Days)}
  return(Dataset)
  }
  
  
  
DatesAllowed<-function(ListCountries,StartDate,EndDate,RealValues,Log,CasesOrDeaths,TimeScale,Measure){
  Dataset<-Dataset_ToPlot(ListCountries,Log,CasesOrDeaths,StartDate,EndDate,Measure,TimeScale)
  Points<-Dataset %>% filter(!is.na(Narrative))
  min<-min(Points$DateReport1)
  max<-max(Points$DateReport1)
  return(list=c(minDateAllowed=min,maxDateAllowed=max))
}
  
plotEpi<-function(ListCountries,StartDate,EndDate,RealValues,Log,CasesOrDeaths,TimeScale,Measure){
  if (Measure=='All'){
    alf<-100
  }
  if (Measure!='All'){
    alf<-0
  }
  #Above, little trick so that points on epicurves are invisible if selection isn't PHSM global index
  #Check with PHSM team if they want to develop the pop up for masks, schools, ...
  
  Dataset<-Dataset_ToPlot(ListCountries,Log,CasesOrDeaths,StartDate,EndDate,Measure,TimeScale)
  
  if (CasesOrDeaths=='Cases'){
    ttl<-'Daily Cases \n '
  }
  
  
  if (CasesOrDeaths=='Deaths'){
    ttl<-'Daily Deaths \n '
  }
  
  Points<-Dataset %>% filter(!is.na(Narrative))
  if (RealValues=='Yes'){
    MaxY<-max(pretty(max((Dataset %>% filter(!is.na(RealValue)))$RealValue)))
  }
  
  if (RealValues=='No'){
    MaxY<-max(pretty(max((Dataset %>% filter(!is.na(SplineValue)))$SplineValue)))
  }
  
  
  if (TimeScale=='Absolute'){
    plot<-ggplot(Dataset,aes(x=X_axis,y=SplineValue,group=ADM0NAME,color=ADM0NAME))+
        geom_line(size=0.7)+
        geom_point(data=Points,size=3,alpha=alf)+
        scale_y_continuous(ttl,position='left',breaks=seq(0,MaxY,MaxY/5),labels=seq(0,MaxY,MaxY/5),limits=c(NA,MaxY))+
        theme_minimal()+
        theme(axis.title.x=element_blank(),axis.text.x=element_blank(),axis.title.y.right=element_blank(),
              legend.title=element_text(size=9,face='bold',hjust=0.5),plot.margin = unit(c(1,5,1,5),"lines"))+
        coord_cartesian(clip = 'off')+
        scale_color_manual('Country',breaks=sort(c(unique(Dataset$ADM0NAME))),values=c(MyPalette[1:length(unique(Dataset$ADM0NAME))]))+
        scale_x_date(date_breaks = "15 days",date_labels =  "%d-%b",limits=c(StartDate,EndDate+1))}
  
  
  if (TimeScale=='Relative'){
    
    RelStartDate<-min(Dataset$Days)
    RelMaxDate<-max(Dataset$Days)

    plot<-ggplot(Dataset)+
      geom_line(aes(x=X_axis,y=SplineValue,group=ADM0NAME,color='First implementation of \nthe measure'),linetype=2,size=0.7,show.legend=TRUE)+
      geom_line(size=0.7,aes(x=X_axis,y=SplineValue,group=ADM0NAME,color=ADM0NAME))+
      geom_vline(xintercept = 0, linetype="dashed",show.legend = TRUE)+
      geom_point(data=Points,size=3,aes(x=X_axis,y=SplineValue,group=ADM0NAME,color=ADM0NAME),alpha=alf)+
      scale_y_continuous(ttl,position='left',breaks=seq(0,MaxY,MaxY/5),labels=seq(0,MaxY,MaxY/5),limits=c(NA,MaxY))+
      scale_x_continuous(breaks=c(0,seq(round(RelStartDate/10)*10,RelMaxDate+5,20)),limits=c(RelStartDate,RelMaxDate+1))+
      theme_minimal()+
      theme(axis.title.x=element_blank(),axis.text.x=element_blank(),axis.title.y.right=element_blank(),
            legend.title=element_text(size=9,face='bold',hjust=0.5),plot.margin = unit(c(1,5,1,5),"lines"))+
      coord_cartesian(clip = 'off')+
      scale_color_manual('Country',breaks=c(sort(c(unique(Dataset$ADM0NAME))),'First implementation of \nthe measure'),values=c(MyPalette[1:length(unique(Dataset$ADM0NAME))],'black'),guide="legend")+
      guides(colour=guide_legend(override.aes=list(
      linetype = c(rep("solid",length(unique(Dataset$ADM0NAME))),'dashed'),
      shape=c(rep(NA,length(unique(Dataset$ADM0NAME))),NA),
      size=c(rep(1,length(unique(Dataset$ADM0NAME))),0.5))))}


  if(RealValues=="Yes")
  {plot<-plot+geom_point(aes(x=X_axis,y=RealValue,color=ADM0NAME),shape=3,alpha=0.3,size=1)}
  
  if(Log=="True"){
  plot<-plot+scale_y_continuous(ttl,labels=function(x) round(10^x),position='left')}
  
  return(plot)
}

StartDates<-function(ListCountries){
  AllDates<-(GlobalDataset_ %>% filter(ADM0NAME %in% ListCountries))$DateReport1
  Value<-min(AllDates)
  return(Value)
}

maxDates<-function(ListCountries){
  AllDates<-(GlobalDataset_ %>% filter(ADM0NAME %in% ListCountries))$DateReport1
  Value<-max(AllDates)
  return(Value)
}

Top3_14DaysIncidence<-function() {
  CurrentDate<-max(MainDataset$DateReport1)
  FourteenDaysIncidence_Dataset_ <- data.frame()
  for (ctr in unique(MainDataset$ADM0NAME)){
    FourteenDaysIncidence_Dataset<-data.frame(nrow=1)
    FourteenDaysIncidence_Dataset$ADM0NAME[1]<-as.character(ctr)
    FourteenDaysIncidence_Dataset$Cumul14Days[1]<-((MainDataset %>% filter(ADM0NAME==ctr & DateReport1==CurrentDate))$TotalCases - (MainDataset %>% filter(ADM0NAME==ctr & DateReport1==CurrentDate-14))$TotalCases)
    FourteenDaysIncidence_Dataset_<-bind_rows(FourteenDaysIncidence_Dataset,FourteenDaysIncidence_Dataset_)
  }
  FourteenDaysIncidence_Dataset_ <- FourteenDaysIncidence_Dataset_ %>% 
    left_join(PopulationDataset,by='ADM0NAME') %>% 
    mutate(Incidence=Cumul14Days/UNPOP2019*100000) %>% filter(ADM0NAME %in% unique(GlobalDataset_$ADM0NAME)) %>% 
    arrange(desc(Incidence)) %>% filter(ADM0NAME %in% unique(GlobalDataset_$ADM0NAME)) %>% top_n(3)
  
  return(FourteenDaysIncidence_Dataset_$ADM0NAME)
}  


PlotSeverity<-function(ListCountries,Log,CasesOrDeaths,country_hovered,Date_hovered,StartDate,EndDate,Measure,TimeScale,RealValues){
  
 
  Dataset<-Dataset_ToPlot(ListCountries,Log,CasesOrDeaths,StartDate,EndDate,Measure,TimeScale)
  if (RealValues=='Yes' & Log =='False'){
    MaxValue<-max(pretty(max((Dataset %>% filter(!is.na(RealValue)))$RealValue)))
  }
  
  if (RealValues=='No' & Log =='False'){
    MaxValue<-max(pretty(max((Dataset %>% filter(!is.na(SplineValue)))$SplineValue)))
  }
  
  if (RealValues=='Yes' & Log =='True'){
    MaxValue<-10^(max(pretty(max((Dataset %>% filter(!is.na(RealValue)))$RealValue))))
  }
  
  if (RealValues=='No' & Log =='True'){
    MaxValue<-10^(max(pretty(max((Dataset %>% filter(!is.na(SplineValue)))$SplineValue))))
  }
  
  ttl<-case_when(Measure=='Schools'~ 'Schools Measures \nSeverity',
                                  Measure=='Gatherings'~ 'Gatherings Measures \nSeverity',
                                  Measure=='Movements'~ 'Movements Measures \nSeverity',
                                  Measure=='Borders' ~ 'Int. Travel Measures \nSeverity',
                                  Measure=='Businesses' ~ 'Businesses Measures \nSeverity',
                                  Measure=='Masks' ~ 'Masks Measures \nSeverity',
                                  Measure=='All' ~ 'PHSM Severity \n')
 if (TimeScale=='Absolute'){
    plot_timeline<-ggplot(Dataset,aes(x=X_axis,y=MaxValue,fill=ADM0NAME))+
      geom_raster(stat='identity',position='stack',width=1,aes(alpha=Index/100))+theme(axis.ticks.y=element_blank())+
      scale_fill_manual('Country',breaks=sort(unique(Dataset$ADM0NAME)),values=c(MyPalette[1:length(unique(Dataset$ADM0NAME))]))+
      scale_color_manual('Country',breaks=sort(unique(Dataset$ADM0NAME)))+
      scale_alpha_continuous(range=c(0,1))+
      theme_minimal()+
      theme(axis.title.x=element_blank(),axis.text.y=element_text(color='white'),axis.text.x=element_text(angle = 90),axis.ticks.y=element_blank(),plot.margin = unit(c(1,5,1,5),"lines"))+
      scale_x_date(date_breaks = "15 days",date_labels =  "%d-%b",limits=c(StartDate,EndDate+1))+
      scale_y_continuous(ttl,breaks=MaxValue)+
      coord_cartesian(clip = 'off')+
      annotate("text",x=EndDate+1,y=seq(MaxValue*length(unique(Dataset$ADM0NAME))-MaxValue/2,MaxValue/2,-MaxValue),label=sort(unique(Dataset$ADM0NAME)),color=c(MyPalette[1:length(unique(Dataset$ADM0NAME))]),hjust=0,)+
      guides(fill=FALSE,alpha=FALSE)
    
    if(!is.null(Date_hovered)){
      DatasetToHighlight<-Dataset %>% filter(DateReport1==Date_hovered) %>% mutate(value=if_else(ADM0NAME==country_hovered,100,0))
      DatasetToHighlight<-DatasetToHighlight %>% arrange(desc(ADM0NAME))
      plot_timeline<-plot_timeline+
        geom_bar(data=DatasetToHighlight,stat='identity',position = 'stack',aes(alpha=value/100),width=1,fill='black',color=alpha('black',0))}
    
 }  
  
  if (TimeScale=='Relative'){
    
    AllDays<-(Dataset %>% filter(!(is.na(Days))))$Days
    RelStartDate<-min(AllDays)
    RelMaxDate<-max(AllDays)
    
    Narratives<-Dataset %>% select(Days,ADM0NAME,DateReport1,Narrative,RealValue,SplineValue,X_axis)
    Dataset<-Dataset %>% select(-c(DateReport1,Narrative,RealValue,SplineValue,X_axis)) %>% pivot_wider(names_from = 'Days',values_from='Index') %>%
        replace(., is.na(.), 0) %>%
        pivot_longer(cols=-c(1)) %>% rename(Days=name) %>% mutate(Days=as.numeric(Days)) %>% select(ADM0NAME,Days,Index=value) %>%
        left_join(Narratives,by=c('ADM0NAME'='ADM0NAME','Days'='Days')) %>% mutate(X_axis=Days)
    
    plot_timeline<-ggplot(Dataset,aes(x=X_axis,y=MaxValue,fill=ADM0NAME))+
      geom_raster(stat='identity',position='stack',width=1,aes(alpha=Index/100))+theme(axis.ticks.y=element_blank())+
      scale_fill_manual('Country',breaks=sort(unique(Dataset$ADM0NAME)),values=c(MyPalette[1:length(unique(Dataset$ADM0NAME))]))+
      scale_color_manual('Country',breaks=sort(unique(Dataset$ADM0NAME)))+
      scale_alpha_continuous(range=c(0,1))+
      theme_minimal()+
      scale_x_continuous(breaks=c(0,seq(round(RelStartDate/10)*10,RelMaxDate+5,20)),limits=c(RelStartDate,RelMaxDate+1))+
      scale_y_continuous(ttl,breaks=MaxValue)+
      coord_cartesian(clip = 'off')+
      theme(axis.title.x=element_blank(),axis.text.y=element_text(color='white'),axis.ticks.y=element_blank(),plot.margin = unit(c(1,5,1,5),"lines"))+
      annotate("text",x=RelMaxDate+1,y=seq(MaxValue*length(unique(Dataset$ADM0NAME))-MaxValue/2,MaxValue/2,-MaxValue),label=sort(unique(Dataset$ADM0NAME)),color=c(MyPalette[1:length(unique(Dataset$ADM0NAME))]),hjust=0,)+
      guides(fill=FALSE,alpha=FALSE)
    
    if(!is.null(Date_hovered)){
      DaysHovered<-(Dataset %>% filter(DateReport1==Date_hovered,ADM0NAME==country_hovered))$Days
      DatasetToHighlight<-Dataset %>% filter(Days==DaysHovered) %>% mutate(value=if_else(ADM0NAME==country_hovered,100,0))
      DatasetToHighlight<-DatasetToHighlight %>% arrange(desc(ADM0NAME))
      plot_timeline<-plot_timeline+
        geom_bar(data=DatasetToHighlight,stat='identity',position = 'stack',aes(alpha=value/100),width=1,fill='black',color=alpha('black',0))}
  } 
  
  
  return(plot_timeline)
    }
  

      
TrickLegend<-function(ListCountries){
  Legend_Countries<-Legend %>% filter (Country %in% ListCountries)
TrickLegend<-ggplot(Legend_Countries,aes(x=value,y=5,fill=Country))+
  geom_tile(stat='identity',aes(alpha=value),position='stack')+
  scale_fill_manual(breaks=sort(unique(Legend_Countries$ADM0NAME)),
                    values=c(MyPalette[1:length(ListCountries)]))+
  theme_void()+
  theme(legend.position="none",plot.title=element_text(size=9,face='bold',hjust=0.5))+
  scale_y_continuous(limits=c(-5,NA))+
  scale_x_continuous(limits=c(-50,150))+
  annotate("text", x = -10, y = -3, label = "No measures")+
  annotate("text", x = 110, y = -3, label = "Most severe \n measures")+
  annotate("text",x=50,y=seq(5*length(ListCountries)-2.5,2.5,-5),label=unique(Legend_Countries$Country),color='white')+
  scale_alpha_continuous(range = c(0, 1))+
  labs(title='Severity Index Scale for \nSelected Measures in Selected Countries')
return(TrickLegend)
}

css <- 
  "
#dd {font-size: 10px;valign=0}
#tab2 {background-color:rgba(245, 245, 245, 0.85);padding:10px;margin:10px 100px 5px 100px;border-radius: 10px}
#tab {background-color:#EEF0F2;padding:10px;margin:10px 100px 5px 100px;border-radius: 10px}
#info {font-size: 11px;color:grey}
#titleinfo {font-size: 12px;color:grey}
#note {font-size: 10px}

#internaltab {background-color:white;padding:2px 5px 0px 5px;border-radius: 10px}
#window {background-color:white;padding:5px 5px 5px 5px;margin:5px 5px 5px 5px;border-radius: 5px;}
#DD {font-size: 10px;valign=0;font-weight: bold}

"


#Define UI for application that draws a histogram
ui <- fluidPage(
  
  useShinyjs(),
  
  tags$head(
    tags$style(css),
    tags$style(HTML("
      p {font-size:8pt},

      .selectize-input {
        font-size: 8pt;
        padding: 1px;
        min-height: 10px;
      }
      
      .selectize-dropdown { font-size: 10px; line-height: 10px; padding:0}
      
      .shiny-date-input {
        font-size: 8pt;
        padding: 1px;
        min-height: 20px;
      }
      
      .form-control  {font-size:10px; height: 30px}

      "))
  ),
  
  
  # Application title
  titlePanel(h4("Regional Overview: Daily Cases and Deaths over Severity of Public Health and Social Measures (PHSM)")),
  div(id='note','Last updated on the 9th of November 2020'),
  #uiOutput("hover_info"),
  div(id='tab2',div(id='titleinfo','Please hover over the points on the epicurves for more information'),
      div(id='info',htmlOutput("txt"))),
      

  
  
  div(
    style = "position:relative",
    plotOutput("Epiplot",height=300,hover = hoverOpts("plot_hover", delay=300,delayType = c("debounce", "throttle"))),
    plotOutput("SeverityPlot",height=100),
    #tableOutput('DatasetTest'),
    #uiOutput("hover_info"),
    ),
  
  br(),
  

  div(id='tab',fluidRow(
    column(3,
           div(id="dd",selectInput("country","Select the countries",unique(StringencyIndex$ADM0NAME),multiple=TRUE,selected=Top3_14DaysIncidence())),
           div(id="dd",selectInput("CasesOrDeaths","Cases or Deaths",c("Cases","Deaths"),multiple=FALSE)),
           div(id="dd",selectInput("scale","Select the scale to display the epicurve",c("Normal scale","Log scale"))),
           p("The chart displays by default smoothed curves built on reported values."),
           div(id="dd",checkboxInput("RealVal","Display reported (unsmoothed) values as well",FALSE))),
         
    column(3,
           div(id="dd",selectInput("Index","Select the PHSM of interest",
                                   c("PHSM Severity Index",'Masks',"Schools","Movements","Gatherings","Businesses","International Travel"),multiple=FALSE)),
           div(id="dd",selectInput("timeline","Select the type of timeline",c("Relative to the first implementation of measure selected","Absolute"),
                                   selected=c('Absolute'))),
          div(id="dd",uiOutput("slider"))),
    column(6,
           div(id="DD",'Legends'),
           fluidRow(
             column(6,div(id='window',plotOutput("LegendEpicurve",height=250))),
             column(6,div(id='window',plotOutput("Legend",height=150))))))),)
    

    
    
    


# Define server logic required to draw a histogram
server <- function(input, output,session) {
  
  
  TimeScale <- reactive({
    req(input$timeline)
    case_when (input$timeline=="Relative to the first implementation of measure selected" ~ "Relative",
               input$timeline=="Absolute" ~ "Absolute",
    )})
  
  StartDate<-reactive({
    req(input$country)
    StartDates(input$country)
  })

  EndDate<-reactive({
    req(input$country)
    maxDates(input$country)
  })
  
  ConditionDates<-reactive({
    req(input$country)
    DatesAllowed(input$country,StartDate(),EndDate(),RealValues(),input$CasesOrDeaths,TimeScale(),Measure())
  })
    
  
  
  
  RealValues <- reactive({
    if(input$RealVal==TRUE)
    {"Yes"}
    else{"No"}
  })
  
  Log <- reactive({
    req(input$scale)
    if(input$scale=="Log scale")
    {"True"}
    else{"False"}
  })
  
  output$slider <- renderUI({
    req(StartDate(),EndDate(),Log())
    dateRangeInput("date_range","Date Range",start=StartDate(), end=EndDate())
  })
  
  Measure <- reactive({
    req(input$Index)
    case_when(input$Index=="PHSM Severity Index" ~ "All",
              input$Index=="Schools" ~ "Schools",
              input$Index=="Movements" ~ "Movements",
              input$Index=="Gatherings" ~ "Gatherings",
              input$Index=="Businesses" ~ "Businesses",
              input$Index=="International Travel" ~ "Borders",
              input$Index=="Masks" ~ "Masks") 
  })
  
  
  Dataset_TEST<-reactive({
    req(input$country,Log(),input$CasesOrDeaths,input$date_range[1],input$date_range[2],Measure(),TimeScale())
    Dataset_ToPlot(input$country,Log(),input$CasesOrDeaths,input$date_range[1],input$date_range[2],Measure(),TimeScale())
  })


  
  # MaxValue<-reactive({
  #   req(RealValues(),Dataset_TEST(),Log())
  #   if(RealValues()=='Yes'){
  #     if (Log()=='False'){
  #       value<-round(max((Dataset_TEST() %>% filter(!is.na(RealValue)))$RealValue))
  #       value<-stepsScale(value)$sequence}
  #     if (Log()=='True'){
  #       value<-round(max((Dataset_TEST() %>% filter(!is.na(RealValue)))$RealValue))
  #       value<-10^value}}
  #     
  #   if(RealValues()=='No'){
  #   if (Log()=='False'){
  #   value<-round(max((Dataset_TEST() %>% filter(!is.na(SplineValue)))$SplineValue))
  #   value<-stepsScale(value)$sequence}
  #   if (Log()=='True'){
  #     value<-round(max((Dataset_TEST() %>% filter(!is.na(SplineValue)))$SplineValue))
  #     value<-10^value}}
  #   return(value)
  # })
    
  KeyValues<-reactive({
    req(input$country,Log(),input$CasesOrDeaths,input$date_range[1],input$date_range[2],Measure(),TimeScale())
    Dataset<-Dataset_ToPlot(input$country,Log(),input$CasesOrDeaths,input$date_range[1],input$date_range[2],Measure(),TimeScale())
    Dataset %>% filter(!is.na(Narrative))
  })
  


  output$Epiplot<-renderPlot({
    shiny::validate(
      need(length(input$date_range[1])>0, 'Loading...'))
    plotEpi(input$country,input$date_range[1],input$date_range[2],RealValues(),Log(),input$CasesOrDeaths,TimeScale(),Measure())+
      theme(legend.position="none")
  })
  
  

  
  output$SeverityPlot<-renderPlot({
    shiny::validate(
      need(!is.null(input$country) & !is.null(Log()) & !is.null(input$CasesOrDeaths) & !is.null(input$date_range[1]) &
             !is.null(input$date_range[2]) & !is.null(Measure()) & !is.null(TimeScale()), ''))
    PlotSeverity(input$country,Log(),input$CasesOrDeaths,CountryTest(),DateTest(),input$date_range[1],input$date_range[2],Measure(),TimeScale(),RealValues())
    })

  
  output$Legend<-renderPlot({
    TrickLegend(input$country)
  })


  output$LegendEpicurve<-renderPlot({
    req(input$country,input$date_range[1],input$date_range[2],RealValues(),Log(),input$CasesOrDeaths,TimeScale(),Measure())
    plot<-plotEpi(input$country,input$date_range[1],input$date_range[2],RealValues(),Log(),input$CasesOrDeaths,TimeScale(),Measure())
    plot_grid(get_legend(plot),align='v',axis='t')
  })

  DateTest<-reactive({
    hover <- input$plot_hover
    point <- nearPoints(KeyValues(), hover, threshold = 5, maxpoints = 1, addDist = TRUE)
    if (nrow(point) == 0) return(NULL)
    point$DateReport1
  })
  
  CountryTest<-reactive({
    hover <- input$plot_hover
    point <- nearPoints(KeyValues(), hover, threshold = 5, maxpoints = 1, addDist = TRUE)
    if (nrow(point) == 0) return(NULL)
    point$ADM0NAME
  })
  
  output$txt<-renderUI({ 
      hover <- input$plot_hover
      point <- nearPoints(KeyValues(), hover, threshold = 5, maxpoints = 1, addDist = TRUE)
      #if (nrow(point) == 0) return(' ')
      HTML(paste0("<b>Country: </b>",point$ADM0NAME,"<br/>",'<b>Date: </b>',point$DateReport1,"<br/>", '<b>Events: </b>',point$Narrative))
      
      # wellPanel(
      #   #style = style,
      #   p(HTML(paste0("<b>", point$ADM0NAME, "</b>","<br/>","<b> Date: </b>", point$DateReport1,"<br/>",
      #                 "<b> Events: </b>", point$Narrative)))
      
    })
    
  output$hover_info <- renderUI({
    hover <- input$plot_hover
    point <- nearPoints(KeyValues(), hover, threshold = 5, maxpoints = 1, addDist = TRUE)
    if (nrow(point) == 0) return(NULL)

    # calculate point position INSIDE the image as percent of total dimensions
    # from left (horizontal) and from top (vertical)
    left_pct <- (hover$x - hover$domain$left) / (hover$domain$right - hover$domain$left)
    top_pct <- (hover$domain$top - hover$y) / (hover$domain$top - hover$domain$bottom)

    # calculate distance from left and bottom side of the picture in pixels
    left_px <- hover$range$left + left_pct * (hover$range$right - hover$range$left)
    top_px <- hover$range$top + top_pct * (hover$range$bottom - hover$range$top)

    # create style property fot tooltip
    # background color is set so tooltip is a bit transparent
    # z-index is set so we are sure are tooltip will be on top
    style <- paste0("position:absolute; z-index:100; background-color: rgba(245, 245, 245, 0.85); ",
                    "left:", left_px+10, "px; top:", top_px - 100, "px;")
    

    # actual tooltip created as wellPanel
    wellPanel(
      #style = style,
      p(HTML(paste0("<b>", point$ADM0NAME, "</b>","<br/>","<b> Date: </b>", point$DateReport1,"<br/>",
                    "<b> Events: </b>", point$Narrative)))
    )

  })
    
    
}






# Run the application 
shinyApp(ui = ui, server = server)
