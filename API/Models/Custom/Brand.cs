using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PartsConnectWebTools.Models.Custom
{
    public class Brand
    {
        public string Company { get; set; }
        public string Phone { get; set; }
        public string BrandCode { get; set; }
        public string BrandName { get; set; }
        public int TenantID { get; set; }
        public int ID { get; set; }
        public int Total { get; set; }
        public string IsBrandVerifiedtxt { get; set; }
    }
}