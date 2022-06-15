aws_region  = "eu-west-3"
aws_profile = "udacity_student"

deployment_tag = "developent"
app_name = "instagram_scraper"

container_parameters = [
  {
    image = "955062508589.dkr.ecr.eu-west-3.amazonaws.com/instagramscraper"
    container_name = "scraperMaster"
    public_ports = [5000]
  }
]
