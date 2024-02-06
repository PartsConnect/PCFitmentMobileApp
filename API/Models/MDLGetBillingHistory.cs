using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{
    public class MDLGetBillingHistory
    {
        public string ActiveDate { get; set; }
        public string PlanName { get; set; }
        public string FitmentTenantSubscriptionsID { get; set; }
        public string PaymentProvider { get; set; }
        public string Amount { get; set; }
        public string InvoiceUrl { get; set; }

    }

    //public class MDLGetBillingHistoryInfo
    //{
    //    public List<MDLGetBillingHistory> mdlGetBillingHistoryList { get; set; }

    //    public MDLGetBillingHistoryInfo()
    //    {
    //        mdlGetBillingHistoryList = new List<MDLGetBillingHistory>();
    //    }

    //}
}
