using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PartsConnectWebTools.Models.Custom
{
    public class TenantsSubscriptionModel
    {
        public string FitmentTenantSubscriptionsID { get; set; }
        public string TenantID { get; set; }
        public string CustomerID { get; set; }
        public string stripeToken { get; set; }
        public string SubscriptionCode { get; set; }
        public string Email { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Address1 { get; set; }
        public string Address2 { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string Postal { get; set; }
        public string CardNumber { get; set; }
        public string Cvc { get; set; }
        public string IsActive { get; set; }
        public string LastBilled { get; set; }
        public string Created { get; set; }
        public string Country { get; set; }
        public string Company { get; set; }
        public string Phone{ get; set; }
        public string PlanName { get; set; }
        public string BillingAmount { get; set; }
        public string Amount { get; set; }
        public string EndDate { get; set; }
        public string ActiveDate { get; set; }
        public string ActivationDate { get; set; }
        public string ActivateNow { get; set; }
        public string ExpirationYear { get; set; }
        public string ExpirationMonth { get; set; }
        public string Name { get; set; }
        public string SubscriptionID { get; set; }
        public string StripePlanID { get; set; }
        public string TransactionID { get; set; }
        public string PayerID { get; set; }
        public string PaypalPlanID { get; set; }
        public string NextBilligDate { get;  set; }
        public string StripeInvoiceId { get; set; }
        public string StripeAmountPaid { get; set; }
        public string StripeAmountDue { get; set; }
        public string PaymentProvider { get; set; }
        public string ECATCode { get; set; }
        public string GiftCodeID { get; set; }        
    }
}