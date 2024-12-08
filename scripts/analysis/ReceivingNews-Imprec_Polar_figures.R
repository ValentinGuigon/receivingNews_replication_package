
##### VARIABLES #####

# Free memory
rm(list = ls(all.names = TRUE)) #will clear all ofbjects includes hidden objects.
gc() #free up memory and report the memory usage

list.of.packages <- c("ggplot2", "sjPlot", "tidyverse", "ggpubr","RColorBrewer",
                      "rprojroot", "patchwork") 
{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}

project_root = find_rstudio_root_file()

dRec <- read.csv(paste(project_root,"/data/processed/receivingNews_data.csv", sep=""))
source(paste(project_root,"/scripts/src/utility/ReceivingNews_analysis_utility.R", sep=""))

dRec = rename_variables(dRec)
nan_str_count = check_nan_strings(dRec)
dRec = correct_nan_strings(dRec, nan_str_count)
dRec = mutate_values(dRec)
dRec = mutate_types(dRec)
dRec = dRec %>% mutate(Veracity = relevel(Veracity, "False"))
dRec = dRec %>% mutate(Judgment = relevel(Judgment, "False"))
dRec <- dRec%>% mutate(Judgment = ifelse(Judgment == "False", "0", "1"))


# Add a column for the Imprecision valence
dRec <- dRec %>%
  mutate(Imprecision_Valence = case_when(
    Imprecision < quantile(Imprecision, 0.3) ~ "Precise",
    Imprecision > quantile(Imprecision, 0.7) ~ "Imprecise",
    TRUE ~ "Neutral"  # The default case if none of the above conditions are met
  ))

# Add a column for the Polarization valence
dRec <- dRec %>%
  mutate(Polarization_Valence = case_when(
    Polarization < quantile(Polarization, 0.3) ~ "Consensual",
    Polarization > quantile(Polarization, 0.7) ~ "Polarizing",
    TRUE ~ "Neutral"  # The default case if none of the above conditions are met
  ))


# Subset to get rid of neutral values
dRec_Imprecision = dRec[dRec$Imprecision_Valence != "Neutral",]
dRec_Polarization = dRec[dRec$Polarization_Valence != "Neutral",]

# Convert Success to numeric
dRec_Imprecision$Success <- as.numeric(as.character(dRec_Imprecision$Success))
dRec_Polarization$Success <- as.numeric(as.character(dRec_Polarization$Success))

dRec_Imprecision$Judgment <- as.numeric(as.character(dRec_Imprecision$Judgment))
dRec_Polarization$Judgment <- as.numeric(as.character(dRec_Polarization$Judgment))

dRec_Imprecision$Reception <- as.numeric(as.character(dRec_Imprecision$Reception))
dRec_Polarization$Reception <- as.numeric(as.character(dRec_Polarization$Reception))





##### SUCCESS MEAN #####

### IMPRECISION
# Compute proportion data using the subject-wise mean
success_proportion_data_Imprecision <- dRec_Imprecision %>%
  group_by(Imprecision_Valence, Veracity, Subject) %>%
  summarize(Proportion_Success = sum(Success == 1) / n())

# Reorder levels for facet_grid and Valence
success_proportion_data_Imprecision$Veracity <- factor(success_proportion_data_Imprecision$Veracity, levels = c("False", "True"))
success_proportion_data_Imprecision$Imprecision_Valence <- factor(success_proportion_data_Imprecision$Imprecision_Valence, levels = c("Precise", "Imprecise"))

# Boxplot to show the distribution of the data
success_imprecision_boxplot <- ggplot(success_proportion_data_Imprecision, aes(x = Imprecision_Valence, y = Proportion_Success, fill = Veracity)) +
  geom_boxplot(position = position_dodge(width = 0.9), color = "black", width = 0.7) +
  labs(title = "Imprecision",
       x = NULL,
       y = "Correct judgments") +
  theme_minimal() + 
  theme(axis.text.x = element_text(size = 14, color = "black"),  # Adjust x-axis text size
        axis.text.y = element_text(size = 14, color = "black"),  # Adjust y-axis text size
        axis.title = element_text(size = 18),
        legend.title = element_text(size = 14), 
        legend.text = element_text(size = 14), 
        plot.title = element_text(size = 20, hjust = 0.5)) +  # Adjust title size
  labs(fill = "Veracity:") +  
  theme(strip.text.y = element_text(angle = 0)) +  # Adjust the angle of facet labels 
  theme(legend.position = "none") + 
  coord_cartesian(ylim = c(0, 1)) + # Adjust y-axis limits
  scale_y_continuous(breaks = seq(0, 1, by = 0.1))


### POLARIZATION
# Compute proportion data using the subject-wise mean
success_proportion_data_Polarization <- dRec_Polarization %>%
  group_by(Polarization_Valence, Veracity, Subject) %>%
  summarize(Proportion_Success = sum(Success == 1) / n())

# Reorder levels for facet_grid and Valence
success_proportion_data_Polarization$Veracity <- factor(success_proportion_data_Polarization$Veracity, levels = c("False", "True"))
success_proportion_data_Polarization$Polarization_Valence <- factor(success_proportion_data_Polarization$Polarization_Valence, levels = c("Consensual", "Polarizing"))

# Boxplot to show the distribution of the data
success_Polarization_boxplot <- ggplot(success_proportion_data_Polarization, aes(x = Polarization_Valence, y = Proportion_Success, fill = Veracity)) +
  geom_boxplot(position = position_dodge(width = 0.9), color = "black", width = 0.7) +
  labs(title = "Polarization",
       x = NULL,
       y = NULL) +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 14, color = "black"),  # Adjust x-axis text size
        axis.text.y = element_text(size = 14, color = "black"),  # Adjust y-axis text size
        axis.title = element_text(size = 18)) +
  theme(legend.title = element_text(size = 18)) + 
  theme(legend.text = element_text(size = 18),
        axis.title.y = element_text(size = 18),
        axis.title.x = element_text(size = 18),
        plot.title = element_text(size = 20, hjust = 0.5)) +  # Adjust title size
  theme(strip.text.y = element_text(angle = 0)) +  # Adjust the angle of facet labels 
  theme(legend.position = "none") + 
  coord_cartesian(ylim = c(0, 1)) +  # Adjust y-axis limits
  scale_y_continuous(breaks = seq(0, 1, by = 0.1))





##### JUDGMENT MEAN #####

### IMPRECISION
# Compute proportion data using the subject-wise mean
judgment_proportion_data_Imprecision <- dRec_Imprecision %>%
  group_by(Imprecision_Valence, Veracity, Subject) %>%
  summarize(Proportion_Judgment = sum(Judgment == 1) / n())

# Reorder levels for facet_grid and Valence
judgment_proportion_data_Imprecision$Veracity <- factor(judgment_proportion_data_Imprecision$Veracity, levels = c("False", "True"))
judgment_proportion_data_Imprecision$Imprecision_Valence <- factor(judgment_proportion_data_Imprecision$Imprecision_Valence, levels = c("Precise", "Imprecise"))

# Boxplot to show the distribution of the data
judgment_imprecision_boxplot <- ggplot(judgment_proportion_data_Imprecision, aes(x = Imprecision_Valence, y = Proportion_Judgment, fill = Veracity)) +
  geom_boxplot(position = position_dodge(width = 0.9), color = "black", width = 0.7) +
  labs(title = "Imprecision",
       x = NULL,
       y = "Judgments as true") +
  theme_minimal() + 
  theme(axis.text.x = element_text(size = 14, color = "black"),  # Adjust x-axis text size
        axis.text.y = element_text(size = 14, color = "black"),  # Adjust y-axis text size
        axis.title = element_text(size = 18),
        legend.title = element_text(size = 14), 
        legend.text = element_text(size = 14), 
        plot.title = element_text(size = 20, hjust = 0.5)) +  # Adjust title size
  labs(fill = "Veracity:") +  
  theme(strip.text.y = element_text(angle = 0)) +  # Adjust the angle of facet labels 
  theme(legend.position = "none") + 
  coord_cartesian(ylim = c(0, 1)) + # Adjust y-axis limits
  scale_y_continuous(breaks = seq(0, 1, by = 0.1))





### Polarization
# Compute proportion data using the subject-wise mean
judgment_proportion_data_Polarization <- dRec_Polarization %>%
  group_by(Polarization_Valence, Veracity, Subject) %>%
  summarize(Proportion_Judgment = sum(Judgment == 1) / n())

# Reorder levels for facet_grid and Valence
judgment_proportion_data_Polarization$Veracity <- factor(judgment_proportion_data_Polarization$Veracity, levels = c("False", "True"))
judgment_proportion_data_Polarization$Polarization_Valence <- factor(judgment_proportion_data_Polarization$Polarization_Valence, levels = c("Consensual", "Polarizing"))

# Boxplot to show the distribution of the data
judgment_Polarization_boxplot <- ggplot(judgment_proportion_data_Polarization, aes(x = Polarization_Valence, y = Proportion_Judgment, fill = Veracity)) +
  geom_boxplot(position = position_dodge(width = 0.9), color = "black", width = 0.7) +
  labs(title = "Polarization",
       x = NULL,
       y = NULL) +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 14, color = "black"),  # Adjust x-axis text size
        axis.text.y = element_text(size = 14, color = "black"),  # Adjust y-axis text size
        axis.title = element_text(size = 18)) +
  theme(legend.title = element_text(size = 18)) + 
  theme(legend.text = element_text(size = 18),
        axis.title.y = element_text(size = 18),
        axis.title.x = element_text(size = 18),
        plot.title = element_text(size = 20, hjust = 0.5)) +  # Adjust title size
  theme(strip.text.y = element_text(angle = 0)) +  # Adjust the angle of facet labels 
  theme(legend.position = "none") + 
  coord_cartesian(ylim = c(0, 1)) +  # Adjust y-axis limits
  scale_y_continuous(breaks = seq(0, 1, by = 0.1))





##### RECEPTION MEAN #####

### IMPRECISION
# Compute proportion data using the subject-wise mean
reception_proportion_data_Imprecision <- dRec_Imprecision %>%
  group_by(Imprecision_Valence, Veracity, Subject) %>%
  summarize(Proportion_Reception = sum(Reception == 1) / n())

# Reorder levels for facet_grid and Valence
reception_proportion_data_Imprecision$Veracity <- factor(reception_proportion_data_Imprecision$Veracity, levels = c("False", "True"))
reception_proportion_data_Imprecision$Imprecision_Valence <- factor(reception_proportion_data_Imprecision$Imprecision_Valence, levels = c("Precise", "Imprecise"))

# Boxplot to show the distribution of the data
reception_imprecision_boxplot <- ggplot(reception_proportion_data_Imprecision, aes(x = Imprecision_Valence, y = Proportion_Reception, fill = Veracity)) +
  geom_boxplot(position = position_dodge(width = 0.9), color = "black", width = 0.7) +
  labs(title = "Imprecision",
       x = NULL,
       y = "Choices to receive") +
  theme_minimal() + 
  theme(axis.text.x = element_text(size = 14, color = "black"),  # Adjust x-axis text size
        axis.text.y = element_text(size = 14, color = "black"),  # Adjust y-axis text size
        axis.title = element_text(size = 18),
        legend.title = element_text(size = 14), 
        legend.text = element_text(size = 14), 
        plot.title = element_text(size = 20, hjust = 0.5)) +  # Adjust title size
  labs(fill = "Veracity:") +  
  theme(strip.text.y = element_text(angle = 0)) +  # Adjust the angle of facet labels 
  theme(legend.position = "none") + 
  coord_cartesian(ylim = c(0, 1)) + # Adjust y-axis limits
  scale_y_continuous(breaks = seq(0, 1, by = 0.1))





### Polarization
# Compute proportion data using the subject-wise mean
reception_proportion_data_Polarization <- dRec_Polarization %>%
  group_by(Polarization_Valence, Veracity, Subject) %>%
  summarize(Proportion_Reception = sum(Reception == 1) / n())

# Reorder levels for facet_grid and Valence
reception_proportion_data_Polarization$Veracity <- factor(reception_proportion_data_Polarization$Veracity, levels = c("False", "True"))
reception_proportion_data_Polarization$Polarization_Valence <- factor(reception_proportion_data_Polarization$Polarization_Valence, levels = c("Consensual", "Polarizing"))

# Boxplot to show the distribution of the data
reception_Polarization_boxplot <- ggplot(reception_proportion_data_Polarization, aes(x = Polarization_Valence, y = Proportion_Reception, fill = Veracity)) +
  geom_boxplot(position = position_dodge(width = 0.9), color = "black", width = 0.7) +
  labs(title = "Polarization",
       x = NULL,
       y = NULL) +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 14, color = "black"),  # Adjust x-axis text size
        axis.text.y = element_text(size = 14, color = "black"),  # Adjust y-axis text size
        axis.title = element_text(size = 18)) +
  theme(legend.title = element_text(size = 18)) + 
  theme(legend.text = element_text(size = 18),
        axis.title.y = element_text(size = 18),
        axis.title.x = element_text(size = 18),
        plot.title = element_text(size = 20, hjust = 0.5)) +  # Adjust title size
  theme(strip.text.y = element_text(angle = 0)) +  # Adjust the angle of facet labels 
  theme(legend.position = "none") + 
  coord_cartesian(ylim = c(0, 1)) +  # Adjust y-axis limits
  scale_y_continuous(breaks = seq(0, 1, by = 0.1))





##### SAVE #####

save.image(paste(project_root, "/R_environments/ReceivingNews-Imprec_Polar_figures_env.RData",sep=""))

invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
