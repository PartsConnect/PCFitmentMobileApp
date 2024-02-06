using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PartsConnectWebTools.Models.Custom
{
    public class TenantSubscriptionUserDetails
    {
        //ID tenantID SubscriptionID PlanID CustomerID TransactionID PayerID PaypalPlanID unsubscribe_notification_to_admin, subscription_status
        public int ID { get; set; }
        public int tenantID { get; set; }
        public string SubscriptionID { get; set; }
        public string SubscriptionCode { get; set; }
        public string PlanID { get; set; }
        public string CustomerID { get; set; }
        public string TransactionID { get; set; }
        public string PayerID { get; set; }
        public string PaypalPlanID { get; set; }
        public bool unsubscribe_notification_to_admin { get; set; }
        public string subscription_status { get; set; }
        public string StripeInvoiceId { get; set; }          
        public long StripeAmountPaid { get; set; }
        public long StripeAmountDue { get; set; }
        public int BillingAmount { get; set; }
    }
}