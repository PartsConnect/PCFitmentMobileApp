using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLGetDashboardRequiredData
    {
        public List<MDLGetTenantPlanDetails> TenantPlanDetails { get; set; }
        public List<MDLGetFitmentsSummary> FitmentsSummary { get; set; }
        public List<MDLGetMostRecentExport> MostRecentExport { get; set; }
        public string IsUserExpired { get; set; } = "No";
        public MDLGetDashboardRequiredData() 
        {
            TenantPlanDetails = new List<MDLGetTenantPlanDetails>();
            FitmentsSummary = new List<MDLGetFitmentsSummary>();
            MostRecentExport = new List<MDLGetMostRecentExport>();
        }
    }
}
