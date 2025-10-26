#EBILL Dev environment setup
#DEFAULT SETUP
project_name = "moba025ebill"
region       = "US"

#PROJECT ID NEEDS TO BE MENTIONED BELOW
project_id  = "cnr-moba025ebill-dev-d28b"


#Global HTTPS loadbalancer values
#LOAD BALANCER SETUP PARAMETERS
global_ip_address_name          = "ebill"
loadbalancername                = "ebill-httpsserverless-loadbalancer"
app                             = "ebill"
env                             = "dev"
hosts                           = ["srv.ebill-fb-dev.web.cn.ca"]
ssl                             = true
dns_suffix                      = "web.cn.ca"
lb_region                       = ["northamerica-northeast1","us-central1"]
neg_region_list                 = ["northamerica-northeast1","us-central1"]
managed_ssl_certificate_domains = ["srv.ebill-fb-dev.web.cn.ca"]
default_backend_function        = "putUpdateLegacyInvoice"
