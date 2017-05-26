library(tidyverse)

url       = 'https://portal.edirepository.org/nis/dataviewer?packageid=edi.5.1&entityid=91615b931c54c3aefedd0b048b22344c'
dir_cache = 'data'
csv_cache = file.path(dir_cache, 'int-fish_91615b931c54c3aefedd0b048b22344c.csv')
csv_small = 'data/int-fish_1000rows_91615b931c54c3aefedd0b048b22344c.csv'


# fetch
if (!file.exists(csv_cache)){
  d = read.csv(url,nrows=1000)
  write_csv(d, csv_cache)
}
d = read.csv(csv_cache) # s = spec_csv(csv_cache)

# translate
d2 = d %>% 
  mutate(
    identificationID     = sprintf('%s;%s;%s;%s;%s;%d', date,site_id, subsite_id, proj_taxon_id, transect_id, replicate_id),
    Location             = sprintf('%s_%s', site_name, subsite_name),
    decimalLatitude      = latitude,
    decimalLongitude     = longitude,
    eventDate            = date,
    eventRemarks         = data_source,
    samplingProtocol     = sprintf('%s -- %s', sample_method, sample_subtype),
    sampleSizeValue      = ifelse(is.na(height),           area,  area * height),
    sampleSizeUnit       = ifelse(is.na(height), 'square meter', 'cubic meter'),
    ScientificName       = taxon_name,
    taxonID              = auth_taxon_id,
    nameAccordingToID    = auth_name,
    organismQuantity     = count,
    organismQuantityType = "individual",
    datasetID            = "10.6073/pasta/ae7a51738a412dda3cc7ced221c5e90d",
    basisOfRecord        = "HumanObservation",
    occurrenceStatus     = ifelse(count>0, "present",ifelse(count==0, "absent", "NA"))) %>%
  select(
    identificationID, datasetID,  basisOfRecord, 
    Location, decimalLatitude, decimalLongitude, 
    eventDate, eventRemarks,
    samplingProtocol, sampleSizeValue, sampleSizeUnit,
    ScientificName, taxonID, nameAccordingToID,
    organismQuantity, occurrenceStatus, organismQuantityType)

# output
write_csv(d2, csv_small)

# preview
d2 %>% 
  DT::datatable()
