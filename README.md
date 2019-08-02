# HTAN_Shiny
## Data Ingest Shiny App

Currently shows a scRNAseq metadata template link on google sheets, then allows for a csv upload and validation based on that file. 

To Use:
- pip install -r the requirements.txt in the htan-data-pipeline
- pip install pygsheet
- specify python 3.5+ (I used a conda env called py3.5 for reticulate, change based on your needs)
- change paths to credentials, etc as needed


To-Do:
- link to synapse project and show project and folder

- option to get previously uploaded manifest
- progress bar for upload
- reactive based on assay input (when we have more templates)

