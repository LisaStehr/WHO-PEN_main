Code for the paper:
"Decentralizing Health Services for Diabetes and Hypertension in Eswatini: Findings from the Nationwide Cluster-Randomized Controlled WHO-PEN@Scale Trial"

This repository contains code and resources related to the WHO-PEN@Scale project, a nationwide cluster-randomized controlled trial in Eswatini. The study utilized data from a nationwide household survey conducted as part of the WHO-PEN@Scale initiative (https://whopenatscale.com/).

The full study protocol for this trial is available here: https://ntnuopen.ntnu.no/ntnu-xmlui/bitstream/handle/11250/3097328/Theilmann.pdf?sequence=2&isAllowed=y.

    Data Cleaning: Performed using STATA.
    Data Management and Analysis: Conducted in R (version 4.1.2, released 2021-11-01).

A sample dataset required to run the provided code can be found in the folder named 'data'. The code for data cleaning and analysis, along with the corresponding codebook, is located in the folder named 'code'.

### Example Code
```R
# Example function to perform basic data analysis
demo_function <- function(data) {
  summary_stats <- data %>% 
    summarize(
      mean_value = mean(value, na.rm = TRUE),
      median_value = median(value, na.rm = TRUE),
      sd_value = sd(value, na.rm = TRUE)
    )
  return(summary_stats)
}

# Example usage
data <- data.frame(id = 1:100, value = rnorm(100))
result <- demo_function(data)
print(result)
```

### Small Dataset for Demonstration
```R
# Example small dataset
data <- data.frame(
  id = 1:10,
  value = c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
)
write.csv(data, "demo_dataset.csv", row.names = FALSE)
```

---

### System Requirements

#### Software Dependencies
- R version: 4.0.5 or higher
- Required R packages: 
  - dplyr (>= 1.0.0)
  - survey

#### Operating Systems
- Windows (10, 11)
- macOS (10.15 and above)
- Linux (Ubuntu 20.04 and above)

#### Tested Versions
- R 4.0.5 on Windows 10
- R 4.0.5 on Ubuntu 20.04

#### Non-Standard Hardware
- No non-standard hardware is required.

---

### Installation Guide

#### Instructions
1. Install R from [CRAN](https://cran.r-project.org/).
2. Install the required package:
   ```R
   install.packages("dplyr")
   ```
3. Download the `demo_function` script and dataset.

#### Typical Install Time
- Approximately 1-2 minutes on a standard desktop computer.

---

### Demo

#### Instructions to Run on Data
1. Load the required library:
   ```R
   library(dplyr)
   ```
2. Load the demo dataset:
   ```R
   demo_data <- read.csv("demo_dataset.csv")
   ```
3. Run the function on the dataset:
   ```R
   demo_result <- demo_function(demo_data)
   print(demo_result)
   ```

#### Expected Output
```
  mean_value median_value sd_value
1        55          55   31.62278
```

#### Expected Run Time
- The demo should execute in less than 1 second on a standard desktop computer.

---

### Instructions for Use can be found in the respective Rmd/do files

---

