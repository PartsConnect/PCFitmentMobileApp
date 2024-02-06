using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{
    public class MDLGetTermsAndConditionAndPrivacyPolicy
    {
        public string IsTermsAndConditionAccept { get; set; }
        public string IsPrivacyPolicyAccept { get; set; }
        public string TermsAndConditionLink { get; set; }
        public string PrivacyPolicyLink { get; set; }
    }
}
