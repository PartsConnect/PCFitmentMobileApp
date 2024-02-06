using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLGetTenantDetails
    {
        public string ID { get; set; }
       
        public string Name { get; set; }
        public string Address1 { get; set; }
        public string Address2 { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string Province { get; set; }
        public string Zipcode { get; set; }
        public string CreateDate { get; set; }
        public string CreateBy { get; set; }
        public string Email { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Phone { get; set; }
        public string Company { get; set; }
        public string Country { get; set; }
        public string DataProviderName { get; set; }
        public string CustomerID { get; set; }
        public string InActive { get; set; }
        public string apiusername { get; set; }
        public string apipassword { get; set; }
        public string IseBayAccess { get; set; }
        public string IsUniversalPartAccess { get; set; }
        public string IsCustomFitmentsAccess { get; set; }
        public string IsMultiBrandAccess { get; set; }
        public string IsMailNotification { get; set; }
        public string BrandLimit { get; set; }
        public string IsBigCommerceAccess { get; set; }
        public string IsWalmartAccess { get; set; }
        public string IsWalmartSetupDone { get; set; }
        public string WeChatID { get; set; }
    }
}
