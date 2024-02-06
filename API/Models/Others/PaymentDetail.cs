using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PartsConnectWebTools.Models.Custom
{
    public class PaymentDetail
    {
        public string PaymentDetailID { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Add1 { get; set; }
        public string Add2 { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string PostalCode { get; set; }
        public string Country { get; set; }
        public string BillingAmount { get; set; }
        public string CardNumber { get; set; }
        public string ExpMonth { get; set; }
        public string ExpYear { get; set; }
        public string CVC { get; set; }
        public string PlanType { get; set; }
        public string ActivateNow { get; set; }
        public string SubscriptionCode { get; set; }
        public string EndDate { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public string Company { get; set; }
        public string Phone { get; set; }
        public string PaymenntOption { get; set; }
        public string ECATCode { get; set; }
    }
}