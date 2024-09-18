using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLAutosync
    {
        public string IsAmazonAccess { get; set; }
        public string IsAmazonAutoSync { get; set; }
        public string IsWalmartAccess { get; set; }
        public string IsWalmartAutoSync { get; set; }
        public string IseBayAccess { get; set; }
        public string IseBayAutoSync { get; set; }
        public string TenantID { get; set; }
    }
}
