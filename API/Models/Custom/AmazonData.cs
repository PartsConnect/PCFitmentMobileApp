using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PartsConnectWebTools.Models.Custom
{
    public class AmazonData
    {
        public int AmazonDataID { get; set; }
        public string YName { get; set; }
        public string CompanyName { get; set; }
        public string BrandID { get; set; }
        public string ACESXMLTitle { get; set; }
        public DateTime ACESEffectiveDate { get; set; }
        public DateTime SubmissionDate { get; set; }
        public bool IsInProcess { get; set; }

    }
}