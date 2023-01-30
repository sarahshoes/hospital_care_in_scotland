## Hospital Care in Scotland - Impact of Covid-19 and Winter

### Background to Project
This was a group project carried out over seven days. The brief was to investigate to what extent the ‘winter crises’ reported in the media are real and determine how Covid has affected acute care in Scotland. The findings were presented via an R Shiny dashboard and presentation. 

The dashboard outlines the topic in terms of a journey through the hospital system from admission, to treatment and then finally discharge. It contains a front page summary which also allows data to be investigated by health board, followed by further tabs which cover admission, treatment and discharge. A tab for statistical analysis of the winter/summer difference is also included. 

### Names of Group Members
Fiona Carson, Sarah Hughes and Malcolm Speight

### Stages of the Project
A large amount of background reading was conducted at the start of the project to help with the questions in the brief. Crises in the NHS is topical at the moment and there are a large number of media reports available.

The data links provided in the brief were investigated and other data was also sourced from the Public Health Scotland website. This stage of the project involved high level analysis such as determining what variables were in the data and what time periods the data was collected over.

The git folder structure was set up and the repository shared.

Once the data was better understood we discussed the key datasets that would help answer the brief. These key datasets were divided among team members and then analysed in detail to determine trends in time and by geography, age and deprivation.

Planning the structure of the dashboard was conducted on pen and paper. Once this was agreed, a more detailed dashboard outline was created and shared through Miro.

Cleaning and wrangling the data was a time consuming task, which was followed by preparing suitable graphs. Getting the datasets into standard formats where possible was important to help make the dahsboard buil smoother. A graph theme, colour palette and plotting function were created to simplify the visualisation step and ensure our plots were consistent.

The outline of an R Shiny app was created and then populated according to the original plan.

It was difficult to visualise the contents of our front page summary tab at the start of the project so this was designed and built after the rest of the app was working.

The app was extensively tested to ensure it worked as it should and all data was displayed as expected.

Finally the documentation was completed and a presentation prepared.



### Ethical Considerations
Some of the datasets had flags for confidentiality, meaning that values were low enough that they could identify and individual. This meant that patient numbers are underestimated in some of teh health boards with lower patient numbers. To limit the effect that this would have we imputed missing values as 1 (making the assumption that at least one patient was there), but only in cased were we were aggregating further. Once aggregated there are no further issues with confidentiality.

There are some ethical considerations around publishing waiting time data. As described in the data bias section different waiting times will be calculated depending on whether you use the completed or patients still waiting datasets. This could lead to patients having unrealistic expectations for how quickly they will be seen for a particular condition.


### Tools Used
- Zoom (daily stand-ups and catch ups early and late afternoon)
- Slack (for arranging meetings, asking questions and updating team on minor issues / changes)
- Trello (planning & task allocation)
- Git/GitHub (collaboration & version control)
- Miro (creating dashboard outline)
- R Studio (data analysis, creating dashboard and documentation)
- Keynote (for presentation)


