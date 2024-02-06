using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLGetTenantPlanDetails
    {
        public string RunningPlan { get; set; }
        public string eBayPlan { get; set; }

    }
}
